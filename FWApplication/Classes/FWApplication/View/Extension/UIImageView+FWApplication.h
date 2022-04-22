//
//  UIImageView+FWApplication.h
//  FWApplication
//
//  Created by wuyong on 2017/5/27.
//  Copyright © 2018年 wuyong.site. All rights reserved.
//

@import FWFramework;

NS_ASSUME_NONNULL_BEGIN

@interface FWImageViewWrapper (FWApplication)

#pragma mark - Mode

// 设置图片模式为ScaleAspectFill，自动拉伸不变形，超过区域隐藏。可通过appearance统一设置
- (void)setContentModeAspectFill UI_APPEARANCE_SELECTOR;

// 设置指定图片模式，超过区域隐藏。可通过appearance统一设置
- (void)setContentMode:(UIViewContentMode)contentMode UI_APPEARANCE_SELECTOR;

#pragma mark - Face

// 优化图片人脸显示，参考：https://github.com/croath/UIImageView-BetterFace
- (void)faceAware;

#pragma mark - Reflect

// 倒影效果
- (void)reflect;

#pragma mark - Watermark

// 图片水印
- (void)setImage:(UIImage *)image watermarkImage:(UIImage *)watermarkImage inRect:(CGRect)rect;

// 文字水印，指定区域
- (void)setImage:(UIImage *)image watermarkString:(NSAttributedString *)watermarkString inRect:(CGRect)rect;

// 文字水印，指定坐标
- (void)setImage:(UIImage *)image watermarkString:(NSAttributedString *)watermarkString atPoint:(CGPoint)point;

@end

NS_ASSUME_NONNULL_END
