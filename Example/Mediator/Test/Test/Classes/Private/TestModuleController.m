//
//  TestModuleController.m
//  Pods
//
//  Created by wuyong on 2021/1/2.
//

#import "TestModuleController.h"
@import FWApplication;
@import Core;

@interface TestModuleExpandedView : UIView

@end

@implementation TestModuleExpandedView

- (CGSize)intrinsicContentSize
{
    return UILayoutFittingExpandedSize;
}

@end

@interface TestModuleController () <FWTableViewController, UISearchBarDelegate>

@property (nonatomic, assign) BOOL isSearch;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) NSMutableArray *searchResult;

@end

@implementation TestModuleController

#pragma mark - Accessor

- (void)setSelectedIndex:(NSInteger)selectedIndex
{
    _selectedIndex = selectedIndex;
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:selectedIndex] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    [self.fw showMessageWithText:[NSString stringWithFormat:@"跳转到测试section: %@", @(selectedIndex)]];
}

- (UISearchBar *)searchBar
{
    if (!_searchBar) {
        _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, FWScreenWidth, FWNavigationBarHeight)];
        _searchBar.placeholder = @"Search";
        _searchBar.delegate = self;
        _searchBar.showsCancelButton = YES;
        [_searchBar.fw.cancelButton setTitle:FWAppBundle.cancelButton forState:UIControlStateNormal];
        _searchBar.fw.forceCancelButtonEnabled = YES;
        _searchBar.fw.backgroundColor = [Theme barColor];
        _searchBar.fw.textFieldBackgroundColor = [Theme tableColor];
        _searchBar.fw.contentInset = UIEdgeInsetsMake(6, 16, 6, 0);
        _searchBar.fw.cancelButtonInset = UIEdgeInsetsMake(0, 16, 0, 16);
        _searchBar.fw.searchIconCenter = YES;
        _searchBar.fw.searchIconOffset = 10;
        _searchBar.fw.searchTextOffset = 4;
        
        UITextField *textField = [_searchBar.fw textField];
        textField.font = [UIFont systemFontOfSize:12];
        [textField fw_setCornerRadius:16];
        textField.fw_touchResign = YES;
    }
    return _searchBar;
}

- (UIView *)titleView
{
    UIView *titleView = [[TestModuleExpandedView alloc] initWithFrame:CGRectMake(0, 0, FWScreenWidth, FWNavigationBarHeight)];
    [titleView fw_setDimension:NSLayoutAttributeHeight toSize:FWNavigationBarHeight];
    titleView.backgroundColor = [UIColor clearColor];
    [titleView addSubview:self.searchBar];
    [self.searchBar fw_pinEdgesToSuperview];
    return titleView;
}

- (NSArray *)displayData
{
    return self.isSearch ? self.searchResult : self.tableData;
}

#pragma mark - Lifecycle

- (UITableViewStyle)renderTableStyle
{
    return UITableViewStyleGrouped;
}

- (void)renderTableView
{
    self.tableView.backgroundColor = [Theme tableColor];
    self.tableView.fw.keyboardDismissOnDrag = YES;
}

- (void)renderData
{
    [self.tableData addObjectsFromArray:@[
        @[@"Framework", @[
              @[@"FWRouter", @"TestRouterViewController"],
              @[@"FWNavigation", @"TestWindowViewController"],
              @[@"FWWorkflow", @"TestWorkflowViewController"],
              @[@"FWException", @"TestCrashViewController"],
              @[@"FWLayoutChain", @"TestChainViewController"],
              @[@"FWTheme", @"TestThemeViewController"],
              @[@"FWTheme+Extension", @"TestThemeExtensionViewController"],
              @[@"FWIcon", @"Test.TestIconViewController"],
              @[@"FWDynamicLayout+UITableView", @"TestTableDynamicLayoutViewController"],
              @[@"FWDynamicLayout+UICollectionView", @"TestCollectionDynamicLayoutViewController"],
              @[@"FWAdaptive", @"TestBarViewController"],
              @[@"FWPromise", @"Test.TestPromiseViewController"],
              @[@"FWImage", @"TestImageViewController"],
              @[@"FWState", @"TestStateViewController"],
              @[@"FWAnnotation", @"Test.TestAnnotationViewController"],
              @[@"FWAuthorize", @"TestAuthorizeViewController"],
              @[@"FWLocation", @"Test.TestLocationViewController"],
              @[@"FWNotification", @"TestNotificationViewController"],
              @[@"FWVersion", @"TestVersionViewController"],
              ]],
        @[@"Application", @[
              @[@"FWWebViewBridge", @"TestJavascriptBridgeViewController"],
              @[@"FWAlertPlugin", @"TestAlertViewController"],
              @[@"FWAlertController", @"TestCustomerAlertController"],
              @[@"FWToastPlugin", @"TestIndicatorViewController"],
              @[@"FWRefreshPlugin", @"TestTableScrollViewController"],
              @[@"FWRefreshPlugin+Reload", @"TestTableReloadViewController"],
              @[@"FWEmptyPlugin", @"TestEmptyViewController"],
              @[@"FWEmptyPlugin+Scroll", @"TestEmptyScrollViewController"],
              @[@"FWViewPlugin", @"TestViewPluginViewController"],
              @[@"FWImagePreviewPlugin", @"Test.TestPhotoBrowserViewController"],
              @[@"FWImageCropController", @"TestCropViewController"],
              @[@"FWModel", @"TestModelViewController"],
              @[@"FWAsyncSocket", @"TestSocketViewController"],
              @[@"FWViewController", @"Test.TestSwiftViewController"],
              @[@"FWScrollViewController", @"TestControllerViewController"],
              @[@"FWToolbarView", @"TestNavigationTitleViewController"],
              @[@"FWToolbarView+Scroll", @"Test.TestNavigationScrollViewController"],
              @[@"FWToolbarView+TabBar", @"Test.TestNavigationTabBarViewController"],
              @[@"FWTabBarController", @"TestTabBarViewController"],
              @[@"FWCache", @"TestCacheViewController"],
              @[@"FWAssetManager", @"Test.TestAssetViewController"],
              @[@"FWImagePicker", @"TestImagePickerViewController"],
              @[@"FWImagePreview", @"TestImagePreviewViewController"],
              @[@"FWAudioPlayer", @"Test.TestAudioViewController"],
              @[@"FWVideoPlayer", @"Test.TestVideoViewController"],
              ]],
        @[@"Component", @[
              @[@"UIButton+FWApplication", @"TestButtonViewController"],
              @[@"UICollectionView+FWApplication", @"TestCollectionViewController"],
              @[@"UIView+FWAnimation", @"TestAnimationViewController"],
              @[@"UIView+FWBadge", @"TestBadgeViewController"],
              @[@"UIView+FWBorder", @"TestBorderViewController"],
              @[@"UIView+FWLayer", @"TestLayerViewController"],
              @[@"UIView+FWStatistical", @"TestStatisticalViewController"],
              @[@"UIImageView+FWFace", @"TestFacesViewController"],
              @[@"UITableView+FWTemplateLayout", @"TestTableLayoutViewController"],
              @[@"NSObject+FWThread", @"TestThreadViewController"],
              @[@"NSAttributedString+FWOption", @"TestAttributedStringViewController"],
              @[@"UITableView+Hover", @"TestScrollViewController"],
              @[@"UITableView+Background", @"TestTableBackgroundViewController"],
              @[@"UIViewController+FWTransition", @"TestTransitionViewController"],
              @[@"UIViewController+FWApplication", @"Test.TestChildViewController"],
              @[@"UITextField+FWKeyboard", @"TestKeyboardViewController"],
              @[@"UITextView+FWPlaceholder", @"Test.TestTextViewViewController"],
              @[@"UILabel+FWApplication", @"TestLabelViewController"],
              @[@"UIView+FWGradient", @"TestGradientViewController"],
              @[@"NSURL+FWVendor", @"TestUrlViewController"],
              @[@"FWSkeletonView", @"TestSkeletonViewController"],
              @[@"FWPagingView", @"TestNestScrollViewController"],
              @[@"FWPasscodeView", @"TestPasscodeViewController"],
              @[@"MKMapView", @"TestMapViewController"],
              @[@"FWDrawerView", @"TestDrawerViewController"],
              @[@"FWDrawerView+Menu", @"TestMenuViewController"],
              @[@"FWSegmentedControl", @"TestSegmentViewController"],
              @[@"FWTableView", @"TestTableCreateViewController"],
              @[@"FWCollectionView", @"TestCollectionCreateViewController"],
              @[@"FWCollectionViewAlignLayout", @"TestCollectionAlignLayoutController"],
              @[@"FWBannerView", @"TestBannerViewController"],
              @[@"FWBarrageView", @"TestBarrageViewController"],
              @[@"FWGridView", @"TestGridViewController"],
              @[@"FWFloatLayoutView", @"TestFloatLayoutViewController"],
              @[@"FWPopupMenu", @"TestPopupMenuViewController"],
              @[@"FWQrcodeScanView", @"TestQrcodeViewController"],
              @[@"FWSignatureView", @"Test.TestSignatureViewController"],
              ]],
    ]];
    [self.tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    self.navigationItem.titleView = [self titleView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.searchBar.fw.cancelButton setTitle:FWAppBundle.cancelButton forState:UIControlStateNormal];
}

#pragma mark - UISearchBar

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    searchBar.fw.searchIconCenter = NO;
    return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
    searchBar.fw.searchIconCenter = YES;
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    self.isSearch = searchText.fw_trimString.length > 0;
    if (!self.isSearch) {
        self.searchResult = [NSMutableArray array];
        [self.tableView reloadData];
        return;
    }
    
    NSMutableArray *searchResult = [NSMutableArray array];
    NSString *searchString = searchText.fw_trimString.lowercaseString;
    for (NSArray *sectionData in self.tableData) {
        NSMutableArray *sectionResult = [NSMutableArray array];
        for (NSArray *rowData in sectionData[1]) {
            if ([[rowData[0] lowercaseString] containsString:searchString]) {
                [sectionResult addObject:rowData];
            }
        }
        if (sectionResult.count > 0) {
            [searchResult addObject:@[sectionData[0], sectionResult]];
        }
    }
    self.searchResult = searchResult;
    [self.tableView reloadData];
}

#pragma mark - UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.displayData.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *sectionData = [self.displayData objectAtIndex:section];
    NSArray *sectionList = [sectionData objectAtIndex:1];
    return sectionList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [UITableViewCell fw_cellWithTableView:tableView];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    NSArray *sectionData = [self.displayData objectAtIndex:indexPath.section];
    NSArray *sectionList = [sectionData objectAtIndex:1];
    NSArray *rowData = [sectionList objectAtIndex:indexPath.row];
    cell.textLabel.text = [rowData objectAtIndex:0];
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSArray *sectionData = [self.displayData objectAtIndex:section];
    NSString *sectionName = [sectionData objectAtIndex:0];
    return sectionName;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSArray *sectionData = [self.displayData objectAtIndex:indexPath.section];
    NSArray *sectionList = [sectionData objectAtIndex:1];
    NSArray *rowData = [sectionList objectAtIndex:indexPath.row];
    
    Class controllerClass = NSClassFromString([rowData objectAtIndex:1]);
    UIViewController *viewController = [[controllerClass alloc] init];
    viewController.navigationItem.title = [rowData objectAtIndex:0];
    [self.navigationController pushViewController:viewController animated:YES];
}

@end
