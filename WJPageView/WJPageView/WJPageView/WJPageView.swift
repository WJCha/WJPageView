//
//  WJPageView
//
//  Created by 陈威杰 (WJCha & W.J Chen)
//  Copyright © 2018-Present W.J Chen - https://github.com/WJCha/WJPageView
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

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
