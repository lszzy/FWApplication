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

@interface NSFileManager (FWApplication)

#pragma mark - Path

// 搜索路径，参数为NSSearchPathDirectory
+ (NSString *)fw_pathSearch:(NSSearchPathDirectory)directory NS_REFINED_FOR_SWIFT;

// 沙盒路径
@property (class, nonatomic, copy, readonly) NSString *fw_pathHome NS_REFINED_FOR_SWIFT;

// 文档路径，iTunes会同步备份
@property (class, nonatomic, copy, readonly) NSString *fw_pathDocument NS_REFINED_FOR_SWIFT;

// 缓存路径，系统不会删除，iTunes会删除
@property (class, nonatomic, copy, readonly) NSString *fw_pathCaches NS_REFINED_FOR_SWIFT;

// Library路径
@property (class, nonatomic, copy, readonly) NSString *fw_pathLibrary NS_REFINED_FOR_SWIFT;

// 配置路径，配置文件保存位置
@property (class, nonatomic, copy, readonly) NSString *fw_pathPreference NS_REFINED_FOR_SWIFT;

// 临时路径，App退出后可能会删除
@property (class, nonatomic, copy, readonly) NSString *fw_pathTmp NS_REFINED_FOR_SWIFT;

// bundle路径，不可写
@property (class, nonatomic, copy, readonly) NSString *fw_pathBundle NS_REFINED_FOR_SWIFT;

// 资源路径，不可写
@property (class, nonatomic, copy, readonly) NSString *fw_pathResource NS_REFINED_FOR_SWIFT;

// 绝对路径缩短为波浪线路径
+ (NSString *)fw_abbreviateTildePath:(NSString *)path NS_REFINED_FOR_SWIFT;

// 波浪线路径展开为绝对路径
+ (NSString *)fw_expandTildePath:(NSString *)path NS_REFINED_FOR_SWIFT;

#pragma mark - Size

// 获取目录大小，单位：B
+ (unsigned long long)fw_folderSize:(NSString *)folderPath NS_REFINED_FOR_SWIFT;

// 获取磁盘可用空间，单位：MB
@property (class, nonatomic, assign, readonly) double fw_availableDiskSize NS_REFINED_FOR_SWIFT;

#pragma mark - Addition

// 禁止iCloud备份路径
+ (BOOL)fw_skipBackup:(NSString *)path NS_REFINED_FOR_SWIFT;

@end

NS_ASSUME_NONNULL_END
