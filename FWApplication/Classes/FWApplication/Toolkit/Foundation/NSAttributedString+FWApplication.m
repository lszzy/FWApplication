/**
 @header     NSAttributedString+FWApplication.m
 @indexgroup FWApplication
      NSAttributedString+FWApplication
 @author     wuyong
 @copyright  Copyright © 2018 wuyong.site. All rights reserved.
 @updated    2018/12/25
 */

#import "NSAttributedString+FWApplication.h"

#pragma mark - FWAttributedOption

@interface FWAttributedOption ()

@end

@implementation FWAttributedOption

#pragma mark - Lifecycle

+ (FWAttributedOption *)appearance
{
    return [FWAppearance appearanceForClass:[self class]];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self fw_applyAppearance];
    }
    return self;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    FWAttributedOption *option = [[[self class] allocWithZone:zone] init];
    option.font = self.font;
    option.paragraphStyle = [self.paragraphStyle mutableCopy];
    option.foregroundColor = self.foregroundColor;
    option.backgroundColor = self.backgroundColor;
    option.ligature = self.ligature;
    option.kern = self.kern;
    option.strikethroughStyle = self.strikethroughStyle;
    option.strikethroughColor = self.strikethroughColor;
    option.underlineStyle = self.underlineStyle;
    option.underlineColor = self.underlineColor;
    option.strokeWidth = self.strokeWidth;
    option.strokeColor = self.strokeColor;
    option.shadow = [self.shadow copy];
    option.textEffect = self.textEffect;
    option.baselineOffset = self.baselineOffset;
    option.obliqueness = self.obliqueness;
    option.expansion = self.expansion;
    option.writingDirection = self.writingDirection;
    option.verticalGlyphForm = self.verticalGlyphForm;
    option.link = self.link;
    option.attachment = self.attachment;
    option.lineHeightMultiplier = self.lineHeightMultiplier;
    option.lineSpacingMultiplier = self.lineSpacingMultiplier;
    return option;
}

#pragma mark - Public

- (NSDictionary<NSAttributedStringKey,id> *)toDictionary
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    if (self.font) dictionary[NSFontAttributeName] = self.font;
    if (self.paragraphStyle) dictionary[NSParagraphStyleAttributeName] = [self.paragraphStyle mutableCopy];
    if (self.foregroundColor) dictionary[NSForegroundColorAttributeName] = self.foregroundColor;
    if (self.backgroundColor) dictionary[NSBackgroundColorAttributeName] = self.backgroundColor;
    if (self.ligature) dictionary[NSLigatureAttributeName] = self.ligature;
    if (self.kern) dictionary[NSKernAttributeName] = self.kern;
    if (self.strikethroughStyle) dictionary[NSStrikethroughStyleAttributeName] = self.strikethroughStyle;
    if (self.strikethroughColor) dictionary[NSStrikethroughColorAttributeName] = self.strikethroughColor;
    if (self.underlineStyle) dictionary[NSUnderlineStyleAttributeName] = self.underlineStyle;
    if (self.underlineColor) dictionary[NSUnderlineColorAttributeName] = self.underlineColor;
    if (self.strokeWidth) dictionary[NSStrokeWidthAttributeName] = self.strokeWidth;
    if (self.strokeColor) dictionary[NSStrokeColorAttributeName] = self.strokeColor;
    if (self.shadow) dictionary[NSShadowAttributeName] = [self.shadow copy];
    if (self.textEffect) dictionary[NSTextEffectAttributeName] = self.textEffect;
    if (self.baselineOffset) dictionary[NSBaselineOffsetAttributeName] = self.baselineOffset;
    if (self.obliqueness) dictionary[NSObliquenessAttributeName] = self.obliqueness;
    if (self.expansion) dictionary[NSExpansionAttributeName] = self.expansion;
    if (self.writingDirection) dictionary[NSWritingDirectionAttributeName] = self.writingDirection;
    if (self.verticalGlyphForm) dictionary[NSVerticalGlyphFormAttributeName] = self.verticalGlyphForm;
    if (self.link) dictionary[NSLinkAttributeName] = self.link;
    if (self.attachment) dictionary[NSAttachmentAttributeName] = self.attachment;
    
    if (self.lineHeightMultiplier > 0 && self.font) {
        CGFloat lineHeight = self.font.pointSize * self.lineHeightMultiplier;
        NSMutableParagraphStyle *paragraphStyle = dictionary[NSParagraphStyleAttributeName] ?: [NSMutableParagraphStyle new];
        if (!paragraphStyle.maximumLineHeight) paragraphStyle.maximumLineHeight = lineHeight;
        if (!paragraphStyle.minimumLineHeight) paragraphStyle.minimumLineHeight = lineHeight;
        dictionary[NSParagraphStyleAttributeName] = paragraphStyle;
        
        if (!dictionary[NSBaselineOffsetAttributeName]) {
            CGFloat baselineOffset = (lineHeight - self.font.lineHeight) / 4;
            dictionary[NSBaselineOffsetAttributeName] = @(baselineOffset);
        }
    }
    
    if (self.lineSpacingMultiplier > 0 && self.font) {
        CGFloat lineSpacing = self.font.pointSize * self.lineSpacingMultiplier - (self.font.lineHeight - self.font.pointSize);
        NSMutableParagraphStyle *paragraphStyle = dictionary[NSParagraphStyleAttributeName] ?: [NSMutableParagraphStyle new];
        if (!paragraphStyle.lineSpacing) paragraphStyle.lineSpacing = lineSpacing;
        dictionary[NSParagraphStyleAttributeName] = paragraphStyle;
    }
    return dictionary;
}

@end

@implementation FWAttributedStringClassWrapper (FWApplication)

#pragma mark - Convert

- (__kindof NSAttributedString *)attributedString:(NSString *)string withFont:(UIFont *)font
{
    return [self attributedString:string withFont:font textColor:nil];
}

- (__kindof NSAttributedString *)attributedString:(NSString *)string withFont:(UIFont *)font textColor:(UIColor *)textColor
{
    NSMutableDictionary *attr = [[NSMutableDictionary alloc] init];
    if (font) {
        attr[NSFontAttributeName] = font;
    }
    if (textColor) {
        attr[NSForegroundColorAttributeName] = textColor;
    }
    return [[self.base alloc] initWithString:string attributes:attr];
}

#pragma mark - Html

- (__kindof NSAttributedString *)attributedStringWithHtmlString:(NSString *)htmlString defaultAttributes:(nullable NSDictionary<NSAttributedStringKey,id> *)attributes
{
    if (!htmlString || htmlString.length < 1) return nil;
    
    if (attributes != nil) {
        NSString *cssString = @"";
        UIColor *textColor = attributes[NSForegroundColorAttributeName];
        if (textColor != nil) {
            cssString = [cssString stringByAppendingFormat:@"color:%@;", [self CSSStringWithColor:textColor]];
        }
        UIFont *font = attributes[NSFontAttributeName];
        if (font != nil) {
            cssString = [cssString stringByAppendingString:[self CSSStringWithFont:font]];
        }
        if (cssString.length > 0) {
            htmlString = [NSString stringWithFormat:@"<style type='text/css'>html{%@}</style>%@", cssString, htmlString];
        }
    }
    
    return [self.base fw_attributedStringWithHtmlString:htmlString];
}

- (FWThemeObject<NSAttributedString *> *)themeObjectWithHtmlString:(NSString *)htmlString defaultAttributes:(NSDictionary<NSAttributedStringKey,id> *)attributes
{
    NSMutableDictionary *lightAttributes = [NSMutableDictionary dictionary];
    NSMutableDictionary *darkAttributes = [NSMutableDictionary dictionary];
    if (attributes != nil) {
        UIColor *textColor = attributes[NSForegroundColorAttributeName];
        if (textColor != nil) {
            lightAttributes[NSForegroundColorAttributeName] = [textColor fw_colorForStyle:FWThemeStyleLight];
            darkAttributes[NSForegroundColorAttributeName] = [textColor fw_colorForStyle:FWThemeStyleDark];
        }
        UIFont *font = attributes[NSFontAttributeName];
        if (font != nil) {
            lightAttributes[NSFontAttributeName] = font;
            darkAttributes[NSFontAttributeName] = font;
        }
    }
    
    NSAttributedString *lightObject = [self attributedStringWithHtmlString:htmlString defaultAttributes:lightAttributes];
    NSAttributedString *darkObject = [self attributedStringWithHtmlString:htmlString defaultAttributes:darkAttributes];
    return [FWThemeObject objectWithLight:lightObject dark:darkObject];
}

- (NSString *)CSSStringWithColor:(UIColor *)color
{
    CGFloat r = 0, g = 0, b = 0, a = 0;
    if (![color getRed:&r green:&g blue:&b alpha:&a]) {
        if ([color getWhite:&r alpha:&a]) { g = r; b = r; }
    }
    
    if (a >= 1.0) {
        return [NSString stringWithFormat:@"rgb(%u, %u, %u)",
                (unsigned)round(r * 255), (unsigned)round(g * 255), (unsigned)round(b * 255)];
    } else {
        return [NSString stringWithFormat:@"rgba(%u, %u, %u, %g)",
                (unsigned)round(r * 255), (unsigned)round(g * 255), (unsigned)round(b * 255), a];
    }
}

- (NSString *)CSSStringWithFont:(UIFont *)font
{
    static NSDictionary *fontWeights = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        fontWeights = @{
            @"ultralight": @"100",
            @"thin": @"200",
            @"light": @"300",
            @"medium": @"500",
            @"semibold": @"600",
            @"demibold": @"600",
            @"extrabold": @"800",
            @"ultrabold": @"800",
            @"bold": @"700",
            @"heavy": @"900",
            @"black": @"900",
        };
    });
    
    NSString *fontName = [font.fontName lowercaseString];
    NSString *fontStyle = @"normal";
    if ([fontName rangeOfString:@"italic"].location != NSNotFound) {
        fontStyle = @"italic";
    } else if ([fontName rangeOfString:@"oblique"].location != NSNotFound) {
        fontStyle = @"oblique";
    }
    
    NSString *fontWeight = @"400";
    for (NSString *fontKey in fontWeights) {
        if ([fontName rangeOfString:fontKey].location != NSNotFound) {
            fontWeight = fontWeights[fontKey];
            break;
        }
    }
    
    return [NSString stringWithFormat:@"font-family:-apple-system;font-weight:%@;font-style:%@;font-size:%.0fpx;",
            fontWeight, fontStyle, font.pointSize];
}

#pragma mark - Option

- (__kindof NSAttributedString *)attributedString:(NSString *)string withOption:(FWAttributedOption *)option
{
    return [[self.base alloc] initWithString:string attributes:[option toDictionary]];
}

@end
