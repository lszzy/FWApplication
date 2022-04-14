//
//  TestTableDynamicLayoutViewController.m
//  Example
//
//  Created by wuyong on 2020/9/17.
//  Copyright © 2020 site.wuyong. All rights reserved.
//

#import "TestTableDynamicLayoutViewController.h"

static BOOL isExpanded = NO;

@interface TestTableDynamicLayoutObject : NSObject

@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy) NSString *text;

@property (nonatomic, copy) NSString *imageUrl;

@end

@implementation TestTableDynamicLayoutObject

@end

@interface TestTableDynamicLayoutCell : UITableViewCell

@property (nonatomic, strong) TestTableDynamicLayoutObject *object;

@property (nonatomic, strong) UILabel *myTitleLabel;

@property (nonatomic, strong) UILabel *myTextLabel;

@property (nonatomic, strong) UIImageView *myImageView;

@property (nonatomic, copy) void (^imageClicked)(TestTableDynamicLayoutObject *object);

@end

@implementation TestTableDynamicLayoutCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.fwSeparatorInset = UIEdgeInsetsZero;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.contentView.backgroundColor = [Theme cellColor];
        
        UILabel *titleLabel = [UILabel new];
        titleLabel.numberOfLines = 0;
        titleLabel.font = [UIFont.fw fontOfSize:15];
        titleLabel.textColor = [Theme textColor];
        self.myTitleLabel = titleLabel;
        [self.contentView addSubview:titleLabel];
        [titleLabel.fw layoutMaker:^(FWLayoutChain * _Nonnull make) {
            make.leftWithInset(15).rightWithInset(15).topWithInset(15);
        }];
        
        UILabel *textLabel = [UILabel new];
        textLabel.numberOfLines = 0;
        textLabel.font = [UIFont.fw fontOfSize:13];
        textLabel.textColor = [Theme textColor];
        self.myTextLabel = textLabel;
        [self.contentView addSubview:textLabel];
        [textLabel.fw layoutMaker:^(FWLayoutChain * _Nonnull make) {
            make.leftToView(titleLabel).rightToView(titleLabel);
            NSLayoutConstraint *constraint = [textLabel.fw pinEdge:NSLayoutAttributeTop toEdge:NSLayoutAttributeBottom ofView:titleLabel withOffset:10];
            [textLabel.fw addCollapseConstraint:constraint];
            textLabel.fw.autoCollapse = YES;
        }];
        
        // maxY视图不需要和bottom布局，默认平齐，可设置底部间距
        self.fw.maxYViewPadding = 15;
        UIImageView *imageView = [UIImageView new];
        self.myImageView = imageView;
        imageView.userInteractionEnabled = YES;
        [imageView fwSetContentModeAspectFill];
        [imageView.fw addTapGestureWithTarget:self action:@selector(onImageClick:)];
        [self.contentView addSubview:imageView];
        [imageView.fw layoutMaker:^(FWLayoutChain * _Nonnull make) {
            [imageView.fw pinEdgeToSuperview:NSLayoutAttributeLeft withInset:15];
            [imageView.fw pinEdgeToSuperview:NSLayoutAttributeBottom withInset:15];
            NSLayoutConstraint *widthCons = [imageView.fw setDimension:NSLayoutAttributeWidth toSize:100];
            NSLayoutConstraint *heightCons = [imageView.fw setDimension:NSLayoutAttributeHeight toSize:100];
            NSLayoutConstraint *constraint = [imageView.fw pinEdge:NSLayoutAttributeTop toEdge:NSLayoutAttributeBottom ofView:textLabel withOffset:10];
            [imageView.fw addCollapseConstraint:widthCons];
            [imageView.fw addCollapseConstraint:heightCons];
            [imageView.fw addCollapseConstraint:constraint];
            imageView.fw.autoCollapse = YES;
        }];
    }
    return self;
}

- (void)setObject:(TestTableDynamicLayoutObject *)object
{
    _object = object;
    // 自动收缩
    self.myTitleLabel.text = object.title;
    if ([object.imageUrl fwIsFormatUrl]) {
        [self.myImageView.fw setImageWithURL:[NSURL URLWithString:object.imageUrl] placeholderImage:[TestBundle imageNamed:@"public_icon"]];
    } else if (object.imageUrl.length > 0) {
        self.myImageView.image = [TestBundle imageNamed:object.imageUrl];
    } else {
        self.myImageView.image = nil;
    }
    // 手工收缩
    self.myTextLabel.text = object.text;
    
    [self.myImageView.fw constraintToSuperview:NSLayoutAttributeBottom].active = isExpanded;
    self.fw.maxYViewExpanded = isExpanded;
}

- (void)onImageClick:(UIGestureRecognizer *)gesture
{
    if (self.imageClicked) {
        self.imageClicked(self.object);
    }
}

@end

@interface TestTableDynamicLayoutHeaderView : UITableViewHeaderFooterView

@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation TestTableDynamicLayoutHeaderView

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = [Theme cellColor];
        self.fw.maxYViewPadding = 15;
        
        UILabel *titleLabel = [UILabel.fw labelWithFont:[UIFont.fw fontOfSize:15] textColor:[Theme textColor]];
        titleLabel.numberOfLines = 0;
        _titleLabel = titleLabel;
        [self.contentView addSubview:titleLabel];
        titleLabel.fw.layoutChain.leftWithInset(15).topWithInset(15).rightWithInset(15).bottomWithInset(15);
    }
    return self;
}

- (void)setFwViewModel:(id)fwViewModel
{
    [super setFwViewModel:fwViewModel];
    
    self.titleLabel.text = FWSafeString(fwViewModel);
    
    [self.titleLabel.fw constraintToSuperview:NSLayoutAttributeBottom].active = isExpanded;
    self.fw.maxYViewExpanded = isExpanded;
}

@end

@interface TestTableDynamicLayoutViewController () <FWTableViewController>

@end

@implementation TestTableDynamicLayoutViewController

- (UITableViewStyle)renderTableStyle
{
    return UITableViewStyleGrouped;
}

- (void)renderView
{
    // [self.tableView fwSetTemplateLayout:NO];
    
    FWWeakifySelf();
    [self.tableView fwResetGroupedStyle];
    self.tableView.backgroundColor = [Theme tableColor];
    [self.tableView.fw setRefreshingBlock:^{
        FWStrongifySelf();
        
        [self onRefreshing];
    }];
    self.tableView.fw.pullRefreshView.stateBlock = ^(FWPullRefreshView * _Nonnull view, FWPullRefreshState state) {
        FWStrongifySelf();
        
        self.navigationItem.title = [NSString stringWithFormat:@"refresh state-%@", @(state)];
    };
    self.tableView.fw.pullRefreshView.progressBlock = ^(FWPullRefreshView * _Nonnull view, CGFloat progress) {
        FWStrongifySelf();
        
        self.navigationItem.title = [NSString stringWithFormat:@"refresh progress-%.2f", progress];
    };
    
    FWInfiniteScrollView.height = 64;
    [self.tableView.fw setLoadingBlock:^{
        FWStrongifySelf();
        
        [self onLoading];
    }];
    self.tableView.fw.infiniteScrollView.preloadHeight = 200;
    self.tableView.fw.infiniteScrollView.stateBlock = ^(FWInfiniteScrollView * _Nonnull view, FWInfiniteScrollState state) {
        FWStrongifySelf();
        
        self.navigationItem.title = [NSString stringWithFormat:@"load state-%@", @(state)];
    };
    self.tableView.fw.infiniteScrollView.progressBlock = ^(FWInfiniteScrollView * _Nonnull view, CGFloat progress) {
        FWStrongifySelf();
        
        self.navigationItem.title = [NSString stringWithFormat:@"load progress-%.2f", progress];
    };
}

- (void)renderModel
{
    FWWeakifySelf();
    [self fwSetRightBarItem:FWIcon.refreshImage block:^(id  _Nonnull sender) {
        FWStrongifySelf();
        [self.fw showSheetWithTitle:nil message:nil cancel:@"取消" actions:@[@"刷新", @"布局撑开", @"布局不撑开"] actionBlock:^(NSInteger index) {
            FWStrongifySelf();
            
            if (index == 1) {
                isExpanded = YES;
            } else if (index == 2) {
                isExpanded = NO;
            }
            [self renderData];
        }];
    }];
}

- (void)renderData
{
    [self.tableView.fw beginRefreshing];
}

#pragma mark - TableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tableData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 渲染可重用Cell
    TestTableDynamicLayoutCell *cell = [TestTableDynamicLayoutCell.fw cellWithTableView:tableView];
    FWWeakifySelf();
    FWWeakify(cell);
    cell.imageClicked = ^(TestTableDynamicLayoutObject *object) {
        FWStrongifySelf();
        FWStrongify(cell);
        [self onPhotoBrowser:cell indexPath:indexPath];
    };
    cell.object = [self.tableData objectAtIndex:indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 最后一次上拉会产生跳跃，处理此方法即可
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [tableView.fw heightWithCellClass:[TestTableDynamicLayoutCell class]
                           cacheByIndexPath:indexPath
                              configuration:^(TestTableDynamicLayoutCell * _Nonnull cell) {
        cell.object = [self.tableData objectAtIndex:indexPath.row];
    }];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.tableData removeObjectAtIndex:indexPath.row];
        [self.tableView fwReloadDataWithoutCache];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    TestTableDynamicLayoutHeaderView *headerView = [TestTableDynamicLayoutHeaderView.fw headerFooterViewWithTableView:tableView];
    headerView.fwViewModel = @"我是表格Header\n我是表格Header";
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CGFloat height = [tableView.fw heightWithHeaderFooterViewClass:[TestTableDynamicLayoutHeaderView class] type:FWHeaderFooterViewTypeHeader configuration:^(TestTableDynamicLayoutHeaderView *headerView) {
        headerView.fwViewModel = @"我是表格Header\n我是表格Header";
    }];
    return height;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    TestTableDynamicLayoutHeaderView *footerView = [TestTableDynamicLayoutHeaderView.fw headerFooterViewWithTableView:tableView];
    footerView.fwViewModel = @"我是表格Footer\n我是表格Footer\n我是表格Footer";
    return footerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    CGFloat height = [tableView.fw heightWithHeaderFooterViewClass:[TestTableDynamicLayoutHeaderView class] type:FWHeaderFooterViewTypeFooter configuration:^(TestTableDynamicLayoutHeaderView *footerView) {
        footerView.fwViewModel = @"我是表格Footer\n我是表格Footer\n我是表格Footer";
    }];
    return height;
}

- (TestTableDynamicLayoutObject *)randomObject
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
                                 @"public_icon",
                                 @"http://www.ioncannon.net/wp-content/uploads/2011/06/test2.webp",
                                 @"http://littlesvr.ca/apng/images/SteamEngine.webp",
                                 @"public_picture",
                                 @"http://ww2.sinaimg.cn/bmiddle/9ecab84ejw1emgd5nd6eaj20c80c8q4a.jpg",
                                 @"http://ww2.sinaimg.cn/bmiddle/642beb18gw1ep3629gfm0g206o050b2a.gif",
                                 @"test.gif",
                                 @"http://ww4.sinaimg.cn/bmiddle/9e9cb0c9jw1ep7nlyu8waj20c80kptae.jpg",
                                 @"https://pic3.zhimg.com/b471eb23a_im.jpg",
                                 @"http://ww4.sinaimg.cn/bmiddle/8e88b0c1gw1e9lpr4nndfj20gy0o9q6i.jpg",
                                 @"http://ww3.sinaimg.cn/bmiddle/8e88b0c1gw1e9lpr57tn9j20gy0obn0f.jpg",
                                 @"http://ww2.sinaimg.cn/bmiddle/677febf5gw1erma104rhyj20k03dz16y.jpg",
                                 @"http://ww4.sinaimg.cn/bmiddle/677febf5gw1erma1g5xd0j20k0esa7wj.jpg"
                                 ]];
    });
    
    TestTableDynamicLayoutObject *object = [TestTableDynamicLayoutObject new];
    object.title = [[randomArray objectAtIndex:0].fw randomObject];
    object.text = [[randomArray objectAtIndex:1].fw randomObject];
    object.imageUrl =[[randomArray objectAtIndex:2].fw randomObject];
    return object;
}

- (void)onRefreshing
{
    NSLog(@"开始刷新");
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"刷新完成");
        
        [self.tableData removeAllObjects];
        for (int i = 0; i < 4; i++) {
            [self.tableData addObject:[self randomObject]];
        }
        [self.tableView fwReloadDataWithoutCache];
        
        self.tableView.fw.showRefreshing = self.tableData.count < 20 ? YES : NO;
        [self.tableView.fw endRefreshing];
        if (!self.tableView.fw.showRefreshing) {
            self.navigationItem.rightBarButtonItem = nil;
        }
    });
}

- (void)onLoading
{
    NSLog(@"开始加载");
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"加载完成");
        
        for (int i = 0; i < 4; i++) {
            [self.tableData addObject:[self randomObject]];
        }
        [self.tableView reloadData];
        
        self.tableView.fw.showLoading = self.tableData.count < 20 ? YES : NO;
        [self.tableView.fw endLoading];
    });
}

#pragma mark - FWPhotoBrowserDelegate

- (void)onPhotoBrowser:(TestTableDynamicLayoutCell *)cell indexPath:(NSIndexPath *)indexPath
{
    // 移除所有缓存
    [[FWImageDownloader defaultInstance].imageCache removeAllImages];
    [[FWImageDownloader defaultURLCache] removeAllCachedResponses];
    
    NSMutableArray *pictureUrls = [NSMutableArray array];
    NSInteger count = 0;
    for (TestTableDynamicLayoutObject *object in self.tableData) {
        NSString *imageUrl = object.imageUrl;
        imageUrl.fw.tempObject = @(count++);
        if ([imageUrl fwIsFormatUrl] || imageUrl.length < 1) {
            [pictureUrls addObject:imageUrl];
        } else {
            [pictureUrls addObject:[TestBundle imageNamed:object.imageUrl]];
        }
    }
    
    FWWeakifySelf();
    [self.fw showImagePreviewWithImageURLs:pictureUrls imageInfos:nil currentIndex:indexPath.row sourceView:^id _Nullable(NSInteger index) {
        FWStrongifySelf();
        TestTableDynamicLayoutCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
        return cell.myImageView;
    }];
}

@end
