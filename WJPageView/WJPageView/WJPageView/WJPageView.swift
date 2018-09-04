//
//  WJPageView.swift
//  WJPageView
//
//  Created by 陈威杰 on 2018/8/31.
//  Copyright © 2018年 W.J Chen. All rights reserved.
//

import UIKit


/**
 # 通过初始化该类，分别获取 titleBarView 和 pageContainerView 添加到对应的地方并布局
 其对应属性：
 1. titleBarView
 2. pageContainerView
 ---
 */
open class WJPageView: NSObject {
    

    
    public private(set) lazy var titleBarView: WJPageTitleBarView = WJPageTitleBarView(frame: .zero, config: config, titles: titles)
    public private(set) lazy var pageContainerView = WJPageContainerView(frame: .zero, config: config, childViewControllers: childViewControllers)
    
    private let config: WJPageViewConfig
    private let titles: [String]
    private let childViewControllers: [UIViewController]
    
    public init(config: WJPageViewConfig, titles: [String], childViewControllers: [UIViewController]) {
        self.config = config
        self.titles = titles
        self.childViewControllers = childViewControllers
        super.init()
        pageViewSetup()
    }
    
    
}


extension WJPageView {
    
    private func pageViewSetup() {
        titleBarView.delegate = pageContainerView
        pageContainerView.delegate = titleBarView
    }
}
