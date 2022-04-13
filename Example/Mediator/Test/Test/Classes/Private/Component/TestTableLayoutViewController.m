/*!
 @header     TestTableLayoutViewController.m
 @indexgroup Example
 @brief      TestTableLayoutViewController
 @author     wuyong
 @copyright  Copyright © 2018年 wuyong.site. All rights reserved.
 @updated    2018/9/21
 */

#import "TestTableLayoutViewController.h"

@interface TestTableLayoutObject : NSObject

@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy) NSString *text;

@property (nonatomic, copy) NSString *imageUrl;

@end

@implementation TestTableLayoutObject

@end

@interface TestTableLayoutCell ()

@property (nonatomic, strong) TestTableLayoutObject *object;

@property (nonatomic, strong) UILabel *myTitleLabel;

@property (nonatomic, strong) UILabel *myTextLabel;

@property (nonatomic, strong) UIImageView *myImageView;

@property (nonatomic, copy) void (^imageClicked)(TestTableLayoutObject *object);

@end

@implementation TestTableLayoutCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.fwSeparatorInset = UIEdgeInsetsZero;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [Theme backgroundColor];
        
        UIView *bgView = [UIView new];
        bgView.backgroundColor = [Theme cellColor];
        bgView.layer.masksToBounds = NO;
        bgView.layer.cornerRadius = 10;
        [bgView.fw setShadowColor:[UIColor grayColor] offset:CGSizeMake(0, 0) radius:5];
        [self.contentView addSubview:bgView];
        bgView.fw.layoutChain.edgesWithInsets(UIEdgeInsetsMake(10, 10, 10, 10));
        
        UIView *expectView = [UIView new];
        expectView.backgroundColor = [UIColor redColor];
        expectView.hidden = YES;
        [bgView addSubview:expectView];
        expectView.fw.layoutChain.edgesWithInsets(UIEdgeInsetsMake(10, 10, 10, 10));
        
        UILabel *titleLabel = [UILabel new];
        titleLabel.numberOfLines = 0;
        titleLabel.font = [UIFont.fw fontOfSize:15];
        titleLabel.textColor = [Theme textColor];
        self.myTitleLabel = titleLabel;
        [bgView addSubview:titleLabel]; {
            [titleLabel.fw pinEdgeToSuperview:NSLayoutAttributeLeft withInset:15];
            [titleLabel.fw pinEdgeToSuperview:NSLayoutAttributeRight withInset:15];
            NSLayoutConstraint *constraint = [titleLabel.fw pinEdgeToSuperview:NSLayoutAttributeTop withInset:15];
            [titleLabel.fw addCollapseConstraint:constraint];
            titleLabel.fw.autoCollapse = YES;
        }
        
        UILabel *textLabel = [UILabel new];
        textLabel.numberOfLines = 0;
        textLabel.font = [UIFont.fw fontOfSize:13];
        textLabel.textColor = [Theme textColor];
        self.myTextLabel = textLabel;
        [bgView addSubview:textLabel]; {
            [textLabel.fw pinEdgeToSuperview:NSLayoutAttributeLeft withInset:15];
            [textLabel.fw pinEdgeToSuperview:NSLayoutAttributeRight withInset:15];
            NSLayoutConstraint *constraint = [textLabel.fw pinEdge:NSLayoutAttributeTop toEdge:NSLayoutAttributeBottom ofView:titleLabel withOffset:10];
            [textLabel.fw addCollapseConstraint:constraint];
        }
        
        UIImageView *imageView = [UIImageView new];
        self.myImageView = imageView;
        imageView.userInteractionEnabled = YES;
        [imageView.fw addTapGestureWithTarget:self action:@selector(onImageClick:)];
        [bgView addSubview:imageView]; {
            [imageView.fw pinEdgeToSuperview:NSLayoutAttributeLeft withInset:15];
            [imageView.fw pinEdgeToSuperview:NSLayoutAttributeRight withInset:15 relation:NSLayoutRelationGreaterThanOrEqual];
            [imageView.fw pinEdgeToSuperview:NSLayoutAttributeBottom withInset:15];
            NSLayoutConstraint *constraint = [imageView.fw pinEdge:NSLayoutAttributeTop toEdge:NSLayoutAttributeBottom ofView:textLabel withOffset:10];
            [imageView.fw addCollapseConstraint:constraint];
            imageView.fw.autoCollapse = YES;
        }
    }
    return self;
}

- (void)setObject:(TestTableLayoutObject *)object
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
    if (object.text.length > 0) {
        self.myTextLabel.fw.collapsed = NO;
    } else {
        self.myTextLabel.fw.collapsed = YES;
    }
}

- (void)onImageClick:(UIGestureRecognizer *)gesture
{
    if (self.imageClicked) {
        self.imageClicked(self.object);
    }
}

@end

@interface TestTableLayoutViewController () <FWTableViewController>

@property (nonatomic, assign) BOOL isShort;

@end

@implementation TestTableLayoutViewController

- (void)renderView
{
    self.isShort = [@[@0, @1].fw.randomObject fw].safeInteger == 0;
    FWWeakifySelf();
    [self.tableView fwSetRefreshingBlock:^{
        FWStrongifySelf();
        
        [self onRefreshing];
    }];
    self.tableView.fwPullRefreshView.stateBlock = ^(FWPullRefreshView * _Nonnull view, FWPullRefreshState state) {
        FWStrongifySelf();
        
        self.navigationItem.title = [NSString stringWithFormat:@"refresh state-%@", @(state)];
    };
    self.tableView.fwPullRefreshView.progressBlock = ^(FWPullRefreshView * _Nonnull view, CGFloat progress) {
        FWStrongifySelf();
        
        self.navigationItem.title = [NSString stringWithFormat:@"refresh progress-%.2f", progress];
    };
    
    FWInfiniteScrollView.height = 64;
    [self.tableView fwSetLoadingBlock:^{
        FWStrongifySelf();
        
        [self onLoading];
    }];
    self.tableView.fwInfiniteScrollView.preloadHeight = self.isShort ? 0 : 200;
    self.tableView.fwInfiniteScrollView.stateBlock = ^(FWInfiniteScrollView * _Nonnull view, FWInfiniteScrollState state) {
        FWStrongifySelf();
        
        self.navigationItem.title = [NSString stringWithFormat:@"load state-%@", @(state)];
    };
    self.tableView.fwInfiniteScrollView.progressBlock = ^(FWInfiniteScrollView * _Nonnull view, CGFloat progress) {
        FWStrongifySelf();
        
        self.navigationItem.title = [NSString stringWithFormat:@"load progress-%.2f", progress];
    };
}

- (void)renderModel
{
    [self fwSetRightBarItem:FWIcon.refreshImage target:self action:@selector(renderData)];
}

- (void)renderData
{
    [self.tableView fwBeginRefreshing];
}

#pragma mark - TableView

- (void)renderTableView
{
    self.tableView.backgroundColor = [Theme tableColor];
    [self.tableView registerClass:[TestTableLayoutCell class] forCellReuseIdentifier:@"Cell"];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tableData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 渲染可重用Cell
    TestTableLayoutCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    FWWeakifySelf();
    FWWeakify(cell);
    cell.imageClicked = ^(TestTableLayoutObject *object) {
        FWStrongifySelf();
        FWStrongify(cell);
        [self onPhotoBrowser:cell];
    };
    TestTableLayoutObject *object = [self.tableData objectAtIndex:indexPath.row];
    cell.object = object;
    return cell;
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
        [self.tableView reloadData];
    }
}

- (TestTableLayoutObject *)randomObject
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
    
    TestTableLayoutObject *object = [TestTableLayoutObject new];
    object.title = [[randomArray objectAtIndex:0].fw randomObject];
    object.text = [[randomArray objectAtIndex:1].fw randomObject];
    NSString *imageName =[[randomArray objectAtIndex:2].fw randomObject];
    if (imageName.length > 0) {
        object.imageUrl = imageName;
    }
    return object;
}

- (void)onRefreshing
{
    NSLog(@"开始刷新");
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"刷新完成");
        
        [self.tableData removeAllObjects];
        for (int i = 0; i < (self.isShort ? 1 : 4); i++) {
            [self.tableData addObject:[self randomObject]];
        }
        [self.tableView reloadData];
        
        self.tableView.fwShowRefreshing = self.tableData.count < 20 ? YES : NO;
        [self.tableView fwEndRefreshing];
        if (!self.tableView.fwShowRefreshing) {
            self.navigationItem.rightBarButtonItem = nil;
        }
    });
}

- (void)onLoading
{
    NSLog(@"开始加载");
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"加载完成");
        
        for (int i = 0; i < (self.isShort ? 1 : 4); i++) {
            [self.tableData addObject:[self randomObject]];
        }
        [self.tableView reloadData];
        
        self.tableView.fwShowLoading = self.tableData.count < 20 ? YES : NO;
        [self.tableView fwEndLoading];
    });
}

#pragma mark - FWPhotoBrowserDelegate

- (void)onPhotoBrowser:(TestTableLayoutCell *)cell
{
    // 移除所有缓存
    [[FWImageDownloader defaultInstance].imageCache removeAllImages];
    [[FWImageDownloader defaultURLCache] removeAllCachedResponses];
    
    // 设置图片浏览
    NSArray *pictureUrls = @[
        @"http://ww2.sinaimg.cn/bmiddle/9ecab84ejw1emgd5nd6eaj20c80c8q4a.jpg",
        @"http://ww2.sinaimg.cn/bmiddle/642beb18gw1ep3629gfm0g206o050b2a.gif",
        @"http://ww4.sinaimg.cn/bmiddle/9e9cb0c9jw1ep7nlyu8waj20c80kptae.jpg",
        [TestBundle imageNamed:@"public_picture"],
        @"http://www.ioncannon.net/wp-content/uploads/2011/06/test2.webp",
        @"http://littlesvr.ca/apng/images/SteamEngine.webp",
        @"https://pic3.zhimg.com/b471eb23a_im.jpg",
        @"http://ww4.sinaimg.cn/bmiddle/8e88b0c1gw1e9lpr4nndfj20gy0o9q6i.jpg",
        [TestBundle imageNamed:@"public_icon"],
        @"http://ww3.sinaimg.cn/bmiddle/8e88b0c1gw1e9lpr57tn9j20gy0obn0f.jpg",
        @"http://ww2.sinaimg.cn/bmiddle/677febf5gw1erma104rhyj20k03dz16y.jpg",
        [TestBundle imageNamed:@"test.gif"],
        @"http://ww4.sinaimg.cn/bmiddle/677febf5gw1erma1g5xd0j20k0esa7wj.jpg"
    ];
    // 设置打开Index
    NSString *fromImageUrl = [cell.object.imageUrl stringByReplacingOccurrencesOfString:@"thumbnail" withString:@"bmiddle"];
    NSInteger currentIndex = [pictureUrls indexOfObject:fromImageUrl];
    [self fwShowImagePreviewWithImageURLs:pictureUrls imageInfos:nil currentIndex:currentIndex != NSNotFound ? currentIndex : 0 sourceView:nil];
}

@end
