//
//  TestCrashViewController.m
//  Example
//
//  Created by wuyong on 2020/2/22.
//  Copyright © 2020 wuyong.site. All rights reserved.
//

#import "TestCrashViewController.h"

@interface TestCrashViewController () <FWTableViewController>

@end

@implementation TestCrashViewController

- (UITableViewStyle)renderTableStyle
{
    return UITableViewStyleGrouped;
}

- (void)renderNavbar
{
    [self fwSetRightBarItem:@"捕获异常" block:^(id  _Nonnull sender) {
        [FWException startCaptureExceptions];
    }];
}

- (void)renderData
{
    [self.tableData addObjectsFromArray:@[
                                         @[@"NSNull", @"onNull"],
                                         @[@"NSString", @"onString"],
                                         @[@"NSArray", @"onArray"],
                                         @[@"NSDictionary", @"onDictionary"],
                                         @[@"KVC", @"onKvc"],
                                         ]];
}

#pragma mark - TableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tableData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [UITableViewCell fwCellWithTableView:tableView];
    NSArray *rowData = [self.tableData objectAtIndex:indexPath.row];
    cell.textLabel.text = [rowData objectAtIndex:0];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSArray *rowData = [self.tableData objectAtIndex:indexPath.row];
    SEL selector = NSSelectorFromString([rowData objectAtIndex:1]);
    if ([self respondsToSelector:selector]) {
        FWIgnoredBegin();
        [self performSelector:selector];
        FWIgnoredEnd();
    }
}

#pragma mark - Action

- (void)onNull
{
    id object = [NSNull null];
    [object onNull];
}

- (void)onString
{
    NSString *str = @"test";
    NSString *subStr = [str substringFromIndex:100];
    subStr = [str substringToIndex:100];
    NSRange range = NSMakeRange(0, 100);
    subStr = [str substringWithRange:range];
    
    str = [NSString stringWithFormat:@"test"];
    subStr = [str substringFromIndex:100];
    subStr = [str substringToIndex:100];
    subStr = [str substringWithRange:range];
    
    str = @"test".mutableCopy;
    subStr = [str substringFromIndex:100];
    subStr = [str substringToIndex:100];
    subStr = [str substringWithRange:range];
}

- (void)onArray
{
    NSArray *arr = @[@1, @2, @3];
    [arr objectAtIndex:10];
    [arr subarrayWithRange:NSMakeRange(2, 10)];
    
    NSMutableArray *arrm = arr.mutableCopy;
    id object = nil;
    [arrm addObject:object];
    [arrm removeObjectAtIndex:10];
    [arrm replaceObjectAtIndex:10 withObject:@3];
    
    NSString *nilStr = nil;
    arr = @[@"chenfanfang", nilStr, @"iOSDeveloper"];
    arr = @[@"chenfanfang", @"iOS_Dev"];
    object = arr[100];
    
    NSMutableArray *marray = @[@"chenfanfang"].mutableCopy;
    object = marray[2];
    object = nil;
    marray[3] = @"iOS";
    [marray removeObjectAtIndex:5];
    [marray insertObject:@"cool" atIndex:5];
}

- (void)onDictionary
{
    NSDictionary *dict = @{@"a": @1};
    NSString *nilStr = nil;
    [dict objectForKey:nilStr];
    
    NSMutableDictionary *dictm = dict.mutableCopy;
    [dictm removeObjectForKey:nilStr];
    [dictm setObject:nilStr forKey:nilStr];
    
    dict = @{
           @"name" : @"chenfanfang",
           @"age" : nilStr
           };
    
    NSMutableDictionary *mdict = @{
                                   @"name" : @"chenfanfang"
                                   
                                   }.mutableCopy;
    NSString *ageKey = nil;
    mdict[ageKey] = @(25);
    
    mdict = [NSMutableDictionary dictionary];
    [mdict setObject:@(25) forKey:ageKey];
    
    mdict = @{
          @"name" : @"chenfanfang",
          @"age" : @(25)
          
          }.mutableCopy;
    NSString *key = nil;
    [mdict removeObjectForKey:key];
}

- (void)onKvc
{
    UITableView *anyObject = [UITableView new];
    [anyObject setValue:self forKey:@"AvoidCrash"];
    [anyObject setValue:self forKeyPath:@"AvoidCrash"];
    NSDictionary *dictionary = @{
                                 @"name" : @"chenfanfang"
                                 };
    
    [anyObject setValuesForKeysWithDictionary:dictionary];
}

@end
