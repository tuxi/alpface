//
//  HeartAnimation.swift
//  Alpface
//
//  Created by swae on 2018/4/1.
//  Copyright © 2018年 alpface. All rights reserved.
//

import UIKit

@objc(ALPHeartAnimation)
class HeartAnimation : NSObject {
    
    /// 根据touchs来触发动画
    open class func animation(touchs: Set<UITouch>, event: UIEvent) {
        
        guard let allTouchs = event.allTouches else { return }
        guard let touch = allTouchs.first else { return }
        let point = touch.location(in: touch.view)
        guard let view = touch.view else { return }
        animation(point: point, inView: view)
    }
    
    /// 根据轻拍手势来触发动画
    open class func animation(tapGesture: UITapGestureRecognizer) {
        let point = tapGesture.location(in: tapGesture.view)
        guard let view = tapGesture.view else { return }
        animation(point: point, inView: view)
    }
    
    open class func animation(point: CGPoint, inView: UIView) {
        let image = UIImage.init(named: "heart")
        let imageView = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: 80.0, height: 80.0))
        imageView.image = image
        imageView.contentMode = .scaleAspectFill
        imageView.center = point
        
        // 左右随机显示
        var leftOrRight = Int(arc4random() % 2)
        if leftOrRight == 0 {
            leftOrRight = -1
        }
        // 旋转动画
        imageView.transform = imageView.transform.rotated(by: CGFloat.pi / 9 * CGFloat(leftOrRight))
        inView.addSubview(imageView)
        
        // 出现时回弹下
        UIView.animate(withDuration: 0.1, animations: {
            imageView.transform = imageView.transform.scaledBy(x: 1.2, y: 1.2)
        }) { (finished) in
            imageView.transform = imageView.transform.scaledBy(x: 0.8, y: 0.8)
            
            self.perform(#selector(HeartAnimation.animationToTop(imageView:)), with: imageView, afterDelay: 0.1)
        }
    }
    
    /// 向上飘，放大、透明动画
    @objc fileprivate class func animationToTop(imageView: UIImageView) {
        UIView.animate(withDuration: 0.6, animations: {
            imageView.frame = CGRect.init(x: imageView.frame.origin.x, y: imageView.frame.origin.y - 100, width: imageView.frame.width, height: imageView.frame.height)
            imageView.transform = imageView.transform.scaledBy(x: 1.8, y: 1.8)
            imageView.alpha = 0.0;
        }) { (isFinshed) in
            imageView.removeFromSuperview()
        }
    }
  
}
