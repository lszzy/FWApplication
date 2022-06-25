//
//  NSBundle+Toolkit.swift
//  FWApplication
//
//  Created by wuyong on 2022/5/19.
//

import UIKit
#if FWMacroSPM
import FWFrameworkCompatible
import FWApplication
#endif

extension Wrapper where Base: Bundle {
    
    /// 自定义GoogleMaps反解析地址结果语言，为nil时不指定
    public static func setGoogleMapsLanguage(_ language: String?) {
        Base.__fw_setGoogleMapsLanguage(language)
    }

    /// 自定义GooglePlaces查询地址结果语言，为nil时不指定
    public static func setGooglePlacesLanguage(_ language: String?) {
        Base.__fw_setGooglePlacesLanguage(language)
    }
    
}
