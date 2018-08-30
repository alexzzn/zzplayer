////
////  GTNet.swift
////  GoldTreasure
////
////  Created by ZZN on 2017/6/27.
////  Copyright © 2017年 zhaofanjinrong.com. All rights reserved.
////
//
import UIKit
import Alamofire
import SwiftyJSON
import YYModel
import RxSwift
import RxCocoa




enum BaseUrl:String {
    
    //    case dev = "http://118.89.164.101/api"
    case dev = "http://43.249.207.159/api"
    
}

enum GTNetType {
    case dev
    case formal
}

enum GTApi<T:NSObject>:String {
    
    
    // block 回调
    //    typealias successClosure = (_ value:AnyObject) -> Void
    //    typealias failureClosure = (_ error:GTNetError) -> Void
    //    typealias successFileClosure = (_ value:Data?) -> Void
    //    typealias completedClosure = (_ value:Data?) -> Void
    
    
    case sendCode       = "send_code"
    case register       = "register"
    case login          = "login"
    case resetPwd       = "reset_pwd"
    case checkLogin     = "check_login"
    case loginWithCode  = "code_login"
    
    
    case personal       = "personal/personal"
    case offLike        = "personal/off_like"
    case avatar         = "personal/avatar"
    case addLike        = "personal/add_like"
    case vip            = "personal/vip"
    
    case update         = "personal/update"
    
    case index          = "index/index"
    case like           = "index/like"
    
    case checkLike      = "index/check_like"
    case tourist        = "tourist"
    case menu           = "menu"
    
    
    func url() -> String {
        
        return  BaseUrl.dev.rawValue + "/" + self.rawValue
    }
    
    //post请求
    func post(params:[String:Any]?) -> Observable<T> {
        
        // 判断网络状态
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        
        return Observable.create({ (observer) -> Disposable in
            
            
            GTNet.post(url: self.url(), params: params ?? [String:Any](), success: { (v) in
                
                
                
                // 判断 body 类型
                if let bodyParams = v as? NSDictionary {
                    
                    let copyParams = NSDictionary(dictionary: bodyParams)
                    
                    debugPrint(copyParams)
                    guard let model = T.yy_model(withJSON: copyParams) else { return }
                    observer.onNext(model)
                    
                } else if let arrList = v as? NSArray {
                    
                    debugPrint(arrList)
                    guard let model = T.yy_model(withJSON: arrList) else { return }
                    observer.onNext(model)
                    
                }
                
                observer.onCompleted()
                
            }, failure: { (error) in
                
                observer.onError(error)
            })
            
            return Disposables.create()
        })
    }
    
}




class GTNet {
    
    // block 回调
    typealias successClosure = (_ value:AnyObject) -> Void
    typealias failureClosure = (_ error:GTNetError) -> Void
    typealias successFileClosure = (_ value:Data?) -> Void
    typealias completedClosure = (_ value:Data?) -> Void
    
    // 网络配置
    static let netType = GTNetType.dev
    // 监听网络连接
    var netReachability = NetworkReachabilityManager.init(host: "www.baidu.com")
    //获取网络状态
    class func isAccNet() -> Bool {
        
        return GTNet.manger.netReachability?.isReachable ?? false
    }
    
    //入口
    static let manger:GTNet = {
        
        let instance = GTNet()
        return instance
    }()
    
    //私有化实例
    private init() {
        
    }
}

//
extension GTNet {
    
    // post请求
    static func post(url:String,params:[String:Any], success:@escaping successClosure, failure:@escaping failureClosure) {
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        
        // 签名
        var dict = params
        
        if GTUser.isLogin() {
            dict["token"] = GTUser.getToken()
        }
        
        
        dict["sign"] = SecUtils.paramsMd5(dict: dict)
        
        
        debugPrint("url->",url)
        // 判断网络状态
        request(url, method: HTTPMethod.post, parameters: dict, encoding: URLEncoding.default, headers: nil)
            .validate(contentType:  ["application/x-www-form-urlencoded","text/html","application/json"])
            .responseJSON(completionHandler: { (res) in
                
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                if res.result.isSuccess {
                    
                    // json data
                    guard let jsonData = res.data else {
                        success(NSDictionary())
                        return
                    }
                    // 解析json -> dict
                    guard let dict = JSON.init(data: jsonData).dictionaryObject else {
                        
                        success(NSDictionary())
                        return
                    }
                    
                    // 根据状态码 判断
                    let model = ResModel.yy_model(with: dict)
                    debugPrint(dict.debugDescription)
                    if model?.code == "0" {
                        
                        // 判断 body 类型
                        if let bodyParams = model?.data as? NSDictionary {
                            
                            let copyParams = NSMutableDictionary(dictionary: bodyParams)
                            copyParams["msg"] = model?.msg ?? ""
                            success(bodyParams)
                            
                        } else if let arrList = model?.data as? NSArray {
                            
                            success(arrList)
                        } else if let jsonStr = model?.data as? NSString  {
                            
                            success(jsonStr)
                        } else {
                            
                            let dict = NSMutableDictionary()
                            dict["msg"] = model?.msg ?? ""
                            success(dict)
                        }
                        
                    } else {
                        
                        let code = model?.code ?? "500"
                        let error = GTNetError.init(errCode: code, msg: model?.msg ?? "未知错误")
                        failure(error)
                    }
                }
                
                if res.result.isFailure || res.error != nil {
                    
                    
                    let code = res.response?.statusCode ?? 500
                    let error = GTNetError.init(errCode: code.description, msg: "服务连接失败")
                    failure(error)
                    debugPrint(res.debugDescription)
                }
                
            })
    }
    
    // 上传头像
    static func upload() {
        
    }
    
    
    
    
    
    //图片上传
    class func requestUpload(url: String, params: [String: String], data: Data, success: @escaping(_ response: [String: AnyObject])->(), fail:@escaping(_ error: Error) -> ()){
        
        let headers = ["content-type":"multipart/form-data"]
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in

                    
            for (k,v) in params {
                multipartFormData.append((v.data(using: String.Encoding.utf8))!, withName: k)
            }
            
            
            multipartFormData.append(data, withName: "avatar", fileName: "avatar", mimeType: "image/jpeg")
            
            
        }, to: url, headers: headers, encodingCompletion:{ encodingResult in
            switch encodingResult{
            case .success(request: let upload,_,_):
                upload.responseJSON(completionHandler: { (response) in
                    if let value = response.result.value as? [String : AnyObject]{
                        success(value)
                    }
                })
            case .failure(let error):
                fail(error)
            }
        })
    }
}
