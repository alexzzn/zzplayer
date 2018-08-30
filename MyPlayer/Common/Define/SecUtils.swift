//
//  SecUtils.swift
//  MyPlayer
//
//  Created by ZZN on 2017/9/15.
//  Copyright © 2017年 ZZN. All rights reserved.
//

import UIKit
import SwiftyJSON
import Security

class SecUtils: NSObject {
    
    
    

    // sign 签名
    class func paramsMd5(dict:[String:Any]) -> String {
        
        let newList = dict.sorted { (d1, d2) -> Bool in
            
            return d1.key < d2.key
        }
        
        
        var compentPath = ""
        if (paramsCompentWithAnd(dict: newList) ?? "").isEmpty == true {
            compentPath = "live"
        } else {
            compentPath = "&live"
        }
        let newstr = (paramsCompentWithAnd(dict: newList) ?? "") + compentPath
        
        debugPrint(newstr)
        return newstr.md5()
    }
    
    
    // dict -> string
    fileprivate class func  paramsCompentWithAnd(dict:[(key:String,value:Any)]) -> String? {
    
        var compentStr = ""
        
        let newList = dict.map { (v) -> String in
            
            let str = v.key + "=" + (v.value as? String ?? "")
            return str
        }
        
        let count = newList.count
        for i in 0 ..< count {
            
            if (i == count - 1) { 
                
                compentStr.append(newList[i])
            } else {
                
                compentStr.append(newList[i] + "&")
            }
        }
        
        return compentStr.isEmpty ? "":compentStr
    }
}
//
//extension String {
//    
//    
//    //md5
//    func md5() -> String {
//        
//        let str = self.cString(using: String.Encoding.utf8)
//        let strLen = CUnsignedInt(self.lengthOfBytes(using: String.Encoding.utf8))
//        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
//        
//        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
//        
//        CC_MD5(str!, strLen, result)
//        let hash = NSMutableString()
//        for i in 0 ..< digestLen {
//            hash.appendFormat("%02x", result[i])
//        }
//        result.deinitialize()
//        return hash.lowercased //String(format: hash as String)
//    }
//    
//}


//extension NSString {
//    
//    //md5
//    func md5() -> String {
//        
//        let str = self.cString(using: String.Encoding.utf8.rawValue)
//        let strLen = CUnsignedInt(self.lengthOfBytes(using: String.Encoding.utf8.rawValue))
//        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
//        
//        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
//        
//        CC_MD5(str!, strLen, result)
//        let hash = NSMutableString()
//        for i in 0 ..< digestLen {
//            hash.appendFormat("%02x", result[i])
//        }
//        result.deinitialize()
//        return hash.lowercased //String(format: hash as String)
//    }
//}
