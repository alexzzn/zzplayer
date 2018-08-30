//
//  DefineClass.swift
//  MyPlayer
//
//  Created by ZZN on 2017/9/15.
//  Copyright © 2017年 ZZN. All rights reserved.
//

import UIKit

class GTNetError: Error {
    
    var errCode:String
    var msg:String
    
    init(errCode:String,msg:String) {
        
        self.errCode = errCode
        self.msg = msg
    }

}




let screenW = UIScreen.main.bounds.size.width
let screenH = UIScreen.main.bounds.size.height
