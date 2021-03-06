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


@objc public protocol WJPageTitleBarViewDelegate: class {

    /// 子控制器刷新代理
    @objc optional var reloader: WJPageReloadable? { get }
    @objc optional func titleBarView(_ titleBarView: WJPageTitleBarView, _ selectedIndex: Int)

}


/// 子控制器要监听标题重复点击以及滚动停止可以实现该协议对应方法
@objc public protocol WJPageReloadable: class {
    
    /// 监听标题重复点击事件
    @objc optional func titleBarViewTitleDidRepeatClicked()
    
    /// 监听 pageContentView 滚动停止
    @objc optional func pageContaionerViewDidEndScroll()
}

open class WJPageTitleBarView: UIView {

    public var titles: [String]
    public var config: WJPageViewConfig
    public weak var delegate: WJPageTitleBarViewDelegate?
 
    
    private lazy var scrollView: UIScrollView = setupScrollView();
    private lazy var indicatorView: UIView    = setupIndicator();
    private lazy var ovalView: UIView         = setupOvalView()
    private var titleLabels: [UILabel] = [UILabel]()
    private var allOvalViews: [UIView] = [UIView]()
    private var titleWidthArr: [CGFloat] = [CGFloat]()
    private var canScrollTitleLabelToCenter: Bool = false
    
    private lazy var normalColorRGB: WJColorRGB = config.titleNormalColor.getRGB()
    private lazy var selectColorRGB: WJColorRGB = config.titleSelectedColor.getRGB()
    private lazy var deltaRGB: WJColorRGB = {
        let deltaR = self.normalColorRGB.red - self.selectColorRGB.red
        let deltaG = self.normalColorRGB.green - self.selectColorRGB.green
        let deltaB = self.normalColorRGB.blue - self.selectColorRGB.blue
        return (deltaR, deltaG, deltaB)
    }()
    
    private lazy var allOvalNormalColorRGB: WJColorRGB = config.allOvalViewNormalColor.getRGB()
    private lazy var allOvalSelectColorRGB: WJColorRGB = config.allOvalViewSelectColor.getRGB()
    private lazy var allOvalDeltaRGB: WJColorRGB = {
        let deltaR = self.allOvalNormalColorRGB.red - self.allOvalSelectColorRGB.red
        let deltaG = self.allOvalNormalColorRGB.green - self.allOvalSelectColorRGB.green
        let deltaB = self.allOvalNormalColorRGB.blue - self.allOvalSelectColorRGB.blue
        return (deltaR, deltaG, deltaB)
    }()
    

    
    public init(frame: CGRect, config: WJPageViewConfig, titles: [String]) {
        self.titles = titles
        self.config = config
        super.init(frame: frame)
        titleBarSetup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        self.titles = [String]()
        self.config = WJPageViewConfig()
        super.init(coder: aDecoder)
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
        
        assert(config.defaultIndex >= 0, "索引必须>=0")
        assert(config.defaultIndex < titles.count, "索引超过标题个数")
        
        titleLabels.removeAll()
        for(index, title) in titles.enumerated() {
            
            if config.isShowAllOvalView {
                let allOvalView = UIView()
                allOvalView.alpha = config.allOvalViewAlpha
                allOvalView.backgroundColor = index == config.defaultIndex ? config.allOvalViewSelectColor : config.allOvalViewNormalColor
                allOvalView.layer.masksToBounds = true
                if config.isShowBorderUnSelect, index != config.defaultIndex {
                    allOvalView.layer.borderColor = config.allOvalViewUnSelectBorderColor.cgColor
                    allOvalView.layer.borderWidth = config.allOvalViewUnSelectBorderWidth
                }
                allOvalViews.append(allOvalView)
                scrollView.addSubview(allOvalView)
            }
            
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
        
        if config.isShowAllOvalView {
            layoutAllOvalView()
        }
        
    }
    
    
    
    private func layoutAllOvalView() {
        for (index, titleLabel) in titleLabels.enumerated() {
            let allOvalView = allOvalViews[index]
            allOvalView.frame.size.width = config.allOvalViewExtendWidth * 2 + titleLabel.frame.size.width
            allOvalView.center.x = titleLabel.center.x
            allOvalView.frame.size.height = config.allOvalViewHeight ?? titleLabel.frame.size.height
            allOvalView.center.y = titleLabel.center.y
            allOvalView.layer.cornerRadius = config.allOvalViewCornerRadius ?? (config.allOvalViewHeight != nil ? config.allOvalViewHeight! * 0.5 : titleLabels[config.defaultIndex].frame.size.height * 0.5)
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
        
        
        if config.isScaleTransformEnable {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.25) {
                self.titleLabels[self.config.defaultIndex].transform = CGAffineTransform(scaleX: self.config.maximumScaleTransformFactor, y: self.config.maximumScaleTransformFactor)
            }
        }
        
      
        
    }
}


// MARK: - 标题按钮点击事件
extension WJPageTitleBarView {
    
    @objc private func titleLabelClicked(_ tapGes: UITapGestureRecognizer) {
        
        guard let targetTitleLabel = tapGes.view as? UILabel else { return }
        
        // repeat click
        if targetTitleLabel.tag == config.defaultIndex {
            delegate?.reloader??.titleBarViewTitleDidRepeatClicked?()
            return
        }
        
        
        delegate?.titleBarView?(self, targetTitleLabel.tag)
        
        animateFromTitleLabel(titleLabels[config.defaultIndex], to: targetTitleLabel)
        
        scrollTargetTitleLabelToCenter(targetTitleLabel)

    }
    
    private func animateFromTitleLabel(_ sourceLabel: UILabel, to targetLabel: UILabel) {
        

        // 标题选中颜色
        changeTitleSelectedState(sourceLabel, targetLabel)
        
        self.config.defaultIndex = targetLabel.tag
        
        // 标题放大动画
        if config.isScaleTransformEnable {
            starTitleScaleTransformAnimate(sourceLabel, targetLabel)
        }
        
        // 线条指示器动画
        if config.isShowIndicator {
            startIndicatorAnimate(sourceLabel, targetLabel)
        }
        
        // 椭圆背景指示器动画
        if config.isShowOvalView {
            startOvalViewAnimate(sourceLabel, targetLabel)
        }
        
        if config.isShowAllOvalView {
            startAllOvalViewAnimate(sourceLabel.tag, targetLabel.tag)
        }
        
    }
    
    
    private func starTitleScaleTransformAnimate(_ sourceLabel: UILabel, _ targetLabel: UILabel) {
        
        UIView.animate(withDuration: 0.25) {
            sourceLabel.transform = CGAffineTransform.identity
            targetLabel.transform = CGAffineTransform(scaleX: self.config.maximumScaleTransformFactor, y: self.config.maximumScaleTransformFactor)
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
    
    private func startAllOvalViewAnimate(_ sourceIndex: Int, _ targetIndex: Int) {
        let sourceAllOvalView = allOvalViews[sourceIndex]
        let targetAllOvalView = allOvalViews[targetIndex]
        
        sourceAllOvalView.backgroundColor = config.allOvalViewNormalColor
        targetAllOvalView.backgroundColor = config.allOvalViewSelectColor
        targetAllOvalView.layer.borderWidth = 0
        
        if config.isShowBorderUnSelect {
            
            sourceAllOvalView.layer.borderWidth = config.allOvalViewUnSelectBorderWidth
            sourceAllOvalView.layer.borderColor = config.allOvalViewUnSelectBorderColor.cgColor
        }
        
    }
    
    
    private func startIndicatorAnimate(_ sourceLabel: UILabel, _ targetLabel: UILabel) {
        
        if config.isIndicatorStretchAnimationEnable {
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
        } else {
            UIView.animate(withDuration: 0.25) {
                self.indicatorView.frame.size.width = self.config.indicatorWidth ?? targetLabel.frame.size.width
                self.indicatorView.center.x = targetLabel.center.x
            }
        }
        
        
    }
    
    
    /// 滚动标题到标题栏中心
    public func scrollTargetTitleLabelToCenter(_ targetLabel: UILabel?, animated: Bool = true) {
        
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
        scrollTargetTitleLabelToCenter(titleLabels[targetIndex], animated: true)
        
        if config.isShowAllOvalView, sourceIndex != targetIndex {
            startAllOvalViewAnimate(sourceIndex, targetIndex)
        }
    }
    
    /// 滚动进度相关信息
    public func pageContainerView(_ pageContainerView: WJPageContainerView, sourceIndex: Int, targetIndex: Int, progress: CGFloat) {
        
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
//            indicatorView.frame.size.width = config.indicatorWidth ?? (sourceLabel.frame.width + changeWidth * progress)
//            indicatorView.center.x = sourceLabel.center.x + distance * progress

            
            if config.isIndicatorStretchAnimationEnable {
                var addIndicatorW: CGFloat = 0
                if config.indicatorWidth != nil {
                    addIndicatorW = config.indicatorWidth!
                } else {
                    addIndicatorW = sourceLabel.frame.width * 0.5 + targetLabel.frame.width * 0.5
                }
                let totalWidth = CGFloat(fabsf(Float(distance))) + addIndicatorW
                let growWidth = totalWidth - (config.indicatorWidth ?? sourceLabel.frame.width)
                let reduceWidth = totalWidth - (config.indicatorWidth ?? targetLabel.frame.width)
                
                if progress <= 0.5 {
                    indicatorView.frame.size.width = (config.indicatorWidth ?? sourceLabel.frame.width) + growWidth * progress * 2
                } else {
                    indicatorView.frame.size.width = totalWidth - reduceWidth * (progress - 0.5) * 2
                }
            } else {
                indicatorView.frame.size.width = config.indicatorWidth ?? (sourceLabel.frame.width + changeWidth * progress)
            }
 
            indicatorView.center.x = sourceLabel.center.x + distance * progress
            
            
        }
        
        
        if config.isScaleTransformEnable {
            let diffScale = config.maximumScaleTransformFactor - 1.0
            sourceLabel.transform = CGAffineTransform(scaleX: config.maximumScaleTransformFactor - progress * diffScale, y: config.maximumScaleTransformFactor - progress * diffScale)
            targetLabel.transform = CGAffineTransform(scaleX: 1.0 + progress * diffScale, y: 1.0 + progress * diffScale)
        }
        
        if config.isTitleColorAnimationEnable {
            
            if config.isShowAllOvalView, config.isShowBorderUnSelect { return }
            
            if config.titleNormalColor == config.titleSelectedColor { return }
            sourceLabel.textColor = UIColor(red: selectColorRGB.red+deltaRGB.red * progress, green: selectColorRGB.green+deltaRGB.green*progress, blue: selectColorRGB.blue+deltaRGB.blue*progress, alpha: 1.0)
            targetLabel.textColor = UIColor(red: normalColorRGB.red-deltaRGB.red*progress, green: normalColorRGB.green-deltaRGB.green*progress, blue: normalColorRGB.blue-deltaRGB.blue*progress, alpha: 1.0)
    
        } else {
            
            if config.isShowAllOvalView, config.isShowBorderUnSelect { return }
            
            if progress >= 0.5 {
                targetLabel.textColor = config.titleSelectedColor
                sourceLabel.textColor = config.titleNormalColor
            } else {
                targetLabel.textColor = config.titleNormalColor
                sourceLabel.textColor = config.titleSelectedColor
            }
        }
        
        
        if config.isShowAllOvalView {
            
            if config.isShowBorderUnSelect { return }
            
            if config.allOvalViewNormalColor == config.allOvalViewSelectColor { return }
            let sourceAllOvalView = allOvalViews[sourceIndex]
            let targetAllOvalView = allOvalViews[targetIndex]

            sourceAllOvalView.backgroundColor = UIColor(red: allOvalSelectColorRGB.red+allOvalDeltaRGB.red*progress, green: allOvalSelectColorRGB.green+allOvalDeltaRGB.green*progress, blue: allOvalSelectColorRGB.blue+allOvalDeltaRGB.blue*progress, alpha: 1.0)
            
            
            targetAllOvalView.backgroundColor = UIColor(red: allOvalNormalColorRGB.red-allOvalDeltaRGB.red*progress, green: allOvalNormalColorRGB.green-allOvalDeltaRGB.green*progress, blue: allOvalNormalColorRGB.blue-allOvalDeltaRGB.blue*progress, alpha: 1.0)
            
//
//            if config.isShowBorderUnSelect {
//
//                sourceAllOvalView.layer.borderWidth = progress * config.allOvalViewUnSelectBorderWidth
//                targetAllOvalView.layer.borderWidth = (1 - progress) * config.allOvalViewUnSelectBorderWidth
//
//                sourceAllOvalView.layer.borderColor = UIColor(red: allOvalBorderColorRGB.red+allOvalBorderDeltaRGB.red*progress, green: allOvalBorderColorRGB.green+allOvalBorderDeltaRGB.green*progress, blue: allOvalBorderColorRGB.blue+allOvalBorderDeltaRGB.blue*progress, alpha: 1.0).cgColor
//
//                targetAllOvalView.layer.borderColor = UIColor(red: allOvalBorderSelectColorRGB.red-allOvalBorderDeltaRGB.red*progress, green: allOvalBorderSelectColorRGB.green-allOvalBorderDeltaRGB.green*progress, blue: allOvalBorderSelectColorRGB.blue-allOvalBorderDeltaRGB.blue*progress, alpha: 1.0).cgColor
//            }
            
        }
        
        
        
    }
    
    
}
















