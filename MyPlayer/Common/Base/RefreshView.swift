//
//  GTBaseRefreshView1.swift
//  GoldTreasure
//
//  Created by ZZN on 2017/7/5.
//  Copyright © 2017年 zhaofanjinrong.com. All rights reserved.
//

import UIKit
import MJRefresh

class RefreshView: NSObject {
    
    
//    private
//    var imagesArr = [UIImage]()
    
    // 刷新头
    internal func header(closure:@escaping (()->Void)) ->MJRefreshHeader {
        
        //        let header = MJRefreshGifHeader.init { //[weak self] in
        //
        //            closure()
        //        }
        
        let header = MJRefreshNormalHeader.init {
            
            closure()
        }
        //
        //        header.setImages(imagesArr, forState: MJRefreshState.Idle)
        //        header.setImages(imagesArr, forState: MJRefreshState.Pulling)
        //        header.automaticallyChangeAlpha = true
        header?.lastUpdatedTimeLabel.isHidden = true
        header?.isAutomaticallyChangeAlpha = true
        //        header.stateLabel.hidden = true
        
        return header!
        
    }
    
    // 刷新尾部
    internal func footer(closure:@escaping (()->Void)) ->MJRefreshBackStateFooter {
        
        
        let footer = MJRefreshBackNormalFooter.init(refreshingBlock: { //[weak self] in
            
            closure()
        })
        
        footer?.isAutomaticallyChangeAlpha = true
        return footer!
    }
    
    // 结束刷新
    public func endRefresh(tableview:UITableView) {
        
        tableview.mj_header.endRefreshing()
        tableview.mj_footer.endRefreshing()
    }
    
    //入口
    class var manger:RefreshView {
        struct Staics {
            static let instance = RefreshView()
        }
        return Staics.instance
    }
    
    private override init() {
        super.init()
        
    }
}

