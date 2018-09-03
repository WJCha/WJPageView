//
//  WJPageTitleBarView.swift
//  WJPageView
//
//  Created by 陈威杰 on 2018/8/30.
//  Copyright © 2018年 W.J Chen. All rights reserved.
//

import UIKit


@objc public protocol WJPageTitleBarViewDelegate: NSObjectProtocol {

    @objc optional func titleBarView(_ titleBarView: WJPageTitleBarView, _ selectedIndex: Int)

}

//@objc public protocol WJPageReloadable: class {
//    /// 标题重复点击
//    @objc optional func titleBarViewTitleDidRepeatSelected()
//}


open class WJPageTitleBarView: UIView {

    public var titles: [String]
    public var config: WJPageViewConfig
    public weak var delegate: WJPageTitleBarViewDelegate?
 
    
    private lazy var scrollView: UIScrollView = setupScrollView();
    private lazy var indicatorView: UIView    = setupIndicator();
    private lazy var ovalView: UIView         = setupOvalView()
    private var titleLabels: [UILabel] = [UILabel]()
    private var titleWidthArr: [CGFloat] = [CGFloat]()
    private var canScrollTitleLabelToCenter: Bool = false
    
    /// 指示器原始X值
//    private var indicatorOriginWidth: CGFloat = 0
//    private var indicatorEndX: CGFloat = 0
//    private var indicatorCenterX: CGFloat = 0

    
    init(frame: CGRect, config: WJPageViewConfig, titles: [String]) {
        self.titles = titles
        self.config = config
        super.init(frame: frame)
        titleBarSetup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        self.titles = [String]()
        self.config = WJPageViewConfig()
        fatalError("init(coder:) has not been implemented")
    }
    
}


// MARK: - 设置 UI
extension WJPageTitleBarView {

    public func titleBarSetup() {
        addSubview(scrollView)
        setupTitles()
        if config.isShowIndicator {
            scrollView.addSubview(indicatorView)
        }
        if config.isShowOvalView {
            scrollView.insertSubview(ovalView, at: 0)
        }
    }
    
    private func setupScrollView() -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.backgroundColor = config.titleBarBgColor
        scrollView.alwaysBounceHorizontal = config.titleAlwaysBounceHorizontal
        return scrollView
    }
    
    private func setupTitles() {
        
        assert(config.defaultIndex >= 0, "索引必须大于0")
        assert(config.defaultIndex > titleLabels.count - 1, "数组越界")
        
        titleLabels.removeAll()
        for(index, title) in titles.enumerated() {
            let titleLabel = UILabel()
            titleLabel.tag = index
            titleLabel.font = UIFont.systemFont(ofSize: config.titleFontSize)
            titleLabel.textAlignment = .center
            titleLabel.text = title
            titleLabel.textColor = index == config.defaultIndex ? config.titleSelectedColor : config.titleNormalColor
            scrollView.addSubview(titleLabel)
            titleLabels.append(titleLabel)
            titleLabel.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(titleLabelClicked(_:)))
            titleLabel.addGestureRecognizer(tap)
        }
    }
    
    private func setupIndicator() -> UIView {
        let indicatorView = UIView()
        indicatorView.backgroundColor = config.indicatorColor
        indicatorView.layer.cornerRadius = config.indicatorLineHeight * 0.5
        indicatorView.layer.masksToBounds = true
        indicatorView.alpha = config.indicatorAlpha
        return indicatorView
    }
    
    private func setupOvalView() -> UIView {
        let ovalView = UIView()
        ovalView.backgroundColor = config.ovalViewBgColor
        ovalView.layer.borderWidth = config.ovalViewBorderWidth
        ovalView.layer.borderColor = config.ovalViewBorderColor.cgColor
        ovalView.alpha = config.ovalViewAlpha
        ovalView.layer.masksToBounds = true
        return ovalView
    }
    
}


// MARK: - 布局 UI
extension WJPageTitleBarView {
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        scrollView.frame = bounds
        layoutTitleLabel()
        
        if config.isShowIndicator {
            layoutIndicator()
        }
        
        if config.isShowOvalView {
            layoutOvalView()
        }
        
    }
    
    private func layoutOvalView() {
        let titleLabel = titleLabels[config.defaultIndex]
        ovalView.frame.size.width = config.ovalViewExtendWidth * 2 + titleLabel.frame.size.width
        ovalView.center.x = titleLabel.center.x
        ovalView.frame.size.height = config.ovalViewHeight ?? titleLabel.frame.size.height
        ovalView.center.y = titleLabel.center.y
        ovalView.layer.cornerRadius = config.ovalViewCornerRadius ?? (config.ovalViewHeight != nil ? config.ovalViewHeight! * 0.5 : titleLabels[config.defaultIndex].frame.size.height * 0.5)
        
    }
    
    
    private func layoutIndicator() {
        
        let titleLabel = titleLabels[config.defaultIndex]
        indicatorView.frame.size.width = config.indicatorWidth ?? titleLabel.frame.size.width
        indicatorView.center.x = titleLabel.center.x
        indicatorView.frame.size.height = config.indicatorLineHeight
        indicatorView.frame.origin.y = bounds.size.height - config.indicatorLineHeight - config.indecatorBottomOffset
        
        
        
    }
    
    private func layoutTitleLabel() {
        
        titleWidthArr = titleLabels.map { $0.text!.getSize(CGSize(width: CGFloat.greatestFiniteMagnitude, height: 0), font: $0.font).width }

        // 第一个标题到最后一个标题的总宽度（包含标题间的间距）
        let totalTitleWidth = titleWidthArr.reduce(0, +) + config.fixedTitleMargin * CGFloat(titleLabels.count - 1)
        
        // 边缘距离
        var edgeMargin: CGFloat = 0
        var isDealWithAlignment = false
        if  bounds.size.width - totalTitleWidth >= 0,
            (bounds.size.width - totalTitleWidth) * 0.5 >= config.titleEdgeMargin{
            canScrollTitleLabelToCenter = false
            isDealWithAlignment = false
            edgeMargin = (bounds.size.width - totalTitleWidth) * 0.5
            if config.contentAlignment == .left { edgeMargin = config.titleEdgeMargin }
            if config.contentAlignment == .right { edgeMargin = (bounds.size.width - totalTitleWidth - config.titleEdgeMargin) }
        } else {
            canScrollTitleLabelToCenter = true
            isDealWithAlignment = true
            edgeMargin = config.titleEdgeMargin
        }

        var itemX: CGFloat = 0
        let itemY: CGFloat = 0
        var itemW: CGFloat = 0
        let itemH: CGFloat = bounds.size.height - (config.isShowIndicator ? config.indicatorLineHeight : 0)
        
        var lastX: CGFloat = edgeMargin
        for (index, titleLable) in titleLabels.enumerated() {
            itemW = titleWidthArr[index]
            itemX = lastX
            titleLable.frame = CGRect(x: itemX, y: itemY, width: itemW, height: itemH)
            lastX += itemW + config.fixedTitleMargin
        }
        
        var lastTitleLabelMaxX: CGFloat = 0
        if let titleLabel = titleLabels.last {
            lastTitleLabelMaxX = titleLabel.frame.maxX
        }
        scrollView.contentSize = CGSize(width: lastTitleLabelMaxX + config.titleEdgeMargin, height: 0)
        
        if isDealWithAlignment {
            if config.contentAlignment == .centerToRight || config.contentAlignment == .right { scrollTargetTitleLabelToCenter(titleLabels.last, animated: false) }
            if config.contentAlignment == .center { scrollTargetTitleLabelToCenter(titleLabels[Int(floorf(Float(titleLabels.count/2)))], animated: false) }
        }
        
        
        
        
      
        
    }
}


// MARK: - 标题按钮点击事件
extension WJPageTitleBarView {
    
    @objc private func titleLabelClicked(_ tapGes: UITapGestureRecognizer) {
        
        guard let targetTitleLabel = tapGes.view as? UILabel else { return }
        
        // repeat click
        if targetTitleLabel.tag == config.defaultIndex {
            print("重复点击")
            return
        }
        
        
        delegate?.titleBarView?(self, targetTitleLabel.tag)
        
        animateFromTitleLabel(titleLabels[config.defaultIndex], to: targetTitleLabel)
        
        scrollTargetTitleLabelToCenter(targetTitleLabel)

    }
    
    private func animateFromTitleLabel(_ sourceLabel: UILabel, to targetLabel: UILabel) {
        

        // 标题动画
        changeTitleSelectedState(sourceLabel, targetLabel)
        
        self.config.defaultIndex = targetLabel.tag
        
        // 线条指示器动画
        if config.isShowIndicator {
            startIndicatorAnimate(sourceLabel, targetLabel)
        }
        
        // 椭圆背景指示器动画
        if config.isShowOvalView {
            startOvalViewAnimate(sourceLabel, targetLabel)
        }
        
    }
    
    private func changeTitleSelectedState(_ sourceLabel: UILabel, _ targetLabel: UILabel) {
        sourceLabel.textColor = self.config.titleNormalColor
        targetLabel.textColor = self.config.titleSelectedColor
    }
    
    private func startOvalViewAnimate(_ sourceLabel: UILabel, _ targetLabel: UILabel) {
        UIView.animate(withDuration: 0.25) {
            self.ovalView.frame.size.width = targetLabel.frame.size.width + self.config.ovalViewExtendWidth * 2
            self.ovalView.center.x = targetLabel.center.x
        }
    }
    
    private func startIndicatorAnimate(_ sourceLabel: UILabel, _ targetLabel: UILabel) {
        // 计算出需要滚动的距离
        let scrollDistance = targetLabel.center.x - sourceLabel.center.x
        UIView.animateKeyframes(withDuration: 0.6, delay: 0, options: .calculationModeLinear, animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.3, animations: {
                var frame = self.indicatorView.frame
                frame.origin.x += frame.size.width * 0.5
                frame.size.width = scrollDistance
                self.indicatorView.frame = frame
            })
            
            UIView.addKeyframe(withRelativeStartTime: 0.2, relativeDuration: 0.3, animations: {
                var frame = self.indicatorView.frame
                frame.size.width = self.config.indicatorWidth ?? targetLabel.frame.size.width
                self.indicatorView.frame = frame
                self.indicatorView.center.x = targetLabel.center.x
            })
        }, completion: nil)
    }
    
    
    private func scrollTargetTitleLabelToCenter(_ targetLabel: UILabel?, animated: Bool = true) {
        
        guard let targetLabel = targetLabel else {
            return
        }
        
        if !canScrollTitleLabelToCenter { return }
        
        let centerX = targetLabel.center.x
        var offset = scrollView.contentOffset

        offset.x = centerX - scrollView.frame.size.width * 0.5

        // 左边超出处理
        if offset.x < 0 { offset.x = 0 }
        // 右边超出处理
        let maxTitleOffsetX = scrollView.contentSize.width - scrollView.bounds.width
        if offset.x > maxTitleOffsetX { offset.x = maxTitleOffsetX }
        scrollView.setContentOffset(offset, animated: animated)
        
    }
    
}


extension WJPageTitleBarView: WJPageContainerViewDelegate {
    
    
    /// 滚动完成
    public func pageContainerView(_ pageContainerView: WJPageContainerView, sourceIndex: Int, targetIndex: Int) {
        
        changeTitleSelectedState(titleLabels[sourceIndex], titleLabels[targetIndex])
    }
    
    /// 滚动进度相关信息
    public func pageContainerView(_ pageContainerView: WJPageContainerView, sourceIndex: Int, targetIndex: Int, progress: CGFloat) {
        
        
        //print("起始索引 \(sourceIndex), 目标索引 \(targetIndex), 进度 \(progress)")
        if sourceIndex > titleLabels.count - 1 || sourceIndex < 0 { return }
        if targetIndex > titleLabels.count - 1 || targetIndex < 0 { return }
        let sourceLabel = titleLabels[sourceIndex]
        let targetLabel = titleLabels[targetIndex]


        let distance = targetLabel.center.x - sourceLabel.center.x
        let changeWidth = targetLabel.frame.size.width - sourceLabel.frame.size.width

        if config.isShowOvalView {
            ovalView.frame.size.width = sourceLabel.frame.width + changeWidth * progress + config.ovalViewExtendWidth * 2
            ovalView.center.x = sourceLabel.center.x + distance * progress
        }


        if config.isShowIndicator {
            indicatorView.frame.size.width = config.indicatorWidth ?? (sourceLabel.frame.width + changeWidth * progress)
            indicatorView.center.x = sourceLabel.center.x + distance * progress
        }
        
    }
    
    
}

