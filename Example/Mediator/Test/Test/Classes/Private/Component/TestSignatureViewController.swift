//
//  TestSignatureViewController.swift
//  Example
//
//  Created by wuyong on 2020/6/5.
//  Copyright © 2020 wuyong.site. All rights reserved.
//

import FWApplication

@objcMembers class TestSignatureViewController: TestViewController, FWSignatureDelegate {
    
    private lazy var signatureView: FWSignatureView = {
        let signatureView = FWSignatureView()
        signatureView.backgroundColor = UIColor.white
        signatureView.delegate = self
        return signatureView
    }()
    
    private lazy var clearButton: UIButton = {
        let button = Theme.largeButton()
        button.setTitle("Clear", for: .normal)
        button.fwAddTouch { [weak self] (sender) in
            self?.signatureView.clear()
        }
        return button
    }()
    
    private lazy var saveButton: UIButton = {
        let button = Theme.largeButton()
        button.setTitle("Save", for: .normal)
        button.fwAddTouch { [weak self] (sender) in
            if let image = self?.signatureView.getSignature(scale: 10) {
                image.fwSave(block: nil)
                self?.signatureView.clear()
            }
        }
        return button
    }()
    
    override func renderView() {
        fwView.addSubview(signatureView)
        signatureView.fwLayoutChain.left().right().centerYToView(view as Any, withOffset: -100).height(300)
        
        fwView.addSubview(clearButton)
        clearButton.fwLayoutChain.centerX().topToBottomOfView(signatureView, withOffset: 20)
        
        fwView.addSubview(saveButton)
        saveButton.fwLayoutChain.centerX().topToBottomOfView(clearButton, withOffset: 20)
    }
    
    func didStart(_ view: FWSignatureView) {
        print("Started Drawing")
    }
    
    func didFinish(_ view: FWSignatureView) {
        print("Finished Drawing")
    }
    
}
