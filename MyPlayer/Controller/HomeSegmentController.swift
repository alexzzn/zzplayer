//
//  HomeSegmentViewController.swift
//  MyPlayer
//
//  Created by ZZN on 2017/10/19.
//  Copyright © 2017年 ZZN. All rights reserved.
//

import UIKit

class HomeSegmentController: UIViewController {

    @IBOutlet weak var segment: UISegmentedControl!
    var contentView: UIScrollView!

    override func viewDidLoad() {
        super.viewDidLoad()

        initView()
        initHandle()
    }


    // 视图初始化
    func initView() {

        automaticallyAdjustsScrollViewInsets = false

        contentView = UIScrollView(frame:CGRect.init(x: 0, y: 64, width: screenW, height: screenH - 64 - 49))
        contentView.isPagingEnabled = true
        contentView.contentSize = CGSize(width: screenW*2, height: contentView.mj_h)
        contentView.isScrollEnabled = true

        let listV = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomeVideoCollection")
        let collectionV = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "collectionv") as! HomeVideoController


        addChildViewController(listV)
        addChildViewController(collectionV)



//        listV.view.backgroundColor = UIColor.brown


        listV.view.frame = CGRect(x: 0, y: 0, width: screenW, height: contentView.mj_h)
        collectionV.view.frame = CGRect(x: screenW, y: 0, width: screenW, height: contentView.mj_h)
        collectionV.collectionView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)


//        collectionV.view.backgroundColor = UIColor.brown
        contentView.addSubview(listV.view)
        contentView.addSubview(collectionV.view)
        
        
        contentView.delegate = self
        view.addSubview(contentView)

    }

    // 事务处理
    func initHandle() {

        // 分段
        segment.bk_addEventHandler({ [weak self] (event) in

            
            self?.tapScroll(tag: self?.segment.selectedSegmentIndex ?? 0)

        }, for: UIControlEvents.valueChanged)

    }
    
    //
    
}

extension HomeSegmentController:UIScrollViewDelegate {
    
    
    // scroll
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        
        let x = scrollView.mj_offsetX / screenW
        
        if x > 0.5 {
            segment.selectedSegmentIndex = 1
        } else {
            segment.selectedSegmentIndex = 0
        }
    }
    // tap scroll
    
    func tapScroll(tag:Int) {
        
        
        UIView.animate(withDuration: 0.5) {
            
            
            self.contentView.contentOffset.x = screenW * CGFloat(tag)
        }
    }
    
    
    
    
    
    
    
    
}

