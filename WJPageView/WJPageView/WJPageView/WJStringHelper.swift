//
//  WJStringHelper.swift
//  WJPageView
//
//  Created by 陈威杰 on 2018/8/30.
//  Copyright © 2018年 W.J Chen. All rights reserved.
//

import UIKit
import Foundation

extension String {

    
    /// 获取文字尺寸
    func getSize(_ size: CGSize, font: UIFont) -> CGSize {
        return (self as NSString).boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: 0), options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font : font], context: nil).size
    }
    
    
}

