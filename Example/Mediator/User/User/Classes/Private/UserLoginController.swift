//
//  UserLoginController.swift
//  User
//
//  Created by wuyong on 2021/1/1.
//

import FWApplication
import Core

@objcMembers class UserLoginController: UIViewController, FWViewController {
    var completion: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = UserBundle.localizedString("loginButton")
        fw.setLeftBarItem(FWIcon.closeImage) { [weak self] (sender) in
            self?.fw.closeViewController(animated: true)
        }
        
        let button = UIButton(type: .system)
        button.setTitle(UserBundle.localizedString("loginButton"), for: .normal)
        button.setImage(UserBundle.imageNamed("user")?.fw.compressImage(withMaxWidth: 25), for: .normal)
        button.fw.addTouch { [weak self] (sender) in
            self?.dismiss(animated: true, completion: self?.completion)
        }
        view.addSubview(button)
        button.fw.layoutChain.center()
    }
}
