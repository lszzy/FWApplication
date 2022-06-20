# 更新日志

## [3.3.2] - 2022-06-20

### Changed
* 拆分弹窗插件showAlert和showSheet方法
* 弹窗插件新增自定义样式配置参数

## [3.3.1] - 2022-06-15

### Changed
* VC动画新增边缘手势关闭功能
* 优化countDown方法后台时计算问题
* 修复导航栏转场动画异常问题
* 兼容FWFramework 3.3.1版本

## [3.3.0] - 2022-06-11

### Added
* 新增应用框架配置默认模板类
* 兼容FWFramework 3.3.0版本

## [3.2.2] - 2022-06-08

### Changed
* 修改网络组件属性名称及参数默认值
* 优化消息为空时不显示toast弹窗

## [3.2.1] - 2022-06-02

### Added
* 新增Swift网络Mock组件
* 新增网络请求失败时重试功能

## [3.2.0] - 2022-05-27

### Changed
* 重构templateHeight为通用缓存
* 优化TableViewDelegate代理类
* 兼容FWFramework 3.2.0版本

## [3.1.0] - 2022-05-26

### Added
* 重构Swift版本Api方法
* 新增FW全局方法，可自定义调用名称
* 重构部分组件，增加若干功能
* 此版本与之前的版本不兼容，须迁移代码
* 兼容FWFramework 3.1.0版本

## [3.0.0] - 2022-04-29

### Added
* 全新的版本，使用.fw.调用方式
* 可自定义.fw.为任意调用名称
* 重构部分组件，增加若干功能
* 此版本与之前的版本不兼容，须迁移代码
* 兼容FWFramework 3.0.0版本

## [1.4.0] - 2022-02-12

### Added
* FWViewController新增renderLayout钩子方法

### Changed
* FWToastPlugin消息吐司支持不自动隐藏方法

## [1.3.1] - 2022-01-17

### Added
* 支持控制器或视图单独设置所用插件

## [1.3.0] - 2022-01-15

### Added
* FWAlertPlugin支持自定义样式配置
* 支持FWApplication子模块单独引入

## [1.2.1] - 2022-01-11

### Fixed
* 修复Swift访问不到appearance单例方法问题

## [1.2.0] - 2021-12-31

### Added
* 重构Pod子模块，拆分OC和Swift代码
* 支持Swift Package Manager
* 新增FWStatisticalObject判断曝光和完成属性

## [1.1.1] - 2021-12-30

### Changed

* 重构FWStatisticalManager点击和曝光埋点统计实现方案
* 统一Changed埋点为Click埋点统计
* 支持自定义点击和曝光埋点事件，支持曝光时长

## [1.1.0] - 2021-12-28

### Added

* UICollectionViewFlowLayout支持section背景设置
* 新增FWCollectionViewAlignLayout组件

## [1.0.4] - 2021-12-27

### Added

* 新增FWCollectionViewAlignLayout组件

## [1.0.3] - 2021-12-20

### Added

* 图片浏览器支持本地图片路径
* 自定义弹窗插件新增间距配置

## [1.0.2] - 2021-12-16

### Added

* 图片选择器新增图片固定列数参数

## [1.0.1] - 2021-12-15

### Added

* FWAlertPlugin等插件支持多级present
* 图片选择器单选预览时支持左右滚动

## [1.0.0] - 2021-12-09

### Added

* 从FWFramework拆分FWApplication，1.0.0版本发布
