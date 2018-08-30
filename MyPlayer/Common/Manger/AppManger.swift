//
//  AppManger.swift
//  MyPlayer
//
//  Created by ZZN on 2017/9/16.
//  Copyright © 2017年 ZZN. All rights reserved.
//

import UIKit
import RxSwift
import BlocksKit

class AppManger: NSObject {

    let dispag = DisposeBag()
    func config() {
        
        GTUser.manger.reloadUserInfo(succ: nil, fail: nil)
        
        Timer.bk_scheduledTimer(withTimeInterval: 180, block: { [weak self] (time) in
            
            self?.checkLoginStatus()
        }, repeats: true).fire()
    }
    
    
    func checkLoginStatus() {

//        if GTUser.isLogin() == false {
//
//            DispatchQueue.main.asyncAfter(wallDeadline: DispatchWallTime.now() + 3) {
//
//                HUD.showError(title: "请登录帐号")
//                GTUser.manger.loginIn(succ: nil, fail: nil)
//            }
//        }



        GTApi<ResModel>.checkLogin.post(params: nil).subscribe(onNext: { (res) in
            
            
        }, onError: { (error) in
            
            
            let err = error as? GTNetError
            
            if err?.errCode == "010004" || err?.errCode == "010003" {
                
                GTUser.manger.loginIn(succ: nil, fail: nil)
                HUD.showToast(info: "帐号在其他地方登录，请重新登录")
                GTUser.setLogin(islogin: false)
            }
            
            
        }).disposed(by: dispag)
    }
    
    
    private override init() {
        super.init()
    }
    static let manger:AppManger = {
        
        let instance = AppManger()
        return instance
    }()
    
}
