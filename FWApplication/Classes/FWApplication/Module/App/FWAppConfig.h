//
//  FWAppConfig.h
//  FWApplication
//
//  Created by wuyong on 2022/6/10.
//

@import FWFramework;

NS_ASSUME_NONNULL_BEGIN

/// 框架内置应用配置类
@interface FWAppConfig : FWConfiguration

@end

/// 框架内置应用默认模板类
@interface FWAppConfigDefaultTemplate : NSObject <FWConfigurationTemplateProtocol>

@end

NS_ASSUME_NONNULL_END
