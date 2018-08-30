//
//  HomeController.swift
//  MyPlayer
//
//  Created by ZZN on 2017/9/12.
//  Copyright © 2017年 ZZN. All rights reserved.
//

import UIKit
import MJRefresh

class HomeVideoController: BaseViewController {

    @IBOutlet weak var collectionView: UICollectionView!
   

    var sites:String?
    var currentPage = 1
    var videoType = 1

    var modelList = [ResModel]() {

        didSet{
            layoutUI()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        initHandle()
        reqNewData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        debugPrint("appear")
    }


    func layoutUI() {


        
        OperationQueue.main.addOperation { [weak self] in
            
            
            if self?.modelList.count == 0 {
                HUD.showToast(info: "没有数据")
                self?.collectionView.reloadData()
                
            } else {
                self?.collectionView.reloadData()
            }
            
        }

    }

    func initUI() {


        collectionView.frame = view.frame
        let layout = UICollectionViewFlowLayout.init()


        layout.sectionInset = UIEdgeInsetsMake(15, 15, 15, 15)
        layout.itemSize = CGSize(width:(view.mj_w-45)/2, height: 210)
        layout.minimumLineSpacing = 15
        layout.minimumInteritemSpacing = 15

        collectionView.collectionViewLayout = layout
        collectionView.delegate = self
        collectionView.dataSource = self
        
        
        
        if #available(iOS 11.0, *) {
            self.collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentBehavior.automatic;
        }else {
            self.automaticallyAdjustsScrollViewInsets = false;
            self.collectionView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0)
            self.collectionView.translatesAutoresizingMaskIntoConstraints = false
        }
    }


    func initHandle() {

        

        collectionView.mj_header = RefreshView.manger.header(closure: { [weak self] in

            self?.reqNewData()
        })

        
        
        if videoType == 1 {
            
            collectionView.mj_footer = RefreshView.manger.footer(closure: { [weak self] in
                
                self?.reqMoreData()
            })
            collectionView.mj_footer.isHidden = true
        }



        GTUser.manger.listenUserInfoChanged { [weak self]  (model) in
            self?.reqNewData()
        }


        GTUser.manger.listenUserLogout { [weak self] in
            self?.modelList = [ResModel]()
        }

        
    }

    // 请求新数据
    func reqNewData() {

        var dict = ["type":videoType.toString()]
        
        if sites != nil {
            dict["sites"] = sites
        }
        
        self.currentPage = 1
        
        
        if GTUser.isLogin() {
            
            GTApi<ResModel>.index.post(params: dict).subscribe(onNext: {[weak self] (res) in
                
                guard let list = res.room as? [ResModel] else { return }
                self?.collectionView.mj_header.endRefreshing()
                self?.modelList = list
                
                if self?.collectionView.mj_footer != nil {
                    self?.collectionView.mj_footer.isHidden = false
                }
                
                
                }, onError: { [weak self] (error) in
                    
                    let err = error as? GTNetError
                    self?.collectionView.mj_header.endRefreshing()
                    HUD.showError(title: err?.msg ?? "未知错误")
                    
            }).disposed(by: disposeBag)
            
        } else {
            
            GTApi<ResModel>.tourist.post(params: dict).subscribe(onNext: {[weak self] (res) in
                
                guard let list = res.room as? [ResModel] else { return }
                self?.collectionView.mj_header.endRefreshing()
                self?.modelList = list
                if self?.collectionView.mj_footer != nil {
                    self?.collectionView.mj_footer.isHidden = false
                }
                
                
                }, onError: { [weak self] (error) in
                    
                    let err = error as? GTNetError
                    self?.collectionView.mj_header.endRefreshing()
                    HUD.showError(title: err?.msg ?? "未知错误")
                    
            }).disposed(by: disposeBag)
        }
        


    }

    // 请求更多数据
    func reqMoreData() {

        let newPage = currentPage + 1
        
        
        
        var dict = ["type":videoType.toString(),"page":newPage.toString()]
        
        if sites != nil {
            dict["sites"] = sites
        }
        if GTUser.isLogin() {
            
            GTApi<ResModel>.index.post(params: dict).subscribe(onNext: {[weak self] (res) in
                
                guard let list = res.room as? [ResModel] else { return }
                
                self?.currentPage += 1
                self?.modelList.append(contentsOf: list)
                self?.collectionView.mj_footer.endRefreshing()
                
                }, onError: { [weak self] (error) in
                    
                    let err = error as? GTNetError
                    self?.collectionView.mj_footer.endRefreshing()
                    HUD.showError(title: err?.msg ?? "未知错误")
                    
            }).disposed(by: disposeBag)
        } else {
            
            
            GTApi<ResModel>.tourist.post(params: dict).subscribe(onNext: {[weak self] (res) in
                
                guard let list = res.room as? [ResModel] else { return }
                
                self?.currentPage += 1
                self?.modelList.append(contentsOf: list)
                self?.collectionView.mj_footer.endRefreshing()
                
                }, onError: { [weak self] (error) in
                    
                    let err = error as? GTNetError
                    self?.collectionView.mj_footer.endRefreshing()
                    HUD.showError(title: err?.msg ?? "未知错误")
                    
            }).disposed(by: disposeBag)
            
        }
        
  
    }
}

extension HomeVideoController:UICollectionViewDataSource, UICollectionViewDelegate {


    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 4
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 4
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return modelList.count
    }
    //cellForItemAt indexPath
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {


        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionViewCell", for: indexPath) as! HomeVideoControllerCell



        if modelList.count > 0 {
            cell.model = modelList[indexPath.row]
        }

        return cell
    }
    //
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        let model = modelList[indexPath.row]

        let webVc = WKWebVC.init(urlStr: model.link ?? "")

        webVc.videoUrl = model.link ?? ""
        webVc.model = model
        webVc.title = model.name

        let vc = PlayerViewController()
        vc.imageUrl = model.snapshot
        vc.liveUrl = model.link
        vc.title = model.name
        


        let vipStr = GTUser.manger.userInfoModel?.user?.object(forKey: "vip") as? String

        let timeInv = CommonTools.timeSwitchTimestamp(vipStr, andFormatter: "YYYY-MM-dd hh:mm:ss")
        let nowInv = Date().timeIntervalSince1970

        _ = NSInteger(nowInv) > timeInv ? true:false



        if !GTUser.isLogin() {

            HUD.showAlert(content: "帐号未登录，是否登录?", trueTitle: "是", cancelTitle: "否", trueCol: {

                GTUser.manger.loginIn(succ: nil, fail: nil)
            }, cancelCol: nil)
        }

        if vipStr == "非会员" {

            HUD.showAlert(content: "请办理会员服务", trueTitle: "办理", cancelTitle: "否", trueCol: { [weak self] in

                let newVc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "addvipvc")
                self?.navigationController?.pushViewController(newVc, animated: true)

                }, cancelCol: nil)

        } else {
            
            
            if self.videoType == 0 {
                navigationController?.pushViewController(vc, animated: true)
            } else {
                navigationController?.pushViewController(webVc, animated: true)
            }
        }
    }
}


class HomeVideoControllerCell:UICollectionViewCell {

    var model:ResModel? {

        didSet {

            name.text = model?.name
            let url = URL(string: model?.snapshot ?? "")
            imgV.sd_setImage(with: url, placeholderImage: UIImage(named: "default"))
            favNoLab.text = (model?.favorite ?? NSNumber(value: 0)).stringValue + "人收藏"
            isLineLab.text = model?.status == "0" ? "离线":"在线"
            
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        debugPrint("HomeVideoControllerCell")
    }
    
    @IBOutlet weak var imgV: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var favNoLab: UILabel!
    @IBOutlet weak var isLineLab: UILabel!
    
}
