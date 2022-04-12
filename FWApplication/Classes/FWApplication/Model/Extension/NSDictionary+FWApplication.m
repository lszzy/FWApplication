/**
 @header     NSDictionary+FWApplication.m
 @indexgroup FWApplication
      NSDictionary分类
 @author     wuyong
 @copyright  Copyright © 2018年 wuyong.site. All rights reserved.
 @updated    2018-09-17
 */

#import "NSDictionary+FWApplication.h"
#import "NSArray+FWApplication.h"
@import FWFramework;

@implementation NSDictionary (FWApplication)

- (id)fwRandomKey
{
    if (self.count < 1) return nil;
    
    return self.allKeys.fw.randomObject;
}

- (id)fwRandomObject
{
    if (self.count < 1) return nil;
        
    return self.allValues.fw.randomObject;
}

- (id)fwRandomWeightKey
{
    if (self.count < 1) return nil;
    
    return [self.allKeys fwRandomObject:self.allValues];
}

- (BOOL)fwIncludeNull
{
    __block BOOL includeNull = NO;
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([obj isKindOfClass:[NSNull class]]) {
            includeNull = YES;
            *stop = YES;
        }
    }];
    return includeNull;
}

- (NSDictionary *)fwRemoveNull
{
    return [self fwRemoveNullRecursive:YES];
}

- (NSDictionary *)fwRemoveNullRecursive:(BOOL)recursive
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:self];
    for (id key in [self allKeys]) {
        id object = [self objectForKey:key];
        
        if (object == [NSNull null]) {
            [dictionary removeObjectForKey:key];
        }
        
        if (recursive) {
            if ([object isKindOfClass:[NSDictionary class]]) {
                NSDictionary *subdictionary = [object fwRemoveNullRecursive:YES];
                [dictionary setValue:subdictionary forKey:key];
            }
            
            if ([object isKindOfClass:[NSArray class]]) {
                NSArray *subarray = [(NSArray *)object fwRemoveNullRecursive:YES];
                [dictionary setValue:subarray forKey:key];
            }
        }
    }
    return [dictionary copy];
}

@end

#pragma mark - FWMutableDictionary

#define INIT(...) \
    self = super.init; \
    if (!self) return nil; \
    __VA_ARGS__; \
    if (!_dic) return nil; \
    _lock = dispatch_semaphore_create(1); \
    return self;

#define LOCK(...) \
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER); \
    __VA_ARGS__; \
    dispatch_semaphore_signal(_lock);

@implementation FWMutableDictionary {
    NSMutableDictionary *_dic;
    dispatch_semaphore_t _lock;
}

#pragma mark - init

- (instancetype)init {
    INIT(_dic = [[NSMutableDictionary alloc] init]);
}

- (instancetype)initWithObjects:(NSArray *)objects forKeys:(NSArray *)keys {
    INIT(_dic =  [[NSMutableDictionary alloc] initWithObjects:objects forKeys:keys]);
}

- (instancetype)initWithCapacity:(NSUInteger)capacity {
    INIT(_dic = [[NSMutableDictionary alloc] initWithCapacity:capacity]);
}

- (instancetype)initWithObjects:(const id[])objects forKeys:(const id <NSCopying>[])keys count:(NSUInteger)cnt {
    INIT(_dic = [[NSMutableDictionary alloc] initWithObjects:objects forKeys:keys count:cnt]);
}

- (instancetype)initWithDictionary:(NSDictionary *)otherDictionary {
    INIT(_dic = [[NSMutableDictionary alloc] initWithDictionary:otherDictionary]);
}

- (instancetype)initWithDictionary:(NSDictionary *)otherDictionary copyItems:(BOOL)flag {
    INIT(_dic = [[NSMutableDictionary alloc] initWithDictionary:otherDictionary copyItems:flag]);
}


#pragma mark - method

- (NSUInteger)count {
    LOCK(NSUInteger c = _dic.count); return c;
}

- (id)objectForKey:(id)aKey {
    LOCK(id o = [_dic objectForKey:aKey]); return o;
}

- (NSEnumerator *)keyEnumerator {
    LOCK(NSEnumerator * e = [_dic keyEnumerator]); return e;
}

- (NSArray *)allKeys {
    LOCK(NSArray * a = [_dic allKeys]); return a;
}

- (NSArray *)allKeysForObject:(id)anObject {
    LOCK(NSArray * a = [_dic allKeysForObject:anObject]); return a;
}

- (NSArray *)allValues {
    LOCK(NSArray * a = [_dic allValues]); return a;
}

- (NSString *)description {
    LOCK(NSString * d = [_dic description]); return d;
}

- (NSString *)descriptionInStringsFileFormat {
    LOCK(NSString * d = [_dic descriptionInStringsFileFormat]); return d;
}

- (NSString *)descriptionWithLocale:(id)locale {
    LOCK(NSString * d = [_dic descriptionWithLocale:locale]); return d;
}

- (NSString *)descriptionWithLocale:(id)locale indent:(NSUInteger)level {
    LOCK(NSString * d = [_dic descriptionWithLocale:locale indent:level]); return d;
}

- (BOOL)isEqualToDictionary:(NSDictionary *)otherDictionary {
    if (otherDictionary == self) return YES;
    
    if ([otherDictionary isKindOfClass:FWMutableDictionary.class]) {
        FWMutableDictionary *other = (id)otherDictionary;
        BOOL isEqual;
        dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
        dispatch_semaphore_wait(other->_lock, DISPATCH_TIME_FOREVER);
        isEqual = [_dic isEqual:other->_dic];
        dispatch_semaphore_signal(other->_lock);
        dispatch_semaphore_signal(_lock);
        return isEqual;
    }
    return NO;
}

- (NSEnumerator *)objectEnumerator {
    LOCK(NSEnumerator * e = [_dic objectEnumerator]); return e;
}

- (NSArray *)objectsForKeys:(NSArray *)keys notFoundMarker:(id)marker {
    LOCK(NSArray * a = [_dic objectsForKeys:keys notFoundMarker:marker]); return a;
}

- (NSArray *)keysSortedByValueUsingSelector:(SEL)comparator {
    LOCK(NSArray * a = [_dic keysSortedByValueUsingSelector:comparator]); return a;
}

- (id)objectForKeyedSubscript:(id)key {
    LOCK(id o = [_dic objectForKeyedSubscript:key]); return o;
}

- (void)enumerateKeysAndObjectsUsingBlock:(void (NS_NOESCAPE ^)(id key, id obj, BOOL *stop))block {
    LOCK([_dic enumerateKeysAndObjectsUsingBlock:block]);
}

- (void)enumerateKeysAndObjectsWithOptions:(NSEnumerationOptions)opts usingBlock:(void (NS_NOESCAPE ^)(id key, id obj, BOOL *stop))block {
    LOCK([_dic enumerateKeysAndObjectsWithOptions:opts usingBlock:block]);
}

- (NSArray *)keysSortedByValueUsingComparator:(NSComparator NS_NOESCAPE)cmptr {
    LOCK(NSArray * a = [_dic keysSortedByValueUsingComparator:cmptr]); return a;
}

- (NSArray *)keysSortedByValueWithOptions:(NSSortOptions)opts usingComparator:(NSComparator NS_NOESCAPE)cmptr {
    LOCK(NSArray * a = [_dic keysSortedByValueWithOptions:opts usingComparator:cmptr]); return a;
}

- (NSSet *)keysOfEntriesPassingTest:(BOOL (NS_NOESCAPE ^)(id key, id obj, BOOL *stop))predicate {
    LOCK(NSSet * a = [_dic keysOfEntriesPassingTest:predicate]); return a;
}

- (NSSet *)keysOfEntriesWithOptions:(NSEnumerationOptions)opts passingTest:(BOOL (NS_NOESCAPE ^)(id key, id obj, BOOL *stop))predicate {
    LOCK(NSSet * a = [_dic keysOfEntriesWithOptions:opts passingTest:predicate]); return a;
}

#pragma mark - mutable

- (void)removeObjectForKey:(id)aKey {
    LOCK([_dic removeObjectForKey:aKey]);
}

- (void)setObject:(id)anObject forKey:(id <NSCopying> )aKey {
    LOCK([_dic setObject:anObject forKey:aKey]);
}

- (void)addEntriesFromDictionary:(NSDictionary *)otherDictionary {
    LOCK([_dic addEntriesFromDictionary:otherDictionary]);
}

- (void)removeAllObjects {
    LOCK([_dic removeAllObjects]);
}

- (void)removeObjectsForKeys:(NSArray *)keyArray {
    LOCK([_dic removeObjectsForKeys:keyArray]);
}

- (void)setDictionary:(NSDictionary *)otherDictionary {
    LOCK([_dic setDictionary:otherDictionary]);
}

- (void)setObject:(id)obj forKeyedSubscript:(id <NSCopying> )key {
    LOCK([_dic setObject:obj forKeyedSubscript:key]);
}

#pragma mark - protocol

- (id)copyWithZone:(NSZone *)zone {
    return [self mutableCopyWithZone:zone];
}

- (id)mutableCopyWithZone:(NSZone *)zone {
    LOCK(id copiedDictionary = [[self.class allocWithZone:zone] initWithDictionary:_dic]);
    return copiedDictionary;
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state
                                  objects:(id __unsafe_unretained[])stackbuf
                                    count:(NSUInteger)len {
    LOCK(NSUInteger count = [_dic countByEnumeratingWithState:state objects:stackbuf count:len]);
    return count;
}

- (BOOL)isEqual:(id)object {
    if (object == self) return YES;
    
    if ([object isKindOfClass:FWMutableDictionary.class]) {
        FWMutableDictionary *other = object;
        BOOL isEqual;
        dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
        dispatch_semaphore_wait(other->_lock, DISPATCH_TIME_FOREVER);
        isEqual = [_dic isEqual:other->_dic];
        dispatch_semaphore_signal(other->_lock);
        dispatch_semaphore_signal(_lock);
        return isEqual;
    }
    return NO;
}

- (NSUInteger)hash {
    LOCK(NSUInteger hash = [_dic hash]);
    return hash;
}

@end
