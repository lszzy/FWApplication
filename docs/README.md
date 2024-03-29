# FWApplication

[![Pod Version](https://img.shields.io/cocoapods/v/FWApplication?style=flat)](http://cocoadocs.org/docsets/FWApplication/)
[![Pod Platform](https://img.shields.io/cocoapods/p/FWApplication.svg?style=flat)](http://cocoadocs.org/docsets/FWApplication/)
[![Pod License](https://img.shields.io/cocoapods/l/FWApplication.svg?style=flat)](https://github.com/lszzy/FWApplication/blob/master/LICENSE)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/lszzy/FWApplication)

# [FWFramework](https://github.com/lszzy/FWFramework)

# [中文](README_CN.md)

## Tutorial
iOS application framework, convenient for iOS development, compatible with OC and Swift.

All Swizzles in this framework will not take effect by default and will not affect existing projects. They need to be manually opened or invoked to take effect. This library has been used in formal projects, and will continue to be maintained and expanded in the future. Everyone is welcome to use and provide valuable comments to grow together.

## Installation
It is recommended to use CocoaPods or Swift Package Manager to install and automatically manage dependencies. For manual import, please refer to Example project configuration.

### CocoaPods
This framework supports CocoaPods, Podfile example:

	platform :ios, '11.0'
	use_frameworks!

	target 'Example' do
	  # Import the default subspecs
	  pod 'FWApplication'
	  
	  # Import the specified subspecs, see the podspec file for the list of subspecs
	  # pod 'FWApplication', :subspecs => ['FWApplication', 'Compatible', 'SDWebImage', 'Lottie']
	end

### Swift Package Manager
This framework supports Swift Package Manager, just add and check the required modules, Package example:

	https://github.com/lszzy/FWApplication.git
	
	# Check and import the default submodule
	import FWApplication
	
	# Check and import the specified sub-modules, see the Package.swift file for the list of sub-modules
	import FWApplicationCompatible
	import FWApplicationSDWebImage
	import FWApplicationLottie

## [Api](https://fwapplication.wuyong.site)
The document is located in the docs folder, just open index.html in the browser, or run docs.sh to automatically generate the Api document.

## [Changelog](CHANGELOG.md)
As this framework is constantly upgrading, optimizing and expanding new functions, the Api of each version may be slightly changed. If a compilation error is reported when the new version is upgraded, the solution is as follows:

	1. Just change to specify the pod version number to import, the recommended way, does not affect the project progress, upgrade to the new version only when you have time, example: pod'FWApplication', '3.8.1'
	2. Upgrade to the new version, please pay attention to the version update log. Obsolete Api will be migrated to the Deprecated submodule as appropriate, and will be deleted in subsequent versions

## Vendor
This framework uses a lot of third-party libraries. Thanks to the authors of all third-party libraries. I will not list them all here. For details, please refer to the relevant links of the source file.
 
	In the introduction of third-party libraries, in order to be compatible with existing project pod dependencies, as well as to customize changes and bug fixes of third-party libraries, and to facilitate subsequent maintenance, this framework uniformly modified the FW class prefix and fw method prefix. If there is any inconvenience during use, Please understand.
	If you are the author of a third-party open source library, if this library violates your rights, please let me know, and I will immediately remove the use of the third-party open source library. 

## Support
[wuyong.site](http://www.wuyong.site)
