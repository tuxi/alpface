//
//  PercentDrivenInteractiveTransition.swift
//  Alpface
//
//  Created by swae on 2018/4/22.
//  Copyright © 2018年 alpface. All rights reserved.
//

import UIKit

typealias GestureConifg = () -> Void

/// 手势的方向
enum ALPInteractiveTransitionGestureDirection: Int {
    case left, right, up, down
}

/// 手势控制哪种转场
enum ALPInteractiveTransitionType {
    case present, dismiss, push, pop
}

@objc(ALPPercentDrivenInteractiveTransition)
class PercentDrivenInteractiveTransition: UIPercentDrivenInteractiveTransition {
    /// 记录是否开始手势，判断pop操作是手势触发还是返回键触发
    public var interactionInProgress: Bool = false
    /// 是否完成转场动画
    private var shouldCompleteTransition = false
    /// 促发手势present的时候的config，config中初始化并present需要弹出的控制器
    public var presentConifg: GestureConifg?
    
    /// 促发手势push的时候的config，config中初始化并push需要弹出的控制器
    public var pushConifg: GestureConifg?
    
    fileprivate weak var viewController: UIViewController?
    /// 手势方向
    fileprivate var direction: ALPInteractiveTransitionGestureDirection = .down
    /// 手势类型
    fileprivate var type: ALPInteractiveTransitionType = .present
    
    convenience init(transitionType type: ALPInteractiveTransitionType, gestureDirection direction: ALPInteractiveTransitionGestureDirection) {
        self.init()
        self.type = type
        self.direction = direction
    }
    
    /// 给传入的控制器添加手势
    public func addPanGesture(forViewController vc: UIViewController) {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handleGesture(panGesture:)))
        self.viewController = vc
        viewController?.view.addGestureRecognizer(pan)
    }
    
}

extension PercentDrivenInteractiveTransition {
    @objc fileprivate func handleGesture(panGesture: UIPanGestureRecognizer) {
        /// 手势百分比
        var progress: CGFloat = 0.0
        switch self.direction {
        case .left:
            let transitionX: CGFloat = -(panGesture.translation(in: panGesture.view).x)
            if let width = panGesture.view?.frame.width {
                progress = transitionX / width
            }
        case .right:
            let transitionX: CGFloat = panGesture.translation(in: panGesture.view).x
            if let width = panGesture.view?.frame.width {
                progress = transitionX / width
            }
        case .up:
            let transitionY: CGFloat = -(panGesture.translation(in: panGesture.view).y)
            if let width = panGesture.view?.frame.width {
                progress = transitionY / width
            }
        case .down:
            let transitionY: CGFloat = panGesture.translation(in: panGesture.view).y
            if let width = panGesture.view?.frame.width {
                progress = transitionY / width
            }
        }
        progress = CGFloat(fminf(fmaxf(Float(progress), 0.0), 1.0))
        shouldCompleteTransition = progress > 0.35
        switch panGesture.state {
        case .began:
            /// 手势开始的时候标记手势状态，并开始相应的事件
            self.interactionInProgress = true
            self.startGesture()
        case .changed, .possible:
            /// 手势过程中，通过updateInteractiveTransition设置pop过程进行的百分比
            self.update(progress)
        case .ended, .failed:
            /// 手势完成后结束标记并且判断移动距离是否过半，过则finishInteractiveTransition完成转场操作，否者取消转场操作
            self.interactionInProgress = false
            if shouldCompleteTransition {
                self.finish()
            }
            else {
                self.cancel()
            }
        case .cancelled:
            self.interactionInProgress = false
            self.cancel()
        }
    }
    
    
    fileprivate func startGesture() {
        switch type {
        case .present:
            if let presentConifg = self.presentConifg {
                presentConifg()
            }
        case .dismiss:
            self.viewController?.dismiss(animated: true, completion: nil)
        case .push:
            if let pushConifg = self.pushConifg {
                pushConifg()
            }
        case .pop:
            self.viewController?.navigationController?.popViewController(animated: true)
        }
        
    }
    
}

