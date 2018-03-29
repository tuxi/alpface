//
//  ProfileViewController.swift
//  Alpface
//
//  Created by swae on 2018/3/27.
//  Copyright © 2018年 alpface. All rights reserved.
//

import UIKit

let HitTestScrollViewCellIdentifier = "HitTestScrollViewCellIdentifier"
let ALPNavigationTitleLabelBottomPadding : CGFloat = 15.0;

open class ProfileViewController: UIViewController {
    
    // MARK: Public methods
    open func numberOfSegments() -> Int {
        /* 需要子类重写 */
        return 0
    }
    
    open func segmentTitle(forSegment index: Int) -> String {
        /* 需要子类重写 */
        return ""
    }
    
    open func prepareForLayout() {
        /* 需要子类重写 */
    }
    
    open func scrollView(forSegment index: Int) -> UIScrollView {
        /* 需要子类重写 */
        return UITableView.init(frame: CGRect.zero, style: .grouped)
    }
    
    // 全局tint color
    open static var globalTint: UIColor = UIColor(red: 42.0/255.0, green: 163.0/255.0, blue: 239.0/255.0, alpha: 1)
    
    
    // Constants
    open let stickyheaderContainerViewHeight: CGFloat = 125
    
    open let bouncingThreshold: CGFloat = 100
    
    open let scrollToScaleDownProfileIconDistance: CGFloat = 60
    
    open var navigationTitleLabelBottomConstraint : NSLayoutConstraint?
    
    open var profileHeaderViewHeight: CGFloat = 160
    
    open let segmentedControlContainerHeight: CGFloat = 46
    
    open var username: String? {
        didSet {
            self.profileHeaderView.usernameLabel?.text = username
            
            self.navigationTitleLabel.text = username
        }
    }
    
    open var nickname : String? {
        didSet {
            self.profileHeaderView.nicknameLabel.text = nickname;
        }
    }
    
    open var profileImage: UIImage? {
        didSet {
            self.profileHeaderView.iconImageView?.image = profileImage
        }
    }
    
    open var locationString: String? {
        didSet {
            self.profileHeaderView.locationLabel?.text = locationString
        }
    }
    
    open var descriptionString: String? {
        didSet {
            self.profileHeaderView.descriptionLabel?.text = descriptionString
        }
    }
    
    open var coverImage: UIImage? {
        didSet {
            self.headerCoverView.image = coverImage
        }
    }
    
    // MARK: Properties
    var currentIndex: Int = 0 {
        didSet {
            self.updateTableViewContent()
        }
    }
    
    var scrollViews: [UIScrollView] = []
    
    var currentScrollView: UIScrollView {
        return scrollViews[currentIndex]
    }
    
    
    fileprivate lazy var mainScrollView: UIScrollView = {
        let _mainScrollView = HitTestScrollView(frame: self.view.bounds)
        _mainScrollView.delegate = self
        _mainScrollView.showsHorizontalScrollIndicator = false
        _mainScrollView.backgroundColor = UIColor.white
        if #available(iOS 11.0, *) {
            _mainScrollView.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        return _mainScrollView
    }()
    
    fileprivate lazy var headerCoverView: UIImageView = {
        let coverImageView = UIImageView()
        coverImageView.clipsToBounds = true
        coverImageView.translatesAutoresizingMaskIntoConstraints = false
        coverImageView.image = UIImage(named: "Firewatch.png")
        coverImageView.contentMode = .scaleAspectFill
        return coverImageView
    }()
    
    fileprivate lazy var profileHeaderView: ProfileHeaderView = {
        let _profileHeaderView = Bundle.main.loadNibNamed("ProfileHeaderView", owner: self, options: nil)?.first as! ProfileHeaderView
        _profileHeaderView.usernameLabel.text = self.username
        _profileHeaderView.locationLabel.text = self.locationString
        _profileHeaderView.iconImageView.image = self.profileImage
        _profileHeaderView.nicknameLabel.text = self.nickname
        return _profileHeaderView
    }()
    
    fileprivate lazy var stickyHeaderContainerView: UIView = {
        let _stickyHeaderContainer = UIView()
        _stickyHeaderContainer.clipsToBounds = true
        return _stickyHeaderContainer
    }()
    
    fileprivate lazy var blurEffectView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .dark)
        let _blurEffectView = UIVisualEffectView(effect: blurEffect)
        _blurEffectView.alpha = 0
        return _blurEffectView
    }()
    
    fileprivate lazy var segmentedControl: UISegmentedControl = {
        let _segmentedControl = UISegmentedControl()
        _segmentedControl.addTarget(self, action: #selector(self.segmentedControlValueDidChange(sender:)), for: .valueChanged)
        _segmentedControl.backgroundColor = UIColor.white
        
        for index in 0..<numberOfSegments() {
            let segmentTitle = self.segmentTitle(forSegment: index)
            _segmentedControl.insertSegment(withTitle: segmentTitle, at: index, animated: false)
        }
        _segmentedControl.selectedSegmentIndex = 0
        return _segmentedControl
    }()
    
    fileprivate lazy var segmentedControlContainer: UIView = {
        let _segmentedControlContainer = UIView.init(frame: CGRect.init(x: 0, y: 0, width: mainScrollView.bounds.width, height: segmentedControlContainerHeight))
        _segmentedControlContainer.backgroundColor = UIColor.white
        return _segmentedControlContainer
    }()
    
    fileprivate lazy var navigationTitleLabel: UILabel = {
        let _navigationTitleLabel = UILabel()
        _navigationTitleLabel.text = self.username ?? "{username}"
        _navigationTitleLabel.textColor = UIColor.white
        _navigationTitleLabel.font = UIFont.boldSystemFont(ofSize: 17.0)
        
        return _navigationTitleLabel
    }()
    
    fileprivate var debugTextView: UILabel!
    
    fileprivate var shouldUpdateScrollViewContentFrame = false
    
    deinit {
        self.scrollViews.forEach { (scrollView) in
            scrollView.removeFromSuperview()
        }
        self.scrollViews.removeAll()
        
        print("[ProfileViewController] memeory leak check passed")
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        self.prepareForLayout()
        
        setNeedsStatusBarAppearanceUpdate()
        
        self.prepareViews()
        
        shouldUpdateScrollViewContentFrame = true
    }
    
    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        //    print(profileHeaderView.sizeThatFits(self.mainScrollView.bounds.size))
        self.profileHeaderViewHeight = profileHeaderView.sizeThatFits(self.mainScrollView.bounds.size).height
        
        if self.shouldUpdateScrollViewContentFrame {
            /// 只要第一次view布局完成时，再调整下stickyHeaderContainerView的frame，剩余的情况会在scrollViewDidScrollView:时调整
            self.stickyHeaderContainerView.frame = self.computeStickyHeaderContainerViewFrame()
            self.shouldUpdateScrollViewContentFrame = false
        }
        
        /// 更新profileHeaderView和segmentedControlContainer的frame
        self.profileHeaderView.frame = self.computeProfileHeaderViewFrame()
        let contentOffset = self.mainScrollView.contentOffset
        let navigationLocation = CGRect(x: 0, y: 0, width: stickyHeaderContainerView.bounds.width, height: stickyHeaderContainerView.frame.origin.y - contentOffset.y + stickyHeaderContainerView.bounds.height)
        let navigationHeight = navigationLocation.height - abs(navigationLocation.origin.y)
        let segmentedControlContainerLocationY = stickyheaderContainerViewHeight + profileHeaderViewHeight - navigationHeight
        if contentOffset.y > 0 && contentOffset.y >= segmentedControlContainerLocationY {
            segmentedControlContainer.frame = CGRect(x: 0, y: contentOffset.y + navigationHeight, width: segmentedControlContainer.bounds.width, height: segmentedControlContainer.bounds.height)
        } else {
            segmentedControlContainer.frame = computeSegmentedControlContainerFrame()
        }
        
        /// 更新 子 scrollView的frame
        self.scrollViews.forEach({ (scrollView) in
            scrollView.frame = self.computeTableViewFrame(tableView: scrollView)
            scrollView.isScrollEnabled = false
        })
        
        self.updateMainScrollViewFrame()
        
        self.mainScrollView.scrollIndicatorInsets = computeMainScrollViewIndicatorInsets()
    }
    
    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
}

extension ProfileViewController {
    
    func prepareViews() {
        
        self.view.addSubview(mainScrollView)
        
        mainScrollView.translatesAutoresizingMaskIntoConstraints = false
        mainScrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        mainScrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        mainScrollView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        mainScrollView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        
        // sticker header Container view
        mainScrollView.addSubview(stickyHeaderContainerView)
        
        // Cover Image View
        stickyHeaderContainerView.addSubview(headerCoverView)
        headerCoverView.translatesAutoresizingMaskIntoConstraints = false
        headerCoverView.leadingAnchor.constraint(equalTo: stickyHeaderContainerView.leadingAnchor).isActive = true
        headerCoverView.trailingAnchor.constraint(equalTo: stickyHeaderContainerView.trailingAnchor).isActive = true
        headerCoverView.topAnchor.constraint(equalTo: stickyHeaderContainerView.topAnchor).isActive = true
        headerCoverView.bottomAnchor.constraint(equalTo: stickyHeaderContainerView.bottomAnchor).isActive = true

        
        // blur effect on top of coverImageView
        stickyHeaderContainerView.addSubview(blurEffectView)
        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
        blurEffectView.leadingAnchor.constraint(equalTo: stickyHeaderContainerView.leadingAnchor).isActive = true
        blurEffectView.trailingAnchor.constraint(equalTo: stickyHeaderContainerView.trailingAnchor).isActive = true
        blurEffectView.topAnchor.constraint(equalTo: stickyHeaderContainerView.topAnchor).isActive = true
        blurEffectView.bottomAnchor.constraint(equalTo: stickyHeaderContainerView.bottomAnchor).isActive = true
        
        // 导航标题
        stickyHeaderContainerView.addSubview(navigationTitleLabel)
        navigationTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        navigationTitleLabel.centerXAnchor.constraint(equalTo: stickyHeaderContainerView.centerXAnchor).isActive = true
        navigationTitleLabelBottomConstraint = navigationTitleLabel.bottomAnchor.constraint(equalTo: stickyHeaderContainerView.bottomAnchor, constant: -ALPNavigationTitleLabelBottomPadding)
        navigationTitleLabelBottomConstraint?.isActive = true
        
        
        // 设置进度为0时的导航条标题和导航条详情label的位置 (此时标题和详情label 在headerView的最下面隐藏)
        animateNaivationTitleAt(progress: 0.0)
        
        // 头部视图
        mainScrollView.addSubview(profileHeaderView)
        
        // 分段控制视图的容器视图
        mainScrollView.addSubview(segmentedControlContainer)
        
        // 分段控制视图
        segmentedControlContainer.addSubview(segmentedControl)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.widthAnchor.constraint(equalTo: segmentedControlContainer.widthAnchor, constant: -16.0).isActive = true
        segmentedControl.centerXAnchor.constraint(equalTo: segmentedControlContainer.centerXAnchor).isActive = true
        segmentedControl.centerYAnchor.constraint(equalTo: segmentedControlContainer.centerYAnchor).isActive = true
        
        self.scrollViews = []
        for index in 0..<numberOfSegments() {
            let scrollView = self.scrollView(forSegment: index)
            self.scrollViews.append(scrollView)
            scrollView.isHidden = (index > 0)
            mainScrollView.addSubview(scrollView)
        }
        
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
    
    func computeMainScrollViewIndicatorInsets() -> UIEdgeInsets {
        return UIEdgeInsetsMake(self.computeSegmentedControlContainerFrame().alp_originBottom, 0, 0, 0)
    }
    
    func computeNavigationFrame() -> CGRect {
        return headerCoverView.convert(headerCoverView.bounds, to: self.view)
    }
    
    func computeSegmentedControlContainerFrame() -> CGRect {
//        let rect = computeProfileHeaderViewFrame()
//        return CGRect(x: 0, y: rect.origin.y + rect.height, width: mainScrollView.bounds.width, height: segmentedControlContainerHeight)
        return CGRect(x: 0, y: profileHeaderView.frame.maxY, width: mainScrollView.bounds.width, height: segmentedControlContainerHeight)
        
    }
    
    func updateMainScrollViewFrame() {
        
        let bottomHeight = max(currentScrollView.bounds.height, 800)
        
        self.mainScrollView.contentSize = CGSize(
            width: view.bounds.width,
            height: stickyheaderContainerViewHeight + profileHeaderViewHeight + segmentedControlContainer.bounds.height + bottomHeight)
    }
}

extension ProfileViewController: UIScrollViewDelegate {
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.isEqual(self.mainScrollView) == false {
            return
        }
        let contentOffset = scrollView.contentOffset
        self.debugContentOffset(contentOffset: contentOffset)
        
        // sticky headerCover
        if contentOffset.y <= 0 {
            let bounceProgress = min(1, abs(contentOffset.y) / bouncingThreshold)
            
            let newHeight = abs(contentOffset.y) + self.stickyheaderContainerViewHeight
            
            // adjust stickyHeader frame
            self.stickyHeaderContainerView.frame = CGRect(
                x: 0,
                y: contentOffset.y,
                width: mainScrollView.bounds.width,
                height: newHeight)
            
            // blurring effect amplitude
            self.blurEffectView.alpha = min(1, bounceProgress * 2)
            
            // scaling effect
            let scalingFactor = 1 + min(log(bounceProgress + 1), 2)
            //      print(scalingFactor)
            self.headerCoverView.transform = CGAffineTransform(scaleX: scalingFactor, y: scalingFactor)
            
            // adjust mainScrollView indicator insets
            var baseInset = computeMainScrollViewIndicatorInsets()
            baseInset.top += abs(contentOffset.y)
            self.mainScrollView.scrollIndicatorInsets = baseInset
            
            self.mainScrollView.bringSubview(toFront: self.profileHeaderView)
        } else {
            
            // anything to be set if contentOffset.y is positive
            self.blurEffectView.alpha = 0
            self.mainScrollView.scrollIndicatorInsets = computeMainScrollViewIndicatorInsets()
        }
        
        // Universal
        // applied to every contentOffset.y
        let scaleProgress = max(0, min(1, contentOffset.y / self.scrollToScaleDownProfileIconDistance))
        self.profileHeaderView.animator(t: scaleProgress)
        
        if contentOffset.y > 0 {
            
            // When scroll View reached the threshold
            if contentOffset.y >= scrollToScaleDownProfileIconDistance {
                self.stickyHeaderContainerView.frame = CGRect(x: 0, y: contentOffset.y - scrollToScaleDownProfileIconDistance, width: mainScrollView.bounds.width, height: stickyheaderContainerViewHeight)
                
                // bring stickyHeader to the front
                self.mainScrollView.bringSubview(toFront: self.stickyHeaderContainerView)
            } else {
                self.mainScrollView.bringSubview(toFront: self.profileHeaderView)
                self.stickyHeaderContainerView.frame = computeStickyHeaderContainerViewFrame()
            }
            
            // Sticky Segmented Control
            let navigationLocation = CGRect(x: 0, y: 0, width: stickyHeaderContainerView.bounds.width, height: stickyHeaderContainerView.frame.origin.y - contentOffset.y + stickyHeaderContainerView.bounds.height)
            let navigationHeight = navigationLocation.height - abs(navigationLocation.origin.y)
            let segmentedControlContainerLocationY = stickyheaderContainerViewHeight + profileHeaderViewHeight - navigationHeight
            
            if contentOffset.y > 0 && contentOffset.y >= segmentedControlContainerLocationY {
                segmentedControlContainer.frame = CGRect(x: 0, y: contentOffset.y + navigationHeight, width: segmentedControlContainer.bounds.width, height: segmentedControlContainer.bounds.height)
            } else {
                segmentedControlContainer.frame = computeSegmentedControlContainerFrame()
            }
            
            // Override
            // 当滚动视图到达标题标签的顶部边缘时
            if let titleLabel = profileHeaderView.nicknameLabel, let usernameLabel = profileHeaderView.usernameLabel  {
                
                // titleLabel location relative to self.view
                let titleLabelLocationY = stickyheaderContainerViewHeight - 35
                
                let totalHeight = titleLabel.bounds.height + usernameLabel.bounds.height + 35
                let detailProgress = max(0, min((contentOffset.y - titleLabelLocationY) / totalHeight, 1))
                blurEffectView.alpha = detailProgress
                animateNaivationTitleAt(progress: detailProgress)
            }
        }
        //  在任何情况下 Segmented control 总是显示在最上面
        self.mainScrollView.bringSubview(toFront: segmentedControlContainer)
    }
}

// MARK: Animators
extension ProfileViewController {
    /// 更新导航条上面titleLabel的位置
    func animateNaivationTitleAt(progress: CGFloat) {
        
        let totalDistance: CGFloat = self.navigationTitleLabel.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height + ALPNavigationTitleLabelBottomPadding

        if progress >= 0 {
            let distance = (1 - progress) * totalDistance
            navigationTitleLabelBottomConstraint?.constant = -ALPNavigationTitleLabelBottomPadding + distance
        }
    }
}

/// status bar
extension ProfileViewController {
    override open var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override open var prefersStatusBarHidden: Bool {
        return false
    }
}

// Table View Switching

extension ProfileViewController {
    func updateTableViewContent() {
        print("currentIndex did changed \(self.currentIndex)")
    }
    
    @objc internal func segmentedControlValueDidChange(sender: AnyObject?) {
        self.currentIndex = self.segmentedControl.selectedSegmentIndex
        
        let scrollViewToBeShown: UIScrollView! = self.currentScrollView
        
        self.scrollViews.forEach { (scrollView) in
            scrollView?.isHidden = scrollView != scrollViewToBeShown
        }
        
        scrollViewToBeShown.frame = self.computeTableViewFrame(tableView: scrollViewToBeShown)
        self.updateMainScrollViewFrame()
        
        // auto scroll to top if mainScrollView.contentOffset > navigationHeight + segmentedControl.height
        let navigationHeight = self.scrollToScaleDownProfileIconDistance
        let threshold = self.computeProfileHeaderViewFrame().alp_originBottom - navigationHeight
        
        if mainScrollView.contentOffset.y > threshold {
            self.mainScrollView.setContentOffset(CGPoint(x: 0, y: threshold), animated: false)
        }
    }
}

extension ProfileViewController {
    
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
            debugTextView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 16.0).isActive = true
            debugTextView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 16.0).isActive = true
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

