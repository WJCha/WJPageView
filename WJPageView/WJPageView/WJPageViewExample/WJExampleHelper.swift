//
//  WJExampleHelper.swift
//  WJPageView
//
//  Created by 陈威杰 on 2018/9/4.
//  Copyright © 2018年 W.J Chen. All rights reserved.
//

import UIKit

// 屏幕宽度
let SCREEN_WIDHT = UIScreen.main.bounds.size.width
// 屏幕高度
let SCREEN_HEIGHT = UIScreen.main.bounds.size.height
// iPhone4
let isIphone4 = SCREEN_HEIGHT  < 568 ? true : false
// iPhone 5
let isIphone5 = SCREEN_HEIGHT  == 568 ? true : false
// iPhone 6
let isIphone6 = SCREEN_HEIGHT  == 667 ? true : false
// iphone 6P
let isIphone6P = SCREEN_HEIGHT == 736 ? true : false
// iphone X
let isIphoneX = SCREEN_HEIGHT == 812 ? true : false
// navigationBarHeight
let kNavigationBarHeight : CGFloat = isIphoneX ? 88 : 64
// tabBarHeight
let kTabBarHeight : CGFloat = isIphoneX ? 49 + 34 : 49


