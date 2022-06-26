/**
 @header     NSFileManager+FWApplication.m
 @indexgroup FWApplication
      NSFileManager+FWApplication
 @author     wuyong
 @copyright  Copyright © 2018年 wuyong.site. All rights reserved.
 @updated    2018/9/18
 */

#import "NSFileManager+FWApplication.h"
#import <AVFoundation/AVFoundation.h>

@implementation NSFileManager (FWApplication)

#pragma mark - Path

+ (NSString *)fw_pathSearch:(NSSearchPathDirectory)directory
{
    NSArray *directories = NSSearchPathForDirectoriesInDomains(directory, NSUserDomainMask, YES);
    return directories.count > 0 ? [directories objectAtIndex:0] : @"";
}

+ (NSString *)fw_pathHome
{
    return NSHomeDirectory();
}

+ (NSString *)fw_pathDocument
{
    return [self fw_pathSearch:NSDocumentDirectory];
}

+ (NSString *)fw_pathCaches
{
    return [self fw_pathSearch:NSCachesDirectory];
}

+ (NSString *)fw_pathLibrary
{
    return [self fw_pathSearch:NSLibraryDirectory];
}

+ (NSString *)fw_pathPreference
{
    return [[self fw_pathLibrary] stringByAppendingPathComponent:@"Preference"];
}

+ (NSString *)fw_pathTmp
{
    return NSTemporaryDirectory();
}

+ (NSString *)fw_pathBundle
{
    return [[NSBundle mainBundle] bundlePath];
}

+ (NSString *)fw_pathResource
{
    return [[NSBundle mainBundle] resourcePath] ?: @"";
}

+ (NSString *)fw_abbreviateTildePath:(NSString *)path
{
    return [path stringByAbbreviatingWithTildeInPath];
}

+ (NSString *)fw_expandTildePath:(NSString *)path
{
    return [path stringByExpandingTildeInPath];
}

#pragma mark - Size

+ (unsigned long long)fw_folderSize:(NSString *)folderPath
{
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:folderPath error:nil];
    NSEnumerator *contentsEnumurator = [contents objectEnumerator];
    
    NSString *file;
    unsigned long long folderSize = 0;
    
    while (file = [contentsEnumurator nextObject]) {
        NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[folderPath stringByAppendingPathComponent:file] error:nil];
        folderSize += [[fileAttributes objectForKey:NSFileSize] intValue];
    }
    return folderSize;
}

+ (double)fw_availableDiskSize
{
    NSDictionary *attributes = [NSFileManager.defaultManager attributesOfFileSystemForPath:[self fw_pathDocument] error:nil];
    return [attributes[NSFileSystemFreeSize] unsignedLongLongValue] / (double)0x100000;
}

#pragma mark - Addition

+ (BOOL)fw_skipBackup:(NSString *)path
{
    return [[NSURL.alloc initFileURLWithPath:path] setResourceValue:@(YES) forKey:NSURLIsExcludedFromBackupKey error:nil];
}

@end
