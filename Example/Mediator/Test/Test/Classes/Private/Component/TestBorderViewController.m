//
//  TestBorderViewController.m
//  Example
//
//  Created by wuyong on 16/11/14.
//  Copyright © 2016年 ocphp.com. All rights reserved.
//

#import "TestBorderViewController.h"

@interface TestBorderViewController ()

@end

@implementation TestBorderViewController

- (void)renderView
{
    UIColor *bgColor = [UIColor yellowColor];
    
    // All
    UIView *frameView = [[UIView alloc] initWithFrame:CGRectMake(20, 20, 50, 50)];
    frameView.backgroundColor = bgColor;
    [self.view addSubview:frameView];
    [frameView fw_setBorderColor:[UIColor redColor] width:0.5];
    
    frameView = [[UIView alloc] initWithFrame:CGRectMake(90, 20, 50, 50)];
    frameView.backgroundColor = bgColor;
    [self.view addSubview:frameView];
    [frameView fw_setCornerRadius:5];
    
    frameView = [[UIView alloc] initWithFrame:CGRectMake(160, 20, 50, 50)];
    frameView.backgroundColor = bgColor;
    [self.view addSubview:frameView];
    [frameView fw_setBorderColor:[UIColor redColor] width:0.5 cornerRadius:5];
    
    // Corener
    frameView = [[UIView alloc] initWithFrame:CGRectMake(20, 300, 80, 36)];
    frameView.backgroundColor = bgColor;
    [frameView fw_setBorderColor:[UIColor redColor] width:0.5 cornerRadius:18];
    [self.view addSubview:frameView];
    
    frameView = [[UIView alloc] initWithFrame:CGRectMake(120, 300, 80, 36)];
    frameView.backgroundColor = bgColor;
    [frameView fw_setBorderColor:[UIColor redColor] width:0.5 cornerRadius:36];
    [self.view addSubview:frameView];
    
    frameView = [[UIView alloc] initWithFrame:CGRectMake(220, 300, 80, 36)];
    frameView.backgroundColor = bgColor;
    [frameView fw_setBorderColor:[UIColor redColor] width:0.5 cornerRadius:9];
    [self.view addSubview:frameView];
    
    frameView = [[UIView alloc] initWithFrame:CGRectMake(20, 370, 80, 36)];
    frameView.backgroundColor = bgColor;
    [frameView fw_setCornerLayer:UIRectCornerAllCorners radius:18 borderColor:[UIColor redColor] width:0.5];
    [self.view addSubview:frameView];
    
    frameView = [[UIView alloc] initWithFrame:CGRectMake(120, 370, 80, 36)];
    frameView.backgroundColor = bgColor;
    [frameView fw_setCornerLayer:UIRectCornerAllCorners radius:36 borderColor:[UIColor redColor] width:0.5];
    [self.view addSubview:frameView];
    
    frameView = [[UIView alloc] initWithFrame:CGRectMake(220, 370, 80, 36)];
    frameView.backgroundColor = bgColor;
    [frameView fw_setCornerLayer:UIRectCornerAllCorners radius:9 borderColor:[UIColor redColor] width:0.5];
    [self.view addSubview:frameView];
    
    // Layer
    frameView = [[UIView alloc] initWithFrame:CGRectMake(20, 90, 50, 50)];
    frameView.backgroundColor = bgColor;
    [self.view addSubview:frameView];
    [frameView fw_setBorderLayer:(UIRectEdgeTop | UIRectEdgeBottom) color:[UIColor redColor] width:0.5];
    
    frameView = [[UIView alloc] initWithFrame:CGRectMake(90, 90, 50, 50)];
    frameView.backgroundColor = bgColor;
    [self.view addSubview:frameView];
    [frameView fw_setBorderLayer:(UIRectEdgeLeft | UIRectEdgeRight) color:[UIColor redColor] width:0.5];
    [frameView fw_setBorderLayer:(UIRectEdgeLeft | UIRectEdgeRight) color:[UIColor redColor] width:0.5 leftInset:5.0 rightInset:5.0];
    
    frameView = [[UIView alloc] initWithFrame:CGRectMake(160, 90, 50, 50)];
    frameView.backgroundColor = bgColor;
    [self.view addSubview:frameView];
    [frameView fw_setCornerLayer:(UIRectCornerTopLeft | UIRectCornerTopRight) radius:0];
    [frameView fw_setCornerLayer:(UIRectCornerTopLeft | UIRectCornerTopRight) radius:5];
    
    frameView = [[UIView alloc] initWithFrame:CGRectMake(230, 90, 50, 50)];
    frameView.backgroundColor = bgColor;
    [self.view addSubview:frameView];
    [frameView fw_setCornerLayer:(UIRectCornerTopLeft | UIRectCornerTopRight) radius:0 borderColor:[UIColor blueColor] width:1];
    [frameView fw_setCornerLayer:(UIRectCornerTopLeft | UIRectCornerTopRight) radius:5 borderColor:[UIColor redColor] width:0.5];
    
    // Layer
    UIView *layoutView = [[UIView alloc] init];
    layoutView.backgroundColor = bgColor;
    [self.view addSubview:layoutView];
    [layoutView fw_setDimensionsToSize:CGSizeMake(50, 50)];
    [layoutView fw_pinEdge:NSLayoutAttributeTop toEdge:NSLayoutAttributeBottom ofView:frameView withOffset:20];
    [layoutView fw_pinEdgeToSuperview:NSLayoutAttributeLeft withInset:20];
    [layoutView layoutIfNeeded];
    [layoutView fw_setBorderLayer:(UIRectEdgeTop | UIRectEdgeBottom) color:[UIColor redColor] width:0.5];
    
    layoutView = [UIView new];
    layoutView.backgroundColor = bgColor;
    [self.view addSubview:layoutView];
    [layoutView fw_setDimensionsToSize:CGSizeMake(50, 50)];
    [layoutView fw_pinEdge:NSLayoutAttributeTop toEdge:NSLayoutAttributeBottom ofView:frameView withOffset:20];
    [layoutView fw_pinEdgeToSuperview:NSLayoutAttributeLeft withInset:90];
    [layoutView layoutIfNeeded];
    [layoutView fw_setBorderLayer:(UIRectEdgeLeft | UIRectEdgeRight) color:[UIColor redColor] width:0.5];
    [layoutView fw_setBorderLayer:(UIRectEdgeLeft | UIRectEdgeRight) color:[UIColor redColor] width:0.5 leftInset:5.0 rightInset:5.0];
    
    layoutView = [UIView new];
    layoutView.backgroundColor = bgColor;
    [self.view addSubview:layoutView];
    [layoutView fw_setDimensionsToSize:CGSizeMake(50, 50)];
    [layoutView fw_pinEdge:NSLayoutAttributeTop toEdge:NSLayoutAttributeBottom ofView:frameView withOffset:20];
    [layoutView fw_pinEdgeToSuperview:NSLayoutAttributeLeft withInset:160];
    [layoutView layoutIfNeeded];
    [layoutView fw_setCornerLayer:(UIRectCornerTopLeft | UIRectCornerTopRight) radius:0];
    [layoutView fw_setCornerLayer:(UIRectCornerTopLeft | UIRectCornerTopRight) radius:5];
    
    layoutView = [UIView new];
    layoutView.backgroundColor = bgColor;
    [self.view addSubview:layoutView];
    [layoutView fw_setDimensionsToSize:CGSizeMake(50, 50)];
    [layoutView fw_pinEdge:NSLayoutAttributeTop toEdge:NSLayoutAttributeBottom ofView:frameView withOffset:20];
    [layoutView fw_pinEdgeToSuperview:NSLayoutAttributeLeft withInset:230];
    [layoutView layoutIfNeeded];
    [layoutView fw_setCornerLayer:(UIRectCornerTopLeft | UIRectCornerTopRight) radius:0 borderColor:[UIColor blueColor] width:1];
    [layoutView fw_setCornerLayer:(UIRectCornerTopLeft | UIRectCornerTopRight) radius:5 borderColor:[UIColor redColor] width:0.5];
    
    // View
    UIView *autoView = [UIView new];
    autoView.backgroundColor = bgColor;
    [self.view addSubview:autoView];
    [autoView fw_setDimensionsToSize:CGSizeMake(50, 50)];
    [autoView fw_pinEdge:NSLayoutAttributeTop toEdge:NSLayoutAttributeBottom ofView:layoutView withOffset:20];
    [autoView fw_pinEdgeToSuperview:NSLayoutAttributeLeft withInset:20];
    [autoView fw_setBorderView:(UIRectEdgeTop | UIRectEdgeBottom) color:[UIColor redColor] width:0.5];
    
    autoView = [UIView new];
    autoView.backgroundColor = bgColor;
    [self.view addSubview:autoView];
    [autoView fw_setDimensionsToSize:CGSizeMake(50, 50)];
    [autoView fw_pinEdge:NSLayoutAttributeTop toEdge:NSLayoutAttributeBottom ofView:layoutView withOffset:20];
    [autoView fw_pinEdgeToSuperview:NSLayoutAttributeLeft withInset:90];
    [autoView fw_setBorderView:(UIRectEdgeLeft | UIRectEdgeRight) color:[UIColor redColor] width:0.5];
    [autoView fw_setBorderView:(UIRectEdgeLeft | UIRectEdgeRight) color:[UIColor redColor] width:0.5 leftInset:5.0 rightInset:5.0];
}

@end
