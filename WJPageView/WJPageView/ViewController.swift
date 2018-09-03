//
//  ViewController.swift
//  WJPageView
//
//  Created by 陈威杰 on 2018/8/30.
//  Copyright © 2018年 W.J Chen. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var titleBar: WJPageTitleBarView?
    var pageContent: WJPageContainerView?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let size = UIScreen.main.bounds.size
        
        let config = WJPageViewConfig()
        config.fixedTitleMargin = 25
        config.titleEdgeMargin = 20
        config.indicatorWidth = 30
//        config.indicatorLineHeight = 6
//        config.indecatorBottomOffset = 8
        config.contentAlignment = .right
//        config.isShowIndicator =
//        config.isShowIndicator = false
//        config.indicatorLineHeight = 8
//        config.isShowOvalView = true
//        config.ovalViewHeight = 30
//        config.ovalViewBgColor = .red
//        config.ovalViewCornerRadius = 8
//        config.ovalViewBorderWidth = 2.0
//        config.ovalViewBorderColor = .red
//        config.defaultIndex = 2
//        config.isScaleTransformEnable = true
//        config.isTitleColorAnimateEnable = true
//        config.maximumScaleTransformFactor = 1.4
//        config.isPageContainerScorllSupport = false
        let titles = ["音乐", "科技杂志"]
        let titleBar = WJPageTitleBarView(frame: CGRect(x: 0, y: 20, width: size.width, height: 44), config: config, titles: titles)
        
        
//        let childVCs: [UIViewController] = titles.map { _ in
//            let controller = UIViewController()
//            controller.view.backgroundColor = UIColor.randomColor
//            return controller
//        }
        
        let childVCs: [UIViewController] = [
            WJTitleExampleController(),
            WJDemoViewController()
        ]
        
        let contentView = WJPageContainerView(frame: CGRect(x: 0, y: 64, width: size.width, height: size.height - 64), config: config, childViewControllers: childVCs)
  
        self.view.addSubview(contentView)
        self.view.addSubview(titleBar)
        
        titleBar.delegate = contentView
        contentView.delegate = titleBar
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
//
//extension ViewController: WJPageTitleBarViewDelegate, WJPageContainerViewDelegate {
//    func titleBarView(_ titleBarView: WJPageTitleBarView, _ selectedIndex: Int) {
//        pageContent?.scrollToPage(pageIndex: selectedIndex)
//    }
//}


