//
//  JPSlideMenuViewController.h
//  JPSlideMenuDemo
//
//  Created by ios app on 16/1/30.
//  Copyright © 2016年 cb2015. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JPSlideMenuViewController : UIViewController
-(void)addRootViewController:(UIViewController * _Nullable)rootViewController andLeftMenuViewController:(UIViewController * _Nullable)leftMenuViewController;
-(void)showLeftMenu;
-(void)hideLeftMenu;
-(BOOL)isShow;
@end
