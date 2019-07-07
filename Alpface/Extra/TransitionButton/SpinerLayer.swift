//
//  SpinerLayer.swift
//  Instagram
//
//  Created by Bobby Negoat on 12/28/17.
//  Copyright © 2017 Mac. All rights reserved.
//

import UIKit

class SpinerLayer: CAShapeLayer {
    
    var spinnerColor = UIColor.white {
        didSet {
            strokeColor = spinnerColor.cgColor
        }
    }
    override init(layer: Any) {
        super.init(layer: layer)
    }
    init(frame:CGRect) {
        super.init()
        self.frame = CGRect(x: 0, y: 0, width: frame.height, height: frame.height)
        
        self.fillColor = nil
        self.strokeColor = spinnerColor.cgColor
        self.lineWidth = 1
        
        self.strokeEnd = 0.4
        self.isHidden = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var frame: CGRect {
        didSet {
            /// 解决使用lautoLaut 时 坐标获取不及时问题
            if oldValue.equalTo(frame) {
                return
            }
            let radius:CGFloat = (frame.height / 2) * 0.5
            let center = CGPoint(x: frame.height / 2, y: bounds.midY)
            let startAngle = 0 - Double.pi/2
            let endAngle = Double.pi * 2 - Double.pi / 2
            let clockwise: Bool = true
            self.path = UIBezierPath(arcCenter: center, radius: radius, startAngle: CGFloat(startAngle), endAngle: CGFloat(endAngle), clockwise: clockwise).cgPath
        }
    }
    
}//SpinerLayer class over line

//custom functions
extension SpinerLayer{
    
    func animation() {
        self.isHidden = false
        let rotate = CABasicAnimation(keyPath: "transform.rotation.z")
        rotate.fromValue = 0
        rotate.toValue = Double.pi * 2
        rotate.duration = 0.4
        rotate.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        
        rotate.repeatCount = HUGE
        rotate.fillMode = CAMediaTimingFillMode.forwards
        rotate.isRemovedOnCompletion = false
        self.add(rotate, forKey: rotate.keyPath)
    }
    
    func stopAnimation() {
        self.isHidden = true
        self.removeAllAnimations()
    }
}

