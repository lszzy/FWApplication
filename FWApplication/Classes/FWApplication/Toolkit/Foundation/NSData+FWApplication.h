/**
 @header     NSData+FWApplication.h
 @indexgroup FWApplication
 @author     wuyong
 @copyright  Copyright © 2018年 wuyong.site. All rights reserved.
 @updated    2018/9/17
 */

@import FWFramework;

NS_ASSUME_NONNULL_BEGIN

@interface NSData (FWApplication)

#pragma mark - Encrypt

/// 利用AES加密数据
- (nullable NSData *)fw_AESEncryptWithKey:(NSString *)key andIV:(NSData *)iv NS_REFINED_FOR_SWIFT;

/// 利用AES解密数据
- (nullable NSData *)fw_AESDecryptWithKey:(NSString *)key andIV:(NSData *)iv NS_REFINED_FOR_SWIFT;

/// 利用3DES加密数据
- (nullable NSData *)fw_DES3EncryptWithKey:(NSString *)key andIV:(NSData *)iv NS_REFINED_FOR_SWIFT;

/// 利用3DES解密数据
- (nullable NSData *)fw_DES3DecryptWithKey:(NSString *)key andIV:(NSData *)iv NS_REFINED_FOR_SWIFT;

#pragma mark - RSA

/// RSA公钥加密，数据传输安全，使用默认标签，执行base64编码
- (nullable NSData *)fw_RSAEncryptWithPublicKey:(NSString *)publicKey NS_REFINED_FOR_SWIFT;

/// RSA公钥加密，数据传输安全，可自定义标签，指定base64编码
- (nullable NSData *)fw_RSAEncryptWithPublicKey:(NSString *)publicKey andTag:(NSString *)tagName base64Encode:(BOOL)base64Encode NS_REFINED_FOR_SWIFT;

/// RSA私钥解密，数据传输安全，使用默认标签，执行base64解密
- (nullable NSData *)fw_RSADecryptWithPrivateKey:(NSString *)privateKey NS_REFINED_FOR_SWIFT;

/// RSA私钥解密，数据传输安全，可自定义标签，指定base64解码
- (nullable NSData *)fw_RSADecryptWithPrivateKey:(NSString *)privateKey andTag:(NSString *)tagName base64Decode:(BOOL)base64Decode NS_REFINED_FOR_SWIFT;

/// RSA私钥加签，防篡改防否认，使用默认标签，执行base64编码
- (nullable NSData *)fw_RSASignWithPrivateKey:(NSString *)privateKey NS_REFINED_FOR_SWIFT;

/// RSA私钥加签，防篡改防否认，可自定义标签，指定base64编码
- (nullable NSData *)fw_RSASignWithPrivateKey:(NSString *)privateKey andTag:(NSString *)tagName base64Encode:(BOOL)base64Encode NS_REFINED_FOR_SWIFT;

/// RSA公钥验签，防篡改防否认，使用默认标签，执行base64解密
- (nullable NSData *)fw_RSAVerifyWithPublicKey:(NSString *)publicKey NS_REFINED_FOR_SWIFT;

/// RSA公钥验签，防篡改防否认，可自定义标签，指定base64解码
- (nullable NSData *)fw_RSAVerifyWithPublicKey:(NSString *)publicKey andTag:(NSString *)tagName base64Decode:(BOOL)base64Decode NS_REFINED_FOR_SWIFT;

@end

NS_ASSUME_NONNULL_END
