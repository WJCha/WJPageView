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
        config.fixedTitleMargin = 30
        config.titleEdgeMargin = 20
//        config.indicatorWidth = 10
//        config.indicatorLineHeight = 6
//        config.indecatorBottomOffset = 8
//        config.contentAlignment = .right
//        config.isShowIndicator = false
        config.isShowIndicator = true
//        config.isShowOvalView = false
//        config.ovalViewHeight = 26
//        config.ovalViewCornerRadius = 8
//        config.ovalViewBorderWidth = 2.0
//        config.ovalViewBorderColor = .red
        let titleBar = WJPageTitleBarView(frame: CGRect(x: 0, y: 20, width: size.width, height: 44), config: config, titles: ["音乐", "科技杂志","科技杂志","视频"])
        titleBar.delegate = self
        self.view.addSubview(titleBar)
        
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



