//
//  OSProgressView.swift
//  ProgressBarDemo
//
//  Created by alpface on 15/08/2017.
//  Copyright © 2017 alpface. All rights reserved.
//

import UIKit

public final class OSProgressView: UIImageView {

    internal var progress: CGFloat = 0 {
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
    
    fileprivate let progressBarWidthConstraint : NSLayoutConstraint
    
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
    
    public override var frame: CGRect {
        didSet {
            let tempProgress = progress
            progress = tempProgress
        }
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
        
        let leftConstraint = NSLayoutConstraint(item: progressBar,
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
            leftConstraint,
            bottomConstraint,
            topConstraint
            ])
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    internal func setProgress(progress: CGFloat, animated: Bool) {
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
    
    public var progressHeight: CGFloat {
        get {
            return frame.height
        }
        set {
            frame.origin.y = superview!.frame.height - newValue
            frame.size.height = newValue
        }
    }

}
