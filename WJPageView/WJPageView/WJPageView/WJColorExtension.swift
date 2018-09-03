//
//  WJColorExtension.swift
//  WJPageView
//
//  Created by 陈威杰 on 2018/9/3.
//  Copyright © 2018年 W.J Chen. All rights reserved.
//

import UIKit


typealias WJColorRGB = (red: CGFloat, green: CGFloat, blue: CGFloat)

extension UIColor {
    /// 获取随机颜色
    static var randomColor: UIColor {
        return UIColor(red: CGFloat(arc4random_uniform(256))/255.0, green: CGFloat(arc4random_uniform(256))/255.0, blue: CGFloat(arc4random_uniform(256))/255.0, alpha: 1.0)
    }
}


extension UIColor {
    
    /// 获取一个颜色值对应的 R,G,B数值(0 ~ 1)
    ///
    /// - Returns: R,G,B数值元祖
    func getRGB() -> WJColorRGB {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: nil)
        return (red, green, blue)
    }
    
}
