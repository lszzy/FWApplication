/**
 @header     UIFont+FWApplication.m
 @indexgroup FWApplication
      UIFont+FWApplication
 @author     wuyong
 @copyright  Copyright © 2018年 wuyong.site. All rights reserved.
 @updated    2018/9/19
 */

#import "UIFont+FWApplication.h"

@implementation FWFontWrapper (FWApplication)

#pragma mark - Font

- (BOOL)isBold
{
    return (self.base.fontDescriptor.symbolicTraits & UIFontDescriptorTraitBold) > 0;
}

- (BOOL)isItalic
{
    return (self.base.fontDescriptor.symbolicTraits & UIFontDescriptorTraitItalic) > 0;
}

- (UIFont *)boldFont
{
    UIFontDescriptorSymbolicTraits symbolicTraits = self.base.fontDescriptor.symbolicTraits | UIFontDescriptorTraitBold;
    return [UIFont fontWithDescriptor:[self.base.fontDescriptor fontDescriptorWithSymbolicTraits:symbolicTraits] size:self.base.pointSize];
}

- (UIFont *)nonBoldFont
{
    UIFontDescriptorSymbolicTraits symbolicTraits = self.base.fontDescriptor.symbolicTraits ^ UIFontDescriptorTraitBold;
    return [UIFont fontWithDescriptor:[self.base.fontDescriptor fontDescriptorWithSymbolicTraits:symbolicTraits] size:self.base.pointSize];
}

- (UIFont *)italicFont
{
    UIFontDescriptorSymbolicTraits symbolicTraits = self.base.fontDescriptor.symbolicTraits | UIFontDescriptorTraitItalic;
    return [UIFont fontWithDescriptor:[self.base.fontDescriptor fontDescriptorWithSymbolicTraits:symbolicTraits] size:self.base.pointSize];
}

- (UIFont *)nonItalicFont
{
    UIFontDescriptorSymbolicTraits symbolicTraits = self.base.fontDescriptor.symbolicTraits ^ UIFontDescriptorTraitItalic;
    return [UIFont fontWithDescriptor:[self.base.fontDescriptor fontDescriptorWithSymbolicTraits:symbolicTraits] size:self.base.pointSize];
}

#pragma mark - Height

- (CGFloat)spaceHeight
{
    return self.base.lineHeight - self.base.pointSize;
}

- (CGFloat)lineSpacingWithMultiplier:(CGFloat)multiplier
{
    return self.base.pointSize * multiplier - (self.base.lineHeight - self.base.pointSize);
}

- (CGFloat)lineHeightWithMultiplier:(CGFloat)multiplier
{
    return self.base.pointSize * multiplier;
}

- (CGFloat)baselineOffset:(UIFont *)font
{
    return (self.base.lineHeight - font.lineHeight) / 2 + (self.base.descender - font.descender);
}

@end
