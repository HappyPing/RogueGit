//
//  ViewController.m
//  JPBrowsePicture
//
//  Created by ios app on 16/1/23.
//  Copyright © 2016年 cb2015. All rights reserved.
//

#import "ViewController.h"
#import "JPBrowsePictureScrollView.h"
#import "UIImageView+WebCache.h"

//RGB颜色
#define Color(r,g,b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]
//随机色 arc4random_uniform(256)：0~255的随机数
#define RandomColor Color(arc4random_uniform(256),arc4random_uniform(256),arc4random_uniform(256))

#define PictureUrl1 @"http://7xkwqs.com2.z0.glb.qiniucdn.com/FgPa3d0lW-Y7h1mwxHLbqBps7Uin"
#define PictureUrl2 @"http://7xkwqs.com2.z0.glb.qiniucdn.com/FgZqs6Captk82o6QUBkryYjPTCV5"
#define PictureUrl3 @"http://7xkwqs.com2.z0.glb.qiniucdn.com/FgjxNSbUtVZFVb2xjnC_zyqVtkKU"
#define PictureUrl4 @"http://7xkwqs.com2.z0.glb.qiniucdn.com/Fh-54rTNYlCOBhHod1vFhbr-mPqI"
#define PictureUrl5 @"http://7xkwqs.com2.z0.glb.qiniucdn.com/FsUHLzKitcLUFC94fKTWcIQI_VpN"
#define PictureUrl6 @"http://7xkwqs.com2.z0.glb.qiniucdn.com/FgIKyX_OSqLnlWtZidwEniS4-e8H"

@interface ViewController ()

@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *allPictures;

@property(nonatomic,strong)NSArray *allPictureUrl;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=RandomColor;
    
    self.allPictureUrl=@[
                       PictureUrl1,
                       PictureUrl2,
                       PictureUrl3,
                       PictureUrl4,
                       PictureUrl5,
                       PictureUrl6
                       ];

}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
    for (int i=0; i<self.allPictureUrl.count;i++) {
        NSString *pictureUrl=self.allPictureUrl[i];
        UIImageView *picture=self.allPictures[i];
        picture.contentMode=UIViewContentModeScaleAspectFit;
        picture.backgroundColor=RandomColor;
        
        NSMutableString *smallPictureUrl=[NSMutableString string];
        [smallPictureUrl appendFormat:@"%@%@",pictureUrl,[NSString stringWithFormat:@"?imageView2/0/w/%ld/h/%ld",(long)picture.bounds.size.width*2,(long)picture.bounds.size.height*2]];
        
        [picture sd_setImageWithURL:[NSURL URLWithString:smallPictureUrl] placeholderImage:[UIImage imageNamed:@"fangaoyouhua-008.jpg"]];
    }
}

- (IBAction)lookPictureWith:(UIButton *)sender {
    NSLog(@"点到了");
    
    NSMutableArray *allBrowsePicture=[NSMutableArray array];
    for (int i=0; i<self.allPictures.count; i++) {

        NSString *pictureUrl=self.allPictureUrl[i];
        UIImageView *picture=self.allPictures[i];

        CGRect smallFrame=[picture convertRect:picture.bounds toView:self.view.window];
        
        JPBrowsePicture *bp=[JPBrowsePicture buildBrowsePictureWithOriginalFrame:smallFrame andImage:picture.image byImageUrl:pictureUrl];

        [allBrowsePicture addObject:bp];

    }


    JPBrowsePictureScrollView *bpSV=[JPBrowsePictureScrollView buildBrowsePictureScrollViewOnView:self.view.window withAllBrowsePicture:[allBrowsePicture copy] andCurrentPage:sender.tag];
    
    [bpSV show];
}

@end
