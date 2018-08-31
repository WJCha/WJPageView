//
//  WJPageTitleBarView.swift
//  WJPageView
//
//  Created by 陈威杰 on 2018/8/30.
//  Copyright © 2018年 W.J Chen. All rights reserved.
//

import UIKit


@objc public protocol WJPageTitleBarViewDelegate: class {

    @objc optional func titleBarView(_ titleBarView: WJPageTitleBarView, _ currentIndex: Int)
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
    private var titleLables: [UILabel] = [UILabel]()
    private var titleWidthArr: [CGFloat] = [CGFloat]()
    private var canScrollTitleLabelToCenter: Bool = false

    
    init(frame: CGRect, config: WJPageViewConfig, titles: [String]) {
        self.titles = titles
        self.config = config
        super.init(frame: frame)
        createUI()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        self.titles = [String]()
        self.config = WJPageViewConfig()
        fatalError("init(coder:) has not been implemented")
    }

    
    deinit {
        print("对象释放了")
    }

}


// MARK: - 设置 UI
extension WJPageTitleBarView {

    private func createUI() {
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
        assert(config.defaultIndex > titleLables.count - 1, "数组越界")
        
        titleLables.removeAll()
        for(index, title) in titles.enumerated() {
            let titleLabel = UILabel()
            titleLabel.tag = index
            titleLabel.font = UIFont.systemFont(ofSize: config.titleFontSize)
            titleLabel.textAlignment = .center
            titleLabel.text = title
            titleLabel.textColor = index == config.defaultIndex ? config.titleSelectedColor : config.titleNormalColor
            scrollView.addSubview(titleLabel)
            titleLables.append(titleLabel)
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
        ovalView.layer.cornerRadius = config.ovalViewCornerRadius ?? (config.ovalViewHeight != nil ? config.ovalViewHeight! * 0.5 : bounds.size.height * 0.7 * 0.5)
        ovalView.layer.masksToBounds = true
        ovalView.alpha = config.ovalViewAlpha
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
        let titleLabel = titleLables[config.defaultIndex]
        ovalView.frame.size.width = config.ovalViewExtendWidth * 2 + titleLabel.frame.size.width
        ovalView.center.x = titleLabel.center.x
        ovalView.frame.size.height = config.ovalViewHeight ?? bounds.size.height * 0.7
        ovalView.center.y = titleLabel.center.y
    }
    
    
    private func layoutIndicator() {
        
        let titleLabel = titleLables[config.defaultIndex]
        indicatorView.frame.size.width = config.indicatorWidth ?? titleLabel.frame.size.width
        indicatorView.center.x = titleLabel.center.x
        indicatorView.frame.size.height = config.indicatorLineHeight
        indicatorView.frame.origin.y = bounds.size.height - config.indicatorLineHeight - config.indecatorBottomOffset
        
    }
    
    private func layoutTitleLabel() {
        
        titleWidthArr = titleLables.map { $0.text!.getSize(CGSize(width: CGFloat.greatestFiniteMagnitude, height: 0), font: $0.font).width }

        // 第一个标题到最后一个标题的总宽度（包含标题间的间距）
        let totalTitleWidth = titleWidthArr.reduce(0, +) + config.fixedTitleMargin * CGFloat(titleLables.count - 1)
        
        // 边缘距离
        var edgeMargin: CGFloat = 0
        if  bounds.size.width - totalTitleWidth > 0,
            (bounds.size.width - totalTitleWidth) * 0.5 >= config.titleEdgeMargin{
            canScrollTitleLabelToCenter = false
            edgeMargin = (bounds.size.width - totalTitleWidth) * 0.5
            if config.contentAlignment == .left { edgeMargin = config.titleEdgeMargin }
            if config.contentAlignment == .right { edgeMargin = (bounds.size.width - totalTitleWidth - config.titleEdgeMargin) }
        } else {
            canScrollTitleLabelToCenter = true
            edgeMargin = config.titleEdgeMargin
        }

        var itemX: CGFloat = 0
        let itemY: CGFloat = 0
        var itemW: CGFloat = 0
        let itemH: CGFloat = bounds.size.height - (config.isShowIndicator ? config.indicatorLineHeight : 0)
        
        var lastX: CGFloat = edgeMargin
        for (index, titleLable) in titleLables.enumerated() {
            itemW = titleWidthArr[index]
            itemX = lastX
            titleLable.frame = CGRect(x: itemX, y: itemY, width: itemW, height: itemH)
            lastX += itemW + config.fixedTitleMargin
        }
        
        var lastTitleLabelMaxX: CGFloat = 0
        if let titleLabel = titleLables.last {
            lastTitleLabelMaxX = titleLabel.frame.maxX
        }
        scrollView.contentSize = CGSize(width: lastTitleLabelMaxX + config.titleEdgeMargin, height: 0)
        
        
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
        
        animateFromTitleLabel(titleLables[config.defaultIndex], to: targetTitleLabel)
        
        scrollTargetTitleLabelToCenter(targetTitleLabel)

    }
    
    private func animateFromTitleLabel(_ sourceLabel: UILabel, to targetLabel: UILabel) {
        

        // 标题动画
        sourceLabel.textColor = self.config.titleNormalColor
        targetLabel.textColor = self.config.titleSelectedColor
        
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
    
    
    private func scrollTargetTitleLabelToCenter(_ targetLabel: UILabel?) {
        
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
        scrollView.setContentOffset(offset, animated: true)
        
    }
    
}

