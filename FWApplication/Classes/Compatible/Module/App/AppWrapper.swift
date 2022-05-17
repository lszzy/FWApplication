//
//  AppWrapper.swift
//  FWApplication
//
//  Created by wuyong on 2020/6/5.
//  Copyright © 2020 wuyong.site. All rights reserved.
//

import UIKit
#if FWMacroSPM
import FWApplication
#endif

extension FW {
    /// 根据名称加载UIImage，优先加载图片文件(无缓存)，文件不存在时尝试系统imageNamed方式(有缓存)
    public static func image(_ named: String) -> UIImage? {
        return UIImage.__fw.imageNamed(named)
    }
}
