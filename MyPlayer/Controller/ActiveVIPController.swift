//
//  ActiveVIPController.swift
//  MyPlayer
//
//  Created by ZZN on 2017/9/17.
//  Copyright © 2017年 ZZN. All rights reserved.
//

import UIKit


class ActiveVIPController: BaseViewController {

    @IBOutlet weak var activeCodeTF: UITextField!
    @IBOutlet weak var activeBtn: UIButton!
    
    override func viewDidLoad() {
        
        
        
        activeBtn.bk_(whenTapped: { [weak self] in
        
            if self?.activeCodeTF.text?.isEmpty == true {
                HUD.showError(title: "请输入激活码")
                return
            }
            
            let dict = ["code":self?.activeCodeTF.text ?? ""]
            GTApi<ResModel>.vip.post(params: dict).subscribe(onNext: { [weak self] (res) in
                
                HUD.showSuccess(title: "激活成功")
                self?.navigationController?.popViewController(animated: true)
            }, onError: { (error) in
            
                let err = error as? GTNetError
                HUD.showError(title: err?.msg ?? "")
            }).disposed(by: self!.disposeBag)
        })
    }
    
}
