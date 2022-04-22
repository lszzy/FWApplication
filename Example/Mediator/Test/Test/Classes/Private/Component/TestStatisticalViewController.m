//
//  TestStatisticalViewController.m
//  Example
//
//  Created by wuyong on 2020/1/16.
//  Copyright © 2020 wuyong.site. All rights reserved.
//

#import "TestStatisticalViewController.h"
#import "TestWebViewController.h"

@interface TestStatisticalCell : UICollectionViewCell

@property (nonatomic, strong) UILabel *textLabel;

@end

@implementation TestStatisticalCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UILabel *textLabel = [UILabel.fw labelWithFont:[UIFont.fw fontOfSize:15] textColor:[Theme textColor]];
        _textLabel = textLabel;
        [self.contentView addSubview:textLabel];
        textLabel.fw.layoutChain.center();
    }
    return self;
}

@end

@interface TestStatisticalViewController () <FWTableViewController, FWCollectionViewController>

FWPropertyWeak(UIView *, shieldView);
FWPropertyWeak(FWBannerView *, bannerView);
FWPropertyWeak(UIView *, testView);
FWPropertyWeak(UIButton *, testButton);
FWPropertyWeak(UISwitch *, testSwitch);
FWPropertyWeak(FWSegmentedControl *, segmentedControl);
FWPropertyWeak(FWTextTagCollectionView *, tagCollectionView);

@end

@implementation TestStatisticalViewController

+ (void)initialize
{
    FWStatisticalManager.sharedInstance.statisticalEnabled = YES;
}

- (void)renderTableView
{
    UIView *headerView = [UIView new];
    
    FWBannerView *bannerView = [FWBannerView new];
    _bannerView = bannerView;
    bannerView.autoScroll = YES;
    bannerView.autoScrollTimeInterval = 6;
    bannerView.placeholderImage = [TestBundle imageNamed:@"public_icon"];
    [headerView addSubview:bannerView];
    bannerView.fw.layoutChain.leftWithInset(10).topWithInset(50).rightWithInset(10).height(100);
    
    UIView *testView = [UIView new];
    _testView = testView;
    testView.backgroundColor = UIColor.fw.randomColor;
    [headerView addSubview:testView];
    testView.fw.layoutChain.width(100).height(30).centerX().topToBottomOfViewWithOffset(bannerView, 50);
    
    UILabel *testLabel = [UILabel new];
    testLabel.text = @"Banner";
    testLabel.textAlignment = NSTextAlignmentCenter;
    [testView addSubview:testLabel];
    testLabel.fw.layoutChain.edges();
    
    UIButton *testButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _testButton = testButton;
    [testButton setTitle:@"Button" forState:UIControlStateNormal];
    [testButton.fw setBackgroundColor:[UIColor.fw randomColor] forState:UIControlStateNormal];
    [headerView addSubview:testButton];
    testButton.fw.layoutChain.width(100).height(30).centerX().topToBottomOfViewWithOffset(testView, 50);
    
    UISwitch *testSwitch = [UISwitch new];
    _testSwitch = testSwitch;
    testSwitch.thumbTintColor = [UIColor.fw randomColor];
    testSwitch.onTintColor = testSwitch.thumbTintColor;
    [headerView addSubview:testSwitch];
    testSwitch.fw.layoutChain.centerX().topToBottomOfViewWithOffset(testButton, 50);
    
    FWSegmentedControl *segmentedControl = [FWSegmentedControl new];
    self.segmentedControl = segmentedControl;
    self.segmentedControl.backgroundColor = Theme.cellColor;
    self.segmentedControl.selectedSegmentIndex = 1;
    self.segmentedControl.selectionStyle = FWSegmentedControlSelectionStyleBox;
    self.segmentedControl.segmentEdgeInset = UIEdgeInsetsMake(0, 30, 0, 5);
    self.segmentedControl.selectionIndicatorEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 10);
    self.segmentedControl.segmentWidthStyle = FWSegmentedControlSegmentWidthStyleDynamic;
    self.segmentedControl.selectionIndicatorLocation = FWSegmentedControlSelectionIndicatorLocationBottom;
    self.segmentedControl.titleTextAttributes = @{NSFontAttributeName: [UIFont.fw fontOfSize:16], NSForegroundColorAttributeName: Theme.textColor};
    self.segmentedControl.selectedTitleTextAttributes = @{NSFontAttributeName: [UIFont.fw boldFontOfSize:18], NSForegroundColorAttributeName: Theme.textColor};
    [headerView addSubview:self.segmentedControl];
    segmentedControl.fw.layoutChain.leftWithInset(10).rightWithInset(10).topToBottomOfViewWithOffset(testSwitch, 50).height(50);
    
    FWTextTagCollectionView *tagCollectionView = [FWTextTagCollectionView new];
    _tagCollectionView = tagCollectionView;
    tagCollectionView.verticalSpacing = 10;
    tagCollectionView.horizontalSpacing = 10;
    [headerView addSubview:tagCollectionView];
    tagCollectionView.fw.layoutChain.leftWithInset(10).rightWithInset(10).topToBottomOfViewWithOffset(segmentedControl, 50).height(100).bottomWithInset(50);
    
    self.tableView.tableHeaderView = headerView;
    [headerView.fw autoLayoutSubviews];
}

- (void)renderTableLayout
{
    self.tableView.fw.layoutChain.edges();
}

- (UICollectionView *)collectionView
{
    UICollectionView *collectionView = objc_getAssociatedObject(self, _cmd);
    if (!collectionView) {
        collectionView = [[FWViewControllerManager sharedInstance] performIntercepter:_cmd withObject:self];
        objc_setAssociatedObject(self, _cmd, collectionView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return collectionView;
}

- (UICollectionViewLayout *)renderCollectionViewLayout
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake((FWScreenWidth - 10) / 2.f, 100);
    layout.minimumLineSpacing = 10;
    layout.minimumInteritemSpacing = 10;
    return layout;
}

- (void)renderCollectionView
{
    [self.collectionView registerClass:[TestStatisticalCell class] forCellWithReuseIdentifier:@"cell"];
}

- (void)renderCollectionLayout
{
    self.collectionView.fw.layoutChain.edges();
}

- (void)renderView
{
    // 设置遮挡视图
    UIView *shieldView = [UIView new];
    self.shieldView = shieldView;
    shieldView.backgroundColor = [Theme tableColor];
    FWWeakifySelf();
    [shieldView.fw addTapGestureWithBlock:^(UITapGestureRecognizer *sender) {
        FWStrongifySelf();
        [self.shieldView removeFromSuperview];
        self.shieldView = nil;
        // 手工触发曝光计算
        self.view.hidden = self.view.hidden;
    }];
    [UIWindow.fw.mainWindow addSubview:shieldView];
    [shieldView.fw pinEdgesToSuperview];
    
    UILabel *shieldLabel = [UILabel new];
    shieldLabel.text = @"点击关闭";
    shieldLabel.textAlignment = NSTextAlignmentCenter;
    [shieldView addSubview:shieldLabel];
    shieldLabel.fw.layoutChain.edges();
    
    [self.testView.fw addTapGestureWithBlock:^(id  _Nonnull sender) {
        FWStrongifySelf();
        self.testView.backgroundColor = UIColor.fw.randomColor;
        [self.bannerView makeScrollViewScrollToIndex:0];
    }];
    
    [self.testButton.fw addTouchBlock:^(id  _Nonnull sender) {
        FWStrongifySelf();
        [self.testButton.fw setBackgroundColor:UIColor.fw.randomColor forState:UIControlStateNormal];
    }];
    
    [self.testSwitch.fw addBlock:^(id  _Nonnull sender) {
        FWStrongifySelf();
        self.testSwitch.thumbTintColor = UIColor.fw.randomColor;
        self.testSwitch.onTintColor = self.testSwitch.thumbTintColor;
    } forControlEvents:UIControlEventValueChanged];
    
    self.bannerView.clickItemOperationBlock = ^(NSInteger currentIndex) {
        FWStrongifySelf();
        [self clickHandler:currentIndex];
    };
    
    self.segmentedControl.indexChangeBlock = ^(NSUInteger index) {
        FWStrongifySelf();
        self.segmentedControl.selectionIndicatorBoxColor = UIColor.fw.randomColor;
    };
}

- (void)renderModel
{
    self.collectionView.hidden = YES;
    FWWeakifySelf();
    [self.fw setRightBarItem:FWIcon.refreshImage block:^(id  _Nonnull sender) {
        FWStrongifySelf();
        if (self.collectionView.hidden) {
            self.collectionView.hidden = NO;
            self.tableView.hidden = YES;
        } else {
            self.collectionView.hidden = YES;
            self.tableView.hidden = NO;
        }
    }];
    
    NSArray *imageUrls = @[@"http://e.hiphotos.baidu.com/image/h%3D300/sign=0e95c82fa90f4bfb93d09854334e788f/10dfa9ec8a136327ee4765839c8fa0ec09fac7dc.jpg", [TestBundle imageNamed:@"public_picture"], @"http://kvm.wuyong.site/images/images/animation.png", @"http://littlesvr.ca/apng/images/SteamEngine.webp", @"not_found.jpg", @"http://ww2.sinaimg.cn/bmiddle/642beb18gw1ep3629gfm0g206o050b2a.gif"];
    self.bannerView.imageURLStringsGroup = imageUrls;
    NSArray *sectionTitles = @[@"Section0", @"Section1", @"Section2", @"Section3", @"Section4", @"Section5", @"Section6", @"Section7", @"Section8"];
    self.segmentedControl.sectionTitles = sectionTitles;
    [self.tagCollectionView addTags:@[@"标签0", @"标签1", @"标签2", @"标签3", @"标签4", @"标签5"]];
    [self.tagCollectionView removeTag:@"标签4"];
    [self.tagCollectionView removeTag:@"标签5"];
    [self.tagCollectionView addTags:@[@"标签4", @"标签5", @"标签6", @"标签7"]];
}

- (void)renderData
{
    FWWeakifySelf();
    [FWStatisticalManager sharedInstance].globalHandler = ^(FWStatisticalObject *object) {
        if (object.isExposure) {
            FWLogDebug(@"%@曝光通知: \nindexPath: %@\ncount: %@\nname: %@\nobject: %@\nuserInfo: %@\nduration: %@\ntotalDuration: %@", NSStringFromClass(object.view.class), [NSString stringWithFormat:@"%@.%@", @(object.indexPath.section), @(object.indexPath.row)], @(object.triggerCount), object.name, object.object, object.userInfo, @(object.triggerDuration), @(object.totalDuration));
        } else {
            FWStrongifySelf();
            [self showToast:[NSString stringWithFormat:@"%@点击事件: \nindexPath: %@\ncount: %@\nname: %@\nobject: %@\nuserInfo: %@", NSStringFromClass(object.view.class), [NSString stringWithFormat:@"%@.%@", @(object.indexPath.section), @(object.indexPath.row)], @(object.triggerCount), object.name, object.object, object.userInfo]];
        }
    };
    
    // Click
    self.testView.fw.statisticalClick = [[FWStatisticalObject alloc] initWithName:@"click_view" object:@"view"];
    self.testButton.fw.statisticalClick = [[FWStatisticalObject alloc] initWithName:@"click_button" object:@"button"];
    self.testSwitch.fw.statisticalClick = [[FWStatisticalObject alloc] initWithName:@"click_switch" object:@"switch"];
    self.tableView.fw.statisticalClick = [[FWStatisticalObject alloc] initWithName:@"click_tableView" object:@"table"];
    self.bannerView.fw.statisticalClick = [[FWStatisticalObject alloc] initWithName:@"click_banner" object:@"banner"];
    self.segmentedControl.fw.statisticalClick = [[FWStatisticalObject alloc] initWithName:@"click_segment" object:@"segment"];
    self.tagCollectionView.fw.statisticalClick = [[FWStatisticalObject alloc] initWithName:@"click_tag" object:@"tag"];
    
    // Exposure
    self.testView.fw.statisticalExposure = [[FWStatisticalObject alloc] initWithName:@"exposure_view" object:@"view"];
    [self configShieldView:self.testView.fw.statisticalExposure];
    self.testButton.fw.statisticalExposure = [[FWStatisticalObject alloc] initWithName:@"exposure_button" object:@"button"];
    self.testButton.fw.statisticalExposure.triggerOnce = YES;
    [self configShieldView:self.testButton.fw.statisticalExposure];
    self.testSwitch.fw.statisticalExposure = [[FWStatisticalObject alloc] initWithName:@"exposure_switch" object:@"switch"];
    [self configShieldView:self.testSwitch.fw.statisticalExposure];
    self.tableView.fw.statisticalExposure = [[FWStatisticalObject alloc] initWithName:@"exposure_tableView" object:@"table"];
    [self configShieldView:self.tableView.fw.statisticalExposure];
    self.bannerView.fw.statisticalExposure = [[FWStatisticalObject alloc] initWithName:@"exposure_banner" object:@"banner"];
    [self configShieldView:self.bannerView.fw.statisticalExposure];
    self.segmentedControl.fw.statisticalExposure = [[FWStatisticalObject alloc] initWithName:@"exposure_segment" object:@"segment"];
    [self configShieldView:self.segmentedControl.fw.statisticalExposure];
    self.tagCollectionView.fw.statisticalExposure = [[FWStatisticalObject alloc] initWithName:@"exposure_tag" object:@"tag"];
    [self configShieldView:self.tagCollectionView.fw.statisticalExposure];
}

- (void)configShieldView:(FWStatisticalObject *)object
{
    FWWeakifySelf();
    // 动态设置，调用时判断
    object.shieldViewBlock = ^UIView * _Nullable{
        FWStrongifySelf();
        return self.shieldView;
    };
    // weak引用，固定设置
    // object.shieldView = self.shieldView;
}

- (void)showToast:(NSString *)toast
{
    [self.fw showMessageWithText:toast];
}

- (void)clickHandler:(NSInteger)index
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        TestWebViewController *viewController = [TestWebViewController new];
        viewController.requestUrl = @"http://kvm.wuyong.site/test.php";
        if (index % 2 == 0) {
            [self.navigationController pushViewController:viewController animated:YES];
        } else {
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
            [self.navigationController presentViewController:navigationController animated:YES completion:nil];
        }
    });
}

#pragma mark - UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%@", @(indexPath.row)];
    cell.contentView.backgroundColor = UIColor.fw.randomColor;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.contentView.backgroundColor = UIColor.fw.randomColor;
    
    [self clickHandler:indexPath.row];
}

#pragma mark - UICollectionView

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 50;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TestStatisticalCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.textLabel.text = [NSString stringWithFormat:@"%@", @(indexPath.row)];
    cell.contentView.backgroundColor = UIColor.fw.randomColor;
    cell.fw.statisticalClick = [[FWStatisticalObject alloc] initWithName:@"click_collectionView" object:@"cell"];
    cell.fw.statisticalExposure = [[FWStatisticalObject alloc] initWithName:@"exposure_collectionView" object:@"cell"];
    cell.fw.statisticalExposure.triggerOnce = YES;
    [self configShieldView:cell.fw.statisticalExposure];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    cell.contentView.backgroundColor = UIColor.fw.randomColor;
    
    [self clickHandler:indexPath.row];
}

@end
