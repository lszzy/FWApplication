//
//  Mediator.swift
//  Mediator
//
//  Created by lingshizhuangzi@gmail.com on 01/01/2021.
//  Copyright (c) 2021 lingshizhuangzi@gmail.com. All rights reserved.
//

import FWApplication

@objc public protocol TestModuleService: ModuleProtocol {
    func testViewController() -> UIViewController
}
