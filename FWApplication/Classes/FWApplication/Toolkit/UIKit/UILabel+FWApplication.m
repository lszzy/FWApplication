/**
 @header     UILabel+FWApplication.m
 @indexgroup FWApplication
      UILabel+FWApplication
 @author     wuyong
 @copyright  Copyright © 2018 wuyong.site. All rights reserved.
 @updated    2018/10/22
 */

#import "UILabel+FWApplication.h"
#import <objc/runtime.h>

@implementation UILabel (FWApplication)

#pragma mark - Size

- (CGSize)fw_textSize
{
    if (CGSizeEqualToSize(self.frame.size, CGSizeZero)) {
        [self setNeedsLayout];
        [self layoutIfNeeded];
    }
    
    NSMutableDictionary *attr = [[NSMutableDictionary alloc] init];
    attr[NSFontAttributeName] = self.font;
    if (self.lineBreakMode != NSLineBreakByWordWrapping) {
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        // 由于lineBreakMode默认值为TruncatingTail，多行显示时仍然按照WordWrapping计算
        if (self.numberOfLines != 1 && self.lineBreakMode == NSLineBreakByTruncatingTail) {
            paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        } else {
            paragraphStyle.lineBreakMode = self.lineBreakMode;
        }
        attr[NSParagraphStyleAttributeName] = paragraphStyle;
    }
    
    CGSize drawSize = CGSizeMake(self.frame.size.width, CGFLOAT_MAX);
    CGSize size = [self.text boundingRectWithSize:drawSize
                                          options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin
                                       attributes:attr
                                          context:nil].size;
    return CGSizeMake(MIN(drawSize.width, ceilf(size.width)), MIN(drawSize.height, ceilf(size.height)));
}

- (CGSize)fw_attributedTextSize
{
    if (CGSizeEqualToSize(self.frame.size, CGSizeZero)) {
        [self setNeedsLayout];
        [self layoutIfNeeded];
    }
    
    CGSize drawSize = CGSizeMake(self.frame.size.width, CGFLOAT_MAX);
    CGSize size = [self.attributedText boundingRectWithSize:drawSize
                                                    options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin
                                                    context:nil].size;
    return CGSizeMake(MIN(drawSize.width, ceilf(size.width)), MIN(drawSize.height, ceilf(size.height)));
}

@end

#pragma mark - UILabel+FWDebugger

@implementation UILabel (FWDebugger)

- (BOOL)fw_showPrincipalLines {
    return self.fw_innerShowPrincipalLines;
}

- (void)setFw_showPrincipalLines:(BOOL)showPrincipalLines {
    self.fw_innerShowPrincipalLines = showPrincipalLines;
}

- (UIColor *)fw_principalLineColor {
    return self.fw_innerPrincipalLineColor;
}

- (void)setFw_principalLineColor:(UIColor *)color {
    self.fw_innerPrincipalLineColor = color;
}

- (CAShapeLayer *)fw_principalLineLayer {
    return objc_getAssociatedObject(self, @selector(fw_principalLineLayer));
}

- (void)setFw_principalLineLayer:(CAShapeLayer *)layer {
    objc_setAssociatedObject(self, @selector(fw_principalLineLayer), layer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (void)fw_swizzlePrincipalLines {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        FWSwizzleClass(UILabel, @selector(layoutSubviews), FWSwizzleReturn(void), FWSwizzleArgs(), FWSwizzleCode({
            FWSwizzleOriginal();
            
            UILabel *label = selfObject;
            if (!label.fw_principalLineLayer || label.fw_principalLineLayer.hidden)  return;
            label.fw_principalLineLayer.frame = label.bounds;
            
            NSRange range = NSMakeRange(0, label.attributedText.length);
            CGFloat baselineOffset = [[label.attributedText attribute:NSBaselineOffsetAttributeName atIndex:0 effectiveRange:&range] doubleValue];
            CGFloat lineOffset = baselineOffset * 2;
            UIFont *font = label.font;
            CGFloat maxX = CGRectGetWidth(label.bounds);
            CGFloat maxY = CGRectGetHeight(label.bounds);
            CGFloat descenderY = maxY + font.descender - lineOffset;
            CGFloat xHeightY = maxY - (font.xHeight - font.descender) - lineOffset;
            CGFloat capHeightY = maxY - (font.capHeight - font.descender) - lineOffset;
            CGFloat lineHeightY = maxY - font.lineHeight - lineOffset;
            
            void (^addLineAtY)(UIBezierPath *, CGFloat) = ^void(UIBezierPath *p, CGFloat y) {
                CGFloat offset = FWPixelOne / 2;
                y = FWFlatValue(y) - offset;
                [p moveToPoint:CGPointMake(0, y)];
                [p addLineToPoint:CGPointMake(maxX, y)];
            };
            UIBezierPath *path = [UIBezierPath bezierPath];
            addLineAtY(path, descenderY);
            addLineAtY(path, xHeightY);
            addLineAtY(path, capHeightY);
            addLineAtY(path, lineHeightY);
            label.fw_principalLineLayer.path = path.CGPath;
        }));
    });
}

- (void)fw_updatePrincipalLines {
    if (self.fw_showPrincipalLines && !self.fw_principalLineLayer) {
        CAShapeLayer *layer = [CAShapeLayer layer];
        self.fw_principalLineLayer = layer;
        layer.strokeColor = self.fw_principalLineColor.CGColor;
        layer.lineWidth = FWPixelOne;
        [self.layer addSublayer:layer];
        
        [UILabel fw_swizzlePrincipalLines];
    }
    self.fw_principalLineLayer.hidden = !self.fw_showPrincipalLines;
}

- (BOOL)fw_innerShowPrincipalLines {
    return [objc_getAssociatedObject(self, @selector(fw_innerShowPrincipalLines)) boolValue];
}

- (void)setFw_innerShowPrincipalLines:(BOOL)showPrincipalLines {
    objc_setAssociatedObject(self, @selector(fw_innerShowPrincipalLines), @(showPrincipalLines), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self fw_updatePrincipalLines];
}

- (UIColor *)fw_innerPrincipalLineColor {
    UIColor *color = objc_getAssociatedObject(self, @selector(fw_innerPrincipalLineColor));
    return color ?: [UIColor colorWithRed:1.0 green:0 blue:0 alpha:0.3];
}

- (void)setFw_innerPrincipalLineColor:(UIColor *)color {
    objc_setAssociatedObject(self, @selector(fw_innerPrincipalLineColor), color, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
