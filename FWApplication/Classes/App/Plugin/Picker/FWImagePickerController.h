/*!
 @header     FWImagePickerController.h
 @indexgroup FWApplication
 @brief      FWImagePickerController
 @author     wuyong
 @copyright  Copyright © 2020 wuyong.site. All rights reserved.
 @updated    2020/9/7
 */

#import <UIKit/UIKit.h>
#import "FWAssetManager.h"
#import "FWImagePickerPlugin.h"
#import "FWImagePreviewController.h"

NS_ASSUME_NONNULL_BEGIN

#pragma mark - FWImageAlbumController

@class FWImageAlbumTableCell;
@class FWImagePickerController;
@class FWImageAlbumController;

/// 相册列表事件代理
@protocol FWImageAlbumControllerDelegate <NSObject>

@optional
/// 需提供FWImagePickerController 用于展示九宫格图片列表
- (FWImagePickerController *)imagePickerControllerForAlbumController:(FWImageAlbumController *)albumController;

/// 点击相簿里某一行时被调用，未实现时默认打开imagePickerController
- (void)albumController:(FWImageAlbumController *)albumController didSelectAssetsGroup:(FWAssetGroup *)assetsGroup;

/// 自定义相册列表cell展示，cellForRow自动调用
- (void)albumController:(FWImageAlbumController *)albumController customCell:(FWImageAlbumTableCell *)cell atIndexPath:(NSIndexPath *)indexPath;

/// 取消查看相册列表后被调用，未实现时自动转发给当前imagePickerController
- (void)albumControllerDidCancel:(FWImageAlbumController *)albumController;

/// 即将需要显示 Loading 时调用，可自定义Loading效果
- (void)albumControllerWillStartLoading:(FWImageAlbumController *)albumController;

/// 即将需要隐藏 Loading 时调用，可自定义Loading效果
- (void)albumControllerWillFinishLoading:(FWImageAlbumController *)albumController;

/// 相册列表未授权时调用，可自定义空界面等
- (void)albumControllerWillShowDenied:(FWImageAlbumController *)albumController;

/// 相册列表为空时调用，可自定义空界面等
- (void)albumControllerWillShowEmpty:(FWImageAlbumController *)albumController;

@end

/// 相册列表默认Cell
@interface FWImageAlbumTableCell : UITableViewCell

// 相册缩略图的大小
@property(nonatomic, assign) CGFloat albumImageSize UI_APPEARANCE_SELECTOR;
// 相册缩略图的 left，-1 表示自动保持与上下 margin 相等
@property(nonatomic, assign) CGFloat albumImageMarginLeft UI_APPEARANCE_SELECTOR;
// 相册名称的上下左右间距
@property(nonatomic, assign) UIEdgeInsets albumNameInsets UI_APPEARANCE_SELECTOR;
// 相册名的字体
@property(nullable, nonatomic, strong) UIFont *albumNameFont UI_APPEARANCE_SELECTOR;
// 相册名的颜色
@property(nullable, nonatomic, strong) UIColor *albumNameColor UI_APPEARANCE_SELECTOR;
// 相册资源数量的字体
@property(nullable, nonatomic, strong) UIFont *albumAssetsNumberFont UI_APPEARANCE_SELECTOR;
// 相册资源数量的颜色
@property(nullable, nonatomic, strong) UIColor *albumAssetsNumberColor UI_APPEARANCE_SELECTOR;

@end

/**
 *  当前设备照片里的相簿列表，使用方式：
 *  1. 使用 init 初始化。
 *  2. 指定一个 albumControllerDelegate，并实现 @required 方法。
 *
 *  注意，iOS 访问相册需要得到授权，建议先询问用户授权([FWAssetsManager requestAuthorization:])，通过了再进行 FWImageAlbumController 的初始化工作。
 */
@interface FWImageAlbumController : UIViewController <UITableViewDataSource, UITableViewDelegate>

/// 相册只读列表视图
@property (nonatomic, strong, readonly) UITableView *tableView;

/// 当前相册列表，异步加载
@property(nonatomic, strong, readonly) NSMutableArray<FWAssetGroup *> *albumsArray;

/// 相册列表事件代理
@property(nullable, nonatomic, weak) id<FWImageAlbumControllerDelegate> albumControllerDelegate;

/// 相册列表 cell 的高度，同时也是相册预览图的宽高，默认88
@property(nonatomic, assign) CGFloat albumTableViewCellHeight;

/// 相册列表默认封面图，默认nil
@property(nullable, nonatomic, strong) UIImage *defaultPosterImage;

/// 相册展示内容的类型，可以控制只展示照片、视频或音频的其中一种，也可以同时展示所有类型的资源，默认展示所有类型的资源。
@property(nonatomic, assign) FWAlbumContentType contentType;

/// 是否直接进入第一个相册列表
@property(nonatomic, assign) BOOL pickDefaultAlbumGroup;

@end

#pragma mark - FWImagePickerPreviewController

@class FWNavigationButton;
@class FWImageCropController;
@class FWImagePickerController;
@class FWImagePreviewController;
@class FWImagePickerPreviewController;

@protocol FWImagePickerPreviewControllerDelegate <NSObject>

@optional

/// 完成选中图片回调，未实现时自动转发给当前imagePickerController
- (void)imagePickerPreviewController:(FWImagePickerPreviewController *)imagePickerPreviewController didFinishPickingImageWithImagesAssetArray:(NSMutableArray<FWAsset *> *)imagesAssetArray;
/// 即将选中图片
- (void)imagePickerPreviewController:(FWImagePickerPreviewController *)imagePickerPreviewController willCheckImageAtIndex:(NSInteger)index;
/// 已经选中图片
- (void)imagePickerPreviewController:(FWImagePickerPreviewController *)imagePickerPreviewController didCheckImageAtIndex:(NSInteger)index;
/// 即将取消选中图片
- (void)imagePickerPreviewController:(FWImagePickerPreviewController *)imagePickerPreviewController willUncheckImageAtIndex:(NSInteger)index;
/// 已经取消选中图片
- (void)imagePickerPreviewController:(FWImagePickerPreviewController *)imagePickerPreviewController didUncheckImageAtIndex:(NSInteger)index;
/// 图片预览界面关闭返回时被调用
- (void)imagePickerPreviewControllerDidCancel:(FWImagePickerPreviewController *)imagePickerPreviewController;
/// 自定义图片裁剪控制器，启用编辑时生效，未实现时使用默认配置
- (FWImageCropController *)imageCropControllerForPreviewController:(FWImagePickerPreviewController *)previewController image:(UIImage *)image;

@end


@interface FWImagePickerPreviewController : FWImagePreviewController <UICollectionViewDataSource, UICollectionViewDelegate, FWImagePreviewViewDelegate>

@property(nullable, nonatomic, weak) id<FWImagePickerPreviewControllerDelegate> delegate;

@property(nullable, nonatomic, strong) UIColor *toolBarBackgroundColor;
@property(nullable, nonatomic, strong) UIColor *toolBarTintColor;

@property(nullable, nonatomic, strong, readonly) UIView *topToolBarView;
@property(nullable, nonatomic, strong, readonly) FWNavigationButton *backButton;
@property(nullable, nonatomic, strong, readonly) UIButton *checkboxButton;
@property(nonatomic, strong) UIImage *checkboxImage;
@property(nonatomic, strong) UIImage *checkboxCheckedImage;

@property(nullable, nonatomic, strong, readonly) UIView *bottomToolBarView;
@property(nullable, nonatomic, strong, readonly) UIButton *sendButton;
@property(nullable, nonatomic, strong, readonly) UIButton *editButton;
@property(nullable, nonatomic, strong, readonly) UIButton *originImageCheckboxButton;
@property(nonatomic, strong) UIImage *originImageCheckboxImage;
@property(nonatomic, strong) UIImage *originImageCheckboxCheckedImage;
@property(nullable, nonatomic, strong, readonly) UILabel *imageCountLabel;
@property(nonatomic, assign) BOOL showsImageCountLabel;
@property(nonatomic, assign) BOOL shouldUseOriginImage;
@property(nonatomic, assign) BOOL showsOriginImageCheckboxButton;
/// 是否显示编辑按钮，默认YES
@property(nonatomic, assign) BOOL showsEditButton;

/// 是否显示编辑collectionView，默认YES，仅多选生效
@property(nonatomic, assign) BOOL showsEditCollectionView;
@property(nullable, nonatomic, strong, readonly) UICollectionViewFlowLayout *editCollectionViewLayout;
@property(nullable, nonatomic, strong, readonly) UICollectionView *editCollectionView;
/// 编辑collectionView高度，默认80
@property(nonatomic, assign) CGFloat editCollectionViewHeight;

/// 由于组件需要通过本地图片的 FWAsset 对象读取图片的详细信息，因此这里的需要传入的是包含一个或多个 FWAsset 对象的数组
@property(nullable, nonatomic, strong) NSMutableArray<FWAsset *> *imagesAssetArray;
@property(nullable, nonatomic, strong) NSMutableArray<FWAsset *> *selectedImageAssetArray;

@property(nonatomic, assign) FWAssetDownloadStatus downloadStatus;

/// 最多可以选择的图片数，默认为9
@property(nonatomic, assign) NSUInteger maximumSelectImageCount;
/// 最少需要选择的图片数，默认为 0
@property(nonatomic, assign) NSUInteger minimumSelectImageCount;
/// 选择图片超出最大图片限制时 alertView 的标题
@property(nullable, nonatomic, copy) NSString *alertTitleWhenExceedMaxSelectImageCount;
/// 选择图片超出最大图片限制时 alertView 的标题
@property(nullable, nonatomic, copy) NSString *alertButtonTitleWhenExceedMaxSelectImageCount;

/**
 *  更新数据并刷新 UI，手工调用
 *
 *  @param imageAssetArray         包含所有需要展示的图片的数组
 *  @param selectedImageAssetArray 包含所有需要展示的图片中已经被选中的图片的数组
 *  @param currentImageIndex       当前展示的图片在 imageAssetArray 的索引
 *  @param singleCheckMode         是否为单选模式，如果是单选模式，则不显示 checkbox
 *  @param previewMode         是否是预览模式，如果是预览模式，图片取消选中时editCollectionView会置灰而不是隐藏
 */
- (void)updateImagePickerPreviewViewWithImagesAssetArray:(NSMutableArray<FWAsset *> * _Nullable)imageAssetArray
                                 selectedImageAssetArray:(NSMutableArray<FWAsset *> * _Nullable)selectedImageAssetArray
                                       currentImageIndex:(NSInteger)currentImageIndex
                                         singleCheckMode:(BOOL)singleCheckMode
                                             previewMode:(BOOL)previewMode;

@end

@interface FWImagePickerPreviewCollectionCell : UICollectionViewCell

/// 缩略图视图
@property(nonatomic, strong, readonly) UIImageView *imageView;
/// 缩略图的大小，默认(60,60)
@property(nonatomic, assign) CGSize thumbnailImageSize UI_APPEARANCE_SELECTOR;
/// 选中边框颜色
@property(nullable, nonatomic, strong) UIColor *checkedBorderColor UI_APPEARANCE_SELECTOR;
/// 选中边框宽度
@property(nonatomic, assign) CGFloat checkedBorderWidth UI_APPEARANCE_SELECTOR;
/// 当前是否选中
@property(nonatomic, assign) BOOL checked;

@property(nonatomic, strong, readonly) UILabel *videoDurationLabel;
/// videoDurationLabel 的字号
@property(nonatomic, strong) UIFont *videoDurationLabelFont UI_APPEARANCE_SELECTOR;
/// videoDurationLabel 的字体颜色
@property(nonatomic, strong) UIColor *videoDurationLabelTextColor UI_APPEARANCE_SELECTOR;
/// 视频时长文字的间距，相对于 cell 右下角而言，也即如果 right 越大则越往左，bottom 越大则越往上，另外 top 会影响底部遮罩的高度
@property(nonatomic, assign) UIEdgeInsets videoDurationLabelMargins UI_APPEARANCE_SELECTOR;

/// 当前这个 cell 正在展示的 FWAsset 的 identifier
@property(nonatomic, copy, nullable) NSString *assetIdentifier;
- (void)renderWithAsset:(FWAsset *)asset referenceSize:(CGSize)referenceSize;

@end

#pragma mark - FWImagePickerController

@class FWImagePickerCollectionCell;
@class FWImagePickerController;

@protocol FWImagePickerControllerDelegate <NSObject>

@optional

/**
 *  创建一个 ImagePickerPreviewViewController 用于预览图片
 */
- (FWImagePickerPreviewController *)imagePickerPreviewControllerForImagePickerController:(FWImagePickerController *)imagePickerController;

/**
 *  控制照片的排序，若不实现，默认为 FWAlbumSortTypePositive
 *  @note 注意返回值会决定第一次进来相片列表时列表默认的滚动位置，如果为 FWAlbumSortTypePositive，则列表默认滚动到底部，如果为 FWAlbumSortTypeReverse，则列表默认滚动到顶部。
 */
- (FWAlbumSortType)albumSortTypeForImagePickerController:(FWImagePickerController *)imagePickerController;

/**
 *  多选模式下选择图片完毕后被调用（点击 sendButton 后被调用），单选模式下没有底部发送按钮，所以也不会走到这个delegate
 *
 *  @param imagePickerController 对应的 FWImagePickerController
 *  @param imagesAssetArray          包含被选择的图片的 FWAsset 对象的数组。
 */
- (void)imagePickerController:(FWImagePickerController *)imagePickerController didFinishPickingImageWithImagesAssetArray:(NSMutableArray<FWAsset *> *)imagesAssetArray;

/**
 *  取消选择图片后被调用
 */
- (void)imagePickerControllerDidCancel:(FWImagePickerController *)imagePickerController;

/**
 *  cell 被点击时调用（先调用这个接口，然后才去走预览大图的逻辑），注意这并非指选中 checkbox 事件
 *
 *  @param imagePickerController        对应的 FWImagePickerController
 *  @param imageAsset                       被选中的图片的 FWAsset 对象
 *  @param imagePickerPreviewController 选中图片后进行图片预览的 viewController
 */
- (void)imagePickerController:(FWImagePickerController *)imagePickerController didSelectImageWithImagesAsset:(FWAsset *)imageAsset afterImagePickerPreviewControllerUpdate:(FWImagePickerPreviewController *)imagePickerPreviewController;

/// 是否能够选中 checkbox
- (BOOL)imagePickerController:(FWImagePickerController *)imagePickerController shouldCheckImageAtIndex:(NSInteger)index;

/// 即将选中 checkbox 时调用
- (void)imagePickerController:(FWImagePickerController *)imagePickerController willCheckImageAtIndex:(NSInteger)index;

/// 选中了 checkbox 之后调用
- (void)imagePickerController:(FWImagePickerController *)imagePickerController didCheckImageAtIndex:(NSInteger)index;

/// 即将取消选中 checkbox 时调用
- (void)imagePickerController:(FWImagePickerController *)imagePickerController willUncheckImageAtIndex:(NSInteger)index;

/// 取消了 checkbox 选中之后调用
- (void)imagePickerController:(FWImagePickerController *)imagePickerController didUncheckImageAtIndex:(NSInteger)index;

/// 自定义图片九宫格cell展示，cellForRow自动调用
- (void)imagePickerController:(FWImagePickerController *)imagePickerController customCell:(FWImagePickerCollectionCell *)cell atIndexPath:(NSIndexPath *)indexPath;

/**
 *  即将需要显示 Loading 时调用
 *
 *  @see shouldShowDefaultLoadingView
 */
- (void)imagePickerControllerWillStartLoading:(FWImagePickerController *)imagePickerController;

/**
 *  即将需要隐藏 Loading 时调用
 *
 *  @see shouldShowDefaultLoadingView
 */
- (void)imagePickerControllerDidFinishLoading:(FWImagePickerController *)imagePickerController;

@end


@interface FWImagePickerController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, FWImagePickerPreviewControllerDelegate>

@property(nullable, nonatomic, weak) id<FWImagePickerControllerDelegate> imagePickerControllerDelegate;

@property(nullable, nonatomic, strong) UIColor *toolBarBackgroundColor;
@property(nullable, nonatomic, strong) UIColor *toolBarTintColor;

/*
 * 图片的最小尺寸，布局时如果有剩余空间，会将空间分配给图片大小，所以最终显示出来的大小不一定等于minimumImageWidth。默认是75。
 * @warning collectionViewLayout 和 collectionView 可能有设置 sectionInsets 和 contentInsets，所以设置几行不可以简单的通过 screenWdith / columnCount 来获得
 */
@property(nonatomic, assign) CGFloat minimumImageWidth;

@property(nullable, nonatomic, strong, readonly) UICollectionViewFlowLayout *collectionViewLayout;
@property(nullable, nonatomic, strong, readonly) UICollectionView *collectionView;

@property(nullable, nonatomic, strong, readonly) UIView *operationToolBarView;
@property(nullable, nonatomic, strong, readonly) UIButton *previewButton;
@property(nullable, nonatomic, strong, readonly) UIButton *sendButton;
@property(nullable, nonatomic, strong, readonly) UILabel *imageCountLabel;
@property(nonatomic, assign) BOOL showsImageCountLabel;

/// 也可以直接传入 FWAssetGroup，然后读取其中的 FWAsset 并储存到 imagesAssetArray 中，传入后会赋值到 FWAssetGroup，并自动刷新 UI 展示
- (void)refreshWithAssetsGroup:(FWAssetGroup * _Nullable)assetsGroup;

@property(nullable, nonatomic, strong, readonly) NSMutableArray<FWAsset *> *imagesAssetArray;
@property(nullable, nonatomic, strong, readonly) FWAssetGroup *assetsGroup;

/// 当前被选择的图片对应的 FWAsset 对象数组
@property(nullable, nonatomic, strong, readonly) NSMutableArray<FWAsset *> *selectedImageAssetArray;

/// 是否允许图片多选，默认为 YES。如果为 NO，则不显示 checkbox 和底部工具栏。
@property(nonatomic, assign) BOOL allowsMultipleSelection;

/// 最多可以选择的图片数，默认为9
@property(nonatomic, assign) NSUInteger maximumSelectImageCount;

/// 最少需要选择的图片数，默认为 0
@property(nonatomic, assign) NSUInteger minimumSelectImageCount;

/// 选择图片超出最大图片限制时 alertView 的标题
@property(nullable, nonatomic, copy) NSString *alertTitleWhenExceedMaxSelectImageCount;

/// 选择图片超出最大图片限制时 alertView 底部按钮的标题
@property(nullable, nonatomic, copy) NSString *alertButtonTitleWhenExceedMaxSelectImageCount;

/**
 *  加载相册列表时会出现 loading，若需要自定义 loading 的形式，可将该属性置为 NO，默认为 YES。
 *  @see imagePickerControllerWillStartLoading: & imagePickerControllerDidFinishLoading:
 */
@property(nonatomic, assign) BOOL shouldShowDefaultLoadingView;

/**
 * 检查并下载一组资源，如果资源仍未从 iCloud 中成功下载，则会发出请求从 iCloud 加载资源
 *
 * 下载完成后，主线程回调资源对象和结果信息，根据过滤类型返回UIImage|PHLivePhoto|NSURL
 */
+ (void)requestImagesAssetArray:(NSMutableArray<FWAsset *> *)imagesAssetArray filterType:(FWImagePickerFilterType)filterType completion:(void (^)(NSArray *objects, NSArray *results))completion;

@end

#pragma mark - FWImagePickerCollectionCell

/**
 *  图片选择空间里的九宫格 cell，支持显示 checkbox、饼状进度条及重试按钮（iCloud 图片需要）
 */
@interface FWImagePickerCollectionCell : UICollectionViewCell

/// checkbox 未被选中时显示的图片
@property(nonatomic, strong) UIImage *checkboxImage UI_APPEARANCE_SELECTOR;
/// checkbox 被选中时显示的图片
@property(nonatomic, strong) UIImage *checkboxCheckedImage UI_APPEARANCE_SELECTOR;
/// checkbox 的 margin，定位从每个 cell（即每张图片）的最右边开始计算
@property(nonatomic, assign) UIEdgeInsets checkboxButtonMargins UI_APPEARANCE_SELECTOR;

/// videoDurationLabel 的字号
@property(nonatomic, strong) UIFont *videoDurationLabelFont UI_APPEARANCE_SELECTOR;
/// videoDurationLabel 的字体颜色
@property(nonatomic, strong) UIColor *videoDurationLabelTextColor UI_APPEARANCE_SELECTOR;
/// 视频时长文字的间距，相对于 cell 右下角而言，也即如果 right 越大则越往左，bottom 越大则越往上，另外 top 会影响底部遮罩的高度
@property(nonatomic, assign) UIEdgeInsets videoDurationLabelMargins UI_APPEARANCE_SELECTOR;

/// checkedIndexLabel 的字号
@property(nonatomic, strong) UIFont *checkedIndexLabelFont UI_APPEARANCE_SELECTOR;
/// checkedIndexLabel 的字体颜色
@property(nonatomic, strong) UIColor *checkedIndexLabelTextColor UI_APPEARANCE_SELECTOR;
/// checkedIndexLabel 的尺寸
@property(nonatomic, assign) CGSize checkedIndexLabelSize UI_APPEARANCE_SELECTOR;
/// checkedIndexLabel 的 margin，定位从每个 cell（即每张图片）的最右边开始计算
@property(nonatomic, assign) UIEdgeInsets checkedIndexLabelMargins UI_APPEARANCE_SELECTOR;
/// checkedIndexLabel 的背景色
@property(nonatomic, strong) UIColor *checkedIndexLabelBackgroundColor UI_APPEARANCE_SELECTOR;
/// 是否显示checkedIndexLabel，大小和checkboxButton保持一致
@property(nonatomic, assign) BOOL showsCheckedIndexLabel UI_APPEARANCE_SELECTOR;

@property(nonatomic, strong, readonly) UIImageView *contentImageView;
@property(nonatomic, strong, readonly) UIButton *checkboxButton;
@property(nonatomic, strong, readonly) UILabel *videoDurationLabel;
@property(nonatomic, strong, readonly) UILabel *checkedIndexLabel;

@property(nonatomic, assign, getter=isSelectable) BOOL selectable;
@property(nonatomic, assign, getter=isChecked) BOOL checked;
@property(nonatomic, assign) NSInteger checkedIndex;
@property(nonatomic, assign) FWAssetDownloadStatus downloadStatus; // Cell 中对应资源的下载状态，这个值的变动会相应地调整 UI 表现
@property(nonatomic, copy, nullable) NSString *assetIdentifier;// 当前这个 cell 正在展示的 FWAsset 的 identifier

- (void)renderWithAsset:(FWAsset *)asset referenceSize:(CGSize)referenceSize;

@end

NS_ASSUME_NONNULL_END
