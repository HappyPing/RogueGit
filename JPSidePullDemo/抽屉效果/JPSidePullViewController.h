//
//  ViewController.h
//  抽屉效果
//
//  Created by ios app on 16/5/11.
//  Copyright © 2016年 cb2015. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JPSidePullViewController : UIViewController
// 设计原理：如果需要把控件暴露出去，一定要要写readonly
@property(nonatomic,weak,readonly)UIView *leftView;
@property(nonatomic,weak,readonly)UIView *rightView;
@property(nonatomic,weak,readonly)UIView *mainView;
-(void)showLeftView;
-(void)showRightView;
-(void)recover;
@end

