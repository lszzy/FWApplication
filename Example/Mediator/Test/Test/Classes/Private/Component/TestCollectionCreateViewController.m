//
//  TestCollectionCreateViewController.m
//  Example
//
//  Created by wuyong on 2020/10/19.
//  Copyright © 2020 site.wuyong. All rights reserved.
//

#import "TestCollectionCreateViewController.h"

@interface TestCollectionCreateObject : NSObject

@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy) NSString *text;

@property (nonatomic, copy) NSString *imageUrl;

@end

@implementation TestCollectionCreateObject

@end

@interface TestCollectionCreateCell : UICollectionViewCell <FWView>

@property (nonatomic, strong) TestCollectionCreateObject *object;

@property (nonatomic, strong) UILabel *myTitleLabel;

@property (nonatomic, strong) UILabel *myTextLabel;

@property (nonatomic, strong) UIImageView *myImageView;

@end

@implementation TestCollectionCreateCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.contentView.backgroundColor = UIColor.fw_randomColor;
        
        UILabel *titleLabel = [UILabel new];
        titleLabel.numberOfLines = 0;
        titleLabel.font = [UIFont fw_fontOfSize:15];
        titleLabel.textColor = [Theme textColor];
        self.myTitleLabel = titleLabel;
        [self.contentView addSubview:titleLabel];
        [titleLabel fw_layoutMaker:^(FWLayoutChain * _Nonnull make) {
            make.leftWithInset(15).rightWithInset(15).topWithInset(15);
        }];
        
        UILabel *textLabel = [UILabel new];
        textLabel.numberOfLines = 0;
        textLabel.font = [UIFont fw_fontOfSize:13];
        textLabel.textColor = [Theme textColor];
        self.myTextLabel = textLabel;
        [self.contentView addSubview:textLabel];
        [textLabel fw_layoutMaker:^(FWLayoutChain * _Nonnull make) {
            make.leftToView(titleLabel).rightToView(titleLabel);
            NSLayoutConstraint *constraint = [textLabel fw_pinEdge:NSLayoutAttributeTop toEdge:NSLayoutAttributeBottom ofView:titleLabel withOffset:10];
            [textLabel fw_addCollapseConstraint:constraint];
            textLabel.fw_autoCollapse = YES;
        }];
        
        // maxY视图不需要和bottom布局，默认平齐，可设置底部间距
        self.fw_maxYViewPadding = 15;
        UIImageView *imageView = [UIImageView new];
        self.myImageView = imageView;
        [imageView fw_setContentModeAspectFill];
        [self.contentView addSubview:imageView];
        [imageView fw_layoutMaker:^(FWLayoutChain * _Nonnull make) {
            [imageView fw_pinEdgeToSuperview:NSLayoutAttributeLeft withInset:15];
            NSLayoutConstraint *widthCons = [imageView fw_setDimension:NSLayoutAttributeWidth toSize:100];
            NSLayoutConstraint *heightCons = [imageView fw_setDimension:NSLayoutAttributeHeight toSize:100];
            NSLayoutConstraint *constraint = [imageView fw_pinEdge:NSLayoutAttributeTop toEdge:NSLayoutAttributeBottom ofView:textLabel withOffset:10];
            [imageView fw_addCollapseConstraint:widthCons];
            [imageView fw_addCollapseConstraint:heightCons];
            [imageView fw_addCollapseConstraint:constraint];
            imageView.fw_autoCollapse = YES;
        }];
    }
    return self;
}

- (void)setObject:(TestCollectionCreateObject *)object
{
    _object = object;
    // 自动收缩
    self.myTitleLabel.text = object.title;
    if ([object.imageUrl fw_isFormatUrl]) {
        [self.myImageView fw_setImageWithURL:[NSURL URLWithString:object.imageUrl] placeholderImage:[TestBundle imageNamed:@"public_icon"]];
    } else if (object.imageUrl.length > 0) {
        self.myImageView.image = [TestBundle imageNamed:object.imageUrl];
    } else {
        self.myImageView.image = nil;
    }
    // 手工收缩
    self.myTextLabel.text = object.text;
}

- (void)renderData
{
    self.myTitleLabel.text = @"我是标题";
    self.myImageView.image = [TestBundle imageNamed:@"public_icon"];
    self.myTextLabel.text = @"我是文本";
}

@end

@interface TestCollectionCreateHeaderView : UICollectionReusableView <FWView>

@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation TestCollectionCreateHeaderView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UIColor.fw_randomColor;
        self.fw_maxYViewPadding = 15;
        
        UILabel *titleLabel = [UILabel fw_labelWithFont:[UIFont fw_fontOfSize:15] textColor:[Theme textColor]];
        titleLabel.numberOfLines = 0;
        _titleLabel = titleLabel;
        [self addSubview:titleLabel];
        titleLabel.fw_layoutChain.leftWithInset(15).topWithInset(15).rightWithInset(15);
    }
    return self;
}

- (void)renderData
{
    self.titleLabel.text = FWSafeString(self.fw_viewModel ?: @"我是Header");
}

@end

@interface TestCollectionCreateViewController () <FWSkeletonViewDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;

@end

@implementation TestCollectionCreateViewController

- (void)renderView
{
    self.collectionView = [UICollectionView fw_collectionView];
    self.collectionView.fw_delegate.collectionData = @[@[]];
    self.collectionView.backgroundColor = [Theme backgroundColor];
    self.collectionView.alwaysBounceVertical = YES;
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    flowLayout.minimumLineSpacing = 0;
    flowLayout.minimumInteritemSpacing = 0;
    flowLayout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    FWWeakifySelf();
    self.collectionView.fw_delegate.cellClass = [TestCollectionCreateCell class];
    self.collectionView.fw_delegate.cellConfiguration = ^(TestCollectionCreateCell * _Nonnull cell, NSIndexPath * _Nonnull indexPath) {
        FWStrongifySelf();
        cell.object = self.collectionView.fw_delegate.collectionData[indexPath.section][indexPath.row];
    };
    self.collectionView.fw_delegate.didSelectItem = ^(NSIndexPath * indexPath) {
        FWStrongifySelf();
        [self fw_showAlertWithTitle:nil message:[NSString stringWithFormat:@"点击了%@", @(indexPath.item)] cancel:nil cancelBlock:nil];
    };
    
    self.collectionView.fw_delegate.headerViewClass = [TestCollectionCreateHeaderView class];
    self.collectionView.fw_delegate.footerViewClass = [TestCollectionCreateHeaderView class];
    self.collectionView.fw_delegate.headerConfiguration = ^(TestCollectionCreateHeaderView * _Nonnull headerView, NSIndexPath *indexPath) {
        headerView.fw_viewModel = @"我是Header\n我是Header";
    };
    self.collectionView.fw_delegate.footerConfiguration = ^(TestCollectionCreateHeaderView * _Nonnull headerView, NSIndexPath *indexPath) {
        headerView.fw_viewModel = @"我是Footer\n我是Footer\n我是Footer";
    };
    
    [self.view addSubview:self.collectionView];
    [self.collectionView fw_pinEdgesToSuperview];
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
    
    [self.collectionView fw_setRefreshingTarget:self action:@selector(onRefreshing)];
    [self.collectionView fw_setLoadingTarget:self action:@selector(onLoading)];
}

- (void)renderModel
{
    FWWeakifySelf();
    [self fw_setRightBarItem:FWIcon.addImage block:^(id sender) {
        FWStrongifySelf();
        NSMutableArray *sectionData = self.collectionView.fw_delegate.collectionData[0].mutableCopy;
        [sectionData addObjectsFromArray:@[[self randomObject], [self randomObject]]];
        self.collectionView.fw_delegate.collectionData = @[sectionData];
        [self.collectionView fw_reloadDataWithoutAnimation];
    }];
}

- (void)renderData
{
    [self.collectionView fw_beginRefreshing];
}

- (void)onRefreshing
{
    NSLog(@"开始刷新");
    [self fw_showSkeleton];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"刷新完成");
        [self fw_hideSkeleton];
        
        self.collectionView.fw_delegate.collectionData = @[@[[self randomObject], [self randomObject]]];
        [self.collectionView fw_clearSizeCache];
        [self.collectionView fw_reloadDataWithoutAnimation];
        
        [self.collectionView fw_endRefreshing];
    });
}

- (void)onLoading
{
    NSLog(@"开始加载");
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"加载完成");
        
        NSMutableArray *sectionData = self.collectionView.fw_delegate.collectionData[0].mutableCopy;
        [sectionData addObjectsFromArray:@[[self randomObject], [self randomObject]]];
        self.collectionView.fw_delegate.collectionData = @[sectionData];
        [self.collectionView fw_reloadDataWithoutAnimation];
        
        [self.collectionView fw_endLoading];
    });
}

- (TestCollectionCreateObject *)randomObject
{
    static NSMutableArray<NSArray *> *randomArray;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        randomArray = [NSMutableArray array];
        
        [randomArray addObject:@[
                                 @"",
                                 @"这是标题",
                                 @"这是复杂的标题这是复杂的标题这是复杂的标题",
                                 @"这是复杂的标题这是复杂的标题\n这是复杂的标题这是复杂的标题",
                                 @"这是复杂的标题\n这是复杂的标题\n这是复杂的标题\n这是复杂的标题",
                                 ]];
        
        [randomArray addObject:@[
                                 @"",
                                 @"这是内容",
                                 @"这是复杂的内容这是复杂的内容这是复杂的内容这是复杂的内容这是复杂的内容这是复杂的内容这是复杂的内容这是复杂的内容这是复杂的内容",
                                 @"这是复杂的内容这是复杂的内容\n这是复杂的内容这是复杂的内容",
                                 @"这是复杂的内容这是复杂的内容\n这是复杂的内容这是复杂的内容\n这是复杂的内容这是复杂的内容\n这是复杂的内容这是复杂的内容",
                                 ]];
        
        [randomArray addObject:@[
                                 @"",
                                 @"public_icon",
                                 @"http://www.ioncannon.net/wp-content/uploads/2011/06/test2.webp",
                                 @"http://littlesvr.ca/apng/images/SteamEngine.webp",
                                 @"public_picture",
                                 @"http://ww2.sinaimg.cn/thumbnail/9ecab84ejw1emgd5nd6eaj20c80c8q4a.jpg",
                                 @"http://ww2.sinaimg.cn/thumbnail/642beb18gw1ep3629gfm0g206o050b2a.gif",
                                 @"http://ww4.sinaimg.cn/thumbnail/9e9cb0c9jw1ep7nlyu8waj20c80kptae.jpg",
                                 @"https://pic3.zhimg.com/b471eb23a_im.jpg",
                                 @"http://ww4.sinaimg.cn/thumbnail/8e88b0c1gw1e9lpr4nndfj20gy0o9q6i.jpg",
                                 @"http://ww3.sinaimg.cn/thumbnail/8e88b0c1gw1e9lpr57tn9j20gy0obn0f.jpg",
                                 @"http://ww2.sinaimg.cn/thumbnail/677febf5gw1erma104rhyj20k03dz16y.jpg",
                                 @"http://ww4.sinaimg.cn/thumbnail/677febf5gw1erma1g5xd0j20k0esa7wj.jpg"
                                 ]];
    });
    
    TestCollectionCreateObject *object = [TestCollectionCreateObject new];
    object.title = [[randomArray objectAtIndex:0] fw_randomObject];
    object.text = [[randomArray objectAtIndex:1] fw_randomObject];
    NSString *imageName =[[randomArray objectAtIndex:2] fw_randomObject];
    if (imageName.length > 0) {
        object.imageUrl = imageName;
    }
    return object;
}

- (void)skeletonViewLayout:(FWSkeletonLayout *)layout
{
    [layout setScrollView:self.collectionView scrollBlock:nil];
    
    FWSkeletonCollectionView *collectionView = (FWSkeletonCollectionView *)[layout addSkeletonView:self.collectionView];
    // 没有数据时需要指定cell，有数据时无需指定
    collectionView.collectionDelegate.cellClass = [TestCollectionCreateCell class];
    // 测试header直接指定类时自动计算高度
    collectionView.collectionDelegate.headerViewClass = [TestCollectionCreateHeaderView class];
}

@end
