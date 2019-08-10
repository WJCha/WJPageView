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

@objc public protocol WJPageContainerViewDelegate: class {
    /// 滚动完成
    @objc optional func pageContainerView(_ pageContainerView: WJPageContainerView, sourceIndex: Int, targetIndex: Int)
    /// 滚动过程中的起始索引、目标索引和拖拽进度
    @objc optional func pageContainerView(_ pageContainerView: WJPageContainerView, sourceIndex: Int, targetIndex: Int, progress: CGFloat)
}

private let PAGE_CELL = "PAGE_CELL"
open class WJPageContainerView: UIView {
    
    public var childViewControllers: [UIViewController]
    public var config: WJPageViewConfig
    
    public weak var delegate: WJPageContainerViewDelegate?
    public weak var reloader: WJPageReloadable?
    
    private lazy var collectionView: UICollectionView = setupCollectionView()
    private var isIgnoreDelegate: Bool = false
    private var startOffsetX: CGFloat = 0
    private var canCallEndScrollDelegate: Bool = false

    public init(frame: CGRect, config: WJPageViewConfig, childViewControllers: [UIViewController]) {
        self.childViewControllers = childViewControllers
        self.config = config
        super.init(frame: frame)
        pageSetup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        self.childViewControllers = [UIViewController]()
        self.config = WJPageViewConfig()
        super.init(coder: aDecoder)
    }
    
    public func scrollToPage(pageIndex: Int) {
        if pageIndex > childViewControllers.count - 1 { return }
        let indexPath = IndexPath(item: pageIndex, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .left, animated: true)
    }
    

}


// MARK: - UI设置
extension WJPageContainerView {
    public func pageSetup() {
        addSubview(collectionView)
        
    }
    
    private func setupCollectionView() -> UICollectionView {
        
        let layout = WJFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: PAGE_CELL)
        collectionView.backgroundColor = config.pageContainerViewBgColor
        collectionView.isScrollEnabled = config.isInteractiveScorllEnable
//        if #available(iOS 11.0, *) {
//            collectionView.contentInsetAdjustmentBehavior = .never
//        }
        return collectionView
    }
    
}

// MARK: - UICollectionViewDataSource
extension WJPageContainerView: UICollectionViewDataSource {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return childViewControllers.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PAGE_CELL, for: indexPath)
        _ = cell.contentView.subviews.map { $0.removeFromSuperview() }
        let childController = childViewControllers[indexPath.item]
        childController.view.frame = cell.contentView.bounds
        cell.contentView.addSubview(childController.view)
        return cell
        
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let childController = childViewControllers[indexPath.item]
        reloader = childController as? WJPageReloadable
    }
    
    
}

// MARK: - UICollectionViewDelegate
extension WJPageContainerView: UICollectionViewDelegate {
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        startOffsetX = scrollView.contentOffset.x
        isIgnoreDelegate = false
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if isIgnoreDelegate {
            return
        }
        
        if scrollView.bounds.width == 0 {
            return
        }
        
        var progress: CGFloat = 0
        var targetIndex = 0
        var sourceIndex = 0
        
        progress = scrollView.contentOffset.x.truncatingRemainder(dividingBy: scrollView.bounds.width) / scrollView.bounds.width
        if progress == 0 { return }
        
        let index = Int(scrollView.contentOffset.x / scrollView.bounds.width)
        
        // 左滑
        if scrollView.contentOffset.x > startOffsetX {
            sourceIndex = index
            targetIndex = index + 1
            if targetIndex > childViewControllers.count - 1 {
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
        
        delegate?.pageContainerView?(self, sourceIndex: sourceIndex, targetIndex: targetIndex, progress: progress)
        
    }
    
    /**
     *  在 scrollView 滚动动画结束时，就会调用该方法
     *  前提：认为拖拽 scrollView 产生的滚动动画
     */
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        dealWithScrollViewDidEndScroll(scrollView)
    }
    
    /**
     *  在 scrollView 滚动动画结束时，就会调用该方法
     *  前提：使用 setContentOffset:animated: 或者 scrollRectVisible:animated: 方法让 scrollView 产生滚动动画
     */
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        dealWithScrollViewDidEndScroll(scrollView)
    }
    
    
    private func dealWithScrollViewDidEndScroll(_ scrollView: UIScrollView) {
        
        let currentPageIndex = Int(round(collectionView.contentOffset.x / collectionView.frame.size.width))
        
        let childVC = childViewControllers[currentPageIndex]
        reloader = childVC as? WJPageReloadable
        reloader?.pageContaionerViewDidEndScroll?()
        
        
        let sourceIndex = config.defaultIndex
        config.defaultIndex = currentPageIndex
        delegate?.pageContainerView?(self, sourceIndex: sourceIndex, targetIndex: currentPageIndex)
    }
}


// MARK: - UI布局
extension WJPageContainerView {
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.frame = bounds
        let layout = collectionView.collectionViewLayout as! WJFlowLayout
        layout.itemSize = bounds.size
        collectionView.scrollToItem(at: NSIndexPath(item: config.defaultIndex, section: 0) as IndexPath, at: .left, animated: false)
        
        // 添加父子控制器
        if let controller = self.viewController() {
            for vc in self.childViewControllers {
                controller.addChildViewController(vc)
            }
        }
        
       
        
    }
    
}


extension WJPageContainerView {
    /// 获取响应事件的控制器
    private func viewController() -> UIViewController? {
        var responder = self.next
        while responder != nil {
            if ((responder as? UIViewController) != nil) {
                return (responder as! UIViewController)
            }
            responder = responder?.next ?? nil
        }
        return nil
    }
    
}


// MARK: - WJPageTitleBarViewDelegate
extension WJPageContainerView: WJPageTitleBarViewDelegate {
    
    public func titleBarView(_ titleBarView: WJPageTitleBarView, _ selectedIndex: Int) {
        isIgnoreDelegate = true
        if selectedIndex > childViewControllers.count - 1 { return }
        let indexPath = IndexPath(item: selectedIndex, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .left, animated: true)
    }
    
    
}



