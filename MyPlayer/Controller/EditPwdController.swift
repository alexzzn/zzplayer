//
//  EditPwdViewController.swift
//  MyPlayer
//
//  Created by ZZN on 2017/9/12.
//  Copyright © 2017年 ZZN. All rights reserved.
//

import UIKit

class EditPwdController: BaseViewController {
    
    @IBOutlet weak var phoneTF: UITextField!
    @IBOutlet weak var smsCodeTF: UITextField!
    @IBOutlet weak var pwdTF: UITextField!
    @IBOutlet weak var sendSmsBtn: UIButton!
    @IBOutlet weak var registerBtn: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        initHandle()
    }
    
    
    
    func initHandle() {
        
        // 校验长度
        phoneTF.rx.text.orEmpty.subscribe(onNext: { [weak self] (value) in
            
            if value.characters.count > 11 {
                self?.phoneTF.text = value.subToOffset(right: 11)
            }
        }).disposed(by: disposeBag)
        
        smsCodeTF.rx.text.orEmpty.subscribe(onNext: { [weak self] (value) in
            
            if value.characters.count > 6 {
                self?.smsCodeTF.text = value.subToOffset(right: 6)
            }
        }).disposed(by: disposeBag)
        
        
        // 发送验证码
        sendSmsBtn.bk_(whenTapped: { [weak self] in
            
            
            let model = ReqModel()
            model.phone = self?.phoneTF.text
            let dict = model.toDict()
            
        
            HUD.showStatus(title: nil)
            GTApi<ResModel>.sendCode.post(params: dict).subscribe(onNext: { (res) in
                
                HUD.showSuccess(title: "发送成功")
                self?.setTimer()
                
            }, onError: { (error) in
                
                let err = error as? GTNetError
                HUD.showError(title: err?.msg ?? "")
                self?.sendSmsBtn.isEnabled = true
                
            }).disposed(by: self!.disposeBag)
            
            
        })
        
        // 重置密码
        registerBtn.bk_(whenTapped: { [weak self] in
            
            self?.registerBtn.isEnabled = false
            
            let model = ReqModel()
            model.phone = self?.phoneTF.text
            model.code = self?.smsCodeTF.text
            model.password = self?.pwdTF.text
            
            let dict = model.yy_modelToJSONObject() as? [String:Any] ?? [String:Any]()
            
            
            if model.phone?.isEmpty == true || model.code?.isEmpty == true || model.password?.isEmpty == true  {
                
                self?.registerBtn.isEnabled = true
                HUD.showError(title: "请检查参数是否完整？")
                return
            }
            
            HUD.showStatus(title: nil)
            GTApi<ResModel>.resetPwd.post(params: dict).subscribe(onNext: { [weak self](res) in
                
                
                HUD.showSuccess(title: "修改成功")
                GTUser.setLogin(islogin: false)
                GTUser.setToken(token: res.token)
                self?.navigationController?.popViewController(animated: true)
                
                GTUser.manger.userInfoModel = ResModel()
                GTUser.manger.loginIn(succ: nil, fail: nil)
                
                }, onError: { (error) in
                    
                    let err = error as? GTNetError
                    HUD.showError(title: err?.msg ?? "")
                    self?.registerBtn.isEnabled = true
                    
            }).disposed(by: self!.disposeBag)
            
            
            
        })
        
    }
    
    //设置定时
    func setTimer() {
        
        //
        var count = 60//设置定时
        Timer.bk_scheduledTimer(withTimeInterval: 1, block: {[weak self] (time) in
            
            if let weakself = self {
                
                count -= 1
                if count == 0  {
                    
                    weakself.sendSmsBtn.isSelected = false
                    weakself.sendSmsBtn.isUserInteractionEnabled = true
                    time?.invalidate()
                    
                } else {
                    
                    weakself.sendSmsBtn.isSelected = true
                    weakself.sendSmsBtn.isUserInteractionEnabled = false
                    weakself.sendSmsBtn.setTitle("\(count)秒", for: .selected)
                }
            }
        }, repeats: true)
        
    }
    

}
