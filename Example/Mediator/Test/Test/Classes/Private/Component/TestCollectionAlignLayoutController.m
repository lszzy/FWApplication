//
//  TestCollectionAlignLayoutController.m
//  Example
//
//  Created by wuyong on 2018/10/18.
//  Copyright © 2018 wuyong.site. All rights reserved.
//

#import "TestCollectionAlignLayoutController.h"

@interface FWCollectionViewCell : UICollectionViewCell

@property (nonatomic, copy) NSString *title;

@end

@interface FWCollectionViewCell ()

@property (nonatomic, weak) UILabel *label;

@end

@implementation FWCollectionViewCell

- (void)setTitle:(NSString *)title {
    _title = title;
    self.label.text = title;
    [self.contentView layoutIfNeeded];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.label.frame = self.contentView.bounds;
}

- (UILabel *)label {
    if (!_label) {
        UILabel *label = [[UILabel alloc] initWithFrame:self.contentView.bounds];
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont boldSystemFontOfSize:14.f];
        label.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:label];
        _label = label;
    }
    return _label;
}

@end

@interface AlignmentCollectionHeaderView : UICollectionReusableView

@property (nonatomic, weak) UILabel *label;

@end

@implementation AlignmentCollectionHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor colorWithWhite:.9f alpha:1.f];
        self.label.frame = self.bounds;
    }
    return self;
}

- (UILabel *)label {
    if (!_label) {
        UILabel *label = [[UILabel alloc] init];
        label.numberOfLines = 0;
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont boldSystemFontOfSize:16.f];
        [self addSubview:label];
        _label = label;
    }
    return _label;
}

@end

@interface JQSectionItemModel : NSObject

@property (nonatomic, strong) UIColor *color;
@property (nonatomic, assign) CGSize size;
@property (nonatomic, assign) NSUInteger index;

- (instancetype)initWithColor:(UIColor *)color size:(CGSize)size index:(NSUInteger)index;

@end

@interface JQSectionModel : NSObject
 
@property (nonatomic, assign) FWCollectionViewItemsHorizontalAlignment horizontalAlignment;
@property (nonatomic, assign) FWCollectionViewItemsVerticalAlignment verticalAlignment;
@property (nonatomic, assign) FWCollectionViewItemsDirection direction;
@property (nonatomic, strong) NSMutableArray<JQSectionItemModel *> *items;
@property (nonatomic, copy, readonly) NSString *alignmentDescription;

@end

@implementation JQSectionItemModel

- (instancetype)initWithColor:(UIColor *)color size:(CGSize)size index:(NSUInteger)index {
    if (self = [super init]) {
        self.color = color;
        self.size = size;
        self.index = index;
    }
    return self;
}

@end

@implementation JQSectionModel
@synthesize alignmentDescription = _alignmentDescription;

- (NSString *)alignmentDescription {
    if (!_alignmentDescription) {
        NSMutableString *desc = @"horizontal: ".mutableCopy;
        if (self.horizontalAlignment == FWCollectionViewItemsHorizontalAlignmentFlow) {
            [desc appendString:@"flow"];
        } else if (self.horizontalAlignment == FWCollectionViewItemsHorizontalAlignmentLeft) {
            [desc appendString:@"left"];
        } else if (self.horizontalAlignment == FWCollectionViewItemsHorizontalAlignmentRight) {
            [desc appendString:@"right"];
        } else if (self.horizontalAlignment == FWCollectionViewItemsHorizontalAlignmentCenter) {
            [desc appendString:@"center"];
        } else if (self.horizontalAlignment == FWCollectionViewItemsHorizontalAlignmentFlowFilled) {
            [desc appendString:@"flow filled"];
        }
        [desc appendString:@"\nvertical: "];
        if (self.verticalAlignment == FWCollectionViewItemsVerticalAlignmentCenter) {
            [desc appendString:@"center"];
        } else if (self.verticalAlignment == FWCollectionViewItemsVerticalAlignmentBottom) {
            [desc appendString:@"bottom"];
        } else if (self.verticalAlignment == FWCollectionViewItemsVerticalAlignmentTop) {
            [desc appendString:@"top"];
        }
        [desc appendString:@"\ndirection: "];
        if (self.direction == FWCollectionViewItemsDirectionRTL) {
            [desc appendString:@"right to left"];
        } else {
            [desc appendString:@"left to right"];
        }
        _alignmentDescription = desc;
    }
    return _alignmentDescription;
}

@end

@interface TestCollectionAlignLayoutController ()<UICollectionViewDataSource, FWCollectionViewDelegateAlignLayout, FWCollectionViewController>

@property (nonatomic, copy) NSArray<JQSectionModel *> *data;

@end

static NSString *const kCellReuseIdentifier = @"kCellReuseIdentifier";
static NSString *const kHeaderReuseIdentifier = @"kHeaderReuseIdentifier";
static NSString *const kFooterReuseIdentifier = @"kFooterReuseIdentifier";

@implementation TestCollectionAlignLayoutController

- (UICollectionViewLayout *)renderCollectionViewLayout {
    FWCollectionViewAlignLayout *viewLayout = [[FWCollectionViewAlignLayout alloc] init];
    return viewLayout;
}

- (void)renderCollectionView {
    self.collectionView.contentInset = UIEdgeInsetsMake(10, 10, 10, 10);
    [self.collectionView registerClass:[FWCollectionViewCell class] forCellWithReuseIdentifier:kCellReuseIdentifier];
    [self.collectionView registerClass:[AlignmentCollectionHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kHeaderReuseIdentifier];
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:kFooterReuseIdentifier];
}

#pragma mark - UICollectionViewDataSource, FWCollectionViewAlignLayoutDelegate

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.data.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.data[section].items.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FWCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellReuseIdentifier forIndexPath:indexPath];
    cell.contentView.backgroundColor = self.data[indexPath.section].items[indexPath.item].color;
    cell.title = [NSString stringWithFormat:@"%zd", self.data[indexPath.section].items[indexPath.item].index];
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        AlignmentCollectionHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kHeaderReuseIdentifier forIndexPath:indexPath];
        headerView.label.text = self.data[indexPath.section].alignmentDescription;
        return headerView;
    }
    UICollectionReusableView *footer = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:kFooterReuseIdentifier forIndexPath:indexPath];
    footer.backgroundColor = [UIColor darkGrayColor];
    return footer;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(10, 10, 10, 10);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(0.f, 90.f);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    return CGSizeMake(0, 44.f);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.data[indexPath.section].items[indexPath.item].size;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableArray *arr = self.data[indexPath.section].items;
    [arr removeObjectAtIndex:indexPath.item];
    [collectionView deleteItemsAtIndexPaths:@[ indexPath ]];
}

- (FWCollectionViewItemsHorizontalAlignment)collectionView:(UICollectionView *)collectionView layout:(FWCollectionViewAlignLayout *)layout itemsHorizontalAlignmentInSection:(NSInteger)section {
    return self.data[section].horizontalAlignment;
}

- (FWCollectionViewItemsVerticalAlignment)collectionView:(UICollectionView *)collectionView layout:(FWCollectionViewAlignLayout *)layout itemsVerticalAlignmentInSection:(NSInteger)section {
    return self.data[section].verticalAlignment;
}

- (FWCollectionViewItemsDirection)collectionView:(UICollectionView *)collectionView layout:(FWCollectionViewAlignLayout *)layout itemsDirectionInSection:(NSInteger)section {
    return self.data[section].direction;
}

- (FWCollectionViewSectionConfig *)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)layout configForSectionAtIndex:(NSInteger)section {
    FWCollectionViewSectionConfig *config = [FWCollectionViewSectionConfig new];
    config.backgroundColor = UIColor.fwRandomColor;
    return config;
}

#pragma mark - getter

- (NSArray<JQSectionModel *> *)data {
    if (!_data) {
        NSMutableArray *data = [[NSMutableArray alloc] init];
        FWCollectionViewItemsVerticalAlignment verticalAlignments[] = {FWCollectionViewItemsVerticalAlignmentCenter, FWCollectionViewItemsVerticalAlignmentTop, FWCollectionViewItemsVerticalAlignmentBottom};
        FWCollectionViewItemsHorizontalAlignment horizontalAlignments[] = {FWCollectionViewItemsHorizontalAlignmentCenter, FWCollectionViewItemsHorizontalAlignmentLeft, FWCollectionViewItemsHorizontalAlignmentRight, FWCollectionViewItemsHorizontalAlignmentFlow, FWCollectionViewItemsHorizontalAlignmentFlowFilled};
        FWCollectionViewItemsDirection directions[] = {FWCollectionViewItemsDirectionLTR, FWCollectionViewItemsDirectionRTL};
        for (int i = 0; i < 5; i++) {
            FWCollectionViewItemsHorizontalAlignment horizontal = horizontalAlignments[i];
            for (int j = 0; j < 3; j++) {
                FWCollectionViewItemsVerticalAlignment vertical = verticalAlignments[j];
                for (int k = 0; k < 2; k++) {
                    FWCollectionViewItemsDirection direction = directions[k];
                    int count = 40;
                    NSMutableArray *items = [[NSMutableArray alloc] init];
                    for (int j = 0; j < count; j++) {
                        UIColor *color = [UIColor colorWithRed:arc4random() % 255 / 255.f green:arc4random() % 255 / 255.f blue:arc4random() % 255 / 255.f alpha:1.f];
                        CGSize size = CGSizeMake((arc4random() % 5 + 5) * 10, (arc4random() % 5 + 5) * 5);
                        JQSectionItemModel *item = [[JQSectionItemModel alloc] initWithColor:color size:size index:j];
                        [items addObject:item];
                    }
                    JQSectionModel *section = [[JQSectionModel alloc] init];
                    section.verticalAlignment = vertical;
                    section.horizontalAlignment = horizontal;
                    section.direction = direction;
                    section.items = items;
                    [data addObject:section];
                }
            }
            _data = data;
        }
    }
    return _data;
}

@end
