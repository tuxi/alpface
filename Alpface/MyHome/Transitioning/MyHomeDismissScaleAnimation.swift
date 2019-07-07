//
//  MyHomeDismissScaleAnimation.swift
//  Alpface
//
//  Created by swae on 2019/7/7.
//  Copyright © 2019 alpface. All rights reserved.
//

import UIKit

class MyHomeDismissScaleAnimation: NSObject, UIViewControllerAnimatedTransitioning {
    
    public var centerFrame: CGRect = CGRect(x: (UIScreen.main.bounds.width-5)*0.5, y: (UIScreen.main.bounds.height-5)*0.5, width: 5.0, height: 5.0)
    // 初始位置 不能为CGRectZero
    public var originCellFrame: CGRect = .zero
    // 结束位置 不能为CGRectZero
    public var finalCellFrame: CGRect = .zero
    public weak var selectCell: UIView?

    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.25
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        guard let fromVc = transitionContext.viewController(forKey: .from), let fromView = fromVc.view else {
            return
        }
        
        var snapshotView: UIView!
        var scaleRatio: CGFloat = 0.0
        var finalFrame: CGRect = self.finalCellFrame
        if let selectCell = self.selectCell, finalFrame != .zero{
            snapshotView = selectCell.snapshotView(afterScreenUpdates: false)
            scaleRatio = fromView.frame.size.width / selectCell.frame.size.width
            snapshotView?.layer.zPosition = 20.0
        }
        else {
            snapshotView = fromView.snapshotView(afterScreenUpdates: false)
            scaleRatio = fromView.frame.size.width / UIScreen.main.bounds.size.width
            finalCellFrame = centerFrame
        }
        
        let containerView = transitionContext.containerView
        containerView.addSubview(snapshotView)
        
        let duration = self.transitionDuration(using: transitionContext)
        fromView.alpha = 0.0
        snapshotView.center = fromView.center
        snapshotView.transform = CGAffineTransform(scaleX: scaleRatio, y: scaleRatio)
        
        UIView.animate(withDuration: duration, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.2, options: .curveEaseOut, animations: {
            snapshotView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            snapshotView.frame = finalFrame
        }) { (finished) in
            transitionContext.finishInteractiveTransition()
            transitionContext.completeTransition(true)
            snapshotView.removeFromSuperview()
        }
        
    }
    
}

