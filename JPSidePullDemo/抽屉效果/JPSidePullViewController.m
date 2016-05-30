//
//  ViewController.m
//  抽屉效果
//
//  Created by ios app on 16/5/11.
//  Copyright © 2016年 cb2015. All rights reserved.
//

#import "JPSidePullViewController.h"

//宏里面的#，会自动把后面的参数变成C语言的字符串
//C语言字符串转OC字符串的格式：@(我是C语言字符串)
#define KeyPath(objc,keyPath) @(((void)objc.keyPath, #keyPath))

/*
    (objc.keyPath, #keyPath)
    逗号表达式：
        int a = ((void)5,(void)4,3); ---> a为3
        只取最右边的值（加(void)是声明这个值不用也罢）
 */

#define Self_View_Width self.view.bounds.size.width
#define Self_View_Height self.view.bounds.size.height

#define MaxY 80 //左右挪的最后目标y值

#define TargetRightScale 4/5.0  //主视图右挪的最后宽度比例值
#define TargetLeftScale 2/3.0   //主视图左挪的最后宽度比例值

@interface JPSidePullViewController ()
@property(nonatomic,assign)CGRect targetLeftRect;   //往左挪的最后frame
@property(nonatomic,assign)CGRect targetRightRect;  //往右挪的最后frame
@end

@implementation JPSidePullViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    //配置视图
    [self setupView];
    
    //在根视图上添加挪动手势
    UIPanGestureRecognizer *pan=[[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(pan:)];
    [self.view addGestureRecognizer:pan];

//    /*
//        利用KVO时刻监听mainV的frame属性
//          参数：
//            Observer：观察者
//            KeyPath：监听的属性
//            options：监听新值的改变
//            context：什么鬼
//     */
//    
//    [self.mainV addObserver:self forKeyPath:KeyPath(self.mainV, frame) options:NSKeyValueObservingOptionNew context:nil];
    
}

////只要监听的属性一改变，就会调用观察者的这个方法，通知你有新值
//-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
//    if (self.mainV.x>0) {
//        self.rightV.hidden=YES;
//        self.leftV.hidden=NO;
//    }else{
//        self.leftV.hidden=YES;
//        self.rightV.hidden=NO;
//    }
//}
//
//-(void)dealloc{
//    //移除观察者
//    [self.mainV removeObserver:self forKeyPath:@"frame"];
//}


//配置视图
- (void)setupView {
    
    //添加左视图
    UIView *leftView=[[UIView alloc] initWithFrame:self.view.bounds];
    leftView.backgroundColor=[UIColor colorWithRed:arc4random_uniform(255)/255.0 green:arc4random_uniform(255)/255.0 blue:arc4random_uniform(255)/255.0 alpha:1.0];
    [self.view addSubview:leftView];
    _leftView=leftView;
    
    //添加右视图
    UIView *rightView=[[UIView alloc] initWithFrame:self.view.bounds];
    rightView.backgroundColor=[UIColor colorWithRed:arc4random_uniform(255)/255.0 green:arc4random_uniform(255)/255.0 blue:arc4random_uniform(255)/255.0 alpha:1.0];
    [self.view addSubview:rightView];
    _rightView=rightView;
    
    //添加主视图
    UIView *mainView=[[UIView alloc] initWithFrame:self.view.bounds];
    mainView.backgroundColor=[UIColor colorWithRed:arc4random_uniform(255)/255.0 green:arc4random_uniform(255)/255.0 blue:arc4random_uniform(255)/255.0 alpha:1.0];
    [self.view addSubview:mainView];
    _mainView=mainView;
    
    //根据目标偏移量计算往右挪的最后frame（显示左视图）
    CGRect targetRightRect=[self frameWithOriginaFrame:self.view.bounds offsetX:Self_View_Width*TargetRightScale isPan:NO];
    self.targetRightRect=targetRightRect;
    
    //根据目标偏移量计算往左挪的最后frame（显示右视图）
    CGRect targetLeftRect=[self frameWithOriginaFrame:self.view.bounds offsetX:Self_View_Width*TargetLeftScale isPan:NO];
    targetLeftRect.origin.x=-Self_View_Width*TargetLeftScale; //因为上面的计算方法会根据主视图的x值来执行反比例计算相应frame，所以这里的x值要单独拿出来设置，不然会是个正数值
    self.targetLeftRect=targetLeftRect;
    
    //添加主视图底层阴影
    _mainView.layer.shadowOpacity=0.8f;
    _mainView.layer.shadowOffset=CGSizeZero;
    _mainView.layer.shadowRadius=4.0f;
    _mainView.layer.shadowPath=[UIBezierPath bezierPathWithRect:_mainView.bounds].CGPath;
    
    //在主视图上添加点击手势
    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap:)];
    [mainView addGestureRecognizer:tap];
}

//挪动手势
-(void)pan:(UIPanGestureRecognizer *)pan{
    //获取手指的偏移量
    CGPoint point=[pan translationInView:self.view];
    
    if (!self.leftView && point.x>0) {
        return;
    }
    if (!self.rightView && point.x<0) {
        return;
    }

    //修改mainV的frame
    self.mainView.frame=[self frameWithOriginaFrame:self.mainView.frame offsetX:point.x isPan:YES];
    
    //不使用KVO则在这里判断左移还是右移
    if (self.mainView.frame.origin.x>0) {
        self.rightView.hidden=YES;
        self.leftView.hidden=NO;
    }else{
        self.leftView.hidden=YES;
        self.rightView.hidden=NO;
    }
    
    //复位（获取每次挪动的差值）
    [pan setTranslation:CGPointZero inView:self.view];
    
    //当手势结束时
    if (pan.state==UIGestureRecognizerStateEnded || pan.state==UIGestureRecognizerStateCancelled) {
        
        //定位
        CGRect targetRect=self.view.bounds;
        CGFloat scale=1.0;
        CGFloat duration=0.5;
        CGFloat damping=0.5;
        
        if (self.mainView.frame.origin.x>(Self_View_Width*0.5)) {               //往右挪
            
            targetRect=self.targetRightRect;
            scale=self.targetRightRect.size.height/Self_View_Height;
            
        }else if (CGRectGetMaxX(self.mainView.frame)<(Self_View_Width*0.5)) {   //往左挪
            
            targetRect=self.targetLeftRect;
            scale=self.targetLeftRect.size.height/Self_View_Height;
            
        }else{                                                                  //还原
            
            duration=0.25;
            damping=10;
            
        }
        
        [UIView animateWithDuration:duration delay:0 usingSpringWithDamping:damping initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.mainView.transform=CGAffineTransformMakeScale(scale, scale);
            self.mainView.frame=targetRect;
        } completion:nil];

    }
}

//点击手势 ---> 还原
-(void)tap:(UITapGestureRecognizer *)tap{
    [self recover];
}

//展示左视图（往右挪）
-(void)showLeftView{
    self.rightView.hidden=YES;
    self.leftView.hidden=NO;
    
    CGFloat scale=self.targetRightRect.size.height/Self_View_Height;
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.mainView.transform=CGAffineTransformMakeScale(scale, scale);
        self.mainView.frame=self.targetRightRect;
    } completion:nil];
}

//展示右视图（往左挪）
-(void)showRightView{
    self.leftView.hidden=YES;
    self.rightView.hidden=NO;
    
    CGFloat scale=self.targetLeftRect.size.height/Self_View_Height;
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.mainView.transform=CGAffineTransformMakeScale(scale, scale);
        self.mainView.frame=self.targetLeftRect;
    } completion:nil];
}

//还原
-(void)recover{
    if (self.mainView.frame.origin.x!=0) {
        [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.mainView.transform=CGAffineTransformIdentity;
            self.mainView.frame=self.view.bounds;
        } completion:nil];
    }
}

//根据偏移量算出相应frame
-(CGRect)frameWithOriginaFrame:(CGRect)frame offsetX:(CGFloat)offsetX isPan:(BOOL)isPan{
    
    CGFloat maxY=Self_View_Width*(MaxY/414.0);
    
    CGFloat offsetY=offsetX*(maxY/Self_View_Width);
    
    //注意：根据view.x来判断，不是根据point.x来判断
    if (self.mainView.frame.origin.x<0) {
        //往左挪 ---> offsetY<0
        frame.size.height=frame.size.height+2*offsetY;
    }else{
        //往右挪 ---> offsetY>0
        frame.size.height=frame.size.height-2*offsetY;
    }
    
    if (frame.size.height>Self_View_Height) {
        frame.size.height=Self_View_Height;
    }
    
    CGFloat scale=frame.size.height/Self_View_Height;
    
    frame.size.width=Self_View_Width*scale;
    frame.origin.x=frame.origin.x+offsetX;
    frame.origin.y=(Self_View_Height-frame.size.height)/2.0;
    
    if (isPan) {
        self.mainView.transform=CGAffineTransformMakeScale(scale, scale);
    }
    
    return frame;
}

@end
