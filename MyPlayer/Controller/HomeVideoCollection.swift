//
//  HomeVideoListCollectionController.swift
//
//
//  Created by ZZN on 2017/11/5.
//

import UIKit
import MJRefresh
import RxSwift

class HomeVideoCollection: BaseViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var dispose = DisposeBag()
    
    
    var infoArr = [[String:String]]() {
        
        didSet {
            
            OperationQueue.main.addOperation { [weak self] in
                self?.collectionView.reloadData()
            }
            
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
    
    }
    
    func initUI() {
        
        
        collectionView.frame = view.frame
        let layout = UICollectionViewFlowLayout.init()
        
        
        layout.sectionInset = UIEdgeInsetsMake(15, 15, 15, 15)
        layout.itemSize = CGSize(width:(view.mj_w-45)/2, height: 180)
        layout.minimumLineSpacing = 15
        layout.minimumInteritemSpacing = 15
        
        collectionView.collectionViewLayout = layout
        collectionView.delegate = self
        collectionView.dataSource = self
        
        
        if #available(iOS 11.0, *) {
            self.collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentBehavior.never;
        }else {
            self.automaticallyAdjustsScrollViewInsets = false;
        }
    }
    
    
    func initHandle() {
        
        
        collectionView.mj_header = RefreshView.manger.header(closure: { [weak self] in
            
            self?.reqNewData()
        })
        
        GTUser.manger.listenUserInfoChanged { [weak self]  (model) in
            self?.reqNewData()
        }
    
    }
    
    // 请求新数据
    func reqNewData() {
        
        
        let dict = [String:String]()
        
        GTApi<ResModel>.menu.post(params: dict).subscribe(onNext: { [weak self] (res) in
            
            
            self?.collectionView.mj_header.endRefreshing()

            guard let dictList = res.menu as? Array<Dictionary<String,String>> else { return }
            self?.infoArr = dictList
            
            }, onError: { [weak self] (err) in
                
                let error = err as? GTNetError
                self?.collectionView.mj_header.endRefreshing()

                HUD.showError(title: error?.msg ?? "未知错误")
                
        }).addDisposableTo(dispose)
        
    }
    
}

extension HomeVideoCollection:UICollectionViewDataSource, UICollectionViewDelegate {
    
    
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
        return infoArr.count
    }
    //cellForItemAt indexPath
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! HomeVideoCollectionCell
        
        if let url = infoArr[indexPath.row]["logo"] {
            cell.imgV.sd_setImage(with: URL.init(string: url), completed: nil)
        }
        cell.nameLab.text = infoArr[indexPath.row]["name"]
    
        return cell
    }
    //
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        
        
        guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "collectionv") as? HomeVideoController else { return }
        vc.hidesBottomBarWhenPushed = true
        
        vc.sites = infoArr[indexPath.row]["name"]
        vc.videoType = 0
        vc.title = infoArr[indexPath.row]["name"]
        navigationController?.pushViewController(vc, animated: true)
        
    }
}

// collection
class HomeVideoCollectionCell:UICollectionViewCell {
    
    @IBOutlet weak var imgV: UIImageView!
    @IBOutlet weak var nameLab: UILabel!
    
}


