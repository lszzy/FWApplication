/**
 @header     NSString+FWApplication.h
 @indexgroup FWApplication
      NSString+FWApplication
 @author     wuyong
 @copyright  Copyright © 2018年 wuyong.site. All rights reserved.
 @updated    2018/9/18
 */

@import FWFramework;

NS_ASSUME_NONNULL_BEGIN

@interface NSString (FWApplication)

#pragma mark - Pinyin

/**
 *  中文转拼音并进行比较
 *
 *  @param string 中文字符串
 */
- (NSComparisonResult)fw_pinyinCompare:(NSString *)string NS_REFINED_FOR_SWIFT;

#pragma mark - Regex

/**
 *  安全截取字符串。解决末尾半个Emoji问题(半个Emoji调UTF8String为NULL，导致MD5签名等失败)
 *
 *  @param index 目标索引
 */
- (NSString *)fw_emojiSubstring:(NSUInteger)index NS_REFINED_FOR_SWIFT;

/**
 *  正则搜索子串
 *
 *  @param regex 正则表达式
 */
- (nullable NSString *)fw_regexSubstring:(NSString *)regex NS_REFINED_FOR_SWIFT;

/**
 *  正则替换字符串
 *
 *  @param regex  正则表达式
 *  @param string 替换模板，如"头部$1中部$2尾部"
 *
 *  @return 替换后的字符串
 */
- (NSString *)fw_regexReplace:(NSString *)regex withString:(NSString *)string NS_REFINED_FOR_SWIFT;

/**
 *  正则匹配回调
 *
 *  @param regex 正则表达式
 *  @param block 回调句柄。range从大至小，方便replace
 */
- (void)fw_regexMatches:(NSString *)regex withBlock:(void (^)(NSRange range))block NS_REFINED_FOR_SWIFT;

#pragma mark - Html

/**
 转义Html，如"a<"转义为"a&lt;"
 
 @return 转义后的字符串
 */
@property (nonatomic, copy, readonly) NSString *fw_escapeHtml NS_REFINED_FOR_SWIFT;

// 创建一个UUID字符串，示例："D1178E50-2A4D-4F1F-9BD3-F6AAB00E06B1"。也可调用NSUUID.UUID.UUIDString
@property (class, nonatomic, copy, readonly) NSString *fw_UUIDString NS_REFINED_FOR_SWIFT;

@end

#pragma mark - NSString+FWFormat

/**
 *  正则表达式简单说明
 *  语法：
 .       匹配除换行符以外的任意字符
 \w      匹配字母或数字或下划线或汉字
 \s      匹配任意的空白符
 \d      匹配数字
 \b      匹配单词的开始或结束
 ^       匹配字符串的开始
 $       匹配字符串的结束
 *       重复零次或更多次
 +       重复一次或更多次
 ?       重复零次或一次
 {n}     重复n次
 {n,}     重复n次或更多次
 {n,m}     重复n到m次
 \W      匹配任意不是字母，数字，下划线，汉字的字符
 \S      匹配任意不是空白符的字符
 \D      匹配任意非数字的字符
 \B      匹配不是单词开头或结束的位置
 [^x]     匹配除了x以外的任意字符
 [^aeiou]匹配除了aeiou这几个字母以外的任意字符
 *?      重复任意次，但尽可能少重复
 +?      重复1次或更多次，但尽可能少重复
 ??      重复0次或1次，但尽可能少重复
 {n,m}?     重复n到m次，但尽可能少重复
 {n,}?     重复n次以上，但尽可能少重复
 \a      报警字符(打印它的效果是电脑嘀一声)
 \b      通常是单词分界位置，但如果在字符类里使用代表退格
 \t      制表符，Tab
 \r      回车
 \v      竖向制表符
 \f      换页符
 \n      换行符
 \e      Escape
 \0nn     ASCII代码中八进制代码为nn的字符
 \xnn     ASCII代码中十六进制代码为nn的字符
 \unnnn     Unicode代码中十六进制代码为nnnn的字符
 \cN     ASCII控制字符。比如\cC代表Ctrl+C
 \A      字符串开头(类似^，但不受处理多行选项的影响)
 \Z      字符串结尾或行尾(不受处理多行选项的影响)
 \z      字符串结尾(类似$，但不受处理多行选项的影响)
 \G      当前搜索的开头
 \p{name}     Unicode中命名为name的字符类，例如\p{IsGreek}
 (?>exp)     贪婪子表达式
 (?<x>-<y>exp)     平衡组
 (?im-nsx:exp)     在子表达式exp中改变处理选项
 (?im-nsx)       为表达式后面的部分改变处理选项
 (?(exp)yes|no)     把exp当作零宽正向先行断言，如果在这个位置能匹配，使用yes作为此组的表达式；否则使用no
 (?(exp)yes)     同上，只是使用空表达式作为no
 (?(name)yes|no) 如果命名为name的组捕获到了内容，使用yes作为表达式；否则使用no
 (?(name)yes)     同上，只是使用空表达式作为no
 
 捕获
 (exp)               匹配exp,并捕获文本到自动命名的组里
 (?<name>exp)        匹配exp,并捕获文本到名称为name的组里，也可以写成(?'name'exp)
 (?:exp)             匹配exp,不捕获匹配的文本，也不给此分组分配组号
 零宽断言
 (?=exp)             匹配exp前面的位置
 (?<=exp)            匹配exp后面的位置
 (?!exp)             匹配后面跟的不是exp的位置
 (?<!exp)            匹配前面不是exp的位置
 注释
 (?#comment)         这种类型的分组不对正则表达式的处理产生任何影响，用于提供注释让人阅读
 
 *  表达式：\(?0\d{2}[) -]?\d{8}
 *  这个表达式可以匹配几种格式的电话号码，像(010)88886666，或022-22334455，或02912345678等。
 *  我们对它进行一些分析吧：
 *  首先是一个转义字符\(,它能出现0次或1次(?),然后是一个0，后面跟着2个数字(\d{2})，然后是)或-或空格中的一个，它出现1次或不出现(?)，
 *  最后是8个数字(\d{8})
 */
@interface NSString (FWFormat)

/**
 *  是否符合正则表达式
 *  示例：用户名：^[a-zA-Z][a-zA-Z0-9_]{4,13}$
 *       密码：^[a-zA-Z0-9_]{6,20}$
 *       昵称：^[a-zA-Z0-9_\u4e00-\u9fa5]{4,14}$
 *
 *  @param regex 正则表达式
 */
- (BOOL)fw_isFormatRegex:(NSString *)regex NS_REFINED_FOR_SWIFT;

/**
 *  是否是手机号
 */
- (BOOL)fw_isFormatMobile NS_REFINED_FOR_SWIFT;

/**
 *  是否是座机号
 */
- (BOOL)fw_isFormatTelephone NS_REFINED_FOR_SWIFT;

/**
 *  是否是整数
 */
- (BOOL)fw_isFormatInteger NS_REFINED_FOR_SWIFT;

/**
 *  是否是数字
 */
- (BOOL)fw_isFormatNumber NS_REFINED_FOR_SWIFT;

/**
 *  是否是合法金额，两位小数点
 */
- (BOOL)fw_isFormatMoney NS_REFINED_FOR_SWIFT;

/**
 *  是否是身份证号
 */
- (BOOL)fw_isFormatIdcard NS_REFINED_FOR_SWIFT;

/**
 *  是否是银行卡号
 */
- (BOOL)fw_isFormatBankcard NS_REFINED_FOR_SWIFT;

/**
 *  是否是车牌号
 */
- (BOOL)fw_isFormatCarno NS_REFINED_FOR_SWIFT;

/**
 *  是否是邮政编码
 */
- (BOOL)fw_isFormatPostcode NS_REFINED_FOR_SWIFT;

/**
 *  是否是工商税号
 */
- (BOOL)fw_isFormatTaxno NS_REFINED_FOR_SWIFT;

/**
 *  是否是邮箱
 */
- (BOOL)fw_isFormatEmail NS_REFINED_FOR_SWIFT;

/**
 *  是否是URL
 */
- (BOOL)fw_isFormatUrl NS_REFINED_FOR_SWIFT;

/**
 *  是否是HTML
 */
- (BOOL)fw_isFormatHtml NS_REFINED_FOR_SWIFT;

/**
 *  是否是IP
 */
- (BOOL)fw_isFormatIp NS_REFINED_FOR_SWIFT;

/**
 *  是否全是中文
 */
- (BOOL)fw_isFormatChinese NS_REFINED_FOR_SWIFT;

/**
 *  是否是合法时间，格式：yyyy-MM-dd HH:mm:ss
 */
- (BOOL)fw_isFormatDatetime NS_REFINED_FOR_SWIFT;

/**
 *  是否是合法时间戳，格式：1301234567
 */
- (BOOL)fw_isFormatTimestamp NS_REFINED_FOR_SWIFT;

/**
 *  是否是坐标点字符串，格式：latitude,longitude
 */
- (BOOL)fw_isFormatCoordinate NS_REFINED_FOR_SWIFT;

@end

NS_ASSUME_NONNULL_END
