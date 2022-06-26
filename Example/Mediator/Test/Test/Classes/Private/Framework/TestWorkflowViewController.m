//
//  TestWorkflowViewController.m
//  Example
//
//  Created by wuyong on 16/11/13.
//  Copyright © 2016年 ocphp.com. All rights reserved.
//

#import "TestWorkflowViewController.h"

@interface TestWorkflowViewController ()

@end

@implementation TestWorkflowViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.step < 1) {
        self.step = 1;
    }
    
    self.fw_workflowName = [NSString stringWithFormat:@"workflow.%ld", self.step];
    self.navigationItem.title = [NSString stringWithFormat:@"工作流-%ld", self.step];
    
    if (self.step < 3) {
        [self fw_setRightBarItem:@"下一步" target:self action:@selector(onNext)];
    } else {
        [self fw_addRightBarItem:@"退出" target:self action:@selector(onExit)];
        [self fw_addRightBarItem:@"重来" target:self action:@selector(onOpen)];
    }
}

#pragma mark - Action

- (void)onNext
{
    TestWorkflowViewController *workflow = [[TestWorkflowViewController alloc] init];
    workflow.step = self.step + 1;
    [self.navigationController pushViewController:workflow animated:YES];
}

- (void)onExit
{
    [self.navigationController fw_popWorkflows:@[@"workflow"] animated:YES];
}

- (void)onOpen
{
    [self.navigationController fw_pushViewController:[[TestWorkflowViewController alloc] init] popWorkflows:@[@"workflow"] animated:YES];
}

@end
