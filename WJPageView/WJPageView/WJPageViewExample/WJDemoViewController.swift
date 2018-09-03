//
//  WJDemoViewController.swift
//  WJPageView
//
//  Created by 陈威杰 on 2018/9/3.
//  Copyright © 2018年 W.J Chen. All rights reserved.
//

import UIKit

class WJDemoViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
        // Do any additional setup after loading the view.
    }

}

extension WJDemoViewController: WJPageReloadable {
    
    func titleBarViewTitleDidRepeatClicked() {
        print("WJDemoViewController")
    }
    
    func pageContaionerViewWillBeginScroll() {
        print("WJDemoViewController 即将开始滚动")
    }
    
    func pageContaionerViewDidEndScroll() {
        print("WJDemoViewController 停止滚动")
    }
    
}
