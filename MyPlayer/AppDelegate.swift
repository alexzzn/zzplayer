//
//  AppDelegate.swift
//  MyPlayer
//
//  Created by ZZN on 2017/9/11.
//  Copyright © 2017年 ZZN. All rights reserved.
//

import UIKit
import Alamofire
import RxSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    
    let dis = DisposeBag.init()
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        //        AppManger.manger.config()
        //        let sub = Observable<Int>.create { (obser) -> Disposable in
        //
        ////            DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + 3, execute: {
        ////
        ////
        ////            })
        //
        //            obser.onNext(1)
        //            obser.onCompleted()
        //            return Disposables.create()
        //        }
        //
        //
        //
        ////        let subject = Obser
        //        sub.subscribe { (event) in
        //
        //            debugPrint(event)
        //        }.disposed(by: dis)
        //
        
        
        
        //        let btn = UIButton()
        //        btn.bk_(whenTapped: {
        //
        //            print("----")
        //        })
        
        
        
        
        
        //        let p = Promise<String,String>.init { (input, callback) in
        //
        //            callback("a")
        //        }.then { (input, callback) in
        //            callback(2)
        //        }
        
        
        window = UIWindow.init(frame: CGRect.zero)
        window?.rootViewController = UIViewController()
        window?.makeKeyAndVisible()
        
        enum MyErr:String,Error {
            
            case net = "net"
            case verify = "verify"
        }
        
        
        // fun1
        func getStr(pwd:String? = nil) -> Promise<String> {
            
            // exec pwd
            let v = Promise<String>.init { (fulfill, reject) in
                
                let v1 = Int(arc4random())%100 > 10 ? true : false
                
                if v1 {
                    
                    fulfill("true")
                } else {
                    
                    reject(MyErr.net)
                }
            }

            return v
        }
        
        // fun2
        func getInt(value:String? = nil) -> Promise<Int> {
            
            // exec value
            let v = Promise<Int>.init { (fulfill, reject) in
                
                fulfill(0)
            }
            
            return v
        }

        
//        getStr().then { (v) -> Promise<Int>? in
//
//            return getInt(value: v)
//        }.doExec { (v) in
//
//            print(v)
//        }
        

        
            
            
            
            
        
        //
        
        let a = DoProtocol()
        a.descPrint()
        
        //
            
            
        //----
        return true
    }
}





// 入参I，callback 返回入参为O闭包
//typealias Action<I, O> = (I, _ callback:@escaping (O) -> ()) -> Void
// Promise

//class ErrorType:Error {
//
//}

class Promise<T> {
    
    typealias fulfilled = (T) -> Void
    typealias rejected = (Error) -> Void
    typealias action = (@escaping fulfilled,@escaping rejected) -> Void
    
    // 实例化执行器
    private let executor:action
    
    // 成功回调
    private var fulfilledCallback:fulfilled?
    // 异常回调
    private var rejectedCallback:rejected?
    
    
    init(exec:@escaping action) {
        executor = exec
    }
    
    // 处理成功结果
    private func resolve(result: T) {
        
        if fulfilledCallback == nil {
            return
        }
        fulfilledCallback!(result)
    }
    
    // 处理异常结果
    private func reject(err:Error) {
        
        if rejectedCallback == nil {
            return
        }
        rejectedCallback!(err)
    }
    
    // 执行结束
    func doExec(callback:@escaping fulfilled) {
        
        fulfilledCallback = callback

        let c1:fulfilled = { [unowned self] v in
            
            self.resolve(result: v)
        }
        
        let c2:rejected = { err in
            
            self.reject(err: err)
        }
        
        executor(c1, c2)
        
    }
    
    // 异常结束
    func doCatch(callback: @escaping rejected) {
        
        rejectedCallback = callback
    }
    
    // then 处理
    func then<U>(exec: @escaping (T) -> Promise<U>?) -> Promise<U> {


        return Promise<U>{ [unowned self] (resolve, reject) in


            let c1:fulfilled = { v in
                
                exec(v)?.doExec(callback: { (obj) in
                    resolve(obj)
                })
            }
            
            let c2:rejected = { e in
                
                reject(e)
            }
            
            self.executor(c1, c2)

        }
    }
}



protocol Protocol1 {
    
    var desc:String { get }
}

extension Protocol1 {
    
    var desc: String {
        
        return "Protocol1"
    }
}

protocol Protocol2 {
    
    var desc:String { get }
}

extension Protocol2 {
    
    var desc: String {
        
        return "Protocol2"
    }
}

class DoProtocol:Protocol1,Protocol2 {
    
//    var desc: String {
//
//        return "Protocol1"
//    }
    
    var desc: String {
        
        return "P"
    }
    
    func descPrint() {
        
        let a = self as Protocol2
       
        print(a.desc)
    }

    
}










