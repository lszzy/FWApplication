//
//  UIImageView+FWApplication.m
//  FWApplication
//
//  Created by wuyong on 2017/5/27.
//  Copyright © 2018年 wuyong.site. All rights reserved.
//

#import "UIImageView+FWApplication.h"
#import <CoreImage/CoreImage.h>
#import <QuartzCore/QuartzCore.h>

@implementation FWImageViewWrapper (FWApplication)

#pragma mark - Mode

- (void)setContentModeAspectFill
{
    [self setContentMode:UIViewContentModeScaleAspectFill];
}

- (void)setContentMode:(UIViewContentMode)contentMode
{
    self.base.contentMode = contentMode;
    self.base.layer.masksToBounds = YES;
}

#pragma mark - Face

- (void)faceAware
{
    if (self.base.image == nil) {
        return;
    }
    
    [self faceDetect:self.base.image];
}

- (void)faceDetect:(UIImage *)aImage
{
    // 初始化人脸检测
    static CIDetector *_faceDetector = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _faceDetector = [CIDetector detectorOfType:CIDetectorTypeFace
                                           context:nil
                                           options:@{CIDetectorAccuracy: CIDetectorAccuracyHigh}];
    });
    
    __weak UIImageView *weakBase = self.base;
    dispatch_queue_t queue = dispatch_queue_create("site.wuyong.FWApplication.FWFaceQueue", NULL);
    dispatch_async(queue, ^{
        CIImage *image = aImage.CIImage;
        if (image == nil) {
            image = [CIImage imageWithCGImage:aImage.CGImage];
        }
        
        NSArray *features = [_faceDetector featuresInImage:image];
        if (features.count == 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[weakBase.fw faceLayer:NO] removeFromSuperlayer];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakBase.fw faceMark:features size:CGSizeMake(CGImageGetWidth(aImage.CGImage), CGImageGetHeight(aImage.CGImage))];
            });
        }
    });
}

- (void)faceMark:(NSArray *)features size:(CGSize)size
{
    CGRect fixedRect = CGRectMake(MAXFLOAT, MAXFLOAT, 0, 0);
    CGFloat rightBorder = 0, bottomBorder = 0;
    for (CIFaceFeature *f in features){
        CGRect oneRect = f.bounds;
        oneRect.origin.y = size.height - oneRect.origin.y - oneRect.size.height;
        
        fixedRect.origin.x = MIN(oneRect.origin.x, fixedRect.origin.x);
        fixedRect.origin.y = MIN(oneRect.origin.y, fixedRect.origin.y);
        
        rightBorder = MAX(oneRect.origin.x + oneRect.size.width, rightBorder);
        bottomBorder = MAX(oneRect.origin.y + oneRect.size.height, bottomBorder);
    }
    
    fixedRect.size.width = rightBorder - fixedRect.origin.x;
    fixedRect.size.height = bottomBorder - fixedRect.origin.y;
    
    CGPoint fixedCenter = CGPointMake(fixedRect.origin.x + fixedRect.size.width / 2.0,
                                      fixedRect.origin.y + fixedRect.size.height / 2.0);
    CGPoint offset = CGPointZero;
    CGSize finalSize = size;
    if (size.width / size.height > self.base.bounds.size.width / self.base.bounds.size.height) {
        // 水平移动
        finalSize.height = self.base.bounds.size.height;
        finalSize.width = size.width/size.height * finalSize.height;
        fixedCenter.x = finalSize.width / size.width * fixedCenter.x;
        fixedCenter.y = finalSize.width / size.width * fixedCenter.y;
        
        offset.x = fixedCenter.x - self.base.bounds.size.width * 0.5;
        if (offset.x < 0) {
            offset.x = 0;
        } else if (offset.x + self.base.bounds.size.width > finalSize.width) {
            offset.x = finalSize.width - self.base.bounds.size.width;
        }
        offset.x = - offset.x;
    } else {
        // 垂直移动
        finalSize.width = self.base.bounds.size.width;
        finalSize.height = size.height/size.width * finalSize.width;
        fixedCenter.x = finalSize.width / size.width * fixedCenter.x;
        fixedCenter.y = finalSize.width / size.width * fixedCenter.y;
        
        offset.y = fixedCenter.y - self.base.bounds.size.height * (1 - 0.618);
        if (offset.y < 0) {
            offset.y = 0;
        } else if (offset.y + self.base.bounds.size.height > finalSize.height){
            offset.y = finalSize.height - self.base.bounds.size.height;
        }
        offset.y = - offset.y;
    }
    
    CALayer *layer = [self faceLayer:YES];
    layer.frame = CGRectMake(offset.x, offset.y, finalSize.width, finalSize.height);
    layer.contents = (id)self.base.image.CGImage;
}

- (CALayer *)faceLayer:(BOOL)lazyload
{
    for (CALayer *layer in self.base.layer.sublayers) {
        if ([@"FWFaceLayer" isEqualToString:layer.name]) {
            return layer;
        }
    }
    
    if (lazyload) {
        CALayer *layer = [CALayer layer];
        layer.name = @"FWFaceLayer";
        layer.actions = @{
                          @"contents": [NSNull null],
                          @"bounds": [NSNull null],
                          @"position": [NSNull null],
                          };
        [self.base.layer addSublayer:layer];
        return layer;
    }
    
    return nil;
}

#pragma mark - Reflect

- (void)reflect
{
    CGRect frame = self.base.frame;
    frame.origin.y += (frame.size.height + 1);
    
    UIImageView *reflectionImageView = [[UIImageView alloc] initWithFrame:frame];
    self.base.clipsToBounds = TRUE;
    reflectionImageView.contentMode = self.base.contentMode;
    [reflectionImageView setImage:self.base.image];
    reflectionImageView.transform = CGAffineTransformMakeScale(1.0, -1.0);
    
    CALayer *reflectionLayer = [reflectionImageView layer];
    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.bounds = reflectionLayer.bounds;
    gradientLayer.position = CGPointMake(reflectionLayer.bounds.size.width / 2, reflectionLayer.bounds.size.height * 0.5);
    gradientLayer.colors = [NSArray arrayWithObjects:
                            (id)[[UIColor clearColor] CGColor],
                            (id)[[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.3] CGColor], nil];
    
    gradientLayer.startPoint = CGPointMake(0.5, 0.5);
    gradientLayer.endPoint = CGPointMake(0.5, 1.0);
    reflectionLayer.mask = gradientLayer;
    
    [self.base.superview addSubview:reflectionImageView];
}

#pragma mark - Watermark

- (void)setImage:(UIImage *)image watermarkImage:(UIImage *)watermarkImage inRect:(CGRect)rect
{
    UIGraphicsBeginImageContextWithOptions(self.base.frame.size, NO, 0.0);
    
    // 原图和水印图
    [image drawInRect:self.base.bounds];
    [watermarkImage drawInRect:rect];
    
    UIImage *newPic = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.base.image = newPic;
}

- (void)setImage:(UIImage *)image watermarkString:(NSAttributedString *)watermarkString inRect:(CGRect)rect
{
    UIGraphicsBeginImageContextWithOptions(self.base.frame.size, NO, 0.0);
    
    // 原图和水印文字
    [image drawInRect:self.base.bounds];
    [watermarkString drawInRect:rect];
    
    UIImage *newPic = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.base.image = newPic;
}

- (void)setImage:(UIImage *)image watermarkString:(NSAttributedString *)watermarkString atPoint:(CGPoint)point
{
    UIGraphicsBeginImageContextWithOptions(self.base.frame.size, NO, 0.0);
    
    // 原图和水印文字
    [image drawInRect:self.base.bounds];
    [watermarkString drawAtPoint:point];
    
    UIImage *newPic = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.base.image = newPic;
}

@end
