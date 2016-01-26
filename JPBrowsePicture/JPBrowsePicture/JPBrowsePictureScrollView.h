//
//  CBBrowsePictureScrollView.h
//  91muzu
//
//  Created by ios app on 16/1/15.
//  Copyright © 2016年 cb2015. All rights reserved.
//

/*
 *  需要在Info.plist文件 添加 View controller-based status bar appearance (Boolean) --> NO
 */

#import <UIKit/UIKit.h>

/* 可浏览图片model */
@interface JPBrowsePicture : UIImageView

/**
 *    创建图片实例
 *
 *    @param originalFrame  放大前的frame
 *    @param image          缩略图的imageData
 *    @param imageUrl       放大后的高清图片url
 *
 *    @return 实例
 */
+(instancetype)buildBrowsePictureWithOriginalFrame:(CGRect)originalFrame andImage:(UIImage *)image byImageUrl:(NSString *)imageUrl;

@property(nonatomic,assign)CGRect enlargeFrame;     //放大后的frame
@property(nonatomic,assign)CGRect originalFrame;    //放大前的frame
@property(nonatomic,copy)NSString *imageUrl;        //高清图片的url
@property(nonatomic,assign)BOOL isBorn;             //是否为被点击的那一张图片

@end






/* 每一页的ScrollView（上面放着可浏览图片model） */
@interface JPBrowsePictureSubScrollView : UIScrollView
@property(nonatomic,strong)JPBrowsePicture *browsePicture;      //可浏览图片model
@property (nonatomic,strong)CALayer *maskLayer;                 //下载时的半透明背景
@property (nonatomic,strong)CAShapeLayer *progressLayer;        //下载进度的读条
@property (nonatomic,weak)UITapGestureRecognizer *doubleTapGR;  //双击手势（放大、还原）

/**
 *    添加图片
 *
 *    @param browsePicture  可浏览图片model
 *
 *    @return nil
 */
-(void)addBrowsePicture:(JPBrowsePicture *)browsePicture;

@end





/* 底层（包含所有页）ScrollView */
@interface JPBrowsePictureScrollView : UIScrollView

/**
 *    创建底层ScrollView（包含着所有的子ScrollView）
 *
 *    @param view               在哪个view上创建
 *    @param allBrowsePicture   所有需要浏览的图片
 *    @param currentPage        点击的是第几张
 *
 *    @return 实例
 */
+(instancetype)buildBrowsePictureScrollViewOnView:(UIView *)view withAllBrowsePicture:(NSArray<JPBrowsePicture *> *)allBrowsePicture andCurrentPage:(NSInteger)currentPage;

/* 展示 */
-(void)show;

@end
