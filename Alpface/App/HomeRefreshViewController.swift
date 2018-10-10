//
//  HomeRefreshViewController.swift
//  Alpface
//
//  Created by xiaoyuan on 2018/10/10.
//  Copyright © 2018 alpface. All rights reserved.
//

import UIKit

class HomeRefreshViewController: UIViewController {
    
    enum HomeRefreshStatus {
        case normal // 正常状态
        case down  // 下拉
        case up     // 上拉
        case refreshing // 刷新中
    }
    
    /// 向下拖拽最大点-刷新临界值
    private let maxDistance: CGFloat = 60.0
    
    /// 记录手指滑动状态
    public var refreshStatus: HomeRefreshStatus = .normal
    
    /// 可以刷新的回调
    fileprivate var refreshCallback: (() -> (Void))?
    fileprivate var startPoint: CGPoint = CGPoint.zero
    
    fileprivate var scrollView: UIScrollView?
    fileprivate var touchView: UIView?
    fileprivate var mainNavigationBar: UIView?
    fileprivate lazy var refreshView: HomeRefreshNavigitionView = {
        var navigationHeight: CGFloat = 66.0;
        if AppUtils.isIPhoneX() {
            navigationHeight = 88.0
        }
        let view = HomeRefreshNavigitionView(frame: CGRect.init(x: 0, y: 0, width: self.view.frame.size.width, height: navigationHeight))
        view.backgroundColor = UIColor.clear
        view.alpha = 0.0
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    public func addHeaderRefresh(_ scrollView: UIScrollView, navigationBar: UIView, callBack: @escaping ()->(Void)) {
        if scrollView.isKind(of: UIScrollView.classForCoder()) == false {
            return
        }
        
        self.refreshCallback = callBack
        
        self.scrollView = scrollView
        //去掉弹性效果
        scrollView.bounces = false
        self.view.addSubview(scrollView)
        
        // 用来响应touch的view
        let _touchView = UIView()
        _touchView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(_touchView)
        NSLayoutConstraint(item: _touchView, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1.0, constant: 0.0).isActive = true
        NSLayoutConstraint(item: _touchView, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1.0, constant: 0.0).isActive = true
        NSLayoutConstraint(item: _touchView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1.0, constant: 0.0).isActive = true
        NSLayoutConstraint(item: _touchView, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1.0, constant: 0.0).isActive = true
        touchView = _touchView
  
        
        self.view.addSubview(self.refreshView)
        
        self.mainNavigationBar = navigationBar
        self.view.addSubview(navigationBar)
        
        //添加观察者
        scrollView.addObserver(self, forKeyPath: "contentOffset", options: [.old, .new], context: nil)
        //触摸结束恢复原位-松手回弹
        scrollView.contentOffset = CGPoint(x: 0, y: 0)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "contentOffset" {
            if let scrollView = self.scrollView {
                if scrollView.contentOffset.y <= 0 {
                    self.touchView?.isHidden = false
                }
            }
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let scrollView = self.scrollView else {
            return
        }
        
        if scrollView.contentOffset.y <= 0.0 && self.refreshStatus == .normal {
            //当tableview停在第一个cell并且是正常状态才记录起始触摸点，防止页面在刷新时用户再次向下拖拽页面造成多次下拉刷新
            let touch    = (touches as NSSet).anyObject() as! UITouch
            startPoint = touch.location(in: self.view)
        }
        else {
            // 隐藏touchView，让页面响应scrollView的事件
            self.touchView?.isHidden = true
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if startPoint.equalTo(.zero) {
            //没记录到起始触摸点就返回
            return
        }
        
        guard let scrollView = self.scrollView else {
            return
        }
        
        let touch    = (touches as NSSet).anyObject() as! UITouch
        let currentPoint = touch.location(in: self.view)
        
        let moveDistance = currentPoint.y - startPoint.y
        if scrollView.contentOffset.y == 0 {
            // 根据触摸点移动方向判断用户是下拉还是上拉
            if moveDistance > 0 && moveDistance < self.maxDistance {
                self.refreshStatus = .down
                //只判断当前触摸点与起始触摸点y轴方向的移动距离，只要y比起始触摸点的y大就证明是下拉，这中间可能存在先下拉一段距离没松手又上滑了一点的情况
                let alpha = moveDistance/self.maxDistance
                //moveDistance>0则是下拉刷新，在下拉距离小于MaxDistance的时候对_refreshNavigitionView和_mainViewNavigitionView进行透明度、frame移动操作
                self.refreshView.alpha = alpha
                var frame = self.refreshView.frame
                frame.origin.y = moveDistance
                self.refreshView.frame = frame
                if let navigationBar = self.mainNavigationBar {
                    navigationBar.alpha = 1 - alpha
                    navigationBar.frame = frame
                }
                
                //在整体判断为下拉刷新的情况下，还需要对上一个触摸点和当前触摸点进行比对，判断圆圈旋转方向，下移逆时针，上移顺时针
                let previousPoint = touch.preciseLocation(in: self.view) // 上一个坐标
                if currentPoint.y > previousPoint.y {
                    self.refreshView.circleImageView.transform = self.refreshView.transform.rotated(by: -0.08)
                }
                else {
                    self.refreshView.circleImageView.transform = self.refreshView.transform.rotated(by: 0.08)
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
                //moveDistance<0则是上拉 根据移动距离修改tableview.contentOffset，模仿tableview的拖拽效果，一旦执行了这行代码，下个触摸点就会走外层else代码
                self.scrollView?.contentOffset = CGPoint(x: 0, y: -moveDistance)
            }
        }
       
        else {
            self.refreshStatus = .up;
            //tableview被上拉了
            self.touchView?.isHidden = true
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch    = (touches as NSSet).anyObject() as! UITouch
        self.updateRefresh(touch)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch    = (touches as NSSet).anyObject() as! UITouch
        self.updateRefresh(touch)
    }
    
    fileprivate func updateRefresh(_ touch: UITouch) {
        let currentPoint = touch.location(in: self.view)
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
            self.refreshStatus = .refreshing
            // 刷新刷新控件
            self.refreshView.startAnimation()
            if let callback = self.refreshCallback {
                callback()
            }
        }
        else {
            resumeNormal()
        }
    }
    
    /// 恢复为正常状态
    fileprivate func resumeNormal() {
        self.refreshStatus = .normal
        UIView.animate(withDuration: 0.3) {
            self.refreshView.alpha = 0.0
            self.mainNavigationBar?.alpha = 1.0
        }
    }
    
    /// 结束刷新
    public func endRefresh() {
        self.resumeNormal()
        self.refreshView.circleImageView.layer .removeAnimation(forKey: "rotationAnimation")
        self.touchView?.isHidden = false
    }
    
    deinit {
        if let scrollView = self.scrollView {
            scrollView.removeObserver(self, forKeyPath: "contentOffset")
        }
    }

}
