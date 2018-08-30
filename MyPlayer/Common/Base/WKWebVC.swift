//
//  QMBaseWKWebVC.swift
//  QianmiQB
//
//  Created by zzn on 2017/4/19.
//  Copyright © 2017年 Qianmi Network. All rights reserved.
//

import UIKit
import WebKit
import SnapKit


class WKWebVC: BaseViewController {
    
    // js 操作模型
    final let jsModelName = "GTWEBKVC"
    // url 地址
    var url:String?
    
    var model:ResModel?
    
    
    var videoUrl:String?// = "https://streamer.camdolls.com/31/hls/stream_5136075_360/index.m3u8?CAMDOLLS=\\"
    
    var favoriteItem:UIBarButtonItem?
    var closeItem:UIBarButtonItem?
    var leftItems:NSMutableArray?
    var webView:WKWebView?
    
    var isAddLike:Bool = false {
        
        didSet{
            
            let title = (isAddLike == true) ? "取消收藏":"收藏"
            self.navigationItem.rightBarButtonItem?.title = title
        }
    }
    /// 进度条
    var progressView:UIProgressView?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        setupView()
        initData()
        
    }
    
    //  初始化URL
    init(urlStr:String) {
        super.init(nibName: nil, bundle: nil)
        url = urlStr
        hidesBottomBarWhenPushed = true
    }
    
    
    private override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    private init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    internal required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initData() {
        
        guard let localUrl =  Bundle.main.url(forResource: "video", withExtension: "html") else { return }
        
        let req = URLRequest.init(url: localUrl, cachePolicy: URLRequest.CachePolicy.useProtocolCachePolicy, timeoutInterval: 5)
        
        
        videoUrl = model?.link ?? ""
        let js = "if(Hls.isSupported()) {" +
            "var video = document.getElementById('video');" +
            "var hls = new Hls();" +
            "var hls_path = \(videoUrl!)" +
            "hls.loadSource(hls_path);" +
            
            
            "hls.attachMedia(video);" +
            "hls.on(Hls.Events.MANIFEST_PARSED,function() {" +
            "video.play();" +
            "});" +
        "}"
        
        
        let jsTitle = "document.title = 'xxxxxx';"
        webView?.evaluateJavaScript(js,completionHandler: nil)
        webView?.evaluateJavaScript(jsTitle, completionHandler: nil)
        
        webView!.load(req)
        
        
        //        navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName:UIFont.systemFont(ofSize: 14),NSForegroundColorAttributeName:UIFont.systemFont(ofSize: 14)]
        
        // 监听URL改变
        rx.observe(String.self, "url").subscribe(onNext: { [weak self] (value) in
            
            guard let newV = value else { return }
            guard let url = URL(string: newV) else { return }
            self?.webView?.load(URLRequest(url: url))
            }, onError: { (error) in
        }).disposed(by: disposeBag)
        
        // 监听进度条
        rx.observe(Float.self, "webView.estimatedProgress").subscribe(onNext: { [weak self] (pro) in
            
            guard let progress = pro else { return }
            debugPrint(progress)
            self?.progressView?.progress = progress
            }, onError: { (error) in
        }).disposed(by: disposeBag)
        
        
        // 请求是否收藏
        let dict = ["room_id":model?.id ?? "0"]
        GTApi<ResModel>.checkLike.post(params: dict).subscribe(onNext: { [weak self] (res) in
            
            
            let title = (res.like == 0) ? "收藏":"取消收藏"
            self?.navigationItem.rightBarButtonItem?.title = title
            self?.favoriteItem?.isEnabled = true
            self?.isAddLike = (res.like == 0) ? false:true
            
            }, onError: { (err) in
                
                print(err)
        }).addDisposableTo(disposeBag)
    }
    
    deinit {
        // 销毁
        webView?.configuration.userContentController.removeScriptMessageHandler(forName: jsModelName)
        progressView?.removeFromSuperview()
    }
    
    //
    override func viewWillDisappear(_ animated: Bool) {
        progressView?.removeFromSuperview()
    }
    
    func setupView() {
        
        
        //webview
        let configure = WKWebViewConfiguration()
        configure.allowsInlineMediaPlayback = true
        configure.userContentController = WKUserContentController()
        configure.userContentController.add(self, name: jsModelName)
        
        webView = WKWebView.init(frame: view.frame , configuration: configure)
        webView?.translatesAutoresizingMaskIntoConstraints = false
        webView?.allowsBackForwardNavigationGestures = true
        webView?.navigationDelegate = self
        webView?.uiDelegate = self
        view.addSubview(webView!)
        
        
        webView?.snp.makeConstraints({ (make) in
            make.top.left.equalTo(0)
            make.bottom.right.equalTo(0)
        })
        

        //progressview
        progressView = UIProgressView(progressViewStyle: UIProgressViewStyle.bar)
        progressView!.frame = CGRect(x:0, y:64 - 1, width:view.mj_w, height:1);
        progressView?.tintColor = UIColor.blue
        navigationController?.view.addSubview(progressView!)
        
        
        
        favoriteItem = UIBarButtonItem(title: "收藏", style: UIBarButtonItemStyle.done, target: self, action: #selector(self.handleLike))
        favoriteItem?.isEnabled = false
        
//        navigationController?.navigationItem.rightBarButtonItem = favoriteItem
//        navigationItem.rightBarButtonItem = favoriteItem

        
    }
    
    // 
    func handleLike() {
     
        if isAddLike == true {
            removeAddLike()
        } else {
            addLike()
        }
    }
    
    //
    func addLike() {
        
        let dict = ["room_id":model?.id ?? "0"]
        HUD.showStatus(title: "收藏中")
        GTApi<ResModel>.addLike.post(params: dict).subscribe(onNext: { [weak self] (res) in
            
            self?.isAddLike = true
            HUD.showSuccess(title: "收藏成功")
        }, onError: { (err) in
            

            HUD.showError(title: "收藏成功")
        }).addDisposableTo(disposeBag)
        
    }
    
    // 
    func removeAddLike() {
        
        let dict = ["room_id":model?.id ?? "0"]
        HUD.showStatus(title: nil)
        GTApi<ResModel>.offLike.post(params: dict).subscribe(onNext: { [weak self] (res) in
            
            self?.isAddLike = false
            HUD.showSuccess(title: "取消收藏成功")
        }, onError: { (err) in
            HUD.showError(title: "取消收藏成功")
        }).addDisposableTo(disposeBag)
        
    }
    
}
extension WKWebVC:WKNavigationDelegate,WKScriptMessageHandler,WKUIDelegate {
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        //window.webkit.messageHandlers.DPLUS.postMessage({body:message});
        if message.name == "QMWKVC" {
            //根据传递的 dict判断
            _ = message.body as? NSDictionary
        }
    }
    
    
    //开始
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        progressView?.isHidden = false;
        //        title = "加载中..."
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        
    }
    
    //完成
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        
        progressView?.isHidden = true
        title = webView.title
        
        //        if webView.canGoBack {
        //
        //            navigationItem.leftBarButtonItems = [backItem!,closeItem!]
        //            rt_navigationController?.interactivePopGestureRecognizer!.isEnabled = false;
        //        } else {
        //            navigationItem.leftBarButtonItems = [backItem!]
        //            rt_navigationController?.interactivePopGestureRecognizer!.isEnabled = true;
        //        }
    }
    //加载失败
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        
        //        HUD.showError(title: "连接错误")
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}
