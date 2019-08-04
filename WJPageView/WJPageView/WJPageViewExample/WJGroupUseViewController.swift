//
//  WJGroupUseViewController.swift
//  WJPageView
//
//  Created by 陈威杰 on 2018/9/4.
//  Copyright © 2018年 W.J Chen. All rights reserved.
//

import UIKit
import SnapKit

class WJGroupUseViewController: UIViewController {

    private lazy var titles: [String] = ["音乐", "视频", "推荐"]
    let childVCs: [UIViewController] = [
        WJMusicViewController(),
        WJVideoViewController(),
        WJRecommendViewController()
    ]
    private lazy var config: WJPageViewConfig = {
        let config = WJPageViewConfig()
        config.titleBarBgColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1.0)
        config.titleSelectedColor = UIColor.white
        config.indecatorBottomOffset = 2
        config.isShowIndicator = false
        config.isShowAllOvalView = true
        config.isTitleColorAnimationEnable = false
        config.fixedTitleMargin = 40
        config.allOvalViewNormalColor = UIColor.white
        config.allOvalViewSelectColor = .blue
//        config.allOvalViewCornerRadius = 10
        config.allOvalViewHeight = 30
//        config.isShowBorderUnSelect = true
        return config
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
            view.backgroundColor = .white
            navigationItem.title = "组合使用"

            let pageView = WJPageView(config: config, titles: titles, childViewControllers: childVCs)
            // 注意 pageContainerView 和 titleBarView 的添加顺序,确保布局时 titleBarView 不会被 pageContainerView 遮盖
            view.addSubview(pageView.pageContainerView)
            view.addSubview(pageView.titleBarView)
        

            // 可以使用Autolayout或者frame布局
            pageView.titleBarView.snp.makeConstraints { (make) in
                make.left.right.equalToSuperview()
                make.top.equalTo(kNavigationBarHeight)
                make.height.equalTo(44)
            }
            pageView.pageContainerView.snp.makeConstraints { (make) in
                make.top.equalTo(pageView.titleBarView.snp.bottom)
                make.left.right.bottom.equalToSuperview()
            }
    }



}
