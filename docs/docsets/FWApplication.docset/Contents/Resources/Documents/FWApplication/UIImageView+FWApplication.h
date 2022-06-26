//
//  UIImageView+FWApplication.h
//  FWApplication
//
//  Created by wuyong on 2017/5/27.
//  Copyright © 2018年 wuyong.site. All rights reserved.
//

@import FWFramework;

NS_ASSUME_NONNULL_BEGIN

@interface UIImageView (FWApplication)

#pragma mark - Mode

// 设置图片模式为ScaleAspectFill，自动拉伸不变形，超过区域隐藏。可通过appearance统一设置
- (void)fw_setContentModeAspectFill UI_APPEARANCE_SELECTOR NS_REFINED_FOR_SWIFT;

// 设置指定图片模式，超过区域隐藏。可通过appearance统一设置
- (void)fw_setContentMode:(UIViewContentMode)contentMode UI_APPEARANCE_SELECTOR NS_REFINED_FOR_SWIFT;

#pragma mark - Face

// 优化图片人脸显示，参考：https://github.com/croath/UIImageView-BetterFace
- (void)fw_faceAware NS_REFINED_FOR_SWIFT;

#pragma mark - Reflect

// 倒影效果
- (void)fw_reflect NS_REFINED_FOR_SWIFT;

#pragma mark - Watermark

// 图片水印
- (void)fw_setImage:(UIImage *)image watermarkImage:(UIImage *)watermarkImage inRect:(CGRect)rect NS_REFINED_FOR_SWIFT;

// 文字水印，指定区域
- (void)fw_setImage:(UIImage *)image watermarkString:(NSAttributedString *)watermarkString inRect:(CGRect)rect NS_REFINED_FOR_SWIFT;

// 文字水印，指定坐标
- (void)fw_setImage:(UIImage *)image watermarkString:(NSAttributedString *)watermarkString atPoint:(CGPoint)point NS_REFINED_FOR_SWIFT;

@end

NS_ASSUME_NONNULL_END
