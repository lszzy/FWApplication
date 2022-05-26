/**
 @header     NSFileManager+FWApplication.h
 @indexgroup FWApplication
      NSFileManager+FWApplication
 @author     wuyong
 @copyright  Copyright © 2018年 wuyong.site. All rights reserved.
 @updated    2018/9/18
 */

@import FWFramework;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Macro

// 搜索路径，参数为NSSearchPathDirectory
#define FWPathSearch( directory ) \
    [NSSearchPathForDirectoriesInDomains(directory, NSUserDomainMask, YES) objectAtIndex:0]

// 沙盒路径，宏常量，非宏方法，下同
#define FWPathHome \
    NSHomeDirectory()

// 文档路径，iTunes会同步备份
#define FWPathDocument \
    FWPathSearch( NSDocumentDirectory )

// 缓存路径，系统不会删除，iTunes会删除
#define FWPathCaches \
    FWPathSearch( NSCachesDirectory )

// Library路径
#define FWPathLibrary \
    FWPathSearch( NSLibraryDirectory )

// 配置路径，配置文件保存位置
#define FWPathPreference \
    [FWPathLibrary stringByAppendingPathComponent:@"Preference"]

// 临时路径，App退出后可能会删除
#define FWPathTmp \
    NSTemporaryDirectory()

// bundle路径，不可写
#define FWPathBundle \
    [[NSBundle mainBundle] bundlePath]

// 资源路径，不可写
#define FWPathResource \
    [[NSBundle mainBundle] resourcePath]

@interface FWFileManagerClassWrapper (FWApplication)

#pragma mark - Path

// 搜索路径，参数为NSSearchPathDirectory
- (NSString *)pathSearch:(NSSearchPathDirectory)directory;

// 沙盒路径
@property (nonatomic, copy, readonly) NSString *pathHome;

// 文档路径，iTunes会同步备份
@property (nonatomic, copy, readonly) NSString *pathDocument;

// 缓存路径，系统不会删除，iTunes会删除
@property (nonatomic, copy, readonly) NSString *pathCaches;

// Library路径
@property (nonatomic, copy, readonly) NSString *pathLibrary;

// 配置路径，配置文件保存位置
@property (nonatomic, copy, readonly) NSString *pathPreference;

// 临时路径，App退出后可能会删除
@property (nonatomic, copy, readonly) NSString *pathTmp;

// bundle路径，不可写
@property (nonatomic, copy, readonly) NSString *pathBundle;

// 资源路径，不可写
@property (nonatomic, copy, readonly) NSString *pathResource;

// 绝对路径缩短为波浪线路径
- (NSString *)abbreviateTildePath:(NSString *)path;

// 波浪线路径展开为绝对路径
- (NSString *)expandTildePath:(NSString *)path;

#pragma mark - Size

// 获取目录大小，单位：B
- (unsigned long long)folderSize:(NSString *)folderPath;

// 获取磁盘可用空间，单位：MB
@property (nonatomic, assign, readonly) double availableDiskSize;

#pragma mark - Addition

// 禁止iCloud备份路径
- (BOOL)skipBackup:(NSString *)path;

@end

NS_ASSUME_NONNULL_END
