//
//  TestModule.m
//  Pods
//
//  Created by wuyong on 2021/1/2.
//

#import "TestModule.h"
#import "TestModuleController.h"

@interface FWAutoloader (TestModule)

@end

@implementation FWAutoloader (TestModule)

- (void)loadTestModule
{
    [FWMediator registerService:@protocol(TestModuleService) withModule:TestModule.class];
}

@end

@implementation TestModule

FWDefSingleton(TestModule);

+ (NSUInteger)priority
{
    return FWModulePriorityDefault - 1;
}

- (UIViewController *)testViewController
{
    return [[TestModuleController alloc] init];
}

@end

@implementation TestBundle

+ (NSBundle *)bundle
{
    static NSBundle *bundle = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        bundle = [[NSBundle fw_bundleWithClass:[self class] name:@"Test"] fw_localizedBundle];
    });
    return bundle;
}

@end
