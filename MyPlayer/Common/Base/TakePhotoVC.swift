//
//  TakePhotoVC.swift
//  QianmiQB
//
//  Created by zzn on 2017/4/11.
//  Copyright © 2017年 Qianmi Network. All rights reserved.
//

import UIKit
import AVFoundation
import AssetsLibrary

class TakePhotoVC: UIViewController {
    
    fileprivate var closure:((_ img:Data)->())?
    lazy var picker:UIImagePickerController = {
        return UIImagePickerController.init()
    }()
    //
    static let shared:TakePhotoVC = {
        let instance = TakePhotoVC()
        return instance
    }()

    //照相
    func takePhoto(done:@escaping (_ img:Data)->()) {
        
        
        picker.delegate = self
        
        let authStatus = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        
        if (authStatus == AVAuthorizationStatus.restricted || authStatus == AVAuthorizationStatus.denied) {
            
            let alert = UIAlertView.init(title: nil, message: "设置-隐私-照片 选项中允许程序访问你的相机", delegate: nil, cancelButtonTitle: "好的")
            alert.show()
            return
        }
        
        if (!UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)) {
            
            let alert = UIAlertView.init(title: nil, message: "相机不可用", delegate: nil, cancelButtonTitle: "好的")
            alert.show()
            return
        }
        
        closure = done
        
        picker.sourceType = UIImagePickerControllerSourceType.camera
        HUD.currentNav().present(picker, animated: true, completion: nil)
    }
    //获取相册
    func getPhotoFromAlbum(done:@escaping (_ img:Data)->()) {
        
        picker.delegate = self
        
        let authStatus = ALAssetsLibrary.authorizationStatus()
        
        if (authStatus == ALAuthorizationStatus.restricted || authStatus == ALAuthorizationStatus.denied) {
            
            let alert = UIAlertView.init(title: nil, message: "设置-隐私-照片 选项中允许程序访问你的相册", delegate: nil, cancelButtonTitle: "好的")
            alert.show()
            return
        }
        
        if (!UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary)) {
            
            let alert = UIAlertView.init(title: nil, message: "相册不可用", delegate: nil, cancelButtonTitle: "好的")
            alert.show()
            return
        }
        
        closure = done
        
        picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        HUD.currentNav().present(picker, animated: true, completion: nil)
        
        
    }
    
    
}

extension TakePhotoVC:UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        picker.dismiss(animated: true, completion: nil)
        let type = info[UIImagePickerControllerMediaType] as? String
        
        if type == "public.image" {
            
            let img = info[UIImagePickerControllerOriginalImage] as? UIImage
            guard let imgdata = UIImageJPEGRepresentation(img!, 0.2) else { return }
            
            if closure != nil {
                
                closure!(imgdata)
            }
        }
    }
    
}

