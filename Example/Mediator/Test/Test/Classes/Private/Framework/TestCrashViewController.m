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
                                         @[@"NSNumber", @"onNumber"],
                                         @[@"NSString", @"onString"],
                                         @[@"NSMutableString", @"onMutableString"],
                                         @[@"NSAttributedString", @"onAttributedString"],
                                         @[@"NSMutableAttributedString", @"onMutableAttributedString"],
                                         @[@"NSArray", @"onArray"],
                                         @[@"NSMutableArray", @"onMutableArray"],
                                         @[@"NSDictionary", @"onDictionary"],
                                         @[@"NSMutableDictionary", @"onMutableDictionary"],
                                         @[@"NSObject", @"onObject"],
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

- (void)onNumber
{
    id value = nil;
    [@(1) isEqualToNumber:value];
    [@(1) compare:value];
}

- (void)onString
{
    NSString *str = @"test";
    [str characterAtIndex:100];
    NSString *subStr = [str substringFromIndex:100];
    subStr = [str substringToIndex:100];
    NSRange range = NSMakeRange(0, 100);
    subStr = [str substringWithRange:range];
    
    NSString *nilStr = nil;
    subStr = [str stringByReplacingOccurrencesOfString:nilStr withString:nilStr];
    
    range = NSMakeRange(0, 1000);
    subStr = [str stringByReplacingOccurrencesOfString:@"chen" withString:@"" options:NSCaseInsensitiveSearch range:range];
    
    range = NSMakeRange(0, 1000);
    subStr = [str stringByReplacingCharactersInRange:range withString:@"cff"];
}

- (void)onMutableString
{
    NSMutableString *strM = [NSMutableString stringWithFormat:@"chenfanfang"];
    NSRange range = NSMakeRange(0, 1000);
    [strM replaceCharactersInRange:range withString:@"--"];
    
    strM = [NSMutableString stringWithFormat:@"chenfanfang"];
    [strM insertString:@"cool" atIndex:1000];
    
    strM = [NSMutableString stringWithFormat:@"chenfanfang"];
    range = NSMakeRange(0, 1000);
    [strM deleteCharactersInRange:range];
}

- (void)onAttributedString
{
    NSString *str = nil;
    NSAttributedString *attributedStr = [[NSAttributedString alloc] initWithString:str];
    
    NSAttributedString *nilAttributedStr = nil;
    attributedStr = [[NSAttributedString alloc] initWithAttributedString:nilAttributedStr];
    
    NSDictionary *attributes = @{
                           NSForegroundColorAttributeName : [UIColor redColor]
                           };
    NSString *nilStr = nil;
    attributedStr = [[NSAttributedString alloc] initWithString:nilStr attributes:attributes];
}

- (void)onMutableAttributedString
{
    NSString *nilStr = nil;
    NSMutableAttributedString *attrStrM = [[NSMutableAttributedString alloc] initWithString:nilStr];
    
    NSDictionary *attributes = @{
                                 NSForegroundColorAttributeName : [UIColor redColor]
                                 };
    attrStrM = [[NSMutableAttributedString alloc] initWithString:nilStr attributes:attributes];
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
    NSArray *array = @[@"chenfanfang", nilStr, @"iOSDeveloper"];
    arr = @[@"chenfanfang", @"iOS_Dev"];
    object = arr[100];
    
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:100];
    [array objectsAtIndexes:indexSet];
    
    array = @[@"1", @"2", @"3"];
    NSRange range = NSMakeRange(0, 11);
    __unsafe_unretained id cArray[range.length];
    [array getObjects:cArray range:range];
}

- (void)onMutableArray
{
    NSMutableArray *array = @[@"chenfanfang"].mutableCopy;
    id object = array[2];
    object = nil;
    array[3] = @"iOS";
    [array removeObjectAtIndex:5];
    [array insertObject:@"cool" atIndex:5];
    NSRange range = NSMakeRange(0, 11);
    __unsafe_unretained id cArray[range.length];
    [array getObjects:cArray range:range];
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
}

- (void)onMutableDictionary
{
    NSMutableDictionary *dict = @{
                                   @"name" : @"chenfanfang"
                                   
                                   }.mutableCopy;
    NSString *ageKey = nil;
    dict[ageKey] = @(25);
    
    dict = [NSMutableDictionary dictionary];
    [dict setObject:@(25) forKey:ageKey];
    
    dict = @{
          @"name" : @"chenfanfang",
          @"age" : @(25)
          
          }.mutableCopy;
    NSString *key = nil;
    [dict removeObjectForKey:key];
}

- (void)onObject
{
    id object = [NSObject new];
    [object onNull];
    [object objectForKey:@"key"];
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
