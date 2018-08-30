//
//  ResModel.swift
//  MyPlayer
//
//  Created by ZZN on 2017/9/15.
//  Copyright © 2017年 ZZN. All rights reserved.
//

import UIKit
import YYModel

class ResModel: NSObject {

    var code:String?
    var msg:String?
    var data:AnyObject?
    
    
    
    var user:NSDictionary?
    var vip:String?
    var nickname:String?
    var avatar:String?
    
    
    var next_status:NSNumber?
    
    var room:NSArray?
    
    var favorite:NSNumber?
    var id:String?
    var name:String?
    var snapshot:String?
    var link:String?
    var status:String?
    var update_time:String?
    var message:String?
    
    var like:NSNumber?
    var token:String?
    var menu:Array<Any>?
    

    static func modelContainerPropertyGenericClass() -> [String : Any]? {
        
        return ["room":ResModel.classForCoder()];
    }
    
}
