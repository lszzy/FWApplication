//
//  TestTableScrollViewController.m
//  Example
//
//  Created by wuyong on 2018/12/13.
//  Copyright © 2018 wuyong.site. All rights reserved.
//

#import "TestTableScrollViewController.h"

@interface TestTableScrollObject : NSObject

@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy) NSString *text;

@property (nonatomic, strong) UIImage *image;

@end

@implementation TestTableScrollObject

@end

@interface TestTableScrollCell : UITableViewCell

@property (nonatomic, strong) TestTableScrollObject *object;

@property (nonatomic, strong) UILabel *myTitleLabel;

@property (nonatomic, strong) UILabel *myTextLabel;

@property (nonatomic, strong) UIImageView *myImageView;

@end

@implementation TestTableScrollCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.fw_separatorInset = UIEdgeInsetsZero;
        
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.numberOfLines = 0;
        titleLabel.font = [UIFont fw_fontOfSize:15];
        titleLabel.textColor = [Theme textColor];
        self.myTitleLabel = titleLabel;
        [self.contentView addSubview:titleLabel]; {
            [titleLabel fw_pinEdgeToSuperview:NSLayoutAttributeLeft withInset:15];
            [titleLabel fw_pinEdgeToSuperview:NSLayoutAttributeRight withInset:15];
            NSLayoutConstraint *constraint = [titleLabel fw_pinEdgeToSuperview:NSLayoutAttributeTop withInset:15];
            [titleLabel fw_addCollapseConstraint:constraint];
            titleLabel.fw_autoCollapse = YES;
        }
        
        UILabel *textLabel = [[UILabel alloc] init];
        textLabel.numberOfLines = 0;
        textLabel.font = [UIFont fw_fontOfSize:13];
        textLabel.textColor = [Theme textColor];
        textLabel.fw_hiddenCollapse = YES;
        self.myTextLabel = textLabel;
        [self.contentView addSubview:textLabel]; {
            [textLabel fw_pinEdgeToSuperview:NSLayoutAttributeLeft withInset:15];
            [textLabel fw_pinEdgeToSuperview:NSLayoutAttributeRight withInset:15];
            NSLayoutConstraint *constraint = [textLabel fw_pinEdge:NSLayoutAttributeTop toEdge:NSLayoutAttributeBottom ofView:titleLabel withOffset:10];
            [textLabel fw_addCollapseConstraint:constraint];
        }
        
        UIImageView *imageView = [[UIImageView alloc] init];
        self.myImageView = imageView;
        [self.contentView addSubview:imageView]; {
            [imageView fw_pinEdgeToSuperview:NSLayoutAttributeLeft withInset:15];
            [imageView fw_pinEdgeToSuperview:NSLayoutAttributeRight withInset:15 relation:NSLayoutRelationGreaterThanOrEqual];
            [imageView fw_pinEdgeToSuperview:NSLayoutAttributeBottom withInset:15];
            NSLayoutConstraint *constraint = [imageView fw_pinEdge:NSLayoutAttributeTop toEdge:NSLayoutAttributeBottom ofView:textLabel withOffset:10];
            [imageView fw_addCollapseConstraint:constraint];
            imageView.fw_autoCollapse = YES;
        }
    }
    return self;
}

- (void)setObject:(TestTableScrollObject *)object
{
    _object = object;
    // 自动收缩
    self.myTitleLabel.text = object.title;
    self.myImageView.image = object.image;
    // 隐藏时自动收缩
    self.myTextLabel.text = object.text;
    self.myTextLabel.hidden = object.text.length < 1;
}

@end

@interface TestTableScrollViewController () <FWTableViewController>

@end

@implementation TestTableScrollViewController

- (UITableViewStyle)renderTableStyle
{
    return UITableViewStyleGrouped;
}

- (void)renderView
{
    FWInfiniteScrollView.height = 64;
    [self.tableView fw_setRefreshingTarget:self action:@selector(onRefreshing)];
    [self.tableView fw_setLoadingTarget:self action:@selector(onLoading)];
    
    UIImageView *pullView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    pullView.image = [TestBundle imageNamed:@"test.gif"];
    self.tableView.fw_pullRefreshView.shouldChangeAlpha = NO;
    [self.tableView.fw_pullRefreshView setCustomView:pullView forState:FWPullRefreshStateAll];
    
    UIImageView *infiniteView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    infiniteView.image = [TestBundle imageNamed:@"LoadingPlaceholder.gif"];
    [self.tableView.fw_infiniteScrollView setCustomView:infiniteView forState:FWInfiniteScrollStateAll];
}

- (void)renderData
{
    [self.tableView fw_beginLoading];
}

#pragma mark - TableView

- (void)renderTableView
{
    [self.tableView registerClass:[TestTableScrollCell class] forCellReuseIdentifier:@"Cell"];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tableData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 渲染可重用Cell
    TestTableScrollCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    TestTableScrollObject *object = [self.tableData objectAtIndex:indexPath.row];
    cell.object = object;
    return cell;
}

- (TestTableScrollObject *)randomObject
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
                                 @"tabbar_home",
                                 @"tabbar_settings",
                                 @"public_picture",
                                 ]];
    });
    
    TestTableScrollObject *object = [TestTableScrollObject new];
    object.title = [[randomArray objectAtIndex:0] fw_randomObject];
    object.text = [[randomArray objectAtIndex:1] fw_randomObject];
    NSString *imageName =[[randomArray objectAtIndex:2] fw_randomObject];
    if (imageName.length > 0) {
        object.image = [TestBundle imageNamed:imageName];
    }
    return object;
}

- (void)onRefreshing
{
    NSLog(@"开始刷新");
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"刷新完成");
        
        [self.tableData removeAllObjects];
        for (int i = 0; i < 1; i++) {
            [self.tableData addObject:[self randomObject]];
        }
        [self.tableView reloadData];
        
        self.tableView.fw_shouldRefreshing = self.tableData.count < 20 ? YES : NO;
        [self.tableView fw_endRefreshing];
    });
}

- (void)onLoading
{
    NSLog(@"开始加载");
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"加载完成");
        
        for (int i = 0; i < 1; i++) {
            [self.tableData addObject:[self randomObject]];
        }
        [self.tableView reloadData];
        
        self.tableView.fw_loadingFinished = self.tableData.count >= 20 ? YES : NO;
        [self.tableView fw_endLoading];
    });
}

@end
