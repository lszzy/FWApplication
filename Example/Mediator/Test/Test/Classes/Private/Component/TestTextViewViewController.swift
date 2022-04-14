//
//  TestTextViewViewController.swift
//  Example
//
//  Created by wuyong on 2020/6/5.
//  Copyright © 2020 wuyong.site. All rights reserved.
//

import FWApplication

@objcMembers class TestTextViewViewController: TestViewController {
    private lazy var textView: UITextView = {
        let result = UITextView(frame: CGRect(x: 16, y: 16, width: FWScreenWidth - 32, height: 44))
        result.fw.placeholder = "我是TextView1"
        result.fw.setBorderColor(Theme.borderColor, width: 0.5, cornerRadius: 8)
        result.fw.autoHeightEnabled = true
        result.fw.maxLength = 100
        result.fw.minHeight = 44
        result.fw.touchResign = true
        result.fw.verticalAlignment = .center
        return result
    }()
    
    private lazy var textView2: UITextView = {
        let result = UITextView()
        result.fw.placeholder = "我是TextView2\n我有两行"
        result.fw.setBorderColor(Theme.borderColor, width: 0.5, cornerRadius: 8)
        result.fw.minHeight = 44
        result.fw.autoHeight(withMaxHeight: 100) { height in
            result.fw.layoutChain.height(height)
        }
        result.fw.touchResign = true
        result.fw.verticalAlignment = .center
        return result
    }()
    
    private lazy var textView3: UITextView = {
        let result = UITextView()
        result.fw.placeholder = "我是TextView2\n我是第二行\n我是第三行"
        result.fw.setBorderColor(Theme.borderColor, width: 0.5, cornerRadius: 8)
        result.fw.touchResign = true
        result.fw.verticalAlignment = .center
        return result
    }()
    
    override func renderView() {
        view.addSubview(textView)
        view.addSubview(textView2)
        view.addSubview(textView3)
        textView2.fw.layoutChain.left(16).right(16).topToBottomOfView(textView, withOffset: 16)
        textView3.fw.layoutChain.left(16).right(16).topToBottomOfView(textView2, withOffset: 16).height(44)
    }
    
    override func renderModel() {
        fw.setRightBarItem("切换") { [weak self] sender in
            self?.fw.showSheet(withTitle: nil, message: nil, cancel: "取消", actions: ["垂直居上", "垂直居中", "垂直居下"], actionBlock: { index in
                var verticalAlignment: UIControl.ContentVerticalAlignment = .top
                if index == 1 {
                    verticalAlignment = .center
                } else if index == 2 {
                    verticalAlignment = .bottom
                }
                self?.textView.fw.verticalAlignment = verticalAlignment
                self?.textView2.fw.verticalAlignment = verticalAlignment
                self?.textView3.fw.verticalAlignment = verticalAlignment
            })
        }
    }
}
