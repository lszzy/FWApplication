/*!
 @header     FWImagePickerController.h
 @indexgroup FWApplication
 @brief      FWImagePickerController
 @author     wuyong
 @copyright  Copyright © 2020 wuyong.site. All rights reserved.
 @updated    2020/9/7
 */

#import "FWImagePickerController.h"
#import "FWImagePickerPluginImpl.h"
#import "FWImageCropController.h"
#import "FWAdaptive.h"
#import "FWToolkit.h"
#import "FWBlock.h"
#import "FWEmptyPlugin.h"
#import "FWToastPlugin.h"
#import "FWAlertPlugin.h"
#import "FWNavigationView.h"
#import "FWViewPlugin.h"
#import "FWImagePlugin.h"
#import "FWSwizzle.h"
#import "FWAppBundle.h"

#pragma mark - FWImageAlbumTableCell

@implementation FWImageAlbumTableCell

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [FWImageAlbumTableCell appearance].albumImageSize = 72;
        [FWImageAlbumTableCell appearance].albumImageMarginLeft = 16;
        [FWImageAlbumTableCell appearance].albumNameInsets = UIEdgeInsetsMake(0, 14, 0, 3);
        [FWImageAlbumTableCell appearance].albumNameFont = [UIFont systemFontOfSize:17];
        [FWImageAlbumTableCell appearance].albumNameColor = nil;
        [FWImageAlbumTableCell appearance].albumAssetsNumberFont = [UIFont systemFontOfSize:17];
        [FWImageAlbumTableCell appearance].albumAssetsNumberColor = nil;
    });
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self didInitializeWithStyle:style];
    }
    return self;
}

- (void)didInitializeWithStyle:(UITableViewCellStyle)style {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.clipsToBounds = YES;
    self.imageView.layer.borderWidth = [UIScreen fwPixelOne];
    self.imageView.layer.borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.1].CGColor;
}

- (void)updateCellAppearance:(NSIndexPath *)indexPath {
    self.textLabel.font = self.albumNameFont;
    self.detailTextLabel.font = self.albumAssetsNumberFont;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat imageEdgeTop = (CGRectGetHeight(self.contentView.bounds) - self.albumImageSize) / 2.0;
    CGFloat imageEdgeLeft = self.albumImageMarginLeft == -1 ? imageEdgeTop : self.albumImageMarginLeft;
    self.imageView.frame = CGRectMake(imageEdgeLeft, imageEdgeTop, self.albumImageSize, self.albumImageSize);
    
    self.textLabel.fwOrigin = CGPointMake(CGRectGetMaxX(self.imageView.frame) + self.albumNameInsets.left, (CGRectGetHeight(self.textLabel.superview.bounds) - CGRectGetHeight(self.textLabel.frame)) / 2.0);
    
    CGFloat textLabelMaxWidth = CGRectGetWidth(self.contentView.bounds) - CGRectGetMinX(self.textLabel.frame) - CGRectGetWidth(self.detailTextLabel.bounds) - self.albumNameInsets.right;
    if (CGRectGetWidth(self.textLabel.bounds) > textLabelMaxWidth) {
        self.textLabel.fwWidth = textLabelMaxWidth;
    }
    
    self.detailTextLabel.fwOrigin = CGPointMake(CGRectGetMaxX(self.textLabel.frame) + self.albumNameInsets.right, (CGRectGetHeight(self.detailTextLabel.superview.bounds) - CGRectGetHeight(self.detailTextLabel.frame)) / 2.0);
}

- (void)setAlbumNameFont:(UIFont *)albumNameFont {
    _albumNameFont = albumNameFont;
    self.textLabel.font = albumNameFont;
}

- (void)setAlbumNameColor:(UIColor *)albumNameColor {
    _albumNameColor = albumNameColor;
    self.textLabel.textColor = albumNameColor;
}

- (void)setAlbumAssetsNumberFont:(UIFont *)albumAssetsNumberFont {
    _albumAssetsNumberFont = albumAssetsNumberFont;
    self.detailTextLabel.font = albumAssetsNumberFont;
}

- (void)setAlbumAssetsNumberColor:(UIColor *)albumAssetsNumberColor {
    _albumAssetsNumberColor = albumAssetsNumberColor;
    self.detailTextLabel.textColor = albumAssetsNumberColor;
}

@end

#pragma mark - FWImageAlbumController

@interface FWImageAlbumController ()

@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, strong) NSMutableArray<FWAssetGroup *> *albumsArray;
@property(nonatomic, strong) FWImagePickerController *imagePickerController;

@end

@implementation FWImageAlbumController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [self didInitialize];
    }
    return self;
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self didInitialize];
    }
    return self;
}

- (void)didInitialize {
    _albumsArray = [[NSMutableArray alloc] init];
    _showsDefaultLoading = YES;
    _albumTableViewCellHeight = 88;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.isViewLoaded ? self.view.bounds : CGRectZero style:UITableViewStylePlain];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.showsHorizontalScrollIndicator = NO;
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.tableView];
    
    if (!self.title) self.title = @"照片";
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem fwBarItemWithObject:FWAppBundle.cancelButton target:self action:@selector(cancelItemClicked:)];
    
    if ([FWAssetManager authorizationStatus] == FWAssetAuthorizationStatusNotAuthorized) {
        if ([self.albumControllerDelegate respondsToSelector:@selector(albumControllerWillShowDenied:)]) {
            [self.albumControllerDelegate albumControllerWillShowDenied:self];
        } else {
            NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
            NSString *appName = infoDictionary[@"CFBundleDisplayName"] ?: infoDictionary[(NSString *)kCFBundleNameKey];
            NSString *tipText = [NSString stringWithFormat:@"请在设备的\"设置-隐私-照片\"选项中，允许%@访问你的手机相册", appName];
            [self fwShowEmptyViewWithText:tipText];
        }
    } else {
        if (self.showsDefaultLoading) {
            [self fwShowLoading];
        }
        if ([self.albumControllerDelegate respondsToSelector:@selector(albumControllerWillStartLoading:)]) {
            [self.albumControllerDelegate albumControllerWillStartLoading:self];
        }
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[FWAssetManager sharedInstance] enumerateAllAlbumsWithAlbumContentType:self.contentType usingBlock:^(FWAssetGroup *resultAssetsGroup) {
                if (resultAssetsGroup) {
                    [self.albumsArray addObject:resultAssetsGroup];
                } else {
                    // 意味着遍历完所有的相簿了
                    [self sortAlbumArray];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self refreshAlbumGroups];
                    });
                }
            }];
        });
    }
}

- (void)sortAlbumArray {
    // 把隐藏相册排序强制放到最后
    __block FWAssetGroup *hiddenGroup = nil;
    [self.albumsArray enumerateObjectsUsingBlock:^(FWAssetGroup * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.phAssetCollection.assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumAllHidden) {
            hiddenGroup = obj;
            *stop = YES;
        }
    }];
    if (hiddenGroup) {
        [self.albumsArray removeObject:hiddenGroup];
        [self.albumsArray addObject:hiddenGroup];
    }
}

- (void)refreshAlbumGroups {
    if ([self.albumsArray count] > 0) {
        [self.tableView reloadData];
        
        if (self.showsDefaultLoading) {
            [self fwHideLoading];
        }
        if ([self.albumControllerDelegate respondsToSelector:@selector(albumControllerWillFinishLoading:)]) {
            [self.albumControllerDelegate albumControllerWillFinishLoading:self];
        }
    } else {
        if ([self.albumControllerDelegate respondsToSelector:@selector(albumControllerWillShowEmpty:)]) {
            [self.albumControllerDelegate albumControllerWillShowEmpty:self];
        } else {
            [self fwShowEmptyViewWithText:@"空照片"];
        }
    }
}

- (void)pickAlbumsGroup:(FWAssetGroup *)assetsGroup animated:(BOOL)animated {
    if (!assetsGroup) return;
    
    if (!self.imagePickerController) {
        self.imagePickerController = [self.albumControllerDelegate imagePickerControllerForAlbumController:self];
    }
    
    [self.imagePickerController refreshWithAssetsGroup:assetsGroup];
    self.imagePickerController.title = [assetsGroup name];
    [self.navigationController pushViewController:self.imagePickerController animated:animated];
}

- (void)pickAlbumsGroup:(FWAssetGroup *)assetsGroup {
    [self pickAlbumsGroup:assetsGroup animated:NO];
}

#pragma mark - <UITableViewDelegate,UITableViewDataSource>

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.albumsArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.albumTableViewCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *kCellIdentifer = @"cell";
    FWImageAlbumTableCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifer];
    if (!cell) {
        cell = [[FWImageAlbumTableCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kCellIdentifer];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    FWAssetGroup *assetsGroup = self.albumsArray[indexPath.row];
    cell.imageView.image = [assetsGroup posterImageWithSize:CGSizeMake(self.albumTableViewCellHeight, self.albumTableViewCellHeight)];
    cell.textLabel.text = [assetsGroup name];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"· %@", @(assetsGroup.numberOfAssets)];
    [cell updateCellAppearance:indexPath];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self pickAlbumsGroup:self.albumsArray[indexPath.row] animated:YES];
}

- (void)cancelItemClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^(void) {
        if (self.albumControllerDelegate && [self.albumControllerDelegate respondsToSelector:@selector(albumControllerDidCancel:)]) {
            [self.albumControllerDelegate albumControllerDidCancel:self];
        }
        [self.imagePickerController.selectedImageAssetArray removeAllObjects];
    }];
}

@end

#pragma mark - FWImagePickerCollectionCell

@interface FWImagePickerCollectionCell ()

@property(nonatomic, strong, readwrite) UIButton *checkboxButton;

@end

@implementation FWImagePickerCollectionCell

@synthesize videoDurationLabel = _videoDurationLabel;

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [FWImagePickerCollectionCell appearance].checkboxImage = FWAppBundle.pickerCheckImage;
        [FWImagePickerCollectionCell appearance].checkboxCheckedImage = FWAppBundle.pickerCheckedImage;
        [FWImagePickerCollectionCell appearance].checkboxButtonMargins = UIEdgeInsetsMake(6, 6, 6, 6);
        [FWImagePickerCollectionCell appearance].videoDurationLabelFont = [UIFont systemFontOfSize:12];
        [FWImagePickerCollectionCell appearance].videoDurationLabelTextColor = UIColor.whiteColor;
        [FWImagePickerCollectionCell appearance].videoDurationLabelMargins = UIEdgeInsetsMake(5, 5, 5, 7);
    });
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initImagePickerCollectionViewCellUI];
    }
    return self;
}

- (void)initImagePickerCollectionViewCellUI {
    _contentImageView = [[UIImageView alloc] init];
    self.contentImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.contentImageView.clipsToBounds = YES;
    [self.contentView addSubview:self.contentImageView];
    
    self.checkboxButton = [[UIButton alloc] init];
    self.checkboxButton.fwTouchInsets = UIEdgeInsetsMake(6, 6, 6, 6);
    self.checkboxButton.hidden = YES;
    [self.contentView addSubview:self.checkboxButton];
}

- (void)renderWithAsset:(FWAsset *)asset referenceSize:(CGSize)referenceSize {
    self.assetIdentifier = asset.identifier;
    
    // 异步请求资源对应的缩略图
    [asset requestThumbnailImageWithSize:referenceSize completion:^(UIImage *result, NSDictionary *info) {
        if ([self.assetIdentifier isEqualToString:asset.identifier]) {
            self.contentImageView.image = result;
        } else {
            self.contentImageView.image = nil;
        }
    }];
    
    if (asset.assetType == FWAssetTypeVideo) {
        [self initVideoDurationLabelIfNeeded];
        NSUInteger min = floor(asset.duration / 60);
        NSUInteger sec = floor(asset.duration - min * 60);
        self.videoDurationLabel.text = [NSString stringWithFormat:@"%02ld:%02ld", (long)min, (long)sec];
        self.videoDurationLabel.hidden = NO;
    } else {
        self.videoDurationLabel.hidden = YES;
    }
    
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.contentImageView.frame = self.contentView.bounds;
    if (_selectable) {
        self.checkboxButton.fwOrigin = CGPointMake(CGRectGetWidth(self.contentView.bounds) - self.checkboxButtonMargins.right - CGRectGetWidth(self.checkboxButton.bounds), self.checkboxButtonMargins.top);
    }
    
    if (self.videoDurationLabel && !self.videoDurationLabel.hidden) {
        [self.videoDurationLabel sizeToFit];
        self.videoDurationLabel.fwOrigin = CGPointMake(CGRectGetWidth(self.contentView.bounds) - self.videoDurationLabelMargins.right - CGRectGetWidth(self.videoDurationLabel.frame), CGRectGetHeight(self.contentView.bounds) - self.videoDurationLabelMargins.bottom - CGRectGetHeight(self.videoDurationLabel.frame));
    }
}

- (void)setCheckboxImage:(UIImage *)checkboxImage {
    if (![self.checkboxImage isEqual:checkboxImage]) {
        [self.checkboxButton setImage:checkboxImage forState:UIControlStateNormal];
        [self.checkboxButton sizeToFit];
        [self setNeedsLayout];
    }
    _checkboxImage = checkboxImage;
}

- (void)setCheckboxCheckedImage:(UIImage *)checkboxCheckedImage {
    if (![self.checkboxCheckedImage isEqual:checkboxCheckedImage]) {
        [self.checkboxButton setImage:checkboxCheckedImage forState:UIControlStateSelected];
        [self.checkboxButton setImage:checkboxCheckedImage forState:UIControlStateSelected|UIControlStateHighlighted];
        [self.checkboxButton sizeToFit];
        [self setNeedsLayout];
    }
    _checkboxCheckedImage = checkboxCheckedImage;
}

- (void)setVideoDurationLabelFont:(UIFont *)videoDurationLabelFont {
    if (![self.videoDurationLabelFont isEqual:videoDurationLabelFont]) {
        _videoDurationLabel.font = videoDurationLabelFont;
        _videoDurationLabel.text = @"测";
        [_videoDurationLabel sizeToFit];
        _videoDurationLabel.text = nil;
        [self setNeedsLayout];
    }
    _videoDurationLabelFont = videoDurationLabelFont;
}

- (void)setVideoDurationLabelTextColor:(UIColor *)videoDurationLabelTextColor {
    if (![self.videoDurationLabelTextColor isEqual:videoDurationLabelTextColor]) {
        _videoDurationLabel.textColor = videoDurationLabelTextColor;
    }
    _videoDurationLabelTextColor = videoDurationLabelTextColor;
}

- (void)setChecked:(BOOL)checked {
    _checked = checked;
    if (_selectable) {
        self.checkboxButton.selected = checked;
    }
}

- (void)setSelectable:(BOOL)editing {
    _selectable = editing;
    if (self.downloadStatus == FWAssetDownloadStatusSucceed) {
        self.checkboxButton.hidden = !_selectable;
    }
}

- (void)setDownloadStatus:(FWAssetDownloadStatus)downloadStatus {
    _downloadStatus = downloadStatus;
    if (_selectable) {
        self.checkboxButton.hidden = !_selectable;
    }
}

- (void)initVideoDurationLabelIfNeeded {
    if (!self.videoDurationLabel) {
        _videoDurationLabel = [[UILabel alloc] init];
        _videoDurationLabel.font = self.videoDurationLabelFont;
        _videoDurationLabel.textColor = self.videoDurationLabelTextColor;
        [self.contentView addSubview:_videoDurationLabel];
        [self setNeedsLayout];
    }
}

@end

#pragma mark - FWImagePickerPreviewController

@implementation FWImagePickerPreviewController {
    BOOL _singleCheckMode;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.maximumSelectImageCount = INT_MAX;
        self.minimumSelectImageCount = 0;
        
        self.toolBarBackgroundColor = [UIColor colorWithRed:27/255.f green:27/255.f blue:27/255.f alpha:.9f];
        self.toolBarTintColor = UIColor.whiteColor;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.imagePreviewView.delegate = self;
    
    _topToolBarView = [[UIView alloc] init];
    self.topToolBarView.backgroundColor = self.toolBarBackgroundColor;
    self.topToolBarView.tintColor = self.toolBarTintColor;
    [self.view addSubview:self.topToolBarView];
    
    _backButton = [[FWNavigationButton alloc] initWithTitle:@"返回"];
    [self.backButton addTarget:self action:@selector(handleCancelPreviewImage:) forControlEvents:UIControlEventTouchUpInside];
    self.backButton.fwTouchInsets = UIEdgeInsetsMake(30, 20, 50, 80);
    [self.topToolBarView addSubview:self.backButton];
    
    _checkboxButton = [[UIButton alloc] init];
    UIImage *checkboxImage = FWAppBundle.pickerCheckImage;
    UIImage *checkedCheckboxImage = FWAppBundle.pickerCheckedImage;
    [self.checkboxButton setImage:checkboxImage forState:UIControlStateNormal];
    [self.checkboxButton setImage:checkedCheckboxImage forState:UIControlStateSelected];
    [self.checkboxButton setImage:[self.checkboxButton imageForState:UIControlStateSelected] forState:UIControlStateSelected|UIControlStateHighlighted];
    [self.checkboxButton sizeToFit];
    [self.checkboxButton addTarget:self action:@selector(handleCheckButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    self.checkboxButton.fwTouchInsets = UIEdgeInsetsMake(6, 6, 6, 6);
    [self.topToolBarView addSubview:self.checkboxButton];
    
    _bottomToolBarView = [[UIView alloc] init];
    self.bottomToolBarView.backgroundColor = self.toolBarBackgroundColor;
    [self.view addSubview:self.bottomToolBarView];
    
    _editButton = [[UIButton alloc] init];
    self.editButton.hidden = !self.showsEditButton;
    self.editButton.fwTouchInsets = UIEdgeInsetsMake(6, 6, 6, 6);
    [self.editButton setTitle:@"编辑" forState:UIControlStateNormal];
    self.editButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [self.editButton sizeToFit];
    [self.editButton addTarget:self action:@selector(handleEditButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomToolBarView addSubview:self.editButton];
    
    _sendButton = [[UIButton alloc] init];
    self.sendButton.fwTouchInsets = UIEdgeInsetsMake(6, 6, 6, 6);
    [self.sendButton setTitle:@"发送" forState:UIControlStateNormal];
    self.sendButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [self.sendButton sizeToFit];
    [self.sendButton addTarget:self action:@selector(handleSendButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomToolBarView addSubview:self.sendButton];
    
    _imageCountLabel = [[UILabel alloc] init];
    _imageCountLabel.backgroundColor = self.toolBarTintColor;
    _imageCountLabel.textColor = UIColor.redColor;
    _imageCountLabel.font = [UIFont systemFontOfSize:12];
    _imageCountLabel.textAlignment = NSTextAlignmentCenter;
    _imageCountLabel.lineBreakMode = NSLineBreakByCharWrapping;
    _imageCountLabel.layer.masksToBounds = YES;
    _imageCountLabel.layer.cornerRadius = 18.0 / 2;
    _imageCountLabel.hidden = YES;
    [self.bottomToolBarView addSubview:_imageCountLabel];
    
    _originImageCheckboxButton = [[UIButton alloc] init];
    self.originImageCheckboxButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [self.originImageCheckboxButton setImage:FWAppBundle.pickerCheckImage forState:UIControlStateNormal];
    [self.originImageCheckboxButton setImage:FWAppBundle.pickerCheckedImage forState:UIControlStateSelected];
    [self.originImageCheckboxButton setImage:FWAppBundle.pickerCheckedImage forState:UIControlStateSelected|UIControlStateHighlighted];
    [self.originImageCheckboxButton setTitle:@"原图" forState:UIControlStateNormal];
    [self.originImageCheckboxButton setImageEdgeInsets:UIEdgeInsetsMake(0, -5.0f, 0, 5.0f)];
    [self.originImageCheckboxButton setContentEdgeInsets:UIEdgeInsetsMake(0, 5.0f, 0, 0)];
    [self.originImageCheckboxButton sizeToFit];
    self.originImageCheckboxButton.fwTouchInsets = UIEdgeInsetsMake(6.0f, 6.0f, 6.0f, 6.0f);
    [self.originImageCheckboxButton addTarget:self action:@selector(handleOriginImageCheckboxButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomToolBarView addSubview:self.originImageCheckboxButton];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (!_singleCheckMode) {
        FWAsset *imageAsset = self.imagesAssetArray[self.imagePreviewView.currentImageIndex];
        self.checkboxButton.selected = [self.selectedImageAssetArray containsObject:imageAsset];
    }
    
    [self updateOriginImageCheckboxButtonWithIndex:self.imagePreviewView.currentImageIndex];
    if ([self.selectedImageAssetArray count] > 0) {
        NSUInteger selectedCount = [self.selectedImageAssetArray count];
        _imageCountLabel.text = [[NSString alloc] initWithFormat:@"%@", @(selectedCount)];
        _imageCountLabel.hidden = NO;
    } else {
        _imageCountLabel.hidden = YES;
    }
    
    // TODO：导航栏样式
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.topToolBarView.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), FWTopBarHeight);
    CGFloat topToolbarPaddingTop = UIScreen.fwSafeAreaInsets.top;
    CGFloat topToolbarContentHeight = CGRectGetHeight(self.topToolBarView.bounds) - topToolbarPaddingTop;
    self.backButton.fwOrigin = CGPointMake(16 + self.view.safeAreaInsets.left, topToolbarPaddingTop + (topToolbarContentHeight - CGRectGetHeight(self.backButton.frame)) / 2.0);
    if (!self.checkboxButton.hidden) {
        self.checkboxButton.fwOrigin = CGPointMake(CGRectGetWidth(self.topToolBarView.frame) - 10 - self.view.safeAreaInsets.right - CGRectGetWidth(self.checkboxButton.frame), topToolbarPaddingTop + (topToolbarContentHeight - CGRectGetHeight(self.checkboxButton.frame)) / 2.0);
    }
    
    CGFloat bottomToolBarPaddingHorizontal = 12.0f;
    CGFloat bottomToolBarContentHeight = 44;
    CGSize imageCountLabelSize = CGSizeMake(18, 18);
    CGFloat bottomToolBarHeight = bottomToolBarContentHeight + self.view.safeAreaInsets.bottom;
    self.bottomToolBarView.frame = CGRectMake(0, CGRectGetHeight(self.view.bounds) - bottomToolBarHeight, CGRectGetWidth(self.view.bounds), bottomToolBarHeight);
    self.sendButton.fwOrigin = CGPointMake(CGRectGetWidth(self.bottomToolBarView.frame) - bottomToolBarPaddingHorizontal - CGRectGetWidth(self.sendButton.frame), (bottomToolBarContentHeight - CGRectGetHeight(self.sendButton.frame)) / 2.0);
    _imageCountLabel.frame = CGRectMake(CGRectGetMinX(self.sendButton.frame) - 5 - imageCountLabelSize.width, CGRectGetMinY(self.sendButton.frame) + (CGRectGetHeight(self.sendButton.frame) - imageCountLabelSize.height) / 2.0, imageCountLabelSize.width, imageCountLabelSize.height);
    
    self.editButton.fwOrigin = CGPointMake(bottomToolBarPaddingHorizontal, (bottomToolBarContentHeight - CGRectGetHeight(self.editButton.frame)) / 2.0);
    if (self.showsEditButton) {
        self.originImageCheckboxButton.fwOrigin = CGPointMake((CGRectGetWidth(self.bottomToolBarView.frame) - CGRectGetWidth(self.originImageCheckboxButton.frame)) / 2.0, (bottomToolBarContentHeight - CGRectGetHeight(self.originImageCheckboxButton.frame)) / 2.0);
    } else {
        self.originImageCheckboxButton.fwOrigin = CGPointMake(bottomToolBarPaddingHorizontal, (bottomToolBarContentHeight - CGRectGetHeight(self.originImageCheckboxButton.frame)) / 2.0);
    }
}

- (BOOL)preferredNavigationBarHidden {
    return YES;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)setToolBarBackgroundColor:(UIColor *)toolBarBackgroundColor {
    _toolBarBackgroundColor = toolBarBackgroundColor;
    self.topToolBarView.backgroundColor = self.toolBarBackgroundColor;
    self.bottomToolBarView.backgroundColor = self.toolBarBackgroundColor;
}

- (void)setToolBarTintColor:(UIColor *)toolBarTintColor {
    _toolBarTintColor = toolBarTintColor;
    self.topToolBarView.tintColor = toolBarTintColor;
    self.bottomToolBarView.tintColor = toolBarTintColor;
    _imageCountLabel.backgroundColor = toolBarTintColor;
    _imageCountLabel.textColor = [UIColor redColor];
}

- (void)setShowsEditButton:(BOOL)showsEditButton {
    _showsEditButton = showsEditButton;
    self.editButton.hidden = !showsEditButton;
}

- (void)setDownloadStatus:(FWAssetDownloadStatus)downloadStatus {
    _downloadStatus = downloadStatus;
    if (!_singleCheckMode) {
        self.checkboxButton.hidden = NO;
    }
}

- (void)updateImagePickerPreviewViewWithImagesAssetArray:(NSMutableArray<FWAsset *> *)imageAssetArray
                                 selectedImageAssetArray:(NSMutableArray<FWAsset *> *)selectedImageAssetArray
                                       currentImageIndex:(NSInteger)currentImageIndex
                                         singleCheckMode:(BOOL)singleCheckMode {
    self.imagesAssetArray = imageAssetArray;
    self.selectedImageAssetArray = selectedImageAssetArray;
    self.imagePreviewView.currentImageIndex = currentImageIndex;
    _singleCheckMode = singleCheckMode;
    if (singleCheckMode) {
        self.checkboxButton.hidden = YES;
    }
}

#pragma mark - <FWImagePreviewViewDelegate>

- (NSInteger)numberOfImagesInImagePreviewView:(FWImagePreviewView *)imagePreviewView {
    return [self.imagesAssetArray count];
}

- (FWImagePreviewMediaType)imagePreviewView:(FWImagePreviewView *)imagePreviewView assetTypeAtIndex:(NSInteger)index {
    FWAsset *imageAsset = [self.imagesAssetArray objectAtIndex:index];
    if (imageAsset.assetType == FWAssetTypeImage) {
        if (imageAsset.assetSubType == FWAssetSubTypeLivePhoto) {
            return FWImagePreviewMediaTypeLivePhoto;
        }
        return FWImagePreviewMediaTypeImage;
    } else if (imageAsset.assetType == FWAssetTypeVideo) {
        return FWImagePreviewMediaTypeVideo;
    } else {
        return FWImagePreviewMediaTypeOthers;
    }
}

- (void)imagePreviewView:(FWImagePreviewView *)imagePreviewView renderZoomImageView:(FWZoomImageView *)zoomImageView atIndex:(NSInteger)index {
    [self requestImageForZoomImageView:zoomImageView withIndex:index];
    
    UIEdgeInsets insets = zoomImageView.videoToolbarMargins;
    insets.bottom = [FWZoomImageView appearance].videoToolbarMargins.bottom + CGRectGetHeight(self.bottomToolBarView.frame) - imagePreviewView.safeAreaInsets.bottom;
    zoomImageView.videoToolbarMargins = insets;// videToolbarMargins 是利用 UIAppearance 赋值的，也即意味着要在 addSubview 之后才会被赋值，而在 renderZoomImageView 里，zoomImageView 可能尚未被添加到 view 层级里，所以无法通过 zoomImageView.videoToolbarMargins 获取到原来的值，因此只能通过 [FWZoomImageView appearance] 的方式获取
}

- (void)imagePreviewView:(FWImagePreviewView *)imagePreviewView willScrollHalfToIndex:(NSInteger)index {
    if (!_singleCheckMode) {
        FWAsset *imageAsset = self.imagesAssetArray[index];
        self.checkboxButton.selected = [self.selectedImageAssetArray containsObject:imageAsset];
    }
    
    [self updateOriginImageCheckboxButtonWithIndex:index];
}

#pragma mark - <FWZoomImageViewDelegate>

- (void)singleTouchInZoomingImageView:(FWZoomImageView *)zoomImageView location:(CGPoint)location {
    self.topToolBarView.hidden = !self.topToolBarView.hidden;
    self.bottomToolBarView.hidden = !self.bottomToolBarView.hidden;
}

- (void)zoomImageView:(FWZoomImageView *)imageView didHideVideoToolbar:(BOOL)didHide {
    self.topToolBarView.hidden = didHide;
    self.bottomToolBarView.hidden = didHide;
}

#pragma mark - 按钮点击回调

- (void)handleCancelPreviewImage:(UIButton *)button {
    if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(imagePickerPreviewControllerDidCancel:)]) {
        [self.delegate imagePickerPreviewControllerDidCancel:self];
    }
}

- (void)handleCheckButtonClick:(UIButton *)button {
    if (button.selected) {
        if ([self.delegate respondsToSelector:@selector(imagePickerPreviewController:willUncheckImageAtIndex:)]) {
            [self.delegate imagePickerPreviewController:self willUncheckImageAtIndex:self.imagePreviewView.currentImageIndex];
        }
        
        button.selected = NO;
        FWAsset *imageAsset = self.imagesAssetArray[self.imagePreviewView.currentImageIndex];
        [self.selectedImageAssetArray removeObject:imageAsset];
        
        if ([self.delegate respondsToSelector:@selector(imagePickerPreviewController:didUncheckImageAtIndex:)]) {
            [self.delegate imagePickerPreviewController:self didUncheckImageAtIndex:self.imagePreviewView.currentImageIndex];
        }
    } else {
        if ([self.selectedImageAssetArray count] >= self.maximumSelectImageCount) {
            if (!self.alertTitleWhenExceedMaxSelectImageCount) {
                self.alertTitleWhenExceedMaxSelectImageCount = [NSString stringWithFormat:@"你最多只能选择%@张图片", @(self.maximumSelectImageCount)];
            }
            if (!self.alertButtonTitleWhenExceedMaxSelectImageCount) {
                self.alertButtonTitleWhenExceedMaxSelectImageCount = [NSString stringWithFormat:@"我知道了"];
            }
            
            [self fwShowAlertWithTitle:self.alertTitleWhenExceedMaxSelectImageCount message:nil cancel:self.alertButtonTitleWhenExceedMaxSelectImageCount cancelBlock:nil];
            return;
        }
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(imagePickerPreviewController:willCheckImageAtIndex:)]) {
            [self.delegate imagePickerPreviewController:self willCheckImageAtIndex:self.imagePreviewView.currentImageIndex];
        }
        
        button.selected = YES;
        FWAsset *imageAsset = [self.imagesAssetArray objectAtIndex:self.imagePreviewView.currentImageIndex];
        [self.selectedImageAssetArray addObject:imageAsset];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(imagePickerPreviewController:didCheckImageAtIndex:)]) {
            [self.delegate imagePickerPreviewController:self didCheckImageAtIndex:self.imagePreviewView.currentImageIndex];
        }
    }
}

- (void)handleEditButtonClick:(id)sender {
    FWAsset *currentAsset = self.imagesAssetArray[self.imagePreviewView.currentImageIndex];
    UIImage *image;
    if (currentAsset.editedImage) {
        image = currentAsset.editedImage;
    } else {
        image = self.shouldUseOriginImage ? currentAsset.originImage : currentAsset.previewImage;
    }
    if (!image) return;
    
    FWImageCropController *cropController;
    if (self.delegate && [self.delegate respondsToSelector:@selector(imageCropControllerForPreviewController:image:)]) {
        cropController = [self.delegate imageCropControllerForPreviewController:self image:image];
    } else {
        cropController = [[FWImageCropController alloc] initWithImage:image];
    }
    __weak __typeof__(self) self_weak_ = self;
    cropController.onDidCropToRect = ^(UIImage * _Nonnull image, CGRect cropRect, NSInteger angle) {
        __typeof__(self) self = self_weak_;
        currentAsset.editedImage = image;
        [self.presentedViewController dismissViewControllerAnimated:NO completion:nil];
    };
    cropController.onDidFinishCancelled = ^(BOOL isFinished) {
        __typeof__(self) self = self_weak_;
        [self.presentedViewController dismissViewControllerAnimated:NO completion:nil];
    };
    [self presentViewController:cropController animated:NO completion:nil];
}

- (void)handleSendButtonClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^(void) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(imagePickerPreviewController:didFinishPickingImageWithImagesAssetArray:)]) {
            if (self.selectedImageAssetArray.count == 0) {
                // 如果没选中任何一张，则点击发送按钮直接发送当前这张大图
                FWAsset *currentAsset = self.imagesAssetArray[self.imagePreviewView.currentImageIndex];
                [self.selectedImageAssetArray addObject:currentAsset];
            }
            [self.delegate imagePickerPreviewController:self didFinishPickingImageWithImagesAssetArray:self.selectedImageAssetArray];
        }
    }];
}

- (void)handleOriginImageCheckboxButtonClick:(UIButton *)button {
    if (button.selected) {
        button.selected = NO;
        [button setTitle:@"原图" forState:UIControlStateNormal];
        [button sizeToFit];
        [self.bottomToolBarView setNeedsLayout];
    } else {
        button.selected = YES;
        [self updateOriginImageCheckboxButtonWithIndex:self.imagePreviewView.currentImageIndex];
        if (!self.checkboxButton.selected) {
            [self.checkboxButton sendActionsForControlEvents:UIControlEventTouchUpInside];
        }

    }
    self.shouldUseOriginImage = button.selected;
}

- (void)updateOriginImageCheckboxButtonWithIndex:(NSInteger)index {
    FWAsset *asset = self.imagesAssetArray[index];
    if (asset.assetType == FWAssetTypeAudio || asset.assetType == FWAssetTypeVideo) {
        self.originImageCheckboxButton.hidden = YES;
        if (self.showsEditButton) {
            self.editButton.hidden = YES;
        }
    } else {
        self.originImageCheckboxButton.hidden = NO;
        if (self.originImageCheckboxButton.selected) {
            [asset assetSize:^(long long size) {
                [self.originImageCheckboxButton setTitle:[NSString stringWithFormat:@"原图(%@)", [NSString fwSizeString:size]] forState:UIControlStateNormal];
                [self.originImageCheckboxButton sizeToFit];
                [self.bottomToolBarView setNeedsLayout];
            }];
        }
        if (self.showsEditButton) {
            self.editButton.hidden = NO;
        }
    }
}

- (void)updateSelectedCollectionView {
    
}

#pragma mark - Request Image

- (void)requestImageForZoomImageView:(FWZoomImageView *)zoomImageView withIndex:(NSInteger)index {
    FWZoomImageView *imageView = zoomImageView ? : [self.imagePreviewView zoomImageViewAtIndex:index];
    // 如果是走 PhotoKit 的逻辑，那么这个 block 会被多次调用，并且第一次调用时返回的图片是一张小图，
    // 拉取图片的过程中可能会多次返回结果，且图片尺寸越来越大，因此这里调整 contentMode 以防止图片大小跳动
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    FWAsset *imageAsset = [self.imagesAssetArray objectAtIndex:index];
    if (imageAsset.editedImage) {
        imageView.image = imageAsset.editedImage;
        return;
    }
    
    // 获取资源图片的预览图，这是一张适合当前设备屏幕大小的图片，最终展示时把图片交给组件控制最终展示出来的大小。
    // 系统相册本质上也是这么处理的，因此无论是系统相册，还是这个系列组件，由始至终都没有显示照片原图，
    // 这也是系统相册能加载这么快的原因。
    // 另外这里采用异步请求获取图片，避免获取图片时 UI 卡顿
    PHAssetImageProgressHandler phProgressHandler = ^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
        imageAsset.downloadProgress = progress;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.downloadStatus != FWAssetDownloadStatusDownloading) {
                self.downloadStatus = FWAssetDownloadStatusDownloading;
                imageView.progress = 0;
            }
            // 拉取资源的初期，会有一段时间没有进度，猜测是发出网络请求以及与 iCloud 建立连接的耗时，这时预先给个 0.02 的进度值，看上去好看些
            float targetProgress = fmax(0.02, progress);
            if (targetProgress < imageView.progress) {
                imageView.progress = targetProgress;
            } else {
                imageView.progress = fmax(0.02, progress);
            }
            if (error) {
                self.downloadStatus = FWAssetDownloadStatusFailed;
                imageView.progress = 0;
            }
        });
    };
    if (imageAsset.assetType == FWAssetTypeVideo) {
        imageView.tag = -1;
        imageAsset.requestID = [imageAsset requestPlayerItemWithCompletion:^(AVPlayerItem *playerItem, NSDictionary *info) {
            // 这里可能因为 imageView 复用，导致前面的请求得到的结果显示到别的 imageView 上，
            // 因此判断如果是新请求（无复用问题）或者是当前的请求才把获得的图片结果展示出来
            dispatch_async(dispatch_get_main_queue(), ^{
                BOOL isNewRequest = (imageView.tag == -1 && imageAsset.requestID == 0);
                BOOL isCurrentRequest = imageView.tag == imageAsset.requestID;
                BOOL loadICloudImageFault = !playerItem || info[PHImageErrorKey];
                if (!loadICloudImageFault && (isNewRequest || isCurrentRequest)) {
                    imageView.videoPlayerItem = playerItem;
                }
            });
        } withProgressHandler:phProgressHandler];
        imageView.tag = imageAsset.requestID;
    } else {
        if (imageAsset.assetType != FWAssetTypeImage) {
            return;
        }
        
        // 这么写是为了消除 Xcode 的 API available warning
        BOOL isLivePhoto = NO;
        if (imageAsset.assetSubType == FWAssetSubTypeLivePhoto) {
            isLivePhoto = YES;
            imageView.tag = -1;
            imageAsset.requestID = [imageAsset requestLivePhotoWithCompletion:^void(PHLivePhoto *livePhoto, NSDictionary *info) {
                // 这里可能因为 imageView 复用，导致前面的请求得到的结果显示到别的 imageView 上，
                // 因此判断如果是新请求（无复用问题）或者是当前的请求才把获得的图片结果展示出来
                dispatch_async(dispatch_get_main_queue(), ^{
                    BOOL isNewRequest = (imageView.tag == -1 && imageAsset.requestID == 0);
                    BOOL isCurrentRequest = imageView.tag == imageAsset.requestID;
                    BOOL loadICloudImageFault = !livePhoto || info[PHImageErrorKey];
                    if (!loadICloudImageFault && (isNewRequest || isCurrentRequest)) {
                        // 如果是走 PhotoKit 的逻辑，那么这个 block 会被多次调用，并且第一次调用时返回的图片是一张小图，
                        // 这时需要把图片放大到跟屏幕一样大，避免后面加载大图后图片的显示会有跳动
                        imageView.livePhoto = livePhoto;
                    }
                    BOOL downloadSucceed = (livePhoto && !info) || (![[info objectForKey:PHLivePhotoInfoCancelledKey] boolValue] && ![info objectForKey:PHLivePhotoInfoErrorKey] && ![[info objectForKey:PHLivePhotoInfoIsDegradedKey] boolValue]);
                    if (downloadSucceed) {
                        // 资源资源已经在本地或下载成功
                        [imageAsset updateDownloadStatusWithDownloadResult:YES];
                        self.downloadStatus = FWAssetDownloadStatusSucceed;
                        imageView.progress = 1;
                    } else if ([info objectForKey:PHLivePhotoInfoErrorKey] ) {
                        // 下载错误
                        [imageAsset updateDownloadStatusWithDownloadResult:NO];
                        self.downloadStatus = FWAssetDownloadStatusFailed;
                        imageView.progress = 0;
                    }
                });
            } withProgressHandler:phProgressHandler];
            imageView.tag = imageAsset.requestID;
        }
        
        if (isLivePhoto) {
        } else if (imageAsset.assetSubType == FWAssetSubTypeGIF) {
            [imageAsset requestImageDataWithCompletion:^(NSData *imageData, NSDictionary<NSString *,id> *info, BOOL isGIF, BOOL isHEIC) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    UIImage *resultImage = [UIImage fwImageWithData:imageData];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        imageView.image = resultImage;
                    });
                });
            }];
        } else {
            imageView.tag = -1;
            // TODO
            CGFloat minimumImageWidth = 75;
            imageView.image = [imageAsset thumbnailWithSize:CGSizeMake(minimumImageWidth, minimumImageWidth)];
            imageAsset.requestID = [imageAsset requestOriginImageWithCompletion:^void(UIImage *result, NSDictionary *info) {
                // 这里可能因为 imageView 复用，导致前面的请求得到的结果显示到别的 imageView 上，
                // 因此判断如果是新请求（无复用问题）或者是当前的请求才把获得的图片结果展示出来
                dispatch_async(dispatch_get_main_queue(), ^{
                    BOOL isNewRequest = (imageView.tag == -1 && imageAsset.requestID == 0);
                    BOOL isCurrentRequest = imageView.tag == imageAsset.requestID;
                    BOOL loadICloudImageFault = !result || info[PHImageErrorKey];
                    if (!loadICloudImageFault && (isNewRequest || isCurrentRequest)) {
                        imageView.image = result;
                    }
                    BOOL downloadSucceed = (result && !info) || (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue]);
                    if (downloadSucceed) {
                        // 资源资源已经在本地或下载成功
                        [imageAsset updateDownloadStatusWithDownloadResult:YES];
                        self.downloadStatus = FWAssetDownloadStatusSucceed;
                        imageView.progress = 1;
                    } else if ([info objectForKey:PHImageErrorKey] ) {
                        // 下载错误
                        [imageAsset updateDownloadStatusWithDownloadResult:NO];
                        self.downloadStatus = FWAssetDownloadStatusFailed;
                        imageView.progress = 0;
                    }
                });
            } withProgressHandler:phProgressHandler];
            imageView.tag = imageAsset.requestID;
        }
    }
}

@end

#pragma mark - FWImagePickerController

static NSString * const kVideoCellIdentifier = @"video";
static NSString * const kImageOrUnknownCellIdentifier = @"imageorunknown";

#pragma mark - FWImagePickerController

@interface FWImagePickerController ()

@property(nonatomic, strong) FWImagePickerPreviewController *imagePickerPreviewController;
@property(nonatomic, assign) BOOL isImagesAssetLoaded;// 这个属性的作用描述：https://github.com/Tencent/FW_iOS/issues/219
@property(nonatomic, assign) BOOL hasScrollToInitialPosition;
@property(nonatomic, assign) BOOL canScrollToInitialPosition;// 要等数据加载完才允许滚动
@end

@implementation FWImagePickerController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [self didInitialize];
    }
    return self;
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self didInitialize];
    }
    return self;
}

- (void)didInitialize {
    self.minimumImageWidth = 75;

    _allowsMultipleSelection = YES;
    _maximumSelectImageCount = INT_MAX;
    _minimumSelectImageCount = 0;
    _shouldShowDefaultLoadingView = YES;
}

- (void)dealloc {
    _collectionView.dataSource = nil;
    _collectionView.delegate = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem fwBarItemWithObject:@"取消" target:self action:@selector(handleCancelPickerImage:)];
    
    self.view.backgroundColor = UIColor.whiteColor;
    [self.view addSubview:self.collectionView];
    if (self.allowsMultipleSelection) {
        [self.view addSubview:self.operationToolBarView];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // 由于被选中的图片 selectedImageAssetArray 是 property，所以可以由外部改变，
    // 因此 viewWillAppear 时检查一下图片被选中的情况，并刷新 collectionView
    if (self.allowsMultipleSelection) {
        [self updateImageCountAndCheckLimited];
    }
    [self.collectionView reloadData];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CGFloat operationToolBarViewHeight = 0;
    if (self.allowsMultipleSelection) {
        operationToolBarViewHeight = FWToolBarHeight;
        CGFloat toolbarPaddingHorizontal = 12;
        self.operationToolBarView.frame = CGRectMake(0, CGRectGetHeight(self.view.bounds) - operationToolBarViewHeight, CGRectGetWidth(self.view.bounds), operationToolBarViewHeight);
        self.previewButton.fwOrigin = CGPointMake(toolbarPaddingHorizontal, (CGRectGetHeight(self.operationToolBarView.bounds) - UIScreen.fwSafeAreaInsets.bottom - CGRectGetHeight(self.previewButton.frame)) / 2.0);
        self.sendButton.frame = CGRectMake(CGRectGetWidth(self.operationToolBarView.bounds) - toolbarPaddingHorizontal - CGRectGetWidth(self.sendButton.frame), (CGRectGetHeight(self.operationToolBarView.frame) - UIScreen.fwSafeAreaInsets.bottom - CGRectGetHeight(self.sendButton.frame)) / 2.0, CGRectGetWidth(self.sendButton.frame), CGRectGetHeight(self.sendButton.frame));
        CGSize imageCountLabelSize = CGSizeMake(18, 18);
        self.imageCountLabel.frame = CGRectMake(CGRectGetMinX(self.sendButton.frame) - imageCountLabelSize.width - 5, CGRectGetMinY(self.sendButton.frame) + (CGRectGetHeight(self.sendButton.frame) - imageCountLabelSize.height) / 2.0, imageCountLabelSize.width, imageCountLabelSize.height);
        self.imageCountLabel.layer.cornerRadius = CGRectGetHeight(self.imageCountLabel.bounds) / 2;
        operationToolBarViewHeight = CGRectGetHeight(self.operationToolBarView.frame);
    }
    
    if (!CGSizeEqualToSize(self.collectionView.frame.size, self.view.bounds.size)) {
        self.collectionView.frame = self.view.bounds;
    }
    UIEdgeInsets contentInset = UIEdgeInsetsMake(FWTopBarHeight, self.collectionView.safeAreaInsets.left, MAX(operationToolBarViewHeight, self.collectionView.safeAreaInsets.bottom), self.collectionView.safeAreaInsets.right);
    if (!UIEdgeInsetsEqualToEdgeInsets(self.collectionView.contentInset, contentInset)) {
        self.collectionView.contentInset = contentInset;
        self.collectionView.scrollIndicatorInsets = UIEdgeInsetsMake(contentInset.top, 0, contentInset.bottom, 0);
        // 放在这里是因为有时候会先走完 refreshWithAssetsGroup 里的 completion 再走到这里，此时前者不会导致 scollToInitialPosition 的滚动，所以在这里再调用一次保证一定会滚
        [self scrollToInitialPositionIfNeeded];
    }
}

- (void)refreshWithAssetsGroup:(FWAssetGroup *)assetsGroup {
    _assetsGroup = assetsGroup;
    if (!self.imagesAssetArray) {
        _imagesAssetArray = [[NSMutableArray alloc] init];
        _selectedImageAssetArray = [[NSMutableArray alloc] init];
    } else {
        [self.imagesAssetArray removeAllObjects];
        // 这里不用 remove 选中的图片，因为支持跨相簿选图
//        [self.selectedImageAssetArray removeAllObjects];
    }
    // 通过 FWAssetGroup 获取该相册所有的图片 FWAsset，并且储存到数组中
    FWAlbumSortType albumSortType = FWAlbumSortTypePositive;
    // 从 delegate 中获取相册内容的排序方式，如果没有实现这个 delegate，则使用 FWAlbumSortType 的默认值，即最新的内容排在最后面
    if (self.imagePickerControllerDelegate && [self.imagePickerControllerDelegate respondsToSelector:@selector(albumSortTypeForImagePickerController:)]) {
        albumSortType = [self.imagePickerControllerDelegate albumSortTypeForImagePickerController:self];
    }
    // 遍历相册内的资源较为耗时，交给子线程去处理，因此这里需要显示 Loading
    if ([self.imagePickerControllerDelegate respondsToSelector:@selector(imagePickerControllerWillStartLoading:)]) {
        [self.imagePickerControllerDelegate imagePickerControllerWillStartLoading:self];
    }
    if (self.shouldShowDefaultLoadingView) {
        [self fwShowLoading];
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [assetsGroup enumerateAssetsWithOptions:albumSortType usingBlock:^(FWAsset *resultAsset) {
            // 这里需要对 UI 进行操作，因此放回主线程处理
            dispatch_async(dispatch_get_main_queue(), ^{
                if (resultAsset) {
                    self.isImagesAssetLoaded = NO;
                    [self.imagesAssetArray addObject:resultAsset];
                } else {
                    // result 为 nil，即遍历相片或视频完毕
                    self.isImagesAssetLoaded = YES;// 这个属性的作用描述： https://github.com/Tencent/FW_iOS/issues/219
                    [self.collectionView reloadData];
                    [self.collectionView performBatchUpdates:^{
                    } completion:^(BOOL finished) {
                        [self scrollToInitialPositionIfNeeded];
                        if (self.shouldShowDefaultLoadingView) {
                          [self fwHideLoading];
                        }
                        if ([self.imagePickerControllerDelegate respondsToSelector:@selector(imagePickerControllerDidFinishLoading:)]) {
                            [self.imagePickerControllerDelegate imagePickerControllerDidFinishLoading:self];
                        }
                    }];
                }
            });
        }];
    });
}

- (void)initPreviewViewControllerIfNeeded {
    if (!self.imagePickerPreviewController) {
        self.imagePickerPreviewController = [self.imagePickerControllerDelegate imagePickerPreviewControllerForImagePickerController:self];
        self.imagePickerPreviewController.maximumSelectImageCount = self.maximumSelectImageCount;
        self.imagePickerPreviewController.minimumSelectImageCount = self.minimumSelectImageCount;
    }
}

- (CGSize)referenceImageSize {
    CGFloat collectionViewWidth = CGRectGetWidth(self.collectionView.bounds);
    CGFloat collectionViewContentSpacing = collectionViewWidth - (self.collectionView.contentInset.left + self.collectionView.contentInset.right) - (self.collectionViewLayout.sectionInset.left + self.collectionViewLayout.sectionInset.right);
    NSInteger columnCount = floor(collectionViewContentSpacing / self.minimumImageWidth);
    CGFloat referenceImageWidth = self.minimumImageWidth;
    BOOL isSpacingEnoughWhenDisplayInMinImageSize = (self.minimumImageWidth + self.collectionViewLayout.minimumInteritemSpacing) * columnCount - self.collectionViewLayout.minimumInteritemSpacing <= collectionViewContentSpacing;
    if (!isSpacingEnoughWhenDisplayInMinImageSize) {
        // 算上图片之间的间隙后发现其实还是放不下啦，所以得把列数减少，然后放大图片以撑满剩余空间
        columnCount -= 1;
    }
    referenceImageWidth = floor((collectionViewContentSpacing - self.collectionViewLayout.minimumInteritemSpacing * (columnCount - 1)) / columnCount);
    return CGSizeMake(referenceImageWidth, referenceImageWidth);
}

- (void)setMinimumImageWidth:(CGFloat)minimumImageWidth {
    _minimumImageWidth = minimumImageWidth;
    [self referenceImageSize];
    [self.collectionView.collectionViewLayout invalidateLayout];
}

- (void)scrollToInitialPositionIfNeeded {
    BOOL isVisible = YES;
    if (_collectionView.hidden || _collectionView.alpha <= 0.01) {
        isVisible = NO;
    }
    if (_collectionView.window) {
        isVisible = YES;
    }
    if (isVisible && self.isImagesAssetLoaded && !self.hasScrollToInitialPosition) {
        if ([self.imagePickerControllerDelegate respondsToSelector:@selector(albumSortTypeForImagePickerController:)] && [self.imagePickerControllerDelegate albumSortTypeForImagePickerController:self] == FWAlbumSortTypeReverse) {
            [_collectionView setContentOffset:CGPointMake(_collectionView.contentOffset.x, -_collectionView.adjustedContentInset.top) animated:NO];
        } else {
            [_collectionView setContentOffset:CGPointMake(_collectionView.contentOffset.x, _collectionView.contentSize.height - _collectionView.bounds.size.height + _collectionView.adjustedContentInset.bottom) animated:NO];
        }
        self.hasScrollToInitialPosition = YES;
    }
}

- (void)willPopInNavigationControllerWithAnimated:(BOOL)animated {
    self.hasScrollToInitialPosition = NO;
}

#pragma mark - Getters & Setters

@synthesize collectionViewLayout = _collectionViewLayout;
- (UICollectionViewFlowLayout *)collectionViewLayout {
    if (!_collectionViewLayout) {
        _collectionViewLayout = [[UICollectionViewFlowLayout alloc] init];
        CGFloat inset = [UIScreen fwPixelOne] * 2; // no why, just beautiful
        _collectionViewLayout.sectionInset = UIEdgeInsetsMake(inset, inset, inset, inset);
        _collectionViewLayout.minimumLineSpacing = _collectionViewLayout.sectionInset.bottom;
        _collectionViewLayout.minimumInteritemSpacing = _collectionViewLayout.sectionInset.left;
    }
    return _collectionViewLayout;
}

@synthesize collectionView = _collectionView;
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:self.isViewLoaded ? self.view.bounds : CGRectZero collectionViewLayout:self.collectionViewLayout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.alwaysBounceHorizontal = NO;
        _collectionView.backgroundColor = UIColor.clearColor;
        [_collectionView registerClass:[FWImagePickerCollectionCell class] forCellWithReuseIdentifier:kVideoCellIdentifier];
        [_collectionView registerClass:[FWImagePickerCollectionCell class] forCellWithReuseIdentifier:kImageOrUnknownCellIdentifier];
        _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    return _collectionView;
}

@synthesize operationToolBarView = _operationToolBarView;
- (UIView *)operationToolBarView {
    if (!_operationToolBarView) {
        _operationToolBarView = [[UIView alloc] init];
        _operationToolBarView.backgroundColor = UIColor.whiteColor;
        
        [_operationToolBarView addSubview:self.sendButton];
        [_operationToolBarView addSubview:self.previewButton];
        [_operationToolBarView addSubview:self.imageCountLabel];
    }
    return _operationToolBarView;
}

@synthesize sendButton = _sendButton;
- (UIButton *)sendButton {
    if (!_sendButton) {
        _sendButton = [[UIButton alloc] init];
        _sendButton.enabled = NO;
        _sendButton.titleLabel.font = [UIFont systemFontOfSize:16];
        _sendButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [_sendButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_sendButton setTitleColor:UIColor.grayColor forState:UIControlStateDisabled];
        [_sendButton setTitle:@"发送" forState:UIControlStateNormal];
        _sendButton.fwTouchInsets = UIEdgeInsetsMake(12, 20, 12, 20);
        [_sendButton sizeToFit];
        [_sendButton addTarget:self action:@selector(handleSendButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sendButton;
}

@synthesize previewButton = _previewButton;
- (UIButton *)previewButton {
    if (!_previewButton) {
        _previewButton = [[UIButton alloc] init];
        _previewButton.enabled = NO;
        _previewButton.titleLabel.font = self.sendButton.titleLabel.font;
        [_previewButton setTitleColor:[self.sendButton titleColorForState:UIControlStateNormal] forState:UIControlStateNormal];
        [_previewButton setTitleColor:[self.sendButton titleColorForState:UIControlStateDisabled] forState:UIControlStateDisabled];
        [_previewButton setTitle:@"预览" forState:UIControlStateNormal];
        _previewButton.fwTouchInsets = UIEdgeInsetsMake(12, 20, 12, 20);
        [_previewButton sizeToFit];
        [_previewButton addTarget:self action:@selector(handlePreviewButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _previewButton;
}

@synthesize imageCountLabel = _imageCountLabel;
- (UILabel *)imageCountLabel {
    if (!_imageCountLabel) {
        _imageCountLabel = [[UILabel alloc] init];
        _imageCountLabel.userInteractionEnabled = NO;// 不要影响 sendButton 的事件
        _imageCountLabel.backgroundColor = UIColor.clearColor;
        _imageCountLabel.textColor = UIColor.blackColor;
        _imageCountLabel.font = [UIFont systemFontOfSize:12];
        _imageCountLabel.textAlignment = NSTextAlignmentCenter;
        _imageCountLabel.lineBreakMode = NSLineBreakByCharWrapping;
        _imageCountLabel.layer.masksToBounds = YES;
        _imageCountLabel.hidden = YES;
    }
    return _imageCountLabel;
}

- (void)setAllowsMultipleSelection:(BOOL)allowsMultipleSelection {
    _allowsMultipleSelection = allowsMultipleSelection;
    if (self.isViewLoaded) {
        if (_allowsMultipleSelection) {
            [self.view addSubview:self.operationToolBarView];
        } else {
            [_operationToolBarView removeFromSuperview];
        }
    }
}

#pragma mark - <UICollectionViewDelegate, UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.imagesAssetArray count];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self referenceImageSize];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FWAsset *imageAsset = [self.imagesAssetArray objectAtIndex:indexPath.item];
    
    NSString *identifier = nil;
    if (imageAsset.assetType == FWAssetTypeVideo) {
        identifier = kVideoCellIdentifier;
    } else {
        identifier = kImageOrUnknownCellIdentifier;
    }
    FWImagePickerCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    [cell renderWithAsset:imageAsset referenceSize:[self referenceImageSize]];
    
    cell.checkboxButton.tag = indexPath.item;
    [cell.checkboxButton addTarget:self action:@selector(handleCheckBoxButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    cell.selectable = self.allowsMultipleSelection;
    if (cell.selectable) {
        // 如果该图片的 FWAsset 被包含在已选择图片的数组中，则控制该图片被选中
        cell.checked = [self.selectedImageAssetArray containsObject:imageAsset];
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    FWAsset *imageAsset = self.imagesAssetArray[indexPath.item];
    if ([self.imagePickerControllerDelegate respondsToSelector:@selector(imagePickerController:didSelectImageWithImagesAsset:afterImagePickerPreviewControllerUpdate:)]) {
        [self.imagePickerControllerDelegate imagePickerController:self didSelectImageWithImagesAsset:imageAsset afterImagePickerPreviewControllerUpdate:self.imagePickerPreviewController];
    }
    if ([self.imagePickerControllerDelegate respondsToSelector:@selector(imagePickerPreviewControllerForImagePickerController:)]) {
        [self initPreviewViewControllerIfNeeded];
        if (!self.allowsMultipleSelection) {
            // 单选的情况下
            [self.imagePickerPreviewController updateImagePickerPreviewViewWithImagesAssetArray:@[imageAsset].mutableCopy
                                                                        selectedImageAssetArray:nil
                                                                              currentImageIndex:0
                                                                                singleCheckMode:YES];
        } else {
            // cell 处于编辑状态，即图片允许多选
            [self.imagePickerPreviewController updateImagePickerPreviewViewWithImagesAssetArray:self.imagesAssetArray
                                                                        selectedImageAssetArray:self.selectedImageAssetArray
                                                                              currentImageIndex:indexPath.item
                                                                                singleCheckMode:NO];
        }
        [self.navigationController pushViewController:self.imagePickerPreviewController animated:YES];
    }
}

#pragma mark - 按钮点击回调

- (void)handleSendButtonClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^() {
        if (self.imagePickerControllerDelegate && [self.imagePickerControllerDelegate respondsToSelector:@selector(imagePickerController:didFinishPickingImageWithImagesAssetArray:)]) {
            [self.imagePickerControllerDelegate imagePickerController:self didFinishPickingImageWithImagesAssetArray:self.selectedImageAssetArray];
        }
        [self.selectedImageAssetArray removeAllObjects];
    }];
}

- (void)handlePreviewButtonClick:(id)sender {
    [self initPreviewViewControllerIfNeeded];
    // 手工更新图片预览界面
    [self.imagePickerPreviewController updateImagePickerPreviewViewWithImagesAssetArray:[self.selectedImageAssetArray copy]
                                                                selectedImageAssetArray:self.selectedImageAssetArray
                                                                      currentImageIndex:0
                                                                        singleCheckMode:NO];
    [self.navigationController pushViewController:self.imagePickerPreviewController animated:YES];
}

- (void)handleCancelPickerImage:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^() {
        if (self.imagePickerControllerDelegate && [self.imagePickerControllerDelegate respondsToSelector:@selector(imagePickerControllerDidCancel:)]) {
            [self.imagePickerControllerDelegate imagePickerControllerDidCancel:self];
        }
        [self.selectedImageAssetArray removeAllObjects];
    }];
}

- (void)handleCheckBoxButtonClick:(UIButton *)checkboxButton {
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:checkboxButton.tag inSection:0];
    if ([self.imagePickerControllerDelegate respondsToSelector:@selector(imagePickerController:shouldCheckImageAtIndex:)] && ![self.imagePickerControllerDelegate imagePickerController:self shouldCheckImageAtIndex:indexPath.item]) {
        return;
    }
    
    FWImagePickerCollectionCell *cell = (FWImagePickerCollectionCell *)[_collectionView cellForItemAtIndexPath:indexPath];
    FWAsset *imageAsset = [self.imagesAssetArray objectAtIndex:indexPath.item];
    if (cell.checked) {
        // 移除选中状态
        if ([self.imagePickerControllerDelegate respondsToSelector:@selector(imagePickerController:willUncheckImageAtIndex:)]) {
            [self.imagePickerControllerDelegate imagePickerController:self willUncheckImageAtIndex:indexPath.item];
        }
        
        cell.checked = NO;
        [self.selectedImageAssetArray removeObject:imageAsset];
        
        if ([self.imagePickerControllerDelegate respondsToSelector:@selector(imagePickerController:didUncheckImageAtIndex:)]) {
            [self.imagePickerControllerDelegate imagePickerController:self didUncheckImageAtIndex:indexPath.item];
        }
        
        // 根据选择图片数控制预览和发送按钮的 enable，以及修改已选中的图片数
        [self updateImageCountAndCheckLimited];
    } else {
        // 选中该资源
        if ([self.selectedImageAssetArray count] >= _maximumSelectImageCount) {
            if (!_alertTitleWhenExceedMaxSelectImageCount) {
                _alertTitleWhenExceedMaxSelectImageCount = [NSString stringWithFormat:@"你最多只能选择%@张图片", @(_maximumSelectImageCount)];
            }
            if (!_alertButtonTitleWhenExceedMaxSelectImageCount) {
                _alertButtonTitleWhenExceedMaxSelectImageCount = [NSString stringWithFormat:@"我知道了"];
            }
            
            [self fwShowAlertWithTitle:_alertTitleWhenExceedMaxSelectImageCount message:nil cancel:_alertButtonTitleWhenExceedMaxSelectImageCount cancelBlock:nil];
            return;
        }
        
        if ([self.imagePickerControllerDelegate respondsToSelector:@selector(imagePickerController:willCheckImageAtIndex:)]) {
            [self.imagePickerControllerDelegate imagePickerController:self willCheckImageAtIndex:indexPath.item];
        }
        
        cell.checked = YES;
        [self.selectedImageAssetArray addObject:imageAsset];
        
        if ([self.imagePickerControllerDelegate respondsToSelector:@selector(imagePickerController:didCheckImageAtIndex:)]) {
            [self.imagePickerControllerDelegate imagePickerController:self didCheckImageAtIndex:indexPath.item];
        }
        
        // 根据选择图片数控制预览和发送按钮的 enable，以及修改已选中的图片数
        [self updateImageCountAndCheckLimited];
        
        // 发出请求获取大图，如果图片在 iCloud，则会发出网络请求下载图片。这里同时保存请求 id，供取消请求使用
        [self requestImageWithIndexPath:indexPath];
    }
}

- (void)updateImageCountAndCheckLimited {
    NSInteger selectedImageCount = [self.selectedImageAssetArray count];
    if (selectedImageCount > 0 && selectedImageCount >= _minimumSelectImageCount) {
        self.previewButton.enabled = YES;
        self.sendButton.enabled = YES;
        self.imageCountLabel.text = [NSString stringWithFormat:@"%@", @(selectedImageCount)];
        self.imageCountLabel.hidden = NO;
    } else {
        self.previewButton.enabled = NO;
        self.sendButton.enabled = NO;
        self.imageCountLabel.hidden = YES;
    }
}

#pragma mark - Request Image

- (void)requestImageWithIndexPath:(NSIndexPath *)indexPath {
    // 发出请求获取大图，如果图片在 iCloud，则会发出网络请求下载图片。这里同时保存请求 id，供取消请求使用
    FWAsset *imageAsset = [self.imagesAssetArray objectAtIndex:indexPath.item];
    FWImagePickerCollectionCell *cell = (FWImagePickerCollectionCell *)[_collectionView cellForItemAtIndexPath:indexPath];
    imageAsset.requestID = [imageAsset requestOriginImageWithCompletion:^(UIImage *result, NSDictionary *info) {
        
        BOOL downloadSucceed = (result && !info) || (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue]);
        
        if (downloadSucceed) {
            // 资源资源已经在本地或下载成功
            [imageAsset updateDownloadStatusWithDownloadResult:YES];
            cell.downloadStatus = FWAssetDownloadStatusSucceed;
            
        } else if ([info objectForKey:PHImageErrorKey] ) {
            // 下载错误
            [imageAsset updateDownloadStatusWithDownloadResult:NO];
            cell.downloadStatus = FWAssetDownloadStatusFailed;
        }
        
    } withProgressHandler:^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
        imageAsset.downloadProgress = progress;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSArray *visibleItemIndexPaths = self.collectionView.indexPathsForVisibleItems;
            BOOL itemVisible = NO;
            for (NSIndexPath *visibleIndexPath in visibleItemIndexPaths) {
                if ([indexPath isEqual:visibleIndexPath]) {
                    itemVisible = YES;
                    break;
                }
            }
            
            if (itemVisible) {
                if (cell.downloadStatus != FWAssetDownloadStatusDownloading) {
                    cell.downloadStatus = FWAssetDownloadStatusDownloading;
                    // 预先设置预览界面的下载状态
                    self.imagePickerPreviewController.downloadStatus = FWAssetDownloadStatusDownloading;
                }
                if (error) {
                    cell.downloadStatus = FWAssetDownloadStatusFailed;
                }
            }
        });
    }];
}

+ (void)requestImagesAssetArray:(NSMutableArray<FWAsset *> *)imagesAssetArray filterType:(FWImagePickerFilterType)filterType completion:(void (^)(NSArray * _Nonnull, NSArray * _Nonnull))completion
{
    if (!completion) return;
    if (imagesAssetArray.count < 1) {
        completion(@[], @[]);
        return;
    }
    
    NSMutableArray *objects = [NSMutableArray array];
    NSMutableArray *results = [NSMutableArray array];
    NSInteger totalCount = imagesAssetArray.count;
    __block NSInteger finishCount = 0;
    BOOL checkLivePhoto = (filterType & FWImagePickerFilterTypeLivePhoto) || filterType < 1;
    BOOL checkVideo = (filterType & FWImagePickerFilterTypeVideo) || filterType < 1;
    for (FWAsset *asset in imagesAssetArray) {
        if (checkVideo && asset.assetType == FWAssetTypeVideo) {
            NSString *filePath = [PHPhotoLibrary fwPickerControllerVideoCachePath];
            [[NSFileManager defaultManager] createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
            filePath = [[filePath stringByAppendingPathComponent:[[NSUUID UUID].UUIDString fwMd5Encode]] stringByAppendingPathExtension:@"mp4"];
            NSURL *fileURL = [NSURL fileURLWithPath:filePath];
            [asset requestVideoURLWithOutputURL:fileURL completion:^(NSURL * _Nullable videoURL, NSDictionary<NSString *,id> * _Nullable info) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (videoURL) {
                        [objects addObject:videoURL];
                        [results addObject:info ?: @{}];
                    }
                    
                    finishCount += 1;
                    if (finishCount == totalCount) {
                        completion(objects.copy, results.copy);
                    }
                });
            } withProgressHandler:nil];
        } else if (asset.assetType == FWAssetTypeImage) {
            if (asset.editedImage) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [objects addObject:asset.editedImage];
                    [results addObject:@{}];
                    
                    finishCount += 1;
                    if (finishCount == totalCount) {
                        completion(objects.copy, results.copy);
                    }
                });
                return;
            }
            
            if (checkLivePhoto && asset.assetSubType == FWAssetSubTypeLivePhoto) {
                [asset requestLivePhotoWithCompletion:^void(PHLivePhoto *livePhoto, NSDictionary *info) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        BOOL downloadSucceed = (livePhoto && !info) || (![[info objectForKey:PHLivePhotoInfoCancelledKey] boolValue] && ![info objectForKey:PHLivePhotoInfoErrorKey] && ![[info objectForKey:PHLivePhotoInfoIsDegradedKey] boolValue]);
                        if (downloadSucceed) {
                            if (livePhoto) {
                                [objects addObject:livePhoto];
                                [results addObject:info ?: @{}];
                            }
                            
                            finishCount += 1;
                            if (finishCount == totalCount) {
                                completion(objects.copy, results.copy);
                            }
                        } else if ([info objectForKey:PHLivePhotoInfoErrorKey] ) {
                            finishCount += 1;
                            if (finishCount == totalCount) {
                                completion(objects.copy, results.copy);
                            }
                        }
                    });
                } withProgressHandler:nil];
            } else if (asset.assetSubType == FWAssetSubTypeGIF) {
                [asset requestImageDataWithCompletion:^(NSData *imageData, NSDictionary<NSString *,id> *info, BOOL isGIF, BOOL isHEIC) {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        UIImage *resultImage = imageData ? [UIImage fwImageWithData:imageData] : nil;
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (resultImage) {
                                [objects addObject:resultImage];
                                [results addObject:info ?: @{}];
                            }
                            
                            finishCount += 1;
                            if (finishCount == totalCount) {
                                completion(objects.copy, results.copy);
                            }
                        });
                    });
                }];
            } else {
                [asset requestOriginImageWithCompletion:^(UIImage *result, NSDictionary<NSString *,id> *info) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        BOOL downloadSucceed = (result && !info) || (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue]);
                        
                        if (downloadSucceed) {
                            if (result) {
                                [objects addObject:result];
                                [results addObject:info ?: @{}];
                            }
                            
                            finishCount += 1;
                            if (finishCount == totalCount) {
                                completion(objects.copy, results.copy);
                            }
                        } else if ([info objectForKey:PHImageErrorKey]) {
                            finishCount += 1;
                            if (finishCount == totalCount) {
                                completion(objects.copy, results.copy);
                            }
                        }
                    });
                } withProgressHandler:nil];
            }
        }
    }
}

@end
