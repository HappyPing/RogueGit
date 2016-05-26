//
//  TestMainViewController.m
//  抽屉效果
//
//  Created by ios app on 16/5/12.
//  Copyright © 2016年 cb2015. All rights reserved.
//

#import "TestMainViewController.h"
#import "TestTableViewController.h"

@interface TestMainViewController ()

@end

@implementation TestMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    TestTableViewController *tableVC=[[TestTableViewController alloc] init];
    tableVC.tableView.frame=self.mainView.bounds;
    
    UINavigationController *navVC=[[UINavigationController alloc] initWithRootViewController:tableVC];
    
    //设计原理，如果A控制器的view成为B控制器View的子控件，注意A控制器一定要成为B控制器的子控制器，不然A控制器会被销毁
    //A控制器成为B控制器的子控制器
    [self addChildViewController:navVC];
    
    //主视图展示A控制器的vie
    [self.mainView addSubview:navVC.view];
    
    NSLog(@"%@",self.mainView.subviews);
    
}

@end
