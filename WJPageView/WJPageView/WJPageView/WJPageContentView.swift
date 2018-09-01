//
//  WJPageContentView.swift
//  WJPageView
//
//  Created by 陈威杰 on 2018/9/1.
//  Copyright © 2018年 W.J Chen. All rights reserved.
//

import UIKit


@objc public protocol WJPageContentViewDelegate: NSObjectProtocol {
    /// 滚动到下一页的索引
    @objc optional func pageContentView(_ pageContentView: WJPageContentView, sourceIndex: Int, targetIndex: Int)
    /// 滚动过程中的起始索引、目标索引和拖拽进度
    @objc optional func pageContentView(_ pageContentView: WJPageContentView, sourceIndex: Int, targetIndex: Int, progress: CGFloat)
}


open class WJPageContentView: UIView {
    
    public weak var delegate: WJPageContentViewDelegate?
    
    private var parentContainer: UIViewController = UIViewController()
    private var childContainers: [UIViewController] = [UIViewController]()
    private lazy var scrollView: UIScrollView = setupScrollView()
    private var config: WJPageViewConfig
    private var startOffsetX: CGFloat = 0
    /// 点击标题忽略禁止分页滚动进度代理方法
    private var isIgnoreDelegate: Bool = false

    init(frame: CGRect, config: WJPageViewConfig, parentContainer: UIViewController, childContainers: [UIViewController]) {
        self.parentContainer = parentContainer
        self.childContainers = childContainers
        self.config = config
        super.init(frame: frame)
        createUI()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


// MARK: - 设置UI
extension WJPageContentView {
    
    private func createUI() {
        backgroundColor = .white
        addSubview(scrollView)
        // 添加父子控制器
        _ = childContainers.map { self.parentContainer.addChildViewController($0) }
        
        // 将子控制器的view添加到scrollView
        if config.isLazyController { addChildViewToScrollViewUseLazy() }
  
    }
    
    private func addChildViewToScrollViewUseLazy() {
        
        let currentVC = childContainers[config.defaultIndex]
        
        if currentVC.isViewLoaded { return }
    
    
        scrollView.addSubview(currentVC.view)
        
        setNeedsLayout()
        layoutIfNeeded()
        
    }
    
    private func setupScrollView() -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isPagingEnabled = true
        scrollView.backgroundColor = .clear
        scrollView.delegate = self
        return scrollView
    }

}


// MARK: - UIScrollViewDelegate
extension WJPageContentView: UIScrollViewDelegate {
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        startOffsetX = scrollView.contentOffset.x
        isIgnoreDelegate = false
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if isIgnoreDelegate {
            return
        }
        
        var progress: CGFloat = 0
        var targetIndex = 0
        var sourceIndex = 0
        
        progress = scrollView.contentOffset.x.truncatingRemainder(dividingBy: scrollView.bounds.width) / scrollView.bounds.width
        if progress == 0 { return }
        
        let index = Int(scrollView.contentOffset.x / scrollView.bounds.width)
        
        if scrollView.contentOffset.x > startOffsetX { // 左滑
            sourceIndex = index
            targetIndex = index + 1
            if targetIndex > childContainers.count - 1 {
                return
            }
        } else {   // 右滑
            sourceIndex = index + 1
            targetIndex = index
            progress = 1 - progress
            if targetIndex < 0 {
                return
            }
        }
        
        if progress >= 0.99 {
            progress = 1
        }
        
        delegate?.pageContentView?(self, sourceIndex: sourceIndex, targetIndex: targetIndex, progress: progress)
//        print("起始索引 \(sourceIndex), 目标索引 \(targetIndex), 进度 \(progress)")
        
    }
    
    /**
     *  在 scrollView 滚动动画结束时，就会调用该方法
     *  前提：认为拖拽 scrollView 产生的滚动动画
     */
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {

        let currentPageIndex = Int(round(scrollView.contentOffset.x / scrollView.frame.size.width))
        let sourceIndex = config.defaultIndex
        config.defaultIndex = currentPageIndex
        delegate?.pageContentView?(self, sourceIndex: sourceIndex, targetIndex: currentPageIndex)
        
        if config.isLazyController {
            addChildViewToScrollViewUseLazy()
        }
    }
    /**
     *  在 scrollView 滚动动画结束时，就会调用该方法
     *  前提：使用 setContentOffset:animated: 或者 scrollRectVisible:animated: 方法让 scrollView 产生滚动动画
     */
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        
   
        // 获取当前页面的 索引（第几个页面）
        let currentPageIndex = Int(round(scrollView.contentOffset.x / scrollView.frame.size.width))
        let sourceIndex = config.defaultIndex
        config.defaultIndex = currentPageIndex
        delegate?.pageContentView?(self, sourceIndex: sourceIndex, targetIndex: currentPageIndex)
        
        if config.isLazyController {
            addChildViewToScrollViewUseLazy()
        }
    }
    
    
    private func dealWithScrollViewDidEndScroll(_ scrollView: UIScrollView) {
    
    }
    
    
}


// MARK: - WJPageTitleBarViewDelegate
extension WJPageContentView: WJPageTitleBarViewDelegate {
    public func titleBarView(_ titleBarView: WJPageTitleBarView, _ currentIndex: Int) {
        
        isIgnoreDelegate = true
        
        if currentIndex > childContainers.count - 1 { return }
        
        // 滚动到指定的view
        var offset = scrollView.contentOffset;
        offset.x = CGFloat(currentIndex) * scrollView.frame.size.width;
        scrollView.setContentOffset(offset, animated: true)
    }
}




// MARK: - 布局UI
extension WJPageContentView {
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        layoutScrollView()
    }
    
    private func layoutScrollView() {
        scrollView.frame = bounds
        scrollView.contentSize = CGSize(width: CGFloat(childContainers.count) * scrollView.frame.size.width, height: 0)
        
        
        // 布局当前控制器的 View 到对应的位置
        let currentVC = childContainers[config.defaultIndex]
        currentVC.view.backgroundColor = .white
        currentVC.view.frame.origin.x = CGFloat(config.defaultIndex) * scrollView.frame.size.width
        currentVC.view.frame.origin.y = scrollView.frame.origin.y
        currentVC.view.frame.size.width = scrollView.frame.size.width
        currentVC.view.frame.size.height = scrollView.frame.size.height
    }
    
    
}
