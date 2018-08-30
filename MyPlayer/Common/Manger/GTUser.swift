//
//  GTUser.swift
//  GoldTreasure
//
//  Created by ZZN on 2017/6/28.
//  Copyright © 2017年 zhaofanjinrong.com. All rights reserved.
//

import UIKit
import Alamofire
import RxSwift
import RxCocoa


fileprivate let USERMODELCHANGENOTI = "USERMODELCHANGENOTI"

fileprivate let NOTIUSERLOGINSUCC = "NOTIUSERLOGINSUCC"
fileprivate let NOTIUSERLOGOUT = "NOTIUSERLOGOUT"


class GTUser: NSObject {
    
    // 监听网络连接
    //    fileprivate var netReachability = NetworkReachabilityManager.init(host: "www.baidu.com")
    private var changedInfoBlock:((_ model:ResModel)->Void)?
    private var disposeBag = DisposeBag.init()
    
    let dispostBag = DisposeBag()
    
    //登录成功后
    var userInfoModel:ResModel? {
        didSet{
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: USERMODELCHANGENOTI), object: nil)
        }
    }
    
    // 监听个人信息 修改
    func listenUserInfoChanged(changed:@escaping (_ model:ResModel)->Void) {
        
        NotificationCenter.default.rx.notification(Notification.Name(rawValue: USERMODELCHANGENOTI), object: nil).subscribe(onNext: {
            [weak self] (noti) in
            
            changed(self?.userInfoModel ?? ResModel())
        }).addDisposableTo(dispostBag)
    }
    // 监听退出
    func listenUserLogout(changed:@escaping ()->Void) {
        
        NotificationCenter.default.rx.notification(Notification.Name(rawValue: NOTIUSERLOGOUT), object: nil).subscribe(onNext: {
            (noti) in
            
            changed()
        }).addDisposableTo(dispostBag)
    }
    
    
    //监听登录失败
    func listnLoginSucc() {
        
    }
    
    // 刷新个人信息
    func reloadUserInfo(succ:((_ model:ResModel)->())?,fail:((_ error:GTNetError?)->())?) {
        
        LoginService.manger.refresh(succ: { (res) in
            
            // 更新个人信息model
            GTUser.manger.userInfoModel = res;
            if succ != nil { succ!(res) }
            
        }) { (err) in
            if fail != nil { fail!(err) }
        }
    }
    // 显示登录页面操作
    func loginIn(succ:((_ model:ResModel)->Void)? = nil,fail:((_ err:GTNetError)->Void)? = nil) {
        
        
        guard let nav = UIStoryboard.init(name: "Login", bundle: nil).instantiateInitialViewController() as? LoginNav else { return }
        guard let loginVC = nav.viewControllers.first as? LoginController else { return }
        
        loginVC.loginIn(succ: { (res) in
            
            
            let resModel = res
            if succ != nil { succ!(resModel) }
            
        }) { (err) in
            
            if fail != nil { fail!(err) }
        }
        
        HUD.currentNav().present(nav, animated: true, completion: nil)
    }
    // 退出登录
    func logoutWith(title:String?,proTitle:String?, succ:((Void)->Void)?,fail:((Void)->Void)?) {
        

        HUD.showAlert(content: "是否退出", trueTitle: "是", cancelTitle: "否", trueCol: { 
            
            HUD.showStatus(title: proTitle ?? "")
            // 重置 token
            GTUser.resetToken()
            GTUser.setLogin(islogin: false)
            GTUser.manger.userInfoModel = ResModel()
            

            NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIUSERLOGOUT), object: nil, userInfo: nil)
            let time: TimeInterval = 1.0
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + time) {
                
                //code
                HUD.showSuccess(title: title ?? "退出成功")
                if succ != nil { succ!() }
            }
            
        }, cancelCol: nil)
    }
    
    
    // 监听个人信息
    func initNoti() {
        
        // 登录成功通知
        NotificationCenter.default.rx
            .notification(Notification.Name(rawValue: NOTIUSERLOGINSUCC), object: nil)
            .subscribe { [weak self] (noti) in
                
                if noti.element?.userInfo != nil {
                    self?.reloadUserInfo(succ: nil, fail: nil)
                }
            }.disposed(by: disposeBag)
        
        // 监听网络连接
        GTNet.manger.netReachability?.listener = { status in
            
            switch status {
            case .notReachable:
                HUD.showToast(info: "网络断开连接")
            default:
                break
            }
        }
        GTNet.manger.netReachability?.startListening()
    }
    // 销毁
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //管理实例
    static let manger:GTUser = {
        
        let instance = GTUser()
        instance.initNoti()
        return instance
    }()
    
    private override init() {
        super.init()
    }
}

// 类方法
extension GTUser {
    //是否登陆
    class func isLogin() -> Bool {
        let bools = UserDefaults.standard.bool(forKey: USERISLOGIN)
        debugPrint(bools)
        return bools
    }
    
    //设置登陆状态
    class func setLogin(islogin:Bool) {
        
        if islogin == false {
            
            GTUser.clearCurrentUserID()
            GTUser.resetToken()
            
        } else {
            
        }
        UserDefaults.standard.set(islogin, forKey: USERISLOGIN)
        let bools = islogin
        debugPrint(bools)
    }
    //登录客服端
    class func saveLoginUser(phone:String, cusId:NSNumber, token:String) {
        
        setUserPhoneNo(phone: phone)
        setCurrentUserID(cusID: cusId)
        setToken(token:token)
        setLogin(islogin: true)
    }
    //设置当前用户手机号
    class func setUserPhoneNo(phone:String) {
        UserDefaults.standard.set(phone, forKey: APPCURRENTPHONENO)
    }
    //设置手机号
    class func getUserPhoneNo() -> String? {
        return UserDefaults.standard.object(forKey: APPCURRENTPHONENO) as? String ?? nil
    }
    
    //设置当前用户ID
    class func setCurrentUserID(cusID:NSNumber) {
        
        UserDefaults.standard.set(cusID, forKey: APPCURRENTUSERID)
    }
    //清除设置当前用户ID
    class func clearCurrentUserID() {
        
        UserDefaults.standard.removeObject(forKey: APPCURRENTUSERID)//set(cusID, forKey: APPCURRENTUSERID)
    }
    //得到当前用户的ID
    class func getCurrentUserID() -> NSNumber? {
        
        return UserDefaults.standard.object(forKey: APPCURRENTUSERID) as? NSNumber ?? nil
    }
    
    // 获取 clientid 个推
    class func getGeTuiClentID() -> String {
        
        return UserDefaults.standard.object(forKey: APPCLIENTID) as? String ?? ""
    }
    // 设置 clientid 个推
    class func setGeTuiClentID(client:String) {
        
        UserDefaults.standard.set(client, forKey: APPCLIENTID)
    }
    //查询保存的用户id
    class func getAllUserId() -> [String] {
        
        let arr = UserDefaults.standard.array(forKey: APPALLUSERID) as? [String] ?? [String]()
        return arr
    }
    //增加用户ID
    class func addUserId(cusID:String) {
        
        var arr = getAllUserId()
        arr.append(cusID)
        UserDefaults.standard.set(arr, forKey: APPALLUSERID)
    }
    // 设置当前用户token
    class func getToken() ->String {
        
        let token = UserDefaults.standard.object(forKey: APPDEFAULTUSERTOKEN) as? String ?? ""
        return token
    }
    // 读取当前token
    class func setToken(token:String?) {
        
        UserDefaults.standard.set(token, forKey: APPDEFAULTUSERTOKEN)
    }
    // 登录时初始化token
    class func resetToken() {
        UserDefaults.standard.set(APPDEFAULTUSERTOKEN, forKey: APPDEFAULTUSERTOKEN)
    }
    //    // 读取当前约定 key
    //    class func getKey() -> String {
    //
    //        return APPCURRENTUSERKEY
    //    }
    //
    //    // token 是否过期
    //    class func isDefaultTokenKey() ->Bool {
    //
    //        let isEqual =  getToken() == APPCURRENTUSERKEY
    //        return isEqual
    //    }
    
    // 设置appVer
    class func setAppVer(ver:String) {
        UserDefaults.standard.set(ver, forKey: "APPNOWVERSION")
    }
    // 读取appVer
    class func getAppVer() ->String {
        return UserDefaults.standard.object(forKey: "APPNOWVERSION") as? String ?? ""
    }
    
    // 设置是否有未读通知
    class func setAppHasNoReadNoti(isFrist:Bool) {
        
        debugPrint("设置通知->",isFrist)
        UserDefaults.standard.set(isFrist, forKey: "SETEACHAPPSTARTFRISTNOTI")
        UserDefaults.standard.synchronize()
    }
    // 获取未读通知
    class func getAppHasNoReadNoti() ->Bool {
        
        let isRead = UserDefaults.standard.object(forKey: "SETEACHAPPSTARTFRISTNOTI") as? Bool ?? false
        debugPrint("读取通知->",isRead)
        return isRead
    }
    
    
    
    // 设置引导图状态
    class func setIsShowGuider(isOk:Bool) {
        UserDefaults.standard.set(isOk, forKey: APPISSHOWGUIDEPIC)
    }
    // 获取引导图状态
    class func getIsShowGuider() -> Bool {
        return UserDefaults.standard.bool(forKey: APPISSHOWGUIDEPIC)
    }
    // 公司电话号码
    class func getCompanyServerPhone()->String {
        
        return UserDefaults.standard.object(forKey: "CompanyServerPhone") as?String ?? "-"
    }
    class func setCompanyServerPhone(phone:String?) {
        UserDefaults.standard.set(phone, forKey: "CompanyServerPhone")
    }
    
}
