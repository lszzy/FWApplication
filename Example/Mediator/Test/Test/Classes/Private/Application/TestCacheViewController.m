//
//  TestCacheViewController.m
//  Example
//
//  Created by wuyong on 2018/12/26.
//  Copyright © 2018 wuyong.site. All rights reserved.
//

#import "TestCacheViewController.h"

#define TestCacheKey @"TestCacheKey"
#define TestExpireKey @"TestCacheKey.__EXPIRE__"

@interface TestCacheViewController ()

@property (nonatomic, strong) id<FWCacheProtocol> cache;

@property (nonatomic, strong) UILabel *cacheLabel;

@end

@implementation TestCacheViewController

- (void)renderView
{
    UILabel *cacheLabel = [UILabel new];
    self.cacheLabel = cacheLabel;
    cacheLabel.numberOfLines = 0;
    cacheLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:cacheLabel]; {
        [cacheLabel.fw pinEdgesToSuperviewWithInsets:UIEdgeInsetsMake(10, 10, 10, 10) excludingEdge:NSLayoutAttributeBottom];
    }
    
    UIButton *refreshButton = [Theme largeButton];
    [refreshButton setTitle:@"读取缓存" forState:UIControlStateNormal];
    FWWeakifySelf();
    [refreshButton.fw addTouchBlock:^(id sender) {
        FWStrongifySelf();
        
        [self refreshCache];
    }];
    [self.view addSubview:refreshButton]; {
        [refreshButton.fw pinEdge:NSLayoutAttributeTop toEdge:NSLayoutAttributeBottom ofView:cacheLabel withOffset:10];
        [refreshButton.fw  alignAxisToSuperview:NSLayoutAttributeCenterX];
    }
    
    UIButton *cacheButton = [Theme largeButton];
    [cacheButton setTitle:@"写入缓存" forState:UIControlStateNormal];
    [cacheButton.fw addTouchBlock:^(id sender) {
        FWStrongifySelf();
        
        [self.cache setObject:[NSString fwUUIDString] forKey:TestCacheKey];
        [self refreshCache];
    }];
    [self.view addSubview:cacheButton]; {
        [cacheButton.fw pinEdge:NSLayoutAttributeTop toEdge:NSLayoutAttributeBottom ofView:refreshButton withOffset:10];
        [cacheButton.fw  alignAxisToSuperview:NSLayoutAttributeCenterX];
    }
    
    UIButton *expireButton = [Theme largeButton];
    [expireButton setTitle:@"写入缓存(10s)" forState:UIControlStateNormal];
    [expireButton.fw addTouchBlock:^(id sender) {
        FWStrongifySelf();
        
        [self.cache setObject:[NSString fwUUIDString] forKey:TestCacheKey withExpire:10];
        [self refreshCache];
    }];
    [self.view addSubview:expireButton]; {
        [expireButton.fw pinEdge:NSLayoutAttributeTop toEdge:NSLayoutAttributeBottom ofView:cacheButton withOffset:10];
        [expireButton.fw  alignAxisToSuperview:NSLayoutAttributeCenterX];
    }
    
    UIButton *deleteButton = [Theme largeButton];
    [deleteButton setTitle:@"删除缓存" forState:UIControlStateNormal];
    [deleteButton.fw addTouchBlock:^(id sender) {
        FWStrongifySelf();
        
        [self.cache removeObjectForKey:TestCacheKey];
        [self refreshCache];
    }];
    [self.view addSubview:deleteButton]; {
        [deleteButton.fw pinEdge:NSLayoutAttributeTop toEdge:NSLayoutAttributeBottom ofView:expireButton withOffset:10];
        [deleteButton.fw  alignAxisToSuperview:NSLayoutAttributeCenterX];
    }
    
    UIButton *clearButton = [Theme largeButton];
    [clearButton setTitle:@"清空缓存" forState:UIControlStateNormal];
    [clearButton.fw addTouchBlock:^(id sender) {
        FWStrongifySelf();
        
        [self.cache removeAllObjects];
        [self refreshCache];
    }];
    [self.view addSubview:clearButton]; {
        [clearButton.fw pinEdge:NSLayoutAttributeTop toEdge:NSLayoutAttributeBottom ofView:deleteButton withOffset:10];
        [clearButton.fw  alignAxisToSuperview:NSLayoutAttributeCenterX];
    }
}

- (void)renderData
{
    self.cache = [FWCacheMemory sharedInstance];
    [self refreshCache];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    FWWeakifySelf();
    [self fwSetRightBarItem:@"切换" block:^(id sender) {
        FWStrongifySelf();
        
        [self fwShowSheetWithTitle:@"选择缓存类型" message:nil cancel:@"取消" actions:@[@"FWCacheMemory", @"FWCacheUserDefaults", @"FWCacheKeychain", @"FWCacheFile", @"FWCacheSqlite"] actionBlock:^(NSInteger index) {
            FWStrongifySelf();
            
            if (index == 0) {
                self.cache = [FWCacheManager managerWithType:FWCacheTypeMemory];
            } else if (index == 1) {
                self.cache = [FWCacheManager managerWithType:FWCacheTypeUserDefaults];
            } else if (index == 2) {
                self.cache = [FWCacheManager managerWithType:FWCacheTypeKeychain];
            } else if (index == 3) {
                self.cache = [FWCacheManager managerWithType:FWCacheTypeFile];
            } else if (index == 4) {
                self.cache = [FWCacheManager managerWithType:FWCacheTypeSqlite];
            }
            
            [self refreshCache];
        }];
    }];
}

- (void)refreshCache
{
    NSMutableString *statusStr = [[NSMutableString alloc] init];
    [statusStr appendString:NSStringFromClass([self.cache class])];
    [statusStr appendString:@"\n"];
    NSString *cacheStr = [self.cache objectForKey:TestCacheKey];
    if ([cacheStr.fw isNotEmpty]) {
        [statusStr appendString:cacheStr];
    } else {
        [statusStr appendString:@"缓存不存在"];
    }
    [statusStr appendString:@"\n"];
    NSNumber *expireNum = [self.cache objectForKey:TestExpireKey];
    if ([expireNum.fw isNotEmpty]) {
        [statusStr appendString:[NSString stringWithFormat:@"%.1fs有效", [expireNum doubleValue] - [[NSDate date] timeIntervalSince1970]]];
    } else {
        [statusStr appendString:cacheStr.fw.isNotEmpty ? @"永久有效" : @"缓存无效"];
    }
    self.cacheLabel.text = statusStr;
}

@end
