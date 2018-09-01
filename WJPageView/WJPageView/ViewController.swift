//
//  ViewController.swift
//  WJPageView
//
//  Created by 陈威杰 on 2018/8/30.
//  Copyright © 2018年 W.J Chen. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let size = UIScreen.main.bounds.size
        
        let config = WJPageViewConfig()
        config.fixedTitleMargin = 25
//        config.titleEdgeMargin = 10
//        config.indicatorWidth = 10
//        config.indicatorLineHeight = 6
//        config.indecatorBottomOffset = 8
        config.contentAlignment = .centerToLeft
//        config.isShowIndicator =
//        config.isShowIndicator = false
//        config.indicatorLineHeight = 8
//        config.isShowOvalView = true
//        config.ovalViewHeight = 30
//        config.ovalViewCornerRadius = 8
//        config.ovalViewBorderWidth = 2.0
//        config.ovalViewBorderColor = .red
        let titles = ["音乐", "科技杂志","科技杂志"]
        let titleBar = WJPageTitleBarView(frame: CGRect(x: 0, y: 20, width: size.width, height: 44), config: config, titles: titles)
        titleBar.delegate = self
        self.view.addSubview(titleBar)
        
        
        let childVCs: [UIViewController] = titles.map { _ in
            let controller = UIViewController()
            return controller
        }
        let contentView = WJPageContentView(frame: CGRect(x: 0, y: 64, width: size.width, height: size.height - 64), config: config, parentContainer: self, childContainers: childVCs)
        self.view.addSubview(contentView)
        
        
        titleBar.delegate = contentView
        contentView.delegate = titleBar
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}




extension ViewController: WJPageTitleBarViewDelegate {
    func titleBarView(_ titleBarView: WJPageTitleBarView, _ currentIndex: Int) {
        print("当前选中索引\(currentIndex)")
    }
}



