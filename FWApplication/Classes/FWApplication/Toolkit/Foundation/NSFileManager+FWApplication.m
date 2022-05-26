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

@implementation FWFileManagerClassWrapper (FWApplication)

#pragma mark - Path

- (NSString *)pathSearch:(NSSearchPathDirectory)directory
{
    NSArray *directories = NSSearchPathForDirectoriesInDomains(directory, NSUserDomainMask, YES);
    return directories.count > 0 ? [directories objectAtIndex:0] : @"";
}

- (NSString *)pathHome
{
    return NSHomeDirectory();
}

- (NSString *)pathDocument
{
    return [self pathSearch:NSDocumentDirectory];
}

- (NSString *)pathCaches
{
    return [self pathSearch:NSCachesDirectory];
}

- (NSString *)pathLibrary
{
    return [self pathSearch:NSLibraryDirectory];
}

- (NSString *)pathPreference
{
    return [[self pathLibrary] stringByAppendingPathComponent:@"Preference"];
}

- (NSString *)pathTmp
{
    return NSTemporaryDirectory();
}

- (NSString *)pathBundle
{
    return [[NSBundle mainBundle] bundlePath];
}

- (NSString *)pathResource
{
    return [[NSBundle mainBundle] resourcePath] ?: @"";
}

- (NSString *)abbreviateTildePath:(NSString *)path
{
    return [path stringByAbbreviatingWithTildeInPath];
}

- (NSString *)expandTildePath:(NSString *)path
{
    return [path stringByExpandingTildeInPath];
}

#pragma mark - Size

- (unsigned long long)folderSize:(NSString *)folderPath
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

- (double)availableDiskSize
{
    NSDictionary *attributes = [NSFileManager.defaultManager attributesOfFileSystemForPath:[self pathDocument] error:nil];
    return [attributes[NSFileSystemFreeSize] unsignedLongLongValue] / (double)0x100000;
}

#pragma mark - Addition

- (BOOL)skipBackup:(NSString *)path
{
    return [[NSURL.alloc initFileURLWithPath:path] setResourceValue:@(YES) forKey:NSURLIsExcludedFromBackupKey error:nil];
}

@end
