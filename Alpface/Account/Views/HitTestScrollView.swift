//
//  HitTestScrollView.swift
//  Alpface
//
//  Created by swae on 2018/3/27.
//  Copyright © 2018年 alpface. All rights reserved.
//

import UIKit

@objc(ALPHitTestScrollView)
internal class HitTestScrollView: UIScrollView {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.delaysContentTouches = false
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.delaysContentTouches = false
    }
//    override init(frame: CGRect, style: UITableViewStyle) {
//        super.init(frame: frame, style: style)
//        self.delaysContentTouches = false
//    }
    
    override func touchesShouldCancel(in view: UIView) -> Bool {
        if view.isKind(of: UIButton.self) {
            return true
        }
        
        return super.touchesShouldCancel(in: view)
    }
}

