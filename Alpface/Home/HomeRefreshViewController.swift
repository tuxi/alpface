//
//  HomeRefreshViewController.swift
//  Alpface
//
//  Created by xiaoyuan on 2018/10/10.
//  Copyright © 2018 alpface. All rights reserved.
//

import UIKit
import MBProgressHUD

class HomeRefreshViewController: UIViewController {
    
    enum HomeRefreshStatus {
        // 正常状态
        case normal
        // 下拉
        case down
        // 上拉
        case up
        // 正在刷新中
        case refreshing
    }
    
    /// 向下拖拽最大点-刷新临界值，到达时即可刷新
    private let maxDistance: CGFloat = 60.0
    
    /// 记录手指滑动状态
    public var refreshStatus: HomeRefreshStatus = .normal
    
    /// 可以刷新的回调
    fileprivate var refreshCallback: (() -> (Void))?
    fileprivate var startPoint: CGPoint = CGPoint.zero
    fileprivate var previousPoint: CGPoint = CGPoint.zero
    
    fileprivate var scrollView: UIScrollView?
    fileprivate var mainNavigationBar: UIView?
    
    fileprivate var panGestureOfTouchView: UIPanGestureRecognizer?
    fileprivate var isSendFeedBackGenertor: Bool = false
    fileprivate var animationStyle: HomeRefreshAnimationStyle = .circle
    
    fileprivate lazy var refreshView: HomeRefreshNavigitionView = {
        var navigationHeight: CGFloat = 66.0-20.0; // 20.0为statusBar高度 非iPhoneX 主页不显示statusBar
        if AppUtils.isIPhoneX() {
            navigationHeight = 88.0
        }
        let view = HomeRefreshNavigitionView(frame: CGRect.init(x: 0, y: 0, width: self.view.frame.size.width, height: navigationHeight))
        view.backgroundColor = UIColor.clear
        view.alpha = 0.0
        return view
    }()
    
    fileprivate lazy var feedBackGenertor:UIImpactFeedbackGenerator = {
        let feedBackGenertor = UIImpactFeedbackGenerator(style: .medium)
        return feedBackGenertor
    }()
    
    public func addHeaderRefresh(_ scrollView: UIScrollView,
                                 navigationBar: UIView,
                                 animationStyle: HomeRefreshAnimationStyle = .eye,
                                 callBack: @escaping ()->(Void)) {
        if scrollView.isKind(of: UIScrollView.classForCoder()) == false {
            return
        }
        
        self.refreshCallback = callBack
        self.animationStyle = animationStyle
        self.scrollView = scrollView
        //去掉弹性效果
        scrollView.bounces = false
        self.view.addSubview(scrollView)
        
        let panGes = UIPanGestureRecognizer(target: self, action: #selector(panGestureOnTouchView(pan:)))
        scrollView.addGestureRecognizer(panGes)
        panGes.delegate = self
        panGestureOfTouchView = panGes
        
        self.view.addSubview(self.refreshView)
        
        self.mainNavigationBar = navigationBar
        self.view.addSubview(navigationBar)
        
        // 添加观察者
        scrollView.addObserver(self, forKeyPath: "contentOffset", options: [.old, .new], context: nil)
        // 触摸结束恢复原位-松手回弹
        scrollView.contentOffset = CGPoint.zero
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "contentOffset" {
            if let scrollView = self.scrollView {
                if scrollView.contentOffset.y <= 0 {

                }
            }
        }
        
    }
    
    @objc fileprivate func panGestureOnTouchView(pan: UIPanGestureRecognizer) {
        switch pan.state {
        case .began:
            panGestureBeganOnTouchView(pan: pan)
            break
        case .changed:
            panGestureMovedOnTouchView(pan: pan)
            break
        case .cancelled:
            panGestureCancelledOnTouchView(pan: pan)
            break
        case .ended:
            panGestureEndOnTouchView(pan: pan)
            break
        default:
            break
            
        }
    }
    
    fileprivate func panGestureBeganOnTouchView(pan: UIPanGestureRecognizer) {
        guard let scrollView = self.scrollView else {
            return
        }
        self.isSendFeedBackGenertor = false
        
        if scrollView.contentOffset.y <= 0.0 && self.refreshStatus == .normal {
            // 当scrollView停在顶部并且是正常状态才记录起始触摸点，防止页面在刷新时用户再次向下拖拽页面造成多次下拉刷新
            startPoint = pan.location(in: self.view)
        }
        else {
            // 在底部
            if isScrollInBottom() {
                startPoint = pan.location(in: self.view)
            }
        }
    }
    
    fileprivate func panGestureMovedOnTouchView(pan: UIPanGestureRecognizer) {
        if startPoint.equalTo(.zero) {
            //没记录到起始触摸点就返回
            return
        }
        
        guard let scrollView = self.scrollView else {
            return
        }
        
        let currentPoint = pan.location(in: self.view)
        
        let moveDistance = currentPoint.y - startPoint.y
        if self.isScrollInTop() {
            // 根据触摸点移动方向判断用户是下拉还是上拉
            if moveDistance > 0 && moveDistance < self.maxDistance {
                self.refreshStatus = .down
                //只判断当前触摸点与起始触摸点y轴方向的移动距离，只要y比起始触摸点的y大就证明是下拉，这中间可能存在先下拉一段距离没松手又上滑了一点的情况
                let progress = moveDistance/self.maxDistance
                //moveDistance>0则是下拉刷新，在下拉距离小于MaxDistance的时候对_refreshNavigitionView和_mainViewNavigitionView进行透明度、frame移动操作
                self.refreshView.alpha = progress
                var frame = self.refreshView.frame
                frame.origin.y = moveDistance
                self.refreshView.frame = frame
                if let navigationBar = self.mainNavigationBar {
                    navigationBar.alpha = 1 - progress
                    navigationBar.frame = frame
                }
                
                //在整体判断为下拉刷新的情况下，还需要对上一个触摸点和当前触摸点进行比对，判断圆圈旋转方向，下移逆时针，上移顺时针
                if animationStyle == .circle {
                    let previousPoint = self.previousPoint // 上一个坐标
                    if currentPoint.y > previousPoint.y {
                        self.refreshView.animationImageView.transform = self.refreshView.transform.rotated(by: -0.08)
                    }
                    else {
                        self.refreshView.animationImageView.transform = self.refreshView.transform.rotated(by: 0.08)
                    }
                }
                else if animationStyle == .eye {
                    self.refreshView.animation(progress: progress)
                }
                
            }
            else if moveDistance >= self.maxDistance {
                self.refreshStatus = .down
                //下拉到最大点之后，_refreshNavigitionView和_mainViewNavigitionView就保持透明度和位置，不再移动
                self.refreshView.alpha = 1
                if let navigationBar = self.mainNavigationBar {
                    navigationBar.alpha = 0.0
                }
            } else if moveDistance < 0.0 {
                self.refreshStatus = .up
                // moveDistance<0则是上拉 根据移动距离修改tableview.contentOffset，模仿tableview的拖拽效果，一旦执行了这行代码，下个触摸点就会走外层else代码
                scrollView.contentOffset = CGPoint(x: 0, y: -moveDistance)
            }
            
            if self.refreshView.alpha == 1.0 {
                self.sendFeedBackGenertor()
            }
        }
            
        else if self.isScrollInBottom() {
            self.refreshStatus = .up;
            // scrollView被上拉了
            // 触发上拉加载更多
//            self.scrollView?.contentOffset = CGPoint(x: 0, y: -moveDistance)
            self.view.xy_show("已触发上拉加载更多，功能还未完成")
        }
        
        previousPoint = currentPoint
    }

    fileprivate func panGestureEndOnTouchView(pan: UIPanGestureRecognizer) {
        let point = pan.location(in: self.view)
        self.updateRefresh(point)
    }
    
    fileprivate func panGestureCancelledOnTouchView(pan: UIPanGestureRecognizer) {
        let point = pan.location(in: self.view)
        self.updateRefresh(point)
    }

    
    fileprivate func updateRefresh(_ currentPoint: CGPoint) {
        let moveDistance = currentPoint.y - startPoint.y
        if moveDistance == 0 {
            
        }
        
        // 清除起始触摸点
        startPoint = CGPoint.zero
        
        UIView.animate(withDuration: 0.3) {
         var frame = self.refreshView.frame
            frame.origin.y = 0.0
            self.refreshView.frame = frame
            if let navigationBar = self.mainNavigationBar {
                navigationBar.frame = frame
            }
        }
        
        //_refreshNavigitionView.alpha=1的时候说明用户拖拽到最大点，可以开始刷新页面
        if self.refreshView.alpha == 1.0 {
            self.beginRefresh()
        }
        else {
            resetRefresh()
        }
    }
    
    fileprivate func sendFeedBackGenertor() {
        if isSendFeedBackGenertor == false {
            self.feedBackGenertor.impactOccurred()
            isSendFeedBackGenertor = true
        }
    }
    
    /// 恢复为正常状态
    fileprivate func resetRefresh() {
        self.refreshStatus = .normal
        UIView.animate(withDuration: 0.3) {
            self.refreshView.alpha = 0.0
            self.mainNavigationBar?.alpha = 1.0
        }
    }
    
    /// 开始刷新
    public func beginRefresh() {
        // 正常刷新中禁止触发
        if self.refreshStatus == .refreshing {
            return
        }
        self.refreshStatus = .refreshing
        // 刷新刷新控件
        self.refreshView.startAnimation(style: self.animationStyle)
        if let callback = self.refreshCallback {
            callback()
        }
    }
    
    /// 结束刷新
    public func endRefresh() {
        self.resetRefresh()
        self.refreshView.stopAnimation()
    }
    
    /// scrollView是否滚动到了底部
    private func isScrollInBottom() -> Bool {
        // 当scrollView上滑动到底部时，触发上拉刷新
        if let scrollView = self.scrollView {
            let height: CGFloat = scrollView.frame.size.height
            let contentOffsetY: CGFloat = scrollView.contentOffset.y
            let bottomOffset: CGFloat = scrollView.contentSize.height - contentOffsetY
            if (bottomOffset <= height)    {
                //在最底部
                return true
            }
        }
        return false
    }
    
    /// scrollView是否滚动到了顶部
    private func isScrollInTop() -> Bool {
        if let scrollView = self.scrollView {
            if scrollView.contentOffset.y <= 0  {
                // 滑到顶部，下拉刷新
                return true
            }
        }
        
        return false
    }
    
    deinit {
        if let scrollView = self.scrollView {
            scrollView.removeObserver(self, forKeyPath: "contentOffset")
        }
    }

}

extension HomeRefreshViewController: UIGestureRecognizerDelegate {
    
    /// 决定添加到scrollView的手势触发时机
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let pan = gestureRecognizer as? UIPanGestureRecognizer else {
            return true
        }
        if pan != self.panGestureOfTouchView {
            return true
        }
        
        if self.refreshStatus == .refreshing {
            return false
        }
        
        if pan.state == .began || pan.state == .possible {
            
            let velocity = pan.velocity(in: self.view)
            let currentPoint = pan.translation(in: self.view)
            // y轴偏移量大，说明是上下移动，此时如果手势是gestureRecognizer时，让其不能响应
            if fabs(currentPoint.y) > fabs(currentPoint.x) {
                // 上下滑动
                if velocity.y > 0 {
                    // 下
                    if isScrollInTop() {
                        return true
                    }
                }
                else {
                    // 上
                    // 当scrollView上滑动到底部时，触发上拉刷新
                    if self.isScrollInBottom() {
                        return true
                    }
                    
                    return false
                }
            }
            else {
                // 左右滑动
                if velocity.x > 0 {
                    // 向右滑动
                    return false
                }
                else {
                    // 向左滑动
                    return false
                }
            }
        }
        return false
    }
}
