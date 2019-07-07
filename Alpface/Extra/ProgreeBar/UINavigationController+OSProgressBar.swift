//
//  UINavigationController+OSProgressBar.swift
//  ProgressBarDemo
//
//  Created by alpface on 15/08/2017.
//  Copyright © 2017 alpface. All rights reserved.
//

import UIKit

public extension UINavigationController {
    
    public var progressView: OSProgressView {
        for subview in navigationBar.subviews {
            if let progressView = subview as? OSProgressView {
                return progressView
            }
        }
        
        let defaultHeight = CGFloat(2.0)
        
        let frame = CGRect(x: 0,
                           y: navigationBar.frame.height - defaultHeight,
                           width: navigationBar.frame.width,
                           height: defaultHeight)
        
        let progressView = OSProgressView(frame: frame)
        
        navigationBar.addSubview(progressView)
        
        progressView.autoresizingMask = [
            .flexibleWidth, .flexibleTopMargin
        ]
        
        return progressView
    }
   
   
}
