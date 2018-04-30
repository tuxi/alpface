//
//  UIViewController+CustomTransitioningAnimator.swift
//  Alpface
//
//  Created by swae on 2018/4/30.
//  Copyright © 2018年 alpface. All rights reserved.
//

import UIKit

extension UIViewController {
    private struct CustomTransitioningAnimatorKeys {
        static var modalAnimatorKey = "com.alpface.CustomTransitioningAnimatorKeys.modalAnimatorKey"
    }
    public var modalAnimator: ZFModalTransitionAnimator? {
        set {
            objc_setAssociatedObject(self, &CustomTransitioningAnimatorKeys.modalAnimatorKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return objc_getAssociatedObject(self, &CustomTransitioningAnimatorKeys.modalAnimatorKey) as? ZFModalTransitionAnimator
        }
    }
    
    public func usingCustomModalTransitioningAnimator() {
        self.modalAnimator = ZFModalTransitionAnimator(modalViewController: self)
        self.transitioningDelegate = modalAnimator
        
        self.modalAnimator?.topViewScale = ZFModalTransitonSizeScale.init(widthScale: 1.0, heightScale: 0.95)
        self.modalAnimator?.isDragable = true
        self.modalAnimator?.bounces = false
        self.modalAnimator?.behindViewAlpha = 0.5
        self.modalAnimator?.behindViewScale = 0.9
        self.modalAnimator?.transitionDuration = 0.7
        self.modalAnimator?.direction = .bottom
    }
}


