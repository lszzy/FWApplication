//
//  CoreModule.swift
//  Core
//
//  Created by wuyong on 2021/1/1.
//

import FWApplication

@objcMembers public class CoreBundle: ModuleBundle {
    private static let sharedBundle: Bundle = {
        return Bundle.fw.bundle(with: CoreBundle.classForCoder(), name: "Core")?.fw.localizedBundle() ?? .main
    }()
    
    public override class func bundle() -> Bundle {
        return sharedBundle
    }
}

@objc protocol CoreService: ModuleProtocol {}

class CoreModule: NSObject, CoreService {
    private static let sharedModule = CoreModule()
    
    static func sharedInstance() -> Self {
        return sharedModule as! Self
    }
    
    static func priority() -> UInt {
        return ModulePriority.default.rawValue + 1
    }
    
    static func setupSynchronously() -> Bool {
        return true
    }
    
    func setup() {
        Theme.setupTheme()
        
        Icon.registerClass(Octicons.self)
        Icon.registerClass(FontAwesome.self)
        Icon.registerClass(FoundationIcons.self)
        Icon.registerClass(IonIcons.self)
        Icon.registerClass(MaterialIcons.self)
    }
}

@objc extension Autoloader {
    func loadCoreModule() {
        Mediator.registerService(CoreService.self, withModule: CoreModule.self)
    }
}
