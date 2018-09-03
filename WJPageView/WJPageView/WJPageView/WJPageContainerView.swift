//
//  WJPageContainerView.swift
//  WJPageView
//
//  Created by 陈威杰 on 2018/9/3.
//  Copyright © 2018年 W.J Chen. All rights reserved.
//

import UIKit

@objc public protocol WJPageContainerViewDelegate: NSObjectProtocol {
    /// 滚动完成
    @objc optional func pageContainerView(_ pageContainerView: WJPageContainerView, sourceIndex: Int, targetIndex: Int)
    /// 滚动过程中的起始索引、目标索引和拖拽进度
    @objc optional func pageContainerView(_ pageContainerView: WJPageContainerView, sourceIndex: Int, targetIndex: Int, progress: CGFloat)
}

private let PAGE_CELL = "PAGE_CELL"
open class WJPageContainerView: UIView {
    
    public weak var delegate: WJPageContainerViewDelegate?
    
    private let childViewControllers: [UIViewController]
    private let config: WJPageViewConfig
    private lazy var collectionView: UICollectionView = setupCollectionView()
    private var isIgnoreDelegate: Bool = false
    private var startOffsetX: CGFloat = 0

    init(frame: CGRect, config: WJPageViewConfig, childViewControllers: [UIViewController]) {
        self.childViewControllers = childViewControllers
        self.config = config
        super.init(frame: frame)
        pageSetup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        self.childViewControllers = [UIViewController]()
        self.config = WJPageViewConfig()
        fatalError("init(coder:) has not been implemented")
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

        print("起始索引 \(sourceIndex), 目标索引 \(targetIndex), 进度 \(progress)")
        
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
        
        let currentPageIndex = Int(round(scrollView.contentOffset.x / scrollView.frame.size.width))
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



