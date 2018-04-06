//
//  HitTestScrollView.swift
//  Alpface
//
//  Created by swae on 2018/3/27.
//  Copyright © 2018年 alpface. All rights reserved.
//

import UIKit

@objc(ALPHitTestScrollViewGestureRecognizerDelegate)
protocol HitTestScrollViewGestureRecognizerDelegate: UIScrollViewDelegate {
    @objc func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool
}

@objc(ALPHitTestScrollView)
internal class HitTestScrollView: UITableView, UIGestureRecognizerDelegate {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.delaysContentTouches = false
    }
    
    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
        self.delaysContentTouches = false
    }

    
    override func touchesShouldCancel(in view: UIView) -> Bool {
        if view.isKind(of: UIButton.self) {
            return true
        }
        
        return super.touchesShouldCancel(in: view)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if let delegate = self.delegate as? HitTestScrollViewGestureRecognizerDelegate {
            if delegate.responds(to: #selector(HitTestScrollViewGestureRecognizerDelegate.gestureRecognizer(_:shouldRecognizeSimultaneouslyWith:))) {
               return delegate.gestureRecognizer(gestureRecognizer, shouldRecognizeSimultaneouslyWith: otherGestureRecognizer)
            }
        }
        return true
    }
}

