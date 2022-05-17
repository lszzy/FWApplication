//
//  TestSignatureViewController.swift
//  Example
//
//  Created by wuyong on 2020/6/5.
//  Copyright © 2020 wuyong.site. All rights reserved.
//

import FWApplication

@objcMembers class TestSignatureViewController: TestViewController, SignatureDelegate {
    
    private lazy var signatureView: SignatureView = {
        let signatureView = SignatureView()
        signatureView.backgroundColor = UIColor.white
        signatureView.delegate = self
        return signatureView
    }()
    
    private lazy var clearButton: UIButton = {
        let button = Theme.largeButton()
        button.setTitle("Clear", for: .normal)
        button.fw.addTouch { [weak self] (sender) in
            self?.signatureView.clear()
        }
        return button
    }()
    
    private lazy var saveButton: UIButton = {
        let button = Theme.largeButton()
        button.setTitle("Save", for: .normal)
        button.fw.addTouch { [weak self] (sender) in
            if let image = self?.signatureView.getSignature(scale: 10) {
                image.__fw.saveImage()
                self?.signatureView.clear()
            }
        }
        return button
    }()
    
    override func renderView() {
        view.addSubview(signatureView)
        signatureView.fw.layoutChain.left().right().centerY(toView: view as Any, offset: -100).height(300)
        
        view.addSubview(clearButton)
        clearButton.fw.layoutChain.centerX().topToBottom(ofView: signatureView, offset: 20)
        
        view.addSubview(saveButton)
        saveButton.fw.layoutChain.centerX().topToBottom(ofView: clearButton, offset: 20)
    }
    
    func didStart(_ view: SignatureView) {
        print("Started Drawing")
    }
    
    func didFinish(_ view: SignatureView) {
        print("Finished Drawing")
    }
    
}
