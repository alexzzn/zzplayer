//
//  Extensions.swift
//  MyPlayer
//
//  Created by ZZN on 2017/9/16.
//  Copyright © 2017年 ZZN. All rights reserved.
//

import UIKit
var navBarBgKey = "NAVBARBGKEY"
var UserInteractionEnabled = "NAVBARTINTCOLORBGKEY"




extension NSNumber {
    
    public static func -(lhs: NSNumber, rhs: NSNumber) -> NSNumber {
        
        return NSNumber.init(value: lhs.intValue - rhs.intValue)
        
    }
}

extension Int32 {
    
    // 32 -> 64
    func toInt() -> Int {
        return Int(self)
    }
}
extension Int {
    func toString() -> String {
        
        return String.init(format: "%d", self)
    }
}

extension Float {
    
    //
    func toString() -> String {
        
        let str = String.init(format: "%.2f", self)
        return str
    }
}

extension String {
    
    
    //获得行间距富文本
    func getAttrFormString(lineH:CGFloat,font:UIFont) ->NSMutableAttributedString {
        
        let paragrapStyle = NSMutableParagraphStyle()
        paragrapStyle.lineSpacing = lineH
        paragrapStyle.alignment = NSTextAlignment.left
        //        paragrapStyle.lineSpacing =
        paragrapStyle.lineBreakMode = NSLineBreakMode.byWordWrapping
        
        let attr = NSMutableAttributedString.init(string: self)
        attr.addAttributes([NSParagraphStyleAttributeName:paragrapStyle,NSFontAttributeName:font,NSForegroundColorAttributeName:UIColor.red], range: NSMakeRange(0, attr.length))
        return attr
    }
    //截取字符 To
    func subToOffset(right:Int) ->String {
        
        if self.characters.count < right {
            
            return self
        }
        let index = self.index(self.startIndex, offsetBy: right)
        return self.substring(to: index)
    }
    //截取字符 From
    func subFromOffset(left:Int) ->String {
        
        if self.characters.count < left {
            
            return ""
        }
        let index = self.index(self.startIndex, offsetBy: left)
        return self.substring(from: index)
    }
    
    //md5
    func md5() -> String {
        
        let str = self.cString(using: String.Encoding.utf8)
        let strLen = CUnsignedInt(self.lengthOfBytes(using: String.Encoding.utf8))
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
        
        CC_MD5(str!, strLen, result)
        let hash = NSMutableString()
        for i in 0 ..< digestLen {
            hash.appendFormat("%02x", result[i])
        }
        result.deinitialize()
        return hash.lowercased //String(format: hash as String)
    }
}


//MARK - viewcontroller

extension UIViewController {
    

    /// 设置 侧滑 手势
    open var navbarInteractionEnabled: Bool {
        get {
            
            guard let isEnabled = objc_getAssociatedObject(self, &UserInteractionEnabled) as? Bool else {
                
                return true
            }
            return isEnabled
        }
        set {
            
            objc_setAssociatedObject(self, &UserInteractionEnabled,newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
    
    
    // 状态栏透明 （设置 透明 image）
    func transNavBar(isTrue:Bool) {
        
        if isTrue {
            
            navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
            navigationController?.navigationBar.shadowImage = UIImage()
            navigationController?.navigationBar.isOpaque = true
            //            hiddenNavBarShadowLine()
        } else {
            
            // 默认
            navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
            //            showNavBarShadowLine()
            navigationController?.navigationBar.shadowImage = nil
            navigationController?.navigationBar.isOpaque = false
        }
    }
    
//    // 设置默认导航栏 bar 样式
//    func setDefaultNavbarStyle() {
//        
//        let nav = self.navigationController as? RootNavVC
//        nav?.setDefaultStyle()
//    }
    
    // 设置导航栏 背景色
    
//    // 隐藏 line
//    private func hiddenNavBarShadowLine() {
//        
//        
//        let lineView = self.findHairlineImageViewUnder(navigationController?.navigationBar)
//        lineView?.isHidden = true;
//    }
//    // 显示 line
//    private func showNavBarShadowLine() {
//        
//        let lineView = self.findHairlineImageViewUnder(navigationController?.navigationBar)
//        lineView?.isHidden = false;
//    }
    
    
}
