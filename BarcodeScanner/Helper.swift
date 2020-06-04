//
//  Helper.swift
//  BarcodeScanner
//
//  Created by Gabriela Shaooli on 2020-06-04.
//  Copyright © 2020 Gabriela Shaooli. All rights reserved.
//

import Foundation
import CommonCrypto

// Define the different types of HMAC hashing algorithms
// HMAC = "keyed-hash message authentication code
// See: https://en.wikipedia.org/wiki/HMAC
enum HMACAlgorithm {
    case MD5, SHA1, SHA224, SHA256, SHA384, SHA512
    
    func toCCHmacAlgorithm() -> CCHmacAlgorithm {
        var result: Int = 0
        switch self {
        case .MD5:
            result = kCCHmacAlgMD5
        case .SHA1:
            result = kCCHmacAlgSHA1
        case .SHA224:
            result = kCCHmacAlgSHA224
        case .SHA256:
            result = kCCHmacAlgSHA256
        case .SHA384:
            result = kCCHmacAlgSHA384
        case .SHA512:
            result = kCCHmacAlgSHA512
        }
        return CCHmacAlgorithm(result)
    }
    
    func digestLength() -> Int {
        var result: CInt = 0
        switch self {
        case .MD5:
            result = CC_MD5_DIGEST_LENGTH
        case .SHA1:
            result = CC_SHA1_DIGEST_LENGTH
        case .SHA224:
            result = CC_SHA224_DIGEST_LENGTH
        case .SHA256:
            result = CC_SHA256_DIGEST_LENGTH
        case .SHA384:
            result = CC_SHA384_DIGEST_LENGTH
        case .SHA512:
            result = CC_SHA512_DIGEST_LENGTH
        }
        return Int(result)
    }
}

// Extend the String type to allow creations of a base64 encoded HMAC hash
extension String {
    
    func hmac(algorithm: HMACAlgorithm, key: String) -> String {
        
        let cKey = key.cString(using: String.Encoding.utf8)
        
        let cData = self.cString(using: String.Encoding.utf8)
        
        var result = [CUnsignedChar](repeating: 0, count: Int(algorithm.digestLength()))
        
        CCHmac(algorithm.toCCHmacAlgorithm(), cKey!, Int(strlen(cKey!)), cData!, Int(strlen(cData!)), &result)
        
        let hmacData:NSData = NSData(bytes: result, length: (Int(algorithm.digestLength())))
        
        let hmacBase64 = hmacData.base64EncodedString(options: NSData.Base64EncodingOptions.lineLength76Characters)
        
        return String(hmacBase64)
    }
    
}

// Build a URL to retrieve the JSON response from DigitEyes
func getDataLookupURL(forUPC providedUPC: String) -> URL {
    
    // What we need to build (for example):
    /*
     
     https://www.digit-eyes.com/gtin/v2_0/?upcCode=7501035911208 &field_names=all&language=en&app_key=/wADzn2k+r4k&signature=NaaeIhj5TNzRhjSWzyeNbca969g=
     
     */
    
    // Define the authorization key
    let myAuthKey = "Be67Q9d5b5Bm4Cr7"
    
    // Define the application key
    let myAppKey = "/wADzn2k+r4k"
    
    // Get the signature
    let signature: String = providedUPC.hmac(algorithm: .SHA1, key: myAuthKey)
    
    // Assemble the address
    let address = "https://www.digit-eyes.com/gtin/v2_0/?upcCode=\(providedUPC)&field_names=all&language=en&app_key=\(myAppKey)&signature=\(signature)"
    
    return URL(string: address)!
    
}
