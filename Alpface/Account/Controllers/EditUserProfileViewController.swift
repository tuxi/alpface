//
//  EditUserProfileViewController.swift
//  Alpface
//
//  Created by swae on 2018/4/10.
//  Copyright © 2018年 alpface. All rights reserved.
//

import UIKit

class EditUserProfileViewController: UIViewController {
    
    fileprivate lazy var mainScrollView: UITableView = {
        let _mainScrollView = HitTestScrollView(frame: self.view.bounds, style: .plain)
        _mainScrollView.delegate = self
        _mainScrollView.showsHorizontalScrollIndicator = false
        _mainScrollView.backgroundColor = UIColor.white
        _mainScrollView.separatorStyle = .none
        _mainScrollView.scrollsToTop = true
        return _mainScrollView
    }()
    
    open lazy var profileHeaderView: ProfileHeaderView = {
        let _profileHeaderView = ProfileHeaderView(frame: CGRect.init(x: 0, y: 0, width: self.mainScrollView.frame.width, height: 220))
        return _profileHeaderView
    }()
    
    /// 下拉头部放大控件 (头部背景视图)
    fileprivate lazy var stickyHeaderContainerView: StickyHeaderContainerView = {
        let _stickyHeaderContainer = StickyHeaderContainerView()
        return _stickyHeaderContainer
    }()
    
    fileprivate lazy var tableHeaderView: UIView = {
        let view = UIView()
        return view
    }()
    
    open lazy var navigationTitleLabel: UILabel = {
        let _navigationTitleLabel = UILabel()
        _navigationTitleLabel.text = "username"
        _navigationTitleLabel.textColor = UIColor.white
        _navigationTitleLabel.font = UIFont.boldSystemFont(ofSize: 17.0)
        
        return _navigationTitleLabel
    }()
    
    /// 头部描述用户信息视图的高度(不固定值)
    open var profileHeaderViewHeight: CGFloat = 160
    /// 头部背景视图最小的高度(固定值)
    open let navigationMinHeight : CGFloat = 65.0
    open var navigationTitleLabelBottomConstraint : NSLayoutConstraint?
    open let bouncingThreshold: CGFloat = 100
    /// scrollView 向上滚动时时，固定头部背景视图，此属性为scrollView滚动到contentView.y==这个偏移量时，就固定头部背景视图，将其作为当导航条展示 (固定值)
    open func scrollToScaleDownProfileIconDistance() -> CGFloat {
        return stickyheaderContainerViewHeight - navigationMinHeight
    }
    
    
    /// 更新table header 布局，高度是计算出来的，所以当header上的内容发生改变时，应该执行一次更新header布局
    fileprivate var needsUpdateHeaderLayout = false
    open func setNeedsUpdateHeaderLayout() {
        self.needsUpdateHeaderLayout = true
    }
    open func updateHeaderLayoutIfNeeded() {
        if self.needsUpdateHeaderLayout == true {
            self.profileHeaderViewHeight = profileHeaderView.sizeThatFits(self.mainScrollView.bounds.size).height
            
            /// 只要第一次view布局完成时，再调整下stickyHeaderContainerView的frame，剩余的情况会在scrollViewDidScrollView:时调整
            self.stickyHeaderContainerView.frame = self.computeStickyHeaderContainerViewFrame()
            
            
            /// 更新profileHeaderView和segmentedControlContainer的frame
            self.profileHeaderView.frame = self.computeProfileHeaderViewFrame()
            
            tableHeaderView.frame = CGRect.init(x: 0, y: 0, width: 0, height: stickyHeaderContainerView.frame.height + profileHeaderView.frame.size.height)
            self.mainScrollView.tableHeaderView = tableHeaderView
            profileHeaderView.frame = self.computeProfileHeaderViewFrame()
            self.needsUpdateHeaderLayout = false
        }
    }
    
    func computeStickyHeaderContainerViewFrame() -> CGRect {
        return CGRect(x: 0, y: 0, width: mainScrollView.bounds.width, height: stickyheaderContainerViewHeight)
    }
    
    func computeProfileHeaderViewFrame() -> CGRect {
        return CGRect(x: 0, y: computeStickyHeaderContainerViewFrame().origin.y + stickyheaderContainerViewHeight, width: mainScrollView.bounds.width, height: profileHeaderViewHeight)
    }
    
    func computeNavigationFrame() -> CGRect {
        let navigationHeight:CGFloat = max(stickyHeaderContainerView.frame.origin.y - self.mainScrollView.contentOffset.y + stickyHeaderContainerView.bounds.height, navigationMinHeight)
        
        let navigationLocation = CGRect(x: 0, y: 0, width: stickyHeaderContainerView.bounds.width, height: navigationHeight)
        return navigationLocation
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.prepareViews()
    }
    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        updateHeaderLayoutIfNeeded()
    }
    
    @objc fileprivate func backAction() {
        self.dismiss(animated: true, completion: nil)
    }
    
}
extension EditUserProfileViewController {
    func prepareViews() {
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "取消", style: .plain, target: self, action: #selector(backAction))
        self.navigationItem.title = "编辑个人资料"
        self.view.backgroundColor = UIColor.white
        
        self.view.addSubview(mainScrollView)
        
        mainScrollView.translatesAutoresizingMaskIntoConstraints = false
        mainScrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        mainScrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        mainScrollView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        mainScrollView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        
        tableHeaderView.addSubview(stickyHeaderContainerView)
        tableHeaderView.addSubview(profileHeaderView)
        
        mainScrollView.tableHeaderView = tableHeaderView
        
        
        // 导航标题
        stickyHeaderContainerView.addSubview(navigationTitleLabel)
        navigationTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        navigationTitleLabel.centerXAnchor.constraint(equalTo: stickyHeaderContainerView.centerXAnchor).isActive = true
        navigationTitleLabelBottomConstraint = navigationTitleLabel.bottomAnchor.constraint(equalTo: stickyHeaderContainerView.bottomAnchor, constant: -ALPNavigationTitleLabelBottomPadding)
        navigationTitleLabelBottomConstraint?.isActive = true
        
        
        // 设置进度为0时的导航条标题和导航条详情label的位置 (此时标题和详情label 在headerView的最下面隐藏)
        animateNaivationTitleAt(progress: 0.0)
        setNeedsUpdateHeaderLayout()
    }
    
}

extension EditUserProfileViewController: UITableViewDelegate {
    
    /// scrollView滚动时调用
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView.isEqual(self.mainScrollView) == false {
            return
        }
        let contentOffset = scrollView.contentOffset
        
        // 当向下滚动时，固定头部视图
        if contentOffset.y <= 0 {
            let bounceProgress = min(1, abs(contentOffset.y) / bouncingThreshold)
            
            let newHeight = abs(contentOffset.y) + stickyheaderContainerViewHeight
            
            // 调整 stickyHeader 的 frame
            self.stickyHeaderContainerView.frame = CGRect(
                x: 0,
                y: contentOffset.y,
                width: mainScrollView.bounds.width,
                height: newHeight)
            
            // 更新blurEffectView的透明度
            self.stickyHeaderContainerView.blurEffectView.alpha = min(1, bounceProgress * 2)
            
            // 更新headerCoverView的缩放比例
            let scalingFactor = 1 + min(log(bounceProgress + 1), 2)
            //      print(scalingFactor)
            self.stickyHeaderContainerView.headerCoverView.transform = CGAffineTransform(scaleX: scalingFactor, y: scalingFactor)
            
        } else {
            
            self.stickyHeaderContainerView.blurEffectView.alpha = 0
        }
        
        // 普通情况时，适用于contentOffset.y改变时的更新
        let scaleProgress = max(0, min(1, contentOffset.y / self.scrollToScaleDownProfileIconDistance()))
        self.profileHeaderView.animator(t: scaleProgress)
        
        if contentOffset.y > 0 {
            
            // 当scrollView滚动到达阈值时scrollToScaleDownProfileIconDistance
            if contentOffset.y >= scrollToScaleDownProfileIconDistance() {
                self.stickyHeaderContainerView.frame = CGRect(x: 0, y: contentOffset.y - scrollToScaleDownProfileIconDistance(), width: mainScrollView.bounds.width, height: stickyheaderContainerViewHeight)
                // 当scrollView 的 segment顶部 滚动到scrollToScaleDownProfileIconDistance时(也就是导航底部及以上位置)，让stickyHeaderContainerView显示在最上面，防止被profileHeaderView遮挡
                tableHeaderView.bringSubview(toFront: self.stickyHeaderContainerView)
                
            } else {
                // 当scrollView 的 segment顶部 滚动到导航底部以下位置，让profileHeaderView显示在最上面,防止用户头像被遮挡
                self.stickyHeaderContainerView.frame = computeStickyHeaderContainerViewFrame()
                tableHeaderView.bringSubview(toFront: self.profileHeaderView)
            }
            
            // 当滚动视图到达标题标签的顶部边缘时
            let titleLabel = profileHeaderView.usernameLabel
            let nicknameLabel = profileHeaderView.nicknameLabel
            
            //  titleLabel 相对于控制器view的位置
            let titleLabelLocationY = stickyheaderContainerViewHeight - 35
            
            let totalHeight = titleLabel.bounds.height + nicknameLabel.bounds.height + 35
            let detailProgress = max(0, min((contentOffset.y - titleLabelLocationY) / totalHeight, 1))
            self.stickyHeaderContainerView.blurEffectView.alpha = detailProgress
            animateNaivationTitleAt(progress: detailProgress)
            
        }
        
    }
    
}
// MARK: Animators
extension EditUserProfileViewController {
    /// 更新导航条上面titleLabel的位置
    func animateNaivationTitleAt(progress: CGFloat) {
        
        let totalDistance: CGFloat = self.navigationTitleLabel.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height + ALPNavigationTitleLabelBottomPadding
        
        if progress >= 0 {
            let distance = (1 - progress) * totalDistance
            navigationTitleLabelBottomConstraint?.constant = -ALPNavigationTitleLabelBottomPadding + distance
        }
    }
}
