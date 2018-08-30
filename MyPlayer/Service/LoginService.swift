//
//  LoginService.swift
//  MyPlayer
//
//  Created by ZZN on 2017/9/16.
//  Copyright © 2017年 ZZN. All rights reserved.
//

import UIKit
import RxSwift

class LoginService: NSObject {
    
    
    let dispose = DisposeBag()
    // 登录
    func refresh(succ:((_ model:ResModel)->())? = nil,fail:((_ error:GTNetError?)->())? = nil) {
        
        let dict = [String:String]()
        GTApi<ResModel>.personal.post(params: dict).subscribe(onNext: { (res) in
            
            if succ != nil { succ!(res) }
            
        }, onError: { (error) in
            
            let err = error as? GTNetError
            if fail != nil { fail!(err) }
        }).disposed(by: dispose)

        
    }
    
    
    private override init() {
        super.init()
    }
    static let manger:LoginService = {
        
        let instance = LoginService()
        return instance
    }()
    
}


