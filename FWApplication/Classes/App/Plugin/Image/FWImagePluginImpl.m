/*!
 @header     FWImagePluginImpl.m
 @indexgroup FWApplication
 @brief      FWImagePluginImpl
 @author     wuyong
 @copyright  Copyright © 2020 wuyong.site. All rights reserved.
 @updated    2020/11/30
 */

#import "FWImagePluginImpl.h"
#import "FWPlugin.h"

#if FWCOMPONENT_SDWEBIMAGE_ENABLED
@import SDWebImage;
#endif

@implementation FWSDWebImagePlugin

+ (FWSDWebImagePlugin *)sharedInstance
{
    static FWSDWebImagePlugin *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[FWSDWebImagePlugin alloc] init];
    });
    return instance;
}

#if FWCOMPONENT_SDWEBIMAGE_ENABLED

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [FWPluginManager registerPlugin:@protocol(FWImagePlugin) withObject:[FWSDWebImagePlugin class]];
    });
}

- (Class)fwImageViewAnimatedClass
{
    return [SDAnimatedImageView class];
}

- (UIImage *)fwImageDecode:(NSData *)data scale:(CGFloat)scale options:(NSDictionary<FWImageCoderOptions,id> *)options
{
    SDImageCoderMutableOptions *coderOptions = [[NSMutableDictionary alloc] init];
    coderOptions[SDImageCoderDecodeScaleFactor] = @(MAX(scale, 1));
    coderOptions[SDImageCoderDecodeFirstFrameOnly] = @(NO);
    if (options) [coderOptions addEntriesFromDictionary:options];
    return [[SDImageCodersManager sharedManager] decodedImageWithData:data options:[coderOptions copy]];
}

- (NSData *)fwImageEncode:(UIImage *)image options:(NSDictionary<FWImageCoderOptions,id> *)options
{
    SDImageCoderMutableOptions *coderOptions = [[NSMutableDictionary alloc] init];
    coderOptions[SDImageCoderEncodeCompressionQuality] = @(1);
    coderOptions[SDImageCoderEncodeFirstFrameOnly] = @(NO);
    if (options) [coderOptions addEntriesFromDictionary:options];
    return [[SDImageCodersManager sharedManager] encodedDataWithImage:image format:SDImageFormatUndefined options:[coderOptions copy]];
}

- (NSURL *)fwImageURL:(UIImageView *)imageView
{
    return imageView.sd_imageURL;
}

- (void)fwImageView:(UIImageView *)imageView
        setImageURL:(NSURL *)imageURL
        placeholder:(UIImage *)placeholder
            options:(FWWebImageOptions)options
         completion:(void (^)(UIImage * _Nullable, NSError * _Nullable))completion
           progress:(void (^)(double))progress
{
    if (self.fadeAnimated && !imageView.sd_imageTransition) {
        imageView.sd_imageTransition = SDWebImageTransition.fadeTransition;
    }
    if (self.customBlock) {
        self.customBlock(imageView);
    }
    
    [imageView sd_setImageWithURL:imageURL
                 placeholderImage:placeholder
                          options:options | SDWebImageRetryFailed
                          context:nil
                         progress:progress ? ^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
                            if (expectedSize > 0) {
                                if ([NSThread isMainThread]) {
                                    progress(receivedSize / (double)expectedSize);
                                } else {
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        progress(receivedSize / (double)expectedSize);
                                    });
                                }
                            }
                        } : nil
                        completed:completion ? ^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                            completion(image, error);
                        } : nil];
}

- (void)fwCancelImageRequest:(UIImageView *)imageView
{
    [imageView sd_cancelCurrentImageLoad];
}

- (id)fwDownloadImage:(NSURL *)imageURL
              options:(FWWebImageOptions)options
           completion:(void (^)(UIImage * _Nullable, NSError * _Nullable))completion
             progress:(void (^)(double))progress
{
    return [[SDWebImageManager sharedManager]
            loadImageWithURL:imageURL
            options:options | SDWebImageRetryFailed
            progress:(progress ? ^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
                if (expectedSize > 0) {
                    if ([NSThread isMainThread]) {
                        progress(receivedSize / (double)expectedSize);
                    } else {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            progress(receivedSize / (double)expectedSize);
                        });
                    }
                }
            } : nil)
            completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
                if (completion) {
                    completion(image, error);
                }
            }];
}

- (void)fwCancelImageDownload:(id)receipt
{
    if (receipt && [receipt isKindOfClass:[SDWebImageCombinedOperation class]]) {
        [(SDWebImageCombinedOperation *)receipt cancel];
    }
}

#endif

@end
