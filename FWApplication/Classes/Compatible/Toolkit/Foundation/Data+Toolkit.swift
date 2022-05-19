//
//  NSData+Toolkit.swift
//  FWApplication
//
//  Created by wuyong on 2022/5/19.
//

import UIKit

extension Wrapper where Base == Data {
    
    // MARK: - Encrypt

    /// 利用AES加密数据
    public func aesEncrypt(key: String, iv: Data) -> Data? {
        return (base as NSData).__fw.aesEncrypt(withKey: key, andIV: iv)
    }

    /// 利用AES解密数据
    public func aesDecrypt(key: String, iv: Data) -> Data? {
        return (base as NSData).__fw.aesDecrypt(withKey: key, andIV: iv)
    }

    /// 利用3DES加密数据
    public func des3Encrypt(key: String, iv: Data) -> Data? {
        return (base as NSData).__fw.des3Encrypt(withKey: key, andIV: iv)
    }

    /// 利用3DES解密数据
    public func des3Decrypt(key: String, iv: Data) -> Data? {
        return (base as NSData).__fw.des3Decrypt(withKey: key, andIV: iv)
    }

    // MARK: - RSA

    /// RSA公钥加密，数据传输安全，使用默认标签，执行base64编码
    public func rsaEncrypt(publicKey: String) -> Data? {
        return (base as NSData).__fw.rsaEncrypt(withPublicKey: publicKey)
    }

    /// RSA公钥加密，数据传输安全，可自定义标签，指定base64编码
    public func rsaEncrypt(publicKey: String, tag: String, base64Encode: Bool) -> Data? {
        return (base as NSData).__fw.rsaEncrypt(withPublicKey: publicKey, andTag: tag, base64Encode: base64Encode)
    }

    /// RSA私钥解密，数据传输安全，使用默认标签，执行base64解密
    public func rsaDecrypt(privateKey: String) -> Data? {
        return (base as NSData).__fw.rsaDecrypt(withPrivateKey: privateKey)
    }

    /// RSA私钥解密，数据传输安全，可自定义标签，指定base64解码
    public func rsaDecrypt(privateKey: String, tag: String, base64Decode: Bool) -> Data? {
        return (base as NSData).__fw.rsaDecrypt(withPrivateKey: privateKey, andTag: tag, base64Decode: base64Decode)
    }

    /// RSA私钥加签，防篡改防否认，使用默认标签，执行base64编码
    public func rsaSign(privateKey: String) -> Data? {
        return (base as NSData).__fw.rsaSign(withPrivateKey: privateKey)
    }

    /// RSA私钥加签，防篡改防否认，可自定义标签，指定base64编码
    public func rsaSign(privateKey: String, tag: String, base64Encode: Bool) -> Data? {
        return (base as NSData).__fw.rsaSign(withPrivateKey: privateKey, andTag: tag, base64Encode: base64Encode)
    }

    /// RSA公钥验签，防篡改防否认，使用默认标签，执行base64解密
    public func rsaVerify(publicKey: String) -> Data? {
        return (base as NSData).__fw.rsaVerify(withPublicKey: publicKey)
    }

    /// RSA公钥验签，防篡改防否认，可自定义标签，指定base64解码
    public func rsaVerify(publicKey: String, tag: String, base64Decode: Bool) -> Data? {
        return (base as NSData).__fw.rsaVerify(withPublicKey: publicKey, andTag: tag, base64Decode: base64Decode)
    }
    
}
