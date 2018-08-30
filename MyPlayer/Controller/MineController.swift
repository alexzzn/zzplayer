//
//  MineController.swift
//  MyPlayer
//
//  Created by ZZN on 2017/9/16.
//  Copyright © 2017年 ZZN. All rights reserved.
//

import UIKit
import SDWebImage
import Alamofire
import SwiftyJSON

class MineController: BaseViewController {
    
    @IBOutlet weak var bgImageV: UIImageView!
    @IBOutlet weak var avterImgV: UIImageView!
    @IBOutlet weak var idNoLab: UILabel!
    @IBOutlet weak var vipBgV: UIView!
    @IBOutlet weak var vipTimeLab: UILabel!
    @IBOutlet weak var actionBtn: UIButton!
    
    
    override func viewDidLoad() {
        
        initHandle()
        avterImgV.layer.cornerRadius = 30
    }
    
    // 初始化视图
    func initUI() {
        
        if GTUser.isLogin() {
            
            actionBtn.setTitle("退出", for: UIControlState.normal)
        } else {
            
            actionBtn.setTitle("登录", for: UIControlState.normal)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        GTUser.manger.reloadUserInfo(succ: nil, fail: nil)
    }
    //
    func initNet() {
        
        //        // 登录个人信息
        //        let dict = ["token":GTUser.getToken()]
        //        GTApi<ResModel>.personal.post(params: dict).subscribe(onNext: { (res) in
        //
        //        }, onError: { (error) in
        //
        //        }).disposed(by: dispose)
        
    }
    
    func initHandle() {
        
        // 执行登录 或 退出
        actionBtn.bk_(whenTapped: {
            
            if GTUser.isLogin() {
                
                GTUser.manger.logoutWith(title: "提示", proTitle: "是否退出", succ: { [weak self] in
                    
                    self?.navigationController?.popViewController(animated: true)
                    }, fail: {
                        
                })
                
            } else {
                
                GTUser.manger.loginIn(succ: nil, fail: nil)
                
            }
        })
        
        // 个人信息改变
        GTUser.manger.listenUserInfoChanged { [weak self] (res) in
            
            
            self?.initUI()
            guard let userModel = ResModel.yy_model(with: res.user as? [AnyHashable : Any] ?? [AnyHashable:Any]()) else { return }
            
            let url = URL(string: userModel.avatar ?? "")
            
            self?.avterImgV.sd_setImage(with: url, placeholderImage: UIImage(named: "default_avatar"))
            self?.idNoLab.text = userModel.nickname
            self?.vipTimeLab.text = userModel.vip
        }
        
        // 更换头像
        avterImgV.bk_(whenTapped: { [weak self] in
            
            self?.upLoadHeadImg()
        })
        
    }
    
    //上传图片
    func upLoadHeadImg() {
        
        let titleList = ["打开相册","打开照相机"]
        
        let vc = HUD.getSheetView(titleList: titleList, sel: { (index) in
            
            if index == 0 {
                
                
                TakePhotoVC.shared.getPhotoFromAlbum(done: { [weak self] (img) in
                    
                    
                    
                    HUD.showStatus(title: "上传中")
                    

                    var dict = [String:Any]()
                    dict["token"] = GTUser.getToken()
                    dict["sign"] = SecUtils.paramsMd5(dict: dict)
                    
                    CommonTools.upload(GTApi.update.url(), parameters: dict, filesDatas: img, success: { (obj) in
                        
                        HUD.showSuccess(title: "上传成功")
                    }, failure: { (err) in
                        HUD.showError(title: "上传失败")
                    })
                    
                    
                    
                    // -------------
                    //
                    //                    var dict = [String:Any]()
                    //                    dict["token"] = GTUser.getToken()
                    //                    dict["sign"] = SecUtils.paramsMd5(dict: dict)
                    //                    dict["avatar"] = img
                    //
                    //                    request(GTApi.update.url(), method: HTTPMethod.post, parameters: dict, encoding: URLEncoding.default, headers: nil).responseData(completionHandler: { (res) in
                    //
                    //                        let data = JSON(res.data!).dictionaryObject
                    //                        let model = ResModel.yy_model(with: data!)
                    //
                    //                        if model?.code == "0" {
                    //
                    //
                    //                            HUD.showSuccess(title: "上传成功")
                    //
                    //                        } else {
                    //
                    ////                            let code = model?.code ?? "500"
                    //                            HUD.showError(title: model?.msg ?? "未知错误")
                    //                        }
                    //
                    //
                    //                    })
                    // -----------
                    
//                -----------
                    
//                    var dict = [String:Any]()
//                    dict["token"] = GTUser.getToken()
//                    dict["sign"] = SecUtils.paramsMd5(dict: dict)
//                    dict["avatar"] = img
//                    
//                    upload(multipartFormData: { (multipartFormData) in
//                        
//                        guard let token = GTUser.getToken().data(using: String.Encoding.utf8) else { return }
//                        
//                        multipartFormData.append(token, withName: "token")
//                        
//                        
//                        let dict = ["token":GTUser.getToken()]
//                        let sign = SecUtils.paramsMd5(dict: dict)
//                        
//                        
//                        multipartFormData.append(token, withName: "token")
//                        multipartFormData.append(sign.data(using: String.Encoding.utf8)!, withName: "sign")
//                        multipartFormData.append(img, withName: "avatar", mimeType: "image/png")
//                        
//    
//                        
//                    }, to: GTApi.update.url() , encodingCompletion: { (encodingResult) in
//                        
//                        switch encodingResult {
//                            
//                        case .success(let upload, _, _):
//                            
//                            
//                            upload.responseData(completionHandler: { (result) in
//                                
//                                if result.data == nil { return }
//                                let json =  JSON.init(data: result.data!)
//                                
//                                guard let dict = json.dictionaryObject else { return }
//                                
//                                let code = dict["code"] as? String ?? ""
//                                
//                                if code == "0" {
//                                    
//                                    HUD.showSuccess(title: "上传成功")
//                                } else {
//                                    let msg = dict["msg"] as? String ?? "上传失败"
//                                    HUD.showError(title: msg)
//                                }
//                                
//                                
//                            })
//                            
//                        case .failure(let encodingError):
//                            print(encodingError)
//                        }
//                        
//                    })
                    
//                    ------------

                })
                
            } else {
                
                
                
                TakePhotoVC.shared.takePhoto(done: { (img) in
                    
                    
                    HUD.showStatus(title: "上传中")
                    
                    
                    var dict = [String:Any]()
                    dict["token"] = GTUser.getToken()
                    dict["sign"] = SecUtils.paramsMd5(dict: dict)
                    
                    CommonTools.upload(GTApi.update.url(), parameters: dict, filesDatas: img, success: { (obj) in
                        
                        HUD.showSuccess(title: "上传成功")
                    }, failure: { (err) in
                        HUD.showError(title: "上传失败")
                    })
                    
                })
            }
        })
        HUD.currentNav().present(vc, animated: true, completion: nil)//pushViewController(vc, animated: true)
    }
}
