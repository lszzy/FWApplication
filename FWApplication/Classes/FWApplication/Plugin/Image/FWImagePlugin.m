/**
 @header     FWImagePlugin.m
 @indexgroup FWApplication
      FWImagePlugin
 @author     wuyong
 @copyright  Copyright © 2020 wuyong.site. All rights reserved.
 @updated    2020/11/30
 */

#import "FWImagePlugin.h"
#import <objc/runtime.h>

FWImageCoderOptions const FWImageCoderOptionScaleFactor = @"imageScaleFactor";

#pragma mark - UIImage+FWImagePlugin

UIImage * FWImageNamed(NSString *name) {
    return [UIImage.fw imageNamed:name];
}

static NSArray *FWInnerBundlePreferredScales() {
    static NSArray *scales;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CGFloat screenScale = [UIScreen mainScreen].scale;
        if (screenScale <= 1) {
            scales = @[@1, @2, @3];
        } else if (screenScale <= 2) {
            scales = @[@2, @3, @1];
        } else {
            scales = @[@3, @2, @1];
        }
    });
    return scales;
}

static NSString *FWInnerAppendingNameScale(NSString *string, CGFloat scale) {
    if (!string) return nil;
    if (fabs(scale - 1) <= __FLT_EPSILON__ || string.length == 0 || [string hasSuffix:@"/"]) return string.copy;
    return [string stringByAppendingFormat:@"@%@x", @(scale)];
}

static CGFloat FWInnerStringPathScale(NSString *string) {
    if (string.length == 0 || [string hasSuffix:@"/"]) return 1;
    NSString *name = string.stringByDeletingPathExtension;
    __block CGFloat scale = 1;
    
    NSRegularExpression *pattern = [NSRegularExpression regularExpressionWithPattern:@"@[0-9]+\\.?[0-9]*x$" options:NSRegularExpressionAnchorsMatchLines error:nil];
    [pattern enumerateMatchesInString:name options:kNilOptions range:NSMakeRange(0, name.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        if (result.range.location >= 3) {
            scale = [string substringWithRange:NSMakeRange(result.range.location + 1, result.range.length - 2)].doubleValue;
        }
    }];
    return scale;
}

@implementation FWImageClassWrapper (FWImagePlugin)

- (UIImage *)imageNamed:(NSString *)name
{
    return [self imageNamed:name bundle:nil];
}

- (UIImage *)imageNamed:(NSString *)name bundle:(NSBundle *)bundle
{
    return [self imageNamed:name bundle:bundle options:nil];
}

- (UIImage *)imageNamed:(NSString *)name bundle:(NSBundle *)aBundle options:(NSDictionary<FWImageCoderOptions,id> *)options
{
    if (name.length < 1) return nil;
    if ([name hasSuffix:@"/"]) return nil;
    
    if ([name isAbsolutePath]) {
        NSData *data = [NSData dataWithContentsOfFile:name];
        CGFloat scale = FWInnerStringPathScale(name);
        return [self imageWithData:data scale:scale options:options];
    }
    
    NSString *path = nil;
    CGFloat scale = 1;
    NSBundle *bundle = aBundle ?: [NSBundle mainBundle];
    NSString *res = name.stringByDeletingPathExtension;
    NSString *ext = name.pathExtension;
    NSArray *exts = ext.length > 0 ? @[ext] : @[@"", @"png", @"jpeg", @"jpg", @"gif", @"webp", @"apng", @"svg"];
    NSArray *scales = FWInnerBundlePreferredScales();
    for (int s = 0; s < scales.count; s++) {
        scale = ((NSNumber *)scales[s]).floatValue;
        NSString *scaledName = FWInnerAppendingNameScale(res, scale);
        for (NSString *e in exts) {
            path = [bundle pathForResource:scaledName ofType:e];
            if (path) break;
        }
        if (path) break;
    }
    
    NSData *data = path.length > 0 ? [NSData dataWithContentsOfFile:path] : nil;
    if (data.length < 1) {
        return [UIImage imageNamed:name inBundle:bundle compatibleWithTraitCollection:nil];
    }
    return [self imageWithData:data scale:scale options:options];
}

- (UIImage *)imageWithContentsOfFile:(NSString *)path
{
    NSData *data = [NSData dataWithContentsOfFile:path];
    CGFloat scale = FWInnerStringPathScale(path);
    return [self imageWithData:data scale:scale];
}

- (UIImage *)imageWithData:(NSData *)data
{
    return [self imageWithData:data scale:1];
}

- (UIImage *)imageWithData:(NSData *)data scale:(CGFloat)scale
{
    return [self imageWithData:data scale:scale options:nil];
}

- (UIImage *)imageWithData:(NSData *)data scale:(CGFloat)scale options:(NSDictionary<FWImageCoderOptions,id> *)options
{
    if (data.length < 1) return nil;
    
    id<FWImagePlugin> imagePlugin = [FWPluginManager loadPlugin:@protocol(FWImagePlugin)];
    if (imagePlugin && [imagePlugin respondsToSelector:@selector(imageDecode:scale:options:)]) {
        return [imagePlugin imageDecode:data scale:scale options:options];
    }
    
    NSNumber *scaleFactor = options[FWImageCoderOptionScaleFactor];
    if (scaleFactor != nil) scale = [scaleFactor doubleValue];
    return [UIImage imageWithData:data scale:MAX(scale, 1)];
}

- (NSData *)dataWithImage:(UIImage *)image
{
    return [self dataWithImage:image options:nil];
}

- (NSData *)dataWithImage:(UIImage *)image options:(NSDictionary<FWImageCoderOptions,id> *)options
{
    if (!image) return nil;
    
    id<FWImagePlugin> imagePlugin = [FWPluginManager loadPlugin:@protocol(FWImagePlugin)];
    if (imagePlugin && [imagePlugin respondsToSelector:@selector(imageEncode:options:)]) {
        return [imagePlugin imageEncode:image options:options];
    }
    
    if (image.fw.hasAlpha) {
        return UIImagePNGRepresentation(image);
    } else {
        return UIImageJPEGRepresentation(image, 1);
    }
}

- (id)downloadImage:(id)url
           completion:(void (^)(UIImage * _Nullable, NSError * _Nullable))completion
             progress:(void (^)(double))progress
{
    return [self downloadImage:url options:0 context:nil completion:completion progress:progress];
}

- (id)downloadImage:(id)url
              options:(FWWebImageOptions)options
              context:(NSDictionary<FWImageCoderOptions,id> *)context
           completion:(void (^)(UIImage * _Nullable, NSError * _Nullable))completion
             progress:(void (^)(double))progress
{
    id<FWImagePlugin> imagePlugin = [FWPluginManager loadPlugin:@protocol(FWImagePlugin)];
    if (imagePlugin && [imagePlugin respondsToSelector:@selector(downloadImage:options:context:completion:progress:)]) {
        NSURL *imageURL = nil;
        if ([url isKindOfClass:[NSString class]] && [url length] > 0) {
            imageURL = [NSURL URLWithString:url];
            if (!imageURL) {
                imageURL = [NSURL URLWithString:[url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
            }
        } else if ([url isKindOfClass:[NSURL class]]) {
            imageURL = url;
        } else if ([url isKindOfClass:[NSURLRequest class]]) {
            imageURL = [url URL];
        }
        
        return [imagePlugin downloadImage:imageURL options:options context:context completion:completion progress:progress];
    }
    return nil;
}

- (void)cancelImageDownload:(id)receipt
{
    id<FWImagePlugin> imagePlugin = [FWPluginManager loadPlugin:@protocol(FWImagePlugin)];
    if (imagePlugin && [imagePlugin respondsToSelector:@selector(cancelImageDownload:)]) {
        [imagePlugin cancelImageDownload:receipt];
    }
}

@end

#pragma mark - FWImageViewWrapper+FWImagePlugin

@implementation FWImageViewWrapper (FWImagePlugin)

- (id<FWImagePlugin>)imagePlugin
{
    id<FWImagePlugin> imagePlugin = objc_getAssociatedObject(self.base, @selector(imagePlugin));
    if (!imagePlugin) imagePlugin = [FWPluginManager loadPlugin:@protocol(FWImagePlugin)];
    return imagePlugin;
}

- (void)setImagePlugin:(id<FWImagePlugin>)imagePlugin
{
    objc_setAssociatedObject(self.base, @selector(imagePlugin), imagePlugin, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSURL *)imageURL
{
    id<FWImagePlugin> imagePlugin = self.imagePlugin;
    if (imagePlugin && [imagePlugin respondsToSelector:@selector(imageURL:)]) {
        return [imagePlugin imageURL:self.base];
    }
    return nil;
}

- (void)setImageWithURL:(id)url
{
    [self setImageWithURL:url placeholderImage:nil];
}

- (void)setImageWithURL:(id)url
         placeholderImage:(UIImage *)placeholderImage
{
    [self setImageWithURL:url placeholderImage:placeholderImage completion:nil];
}

- (void)setImageWithURL:(id)url
         placeholderImage:(UIImage *)placeholderImage
               completion:(void (^)(UIImage * _Nullable, NSError * _Nullable))completion
{
    [self setImageWithURL:url placeholderImage:placeholderImage options:0 context:nil completion:completion progress:nil];
}

- (void)setImageWithURL:(id)url
         placeholderImage:(UIImage *)placeholderImage
                  options:(FWWebImageOptions)options
                  context:(NSDictionary<FWImageCoderOptions,id> *)context
               completion:(void (^)(UIImage * _Nullable, NSError * _Nullable))completion
                 progress:(void (^)(double))progress
{
    id<FWImagePlugin> imagePlugin = self.imagePlugin;
    if (imagePlugin && [imagePlugin respondsToSelector:@selector(imageView:setImageURL:placeholder:options:context:completion:progress:)]) {
        NSURL *imageURL = nil;
        if ([url isKindOfClass:[NSString class]] && [url length] > 0) {
            imageURL = [NSURL URLWithString:url];
            if (!imageURL) {
                imageURL = [NSURL URLWithString:[url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
            }
        } else if ([url isKindOfClass:[NSURL class]]) {
            imageURL = url;
        } else if ([url isKindOfClass:[NSURLRequest class]]) {
            imageURL = [url URL];
        }
        
        [imagePlugin imageView:self.base setImageURL:imageURL placeholder:placeholderImage options:options context:context completion:completion progress:progress];
    }
}

- (void)cancelImageRequest
{
    id<FWImagePlugin> imagePlugin = self.imagePlugin;
    if (imagePlugin && [imagePlugin respondsToSelector:@selector(cancelImageRequest:)]) {
        [imagePlugin cancelImageRequest:self.base];
    }
}

@end

@implementation FWImageViewClassWrapper (FWImagePlugin)

- (Class)imageViewAnimatedClass
{
    id<FWImagePlugin> imagePlugin = [FWPluginManager loadPlugin:@protocol(FWImagePlugin)];
    if (imagePlugin && [imagePlugin respondsToSelector:@selector(imageViewAnimatedClass)]) {
        return [imagePlugin imageViewAnimatedClass];
    }
    
    return objc_getAssociatedObject([UIImageView class], @selector(imageViewAnimatedClass)) ?: [UIImageView class];
}

- (void)setImageViewAnimatedClass:(Class)animatedClass
{
    objc_setAssociatedObject([UIImageView class], @selector(imageViewAnimatedClass), animatedClass, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
