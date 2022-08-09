# Changelog

## [3.8.2] - 2022-08-10

### Fixed
* Fix EmptyPluginView not calling update

## [3.8.1] - 2022-08-03

### Changed
* Optimize PluginView progress bar view
* Optimize ViewContext to support subscribing to object and userInfo
* Optimize SwiftUI module directory structure

## [3.8.0] - 2022-08-02

### Added
* Added a large number of SwiftUI basic components to facilitate development
* Added methods to monitor View size and scroll view contentOffset
* Added a method to get the controller where View is located
* Added Introspect component and pull-down refresh component
* Added View configuration navigation bar method, which is common to UIKit
* Added PluginView for loading view specification plugins, common to UIKit
* Added HostingView for loading View as UIView
* Added StateView state machine view
* Added HostingController controller, common to UIKit
* Compatible with FWFramework 3.8.0 version

## [3.7.0] - 2022-07-27

### Added
* Added SwiftUI web image, wrapper, toolkit components
* Compatible with FWFramework 3.7.0 version

## [3.6.3] - 2022-07-18

### Added
* Added optional Lottie plugin to load Lottie animations
* Pull-down refresh plugin supports progress bar effect when dragging
* Pull-up additional plug-in support shows that there are no more views
* The shortcut jump TabBar is compatible with the case where the root controller is the navigation controller

## [3.6.2] - 2022-07-14

### Added
* FWTagCollectionView added selected font configuration

## [3.6.1] - 2022-07-13

### Changed
* Toast plugin supports controller configuration displayed in the window

## [3.6.0] - 2022-07-11

### Changed
* Refactor the image plugin to create a view method
* Modify the WebView bridge parameter context to weak reference
* Compatible with FWFramework 3.6.0 version

## [3.5.1] - 2022-07-06

### Fixed
* Image plugin supports ignore cache option
* Fix the problem that the empty interface occasionally displays abnormally
* Fix Tabbar controller loading remote image issue

## [3.5.0] - 2022-07-04

### Added
* Added batch registration WebView bridge class method
* Migrate some common methods to FWFramework
* Compatible with FWFramework 3.5.0 version

## [3.4.0] - 2022-06-26

### Changed
* Refactored OC version classification API, changed to fw_ prefix, removed Wrapper
* Added a new closing method for the pop-up plug-in
* Compatible with FWFramework 3.4.0 version

## [3.3.2] - 2022-06-20

### Changed
* Split popup plugin showAlert and showSheet methods
* Added custom style configuration parameters for popup plugins

## [3.3.1] - 2022-06-15

### Changed
* VC animation adds edge gesture close function
* Optimize the calculation problem in the background of the countDown method
* Fix the abnormal problem of navigation bar transition animation
* Compatible with FWFramework 3.3.1 version

## [3.3.0] - 2022-06-11

### Added
* New application framework configuration default template class
* Compatible with FWFramework 3.3.0 version

## [3.2.2] - 2022-06-08

### Changed
* Modify network component attribute names and parameter default values
* The toast pop-up window is not displayed when the optimization message is empty

## [3.2.1] - 2022-06-02

### Added
* Added Swift Network Mock component
* Added retry function when network request fails

## [3.2.0] - 2022-05-27

### Changed
* Refactor templateHeight to generic cache
* Optimize the TableViewDelegate proxy class
* Compatible with FWFramework 3.2.0 version

## [3.1.0] - 2022-05-26

### Added
* Refactor Swift version Api method
* Added FW global method, you can customize the call name
* Refactored some components and added several functions
* This version is not compatible with the previous version, the code must be migrated
* Compatible with FWFramework 3.1.0 version

## [3.0.0] - 2022-04-29

### Added
* Brand new version, using .fw. calling method
* Customizable .fw. for any call name
* Refactored some components and added several functions
* This version is not compatible with the previous version, the code must be migrated
* Compatible with FWFramework 3.0.0 version

## [1.4.0] - 2022-02-12

### Added
* FWViewController adds renderLayout hook method

### Changed
* FWToastPlugin message toast support does not automatically hide the method

## [1.3.1] - 2022-01-17

### Added
* Support controller or view to set plugins used individually

## [1.3.0] - 2022-01-15

### Added
* FWAlertPlugin supports custom style configuration
* Support FWApplication sub-module to be imported separately

## [1.2.1] - 2022-01-11

### Fixed
* Fix the problem that Swift cannot access the appearance singleton method

## [1.2.0] - 2021-12-31

### Added
* Refactored Pod sub-module, split OC and Swift code
* Support Swift Package Manager
* Added FWStatisticalObject to determine exposure and completion attributes

## [1.1.1] - 2021-12-30

### Changed

* Refactored FWStatisticalManager click and exposure buried point statistics implementation plan
* Unified Changed burying point is Click burying point statistics
* Support custom click and exposure buried point events, support exposure time

## [1.1.0] - 2021-12-28

### Added

* UICollectionViewFlowLayout supports section background settings
* Added FWCollectionViewAlignLayout component

## [1.0.4] - 2021-12-27

### Added

* Added FWCollectionViewAlignLayout component

## [1.0.3] - 2021-12-20

### Added

* Picture browser supports local picture path
* Added spacing configuration for custom pop-up plugins

## [1.0.2] - 2021-12-16

### Added

* The picture picker adds a fixed number of picture columns parameter

## [1.0.1] - 2021-12-15

### Added

* Plug-ins such as FWAlertPlugin support multi-level present
* The picture selector supports left and right scrolling during single selection preview

## [1.0.0] - 2021-12-09

### Added

* Split FWApplication from FWFramework, version 1.0.0 is released
