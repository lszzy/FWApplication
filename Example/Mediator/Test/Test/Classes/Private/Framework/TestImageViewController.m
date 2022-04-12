//
//  TestImageViewController.m
//  Example
//
//  Created by wuyong on 2020/2/24.
//  Copyright © 2020 wuyong.site. All rights reserved.
//

#import "TestImageViewController.h"
#import <dlfcn.h>
#import <objc/runtime.h>
@import SDWebImage;

API_AVAILABLE(ios(13.0))
@interface SDImageSVGCoder : NSObject <SDImageCoder>

@property (nonatomic, class, readonly) SDImageSVGCoder *sharedCoder;

@end

#define kSVGTagEnd @"</svg>"

typedef struct CF_BRIDGED_TYPE(id) CGSVGDocument *CGSVGDocumentRef;
static CGSVGDocumentRef (*SDCGSVGDocumentRetain)(CGSVGDocumentRef);
static void (*SDCGSVGDocumentRelease)(CGSVGDocumentRef);
static CGSVGDocumentRef (*SDCGSVGDocumentCreateFromData)(CFDataRef data, CFDictionaryRef options);
static void (*SDCGSVGDocumentWriteToData)(CGSVGDocumentRef document, CFDataRef data, CFDictionaryRef options);
static void (*SDCGContextDrawSVGDocument)(CGContextRef context, CGSVGDocumentRef document);
static CGSize (*SDCGSVGDocumentGetCanvasSize)(CGSVGDocumentRef document);

static SEL SDImageWithCGSVGDocumentSEL = NULL;
static SEL SDCGSVGDocumentSEL = NULL;

static inline NSString *SDBase64DecodedString(NSString *base64String) {
    NSData *data = [[NSData alloc] initWithBase64EncodedString:base64String options:NSDataBase64DecodingIgnoreUnknownCharacters];
    if (!data) {
        return nil;
    }
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

@implementation SDImageSVGCoder

+ (SDImageSVGCoder *)sharedCoder {
    static dispatch_once_t onceToken;
    static SDImageSVGCoder *coder;
    dispatch_once(&onceToken, ^{
        coder = [[SDImageSVGCoder alloc] init];
    });
    return coder;
}

+ (void)initialize {
    SDCGSVGDocumentRetain = dlsym(RTLD_DEFAULT, SDBase64DecodedString(@"Q0dTVkdEb2N1bWVudFJldGFpbg==").UTF8String);
    SDCGSVGDocumentRelease = dlsym(RTLD_DEFAULT, SDBase64DecodedString(@"Q0dTVkdEb2N1bWVudFJlbGVhc2U=").UTF8String);
    SDCGSVGDocumentCreateFromData = dlsym(RTLD_DEFAULT, SDBase64DecodedString(@"Q0dTVkdEb2N1bWVudENyZWF0ZUZyb21EYXRh").UTF8String);
    SDCGSVGDocumentWriteToData = dlsym(RTLD_DEFAULT, SDBase64DecodedString(@"Q0dTVkdEb2N1bWVudFdyaXRlVG9EYXRh").UTF8String);
    SDCGContextDrawSVGDocument = dlsym(RTLD_DEFAULT, SDBase64DecodedString(@"Q0dDb250ZXh0RHJhd1NWR0RvY3VtZW50").UTF8String);
    SDCGSVGDocumentGetCanvasSize = dlsym(RTLD_DEFAULT, SDBase64DecodedString(@"Q0dTVkdEb2N1bWVudEdldENhbnZhc1NpemU=").UTF8String);
    SDImageWithCGSVGDocumentSEL = NSSelectorFromString(SDBase64DecodedString(@"X2ltYWdlV2l0aENHU1ZHRG9jdW1lbnQ6"));
    SDCGSVGDocumentSEL = NSSelectorFromString(SDBase64DecodedString(@"X0NHU1ZHRG9jdW1lbnQ="));
}

#pragma mark - Decode

- (BOOL)canDecodeFromData:(NSData *)data {
    return [self.class isSVGFormatForData:data];
}

- (UIImage *)decodedImageWithData:(NSData *)data options:(SDImageCoderOptions *)options {
    if (!data) {
        return nil;
    }
    
    BOOL prefersBitmap = NO;
    CGSize imageSize = CGSizeZero;
    BOOL preserveAspectRatio = YES;

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    // Parse args
    SDWebImageContext *context = options[SDImageCoderWebImageContext];
    if (context[@"svgImageSize"]) {
        prefersBitmap = YES;
        NSValue *sizeValue = context[@"svgImageSize"];
        imageSize = sizeValue.CGSizeValue;
    } else if (options[SDImageCoderDecodeThumbnailPixelSize]) {
        prefersBitmap = YES;
        NSValue *sizeValue = options[SDImageCoderDecodeThumbnailPixelSize];
        imageSize = sizeValue.CGSizeValue;
    } else if (context[@"svgPrefersBitmap"]) {
        prefersBitmap = [context[@"svgPrefersBitmap"] boolValue];
    }
    if (context[@"svgImagePreserveAspectRatio"]) {
        preserveAspectRatio = [context[@"svgImagePreserveAspectRatio"] boolValue];
    } else if (options[SDImageCoderDecodePreserveAspectRatio]) {
        preserveAspectRatio = [context[SDImageCoderDecodePreserveAspectRatio] boolValue];
    }
#pragma clang diagnostic pop
    
    UIImage *image;
    if (!prefersBitmap && [self.class supportsVectorSVGImage]) {
        image = [self createVectorSVGWithData:data];
    } else {
        image = [self createBitmapSVGWithData:data targetSize:imageSize preserveAspectRatio:preserveAspectRatio];
    }
    
    image.sd_imageFormat = SDImageFormatSVG;
    
    return image;
}

#pragma mark - Encode

- (BOOL)canEncodeToFormat:(SDImageFormat)format {
    return format == SDImageFormatSVG;
}

- (NSData *)encodedDataWithImage:(UIImage *)image format:(SDImageFormat)format options:(SDImageCoderOptions *)options {
    if (!image) {
        return nil;
    }
    if (![self.class supportsVectorSVGImage]) {
        return nil;
    }
    NSMutableData *data = [NSMutableData data];
    CGSVGDocumentRef document = NULL;
    document = ((CGSVGDocumentRef (*)(id,SEL))[image methodForSelector:SDCGSVGDocumentSEL])(image, SDCGSVGDocumentSEL);
    if (!document) {
        return nil;
    }
    
    SDCGSVGDocumentWriteToData(document, (__bridge CFDataRef)data, NULL);
    
    return [data copy];
}

#pragma mark - Vector SVG representation
- (UIImage *)createVectorSVGWithData:(nonnull NSData *)data {
    NSParameterAssert(data);
    UIImage *image;
    
    CGSVGDocumentRef document = SDCGSVGDocumentCreateFromData((__bridge CFDataRef)data, NULL);
    if (!document) {
        return nil;
    }
    image = ((UIImage *(*)(id,SEL,CGSVGDocumentRef))[UIImage.class methodForSelector:SDImageWithCGSVGDocumentSEL])(UIImage.class, SDImageWithCGSVGDocumentSEL, document);
    SDCGSVGDocumentRelease(document);
    return image;
}

#pragma mark - Bitmap SVG representation
- (UIImage *)createBitmapSVGWithData:(nonnull NSData *)data targetSize:(CGSize)targetSize preserveAspectRatio:(BOOL)preserveAspectRatio {
    NSParameterAssert(data);
    UIImage *image;
    
    CGSVGDocumentRef document = SDCGSVGDocumentCreateFromData((__bridge CFDataRef)data, NULL);
    if (!document) {
        return nil;
    }
    
    CGSize size = SDCGSVGDocumentGetCanvasSize(document);
    // Invalid size
    if (size.width == 0 || size.height == 0) {
        return nil;
    }
    
    CGFloat xScale;
    CGFloat yScale;
    // Calculation for actual target size, see rules in documentation
    if (targetSize.width <= 0 && targetSize.height <= 0) {
        // Both width and height is 0, use original size
        targetSize.width = size.width;
        targetSize.height = size.height;
        xScale = 1;
        yScale = 1;
    } else {
        CGFloat xRatio = targetSize.width / size.width;
        CGFloat yRatio = targetSize.height / size.height;
        if (preserveAspectRatio) {
            // If we specify only one length of the size (width or height) we want to keep the ratio for that length
            if (targetSize.width <= 0) {
                yScale = yRatio;
                xScale = yRatio;
                targetSize.width = size.width * xScale;
            } else if (targetSize.height <= 0) {
                xScale = xRatio;
                yScale = xRatio;
                targetSize.height = size.height * yScale;
            } else {
                xScale = MIN(xRatio, yRatio);
                yScale = MIN(xRatio, yRatio);
                targetSize.width = size.width * xScale;
                targetSize.height = size.height * yScale;
            }
        } else {
            // If we specify only one length of the size but don't keep the ratio, use original size
            if (targetSize.width <= 0) {
                targetSize.width = size.width;
                yScale = yRatio;
                xScale = 1;
            } else if (targetSize.height <= 0) {
                xScale = xRatio;
                yScale = 1;
                targetSize.height = size.height;
            } else {
                xScale = xRatio;
                yScale = yRatio;
            }
        }
    }
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    CGRect targetRect = CGRectMake(0, 0, targetSize.width, targetSize.height);
    
    CGAffineTransform scaleTransform = CGAffineTransformMakeScale(xScale, yScale);
    CGAffineTransform transform = CGAffineTransformIdentity;
    if (preserveAspectRatio) {
        // Calculate the offset
        transform = CGAffineTransformMakeTranslation((targetRect.size.width / xScale - rect.size.width) / 2, (targetRect.size.height / yScale - rect.size.height) / 2);
    }
    
    SDGraphicsBeginImageContextWithOptions(targetRect.size, NO, 0);
    CGContextRef context = SDGraphicsGetCurrentContext();
    
    // Core Graphics coordinate system use the bottom-left, UIkit use the flipped one
    CGContextTranslateCTM(context, 0, targetRect.size.height);
    CGContextScaleCTM(context, 1, -1);
    
    CGContextConcatCTM(context, scaleTransform);
    CGContextConcatCTM(context, transform);
    
    SDCGContextDrawSVGDocument(context, document);
    
    image = SDGraphicsGetImageFromCurrentImageContext();
    SDGraphicsEndImageContext();
    
    SDCGSVGDocumentRelease(document);
    
    return image;
}

#pragma mark - Helper

+ (BOOL)supportsVectorSVGImage {
    static dispatch_once_t onceToken;
    static BOOL supports;
    dispatch_once(&onceToken, ^{
        // iOS 13+ supports SVG built-in rendering, use selector to check is more accurate
        if ([UIImage respondsToSelector:SDImageWithCGSVGDocumentSEL]) {
            supports = YES;
        } else {
            supports = NO;
        }
    });
    return supports;
}

+ (BOOL)isSVGFormatForData:(NSData *)data {
    if (!data) {
        return NO;
    }
    // Check end with SVG tag
    return [data rangeOfData:[kSVGTagEnd dataUsingEncoding:NSUTF8StringEncoding] options:NSDataSearchBackwards range: NSMakeRange(data.length - MIN(100, data.length), MIN(100, data.length))].location != NSNotFound;
}

@end

@interface TestImageCell : UITableViewCell

@property (nonatomic, strong, readonly) UILabel *nameLabel;

@property (nonatomic, strong, readonly) UIImageView *systemView;

@property (nonatomic, strong, readonly) UIImageView *animatedView;

@end

@implementation TestImageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _nameLabel = [UILabel new];
        [self.contentView addSubview:_nameLabel];
        _nameLabel.fw.layoutChain.leftWithInset(10).topWithInset(10).height(20);
        
        _systemView = [UIImageView new];
        [self.contentView addSubview:_systemView];
        _systemView.fw.layoutChain.leftWithInset(10).topToBottomOfViewWithOffset(_nameLabel, 10).bottomWithInset(10).width(100);
        
        _animatedView = [[UIImageView fwImageViewAnimatedClass] new];
        [self.contentView addSubview:_animatedView];
        _animatedView.fw.layoutChain.leftToRightOfViewWithOffset(_systemView, 60).topToView(_systemView).bottomToView(_systemView).widthToView(_systemView);
    }
    return self;
}

@end

@interface TestImageViewController () <FWTableViewController>

@property (nonatomic, assign) BOOL isSDWebImage;

@end

@implementation TestImageViewController

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 全版本支持WebP: pod 'SDWebImageWebPCoder'
        // 全版本支持SVG: pod 'SDWebImageSVGKitPlugin'
        
        // 系统支持WebP，iOS14+
        if (@available(iOS 14.0, *)) {
            [SDImageCodersManager.sharedManager addCoder:[SDImageAWebPCoder sharedCoder]];
        }
        // 系统支持SVG，iOS13+
        if (@available(iOS 13.0, *)) {
            [SDImageCodersManager.sharedManager addCoder:[SDImageSVGCoder sharedCoder]];
        }
    });
}

- (UITableViewStyle)renderTableStyle
{
    return UITableViewStyleGrouped;
}

- (void)renderModel
{
    FWWeakifySelf();
    [self fwSetRightBarItem:@"Change" block:^(id  _Nonnull sender) {
        FWStrongifySelf();
        self.isSDWebImage = !self.isSDWebImage;
        [FWPluginManager unloadPlugin:@protocol(FWImagePlugin)];
        [FWPluginManager registerPlugin:@protocol(FWImagePlugin) withObject:self.isSDWebImage ? [FWSDWebImagePlugin class] : [FWImagePluginImpl class]];
        if (self.isSDWebImage) {
            [[SDImageCache sharedImageCache] clearWithCacheType:SDImageCacheTypeAll completion:nil];
        }
        
        [self.tableData removeAllObjects];
        [self.tableView reloadData];
        [self.tableView layoutIfNeeded];
        [self.tableView setContentOffset:CGPointZero animated:NO];
        [self renderData];
    }];
}

- (void)renderData
{
    self.isSDWebImage = [[FWPluginManager loadPlugin:@protocol(FWImagePlugin)] isKindOfClass:[FWSDWebImagePlugin class]];
    self.fwBarTitle = self.isSDWebImage ? @"FWImage - SDWebImage" : @"FWImage - FWWebImage";
    FWSDWebImagePlugin.sharedInstance.fadeAnimated = YES;
    FWImagePluginImpl.sharedInstance.fadeAnimated = YES;
    
    [self.tableData setArray:@[
        @"test.svg",
        @"close.svg",
        @"progressive.jpg",
        @"animation.png",
        @"test.gif",
        @"test.webp",
        @"test.heic",
        @"test.heif",
        @"animation.heic",
        @"http://kvm.wuyong.site/images/images/progressive.jpg",
        @"http://kvm.wuyong.site/images/images/animation.png",
        @"http://kvm.wuyong.site/images/images/test.gif",
        @"http://kvm.wuyong.site/images/images/test.webp",
        @"http://kvm.wuyong.site/images/images/test.heic",
        @"http://kvm.wuyong.site/images/images/test.heif",
        @"http://kvm.wuyong.site/images/images/animation.heic",
        @"http://assets.sbnation.com/assets/2512203/dogflops.gif",
        @"https://raw.githubusercontent.com/liyong03/YLGIFImage/master/YLGIFImageDemo/YLGIFImageDemo/joy.gif",
        @"http://apng.onevcat.com/assets/elephant.png",
        @"http://www.ioncannon.net/wp-content/uploads/2011/06/test2.webp",
        @"http://www.ioncannon.net/wp-content/uploads/2011/06/test9.webp",
        @"http://littlesvr.ca/apng/images/SteamEngine.webp",
        @"http://littlesvr.ca/apng/images/world-cup-2014-42.webp",
        @"https://isparta.github.io/compare-webp/image/gif_webp/webp/2.webp",
        @"https://nokiatech.github.io/heif/content/images/ski_jump_1440x960.heic",
        @"https://nokiatech.github.io/heif/content/image_sequences/starfield_animation.heic",
        @"https://s2.ax1x.com/2019/11/01/KHYIgJ.gif",
        @"https://raw.githubusercontent.com/icons8/flat-color-icons/master/pdf/stack_of_photos.pdf",
        @"https://nr-platform.s3.amazonaws.com/uploads/platform/published_extension/branding_icon/275/AmazonS3.png",
        @"https://upload.wikimedia.org/wikipedia/commons/1/14/Mahuri.svg",
        @"https://simpleicons.org/icons/github.svg",
        @"http://via.placeholder.com/200x200.jpg",
    ]];
    [self.tableView reloadData];
}

#pragma mark - TableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tableData.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 150;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TestImageCell *cell = [TestImageCell.fw cellWithTableView:tableView style:UITableViewCellStyleDefault reuseIdentifier:self.isSDWebImage ? @"SDWebImage" : @"FWWebImage"];
    NSString *fileName = [self.tableData objectAtIndex:indexPath.row];
    cell.nameLabel.text = [[fileName lastPathComponent] stringByAppendingFormat:@"(%@)", [NSData fwMimeTypeFromExtension:[fileName pathExtension]]];
    if (!fileName.fwIsFormatUrl) {
        cell.fw.tempObject = fileName;
        FWDispatchGlobal(^{
            UIImage *image = [TestBundle imageNamed:fileName];
            UIImage *decodeImage = [UIImage fwImageWithData:[UIImage fwDataWithImage:image]];
            FWDispatchMain(^{
                if ([cell.fw.tempObject isEqualToString:fileName]) {
                    [cell.systemView fwSetImageWithURL:nil placeholderImage:image];
                    [cell.animatedView fwSetImageWithURL:nil placeholderImage:decodeImage];
                }
            });
        });
    } else {
        cell.fw.tempObject = nil;
        NSString *url = fileName;
        if ([url hasPrefix:@"http://kvm.wuyong.site"]) {
            url = [url stringByAppendingFormat:@"?t=%@", @(NSDate.fw.currentTime)];
        }
        [cell.systemView fwSetImageWithURL:url];
        [cell.animatedView fwSetImageWithURL:url placeholderImage:[TestBundle imageNamed:@"public_icon"]];
    }
    return cell;
}

@end
