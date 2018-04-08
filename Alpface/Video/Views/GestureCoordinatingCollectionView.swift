//
//  GestureCoordinatingCollectionView.swift
//  Alpface
//
//  Created by swae on 2018/3/11.
//  Copyright © 2018年 alpface. All rights reserved.
//

import UIKit

@objc(ALPGestureCoordinatingCollectionView)
class GestureCoordinatingCollectionView: UICollectionView {
    
    public weak var gestureDelegate: UIGestureRecognizerDelegate?

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    override func touchesShouldCancel(in view: UIView) -> Bool {
        return true
    }

}
