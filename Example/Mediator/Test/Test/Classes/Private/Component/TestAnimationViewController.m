//
//  TestAnimationViewController.m
//  Example
//
//  Created by wuyong on 16/11/29.
//  Copyright © 2016年 ocphp.com. All rights reserved.
//

#import "TestAnimationViewController.h"

@interface TestAnimationView : UIView

@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, assign) NSInteger transitionType;

@end

@implementation TestAnimationView

- (instancetype)initWithTransitionType:(NSInteger)transitionType
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.transitionType = transitionType;
        if (self.transitionType > 8) {
            self.backgroundColor = [UIColor clearColor];
        } else {
            self.backgroundColor = [UIColor fw_colorWithHex:0x000000 alpha:0.5];
        }
        
        self.bottomView = [UIView new];
        self.bottomView.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.bottomView];
        if (self.transitionType == 6 || self.transitionType == 9) {
            self.bottomView.fw_layoutChain.left().right().bottom().height(FWScreenHeight / 2);
        } else {
            self.bottomView.fw_layoutChain.center().width(300).height(200);
        }
        
        FWWeakifySelf();
        [self fw_addTapGestureWithBlock:^(id  _Nonnull sender) {
            FWStrongifySelf();
            if (self.transitionType > 8) {
                [self.fw_viewController dismissViewControllerAnimated:YES completion:nil];
                return;
            }
            
            if (self.transitionType == 6) {
                [self.fw setPresentTransition:FWAnimatedTransitionTypeDismiss contentView:self.bottomView completion:nil];
            } else if (self.transitionType == 7) {
                [self.fw setAlertTransition:FWAnimatedTransitionTypeDismiss completion:nil];
            } else {
                [self.fw setFadeTransition:FWAnimatedTransitionTypeDismiss completion:nil];
            }
        }];
    }
    return self;
}

- (void)showInViewController:(UIViewController *)viewController
{
    if (self.transitionType > 8) {
        UIViewController *wrappedController = [self.fw wrappedTransitionController:YES];
        if (self.transitionType == 9) {
            [wrappedController.fw setPresentTransition:nil];
        } else if (self.transitionType == 10) {
            [wrappedController.fw setAlertTransition:nil];
        } else {
            [wrappedController.fw setFadeTransition:nil];
        }
        [viewController presentViewController:wrappedController animated:YES completion:nil];
        return;
    }
    
    [self.fw transitionToController:viewController pinEdges:YES];
    if (self.transitionType == 6) {
        [self.fw setPresentTransition:FWAnimatedTransitionTypePresent contentView:self.bottomView completion:nil];
    } else if (self.transitionType == 7) {
        [self.fw setAlertTransition:FWAnimatedTransitionTypePresent completion:nil];
    } else {
        [self.fw setFadeTransition:FWAnimatedTransitionTypePresent completion:nil];
    }
}

@end

@interface TestAnimationChildController : UIViewController

@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, assign) NSInteger transitionType;

@end

@implementation TestAnimationChildController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.fw_navigationBarHidden = YES;
    self.view.backgroundColor = [UIColor clearColor];
    FWWeakifySelf();
    [self.view fw_addTapGestureWithBlock:^(id  _Nonnull sender) {
        FWStrongifySelf();
        [self fw_closeViewControllerAnimated:YES];
    }];
    
    self.bottomView = [UIView new];
    self.bottomView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.bottomView];
    if (self.transitionType == 0 || self.transitionType == 3) {
        self.bottomView.fw_layoutChain.left().right().bottom().height(FWScreenHeight / 2);
    } else {
        self.bottomView.fw_layoutChain.center().width(300).height(200);
    }
    
    UIButton *button = [UIButton new];
    [button setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    NSString *buttonTitle = self.navigationController ? @"支持push" : @"不支持push";
    [button setTitle:buttonTitle forState:UIControlStateNormal];
    [self.bottomView addSubview:button];
    [button fw_addTouchBlock:^(id  _Nonnull sender) {
        FWStrongifySelf();
        TestAnimationChildController *animationController = [TestAnimationChildController new];
        animationController.transitionType = self.transitionType;
        [self.navigationController pushViewController:animationController animated:YES];
    }];
    button.fw_layoutChain.center();
}

- (void)showInViewController:(UIViewController *)viewController
{
    if (self.transitionType == 0) {
        [self.fw setPresentTransition:nil];
    } else if (self.transitionType == 1) {
        [self.fw setAlertTransition:nil];
    } else {
        [self.fw setFadeTransition:nil];
    }
    [viewController presentViewController:self animated:YES completion:nil];
}

- (void)showInNavigationController:(UIViewController *)viewController
{
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:self];
    if (self.transitionType == 3) {
        [nav.fw setPresentTransition:nil];
    } else if (self.transitionType == 4) {
        [nav.fw setAlertTransition:nil];
    } else {
        [nav.fw setFadeTransition:nil];
    }
    [viewController presentViewController:nav animated:YES completion:nil];
}

@end

@interface TestAnimationViewController ()

FWLazyProperty(UIView *, animationView);

@end

@implementation TestAnimationViewController {
    NSInteger animationIndex_;
}

FWDefLazyProperty(UIView *, animationView, {
    _animationView = [[UIView alloc] initWithFrame:CGRectMake(FWScreenWidth / 2.0 - 75.0, 20, 150, 200)];
    _animationView.backgroundColor = [UIColor redColor];
    [self.view addSubview:_animationView];
});

- (void)renderView
{
    UIButton *button = [Theme largeButton];
    [button setTitle:@"转场动画" forState:UIControlStateNormal];
    [button fw_addTouchTarget:self action:@selector(onPresent)];
    [self.view addSubview:button];
    [button fw_pinEdgeToSuperview:NSLayoutAttributeBottom withInset:15];
    [button fw_alignAxisToSuperview:NSLayoutAttributeCenterX];
    
    UIButton *button2 = [Theme largeButton];
    [button2 setTitle:@"切换拖动" forState:UIControlStateNormal];
    [button2 fw_addTouchTarget:self action:@selector(onDrag:)];
    [self.view addSubview:button2];
    [button2 fw_pinEdge:NSLayoutAttributeBottom toEdge:NSLayoutAttributeTop ofView:button withOffset:-15];
    [button2 fw_alignAxisToSuperview:NSLayoutAttributeCenterX];
    
    UIButton *button3 = [Theme largeButton];
    [button3 setTitle:@"切换动画" forState:UIControlStateNormal];
    [button3 fw_addTouchTarget:self action:@selector(onAnimation:)];
    [self.view addSubview:button3];
    [button3 fw_pinEdge:NSLayoutAttributeBottom toEdge:NSLayoutAttributeTop ofView:button2 withOffset:-15];
    [button3 fw_alignAxisToSuperview:NSLayoutAttributeCenterX];
}

- (void)renderModel
{
    FWWeakifySelf();
    [self fw_setRightBarItem:@("Animator") block:^(id  _Nonnull sender) {
        FWStrongifySelf();
        UIViewController *viewController = [NSClassFromString(@"Test.TestPropertyAnimatorViewController") new];
        [self.navigationController pushViewController:viewController animated:true];
    }];
}

#pragma mark - Action

- (void)onPresent
{
    FWWeakifySelf();
    [self.fw showSheetWithTitle:nil message:nil cancel:@"取消" actions:@[@"VC present", @"VC alert", @"VC fade", @"nav present", @"nav alert", @"nav fade", @"view present", @"view alert", @"view fade", @"wrapped present", @"wrapped alert", @"wrapped fade"] actionBlock:^(NSInteger index) {
        FWStrongifySelf();
        if (index < 3) {
            TestAnimationChildController *animationController = [TestAnimationChildController new];
            animationController.transitionType = index;
            [animationController showInViewController:self];
        } else if (index < 6) {
            TestAnimationChildController *animationController = [TestAnimationChildController new];
            animationController.transitionType = index;
            [animationController showInNavigationController:self];
        } else {
            TestAnimationView *animationView = [[TestAnimationView alloc] initWithTransitionType:index];
            [animationView showInViewController:self];
        }
    }];
}

- (void)onAnimation:(UIButton *)sender
{
    animationIndex_++;
    
    NSString *title = nil;
    if (animationIndex_ == 1) {
        title = @"Push.FromTop";
        [self.animationView.fw addTransitionWithType:kCATransitionPush
                                            subtype:kCATransitionFromTop
                                     timingFunction:kCAMediaTimingFunctionEaseInEaseOut
                                           duration:1.0
                                         completion:NULL];
    }
    
    if (animationIndex_ == 2) {
        title = @"CurlUp";
        [self.animationView.fw addAnimationWithCurve:UIViewAnimationCurveEaseInOut
                                         transition:UIViewAnimationTransitionCurlUp
                                           duration:1.0
                                         completion:NULL];
    }
    
    if (animationIndex_ == 3) {
        title = @"transform.rotation.y";
        [self.animationView.fw addAnimationWithKeyPath:@"transform.rotation.y"
                                            fromValue:@(0)
                                              toValue:@(M_PI)
                                             duration:1.0
                                           completion:NULL];
    }
    
    if (animationIndex_ == 4) {
        title = @"Shake";
        [self.animationView.fw shakeWithTimes:10 delta:0 duration:0.1 completion:NULL];
    }
    
    if (animationIndex_ == 5) {
        title = @"Alpha";
        [self.animationView.fw fadeWithAlpha:0.0 duration:1.0 completion:^(BOOL finished) {
            [self.animationView.fw fadeWithAlpha:1.0 duration:1.0 completion:NULL];
        }];
    }
    
    if (animationIndex_ == 6) {
        title = @"Rotate";
        [self.animationView.fw rotateWithDegree:180 duration:1.0 completion:NULL];
    }
    
    if (animationIndex_ == 7) {
        title = @"Scale";
        [self.animationView.fw scaleWithScaleX:0.5 scaleY:0.5 duration:1.0 completion:^(BOOL finished) {
            [self.animationView.fw scaleWithScaleX:2.0 scaleY:2.0 duration:1.0 completion:NULL];
        }];
    }
    
    if (animationIndex_ == 8) {
        title = @"Move";
        CGPoint point = self.animationView.frame.origin;
        [self.animationView.fw moveWithPoint:CGPointMake(10, 10) duration:1.0 completion:^(BOOL finished) {
            [self.animationView.fw moveWithPoint:point duration:1.0 completion:NULL];
        }];
    }
    
    if (animationIndex_ == 9) {
        title = @"Frame";
        CGRect frame = self.animationView.frame;
        [self.animationView.fw moveWithFrame:CGRectMake(10, 10, 50, 50) duration:1.0 completion:^(BOOL finished) {
            [self.animationView.fw moveWithFrame:frame duration:1.0 completion:NULL];
        }];
    }
    
    if (animationIndex_ == 10) {
        title = @"切换动画";
        animationIndex_ = 0;
    }
    
    if (title) {
        [sender setTitle:title forState:UIControlStateNormal];
    }
}

- (void)onDrag:(UIButton *)sender
{
    if (!self.animationView.fw.dragEnabled) {
        self.animationView.fw.dragEnabled = YES;
        self.animationView.fw.dragLimit = CGRectMake(0, 0, FWScreenWidth, FWScreenHeight - FWNavigationBarHeight - FWStatusBarHeight);
    } else {
        self.animationView.fw.dragEnabled = NO;
    }
}

@end
