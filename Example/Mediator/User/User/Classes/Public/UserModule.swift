//
//  UserModule.swift
//  User
//
//  Created by wuyong on 2021/1/1.
//

import FWApplication
import Mediator

@objc extension Autoloader {
    func loadUserModule() {
        FWMediator.registerService(UserModuleService.self, withModule: UserModule.self)
    }
}

@objcMembers public class UserBundle: FWModuleBundle {
    private static let sharedBundle: Bundle = {
        return Bundle.fw.bundle(with: UserBundle.classForCoder(), name: "UserModule")?.fw.localizedBundle() ?? .main
    }()
    
    public override class func bundle() -> Bundle {
        return sharedBundle
    }
}

@objcMembers public class UserModule: NSObject, UserModuleService {
    private static let sharedModule = UserModule()
    
    @UserDefaultAnnotation("userId", defaultValue: "")
    private var userId: String
    
    @UserDefaultAnnotation("userName", defaultValue: "")
    private var userName: String
    
    public static func sharedInstance() -> Self {
        return sharedModule as! Self
    }
    
    public func isLogin() -> Bool {
        return userId.count > 0
    }
    
    public func userInfo() -> UserInfo? {
        if userId.count < 1 { return nil }
        
        let userInfo = UserInfo()
        userInfo.userId = userId
        userInfo.userName = userName
        userInfo.userAvatar = UserBundle.imageNamed("user")
        return userInfo
    }
    
    public func login(_ completion: (() -> Void)?) {
        let viewController = UserLoginController()
        viewController.completion = { [weak self] in
            self?.userId = "1"
            self?.userName = "test"
            completion?()
        }
        let navigationController = UINavigationController(rootViewController: viewController)
        FWRouter.present(navigationController, animated: true, completion: nil)
    }
    
    public func logout(_ completion: (() -> Void)?) {
        userId = ""
        userName = ""
        completion?()
    }
}
