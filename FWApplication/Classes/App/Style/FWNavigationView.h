/*!
 @header     FWNavigationView.h
 @indexgroup FWApplication
 @brief      FWNavigationView
 @author     wuyong
 @copyright  Copyright © 2019 wuyong.site. All rights reserved.
 @updated    2019/2/14
 */

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark - FWNavigationView

@class FWMenuView;

/**
 * 自定义导航栏视图，高度自动布局，隐藏时自动收起；整体高度为height，隐藏时为0
 */
@interface FWNavigationView : UIView

/// 背景图片视图，用于设置背景图片
@property (nonatomic, strong, readonly) UIImageView *backgroundView;

/// 顶部视图，延迟加载
@property (nonatomic, strong, readonly) UIView *topView;
/// 菜单视图，初始加载
@property (nonatomic, strong, readonly) FWMenuView *menuView;
/// 底部视图，延迟加载
@property (nonatomic, strong, readonly) UIView *bottomView;

/// 顶部高度，默认FWStatusBarHeight
@property (nonatomic, assign) CGFloat topHeight;
/// 菜单高度，默认FWNavigationBarHeight
@property (nonatomic, assign) CGFloat menuHeight;
/// 底部高度，默认0
@property (nonatomic, assign) CGFloat bottomHeight;
/// 导航栏只读总高度，topHeight+menuHeight+bottomHeight，隐藏时为0
@property (nonatomic, assign, readonly) CGFloat height;

/// 顶部栏是否隐藏，默认NO
@property (nonatomic, assign) BOOL topHidden;
/// 菜单是否隐藏，默认NO
@property (nonatomic, assign) BOOL menuHidden;
/// 底部栏是否隐藏，默认NO
@property (nonatomic, assign) BOOL bottomHidden;

/// 动态隐藏顶部栏
- (void)setTopHidden:(BOOL)hidden animated:(BOOL)animated;
/// 动态隐藏菜单栏
- (void)setMenuHidden:(BOOL)hidden animated:(BOOL)animated;
/// 动态隐藏底部栏
- (void)setBottomHidden:(BOOL)hidden animated:(BOOL)animated;
/// 动态隐藏导航栏
- (void)setHidden:(BOOL)hidden animated:(BOOL)animated;

@end

#pragma mark - FWMenuView

/**
 * 自定义菜单栏视图，支持完全自定义
 *
 * 默认最多只支持左右各两个按钮，如需更多按钮，请自行添加并布局即可
 */
@interface FWMenuView : UIView

/// 自定义返回按钮，自定义导航栏使用时会自动设置为左侧按钮
@property (nonatomic, strong, nullable) __kindof UIView *backButton;

/// 自定义左侧按钮，设置后才显示，左侧间距为8，同系统一致。建议使用FWMenuButton
@property (nonatomic, strong, nullable) __kindof UIView *leftButton;

/// 自定义左侧更多按钮，设置后才显示，左侧间距为8，同系统一致。建议使用FWMenuButton
@property (nonatomic, strong, nullable) __kindof UIView *leftMoreButton;

/// 自定义标题视图，居中显示，需支持自动布局，左右最大间距为0。建议使用FWMenuTitleView
@property (nonatomic, strong, nullable) __kindof UIView *titleView;

/// 快速设置标题，titleView类型为FWMenuTitleViewProtocol时才生效
@property (nonatomic, copy, nullable) NSString *title;

/// 自定义右侧更多按钮，设置后才显示，右侧间距为8，同系统一致。建议使用FWMenuButton
@property (nonatomic, strong, nullable) __kindof UIView *rightMoreButton;

/// 自定义右侧按钮，设置后才显示，右侧间距为8，同系统一致。建议使用FWMenuButton
@property (nonatomic, strong, nullable) __kindof UIView *rightButton;

@end

#pragma mark - FWMenuTitleView

/// 自定义titleView协议
@protocol FWMenuTitleViewProtocol <NSObject>

@required

/// 当前标题文字，自动兼容VC.title和navigationItem.title调用
@property(nonatomic, copy, nullable) NSString *title;

@end

@class FWMenuTitleView;
@protocol FWIndicatorViewPlugin;

/// 自定义titleView事件代理
@protocol FWMenuTitleViewDelegate <NSObject>

@optional

/**
 点击 titleView 后的回调，只需设置 titleView.userInteractionEnabled = YES 后即可使用

 @param titleView 被点击的 titleView
 @param isActive titleView 是否处于活跃状态
 */
- (void)didTouchTitleView:(FWMenuTitleView *)titleView isActive:(BOOL)isActive;

/**
 titleView 的活跃状态发生变化时会被调用，也即 [titleView setActive:] 被调用时。

 @param active 是否处于活跃状态
 @param titleView 变换状态的 titleView
 */
- (void)didChangedActive:(BOOL)active forTitleView:(FWMenuTitleView *)titleView;

@end

/// 自定义titleView布局方式，默认水平布局
typedef NS_ENUM(NSInteger, FWMenuTitleViewStyle) {
    FWMenuTitleViewStyleHorizontal = 0,
    FWMenuTitleViewStyleVertical,
};

/**
 *  可作为导航栏标题控件，通过 navigationItem.titleView 来设置。也可当成单独的标题组件，脱离 UIViewController 使用
 *
 *  默认情况下 titleView 是不支持点击的，如需点击，请把 `userInteractionEnabled` 设为 `YES`
 *
 *  @see https://github.com/Tencent/QMUI_iOS
 */
@interface FWMenuTitleView : UIControl <FWMenuTitleViewProtocol>

/// 事件代理
@property(nonatomic, weak, nullable) id<FWMenuTitleViewDelegate> delegate;

/// 标题栏样式
@property(nonatomic, assign) FWMenuTitleViewStyle style;

/// 标题栏是否是激活状态，主要针对accessoryImage生效
@property(nonatomic, assign, getter=isActive) BOOL active;

/// 动画方式设置标题栏是否激活，主要针对accessoryImage生效
- (void)setActive:(BOOL)active animated:(BOOL)animated;

/// 标题栏最大显示宽度
@property(nonatomic, assign) CGFloat maximumWidth UI_APPEARANCE_SELECTOR;

/// 标题标签
@property(nonatomic, strong, readonly) UILabel *titleLabel;

/// 标题文字
@property(nonatomic, copy, nullable) NSString *title;

/// 副标题标签
@property(nonatomic, strong, readonly) UILabel *subtitleLabel;

/// 副标题
@property(nonatomic, copy, nullable) NSString *subtitle;

/// 是否适应tintColor变化，影响titleLabel、subtitleLabel、loadingView，默认YES
@property(nonatomic, assign) BOOL adjustsTintColor UI_APPEARANCE_SELECTOR;

/// 水平布局下的标题字体，默认为 加粗17
@property(nonatomic, strong) UIFont *horizontalTitleFont UI_APPEARANCE_SELECTOR;

/// 水平布局下的副标题的字体，默认为 加粗17
@property(nonatomic, strong) UIFont *horizontalSubtitleFont UI_APPEARANCE_SELECTOR;

/// 垂直布局下的标题字体，默认为 15
@property(nonatomic, strong) UIFont *verticalTitleFont UI_APPEARANCE_SELECTOR;

/// 垂直布局下的副标题字体，默认为 12
@property(nonatomic, strong) UIFont *verticalSubtitleFont UI_APPEARANCE_SELECTOR;

/// 标题的上下左右间距，标题不显示时不参与计算大小，默认为 UIEdgeInsetsZero
@property(nonatomic, assign) UIEdgeInsets titleEdgeInsets UI_APPEARANCE_SELECTOR;

/// 副标题的上下左右间距，副标题不显示时不参与计算大小，默认为 UIEdgeInsetsZero
@property(nonatomic, assign) UIEdgeInsets subtitleEdgeInsets UI_APPEARANCE_SELECTOR;

/// 标题栏左侧loading视图，可自定义，开启loading后才存在
@property(nonatomic, strong, nullable) UIView<FWIndicatorViewPlugin> *loadingView;

/// 是否显示loading视图，开启后才会显示，默认NO
@property(nonatomic, assign) BOOL showsLoadingView;

/// 是否隐藏loading，开启之后生效，默认YES
@property(nonatomic, assign) BOOL loadingViewHidden;

/// 标题右侧是否显示和左侧loading一样的占位空间，默认YES
@property(nonatomic, assign) BOOL showsLoadingPlaceholder;

/// loading视图指定大小，默认(18, 18)
@property(nonatomic, assign) CGSize loadingViewSize UI_APPEARANCE_SELECTOR;

/// 指定loading右侧间距，默认3
@property(nonatomic, assign) CGFloat loadingViewSpacing UI_APPEARANCE_SELECTOR;

/// 自定义accessoryView，设置后accessoryImage无效，默认nil
@property(nonatomic, strong, nullable) UIView *accessoryView;

/// 自定义accessoryImage，accessoryView为空时才生效，默认nil
@property (nonatomic, strong, nullable) UIImage *accessoryImage;

/// 指定accessoryView偏移位置，默认(3, 0)
@property(nonatomic, assign) CGPoint accessoryViewOffset UI_APPEARANCE_SELECTOR;

/// 值为YES则title居中，`accessoryView`放在title的左边或右边；如果为NO，`accessoryView`和title整体居中；默认NO
@property(nonatomic, assign) BOOL showsAccessoryPlaceholder;

/// 同 accessoryView，用于 subtitle 的 AccessoryView，仅Vertical样式生效
@property(nonatomic, strong, nullable) UIView *subAccessoryView;

/// 指定subAccessoryView偏移位置，默认(3, 0)
@property(nonatomic, assign) CGPoint subAccessoryViewOffset UI_APPEARANCE_SELECTOR;

/// 同 showsAccessoryPlaceholder，用于 subtitle
@property(nonatomic, assign) BOOL showsSubAccessoryPlaceholder;

/// 指定样式初始化
- (instancetype)initWithStyle:(FWMenuTitleViewStyle)style;

@end

#pragma mark - FWMenuButton

/**
 * 自定义菜单栏按钮，兼容系统customView方式和自定义方式
 *
 * UIBarButtonItem自定义导航栏时最左和最右间距为16，系统导航栏时为8；FWMenuButton作为customView使用时，会自动调整按钮内间距，和系统表现一致
 */
@interface FWMenuButton : UIButton

/// UIBarButtonItem默认都是跟随tintColor的，所以这里声明是否让图片也是用AlwaysTemplate模式，默认YES
@property (nonatomic, assign) BOOL adjustsTintColor;

/// 指定标题初始化，默认内间距：{8, 8, 8, 8}，可自定义
- (instancetype)initWithTitle:(nullable NSString *)title;

/// 指定图片初始化，默认内间距：{8, 8, 8, 8}，可自定义
- (instancetype)initWithImage:(nullable UIImage *)image;

/// 使用指定对象创建按钮，支持UIImage|NSString(默认)，同时添加点击事件
+ (instancetype)buttonWithObject:(nullable id)object target:(nullable id)target action:(nullable SEL)action;

/// 使用指定对象创建按钮，支持UIImage|NSString(默认)，同时添加点击句柄
+ (instancetype)buttonWithObject:(nullable id)object block:(nullable void (^)(id sender))block;

@end

NS_ASSUME_NONNULL_END
