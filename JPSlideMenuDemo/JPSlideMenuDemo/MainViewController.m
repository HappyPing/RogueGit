//
//  MainViewController.m
//  JPSideDemo
//
//  Created by ios app on 16/1/31.
//  Copyright © 2016年 cb2015. All rights reserved.
//

#import "MainViewController.h"
#import "JPSlideMenuViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)showLeftMenu:(id)sender {
    JPSlideMenuViewController *sVC=(JPSlideMenuViewController *)self.tabBarController.parentViewController;
    if ([sVC isShow]==NO) {
        [sVC showLeftMenu];
    }else{
        [sVC hideLeftMenu];
    }
}


@end
