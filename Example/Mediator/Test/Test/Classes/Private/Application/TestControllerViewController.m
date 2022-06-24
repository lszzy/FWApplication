/*!
 @header     TestControllerViewController.m
 @indexgroup Example
 @brief      TestControllerViewController
 @author     wuyong
 @copyright  Copyright © 2018 wuyong.site. All rights reserved.
 @updated    2018/12/27
 */

#import "TestControllerViewController.h"

@interface TestControllerViewController () <FWScrollViewController, UIScrollViewDelegate>

@property (nonatomic, strong) UIView *redView;
@property (nonatomic, strong) UIView *hoverView;

@property (nonatomic, assign) BOOL isTop;

@end

@implementation TestControllerViewController

- (void)setIsTop:(BOOL)isTop
{
    _isTop = isTop;
    
    if (isTop) {
        self.fw.navigationBarStyle = FWNavigationBarStyleTransparent;
        self.fw.extendedLayoutEdge = UIRectEdgeTop;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    FWWeakifySelf();
    [self fw_setRightBarItem:@"切换" block:^(id sender) {
        FWStrongifySelf();
        
        TestControllerViewController *viewController = [TestControllerViewController new];
        viewController.isTop = !self.isTop;
        [self fw_openViewController:viewController animated:YES];
    }];
}

- (void)renderInit
{
    self.fw.navigationBarStyle = FWNavigationBarStyleDefault;
}

- (void)renderView
{
    self.scrollView.delegate = self;
    
    UIImageView *imageView = [UIImageView new];
    imageView.image = [TestBundle imageNamed:@"public_picture"];
    [self.contentView addSubview:imageView]; {
        [imageView fw_setDimension:NSLayoutAttributeWidth toSize:FWScreenWidth];
        [imageView fw_pinEdgesToSuperviewWithInsets:UIEdgeInsetsZero excludingEdge:NSLayoutAttributeBottom];
        [imageView fw_setDimension:NSLayoutAttributeHeight toSize:150];
    }
    
    UIView *redView = [UIView new];
    _redView = redView;
    redView.backgroundColor = [UIColor redColor];
    [self.contentView addSubview:redView]; {
        [redView fw_pinEdgeToSuperview:NSLayoutAttributeLeft];
        [redView fw_pinEdgeToSuperview:NSLayoutAttributeRight];
        [redView fw_pinEdge:NSLayoutAttributeTop toEdge:NSLayoutAttributeBottom ofView:imageView];
        [redView fw_setDimension:NSLayoutAttributeHeight toSize:50];
    }
    
    UIView *hoverView = [UIView new];
    _hoverView = hoverView;
    hoverView.backgroundColor = [UIColor redColor];
    [redView addSubview:hoverView]; {
        [hoverView fw_pinEdgesToSuperview];
    }
    
    UIView *blueView = [UIView new];
    blueView.backgroundColor = [UIColor blueColor];
    [self.contentView addSubview:blueView]; {
        [blueView fw_pinEdgesToSuperviewWithInsets:UIEdgeInsetsZero excludingEdge:NSLayoutAttributeTop];
        [blueView fw_pinEdge:NSLayoutAttributeTop toEdge:NSLayoutAttributeBottom ofView:redView];
        [blueView fw_setDimension:NSLayoutAttributeHeight toSize:FWScreenHeight];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.isTop) {
        CGFloat distance = [scrollView.fw hoverView:self.hoverView fromSuperview:self.redView toSuperview:self.view toPosition:FWTopBarHeight];
        if (distance <= 0) {
            self.navigationController.navigationBar.fw_backgroundColor = [UIColor whiteColor];
        } else if (distance <= FWTopBarHeight) {
            self.navigationController.navigationBar.fw_backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:1 - distance / FWTopBarHeight];
        }
    } else {
        [scrollView.fw hoverView:self.hoverView fromSuperview:self.redView toSuperview:self.view toPosition:0];
    }
}

@end
