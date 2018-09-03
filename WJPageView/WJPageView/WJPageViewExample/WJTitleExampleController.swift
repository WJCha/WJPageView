//
//  WJTitleExampleController.swift
//  WJPageView
//
//  Created by 陈威杰 on 2018/9/3.
//  Copyright © 2018年 W.J Chen. All rights reserved.
//

import UIKit

class WJTitleExampleController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "标题栏案例"
        view.backgroundColor = .blue
        
        
    }
}

extension WJTitleExampleController: WJPageReloadable {
    
    func titleBarViewTitleDidRepeatClicked() {
        print("WJTitleExampleController")
    }
    
    func pageContaionerViewWillBeginScroll() {
        print("WJTitleExampleController 即将开始滚动")
    }
    
    func pageContaionerViewDidEndScroll() {
        print("WJTitleExampleController 停止滚动")
    }
    
}

