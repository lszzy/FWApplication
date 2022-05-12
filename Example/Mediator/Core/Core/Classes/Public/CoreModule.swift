//
//  CoreModule.swift
//  Core
//
//  Created by wuyong on 2021/1/1.
//

import FWApplication

@objcMembers public class CoreBundle: FWModuleBundle {
    private static let sharedBundle: Bundle = {
        return Bundle.fw.bundle(with: CoreBundle.classForCoder(), name: "Core")?.fw.localizedBundle() ?? .main
    }()
    
    public override class func bundle() -> Bundle {
        return sharedBundle
    }
}

@objc protocol CoreService: FWModuleProtocol {}

class CoreModule: NSObject, CoreService {
    private static let sharedModule = CoreModule()
    
    static func sharedInstance() -> Self {
        return sharedModule as! Self
    }
    
    static func priority() -> UInt {
        return FWModulePriorityDefault + 1
    }
    
    static func setupSynchronously() -> Bool {
        return true
    }
    
    func setup() {
        Theme.setupTheme()
        
        FWIcon.registerClass(Octicons.self)
        FWIcon.registerClass(FontAwesome.self)
        FWIcon.registerClass(FoundationIcons.self)
        FWIcon.registerClass(IonIcons.self)
        FWIcon.registerClass(MaterialIcons.self)
    }
}

@objc extension Autoloader {
    func loadCoreModule() {
        FWMediator.registerService(CoreService.self, withModule: CoreModule.self)
    }
}
