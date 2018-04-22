//
//  HitTestContainerViewController.swift
//  UserProfileExample
//
//  Created by swae on 2018/4/5.
//  Copyright © 2018年 alpface. All rights reserved.
//

import UIKit

@objc(HitTestContainerViewCollectionViewCell)
class HitTestContainerViewCollectionViewCell: UICollectionViewCell {
    
    fileprivate var view: UIView? {
        didSet {
            view?.backgroundColor = UIColor.white
            if view != oldValue {
                oldValue?.removeFromSuperview()
                guard let v = view else { return }
                self.contentView.addSubview(v)
                v.translatesAutoresizingMaskIntoConstraints = false
                v.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor).isActive = true
                v.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor).isActive = true
                v.topAnchor.constraint(equalTo: self.contentView.topAnchor).isActive = true
                v.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor).isActive = true
            }
        }
    }
}

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

class HitTestContainerCollectionView: UICollectionView {
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        let pan : UIPanGestureRecognizer = gestureRecognizer as! UIPanGestureRecognizer
        
        if pan.isEqual(self.panGestureRecognizer) == false {
            return true
        }
        
        let point = pan.translation(in: self)
        if pan.state == .began || pan.state == .possible {
            // y轴偏移量大，说明是上下移动, 上下滑动，让其不能响应手势
            if fabs(point.y) >= fabs(point.x) {
                return false
            }
            else {
                // 左右滑动，如果此时collectionView的contentOffset.x < 0，
                // 并且 手指在collectionView上的x轴偏移量大于0，说明向左移动，此时让其不能响应手势
                if self.contentOffset.x <= 0 && point.x > 0 {
                    return false
                }
            }
        }
        
        return true
    }
}

class HitTestContainerViewController: UIViewController {
    
    public var viewControllers: [ProfileViewChildControllerProtocol]? {
        didSet {
            let keyPath = "contentOffset"
            oldValue?.forEach({ (controller) in
                controller.childScrollView()?.removeObserver(self, forKeyPath: keyPath)
            })
            viewControllers?.forEach({ (controller) in
                let c = controller
                c.childScrollView()?.addObserver(self, forKeyPath: keyPath, options: .new, context: nil)
            })
        }
    }
    
    public weak var delegate: HitTestContainerViewControllerDelegate?
    
    /// 子scrollView是否可以滚动
    public var shouldScrollForCurrentChildScrollView: Bool?
    
    fileprivate static let cellIfentifier: String = "HitTestContainerViewCollectionViewCell"
    
    public lazy var collectionView: HitTestContainerCollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.scrollDirection = .horizontal
        let view = HitTestContainerCollectionView(frame: .zero, collectionViewLayout: flowLayout)
        view.delegate = self
        view.dataSource = self
        view.register(HitTestContainerViewCollectionViewCell.classForCoder(), forCellWithReuseIdentifier: HitTestContainerViewController.cellIfentifier)
        view.isPagingEnabled = true
        view.backgroundColor = UIColor.white
        view.addObserver(self, forKeyPath: "panGestureRecognizer.state", options: .new, context: nil)
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupUI()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let childController = self.displayViewController() {
            childController.beginAppearanceTransition(true, animated: true)
        }
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let childController = self.displayViewController() {
            childController.endAppearanceTransition()
        }
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let childController = self.displayViewController() {
            childController.beginAppearanceTransition(false, animated: true)
        }
    }
    
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if let childController = self.displayViewController() {
            childController.endAppearanceTransition()
        }
    }
    
    fileprivate func setupUI() {
        self.view.addSubview(self.collectionView)
        self.collectionView.translatesAutoresizingMaskIntoConstraints = false
        self.collectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.collectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        self.collectionView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.collectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    public var initialPage = 0
    public func displayViewController() -> UIViewController? {
        guard let viewControllers = viewControllers else {
            return nil
        }
        let indexPath = collectionView.indexPathsForVisibleItems.first
        guard let ip = indexPath else { return nil }
        let vc = viewControllers[ip.row]
        return vc  as? UIViewController
    }
    
    public func show(page index: NSInteger, animated: Bool) {
        if collectionView.indexPathsForVisibleItems.first?.row == index {
            return
        }
        collectionView .scrollToItem(at: IndexPath.init(row: index, section: 0), at: .centeredHorizontally, animated: animated)
    }
    
    deinit {
        self.collectionView.removeObserver(self, forKeyPath: "panGestureRecognizer.state")
    }

}

extension HitTestContainerViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let viewControllers = viewControllers else { return 0 }
        return viewControllers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HitTestContainerViewController.cellIfentifier, for: indexPath) as! HitTestContainerViewCollectionViewCell
        if let viewController = viewControllers![indexPath.row] as? UIViewController {
            cell.view = viewController.view
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return collectionView.frame.size
    }
    
    /// cell 完全离开屏幕后调用
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let viewControllers = viewControllers else { return }
        // 获取当前显示已经显示的控制器
        guard let displayIndexPath = collectionView.indexPathsForVisibleItems.first else { return }
        let displayIndexPathController = viewControllers[displayIndexPath.row] as! UIViewController
        displayIndexPathController.endAppearanceTransition()
        
        if let delegate = delegate {
            if delegate.responds(to: #selector(HitTestContainerViewControllerDelegate.hitTestContainerViewController(_:didPageDisplay:forItemAt:))) {
                delegate.hitTestContainerViewController!(_: self, didPageDisplay: displayIndexPathController, forItemAt: displayIndexPath.row)
            }
        }
        
        // 获取已离开屏幕的cell上控制器，执行其view消失的生命周期方法
        let endDisplayingViewController = viewControllers[indexPath.row] as! UIViewController
        if displayIndexPathController != endDisplayingViewController {
            // 如果完全显示的控制器和已经离开屏幕的控制器是同一个就return，防止初始化完成后是同一个
            endDisplayingViewController.endAppearanceTransition()
        }
//        UIView.animate(withDuration: 0.3) {
//            UIApplication.shared.setNeedsStatusBarAppearanceUpdate()
//        }
    }
    
    /// cell 即将显示在屏幕时调用
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if initialPage > 0 {
            show(page: initialPage, animated: false)
            initialPage = 0
        }
        guard let viewControllers = viewControllers else { return }
        /// 获取即将显示的cell上的控制器，执行其view显示的生命周期方法
        let willDisplayController = viewControllers[indexPath.row] as! UIViewController
        willDisplayController.beginAppearanceTransition(true, animated: true)
        if let delegate = delegate {
            if delegate.responds(to: #selector(HitTestContainerViewControllerDelegate.hitTestContainerViewController(_:willPageDisplay:forItemAt:))) {
                delegate.hitTestContainerViewController!(_: self, willPageDisplay: willDisplayController, forItemAt: indexPath.row)
            }
        }
        
        /// 获取即将消失的控制器（当前collectionView显示的cell就是即将要离开屏幕的cell）
        guard let willEndDisplayingIndexPath = collectionView.indexPathsForVisibleItems.first else { return }
        let willEndDisplayingController = viewControllers[willEndDisplayingIndexPath.row] as! UIViewController
        if willEndDisplayingController != willDisplayController {
            // 如果是同一个控制器return，防止初始化完成后是同一个
            willEndDisplayingController.beginAppearanceTransition(false, animated: true)
        }
    }
    
}

extension HitTestContainerViewController {
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        let scrollView = object as! UIScrollView
        if keyPath == "panGestureRecognizer.state" && scrollView == self.collectionView {
            if let delegate = delegate {
                if delegate.responds(to: #selector(HitTestContainerViewControllerDelegate.hitTestContainerViewController(_:handlerContainerPanGestureState:))) {
                    delegate.hitTestContainerViewController!(self, handlerContainerPanGestureState: self.collectionView.panGestureRecognizer)
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

