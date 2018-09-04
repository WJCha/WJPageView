//
//  WJRecommendViewController.swift
//  WJPageView
//
//  Created by 陈威杰 on 2018/9/4.
//  Copyright © 2018年 W.J Chen. All rights reserved.
//

import UIKit

class WJRecommendViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .blue
        //automaticallyAdjustsScrollViewInsets = false
        // Do any additional setup after loading the view.
    }

}

extension WJRecommendViewController: WJPageReloadable {
    func titleBarViewTitleDidRepeatClicked() {
        print("推荐标题重复点击")
    }
}
