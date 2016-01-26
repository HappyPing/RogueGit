//
//  CBBrowsePictureScrollView.m
//  91muzu
//
//  Created by ios app on 16/1/15.
//  Copyright © 2016年 cb2015. All rights reserved.
//

#import "JPBrowsePictureScrollView.h"
#import <AVFoundation/AVFoundation.h>
#import "UIImageView+WebCache.h"

#define PictureSpace 20
#define AnimateDuration 0.3



/* 可浏览图片model */
@implementation JPBrowsePicture

-(instancetype)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    if (self) {
        self.backgroundColor=[UIColor clearColor];
        self.contentMode=UIViewContentModeScaleAspectFit;
    }
    return self;
}

+(instancetype)buildBrowsePictureWithOriginalFrame:(CGRect)originalFrame andImage:(UIImage *)image byImageUrl:(NSString *)imageUrl{
    JPBrowsePicture *browsePicture=[[JPBrowsePicture alloc]initWithFrame:originalFrame];
    browsePicture.originalFrame=originalFrame;
    browsePicture.backgroundColor=[UIColor clearColor];
    browsePicture.image=image;
    browsePicture.imageUrl=imageUrl;
    return browsePicture;
}

@end







/* 每一页的ScrollView（上面放着可浏览图片model） */
@interface JPBrowsePictureSubScrollView ()<UIScrollViewDelegate>

@end

@implementation JPBrowsePictureSubScrollView

-(instancetype)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    if (self) {
        
        self.contentSize=self.frame.size;
        
        self.showsHorizontalScrollIndicator=NO;
        self.showsVerticalScrollIndicator=NO;
        
        self.delegate=self;
        self.backgroundColor=[UIColor clearColor];
        
        self.maximumZoomScale=1.0;
        self.minimumZoomScale=1.0;
        
        UITapGestureRecognizer *doubleTapGR=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(enlargeOrReturn:)];
        doubleTapGR.numberOfTapsRequired=2;
        self.doubleTapGR=doubleTapGR;
        [self addGestureRecognizer:doubleTapGR];
        
    }
    return self;
}

-(void)addBrowsePicture:(JPBrowsePicture *)browsePicture{
    self.browsePicture=browsePicture;
    
    [self addSubview:self.browsePicture];
    
    self.maskLayer=[CALayer layer];
    self.maskLayer.frame=self.bounds;
    self.maskLayer.backgroundColor=[UIColor blackColor].CGColor;
    self.maskLayer.opacity=0.7 ;    //透明度
    self.maskLayer.hidden=YES;
    [self.layer addSublayer:self.maskLayer];
    
    self.progressLayer=[CAShapeLayer layer];
    self.progressLayer.frame=CGRectMake(self.frame.size.width/2 - 20, self.frame.size.height/2 - 20, 40, 40);
    self.progressLayer.cornerRadius=20;
    self.progressLayer.backgroundColor=[UIColor colorWithWhite:0.000 alpha:0.500].CGColor;
    UIBezierPath *path=[UIBezierPath bezierPathWithRoundedRect:CGRectInset(self.progressLayer.bounds, 7, 7) cornerRadius:(40 / 2 - 7)];
    self.progressLayer.path = path.CGPath;
    self.progressLayer.fillColor=[UIColor clearColor].CGColor;
    self.progressLayer.strokeColor=[UIColor whiteColor].CGColor;
    self.progressLayer.lineWidth=4;
    self.progressLayer.lineCap=kCALineCapRound;
    self.progressLayer.strokeStart=0;
    self.progressLayer.strokeEnd=0;
    self.progressLayer.hidden=YES;
    [self.layer addSublayer:self.progressLayer];
}

//双击放大、还原
-(void)enlargeOrReturn:(UITapGestureRecognizer *)doubleTapGR{
    if (self.zoomScale>1) {
        [self setZoomScale:1.0 animated:YES];
    }else{
        CGPoint touchPoint = [doubleTapGR locationInView:self.browsePicture];
        CGFloat newZoomScale = self.maximumZoomScale;
        CGFloat xsize = self.frame.size.width / newZoomScale;
        CGFloat ysize = self.frame.size.height / newZoomScale;
        [self zoomToRect:CGRectMake(touchPoint.x - xsize/2, touchPoint.y - ysize/2, xsize, ysize) animated:YES];
    }
}

#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return  self.browsePicture;
}

//让图片居中（当图片不是在scrollView的顶部，缩放时会在上方留下一截）
- (void)scrollViewDidZoom:(UIScrollView *)aScrollView{
    CGFloat offsetX = (aScrollView.bounds.size.width > aScrollView.contentSize.width)?
    (aScrollView.bounds.size.width - aScrollView.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (aScrollView.bounds.size.height > aScrollView.contentSize.height)?
    (aScrollView.bounds.size.height - aScrollView.contentSize.height) * 0.5 : 0.0;
    self.browsePicture.center = CGPointMake(aScrollView.contentSize.width * 0.5 + offsetX,aScrollView.contentSize.height * 0.5 + offsetY);
}


@end






/* 底层（包含所有页）ScrollView */
@interface JPBrowsePictureScrollView ()<UIScrollViewDelegate>
@property(nonatomic,strong)UIView *showView;
@property(nonatomic,assign)NSInteger currentPage;
@property(nonatomic,weak)UIPageControl *pageControl;

@property(nonatomic,strong)NSMutableArray<JPBrowsePicture *> *allBrowsePictures;
@property(nonatomic,strong)NSMutableArray<JPBrowsePictureSubScrollView *> *subBrowsePictureScrollViews;
@end

@implementation JPBrowsePictureScrollView

-(NSMutableArray<JPBrowsePicture *> *)allBrowsePictures{
    if (!_allBrowsePictures) {
        _allBrowsePictures=[NSMutableArray array];
    }
    return _allBrowsePictures;
}

-(NSMutableArray<JPBrowsePictureSubScrollView *> *)subBrowsePictureScrollViews{
    if (!_subBrowsePictureScrollViews) {
        _subBrowsePictureScrollViews=[NSMutableArray array];
    }
    return _subBrowsePictureScrollViews;
}

+(instancetype)buildBrowsePictureScrollViewOnView:(UIView *)view withAllBrowsePicture:(NSArray<JPBrowsePicture *> *)allBrowsePicture andCurrentPage:(NSInteger)currentPage{
    
    JPBrowsePictureScrollView *mainScrollView=[[JPBrowsePictureScrollView alloc]initWithFrame:CGRectMake(-PictureSpace/2, 0, view.frame.size.width+PictureSpace, view.frame.size.height)];
    
    mainScrollView.showView=view;
    [mainScrollView.allBrowsePictures addObjectsFromArray:allBrowsePicture];
    
    mainScrollView.backgroundColor=[UIColor blackColor];
    mainScrollView.pagingEnabled=YES;
    mainScrollView.delegate=mainScrollView;
    mainScrollView.showsHorizontalScrollIndicator=NO;
    mainScrollView.showsVerticalScrollIndicator=NO;
    mainScrollView.contentSize=CGSizeMake((view.bounds.size.width+PictureSpace)*mainScrollView.allBrowsePictures.count,view.bounds.size.height);

    UITapGestureRecognizer *tapGR=[[UITapGestureRecognizer alloc]initWithTarget:mainScrollView action:@selector(dismiss:)];
    [mainScrollView addGestureRecognizer:tapGR];
    
    for (int i=0;i<mainScrollView.allBrowsePictures.count;i++) {
        
        JPBrowsePicture *browsePicture=mainScrollView.allBrowsePictures[i];
        
        //创建子scrollView
        JPBrowsePictureSubScrollView *subBrowsePictureScrollView=[[JPBrowsePictureSubScrollView alloc]initWithFrame:CGRectMake(i*(view.bounds.size.width+PictureSpace/2)+(PictureSpace/2)*(i+1), 0, view.bounds.size.width, view.bounds.size.height)];
        
        [tapGR requireGestureRecognizerToFail:subBrowsePictureScrollView.doubleTapGR];
        
        if (currentPage==i) {
            mainScrollView.currentPage=i;
            browsePicture.isBorn=YES;
            NSLog(@"111 %@",NSStringFromCGRect(browsePicture.originalFrame));
        }else{
            browsePicture.center=mainScrollView.center;
        }
        
        [subBrowsePictureScrollView addBrowsePicture:browsePicture];

        [mainScrollView.subBrowsePictureScrollViews addObject:subBrowsePictureScrollView];
        [mainScrollView addSubview:subBrowsePictureScrollView];
        
    }
  
    [mainScrollView setContentOffset:CGPointMake(mainScrollView.currentPage*(view.bounds.size.width+PictureSpace/2)+(PictureSpace/2)*mainScrollView.currentPage, 0)];
    /*不知道为什么设置偏移量之后 currentPage 属性就置零了！！ */
    
    return mainScrollView;
}

-(void)show{
    [self.showView addSubview:self];
    
    self.currentPage=(NSInteger)self.contentOffset.x/self.bounds.size.width;
    
    UIPageControl *pageControl=[[UIPageControl alloc]init];
    pageControl.numberOfPages=self.allBrowsePictures.count;
    pageControl.center=CGPointMake(self.center.x, self.frame.size.height-50);
    
    self.pageControl=pageControl;
    self.pageControl.currentPage=self.currentPage;
    [self.showView addSubview:pageControl];
    
    for (JPBrowsePictureSubScrollView *subBp in self.subBrowsePictureScrollViews) {
        CGRect bigFrame=AVMakeRectWithAspectRatioInsideRect(subBp.browsePicture.image.size,self.showView.bounds);
        subBp.browsePicture.enlargeFrame=bigFrame;
        
        if (subBp.browsePicture.isBorn) {
            [UIView animateWithDuration:AnimateDuration delay:0 usingSpringWithDamping:0.2 initialSpringVelocity:1.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                
                [UIApplication sharedApplication].statusBarStyle=UIStatusBarStyleLightContent;
                
                subBp.browsePicture.frame=bigFrame;
                
            } completion:nil];
       
        }else{
            
            subBp.browsePicture.frame=bigFrame;
            
        }
        
        [subBp.browsePicture sd_setImageWithURL:[NSURL URLWithString:subBp.browsePicture.imageUrl] placeholderImage:subBp.browsePicture.image options:SDWebImageLowPriority progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            subBp.maskLayer.hidden=NO;
            subBp.progressLayer.hidden=NO;
            float progress=(float)receivedSize/(float)expectedSize;
            [subBp.progressLayer setStrokeEnd:progress];
        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (image) {
                subBp.browsePicture.image=image;
                
                CGFloat xScale=subBp.frame.size.width/subBp.browsePicture.bounds.size.width;
                CGFloat yScale=subBp.frame.size.height/subBp.browsePicture.bounds.size.height;
                subBp.maximumZoomScale=MAX(xScale, yScale);
                subBp.minimumZoomScale=MIN(xScale, yScale);
                
                subBp.progressLayer.hidden=YES;
                subBp.maskLayer.hidden=YES;
            }
        }];
    }

    
}

//点击返回
-(void)dismiss:(UITapGestureRecognizer*)tapGR{
    if (self.subBrowsePictureScrollViews[self.currentPage].zoomScale!=1.0) {
        [self.subBrowsePictureScrollViews[self.currentPage] setZoomScale:1.0];
    }
    
    JPBrowsePicture *bp=self.subBrowsePictureScrollViews[self.currentPage].browsePicture;
    [UIView animateWithDuration:AnimateDuration animations:^{
        [UIApplication sharedApplication].statusBarStyle=UIStatusBarStyleDefault;
        self.backgroundColor=[UIColor clearColor];
        self.pageControl.alpha=0;
        bp.frame=bp.originalFrame;
    } completion:^(BOOL finished) {
        [self.pageControl removeFromSuperview];
        [self removeFromSuperview];
    }];
}

#pragma mark - UIScrollViewDelegate
//监听滚动
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    double page=scrollView.contentOffset.x/scrollView.bounds.size.width;
    //使用四舍五入计算出页码（当滚动视图滚动到下一页差不多一半时，页面点数变成下一点）
    self.pageControl.currentPage=(int)(page+0.5);
    self.currentPage=self.pageControl.currentPage;

}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    JPBrowsePictureSubScrollView *subScrollView=self.subBrowsePictureScrollViews[self.currentPage];
    if (subScrollView.zoomScale!=1.0) {
        [subScrollView setZoomScale:1.0 animated:YES];
    }
}

@end
