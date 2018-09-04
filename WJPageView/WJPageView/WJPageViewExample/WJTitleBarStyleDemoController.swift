//
//  WJTitleBarStyleDemoController.swift
//  WJPageView
//
//  Created by 陈威杰 on 2018/9/4.
//  Copyright © 2018年 W.J Chen. All rights reserved.
//

import UIKit

class WJTitleBarStyleDemoController: UIViewController {

    private let size = UIScreen.main.bounds
    
    private let grayColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1.0)
    private lazy var shortTitles: [String] = ["音乐", "视频", "推荐"]
    private lazy var longTitles: [String] = ["音乐", "视频", "推荐", "智能家居", "军事", "社会", "人气段子", "手机", "互联网", "历史"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "标题栏样式"
        view.backgroundColor = .white
        
        setup()
    }

    private func setup() {
        
        addDefaultStyle()
        addAlignmentStyle01()
        addAlignmentStyle02()
        addOvalViewStyle()
        addIndicatorStyle()
        // ...
    }


}


extension WJTitleBarStyleDemoController {
    private func addDefaultStyle() {
        let frame = CGRect(x: 0, y: 64, width: size.width, height: 44)
        let config = WJPageViewConfig()
        config.titleBarBgColor = grayColor
        let titleBarView = WJPageTitleBarView(frame: frame, config: config, titles: shortTitles)
        view.addSubview(titleBarView)
    }
    
    private func addAlignmentStyle01() {
        let frame = CGRect(x: 0, y: 114, width: size.width, height: 44)
        let config = WJPageViewConfig()
        config.titleBarBgColor = grayColor
        config.contentAlignment = .right
        config.isShowIndicator = false
        config.titleEdgeMargin = 15.0
        let titleBarView = WJPageTitleBarView(frame: frame, config: config, titles: shortTitles)
        view.addSubview(titleBarView)

    }
    
    private func addAlignmentStyle02() {
        let frame = CGRect(x: 0, y: 164, width: size.width, height: 44)
        let config = WJPageViewConfig()
        config.titleBarBgColor = grayColor
        config.contentAlignment = .right
        config.isShowIndicator = false
        config.titleEdgeMargin = 15.0
        config.defaultIndex = longTitles.count - 1
        let titleBarView = WJPageTitleBarView(frame: frame, config: config, titles: longTitles)
        view.addSubview(titleBarView)
        
    }
    
    private func addOvalViewStyle() {
        let frame = CGRect(x: 0, y: 213, width: size.width, height: 44)
        let config = WJPageViewConfig()
        config.titleBarBgColor = grayColor
        config.contentAlignment = .left
        config.titleEdgeMargin = 15.0
        config.fixedTitleMargin = 30
        config.isShowIndicator = false
        config.isShowOvalView = true
        config.ovalViewBgColor = .red
        config.ovalViewHeight = 30
        config.titleNormalColor = .black
        config.titleSelectedColor = .white
        let titleBarView = WJPageTitleBarView(frame: frame, config: config, titles: longTitles)
        view.addSubview(titleBarView)
        
    }
    
    private func addIndicatorStyle() {
        let frame = CGRect(x: 0, y: 262, width: size.width, height: 44)
        let config = WJPageViewConfig()
        config.titleBarBgColor = grayColor
        config.fixedTitleMargin = 40
        config.indicatorWidth = 6
        config.indicatorLineHeight = 6
        config.indecatorBottomOffset = 4  // 设置指示器距离 titleBarView 底部往上偏移量
        config.indicatorColor = .red
        let titleBarView = WJPageTitleBarView(frame: frame, config: config, titles: shortTitles)
        view.addSubview(titleBarView)
    }
    
    
    
}
