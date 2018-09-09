# WJPageView

[![Version](https://img.shields.io/cocoapods/v/WJPageView.svg?style=flat)](http://cocoapods.org/pods/DNSPageView)
[![License](https://img.shields.io/cocoapods/l/WJPageView.svg?style=flat)](http://cocoapods.org/pods/DNSPageView)
[![Platform](https://img.shields.io/cocoapods/p/DNSPageView.svg?style=flat)](http://cocoapods.org/pods/WJPageView)

`WJPageView`是一个纯`swift`编写的易用的标题栏和控制器切换交互工具视图。



## Demo



<img src="https://github.com/WJCha/WJPageView/blob/master/Resource/title01.png" width="260" hegiht="463" style="float: left;" />

<img src="https://github.com/WJCha/WJPageView/blob/master/Resource/demo01.gif" width="260" hegiht="463" style="float: left;" />



## Components

![Components](https://github.com/WJCha/WJPageView/blob/master/Resource/结构.jpg)

- `WJPageTitleBarView`对应用于创建`标题栏titleBar`，通过`WJPageViewConfig`来控制器样式，
- `WJPageContainerView`对应用于创建内容页，通过`WJPageViewConfig`来控制器样式
- `WJPageView`包含两个属性，即分别对应标题栏和内容页视图，通过该类可以快速创建含有标题栏和内容页的处理交互页面
- `WJPageTitleBarView` 和 `WJPageContainerView`之间通过代理完成标题栏和内容页的交互操作

### `WJPageTitleBarView` 样式结构

> 为了方便大家控制该类创建标题栏样式，现针对其做一个简要图示说明

![titleBarView](https://github.com/WJCha/WJPageView/blob/master/Resource/titleBarView.jpg)



## Requirements

- `iOS 8.0+`
- `Xcode 9.0+`
- `Swift 4.0+`



## Installation

### CocoaPods

#### Podfile 文件编写
```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'
use_frameworks!

target 'TargetName' do
  pod 'WJPageView'
end
```
#### 执行安装
`pod install`

### Manually

如果要手工导入的话，只需下载该项目，将 `WJPageView`目录拖入项目即可



## Usage

#### 快速创建标题栏和内容页

```swift
    // titles
    private lazy var titles: [String] = ["音乐", "视频", "推荐"]
    // childViewControllers
    let childVCs: [UIViewController] = [
        WJMusicViewController(),
        WJVideoViewController(),
        WJRecommendViewController()
    ]
    // WJPageViewConfig style
    private lazy var config: WJPageViewConfig = {
        let config = WJPageViewConfig()
        config.titleBarBgColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1.0)
        config.titleSelectedColor = .red
        config.indecatorBottomOffset = 2
        return config
    }()
    // create WJPageView
    let pageView = WJPageView(config: config, titles: titles, childViewControllers: childVCs)
    // 注意 pageContainerView 和 titleBarView 的添加顺序,确保布局时 titleBarView 不会被 pageContainerView 遮盖
    view.addSubview(pageView.pageContainerView)
    view.addSubview(pageView.titleBarView)

     // 分别布局titleBarView和pageContainerView，可以使用Autolayout或frame布局
    pageView.titleBarView.snp.makeConstraints { (make) in
        make.left.right.equalToSuperview()
        make.top.equalTo(kNavigationBarHeight)
        make.height.equalTo(44)
    }
    pageView.pageContainerView.snp.makeConstraints { (make) in
        make.top.equalTo(pageView.titleBarView.snp.bottom)
        make.left.right.bottom.equalToSuperview()
    }
```

> 更多案例请下载该项目运行查看



## 监听标题重复点击

要想监听标题重复点击事件，可以在子控制器中遵守`WJPageReloadable`协议，实现 `titleBarViewTitleDidRepeatClicked()`方法即可

```swift
extension WJMusicViewController: WJPageReloadable {
    func titleBarViewTitleDidRepeatClicked() {
        print("音乐标题重复点击")
    }
}
```

该监听代理属于 `WJPageTitleBarViewDelegat` 中一个可选属性，通过其还可以获取内容页滚动停止的事件

```swift
@objc public protocol WJPageReloadable: NSObjectProtocol {
    
    /// 监听标题重复点击事件
    @objc optional func titleBarViewTitleDidRepeatClicked()
    
    /// 监听 pageContentView 滚动停止
    @objc optional func pageContaionerViewDidEndScroll()
}
```

## License

WJPageView is released under the MIT license. See [LICENSE](https://github.com/WJCha/WJPageView/blob/master/LICENSE) for details.
