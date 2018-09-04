//
//  WJVideoViewController.swift
//  WJPageView
//
//  Created by 陈威杰 on 2018/9/4.
//  Copyright © 2018年 W.J Chen. All rights reserved.
//

import UIKit

class WJVideoViewController: UIViewController {


    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .green
        //automaticallyAdjustsScrollViewInsets = false
        // Do any additional setup after loading the view.
    }


}

extension WJVideoViewController: WJPageReloadable {
    func titleBarViewTitleDidRepeatClicked() {
        print("视频标题重复点击")
    }
}
