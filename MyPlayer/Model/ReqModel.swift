//
//  ReqModel.swift
//  MyPlayer
//
//  Created by ZZN on 2017/9/15.
//  Copyright © 2017年 ZZN. All rights reserved.
//

import UIKit

class ReqModel: NSObject {

    
    var phone:String?
    var sign:String?
    var password:String?
    var code:String?
    var invite_code:String?
    
    
    var room_id:String?
    var sites:String?
    var type:String?
    var page:String?
    
    
    func toDict() -> [String:Any] {
        
        let dict = self.yy_modelToJSONObject() as? [String:Any] ?? [String:Any]()
        return dict
    }
}
