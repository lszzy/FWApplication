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

/// 自定义导航栏样式
typedef NS_ENUM(NSInteger, FWNavigationViewStyle) {
    /// 默认样式，UINavigationBar实现，兼容FWNavigationStyle相关方法
    FWNavigationViewStyleDefault = 0,
    /// 完全自定义样式，提供navigationView容器视图，自行处理布局
    FWNavigationViewStyleCustom,
};

@class FWNavigationContentView;

/**
 * 自定义导航栏视图，高度自动布局，隐藏时自动收起
 *
 * 自定义导航栏视图结构如下：
 * 顶部：延迟加载topView，高度为topHeight，可设置topHidden显示或隐藏
 * 中间：初始加载middleView，高度为middelHeight，可设置middleHidden显示或隐藏
 *     navigationBar: 高度同middleHeight，default样式时显示，兼容FWNavigationStyle方法
 *     contentView: 高度为contentHeight，custom样式时显示，内容完全自定义
 * 底部：延迟加载bottomView，高度为bottomHeight，可设置bottomHidden显示或隐藏
 *
 * 自定义导航栏整体高度为height，隐藏时为0；绑定控制器后自动同步系统导航栏状态，可解除绑定。
 * custom样式不支持iOS11+自带largeTitles效果，需要时可使用bottomView自行实现
 */
@interface FWNavigationView : UIView

/// 当前导航栏样式，默认default，设置后自动显示navigationBar或contentView
@property (nonatomic, assign) FWNavigationViewStyle style;

/// 背景视图，仅custom样式时显示，default样式请使用navigationBar设置背景
@property (nonatomic, strong, readonly) UIImageView *backgroundView;

/// 顶部视图，延迟加载，默认不加载
@property (nonatomic, strong, readonly) UIView *topView;

/// 顶部是否隐藏，隐藏后自动收起，默认NO。绑定控制器后自动跟随系统导航栏变化
@property (nonatomic, assign) BOOL topHidden;

/// 自定义顶部高度，隐藏时自动收起，默认FWStatusBarHeight。绑定控制器后自动跟随系统导航栏变化
@property (nonatomic, assign) CGFloat topHeight;

/// 中间视图，初始加载，默认高度跟随navigationBar自适应
@property (nonatomic, strong, readonly) UIView *middleView;

/// 中间视图是否隐藏，隐藏后自动收起，默认NO
@property (nonatomic, assign) BOOL middleHidden;

/// 中间视图高度，隐藏时自动收起，默认0自适应，非0时固定高度。绑定控制器后自动跟随系统导航栏变化
@property (nonatomic, assign) CGFloat middleHeight;

/// 自定义导航栏，默认高度自适应，default样式时显示
@property (nonatomic, strong, readonly) UINavigationBar *navigationBar;

/// 自定义导航项，可设置标题、按钮等，default样式时生效
@property (nonatomic, strong, readonly) UINavigationItem *navigationItem;

/// 内容视图，初始加载，custom样式时显示，与navigationBar布局相同
@property (nonatomic, strong, readonly) FWNavigationContentView *contentView;

/// 内容视图内间距，支持navigationBar和contentView，默认zero
@property (nonatomic, assign) UIEdgeInsets contentInsets;

/// 内容视图高度，只读，与是否隐藏无关。绑定控制器后自动跟随系统导航栏变化
@property (nonatomic, assign, readonly) CGFloat contentHeight;

/// 底部视图，延迟加载，默认不加载
@property (nonatomic, strong, readonly) UIView *bottomView;

/// 底部是否隐藏，隐藏后自动收起，默认NO
@property (nonatomic, assign) BOOL bottomHidden;

/// 自定义底部高度，隐藏时自动收起，默认0
@property (nonatomic, assign) CGFloat bottomHeight;

/// 当前总高度，自动计算实际显示高度，隐藏时为0
@property (nonatomic, assign, readonly) CGFloat height;

/// 设置标题视图，default样式使用navigationBar，custom样式使用contentView，不支持style动态切换
@property (nonatomic, weak, nullable) UIView *titleView;

/// 绑定视图控制器，绑定后导航栏状态自动跟随变化，设为nil时解除绑定
@property (nonatomic, weak, nullable) UIViewController *viewController;

/**
 * 绑定scrollView，绑定后自动处理滚动动画效果并更新相应高度，要求scrollView内容足够高
 *
 * 1. 如果bottomHeight > 0，则滚动bottomView并更新bottomHeight，不执行2
 * 2. 如果为default样式且为竖屏并开启了iOS11+largeTitles效果，则滚动大标题并更新middleHeight(自动变为固定高度)
 */
@property (nonatomic, weak, nullable) UIScrollView *scrollView;

@end

#pragma mark - UIViewController+FWNavigationView

/**
 * 控制器自定义导航栏分类，建议loadView之后再调用fwNavigationView相关属性
 *
 * 原则：优先用系统导航栏，不满足时才使用自定义导航栏
 * 注意：启用自定义导航栏后，自动绑定控制器，虽然兼容FWNavigationStyle方法，但有几点不同，列举如下：
 * 1. VC容器视图为fwView，所有子视图应该添加到fwView；fwView兼容系统导航栏view和edgesForExtendedLayout(详见fwNavigationExtendedLayout)
 * 2. fwNavigationView位于VC.view顶部；fwView位于VC.view底部，顶部对齐fwNavigationView.底部
 * 3. VC返回按钮会使用自身的backBarButtonItem，兼容系统导航栏动态切换；而系统VC会使用前一个控制器的backBarButtonItem
 * 4. 不支持iOS11+自带largeTitles效果，需要时可使用bottomView自行实现
 * 5. 不兼容框架导航栏半透明效果，如需该效果请使用系统导航栏
 * 如果从系统导航栏动态迁移到自定义导航栏，注意检查导航相关功能是否异常
 */
@interface UIViewController (FWNavigationView)

/// 是否启用自定义导航栏，需在init中设置或子类重写，默认NO
@property (nonatomic, assign) BOOL fwNavigationViewEnabled;

/// 自定义导航栏视图，fwNavigationViewEnabled为YES时生效。默认自动绑定控制器，导航栏状态跟随变化
@property (nonatomic, strong, readonly) FWNavigationView *fwNavigationView;

/// 当前导航栏，默认navigationController.navigationBar，用于兼容自定义导航栏，仅default样式时生效
@property (nullable, nonatomic, readonly) UINavigationBar *fwNavigationBar;

/// 当前导航项，默认navigationItem，用于兼容自定义导航栏，仅default样式时生效
@property (nonatomic, strong, readonly) UINavigationItem *fwNavigationItem;

/// 启用自定义导航栏后的内容容器视图，位于导航栏下方或底部，建议通过fwView方法调用
@property (nonatomic, strong, readonly) UIView *fwContainerView;

/// 自定义导航栏是否兼容edgesForExtendedLayout(不支持scrollView边缘自适应)，默认YES
@property (nonatomic, assign) BOOL fwNavigationExtendedLayout;

/// 当前内容视图，默认view，用于兼容自定义导航栏等方案
@property (nonatomic, strong, readonly) UIView *fwView;

@end

#pragma mark - FWNavigationContentView

/**
 * 自定义导航栏内容视图，支持完全自定义
 *
 * 默认最多只支持左右各两个按钮，如需更多按钮，请自行添加并布局即可
 */
@interface FWNavigationContentView : UIView

/// 自定义返回按钮，自定义导航栏使用时会自动设置为左侧按钮
@property (nonatomic, strong, nullable) __kindof UIView *backButton;

/// 自定义左侧按钮，设置后才显示，左侧间距为8，同系统一致。建议使用FWNavigationButton
@property (nonatomic, strong, nullable) __kindof UIView *leftButton;

/// 自定义左侧更多按钮，设置后才显示，左侧间距为8，同系统一致。建议使用FWNavigationButton
@property (nonatomic, strong, nullable) __kindof UIView *leftMoreButton;

/// 自定义标题视图，居中显示，需支持自动布局，左右最大间距为0。默认初始化FWNavigationTitleView，设为nil可清空
@property (nonatomic, strong, nullable) __kindof UIView *titleView;

/// 快速设置标题，titleView类型为FWNavigationTitleViewProtocol时才生效
@property (nonatomic, copy, nullable) NSString *title;

/// 自定义右侧更多按钮，设置后才显示，右侧间距为8，同系统一致。建议使用FWNavigationButton
@property (nonatomic, strong, nullable) __kindof UIView *rightMoreButton;

/// 自定义右侧按钮，设置后才显示，右侧间距为8，同系统一致。建议使用FWNavigationButton
@property (nonatomic, strong, nullable) __kindof UIView *rightButton;

@end

#pragma mark - FWNavigationTitleView

/// 自定义titleView协议
@protocol FWNavigationTitleViewProtocol <NSObject>

@required

/// 当前标题文字，自动兼容VC.title和navigationItem.title调用
@property(nonatomic, copy, nullable) NSString *title;

@end

@class FWNavigationTitleView;
@protocol FWIndicatorViewPlugin;

/// 自定义titleView事件代理
@protocol FWNavigationTitleViewDelegate <NSObject>

@optional

/**
 点击 titleView 后的回调，只需设置 titleView.userInteractionEnabled = YES 后即可使用

 @param titleView 被点击的 titleView
 @param isActive titleView 是否处于活跃状态
 */
- (void)didTouchTitleView:(FWNavigationTitleView *)titleView isActive:(BOOL)isActive;

/**
 titleView 的活跃状态发生变化时会被调用，也即 [titleView setActive:] 被调用时。

 @param active 是否处于活跃状态
 @param titleView 变换状态的 titleView
 */
- (void)didChangedActive:(BOOL)active forTitleView:(FWNavigationTitleView *)titleView;

@end

/// 自定义titleView布局方式，默认水平布局
typedef NS_ENUM(NSInteger, FWNavigationTitleViewStyle) {
    FWNavigationTitleViewStyleHorizontal = 0,
    FWNavigationTitleViewStyleVertical,
};

/**
 *  可作为导航栏标题控件，通过 navigationItem.titleView 来设置。也可当成单独的组件，脱离 UIViewController 使用
 *
 *  默认情况下 titleView 是不支持点击的，如需点击，请把 `userInteractionEnabled` 设为 `YES`
 *
 *  @see https://github.com/Tencent/QMUI_iOS
 */
@interface FWNavigationTitleView : UIControl <FWNavigationTitleViewProtocol>

/// 事件代理
@property(nonatomic, weak, nullable) id<FWNavigationTitleViewDelegate> delegate;

/// 标题栏样式
@property(nonatomic, assign) FWNavigationTitleViewStyle style;

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
- (instancetype)initWithStyle:(FWNavigationTitleViewStyle)style;

@end

#pragma mark - FWNavigationButton

/**
 * 自定义导航栏按钮，兼容系统customView方式和自定义方式
 *
 * UIBarButtonItem自定义导航栏时最左和最右间距为16，系统导航栏时为8；FWNavigationButton作为customView使用时，会自动调整按钮内间距，和系统表现一致
 */
@interface FWNavigationButton : UIButton

/// UIBarButtonItem默认都是跟随tintColor的，所以这里声明是否让图片也是用AlwaysTemplate模式，默认YES
@property (nonatomic, assign) BOOL adjustsTintColor;

/// 初始化标题类型按钮，默认内间距：{8, 8, 8, 8}，可自定义
- (instancetype)initWithTitle:(nullable NSString *)title;

/// 初始化图片类型按钮，默认内间距：{8, 8, 8, 8}，可自定义
- (instancetype)initWithImage:(nullable UIImage *)image;

/// 使用指定对象创建按钮，支持UIImage|NSString，不支持时返回nil
- (nullable instancetype)initWithObject:(nullable id)object;

@end

NS_ASSUME_NONNULL_END
