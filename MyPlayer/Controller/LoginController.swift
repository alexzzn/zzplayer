//
//  LoginController.swift
//  MyPlayer
//
//  Created by ZZN on 2017/9/12.
//  Copyright © 2017年 ZZN. All rights reserved.
//

import UIKit

class LoginController: BaseViewController {
    
    @IBOutlet weak var registerBar: UIBarButtonItem!
    @IBOutlet weak var phoneTF: UITextField!
    @IBOutlet weak var pwdTF: UITextField!
    
    @IBOutlet weak var actionBtn: UIButton!
    
    var succ:((_ model:ResModel)->Void)?
    var fail:((_ err:GTNetError)->Void)?
    
    
    
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
    }
    
    @IBAction func cancelLogin(_ sender: UIBarButtonItem) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func loginAction(_ sender: UIButton) {
        
        sender.isEnabled = false
        
        let model = ReqModel()
        model.phone = phoneTF.text
        model.password = pwdTF.text
        
        HUD.showStatus(title: nil)
        GTApi<ResModel>.login.post(params: model.toDict()).subscribe(onNext: { [weak self] (res) in
            
            sender.isEnabled = true
            
            HUD.showSuccess(title: "登录成功")
            GTUser.setToken(token: res.token)
            GTUser.setLogin(islogin: true)
            
            if self?.succ != nil {  self?.succ!(res) }
            self?.navigationController?.dismiss(animated: true, completion: nil)
            
        }, onError: { [weak self] (error) in
                
                sender.isEnabled = true
                let err = error as? GTNetError
                if self?.succ != nil {  self?.fail!(err!) }
                
                HUD.showError(title: err?.msg ?? "")
                
        }).disposed(by: disposeBag)
    }
    
    // 登录
    func loginIn(succ:((_ model:ResModel)->Void)? = nil,fail:((_ error:GTNetError)->Void)? = nil) {
        
        
        
        self.fail = fail
        self.succ = succ
    }
    
    
}
