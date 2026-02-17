//
//  DMNetEaseCrypto.swift
//  diumoo
//
//  Created by OpenCode Agent on 2/17/2026.
//  NetEase Cloud Music encryption algorithms
//  Based on: https://github.com/xjbeta/NeteaseMusic-macOS
//

import Foundation
import CommonCrypto
import CryptoKit

@objcMembers public class DMNetEaseCrypto: NSObject {

    // MARK: - Constants

    static let base62 = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    static let presetKey = "0CoJUm6Qyw8W8jud"
    static let iv = "0102030405060708"
    static let linuxapiKey = "rFgB&h#%2?^eDg:Q"
    static let eapiKey = "e82ckenh8dichen8"

    static let publicKey = """
-----BEGIN PUBLIC KEY-----
MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDgtQn2JZ34ZC28NWYpAUd98iZ37BUrX/aKzmFbt7clFSs6sXqHauqKWqdtLkF2KexO40H1YTX8z2lSgBBOAxLsvaklV8k4cBFK9snQXE9/DDaFt6Rr7iVZMldczhC0JNgTz+SHXT6CBHuX3e9SdB1Ua44oncaTWz7OBGLbCiK45wIDAQAB
-----END PUBLIC KEY-----
"""

    // MARK: - RSA Encryption

    static func rsaEncrypt(_ data: Data, with publicKeyString: String) -> String? {
        let publicKey = publicKeyString
            .replacingOccurrences(of: "-----BEGIN PUBLIC KEY-----", with: "")
            .replacingOccurrences(of: "-----END PUBLIC KEY-----", with: "")
            .replacingOccurrences(of: "\n", with: "")

        guard let keyData = Data(base64Encoded: publicKey) else {
            print("❌ Failed to decode public key")
            return nil
        }

        var error: Unmanaged<CFError>?
        guard let key = SecKeyCreateWithData(
            keyData as CFData,
            [
                kSecAttrKeyType: kSecAttrKeyTypeRSA,
                kSecAttrKeyClass: kSecAttrKeyClassPublic,
                kSecAttrKeySizeInBits: (keyData.count * 8) as NSNumber
            ] as CFDictionary,
            &error
        ) else {
            if let error = error {
                print("❌ Failed to create SecKey: \(error.takeRetainedValue() as Error)")
            }
            return nil
        }

        var error2: Unmanaged<CFError>?
        guard let encryptedData = SecKeyCreateEncryptedData(
            key,
            .rsaEncryptionRaw,
            data as CFData,
            &error2
        ) else {
            if let error = error2 {
                print("❌ RSA encryption failed: \(error.takeRetainedValue() as Error)")
            }
            return nil
        }

        return (encryptedData as Data).hexString
    }

    // MARK: - AES Encryption

    static func aesEncrypt(_ text: String, key: String, iv: String) -> String? {
        guard let textData = text.data(using: .utf8),
              let keyData = key.data(using: .utf8),
              let ivData = iv.data(using: .utf8) else {
            return nil
        }

        var numBytesEncrypted: size_t = 0
        let bufferSize = textData.count + kCCBlockSizeAES128
        var buffer = Data(count: bufferSize)

        let status = buffer.withUnsafeMutableBytes { bufferBytes in
            textData.withUnsafeBytes { textBytes in
                keyData.withUnsafeBytes { keyBytes in
                    ivData.withUnsafeBytes { ivBytes in
                        CCCrypt(
                            CCOperation(kCCEncrypt),
                            CCAlgorithm(kCCAlgorithmAES),
                            CCOptions(kCCOptionPKCS7Padding),
                            keyBytes.baseAddress, keyData.count,
                            ivBytes.baseAddress,
                            textBytes.baseAddress, textData.count,
                            bufferBytes.baseAddress, bufferSize,
                            &numBytesEncrypted
                        )
                    }
                }
            }
        }

        guard status == kCCSuccess else {
            print("❌ AES encryption failed with status: \(status)")
            return nil
        }

        buffer.count = numBytesEncrypted
        return buffer.base64EncodedString()
    }

    // MARK: - WeAPI Encryption (for web API)

    static func weapiEncrypt(_ params: [String: Any]) -> [String: String]? {
        guard let jsonData = try? JSONSerialization.data(withJSONObject: params, options: []),
              let text = String(data: jsonData, encoding: .utf8) else {
            return nil
        }

        // Generate random secret key (16 chars from base62)
        var secretKey = ""
        for _ in 0..<16 {
            let randomIndex = Int.random(in: 0..<base62.count)
            let index = base62.index(base62.startIndex, offsetBy: randomIndex)
            secretKey.append(base62[index])
        }

        // Double AES encryption
        guard let encrypted1 = aesEncrypt(text, key: presetKey, iv: iv),
              let encrypted2 = aesEncrypt(encrypted1, key: secretKey, iv: iv) else {
            return nil
        }

        // RSA encrypt secret key
        var reversedKey = Data(secretKey.utf8)
        reversedKey.reverse()

        // Pad to 128 bytes
        var paddedKey = Data(count: 128 - reversedKey.count)
        paddedKey.append(reversedKey)

        guard let encSecKey = rsaEncrypt(paddedKey, with: publicKey) else {
            return nil
        }

        return [
            "params": encrypted2,
            "encSecKey": encSecKey
        ]
    }

    // MARK: - LinuxAPI Encryption

    static func linuxapiEncrypt(_ params: [String: Any]) -> [String: String]? {
        guard let jsonData = try? JSONSerialization.data(withJSONObject: params, options: []),
              let text = String(data: jsonData, encoding: .utf8) else {
            return nil
        }

        guard let encrypted = aesEncryptECB(text, key: linuxapiKey) else {
            return nil
        }

        return ["eparams": encrypted.uppercased()]
    }

    // MARK: - EAPI Encryption

    static func eapiEncrypt(url: String, params: [String: Any]) -> [String: String]? {
        let text: String
        if let jsonData = try? JSONSerialization.data(withJSONObject: params, options: []),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            text = jsonString
        } else {
            text = String(describing: params)
        }

        let message = "nobody\(url)use\(text)md5forencrypt"
        let digest = md5(message)

        let data = "\(url)-36cd479b6b5-\(text)-36cd479b6b5-\(digest)"

        guard let encrypted = aesEncryptECB(data, key: eapiKey) else {
            return nil
        }

        return ["params": encrypted.uppercased()]
    }

    // MARK: - Helper: AES ECB Encryption

    static func aesEncryptECB(_ text: String, key: String) -> String? {
        guard let textData = text.data(using: .utf8),
              let keyData = key.data(using: .utf8) else {
            return nil
        }

        var numBytesEncrypted: size_t = 0
        let bufferSize = textData.count + kCCBlockSizeAES128
        var buffer = Data(count: bufferSize)

        let status = buffer.withUnsafeMutableBytes { bufferBytes in
            textData.withUnsafeBytes { textBytes in
                keyData.withUnsafeBytes { keyBytes in
                    CCCrypt(
                        CCOperation(kCCEncrypt),
                        CCAlgorithm(kCCAlgorithmAES),
                        CCOptions(kCCOptionPKCS7Padding),
                        keyBytes.baseAddress, keyData.count,
                        nil, // ECB mode, no IV
                        textBytes.baseAddress, textData.count,
                        bufferBytes.baseAddress, bufferSize,
                        &numBytesEncrypted
                    )
                }
            }
        }

        guard status == kCCSuccess else {
            print("❌ AES ECB encryption failed with status: \(status)")
            return nil
        }

        buffer.count = numBytesEncrypted
        return buffer.hexString.uppercased()
    }

    // MARK: - Helper: MD5

    static func md5(_ string: String) -> String {
        let length = Int(CC_MD5_DIGEST_LENGTH)
        var digest = [UInt8](repeating: 0, count: length)

        if let data = string.data(using: .utf8) {
            _ = data.withUnsafeBytes { (body: UnsafeRawBufferPointer) in
                CC_MD5(body.baseAddress, CC_LONG(data.count), &digest)
            }
        }

        return digest.map { String(format: "%02x", $0) }.joined()
    }
}

// MARK: - Data Extension

extension Data {
    var hexString: String {
        return reduce("") { $0 + String(format: "%02x", $1) }
    }
}
