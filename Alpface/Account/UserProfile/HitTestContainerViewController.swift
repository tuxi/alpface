//
//  HitTestContainerViewController.swift
//  UserProfileExample
//
//  Created by swae on 2018/4/5.
//  Copyright © 2018年 alpface. All rights reserved.
//

import UIKit


@objc protocol HitTestContainerViewControllerDelegate: NSObjectProtocol {
    /// 页面完全显示时调用
    @objc optional func hitTestContainerViewController(_ containerViewController: HitTestContainerViewController, didPageDisplay controller: UIViewController, forItemAt index: Int) -> Void
    /// 页面即将显示时调用
    @objc optional func hitTestContainerViewController(_ containerViewController: HitTestContainerViewController, willPageDisplay controller: UIViewController, forItemAt index: Int) -> Void
    
    /// container scrollView 自带滑动手势状态发送改变时调用
    @objc optional func hitTestContainerViewController(_ containerViewController: HitTestContainerViewController, handlerContainerPanGestureState panGesture: UIPanGestureRecognizer) -> Void

    /// child scrollView 滚动时调用
    @objc optional func hitTestContainerViewController(_ containerViewController: HitTestContainerViewController, childScrollViewDidScroll scrollView: UIScrollView) -> Void
    
    /// child scrollView 离开顶部时调用 (从上往下滚动时)
    @objc optional func hitTestContainerViewController(_ containerViewController: HitTestContainerViewController, childScrollViewLeaveTop scrollView: UIScrollView) -> Void
}

//class HitTestContainerCollectionView: UICollectionView {
//    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
//
//        let pan : UIPanGestureRecognizer = gestureRecognizer as! UIPanGestureRecognizer
//
//        if pan.isEqual(self.panGestureRecognizer) == false {
//            return true
//        }
//
//        let point = pan.translation(in: self)
//        if pan.state == .began || pan.state == .possible {
//            // y轴偏移量大，说明是上下移动, 上下滑动，让其不能响应手势
//            if fabs(point.y) >= fabs(point.x) {
//                return false
//            }
//            else {
//                // 左右滑动，如果此时collectionView的contentOffset.x < 0，
//                // 并且 手指在collectionView上的x轴偏移量大于0，说明向左移动，此时让其不能响应手势
//                if self.contentOffset.x <= 0 && point.x > 0 {
//                    return false
//                }
//            }
//        }
//
//        return true
//    }
//}

class HitTestContainerViewController: UIViewController {
    
    fileprivate var pageViewController: UIPageViewController!
    fileprivate var currentIndex: Int = -1
    
    public var viewControllers: [BaseProfileViewChildControllr]? {
        didSet {
            self.show(page: self.initialPage, animated: true)
        }
    }
    
    public weak var delegate: HitTestContainerViewControllerDelegate?
    fileprivate weak var scrollView: UIScrollView?
    
    /// 子scrollView是否可以滚动
    public var shouldScrollForCurrentChildScrollView: Bool?
    
    public func displayViewController() -> BaseProfileViewChildControllr? {
        if self.currentIndex == -1 {
            return nil
        }
        return self.viewControllerAtIndex(self.currentIndex)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupUI()
    }
    
    fileprivate func setupUI() {
        
        pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pageViewController.dataSource = self
        pageViewController.delegate = self
        pageViewController.view.backgroundColor = UIColor.black
        addChild(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.didMove(toParent: self)
        
    
        pageViewController!.view.translatesAutoresizingMaskIntoConstraints = false
        pageViewController!.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        pageViewController!.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        pageViewController!.view.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        pageViewController!.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        
        for subView: UIView in pageViewController.view.subviews {
            if subView.isKind(of: UIScrollView.classForCoder()) {
                let tempScrollView = subView as? UIScrollView
                tempScrollView?.addObserver(self, forKeyPath: "panGestureRecognizer.state", options: .new, context: nil)
                self.scrollView = tempScrollView
                tempScrollView?.isScrollEnabled = false
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    public var initialPage = 0
    
    fileprivate func viewControllerAtIndex(_ index: Int) -> BaseProfileViewChildControllr? {
        guard let controllers = self.viewControllers else {
            return nil
        }
        if controllers.count == 0 || index >= controllers.count {
            return nil
        }
        
        return controllers[index]
    }
    
    fileprivate func indexOfViewController(_ controller: UIViewController) -> Int {
        guard let viewControllers = self.viewControllers else {
            return NSNotFound
        }
        var idx = 0
        for item in viewControllers {
            if item == controller {
                return idx
            }
            idx += 1
        }
        return NSNotFound
    }
    
    public func show(page index: NSInteger, animated: Bool, completion: ((_ finished: Bool) -> Void)? = nil) {
        if currentIndex == index {
            return
        }
        guard let controllers = self.viewControllers else {
            return
        }
        if index >= controllers.count {
            return
        }
        let direction: UIPageViewController.NavigationDirection = (index > currentIndex) ? .forward : .reverse
        let controller = controllers[index]
        self.currentIndex = index
        pageViewController.setViewControllers([controller], direction: direction, animated: animated, completion: completion)
        
    }
    deinit {
        scrollView?.removeObserver(self, forKeyPath: "panGestureRecognizer.state")
        
    }

}

extension HitTestContainerViewController {
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let scrollView = self.scrollView else {
            return
        }
        let currentScrollView = object as! UIScrollView
        if keyPath == "panGestureRecognizer.state" && currentScrollView == scrollView {
            if let delegate = delegate {
                if delegate.responds(to: #selector(HitTestContainerViewControllerDelegate.hitTestContainerViewController(_:handlerContainerPanGestureState:))) {
                    delegate.hitTestContainerViewController!(self, handlerContainerPanGestureState: scrollView.panGestureRecognizer)
                }
            }
        }
        else if keyPath == "contentOffset" {
            guard let delegate = delegate else { return }
            let childScrollView = object as! UIScrollView
            if delegate.responds(to: #selector(HitTestContainerViewControllerDelegate.hitTestContainerViewController(_:childScrollViewDidScroll:))) {
                delegate.hitTestContainerViewController!(self, childScrollViewDidScroll: childScrollView)
            }
            
            if self.shouldScrollForCurrentChildScrollView == false {
                if childScrollView.contentOffset.equalTo(.zero) == false {
                    childScrollView.contentOffset = .zero
                }
            }
            
            /// 子scrollView 离开其顶部时，子不能滚动，通知代理main scrollView 可以滚动
            if childScrollView.contentOffset.y <= 0 {
                if delegate.responds(to: #selector(HitTestContainerViewControllerDelegate.hitTestContainerViewController(_:childScrollViewLeaveTop:))) {
                    delegate.hitTestContainerViewController!(self, childScrollViewLeaveTop: childScrollView)
                }
                shouldScrollForCurrentChildScrollView = false
                if childScrollView.contentOffset.equalTo(.zero) == false {
                    childScrollView.contentOffset = .zero
                }
            }
        }
    }
}

extension HitTestContainerViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        guard completed else {
            return
        }
        
        guard let viewController = pageViewController.viewControllers?.last else {
            return
        }
        
        let index = indexOfViewController(viewController)
        if index == NSNotFound {
            return
        }
        currentIndex = index
        if let delegate = delegate {
            if delegate.responds(to: #selector(HitTestContainerViewControllerDelegate.hitTestContainerViewController(_:didPageDisplay:forItemAt:))) {
                delegate.hitTestContainerViewController!(_: self, didPageDisplay: viewController, forItemAt: index)
            }
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        guard let vc = pendingViewControllers.first else { return }
        let index = self.indexOfViewController(vc)
        if let delegate = delegate {
            if delegate.responds(to: #selector(HitTestContainerViewControllerDelegate.hitTestContainerViewController(_:willPageDisplay:forItemAt:))) {
                delegate.hitTestContainerViewController!(_: self, willPageDisplay: vc, forItemAt: index)
            }
        }

    }
}

extension HitTestContainerViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        var index = self.indexOfViewController(viewController)
        
        if (index == 0) || (index == NSNotFound) {
            return nil
        }
        
        index -= 1
        
        return viewControllerAtIndex(index)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        var index = self.indexOfViewController(viewController)
        
        if index == NSNotFound {
            return nil
        }
        
        index += 1
        
        return viewControllerAtIndex(index)
    }
    
    
}
