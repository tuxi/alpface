//
//  OSProgressView.swift
//  ProgressBarDemo
//
//  Created by alpface on 15/08/2017.
//  Copyright © 2017 alpface. All rights reserved.
//

import UIKit

public final class OSProgressView: UIImageView {
    
    public var progress: CGFloat = 0 {
        didSet {
            progress = min(1.0, progress)
            progressBarWidthConstraint.constant = bounds.width * CGFloat(progress)
            if let progressHandler = self.progressHandler {
                progressHandler(progress)
            }
            if progress == 1.0 {
                if let completionHandler = self.completionHandler {
                    completionHandler()
                }
            }
            
        }
    }
    
    internal let progressBar = UIImageView()
    fileprivate var needsLoading: Bool = false
    fileprivate var isLoading: Bool = false
    
    fileprivate let progressBarWidthConstraint : NSLayoutConstraint
    // loading时 使用centerX
    fileprivate var progressBarCenterXConstraint : NSLayoutConstraint?
    // progress时 使用left
    fileprivate var progressBarLeftConstraint : NSLayoutConstraint?
    
    @objc public dynamic var trackTintColor : UIColor? = .clear {
        didSet {
            backgroundColor = trackTintColor;
        }
    }
    
    @objc public dynamic var progressTintColor : UIColor? = UIColor(red: 0, green: 122/255, blue: 1, alpha: 1) {
        didSet {
            progressBar.backgroundColor = progressTintColor
        }
    }
    
    @objc public dynamic var loadingTintColor : UIColor? = UIColor.white {
        didSet {
            progressBar.backgroundColor = loadingTintColor
        }
    }
    
    @objc fileprivate func loadingAnimation(duration : TimeInterval = 0.55) {
        if needsLoading == false {
            return
        }
        if isLoading == true {
            return
        }
        isLoading = true
        var needLayout = false
        if self.progressBarLeftConstraint?.isActive == true {
            self.progressBarLeftConstraint?.isActive = false
            needLayout = true
        }
        if self.progressBarCenterXConstraint?.isActive == false {
            self.progressBarCenterXConstraint?.isActive = true
            needLayout = true
        }
        if needLayout == true {
            self.layoutIfNeeded()
        }
        
        progressBar.alpha = 1.0
        progressBarWidthConstraint.constant = bounds.width * CGFloat(1.0)
        UIView.animate(withDuration: duration-0.1, animations: {
            self.layoutIfNeeded()
        }) { (finished) in
            self.progressBarWidthConstraint.constant = 0.0
            self.progressBar.alpha = 0.0
            UIView.animate(withDuration: 0.1, animations: {
                self.layoutIfNeeded()
            }, completion: { (finished) in
                self.isLoading = false
                self.loadingAnimation(duration: duration)
            })
        }
    }
    
//    public override var frame: CGRect {
//        didSet {
//            let tempProgress = progress
//            progress = tempProgress
//        }
//    }
    
    public override func layoutSubviews() {
        superview?.layoutSubviews()
        //        progress = min(1.0, progress)
        //        progressBarWidthConstraint.constant = bounds.width * CGFloat(progress)
    }
    
    /* ====================================================================== */
    // MARK: - initializer
    /* ====================================================================== */
    public override init(frame: CGRect) {
        
        progressBarWidthConstraint = NSLayoutConstraint(item: progressBar,
                                                        attribute: .width,
                                                        relatedBy: .equal,
                                                        toItem: nil,
                                                        attribute: .notAnAttribute,
                                                        multiplier: 1.0,
                                                        constant: frame.width * CGFloat(progress))
        
        super.init(frame: frame);
        
        progressBarCenterXConstraint = NSLayoutConstraint(item: progressBar, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0.0)
        
        progressBarLeftConstraint = NSLayoutConstraint(item: progressBar,
                                                       attribute: .left,
                                                       relatedBy: .equal,
                                                       toItem: self,
                                                       attribute: .left,
                                                       multiplier: 1.0,
                                                       constant: 0.0)
        
        let bottomConstraint = NSLayoutConstraint(item: progressBar,
                                                  attribute: .bottom,
                                                  relatedBy: .equal,
                                                  toItem: self,
                                                  attribute: .bottom,
                                                  multiplier: 1.0,
                                                  constant: 0.0)
        
        let topConstraint = NSLayoutConstraint(item: progressBar,
                                               attribute: .top,
                                               relatedBy: .equal,
                                               toItem: self,
                                               attribute: .top,
                                               multiplier: 1.0,
                                               constant: 0.0)
        
        addSubview(progressBar)
        
        progressBar.backgroundColor = trackTintColor
        
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        
        addConstraints([
            progressBarWidthConstraint,
            progressBarLeftConstraint!,
            bottomConstraint,
            topConstraint
            ])
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setProgress(progress: CGFloat, animated: Bool) {
        self.endLoading()
        if self.isLoading {
            // 防止最后一次loading还未结束，就开始执行progress，导致布局问题
            return
        }
        progressBar.alpha = 1.0
        let duration : TimeInterval = animated ? 0.1 : 0.0
        
        self.progress = progress
        
        UIView.animate(withDuration: duration) {
            self.layoutIfNeeded()
        }
    }
    
    public var cancellationHandler: (() -> Swift.Void)?
    public var completionHandler: (() -> Swift.Void)?
    public var progressHandler: ((_ fractionCompleted: CGFloat) -> Swift.Void)?
    
    public func completed() {
        setProgress(progress: 1.0, animated: true)
        
        UIView.animate(withDuration: 0.25, animations: {
            self.progressBar.alpha = 0.0
        }) { (finished: Bool) in
            self.progress = 0.0
            if let completionHandler = self.completionHandler {
                completionHandler()
            }
        }
    }
    
    public func cancel() {
        setProgress(progress: 0.0, animated: true)
        
        UIView.animate(withDuration: 0.25, animations: {
            self.progressBar.alpha = 0.0
        }) { (finished: Bool) in
            if let cancellationHandler = self.cancellationHandler {
                cancellationHandler()
            }
        }
    }
    
    public func startLoading(duration: TimeInterval = 0.45) {
        self.needsLoading = true
        loadingAnimation(duration: duration)
    }
    
    public func endLoading() {
        self.needsLoading = false
        self.progressBarCenterXConstraint?.isActive = false
        self.progressBarLeftConstraint?.isActive = true
        self.layoutIfNeeded()
    }
    
}
