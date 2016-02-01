//
//  JPSlideMenuViewController.m
//  JPSlideMenuDemo
//
//  Created by ios app on 16/1/30.
//  Copyright © 2016年 cb2015. All rights reserved.
//

#import "JPSlideMenuViewController.h"
#import "UIView+Extension.h"

#define ShowDuration 0.8
#define HideDuration 0.3
#define ScaleValue 0.8
#define AlphaValue 0.3

@interface JPSlideMenuViewController ()
@property(nonatomic,weak)UIViewController *rootViewController;
@property(nonatomic,weak)UIViewController *leftMenuViewController;
@property(nonatomic,strong)UIPanGestureRecognizer *panGR;
@property(nonatomic,strong)UITapGestureRecognizer *tapGR;
@property(nonatomic,assign)BOOL panMovingLeft;
@end

@implementation JPSlideMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor colorWithRed:0.103 green:0.651 blue:0.9495 alpha:1.0];
    
    self.panGR=[[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(pan:)];
    [self.view addGestureRecognizer:self.panGR];
    
    self.tapGR=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap:)];
    
}

-(void)pan:(UIPanGestureRecognizer *)panGR{
    
    CGPoint translation=[panGR translationInView:self.view];//移动时，以起点作为原点，得出与起点的偏移坐标（此处设起点坐标为(0,0)）
    
    if (panGR.state == UIGestureRecognizerStateBegan) {
        if (self.rootViewController.view.x<((3/4.0)*self.view.width)) {
            self.panMovingLeft=NO;
        }else{
            self.panMovingLeft=YES;
        }
    }
    
    if (panGR.state == UIGestureRecognizerStateChanged) {
        
        if (self.panMovingLeft==NO && translation.x>0) {
            CGFloat percentage=translation.x / self.view.width;
            
            self.rootViewController.view.transform=
                CGAffineTransformMakeScale(
                                           1-percentage*(1-ScaleValue),
                                           1-percentage*(1-ScaleValue)
                                           );
            
            self.rootViewController.view.frame=
                CGRectMake(
                           (3/4.0)*self.view.width*percentage,
                           (self.view.height-self.view.height*(1-percentage*(1-ScaleValue)))/2,
                           self.view.width*(1-percentage*(1-ScaleValue)),
                           self.view.height*(1-percentage*(1-ScaleValue))
                           );
            
            
            self.leftMenuViewController.view.alpha=AlphaValue+percentage*(1-AlphaValue);
            
            self.leftMenuViewController.view.transform=
                CGAffineTransformMakeScale(
                                           ScaleValue+percentage*(1-ScaleValue),
                                           ScaleValue+percentage*(1-ScaleValue)
                                           );
            
        }else if (self.panMovingLeft==YES && translation.x<0) {
            CGFloat percentage=-translation.x / self.view.width;
            
            self.rootViewController.view.transform=
                CGAffineTransformMakeScale(
                                           ScaleValue+percentage*(1-ScaleValue),
                                           ScaleValue+percentage*(1-ScaleValue)
                                           );
            
            self.rootViewController.view.frame=
                CGRectMake(
                           (3/4.0)*self.view.width-(3/4.0)*self.view.width*percentage,
                           (self.view.height-self.view.height*(ScaleValue+percentage*(1-ScaleValue)))/2,
                           self.view.width*(ScaleValue+percentage*(1-ScaleValue)),
                           self.view.height*(ScaleValue+percentage*(1-ScaleValue))
                           );
            
            
            self.leftMenuViewController.view.alpha=1-percentage*(1-AlphaValue);
            
            self.leftMenuViewController.view.transform=
                CGAffineTransformMakeScale(
                                           1-percentage*(1-ScaleValue),
                                           1-percentage*(1-ScaleValue)
                                           );
        }
        
    }
    
    
    if (panGR.state == UIGestureRecognizerStateEnded || panGR.state == UIGestureRecognizerStateCancelled) {
        float distance=0;
        if (self.panMovingLeft==NO) {
            distance=1/4.0;
        }else{
            distance=1/2.0;
        }
        if (self.rootViewController.view.x<distance*self.view.width) {
            [self hideLeftMenu];
        }else{
            [self showLeftMenu];
        }
    }
    
}

-(void)tap:(UITapGestureRecognizer *)tapGR{
    if (self.rootViewController.view.x>=(3/4.0)*self.view.width) {
        [self hideLeftMenu];
    }
}

-(void)addRootViewController:(UIViewController * _Nullable)rootViewController andLeftMenuViewController:(UIViewController * _Nullable)leftMenuViewController{
    _rootViewController=rootViewController;
    _leftMenuViewController=leftMenuViewController;
    
    _leftMenuViewController.view.alpha=AlphaValue;
    _leftMenuViewController.view.transform=CGAffineTransformMakeScale(ScaleValue, ScaleValue);
    
    _rootViewController.view.layer.shadowOpacity=0.8f;
    _rootViewController.view.layer.shadowOffset=CGSizeZero;
    _rootViewController.view.layer.shadowRadius=4.0f;
    _rootViewController.view.layer.shadowPath=[UIBezierPath bezierPathWithRect:self.rootViewController.view.bounds].CGPath;
    
    [self addChildViewController:_rootViewController];
    [self addChildViewController:_leftMenuViewController];
    [self.view addSubview:_rootViewController.view];
    [self.view insertSubview:_leftMenuViewController.view belowSubview:_rootViewController.view];
    
}

-(void)showLeftMenu{
    [UIView animateWithDuration:ShowDuration delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        self.rootViewController.view.transform=CGAffineTransformMakeScale(ScaleValue, ScaleValue);
        
        self.rootViewController.view.frame=
            CGRectMake(
                       (3/4.0)*self.view.width,
                       (self.view.height-self.view.height*ScaleValue)/2,
                       self.view.width*ScaleValue,
                       self.view.height*ScaleValue
                       );
        
        self.leftMenuViewController.view.transform=CGAffineTransformMakeScale(1, 1);
        self.leftMenuViewController.view.alpha=1;
        
    } completion:^(BOOL finished) {
        
        [self.rootViewController.view addGestureRecognizer:self.tapGR];
        
    }];
}

-(void)hideLeftMenu{
    [UIView animateWithDuration:HideDuration animations:^{
        
        self.rootViewController.view.transform=CGAffineTransformMakeScale(1, 1);
        self.rootViewController.view.frame=self.view.bounds;
        self.leftMenuViewController.view.transform=CGAffineTransformMakeScale(ScaleValue, ScaleValue);
        self.leftMenuViewController.view.alpha=AlphaValue;
        
    }completion:^(BOOL finished) {
        
        [self.rootViewController.view removeGestureRecognizer:self.tapGR];
        
    }];
}

-(BOOL)isShow{
    return self.rootViewController.view.x<(3/4.0)*self.view.width? NO:YES;
}


@end
