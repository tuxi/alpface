//
//  BaseProfileViewController.swift
//  Alpface
//
//  Created by swae on 2018/4/5.
//  Copyright © 2018年 alpface. All rights reserved.
//

import UIKit

fileprivate let HitTestScrollViewCellIdentifier = "HitTestScrollViewCellIdentifier"
fileprivate let HitTestScrollViewSectionIdentifier = "HitTestScrollViewSectionIdentifier"
let ALPNavigationTitleLabelBottomPadding : CGFloat = 15.0;

@objc public protocol ProfileViewChildControllerProtocol {
    /// 必须实现此方法，告知BaseProfileViewController当前控制器的view是否是scrollView
    /// 用与控制mainScrollView和child scrollView 之间滚动
    /// 如果不是UIScrollView类型，返回nil即可
    func childScrollView() -> UIScrollView?
}

@objc(ALPBaseProfileViewController)
open class BaseProfileViewController: UIViewController {
    
    /// 全局tint color
    open static var globalTint: UIColor = UIColor(red: 42.0/255.0, green: 163.0/255.0, blue: 239.0/255.0, alpha: 1)
    
    open let bouncingThreshold: CGFloat = 100
    
    /// scrollView 向上滚动时时，固定头部背景视图，此属性为scrollView滚动到contentView.y==这个偏移量时，就固定头部背景视图，将其作为当导航条展示 (固定值)
    open func scrollToScaleDownProfileIconDistance() -> CGFloat {
        return stickyheaderContainerViewHeight - navigationMinHeight
    }
    
    /// 头部背景视图最小的高度(固定值)
    open let navigationMinHeight : CGFloat = 65.0
    
    open var navigationTitleLabelBottomConstraint : NSLayoutConstraint?
    
    /// 头部描述用户信息视图的高度(不固定值)
    open var profileHeaderViewHeight: CGFloat = 160
    
    open let segmentedControlContainerHeight: CGFloat = 46
    
    /// 容器cell最大高度
    open func containerCellMaxHeight() -> CGFloat {
        // 感觉算的差一点，就加上一个间距，补充差值
        let padding : CGFloat = 5.0
        let maxHeight: CGFloat = self.view.frame.size.height - navigationMinHeight - segmentedControlContainerHeight + padding
        return maxHeight
    }
    
    // MARK: Properties
    open var currentIndex: Int = 0 {
        didSet {
            if currentIndex == oldValue {
                return
            }
            self.updateTableViewContent(index: currentIndex)
        }
    }
    
    open var controllers: [ProfileViewChildControllerProtocol] = []
    
    open var currentController: ProfileViewChildControllerProtocol {
        return controllers[currentIndex]
    }
    
    fileprivate lazy var containerViewController: HitTestContainerViewController = {
        let containerViewController = HitTestContainerViewController()
        containerViewController.delegate = self
        return containerViewController;
    }()
    
    /// main scrollView是否可以滚动 (用于控制main 与 child scrollView 之间的滚动)
    public var shouldScrollForMainScrollView: Bool = true
    
    open lazy var mainScrollView: UITableView = {
        let _mainScrollView = HitTestScrollView(frame: self.view.bounds, style: .plain)
        _mainScrollView.delegate = self
        _mainScrollView.dataSource = self
        _mainScrollView.showsHorizontalScrollIndicator = false
        _mainScrollView.showsVerticalScrollIndicator = false
        _mainScrollView.backgroundColor = UIColor.white
        _mainScrollView.separatorStyle = .none
        _mainScrollView.scrollsToTop = false
        _mainScrollView.register(HitTestScrollViewCell.classForCoder(), forCellReuseIdentifier: HitTestScrollViewCellIdentifier)
        if #available(iOS 11.0, *) {
            _mainScrollView.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        return _mainScrollView
    }()
    
    open lazy var profileHeaderView: ProfileHeaderView = {
        let _profileHeaderView = ProfileHeaderView(frame: CGRect.init(x: 0, y: 0, width: self.mainScrollView.frame.width, height: 220))
        return _profileHeaderView
    }()
    
    /// 下拉头部放大控件 (头部背景视图)
    open lazy var stickyHeaderView: StickyHeaderContainerView = {
        let stickyHeaderView = StickyHeaderContainerView()
        return stickyHeaderView
    }()
    
    fileprivate lazy var tableHeaderView: UIView = {
        let view = UIView()
        return view
    }()
    
    
    fileprivate lazy var segmentedControl: ScrollableSegmentedControl = {
        let _segmentedControl = ScrollableSegmentedControl()
        _segmentedControl.segmentStyle = .textOnly
        _segmentedControl.addTarget(self, action: #selector(self.segmentedControlValueDidChange(sender:)), for: .valueChanged)
        
        for index in 0..<numberOfSegments() {
            let segmentTitle = self.segmentTitle(forSegment: index)
            _segmentedControl.insertSegment(withTitle: segmentTitle, image: nil, at: index)
            
        }
        _segmentedControl.backgroundColor = UIColor.black
        return _segmentedControl
    }()
    
    fileprivate lazy var segmentedControlContainer: UITableViewHeaderFooterView = {
        let _segmentedControlContainer = UITableViewHeaderFooterView.init(reuseIdentifier: HitTestScrollViewSectionIdentifier)
        _segmentedControlContainer.contentView.backgroundColor = UIColor.white
        return _segmentedControlContainer
    }()
    
    open lazy var navigationTitleLabel: UILabel = {
        let _navigationTitleLabel = UILabel()
        _navigationTitleLabel.text = "username"
        _navigationTitleLabel.textColor = UIColor.white
        _navigationTitleLabel.font = UIFont.boldSystemFont(ofSize: 17.0)
        
        return _navigationTitleLabel
    }()
    
    fileprivate var debugTextView: UILabel!
    
    /// 更新table header 布局，高度是计算出来的，所以当header上的内容发生改变时，应该执行一次更新header布局
    fileprivate var needsUpdateHeaderLayout = false
    open func setNeedsUpdateHeaderLayout() {
        self.needsUpdateHeaderLayout = true
    }
    open func updateHeaderLayoutIfNeeded() {
        if self.needsUpdateHeaderLayout == true {
            self.profileHeaderViewHeight = profileHeaderView.sizeThatFits(self.mainScrollView.bounds.size).height
            
            /// 只要第一次view布局完成时，再调整下stickyHeaderContainerView的frame，剩余的情况会在scrollViewDidScrollView:时调整
            self.stickyHeaderView.frame = self.computeStickyHeaderContainerViewFrame()
            
            
            /// 更新profileHeaderView和segmentedControlContainer的frame
            self.profileHeaderView.frame = self.computeProfileHeaderViewFrame()
            
            tableHeaderView.frame = CGRect.init(x: 0, y: 0, width: 0, height: stickyHeaderView.frame.height + profileHeaderView.frame.size.height)
            self.mainScrollView.tableHeaderView = tableHeaderView
            profileHeaderView.frame = self.computeProfileHeaderViewFrame()
            self.needsUpdateHeaderLayout = false
        }
    }
    
    deinit {
        self.controllers.forEach { (controller) in
            let vc = controller as! UIViewController
            vc.view.removeFromSuperview()
        }
        self.controllers.removeAll()
        
    }
    
    /// 刷新页面
    open func reloadPage() {
        self.controllers = []
        for index in 0..<numberOfSegments() {
            let controller = self.controller(forSegment: index)
            self.controllers.append(controller)
        }
        
        self.mainScrollView.reloadData()
        
        containerDidLoad()
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        setNeedsStatusBarAppearanceUpdate()
        
        self.prepareViews()
        
        self.setNeedsUpdateHeaderLayout()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.containerViewController.beginAppearanceTransition(true, animated: true)
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.containerViewController.endAppearanceTransition()
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.containerViewController.beginAppearanceTransition(false, animated: true)
    }
    
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.containerViewController.endAppearanceTransition()
    }
    
    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        updateHeaderLayoutIfNeeded()
    }
    
    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    // MARK: - Override methods
    open func numberOfSegments() -> Int {
        /* 需要子类重写 */
        return 0
    }
    
    open func segmentTitle(forSegment index: Int) -> String {
        /* 需要子类重写 */
        return ""
    }
    
    open func controller(forSegment index: Int) -> ProfileViewChildControllerProtocol {
        /* 需要子类重写 */
        return (UIViewController() as? ProfileViewChildControllerProtocol)!
    }
    
    open func controller(didDisplay controller: UIViewController, forItemAt index: Int) {
         /* 子类可以重写 */
    }
    
    open func controller(willDisplay controller: UIViewController, forItemAt index: Int) {
         /* 子类可以重写 */
    }
}

extension BaseProfileViewController {
    
    func prepareViews() {
        
        self.view.addSubview(mainScrollView)
        
        mainScrollView.translatesAutoresizingMaskIntoConstraints = false
        mainScrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        mainScrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        mainScrollView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        mainScrollView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        
        tableHeaderView.addSubview(stickyHeaderView)
        tableHeaderView.addSubview(profileHeaderView)
        
        mainScrollView.tableHeaderView = tableHeaderView
        
        
        // 导航标题
        stickyHeaderView.addSubview(navigationTitleLabel)
        navigationTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        navigationTitleLabel.centerXAnchor.constraint(equalTo: stickyHeaderView.centerXAnchor).isActive = true
        navigationTitleLabelBottomConstraint = navigationTitleLabel.bottomAnchor.constraint(equalTo: stickyHeaderView.bottomAnchor, constant: -ALPNavigationTitleLabelBottomPadding)
        navigationTitleLabelBottomConstraint?.isActive = true
        
        
        // 设置进度为0时的导航条标题和导航条详情label的位置 (此时标题和详情label 在headerView的最下面隐藏)
        animateNaivationTitleAt(progress: 0.0)
        
        // 分段控制视图
        segmentedControlContainer.contentView.addSubview(segmentedControl)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.widthAnchor.constraint(equalTo: segmentedControlContainer.contentView.widthAnchor, constant: 0.0).isActive = true
        segmentedControl.heightAnchor.constraint(equalTo: segmentedControlContainer.contentView.heightAnchor, constant: 0.0).isActive = true
        segmentedControl.centerXAnchor.constraint(equalTo: segmentedControlContainer.contentView.centerXAnchor).isActive = true
        segmentedControl.centerYAnchor.constraint(equalTo: segmentedControlContainer.contentView.centerYAnchor).isActive = true
        
        segmentedControl.underlineSelected = true
        segmentedControl.selectedSegmentIndex = 0
        let largerWhiteTextAttributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16),
                                       NSAttributedStringKey.foregroundColor: UIColor.white]
        
        let largerRedTextHighlightAttributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16),
                                                NSAttributedStringKey.foregroundColor: UIColor.blue]
        let largerRedTextSelectAttributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16),
                                             NSAttributedStringKey.foregroundColor: UIColor.orange]
        
        segmentedControl.setTitleTextAttributes(largerWhiteTextAttributes, for: .normal)
        
    segmentedControl.setTitleTextAttributes(largerRedTextHighlightAttributes, for: .highlighted)
        
        segmentedControl.setTitleTextAttributes(largerRedTextSelectAttributes, for: .selected)
        
        self.reloadPage()
        self.showDebugInfo()
    }

    
    func computeStickyHeaderContainerViewFrame() -> CGRect {
        return CGRect(x: 0, y: 0, width: mainScrollView.bounds.width, height: stickyheaderContainerViewHeight)
    }
    
    func computeProfileHeaderViewFrame() -> CGRect {
        return CGRect(x: 0, y: computeStickyHeaderContainerViewFrame().origin.y + stickyheaderContainerViewHeight, width: mainScrollView.bounds.width, height: profileHeaderViewHeight)
    }
    
    func computeTableViewFrame(tableView: UIScrollView) -> CGRect {
        let upperViewFrame = computeSegmentedControlContainerFrame()
        return CGRect(x: 0, y: upperViewFrame.origin.y + upperViewFrame.height , width: mainScrollView.bounds.width, height: tableView.contentSize.height)
    }
    
    func computeNavigationFrame() -> CGRect {
        let navigationHeight:CGFloat = max(stickyHeaderView.frame.origin.y - self.mainScrollView.contentOffset.y + stickyHeaderView.bounds.height, navigationMinHeight)

        let navigationLocation = CGRect(x: 0, y: 0, width: stickyHeaderView.bounds.width, height: navigationHeight)
        return navigationLocation
    }
    
    func computeSegmentedControlContainerFrame() -> CGRect {
        //        let rect = computeProfileHeaderViewFrame()
        //        return CGRect(x: 0, y: rect.origin.y + rect.height, width: mainScrollView.bounds.width, height: segmentedControlContainerHeight)
        return CGRect(x: 0, y: profileHeaderView.frame.maxY, width: mainScrollView.bounds.width, height: segmentedControlContainerHeight)
        
    }
    
}

extension BaseProfileViewController: UIScrollViewDelegate {
    
    /// scrollView滚动时调用
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView.isEqual(self.mainScrollView) == false {
            return
        }
        let contentOffset = scrollView.contentOffset
        self.debugContentOffset(contentOffset: contentOffset)
        
        // 当向下滚动时，固定头部视图
        if contentOffset.y <= 0 {
            let bounceProgress = min(1, abs(contentOffset.y) / bouncingThreshold)
            
            let newHeight = abs(contentOffset.y) + stickyheaderContainerViewHeight
            
            // 调整 stickyHeader 的 frame
            self.stickyHeaderView.frame = CGRect(
                x: 0,
                y: contentOffset.y,
                width: mainScrollView.bounds.width,
                height: newHeight)
            
            // 更新blurEffectView的透明度
            self.stickyHeaderView.blurEffectView.alpha = min(1, bounceProgress * 2)
            
            // 更新headerCoverView的缩放比例
            let scalingFactor = 1 + min(log(bounceProgress + 1), 2)
            //      print(scalingFactor)
            self.stickyHeaderView.headerCoverView.transform = CGAffineTransform(scaleX: scalingFactor, y: scalingFactor)
            
        } else {
            
            self.stickyHeaderView.blurEffectView.alpha = 0
        }

        // 普通情况时，适用于contentOffset.y改变时的更新
        let scaleProgress = max(0, min(1, contentOffset.y / self.scrollToScaleDownProfileIconDistance()))
        self.profileHeaderView.animator(t: scaleProgress)
        
        if contentOffset.y > 0 {
            
            // 当scrollView滚动到达阈值时scrollToScaleDownProfileIconDistance
            if contentOffset.y >= scrollToScaleDownProfileIconDistance() {
                self.stickyHeaderView.frame = CGRect(x: 0, y: contentOffset.y - scrollToScaleDownProfileIconDistance(), width: mainScrollView.bounds.width, height: stickyheaderContainerViewHeight)
                // 当scrollView 的 segment顶部 滚动到scrollToScaleDownProfileIconDistance时(也就是导航底部及以上位置)，让stickyHeaderContainerView显示在最上面，防止被profileHeaderView遮挡
                tableHeaderView.bringSubview(toFront: self.stickyHeaderView)
                
            } else {
                // 当scrollView 的 segment顶部 滚动到导航底部以下位置，让profileHeaderView显示在最上面,防止用户头像被遮挡
                self.stickyHeaderView.frame = computeStickyHeaderContainerViewFrame()
                tableHeaderView.bringSubview(toFront: self.profileHeaderView)
            }
            
            // Sticky Segmented Control
            let navigationLocation = computeNavigationFrame()
//            let navigationHeight:CGFloat = navigationLocation.height - abs(navigationLocation.origin.y)
            
            let segmentedControlContainerLocationY = ceil(stickyheaderContainerViewHeight + profileHeaderViewHeight - navigationLocation.height)
            let contentOffSetY = ceil(contentOffset.y)
            if contentOffSetY > 0 && contentOffSetY >= segmentedControlContainerLocationY {
                // mainScrollView滚动到顶部了, 让segment悬停在导航底部
                // 当视图滑动的距离大于header时，这里就可以设置section1的header的位置啦，设置的时候要考虑到导航栏的透明对滚动视图的影响
                self.scrollViewDidScrollToNavigationBottom(scrollView: scrollView, segmentedControlContainerMinY: segmentedControlContainerLocationY)
            } else {
                // mainScrollView离开顶部了
                self.scrollViewDidLeaveNavigationBottom(scrollView: scrollView, segmentedControlContainerMinY: segmentedControlContainerLocationY)
            }
            
            
            // 当滚动视图到达标题标签的顶部边缘时
            let titleLabel = profileHeaderView.usernameLabel
            let nicknameLabel = profileHeaderView.nicknameLabel
            
            //  titleLabel 相对于控制器view的位置
            let titleLabelLocationY = stickyheaderContainerViewHeight - 35
            
            let totalHeight = titleLabel.bounds.height + nicknameLabel.bounds.height + 35
            let detailProgress = max(0, min((contentOffset.y - titleLabelLocationY) / totalHeight, 1))
            self.stickyHeaderView.blurEffectView.alpha = detailProgress
            animateNaivationTitleAt(progress: detailProgress)
            
        }
        
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.scrollViewDidEndScroll(scrollView)
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate == false {
            self.scrollViewDidEndScroll(scrollView)
        }
    }
   
}

extension BaseProfileViewController: HitTestScrollViewGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == self.mainScrollView.panGestureRecognizer && otherGestureRecognizer == self.containerViewController.collectionView.panGestureRecognizer {
            return false
        }
        if gestureRecognizer.view!.isMember(of: HitTestScrollView.classForCoder()) && otherGestureRecognizer.view!.isMember(of:GestureCoordinatingCollectionView.classForCoder()) {
            return false
        }
        return true
    }
}

extension BaseProfileViewController {
    
    /// scrollView 滚动结束时调用
    fileprivate func scrollViewDidEndScroll(_ scrollView: UIScrollView) {
        // 在scrollView 滚动结束时将所有child scrollView 的滚动禁止掉
    }
    
    /// 容器视图及其内容初始化完成时调用
    fileprivate func containerDidLoad() {
        controllers.forEach { (controller) in
            // 默认让controller的scrollView不能滚动
        }
    }
    
    /// scrollView 滚动到导航底部了，子控制的scrollView可以滚动了
    fileprivate func scrollViewDidScrollToNavigationBottom(scrollView: UIScrollView, segmentedControlContainerMinY: CGFloat) {
        let newContentOffset = CGPoint(x: 0, y: segmentedControlContainerMinY)
        if newContentOffset.equalTo(scrollView.contentOffset) == false {
            scrollView.contentOffset = newContentOffset
        }
        if self.shouldScrollForMainScrollView == true {
            // 当当前显示的child scrollView 不能够滚动时，比如其contentSize小与其frame.size时，就还让main scrollView 响应滚动
            if let controller = self.containerViewController.displayViewController() as? ProfileViewChildControllerProtocol {
                guard let childScrollView = controller.childScrollView() else {
                    self.shouldScrollForMainScrollView = true
                    return
                }
                let contentSizeHeight = childScrollView.contentSize.height
                let frameSizeHeight = childScrollView.frame.size.height
                if contentSizeHeight <= frameSizeHeight {
                    self.shouldScrollForMainScrollView = true
                    self.containerViewController.shouldScrollForCurrentChildScrollView = false
                }
                else {
                    self.shouldScrollForMainScrollView = false
                    self.containerViewController.shouldScrollForCurrentChildScrollView = true
                }
            }
            
        }
    }
    
    /// scrollView 滚动到导航底部了，main scrollView可以滚动了
    fileprivate func scrollViewDidLeaveNavigationBottom(scrollView: UIScrollView, segmentedControlContainerMinY: CGFloat) {
        
        if (self.shouldScrollForMainScrollView == false) {
            let newContentOffset = CGPoint(x: 0, y: segmentedControlContainerMinY)
            if newContentOffset.equalTo(scrollView.contentOffset) == false {
                scrollView.contentOffset = newContentOffset
            }
        }
    }
}
extension BaseProfileViewController: HitTestContainerViewControllerDelegate {
    
    internal func hitTestContainerViewController(_ containerViewController: HitTestContainerViewController, didPageDisplay controller: UIViewController, forItemAt index: Int) {
        segmentedControl.selectedSegmentIndex = index
        self.controller(didDisplay: controller, forItemAt: index)
    }
    
    internal func hitTestContainerViewController(_ containerViewController: HitTestContainerViewController, willPageDisplay controller: UIViewController, forItemAt index: Int) {
        self.controller(willDisplay: controller, forItemAt: index)
    }
    
    internal func hitTestContainerViewController(_ containerViewController: HitTestContainerViewController, handlerContainerPanGestureState panGesture: UIPanGestureRecognizer) {
        // 当滚动page 的容器视图时，mainScrollView不可以滚动
        switch panGesture.state {
        case .began:
            self.mainScrollView.isScrollEnabled = false
        default:
            self.mainScrollView.isScrollEnabled = true
        }
    }
    
    internal func hitTestContainerViewController(_ containerViewController: HitTestContainerViewController, childScrollViewLeaveTop scrollView: UIScrollView) {
        
        // 当子scrollview 离开顶部时，其不应该可能滚动，main scrollView 可以滚动
        self.shouldScrollForMainScrollView = true
        self.mainScrollView.isScrollEnabled = true
    }
}

// MARK: UITableViewDelegates & DataSources
extension BaseProfileViewController: UITableViewDelegate, UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: HitTestScrollViewCellIdentifier, for: indexPath) as! HitTestScrollViewCell
        self.containerViewController.viewControllers = self.controllers
        cell.view = self.containerViewController.view
        return cell
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return containerCellMaxHeight()
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: HitTestScrollViewSectionIdentifier)
        if headerView == nil {
            headerView = self.segmentedControlContainer
        }
        return headerView
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return segmentedControlContainerHeight
    }
    
}

// MARK: Animators
extension BaseProfileViewController {
    /// 更新导航条上面titleLabel的位置
    func animateNaivationTitleAt(progress: CGFloat) {
        
        let totalDistance: CGFloat = self.navigationTitleLabel.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height + ALPNavigationTitleLabelBottomPadding
        
        if progress >= 0 {
            let distance = (1 - progress) * totalDistance
            navigationTitleLabelBottomConstraint?.constant = -ALPNavigationTitleLabelBottomPadding + distance
        }
    }
}

/// MARK: status bar
extension BaseProfileViewController {
    override open var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override open var prefersStatusBarHidden: Bool {
        return false
    }
}


extension BaseProfileViewController {
    func updateTableViewContent(index: Int) {
        self.containerViewController.show(page: index, animated: true)
    }
    
    @objc internal func segmentedControlValueDidChange(sender: AnyObject?) {
        self.currentIndex = self.segmentedControl.selectedSegmentIndex
    }
}

extension BaseProfileViewController {
    
    var debugMode: Bool {
        return false
    }
    
    func showDebugInfo() {
        if debugMode {
            self.debugTextView = UILabel()
            debugTextView.text = "debug mode: on"
            debugTextView.backgroundColor = UIColor.white
            debugTextView.sizeToFit()
            
            self.view.addSubview(debugTextView)
            debugTextView.translatesAutoresizingMaskIntoConstraints = false
            debugTextView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 6.0).isActive = true
            debugTextView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: UIApplication.shared.statusBarFrame.height).isActive = true
        }
    }
    
    func debugContentOffset(contentOffset: CGPoint) {
        self.debugTextView?.text = "\(contentOffset)"
    }
}

extension CGRect {
    var alp_originBottom: CGFloat {
        return self.origin.y + self.height
    }
}
