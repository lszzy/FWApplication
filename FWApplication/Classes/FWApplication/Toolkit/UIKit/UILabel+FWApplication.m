/**
 @header     UILabel+FWApplication.m
 @indexgroup FWApplication
      UILabel+FWApplication
 @author     wuyong
 @copyright  Copyright © 2018 wuyong.site. All rights reserved.
 @updated    2018/10/22
 */

#import "UILabel+FWApplication.h"

@implementation FWLabelWrapper (FWApplication)

#pragma mark - Size

- (CGSize)textSize
{
    if (CGSizeEqualToSize(self.base.frame.size, CGSizeZero)) {
        [self.base setNeedsLayout];
        [self.base layoutIfNeeded];
    }
    
    NSMutableDictionary *attr = [[NSMutableDictionary alloc] init];
    attr[NSFontAttributeName] = self.base.font;
    if (self.base.lineBreakMode != NSLineBreakByWordWrapping) {
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        // 由于lineBreakMode默认值为TruncatingTail，多行显示时仍然按照WordWrapping计算
        if (self.base.numberOfLines != 1 && self.base.lineBreakMode == NSLineBreakByTruncatingTail) {
            paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        } else {
            paragraphStyle.lineBreakMode = self.base.lineBreakMode;
        }
        attr[NSParagraphStyleAttributeName] = paragraphStyle;
    }
    
    CGSize drawSize = CGSizeMake(self.base.frame.size.width, CGFLOAT_MAX);
    CGSize size = [self.base.text boundingRectWithSize:drawSize
                                          options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin
                                       attributes:attr
                                          context:nil].size;
    return CGSizeMake(MIN(drawSize.width, ceilf(size.width)), MIN(drawSize.height, ceilf(size.height)));
}

- (CGSize)attributedTextSize
{
    if (CGSizeEqualToSize(self.base.frame.size, CGSizeZero)) {
        [self.base setNeedsLayout];
        [self.base layoutIfNeeded];
    }
    
    CGSize drawSize = CGSizeMake(self.base.frame.size.width, CGFLOAT_MAX);
    CGSize size = [self.base.attributedText boundingRectWithSize:drawSize
                                                    options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin
                                                    context:nil].size;
    return CGSizeMake(MIN(drawSize.width, ceilf(size.width)), MIN(drawSize.height, ceilf(size.height)));
}

@end
