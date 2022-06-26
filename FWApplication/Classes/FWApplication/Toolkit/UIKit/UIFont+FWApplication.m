/**
 @header     UIFont+FWApplication.m
 @indexgroup FWApplication
      UIFont+FWApplication
 @author     wuyong
 @copyright  Copyright © 2018年 wuyong.site. All rights reserved.
 @updated    2018/9/19
 */

#import "UIFont+FWApplication.h"

@implementation UIFont (FWApplication)

#pragma mark - Font

- (BOOL)fw_isBold
{
    return (self.fontDescriptor.symbolicTraits & UIFontDescriptorTraitBold) > 0;
}

- (BOOL)fw_isItalic
{
    return (self.fontDescriptor.symbolicTraits & UIFontDescriptorTraitItalic) > 0;
}

- (UIFont *)fw_boldFont
{
    UIFontDescriptorSymbolicTraits symbolicTraits = self.fontDescriptor.symbolicTraits | UIFontDescriptorTraitBold;
    return [UIFont fontWithDescriptor:[self.fontDescriptor fontDescriptorWithSymbolicTraits:symbolicTraits] size:self.pointSize];
}

- (UIFont *)fw_nonBoldFont
{
    UIFontDescriptorSymbolicTraits symbolicTraits = self.fontDescriptor.symbolicTraits ^ UIFontDescriptorTraitBold;
    return [UIFont fontWithDescriptor:[self.fontDescriptor fontDescriptorWithSymbolicTraits:symbolicTraits] size:self.pointSize];
}

- (UIFont *)fw_italicFont
{
    UIFontDescriptorSymbolicTraits symbolicTraits = self.fontDescriptor.symbolicTraits | UIFontDescriptorTraitItalic;
    return [UIFont fontWithDescriptor:[self.fontDescriptor fontDescriptorWithSymbolicTraits:symbolicTraits] size:self.pointSize];
}

- (UIFont *)fw_nonItalicFont
{
    UIFontDescriptorSymbolicTraits symbolicTraits = self.fontDescriptor.symbolicTraits ^ UIFontDescriptorTraitItalic;
    return [UIFont fontWithDescriptor:[self.fontDescriptor fontDescriptorWithSymbolicTraits:symbolicTraits] size:self.pointSize];
}

#pragma mark - Height

- (CGFloat)fw_spaceHeight
{
    return self.lineHeight - self.pointSize;
}

- (CGFloat)fw_lineSpacingWithMultiplier:(CGFloat)multiplier
{
    return self.pointSize * multiplier - (self.lineHeight - self.pointSize);
}

- (CGFloat)fw_lineHeightWithMultiplier:(CGFloat)multiplier
{
    return self.pointSize * multiplier;
}

- (CGFloat)fw_baselineOffset:(UIFont *)font
{
    return (self.lineHeight - font.lineHeight) / 2 + (self.descender - font.descender);
}

@end
