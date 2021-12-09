/*!
 @header     TestButtonViewController.m
 @indexgroup Example
 @brief      TestButtonViewController
 @author     wuyong
 @copyright  Copyright © 2019 wuyong.site. All rights reserved.
 @updated    2019/6/20
 */

#import "TestButtonViewController.h"

@implementation TestButtonViewController

- (void)renderView
{
    UIButton *button = [UIButton fwButtonWithTitle:@"Button重复点击" font:[UIFont fwFontOfSize:15] titleColor:[Theme textColor]];
    button.frame = CGRectMake(25, 15, 150, 30);
    [button fwAddTouchTarget:self action:@selector(onClick1:)];
    [self.view addSubview:button];
    
    UILabel *label = [UILabel fwLabelWithFont:[UIFont fwFontOfSize:15] textColor:[Theme textColor] text:@"View重复点击"];
    label.textAlignment = NSTextAlignmentCenter;
    label.userInteractionEnabled = YES;
    label.frame = CGRectMake(200, 15, 150, 30);
    [label fwAddTapGestureWithTarget:self action:@selector(onClick2:)];
    [self.view addSubview:label];
    
    button = [UIButton fwButtonWithTitle:@"Button不可重复点击" font:[UIFont fwFontOfSize:15] titleColor:[Theme textColor]];
    button.frame = CGRectMake(25, 60, 150, 30);
    [button fwAddTouchTarget:self action:@selector(onClick3:)];
    [self.view addSubview:button];
    
    label = [UILabel fwLabelWithFont:[UIFont fwFontOfSize:15] textColor:[Theme textColor] text:@"View不可重复点击"];
    label.textAlignment = NSTextAlignmentCenter;
    label.userInteractionEnabled = YES;
    label.frame = CGRectMake(200, 60, 150, 30);
    [label fwAddTapGestureWithTarget:self action:@selector(onClick4:)];
    [self.view addSubview:label];
    
    button = [UIButton fwButtonWithTitle:@"Button1秒内不可重复点击" font:[UIFont fwFontOfSize:15] titleColor:[Theme textColor]];
    button.fwTouchEventInterval = 1;
    button.frame = CGRectMake(25, 105, 200, 30);
    [button fwAddTouchTarget:self action:@selector(onClick5:)];
    [self.view addSubview:button];
    
    UIButton *timerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    timerButton.frame = CGRectMake(30, 160, 80, 30);
    timerButton.titleLabel.font = [UIFont fwFontOfSize:15];
    [timerButton setTitleColor:[Theme textColor] forState:UIControlStateNormal];
    [timerButton setTitle:@"=>" forState:UIControlStateNormal];
    [self.view addSubview:timerButton];
    
    UIButton *timerButton1 = [UIButton buttonWithType:UIButtonTypeCustom];
    timerButton1.frame = CGRectMake(120, 160, 80, 30);
    timerButton1.titleLabel.font = [UIFont fwFontOfSize:15];
    [timerButton1 setTitleColor:[Theme textColor] forState:UIControlStateNormal];
    [timerButton1 setTitle:@"=>" forState:UIControlStateNormal];
    [self.view addSubview:timerButton1];
    
    UIButton *timerButton2 = [UIButton buttonWithType:UIButtonTypeCustom];
    timerButton2.frame = CGRectMake(220, 160, 80, 30);
    timerButton2.titleLabel.font = [UIFont fwFontOfSize:15];
    [timerButton2 setTitleColor:[Theme textColor] forState:UIControlStateNormal];
    [timerButton2 setTitle:@"发送" forState:UIControlStateNormal];
    __block NSTimer *timer1, *timer2;
    [timerButton2 fwAddTouchBlock:^(UIButton *sender) {
        [timerButton fwCountDown:60 title:@"=>" waitTitle:@"%lds"];
        [timer1 invalidate];
        timer1 = [NSTimer fwCommonTimerWithCountDown:60 block:^(NSInteger countDown) {
            NSString *title = countDown > 0 ? [NSString stringWithFormat:@"%lds", countDown] : @"=>";
            [timerButton1 setTitle:title forState:UIControlStateNormal];
        }];
        [timer2 invalidate];
        NSTimeInterval startTime = NSDate.fwCurrentTime;
        timer2 = [NSTimer fwCommonTimerWithTimeInterval:1 block:^(NSTimer * _Nonnull timer) {
            NSInteger countDown = 60 - (NSInteger)(NSDate.fwCurrentTime - startTime);
            if (countDown < 1) [timer2 invalidate];
            NSString *title = countDown > 0 ? [NSString stringWithFormat:@"%lds", countDown] : @"发送";
            [timerButton2 setTitle:title forState:UIControlStateNormal];
        } repeats:YES];
        [timer2 fire];
    }];
    [self.view addSubview:timerButton2];
    
    UIButton *button1 = [UIButton buttonWithType:UIButtonTypeSystem];
    button1.frame = CGRectMake(25, 205, 150, 50);
    button1.enabled = NO;
    [button1 setTitle:@"System不可点" forState:UIControlStateNormal];
    [button1 setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    button1.backgroundColor = FWColorHex(0xFFDA00);
    [button1 fwSetCornerRadius:5];
    [self.view addSubview:button1];
    
    UIButton *button2 = [UIButton buttonWithType:UIButtonTypeSystem];
    button2.frame = CGRectMake(200, 205, 150, 50);
    [button2 setTitle:@"System可点击" forState:UIControlStateNormal];
    [button2 setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    button2.backgroundColor = FWColorHex(0xFFDA00);
    [button2 fwSetCornerRadius:5];
    [self.view addSubview:button2];
    
    UIButton *button3 = [UIButton buttonWithType:UIButtonTypeCustom];
    button3.frame = CGRectMake(25, 270, 150, 50);
    button3.enabled = NO;
    [button3 setTitle:@"Custom不可点" forState:UIControlStateNormal];
    [button3 setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    button3.backgroundColor = FWColorHex(0xFFDA00);
    [button3 fwSetCornerRadius:5];
    [self.view addSubview:button3];
    
    UIButton *button4 = [UIButton buttonWithType:UIButtonTypeCustom];
    button4.frame = CGRectMake(200, 270, 150, 50);
    [button4 setTitle:@"Custom可点击" forState:UIControlStateNormal];
    [button4 setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    button4.backgroundColor = FWColorHex(0xFFDA00);
    [button4 fwSetCornerRadius:5];
    [self.view addSubview:button4];
    
    button1 = [UIButton buttonWithType:UIButtonTypeSystem];
    button1.frame = CGRectMake(25, 335, 150, 50);
    button1.enabled = NO;
    button1.fwDisabledAlpha = 0.5;
    [button1 setTitle:@"System不可点2" forState:UIControlStateNormal];
    [button1 setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    button1.backgroundColor = FWColorHex(0xFFDA00);
    [button1 fwSetCornerRadius:5];
    [self.view addSubview:button1];
    
    button2 = [UIButton buttonWithType:UIButtonTypeSystem];
    button2.frame = CGRectMake(200, 335, 150, 50);
    button2.fwHighlightedAlpha = 0.5;
    [button2 setTitle:@"System可点击2" forState:UIControlStateNormal];
    [button2 setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    button2.backgroundColor = FWColorHex(0xFFDA00);
    [button2 fwSetCornerRadius:5];
    [self.view addSubview:button2];
    
    button3 = [UIButton buttonWithType:UIButtonTypeCustom];
    button3.frame = CGRectMake(25, 400, 150, 50);
    button3.enabled = NO;
    button3.fwDisabledAlpha = 0.3;
    button3.fwHighlightedAlpha = 0.5;
    [button3 setTitle:@"Custom不可点2" forState:UIControlStateNormal];
    [button3 setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    button3.backgroundColor = FWColorHex(0xFFDA00);
    [button3 fwSetCornerRadius:5];
    [self.view addSubview:button3];
    
    button4 = [UIButton buttonWithType:UIButtonTypeCustom];
    button4.frame = CGRectMake(200, 400, 150, 50);
    button4.fwDisabledAlpha = 0.3;
    button4.fwHighlightedAlpha = 0.5;
    [button4 setTitle:@"Custom可点击2" forState:UIControlStateNormal];
    [button4 setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    button4.backgroundColor = FWColorHex(0xFFDA00);
    [button4 fwSetCornerRadius:5];
    [self.view addSubview:button4];
    
    button1 = [UIButton buttonWithType:UIButtonTypeCustom];
    button1.frame = CGRectMake(25, 465, 150, 50);
    button1.backgroundColor = FWColorHex(0xFFDA00);
    [button1 fwSetCornerRadius:5];
    button1.fwDisabledAlpha = 0.3;
    button1.fwHighlightedAlpha = 0.5;
    [button1 fwSetTitle:@"按钮文字" font:FWFontSize(10) titleColor:UIColor.blackColor];
    [button1 fwSetImage:[TestBundle imageNamed:@"icon_scan"]];
    [button1 fwSetImageEdge:UIRectEdgeTop spacing:4];
    [self.view addSubview:button1];
    
    button2 = [UIButton buttonWithType:UIButtonTypeCustom];
    button2.frame = CGRectMake(200, 465, 150, 50);
    button2.backgroundColor = FWColorHex(0xFFDA00);
    [button2 fwSetCornerRadius:5];
    button2.fwDisabledAlpha = 0.3;
    button2.fwHighlightedAlpha = 0.5;
    [button2 fwSetTitle:@"按钮文字" font:FWFontSize(10) titleColor:UIColor.blackColor];
    [button2 fwSetImage:[TestBundle imageNamed:@"icon_scan"]];
    [button2 fwSetImageEdge:UIRectEdgeLeft spacing:4];
    [self.view addSubview:button2];
    
    button3 = [UIButton buttonWithType:UIButtonTypeCustom];
    button3.frame = CGRectMake(25, 530, 150, 50);
    button3.backgroundColor = FWColorHex(0xFFDA00);
    [button3 fwSetCornerRadius:5];
    button3.fwDisabledAlpha = 0.3;
    button3.fwHighlightedAlpha = 0.5;
    [button3 fwSetTitle:@"按钮文字" font:FWFontSize(10) titleColor:UIColor.blackColor];
    [button3 fwSetImage:[TestBundle imageNamed:@"icon_scan"]];
    [button3 fwSetImageEdge:UIRectEdgeBottom spacing:4];
    [self.view addSubview:button3];
    
    button4 = [UIButton buttonWithType:UIButtonTypeCustom];
    button4.frame = CGRectMake(200, 530, 150, 50);
    button4.backgroundColor = FWColorHex(0xFFDA00);
    [button4 fwSetCornerRadius:5];
    button4.fwDisabledAlpha = 0.3;
    button4.fwHighlightedAlpha = 0.5;
    [button4 fwSetTitle:@"按钮文字" font:FWFontSize(10) titleColor:UIColor.blackColor];
    [button4 fwSetImage:[TestBundle imageNamed:@"icon_scan"]];
    [button4 fwSetImageEdge:UIRectEdgeRight spacing:4];
    [self.view addSubview:button4];
}

#pragma mark - Action

- (void)onClick1:(UIButton *)sender
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"Button重复点击触发事件");
    });
}

- (void)onClick2:(UITapGestureRecognizer *)sender
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"Label重复点击触发事件");
    });
}

- (void)onClick3:(UIButton *)sender
{
    sender.enabled = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"Button不可重复点击触发事件");
        sender.enabled = YES;
    });
}

- (void)onClick4:(UITapGestureRecognizer *)gesture
{
    gesture.view.userInteractionEnabled = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"Label不可重复点击触发事件");
        gesture.view.userInteractionEnabled = YES;
    });
}

- (void)onClick5:(UIButton *)sender
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"Button1秒内不可重复点击触发事件");
    });
}

@end
