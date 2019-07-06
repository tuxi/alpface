//
//  TransitionButton.swift
//  Instagram
//
//  Created by Bobby Negoat on 12/28/17.
//  Copyright © 2017 Mac. All rights reserved.
//

import UIKit

enum StopAnimationStyle {
    case normal
    case expand
    case shake
}

@IBDesignable
class TransitionButton: UIButton,UIViewControllerTransitioningDelegate, CAAnimationDelegate {
    
    // the color of the spinner while animating the button
    @IBInspectable
    var spinnerColor: UIColor = UIColor.white {
        didSet {
            spiner.spinnerColor = spinnerColor
        }
    }
    
    // the background of the button in disabled state
    @IBInspectable
    var disabledBackgroundColor: UIColor = UIColor.lightGray {
        didSet {
            self.setBackgroundImage(UIImage(color: disabledBackgroundColor), for: .disabled)
        }
    }
    
    private lazy var spiner: SpinerLayer = {
        let spiner = SpinerLayer(frame: self.frame)
        self.layer.addSublayer(spiner)
        return spiner
    }()
    
    private var cachedTitle: String?
    private var cachedImage: UIImage?
    
    private let springGoEase:CAMediaTimingFunction  = CAMediaTimingFunction(controlPoints: 0.45, -0.36, 0.44, 0.92)
    private let shrinkCurve:CAMediaTimingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
    private let expandCurve:CAMediaTimingFunction = CAMediaTimingFunction(controlPoints: 0.95, 0.02, 1, 0.05)
    private let shrinkDuration: CFTimeInterval = 0.1
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.setup()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        spiner.frame = CGRect(x: 0, y: 0, width: self.frame.height, height: self.frame.height)
    }
    
}//TransitionButton class over line

//custom functions
extension TransitionButton{
    
    private func setup() {
        self.clipsToBounds  = true
        spiner.spinnerColor = spinnerColor
    }
    
    func startAnimation() {
        
        self.isUserInteractionEnabled = false
        
        // Disable the user interaction during the animation
        self.cachedTitle = title(for: .normal)
        
        // cache title before animation of spiner
        self.cachedImage = image(for: .normal)
        
        // cache image before animation of spiner
        self.setTitle("",  for: .normal)
        
        // place an empty string as title to display a spiner
        self.setImage(nil, for: .normal)
        
        //remove the image, if any, before displaying the spinner
        UIView.animate(withDuration: 0.1, animations: {
            self.layer.cornerRadius = self.frame.height / 2
            
            // corner radius should be half the height to have a circle corners
        }, completion: { completed -> Void in
            self.shrink()
            
            // reduce the width to be equal to the height in order to have a circle
            self.spiner.animation()
        })
    }
    
    func stopAnimation(animationStyle:StopAnimationStyle = .normal, revertAfterDelay delay: TimeInterval = 1.0, completion:(()->Void)? = nil) {
        
        switch animationStyle {
        case .normal:
            completion?()
            
            // We return to original state after a delay to give opportunity to custom transition
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                self.setOriginalState()
            }
        case .shake:
            completion?()
            
            // We return to original state after a delay to give opportunity to custom transition
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                self.setOriginalState()
                self.shakeAnimation()
            }
        case .expand:
            
            // before animate the expand animation we need to hide the spiner first
            self.spiner.stopAnimation()
            
            // scale the round button to fill the screen
            self.expand(completion: completion, revertDelay:delay)
        }
    }
    
    private func shakeAnimation() {
        let keyFrame = CAKeyframeAnimation(keyPath: "position")
        let point = self.layer.position
        keyFrame.values = [NSValue(cgPoint: CGPoint(x: CGFloat(point.x), y: CGFloat(point.y))),
                           NSValue(cgPoint: CGPoint(x: CGFloat(point.x - 10), y: CGFloat(point.y))),
                           NSValue(cgPoint: CGPoint(x: CGFloat(point.x + 10), y: CGFloat(point.y))),
                           NSValue(cgPoint: CGPoint(x: CGFloat(point.x - 10), y: CGFloat(point.y))),
                           NSValue(cgPoint: CGPoint(x: CGFloat(point.x + 10), y: CGFloat(point.y))),
                           NSValue(cgPoint: CGPoint(x: CGFloat(point.x - 10), y: CGFloat(point.y))),
                           NSValue(cgPoint: CGPoint(x: CGFloat(point.x + 10), y: CGFloat(point.y))),
                           NSValue(cgPoint: point)]
        
        keyFrame.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        keyFrame.duration = 0.7
        self.layer.position = point
        self.layer.add(keyFrame, forKey: keyFrame.keyPath)
    }
    
    private func setOriginalState() {
        self.animateToOriginalWidth()
        self.spiner.stopAnimation()
        self.setTitle(self.cachedTitle, for: .normal)
        self.setImage(self.cachedImage, for: .normal)
        self.isUserInteractionEnabled = true // enable again the user interaction
        self.layer.cornerRadius = self.cornerRadius
    }
    
    private func animateToOriginalWidth() {
        let shrinkAnim = CABasicAnimation(keyPath: "bounds.size.width")
        shrinkAnim.fromValue = (self.bounds.height)
        shrinkAnim.toValue = (self.bounds.width)
        shrinkAnim.duration = shrinkDuration
        shrinkAnim.timingFunction = shrinkCurve
        shrinkAnim.fillMode = CAMediaTimingFillMode.forwards
        shrinkAnim.isRemovedOnCompletion = false
        self.layer.add(shrinkAnim, forKey: shrinkAnim.keyPath)
    }
    
    private func shrink() {
        let shrinkAnim = CABasicAnimation(keyPath: "bounds.size.width")
        shrinkAnim.fromValue = frame.width
        shrinkAnim.toValue = frame.height
        shrinkAnim.duration = shrinkDuration
        shrinkAnim.timingFunction = shrinkCurve
        shrinkAnim.fillMode = CAMediaTimingFillMode.forwards
        shrinkAnim.isRemovedOnCompletion = false
        
        layer.add(shrinkAnim, forKey: shrinkAnim.keyPath)
    }
    
    private func expand(completion:(()->Void)?, revertDelay: TimeInterval) {
        let expandAnim = CABasicAnimation(keyPath: "transform.scale")
        expandAnim.fromValue = 1.0
        expandAnim.toValue = 26.0
        expandAnim.timingFunction = expandCurve
        expandAnim.duration = 0.4
        expandAnim.fillMode = CAMediaTimingFillMode.forwards
        expandAnim.isRemovedOnCompletion = false
        
        CATransaction.setCompletionBlock {
            completion?()
            
            // We return to original state after a delay to give opportunity to custom transition
            DispatchQueue.main.asyncAfter(deadline: .now() + revertDelay) {
                self.setOriginalState()
                
                // make sure we remove all animation
                self.layer.removeAllAnimations()
            }
        }
        
        layer.add(expandAnim, forKey: expandAnim.keyPath)
        
        CATransaction.commit()
    }
}
