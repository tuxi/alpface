//
//  MyHomePresentScaleAnimation.swift
//  Alpface
//
//  Created by swae on 2019/7/7.
//  Copyright © 2019 alpface. All rights reserved.
//

import UIKit

@objc(ALPPresentScaleAnimation)
class MyHomePresentScaleAnimation: NSObject, UIViewControllerAnimatedTransitioning {
    
    /// cell在父视图的frame 不能为CGRectZero, 这个坐标 需要的是cell转换父视图完成之后的frame
    public var cellConvertFrame: CGRect = CGRect.zero
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        guard let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) else {
            return
        }
        
        if self.cellConvertFrame == CGRect.zero {
            transitionContext.completeTransition(true)
            return
        }
        guard let toView = toVC.view else {
            return
        }
        let initialFrame = self.cellConvertFrame
        let containerView = transitionContext.containerView
        containerView.addSubview(toView)
       
        let finalFrame = transitionContext.finalFrame(for: toVC)
        let duration = self.transitionDuration(using: transitionContext)
       
        toView.center = CGPoint(x: initialFrame.origin.x+initialFrame.size.width/2, y: initialFrame.origin.y+initialFrame.size.height/2)
       
        toView.transform = CGAffineTransform(scaleX: initialFrame.width/finalFrame.width, y: initialFrame.height/finalFrame.height)
        
        UIView.animate(withDuration: duration, delay: 0, options: .layoutSubviews, animations: {
            toView.center = CGPoint(x: finalFrame.origin.x + finalFrame.width/2, y: finalFrame.origin.y+finalFrame.size.height/2)
            toView.transform = CGAffineTransform(scaleX: 1, y: 1)
        }) { (isFinished) in
            transitionContext.completeTransition(true)
        }
        
    
    }
    



}
