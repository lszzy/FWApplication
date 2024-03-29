/**
 @header     FWModel.h
 @indexgroup FWApplication
      FWModel
 @author     wuyong
 @copyright  Copyright © 2018 wuyong.site. All rights reserved.
 @updated    2018/9/26
 */

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

NS_ASSUME_NONNULL_BEGIN

/// 定义NSCopying实现宏
#define FWDefCopying() \
    - (id)copyWithZone:(NSZone *)zone \
    { \
        return [self fw_modelCopy]; \
    }

/// 定义NSCoding实现宏
#define FWDefCoding( ) \
    - (instancetype)initWithCoder:(NSCoder *)aDecoder \
    { \
        return [self fw_modelInitWithCoder:aDecoder]; \
    } \
    - (void)encodeWithCoder:(NSCoder *)aCoder \
    { \
        [self fw_modelEncodeWithCoder:aCoder]; \
    }

/// 定义数组类型模型
#define FWModelArray( class ) \
    @protocol class <NSObject> \
    @end

/**
 *  Model转换协议
 *  数组类映射支持两种方式：
 *  1. 实现fwModelClassMapper方法，返回类映射字典。示例：@{@"books" : [Book class]}
 *  2. 声明Model类同名协议，同时定义数组属性时也声明协议。示例：NSArray<Book> *books
 *  Swift数组类映射时，需返回AnyClass类型。示例：["books": Book.self]
 */
NS_SWIFT_NAME(ModelProtocol)
@protocol FWModel <NSObject>

@optional

/// 属性映射，示例：@{@"name" : @"book_name", @"bookId" : [@"book_id", @"book.id"]}
+ (nullable NSDictionary<NSString *, id> *)modelPropertyMapper;

/// 类映射(Swift需使用AnyClass类型)，示例：@{@"books" : [Book class], @"users" : @"User"}
+ (nullable NSDictionary<NSString *, id> *)modelClassMapper;

/// 自定义字典解析类(Swift需使用AnyClass类型)
+ (nullable Class)modelClassForDictionary:(NSDictionary *)dictionary;

/// 属性黑名单列表
+ (nullable NSArray<NSString *> *)modelPropertyBlacklist;

/// 属性白名单列表
+ (nullable NSArray<NSString *> *)modelPropertyWhitelist;

/// 字典将要转换模型时钩子处理
- (NSDictionary *)modelWillTransformFromDictionary:(NSDictionary *)dictionary;

/// 字典转换模型时钩子处理
- (BOOL)modelTransformFromDictionary:(NSDictionary *)dictionary;

/// 模型转换字典时钩子处理
- (BOOL)modelTransformToDictionary:(NSMutableDictionary *)dictionary;

@end

/**
 *  ViewModel架构协议
 */
NS_SWIFT_NAME(ViewModelProtocol)
@protocol FWViewModel <NSObject>

@end

/**
 Model模型解析分类，参考自YYModel
 
 @see https://github.com/ibireme/YYModel
 */
@interface NSObject (FWModel)

/**
 从json创建对象，线程安全。NSDate会按照UTC时间解析，下同
 
 @param json json对象，支持NSDictionary、NSString、NSData
 @return 实例对象，失败为nil
 */
+ (nullable instancetype)fw_modelWithJson:(id)json NS_REFINED_FOR_SWIFT;

/**
 从字典创建对象，线程安全
 
 @param dictionary 字典数据
 @return 实例对象，失败为nil
 */
+ (nullable instancetype)fw_modelWithDictionary:(NSDictionary *)dictionary NS_REFINED_FOR_SWIFT;

/**
 从json创建Model数组
 
 @param json json对象，支持NSDictionary、NSString、NSData
 @return Model数组
 */
+ (nullable NSArray *)fw_modelArrayWithJson:(id)json NS_REFINED_FOR_SWIFT;

/**
 从json创建Model字典
 
 @param json json对象，支持NSDictionary、NSString、NSData
 @return Model字典
 */
+ (nullable NSDictionary *)fw_modelDictionaryWithJson:(id)json NS_REFINED_FOR_SWIFT;

/**
 从json对象设置对象属性
 
 @param json json对象，支持NSDictionary、NSString、NSData
 @return 是否设置成功
 */
- (BOOL)fw_modelSetWithJson:(id)json NS_REFINED_FOR_SWIFT;

/**
 从字典设置对象属性
 
 @param dictionary 字典数据
 @return 是否设置成功
 */
- (BOOL)fw_modelSetWithDictionary:(NSDictionary *)dictionary NS_REFINED_FOR_SWIFT;

/**
 转换为json对象
 
 @return json对象，如NSDictionary、NSArray，失败为nil
 */
- (nullable id)fw_modelToJsonObject NS_REFINED_FOR_SWIFT;

/**
 转换为json字符串数据
 
 @return NSData，失败为nil
 */
- (nullable NSData *)fw_modelToJsonData NS_REFINED_FOR_SWIFT;

/**
 转换为json字符串
 
 @return NSString，失败为nil
 */
- (nullable NSString *)fw_modelToJsonString NS_REFINED_FOR_SWIFT;

/**
 从属性拷贝当前对象
 
 @return 拷贝对象，失败为nil
 */
- (nullable id)fw_modelCopy NS_REFINED_FOR_SWIFT;

/// 对象编码
- (void)fw_modelEncodeWithCoder:(NSCoder *)aCoder NS_REFINED_FOR_SWIFT;

/// 对象解码
- (id)fw_modelInitWithCoder:(NSCoder *)aDecoder NS_REFINED_FOR_SWIFT;

/// 对象的hash编码
- (NSUInteger)fw_modelHash NS_REFINED_FOR_SWIFT;

/// 比较Model
- (BOOL)fw_modelIsEqual:(id)model NS_REFINED_FOR_SWIFT;

/// 对象描述
- (NSString *)fw_modelDescription NS_REFINED_FOR_SWIFT;

@end

/// Type-Encoding枚举
typedef NS_OPTIONS(NSUInteger, FWEncodingType) {
    FWEncodingTypeMask       = 0xFF, ///< mask of type value
    FWEncodingTypeUnknown    = 0, ///< unknown
    FWEncodingTypeVoid       = 1, ///< void
    FWEncodingTypeBool       = 2, ///< bool
    FWEncodingTypeInt8       = 3, ///< char / BOOL
    FWEncodingTypeUInt8      = 4, ///< unsigned char
    FWEncodingTypeInt16      = 5, ///< short
    FWEncodingTypeUInt16     = 6, ///< unsigned short
    FWEncodingTypeInt32      = 7, ///< int
    FWEncodingTypeUInt32     = 8, ///< unsigned int
    FWEncodingTypeInt64      = 9, ///< long long
    FWEncodingTypeUInt64     = 10, ///< unsigned long long
    FWEncodingTypeFloat      = 11, ///< float
    FWEncodingTypeDouble     = 12, ///< double
    FWEncodingTypeLongDouble = 13, ///< long double
    FWEncodingTypeObject     = 14, ///< id
    FWEncodingTypeClass      = 15, ///< Class
    FWEncodingTypeSEL        = 16, ///< SEL
    FWEncodingTypeBlock      = 17, ///< block
    FWEncodingTypePointer    = 18, ///< void*
    FWEncodingTypeStruct     = 19, ///< struct
    FWEncodingTypeUnion      = 20, ///< union
    FWEncodingTypeCString    = 21, ///< char*
    FWEncodingTypeCArray     = 22, ///< char[10] (for example)
    
    FWEncodingTypeQualifierMask   = 0xFF00,   ///< mask of qualifier
    FWEncodingTypeQualifierConst  = 1 << 8,  ///< const
    FWEncodingTypeQualifierIn     = 1 << 9,  ///< in
    FWEncodingTypeQualifierInout  = 1 << 10, ///< inout
    FWEncodingTypeQualifierOut    = 1 << 11, ///< out
    FWEncodingTypeQualifierBycopy = 1 << 12, ///< bycopy
    FWEncodingTypeQualifierByref  = 1 << 13, ///< byref
    FWEncodingTypeQualifierOneway = 1 << 14, ///< oneway
    
    FWEncodingTypePropertyMask         = 0xFF0000, ///< mask of property
    FWEncodingTypePropertyReadonly     = 1 << 16, ///< readonly
    FWEncodingTypePropertyCopy         = 1 << 17, ///< copy
    FWEncodingTypePropertyRetain       = 1 << 18, ///< retain
    FWEncodingTypePropertyNonatomic    = 1 << 19, ///< nonatomic
    FWEncodingTypePropertyWeak         = 1 << 20, ///< weak
    FWEncodingTypePropertyCustomGetter = 1 << 21, ///< getter=
    FWEncodingTypePropertyCustomSetter = 1 << 22, ///< setter=
    FWEncodingTypePropertyDynamic      = 1 << 23, ///< @dynamic
} NS_SWIFT_NAME(EncodingType);

/// 解析Type-Encoding字符串类型
FWEncodingType FWEncodingGetType(const char *typeEncoding) NS_SWIFT_NAME(EncodingGetType(_:));

/// Ivar信息
NS_SWIFT_NAME(ClassIvarInfo)
@interface FWClassIvarInfo : NSObject

@property (nonatomic, assign, readonly) Ivar ivar;              ///< ivar opaque struct
@property (nonatomic, strong, readonly) NSString *name;         ///< Ivar's name
@property (nonatomic, assign, readonly) ptrdiff_t offset;       ///< Ivar's offset
@property (nonatomic, strong, readonly) NSString *typeEncoding; ///< Ivar's type encoding
@property (nonatomic, assign, readonly) FWEncodingType type;    ///< Ivar's type

- (instancetype)initWithIvar:(Ivar)ivar;

@end

/// Method 信息
NS_SWIFT_NAME(ClassMethodInfo)
@interface FWClassMethodInfo : NSObject

@property (nonatomic, assign, readonly) Method method;                  ///< method opaque struct
@property (nonatomic, strong, readonly) NSString *name;                 ///< method name
@property (nonatomic, assign, readonly) SEL sel;                        ///< method's selector
@property (nonatomic, assign, readonly) IMP imp;                        ///< method's implementation
@property (nonatomic, strong, readonly) NSString *typeEncoding;         ///< method's parameter and return types
@property (nonatomic, strong, readonly) NSString *returnTypeEncoding;   ///< return value's type
@property (nullable, nonatomic, strong, readonly) NSArray<NSString *> *argumentTypeEncodings; ///< array of arguments' type

- (instancetype)initWithMethod:(Method)method;

@end

/// 属性信息
NS_SWIFT_NAME(ClassPropertyInfo)
@interface FWClassPropertyInfo : NSObject

@property (nonatomic, assign, readonly) objc_property_t property; ///< property's opaque struct
@property (nonatomic, strong, readonly) NSString *name;           ///< property's name
@property (nonatomic, assign, readonly) FWEncodingType type;      ///< property's type
@property (nonatomic, strong, readonly) NSString *typeEncoding;   ///< property's encoding value
@property (nonatomic, strong, readonly) NSString *ivarName;       ///< property's ivar name
@property (nullable, nonatomic, assign, readonly) Class cls;      ///< may be nil
@property (nullable, nonatomic, strong, readonly) NSArray<NSString *> *protocols; ///< may nil
@property (nonatomic, assign, readonly) SEL getter;               ///< getter (nonnull)
@property (nonatomic, assign, readonly) SEL setter;               ///< setter (nonnull)

- (instancetype)initWithProperty:(objc_property_t)property;

@end

/// Class信息
NS_SWIFT_NAME(ClassInfo)
@interface FWClassInfo : NSObject

@property (nonatomic, assign, readonly) Class cls; ///< class object
@property (nullable, nonatomic, assign, readonly) Class superCls; ///< super class object
@property (nullable, nonatomic, assign, readonly) Class metaCls;  ///< class's meta class object
@property (nonatomic, readonly) BOOL isMeta; ///< whether this class is meta class
@property (nonatomic, strong, readonly) NSString *name; ///< class name
@property (nullable, nonatomic, strong, readonly) FWClassInfo *superClassInfo; ///< super class's class info
@property (nullable, nonatomic, strong, readonly) NSDictionary<NSString *, FWClassIvarInfo *> *ivarInfos; ///< ivars
@property (nullable, nonatomic, strong, readonly) NSDictionary<NSString *, FWClassMethodInfo *> *methodInfos; ///< methods
@property (nullable, nonatomic, strong, readonly) NSDictionary<NSString *, FWClassPropertyInfo *> *propertyInfos; ///< properties

- (void)setNeedUpdate;

- (BOOL)needUpdate;

+ (nullable instancetype)classInfoWithClass:(Class)cls;

+ (nullable instancetype)classInfoWithClassName:(NSString *)className;

@end

NS_ASSUME_NONNULL_END
