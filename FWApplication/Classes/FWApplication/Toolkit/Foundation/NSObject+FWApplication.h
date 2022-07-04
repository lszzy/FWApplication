/**
 @header     NSObject+FWApplication.h
 @indexgroup FWApplication
      NSObject分类
 @author     wuyong
 @copyright  Copyright © 2018年 wuyong.site. All rights reserved.
 @updated    2018-05-15
 */

@import FWFramework;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Property

/**
 定义强引用属性
 
 @param type 属性类型
 @param name 属性名称
 */
#define	FWPropertyStrong( type, name ) \
    @property (nonatomic, strong) type name;

/**
 定义弱引用属性
 
 @param type 属性类型
 @param name 属性名称
 */
#define	FWPropertyWeak( type, name )	\
    @property (nonatomic, weak) type name;

/**
 定义赋值属性
 
 @param type 属性类型
 @param name 属性名称
 */
#define	FWPropertyAssign( type, name ) \
    @property (nonatomic, assign) type name;

/**
 定义拷贝属性
 
 @param type 属性类型
 @param name 属性名称
 */
#define	FWPropertyCopy( type, name )	\
    @property (nonatomic, copy) type name;

/**
 定义只读属性
 
 @param type 属性类型
 @param name 属性名称
 */
#define	FWPropertyReadonly( type, name )	\
    @property (nonatomic, readonly) type name;

/**
 定义只读强引用属性
 
 @param type 属性类型
 @param name 属性名称
 */
#define	FWPropertyStrongReadonly( type, name ) \
    @property (nonatomic, strong, readonly) type name;

/**
 定义只读弱引用属性
 
 @param type 属性类型
 @param name 属性名称
 */
#define	FWPropertyWeakReadonly( type, name ) \
    @property (nonatomic, weak, readonly) type name;

/**
 定义只读赋值属性
 
 @param type 属性类型
 @param name 属性名称
 */
#define	FWPropertyAssignReadonly( type, name ) \
    @property (nonatomic, assign, readonly) type name;

/**
 定义只读拷贝属性
 
 @param type 属性类型
 @param name 属性名称
 */
#define	FWPropertyCopyReadonly( type, name ) \
    @property (nonatomic, copy, readonly) type name;

/**
 自定义属性(如unsafe_unretained类似weak，但如果引用的对象被释放会造成野指针，再次访问会crash，weak会置为nil，不会crash)
 
 @param type 属性类型
 @param name 属性名称
 @param ... 属性修饰符
 */
#define	FWPropertyCustom( type, name, ... ) \
    @property (nonatomic, __VA_ARGS__) type name;

/**
 定义属性基本实现
 
 @param name 属性名称
 */
#define FWDefProperty( name ) \
    @synthesize name = _##name;

/**
 定义属性动态实现
 
 @param name 属性名称
 */
#define FWDefDynamic( name ) \
    @dynamic name;

/**
 按存储策略定义动态属性实现
 
 @parseOnly
 @param type 属性类型
 @param name 属性名称
 @param setter 属性setter
 @param policy 存储策略
 */
#define FWDefDynamicPolicy_( type, name, setter, policy ) \
    @dynamic name; \
    - (type)name \
    { \
        return objc_getAssociatedObject(self, #name); \
    } \
    - (void)setter:(type)object \
    { \
        if (object != [self name]) { \
            [self willChangeValueForKey:@#name]; \
            objc_setAssociatedObject(self, #name, object, policy); \
            [self didChangeValueForKey:@#name]; \
        } \
    }

/**
 定义强引用动态属性实现
 
 @param type 属性类型
 @param name 属性名称
 @param setter 属性setter
 */
#define FWDefDynamicStrong( type, name, setter ) \
    FWDefDynamicPolicy_( type, name, setter, OBJC_ASSOCIATION_RETAIN_NONATOMIC )

/**
 定义弱引用动态属性实现，注意可能会产生野指针
 
 @param type 属性类型
 @param name 属性名称
 @param setter 属性setter
 */
#define FWDefDynamicWeak( type, name, setter ) \
    @dynamic name; \
    - (type)name \
    { \
        id (^block)(void) = objc_getAssociatedObject(self, #name); \
        return block ? block() : nil; \
    } \
    - (void)setter:(type)object \
    { \
        if (object != [self name]) { \
            [self willChangeValueForKey:@#name]; \
            id __weak weakObject = object; \
            id (^block)(void) = ^{ return weakObject; }; \
            objc_setAssociatedObject(self, #name, block, OBJC_ASSOCIATION_COPY_NONATOMIC); \
            [self didChangeValueForKey:@#name]; \
        } \
    }

/**
 定义赋值动态属性实现
 
 @param type 属性类型
 @param name 属性名称
 @param setter 属性setter
 */
#define FWDefDynamicAssign( type, name, setter ) \
    @dynamic name; \
    - (type)name \
    { \
        type cvalue = { 0 }; \
        NSValue *value = objc_getAssociatedObject(self, #name); \
        [value getValue:&cvalue]; \
        return cvalue; \
    } \
    - (void)setter:(type)object \
    { \
        if (object != [self name]) { \
            [self willChangeValueForKey:@#name]; \
            NSValue *value = [NSValue value:&object withObjCType:@encode(type)]; \
            objc_setAssociatedObject(self, #name, value, OBJC_ASSOCIATION_RETAIN_NONATOMIC); \
            [self didChangeValueForKey:@#name]; \
        } \
    }

/**
 定义拷贝动态属性实现
 
 @param type 属性类型
 @param name 属性名称
 @param setter 属性setter
 */
#define FWDefDynamicCopy( type, name, setter ) \
    FWDefDynamicPolicy_( type, name, setter, OBJC_ASSOCIATION_COPY_NONATOMIC )

#pragma mark - Lazy

/**
 定义懒加载属性
 
 @param type 属性类型
 @param name 属性名称
 */
#define FWLazyProperty( type, name ) \
    @property (nonatomic, strong) type name;

/**
 定义懒加载属性实现
 
 @param type 属性类型
 @param name 属性名称
 @param code 实现代码
 */
#define FWDefLazyProperty( type, name, code ) \
    - (type)name \
    { \
        if (!_##name) { \
            code \
        } \
        return _##name; \
    }

#pragma mark - Static

/**
 定义静态属性
 
 @param name 属性名称
 */
#define FWStaticProperty( name ) \
    @property (class, nonatomic, readonly) NSString * name; \
    @property (nonatomic, readonly) NSString * name;

/**
 定义静态属性实现
 
 @param name 属性名称
 */
#define FWDefStaticProperty( name ) \
    @dynamic name; \
    - (NSString *)name { return [[self class] name]; } \
    + (NSString *)name { return [NSString stringWithFormat:@"%s", #name]; }

/**
 定义静态属性实现，含前缀
 
 @param name 属性名称
 @param prefix 属性前缀
 */
#define FWDefStaticProperty2( name, prefix ) \
    @dynamic name; \
    - (NSString *)name { return [[self class] name]; } \
    + (NSString *)name { return [NSString stringWithFormat:@"%@.%s", prefix, #name]; }

/**
 定义静态属性实现，含分组、前缀
 
 @param name 属性名称
 @param group 属性分组
 @param prefix 属性前缀
 */
#define FWDefStaticProperty3( name, group, prefix ) \
    @dynamic name; \
    - (NSString *)name { return [[self class] name]; } \
    + (NSString *)name { return [NSString stringWithFormat:@"%@.%@.%s", group, prefix, #name]; }

/**
 定义静态NSInteger属性
 
 @param name 属性名称
 */
#define FWStaticInteger( name ) \
    @property (class, nonatomic, readonly) NSInteger name; \
    @property (nonatomic, readonly) NSInteger name;

/**
 定义静态NSInteger属性实现
 
 @param name 属性名称
 @param value 属性值
 */
#define FWDefStaticInteger( name, value ) \
    @dynamic name; \
    - (NSInteger)name { return [[self class] name]; } \
    + (NSInteger)name { return value; }

/**
 定义静态NSNumber属性
 
 @param name 属性名称
 */
#define FWStaticNumber( name ) \
    @property (class, nonatomic, readonly) NSNumber * name; \
    @property (nonatomic, readonly) NSNumber * name;

/**
 定义静态NSNumber属性实现
 
 @param name 属性名称
 @param value 属性值
 */
#define FWDefStaticNumber( name, value ) \
    @dynamic name; \
    - (NSNumber *)name { return [[self class] name]; } \
    + (NSNumber *)name { return @(value); }

/**
 定义静态字符串属性
 
 @param name 属性名称
 */
#define FWStaticString( name ) \
    @property (class, nonatomic, readonly) NSString * name; \
    @property (nonatomic, readonly) NSString * name;

/**
 定义静态字符串属性实现
 
 @param name 属性名称
 @param value 属性值
 */
#define FWDefStaticString( name, value ) \
    @dynamic name; \
    - (NSString *)name { return [[self class] name]; } \
    + (NSString *)name { return value; }

#pragma mark - GCD

// 执行一次block
#define FWDispatchOnce( block ) \
    static dispatch_once_t onceToken; \
    dispatch_once(&onceToken, block);

// 主并行队列执行block
#define FWDispatchGlobal( block ) \
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block);

// 主UI线程执行block
#define FWDispatchMain( block ) \
    if ([NSThread isMainThread]) { \
        block(); \
    } else { \
        dispatch_async(dispatch_get_main_queue(), block); \
    }

// 延迟几秒后主UI线程执行block
#define FWDispatchAfter( time, block ) \
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), block);

// 线程group同步：声明、异步执行(适合内部同步任务)、进入(适合内部异步任务，可调用FWDispatchGlobal等)、离开、通知
#define FWDispatchGroupCreate( ) \
    dispatch_group_t fwGroup = dispatch_group_create();

#define FWDispatchGroupAsync( block ) \
    dispatch_group_async(fwGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block);

#define FWDispatchGroupEnter( ) \
    dispatch_group_enter(fwGroup);

#define FWDispatchGroupLeave( ) \
    dispatch_group_leave(fwGroup);

#define FWDispatchGroupNotify( block ) \
    dispatch_group_notify(fwGroup, dispatch_get_main_queue(), block);

#define FWDispatchGroupWait( ) \
    dispatch_group_wait(fwGroup, DISPATCH_TIME_FOREVER);

// 创建GCD信号量，value为初始值，大于等于0
#define FWDispatchSemaphoreCreate( value ) \
    dispatch_semaphore_t fwSemaphore = dispatch_semaphore_create(value);

// 发送GCD信号量，信号量值+1
#define FWDispatchSemaphoreSignal( ) \
    dispatch_semaphore_signal(fwSemaphore);

// 等待GCD信号量。如当前信号量值>0，则信号量值-1并执行后续代码；否则一直等待信号值增加
#define FWDispatchSemaphoreWait( ) \
    dispatch_semaphore_wait(fwSemaphore, DISPATCH_TIME_FOREVER);

// 同步信号量执行异步block。阻塞当前线程，同步返回异步结果，block中需调用：dispatch_semaphore_signal(fwSemaphore); 可赋值__block变量等
#define FWDispatchSemaphoreSync( block ) \
    dispatch_semaphore_t fwSemaphore = dispatch_semaphore_create(0); \
    block(); \
    dispatch_semaphore_wait(fwSemaphore, DISPATCH_TIME_FOREVER);

// GCD队列创建和同步异步执行
#define FWDispatchQueueCreate( name, type ) \
    dispatch_queue_t fwQueue = dispatch_queue_create(name, type);

#define FWDispatchQueueAsync( block ) \
    dispatch_async(fwQueue, block);

#define FWDispatchQueueSync( block ) \
    dispatch_sync(fwQueue, block);

#pragma mark - Lock

// 定义GCD信号量锁，声明属性，类声明中调用
#define FWLockSemaphore( lock ) \
    @property (nonatomic, strong) dispatch_semaphore_t lock;

// 创建CGD信号量，初始值1，初始化中调用
#define FWLockCreate( lock ) \
    lock = dispatch_semaphore_create(1);

// 等待GCD信号量，如果>0则值-1继续否则等待，操作前调用
#define FWLock( lock ) \
    dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);

// 发送GCD信号量，值+1，操作后调用
#define FWUnlock( lock ) \
    dispatch_semaphore_signal(lock);

/**
 可使用NS_UNAVAILABLE标记方法不可用，NS_DESIGNATED_INITIALIZER标记默认init方法。
 注意load可能被子类super调用导致调用多次，需dispatch_once避免；而initialize如果子类不实现，默认会调用父类initialize，也会导致调用多次，可判断class或dispatch_once避免
 */
@interface NSObject (FWApplication)

#pragma mark - Archive

/**
 使用NSKeyedArchiver和NSKeyedUnarchiver深拷对象
 
 @return 出错返回nil
 */
- (nullable id)fw_archiveCopy NS_REFINED_FOR_SWIFT;

#pragma mark - Block

/// 延迟delay秒后主线程执行，返回可取消的block，对象范围
- (id)fw_performBlock:(void (^)(id obj))block afterDelay:(NSTimeInterval)delay NS_REFINED_FOR_SWIFT;

/// 延迟delay秒后后台线程执行，返回可取消的block，对象范围
- (id)fw_performBlockInBackground:(void (^)(id obj))block afterDelay:(NSTimeInterval)delay NS_REFINED_FOR_SWIFT;

/// 延迟delay秒后指定线程执行，返回可取消的block，对象范围
- (id)fw_performBlock:(void (^)(id obj))block onQueue:(dispatch_queue_t)queue afterDelay:(NSTimeInterval)delay NS_REFINED_FOR_SWIFT;

/// 同步方式执行异步block，阻塞当前线程(信号量)，异步block必须调用completionHandler，全局范围
- (void)fw_syncPerformAsyncBlock:(void (^)(void (^completionHandler)(void)))asyncBlock NS_REFINED_FOR_SWIFT;

/// 同一个identifier仅执行一次block，对象范围
- (void)fw_performOnce:(NSString *)identifier withBlock:(void (^)(void))block NS_REFINED_FOR_SWIFT;

/// 重试方式执行异步block，直至成功或者次数为0或者超时，完成后回调completion。block必须调用completionHandler，参数示例：重试4次|超时8秒|延迟2秒
- (void)fw_performBlock:(void (^)(void (^completionHandler)(BOOL success, id _Nullable obj)))block completion:(void (^)(BOOL success, id _Nullable obj))completion retryCount:(NSUInteger)retryCount timeoutInterval:(NSTimeInterval)timeoutInterval delayInterval:(NSTimeInterval)delayInterval NS_REFINED_FOR_SWIFT;

#pragma mark - Block

/// 延迟delay秒后主线程执行，返回可取消的block，全局范围
+ (id)fw_performBlock:(void (^)(void))block afterDelay:(NSTimeInterval)delay NS_SWIFT_NAME(__fw_perform(with:afterDelay:)) NS_REFINED_FOR_SWIFT;

/// 延迟delay秒后后台线程执行，返回可取消的block，全局范围
+ (id)fw_performBlockInBackground:(void (^)(void))block afterDelay:(NSTimeInterval)delay NS_SWIFT_NAME(__fw_perform(inBackground:afterDelay:)) NS_REFINED_FOR_SWIFT;

/// 延迟delay秒后指定线程执行，返回可取消的block，全局范围
+ (id)fw_performBlock:(void (^)(void))block onQueue:(dispatch_queue_t)queue afterDelay:(NSTimeInterval)delay NS_SWIFT_NAME(__fw_perform(with:on:afterDelay:)) NS_REFINED_FOR_SWIFT;

/// 取消指定延迟block，全局范围
+ (void)fw_cancelBlock:(id)block NS_REFINED_FOR_SWIFT;

/// 同步方式执行异步block，阻塞当前线程(信号量)，异步block必须调用completionHandler，全局范围
+ (void)fw_syncPerformAsyncBlock:(void (^)(void (^completionHandler)(void)))asyncBlock NS_REFINED_FOR_SWIFT;

/// 同一个identifier仅执行一次block，全局范围
+ (void)fw_performOnce:(NSString *)identifier withBlock:(void (^)(void))block NS_REFINED_FOR_SWIFT;

/// 重试方式执行异步block，直至成功或者次数为0或者超时，完成后回调completion。block必须调用completionHandler，参数示例：重试4次|超时8秒(0不限制)|延迟2秒
+ (void)fw_performBlock:(void (^)(void (^completionHandler)(BOOL success, id _Nullable obj)))block completion:(void (^)(BOOL success, id _Nullable obj))completion retryCount:(NSUInteger)retryCount timeoutInterval:(NSTimeInterval)timeoutInterval delayInterval:(NSTimeInterval)delayInterval NS_REFINED_FOR_SWIFT;

/// 执行轮询block任务，返回任务Id可取消
+ (NSString *)fw_performTask:(void (^)(void))task start:(NSTimeInterval)start interval:(NSTimeInterval)interval repeats:(BOOL)repeats async:(BOOL)async NS_REFINED_FOR_SWIFT;

/// 指定任务Id取消轮询任务
+ (void)fw_cancelTask:(NSString *)taskId NS_REFINED_FOR_SWIFT;

#pragma mark - Debug

/// 获取当前对象的所有 @property、方法，父类的方法也会分别列出
@property (nonatomic, copy, readonly) NSString *fw_methodList NS_REFINED_FOR_SWIFT;

/// 获取当前对象的所有 @property、方法，不包含父类的
@property (nonatomic, copy, readonly) NSString *fw_shortMethodList NS_REFINED_FOR_SWIFT;

/// 当前对象的所有 Ivar 变量
@property (nonatomic, copy, readonly) NSString *fw_ivarList NS_REFINED_FOR_SWIFT;

@end

NS_ASSUME_NONNULL_END
