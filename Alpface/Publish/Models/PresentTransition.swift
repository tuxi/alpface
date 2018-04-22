//
//  PresentTransition.swift
//  Alpface
//
//  Created by swae on 2018/4/22.
//  Copyright © 2018年 alpface. All rights reserved.
//

import UIKit


enum ALPPresentTransitionType: Int {
    case present, dismiss
}

@objc(ALPPresentTransition)
class PresentTransition: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return type == .present ? 0.3 : 0.15
    }
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        /// 为了将两种动画的逻辑分开，变得更加清晰，我们分开书写逻辑，
        switch self.type {
        case .present:
            self.presentAnimation(transitionContext)
        case .dismiss:
            self.dismissAnimation(transitionContext)
        }
        
    }
    
    
    fileprivate var type: ALPPresentTransitionType = .present
    convenience init(transitionType type: ALPPresentTransitionType) {
        self.init()
        self.type = type
    }
    
    /// 实现present动画
    fileprivate func presentAnimation(_ transitionContext: UIViewControllerContextTransitioning) {
        
        //通过viewControllerForKey取出转场前后的两个控制器，这里toVC就是vc1、fromVC就是vc2
        let toVC = transitionContext.viewController(forKey: .to)
        let fromVC = transitionContext.viewController(forKey: .from)
        //snapshotViewAfterScreenUpdates可以对某个视图截图，我们采用对这个截图做动画代替直接对vc1做动画，因为在手势过渡中直接使用vc1动画会和手势有冲突，如果不需要实现手势的话，就可以不是用截图视图了
        let tempView = fromVC?.view.snapshotView(afterScreenUpdates: false)
        tempView?.frame = (fromVC?.view.frame)!
        //因为对截图做动画，vc1就可以隐藏了
        fromVC?.view.isHidden = true
        //这里有个重要的概念containerView，如果要对视图做转场动画，视图就必须要加入containerView中才能进行，可以理解containerView管理者所有做转场动画的视图
        let containerView = transitionContext.containerView
        //将截图视图和vc2的view都加入ContainerView中
        containerView.addSubview(tempView!)
        containerView.addSubview((toVC?.view)!)
        //设置vc2的frame，因为这里vc2present出来不是全屏，且初始的时候在底部，如果不设置frame的话默认就是整个屏幕咯，这里containerView的frame就是整个屏幕
        let height = containerView.frame.height - 100.0
        let width = containerView.frame.width
        toVC?.view.frame = CGRect(x: 0, y: containerView.frame.height, width: width, height: height)
        //开始动画吧，使用产生弹簧效果的动画API
        UIView.animate(withDuration: self.transitionDuration(using: transitionContext), delay: 0, options: [], animations: {
            // 首先我们让vc2向上移动
            toVC?.view.transform = CGAffineTransform(translationX: 0, y: -height)
            // 然后让截图视图缩小一点即可
            tempView?.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            
        }) { (isFinished) in
            //使用如下代码标记整个转场过程是否正常完成[transitionContext transitionWasCancelled]代表手势是否取消了，如果取消了就传NO表示转场失败，反之亦然，如果不是用手势的话直接传YES也是可以的，我们必须标记转场的状态，系统才知道处理转场后的操作，否者认为你一直还在，会出现无法交互的情况，切记
            transitionContext.completeTransition((transitionContext.transitionWasCancelled == false))
            //转场失败后的处理
            if transitionContext.transitionWasCancelled == true {
                //失败后，我们要把vc1显示出来
                fromVC?.view.isHidden = false
                //然后移除截图视图，因为下次触发present会重新截图
                tempView?.removeFromSuperview()
            }
        }
        
    }
    
    /// 实现dimiss动画
    fileprivate func dismissAnimation(_ transitionContext: UIViewControllerContextTransitioning) {
        //注意在dismiss的时候fromVC就是vc2了，toVC才是VC1了，注意理解这个逻辑关系
        let toVC = transitionContext.viewController(forKey: .to)
        let fromVC = transitionContext.viewController(forKey: .from)
        //参照present动画的逻辑，present成功后，containerView的最后一个子视图就是截图视图，我们将其取出准备动画
        let containerView = transitionContext.containerView
        let subviewsArray = containerView.subviews
        let index = min(subviewsArray.count, max(0, subviewsArray.count - 2))
        let tempView = subviewsArray[index]
        //动画吧
        UIView.animate(withDuration: self.transitionDuration(using: transitionContext), delay: 0.0, options: [], animations: {
            //因为present的时候都是使用的transform，这里的动画只需要将transform恢复就可以
            fromVC?.view.transform = CGAffineTransform.identity
            tempView.transform = CGAffineTransform.identity
        }) { (isFinished) in
            if transitionContext.transitionWasCancelled == true {
                //失败了接标记失败
                transitionContext.completeTransition(false)
            }
            else {
                //如果成功了，我们需要标记成功，同时让vc1显示出来，然后移除截图视图，
                transitionContext.completeTransition(true)
                toVC?.view.isHidden = false
                tempView.removeFromSuperview()
            }
        }
    }
    
}
