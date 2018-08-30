//
//  HomeListController.swift
//  MyPlayer
//
//  Created by ZZN on 2017/10/19.
//  Copyright © 2017年 ZZN. All rights reserved.
//

import UIKit
import RxSwift
import MJRefresh

class HomeListController: UITableViewController {

    var dispose = DisposeBag()
    var titleArr = [String]() {
        
        didSet {
            
            OperationQueue.main.addOperation { [weak self] in
                self?.tableView.reloadData()
            }
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        tableView.mj_header = RefreshView.manger.header(closure: { [weak self] in
            
            self?.initNet()
        })
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
     
        super.viewWillAppear(animated)
        initNet()
    }

    
    func initNet() {
        
        
        let dict = [String:String]()
        
        GTApi<ResModel>.menu.post(params: dict).subscribe(onNext: { [weak self] (res) in
            
            
            self?.tableView.mj_header.endRefreshing()
            
            guard let dictList = res.menu as? Array<Dictionary<String,String>> else { return }
            
            let titleList = dictList.map({ (dict) -> String in
                
                return dict["name"] ?? ""
            })
            
            
            self?.titleArr = titleList
            
        }, onError: { [weak self] (err) in
            
            let error = err as? GTNetError
            self?.tableView.mj_header.endRefreshing()
            
            HUD.showError(title: error?.msg ?? "未知错误")
            
        }).addDisposableTo(dispose)

    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "collectionv") as? HomeVideoController else { return }
        vc.hidesBottomBarWhenPushed = true
        
        vc.sites = titleArr[indexPath.row]
        vc.videoType = 0
        vc.title = titleArr[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "rowcell", for: indexPath)
        cell.textLabel?.text = titleArr[indexPath.row]
        return cell
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return titleArr.count
    }
}
