//
//  WJXibUseDemoViewController.swift
//  WJPageView
//
//  Created by 陈威杰 on 2018/9/4.
//  Copyright © 2018年 W.J Chen. All rights reserved.
//

import UIKit

class WJXibUseDemoViewController: UIViewController {
    
    
    @IBOutlet weak var titleBarView: WJPageTitleBarView!
    
    @IBOutlet weak var pageContentView: WJPageContainerView!
    
    @IBOutlet weak var topEdgeContraint: NSLayoutConstraint!
    
    private lazy var config: WJPageViewConfig = {
        let config = WJPageViewConfig()
        config.titleBarBgColor = .white
        config.indecatorBottomOffset = 2
        config.titleEdgeMargin = 15
        config.indicatorWidth = 20
        config.indicatorLineHeight = 4
        config.isScaleTransformEnable = true
        return config
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 禁止自动调整内边距
        automaticallyAdjustsScrollViewInsets = false
        
        topEdgeContraint.constant = kNavigationBarHeight
        
        let titles = ["音乐", "视频", "推荐", "智能家居", "军事", "社会", "人气段子", "手机"]
        titleBarView.titles = titles
        titleBarView.config = config
        titleBarView.titleBarSetup()   // 调用该方法完成设置
        
        let childVCs: [UIViewController] = titles.map { _ in
            let vc = UIViewController()
            vc.view.backgroundColor = UIColor.randomColor
            return vc
        }
        pageContentView.config = config
        pageContentView.childViewControllers = childVCs
        pageContentView.pageSetup()   // 调用该方法完成设置
        
        // 相互设置代理为对方即可完成其两者的逻辑交互
        titleBarView.delegate = pageContentView
        pageContentView.delegate = titleBarView
        

    }

    

}
