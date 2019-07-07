//
//  MyHomeDragLeftInteractiveTransition.swift
//  Alpface
//
//  Created by swae on 2019/7/7.
//  Copyright © 2019 alpface. All rights reserved.
//

import UIKit

class MyHomeDragLeftInteractiveTransition: UIPercentDrivenInteractiveTransition {

    // 是否正在拖动返回 标识是否正在使用转场的交互中
    public var isInteracting: Bool = false
    
    fileprivate var viewControllerCenter: CGPoint = .zero
    fileprivate var presentingVC: UIViewController?
    fileprivate lazy var transitionMaskLayer: CALayer = {
        return CALayer()
    }()
    
    // 设置需要返回的VC
    public func prepare(to viewController: UIViewController) {
        self.presentingVC = viewController
        self.viewControllerCenter = viewController.view.center
        self .prepareGestureRecognizer(inView: viewController.view)
    }

    override func cancel() {
        super.cancel()
        print("转场取消")
    }
    override func finish() {
        super.finish()
        print("转场完成")
    }
    
    
    fileprivate func prepareGestureRecognizer(inView: UIView) {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(self.handleGesture(gestureRecognizer:)))
        inView.addGestureRecognizer(pan)
    }
    
    @objc fileprivate func handleGesture(gestureRecognizer: UIPanGestureRecognizer) {
        guard let vcView = gestureRecognizer.view else {
            return
        }
        let translation = gestureRecognizer.translation(in: vcView.superview)
        if self.isInteracting == false && (translation.x < 0 || translation.y < 0 || translation.x < translation.y) {
            return
        }
        
        switch gestureRecognizer.state {
        case .began:
            let vel = gestureRecognizer.velocity(in: gestureRecognizer.view)
            //修复当从右侧向左滑动的时候的bug 避免开始的时候从又向左滑动 当未开始的时候
            if self.isInteracting == false && vel.x < 0 {
                self.isInteracting = false
            }
            self.transitionMaskLayer.frame = vcView.frame
            self.transitionMaskLayer.isOpaque = false
            self.transitionMaskLayer.opacity = 1.0
            self.transitionMaskLayer.backgroundColor = UIColor.white.cgColor
            self.transitionMaskLayer.setNeedsDisplay()
            self.transitionMaskLayer.displayIfNeeded()
            self.transitionMaskLayer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            self.transitionMaskLayer.position = CGPoint(x: vcView.frame.size.width/2.0, y: vcView.frame.size.height/2.0)
            vcView.layer.mask = self.transitionMaskLayer
            vcView.layer.masksToBounds = true
            self.isInteracting = true
            
            break
        case .changed:
            var progress: CGFloat = translation.x / UIScreen.main.bounds.size.width
            progress = CGFloat(fminf(fmaxf(Float(progress), 0.0), 1.0))
            
            let ratio = 1.0 - progress*0.5
            
            self.presentingVC?.view.center = CGPoint(x: self.viewControllerCenter.x+translation.x*ratio, y: self.viewControllerCenter.y+translation.y*ratio)
            self.presentingVC?.view.transform = CGAffineTransform(scaleX: ratio, y: ratio)
            self.update(progress)
            break
        case .ended, .cancelled:
            var progress: CGFloat = translation.x / UIScreen.main.bounds.size.width
            progress = CGFloat(fminf(fmaxf(Float(progress), 0.0), 1.0))
            
            if progress < 0.2 {
                UIView.animate(withDuration: TimeInterval(progress), delay: 0, options: .curveEaseOut, animations: {
                    self.presentingVC?.view.center = CGPoint(x: UIScreen.main.bounds.width/2, y: UIScreen.main.bounds.height/2)
                    self.presentingVC?.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                    
                }) { (finished) in
                    self.isInteracting = false
                    self.cancel()
                }
            }
            else {
                self.isInteracting = false
                self.finish()
                self.presentingVC?.dismiss(animated: true, completion: nil)
            }
            
            //移除 遮罩
            self.transitionMaskLayer.removeFromSuperlayer()
//            self.transitionMaskLayer = nil
            break
        default:
            break
        }
        
    }

}
