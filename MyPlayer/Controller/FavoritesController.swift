//
//  FavoritesController.swift
//  MyPlayer
//
//  Created by ZZN on 2017/9/17.
//  Copyright © 2017年 ZZN. All rights reserved.
//

import UIKit

class FavoritesController: BaseViewController {

    
    @IBOutlet weak var notiLab: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    var currentPage = 1
    
    
    
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
    
    
    func layoutUI() {
        
        
        if modelList.count == 0 {
            
            notiLab.isHidden = false
        } else {
            
            notiLab.isHidden = true
            collectionView.reloadData()
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
    }
    
    
    func initHandle() {
        
        collectionView.mj_header = RefreshView.manger.header(closure: { [weak self] in
            
            self?.reqNewData()
        })
        
        collectionView.mj_footer = RefreshView.manger.footer(closure: { [weak self] in
            
            self?.reqMoreData()
        })
        
        
        GTUser.manger.listenUserInfoChanged { [weak self]  (model) in
            self?.reqMoreData()
        }
        
        collectionView.mj_footer.isHidden = true
    }
    
    // 请求新数据
    func reqNewData() {
        
        let dict = ["page":"1"]
        self.currentPage = 1
    
        GTApi<ResModel>.like.post(params: dict).subscribe(onNext: {[weak self] (res) in
            
            guard let list = res.room as? [ResModel] else { return }
            self?.collectionView.mj_header.endRefreshing()
            self?.modelList = list
            self?.collectionView.mj_footer.isHidden = false
            
            }, onError: { [weak self] (error) in
                
                let err = error as? GTNetError
                self?.collectionView.mj_header.endRefreshing()
                HUD.showError(title: err?.msg ?? "未知错误")
                
        }).disposed(by: disposeBag)
        
    }
    
    // 请求更多数据
    func reqMoreData() {
        
        let newPage = currentPage + 1
        let dict = ["page":newPage.toString()]
        GTApi<ResModel>.like.post(params: dict).subscribe(onNext: {[weak self] (res) in
            
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

extension FavoritesController:UICollectionViewDataSource, UICollectionViewDelegate {
    
    
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
        
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionViewCell", for: indexPath) as! FavoritesCollectionViewCell
        cell.model = modelList[indexPath.row]
        return cell
    }
    //
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let model = modelList[indexPath.row]
        
        let vc = WKWebVC.init(urlStr: model.link ?? "")
        
        vc.videoUrl = model.link ?? ""
        vc.model = model
        navigationController?.pushViewController(vc, animated: true)
        
    }
}



class FavoritesCollectionViewCell:UICollectionViewCell {
    
    var model:ResModel? {
        
        didSet {
            
            name.text = model?.name
            let url = URL(string: model?.snapshot ?? "")
            imgV.sd_setImage(with: url, placeholderImage: UIImage(named: "default"))
            favNoLab.text = (model?.favorite ?? NSNumber(value: 0)).stringValue + "人收藏"
            isLineLab.text = model?.status == "0" ? "离线":"在线"
            
        }
    }
    
    @IBOutlet weak var imgV: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var favNoLab: UILabel!
    @IBOutlet weak var isLineLab: UILabel!
    
}

