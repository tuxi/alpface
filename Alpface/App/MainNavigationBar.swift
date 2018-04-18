//
//  MainNavigationBar.swift
//  Alpface
//
//  Created by xiaoyuan on 2018/4/18.
//  Copyright © 2018年 alpface. All rights reserved.
//

import UIKit

@objc(ALPMainNavigationBar)
class MainNavigationBar: UINavigationBar {

    // 设置NavigationBar的高度，用于固定导航的高度，不受status bar隐藏显示的影响
    // 对于iphonex，建议设置最小高度为88或更高
    var customHeight : CGFloat = 66.0
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        
        return CGSize(width: size.width, height: customHeight)
        
    }
    override var frame: CGRect {
        didSet {
            var newFrame = frame
            newFrame.origin.y = 0.0
            newFrame.size.height = customHeight
            super.frame = newFrame
        }
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let newFrame = CGRect(x: frame.origin.x, y:  0, width: frame.size.width, height: customHeight)
        // 防止死循环
        if newFrame.equalTo(self.frame) == false {
            self.frame = newFrame
        }
        
        // 调整title的位置：title position (statusbar height / 2)
//        setTitleVerticalPositionAdjustment(-10, for: UIBarMetrics.default)
        
        for subview in self.subviews {
            let stringFromClass = NSStringFromClass(subview.classForCoder)
            if stringFromClass.contains("BarBackground") {
                subview.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: customHeight)
            }
            
            if stringFromClass.contains("BarContent") {
                subview.frame = CGRect(x: subview.frame.origin.x, y: 20, width: subview.frame.width, height: customHeight - 20)
            }
        }
    }

}
