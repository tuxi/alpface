//
//  UIView+XYExtension.swift
//  Alpface
//
//  Created by swae on 2018/4/22.
//  Copyright © 2018年 alpface. All rights reserved.
//

import UIKit

extension UIView {
    /// 确定当前视图是否在显示
    public func isVisibleOnKeyWindow() -> Bool {
        let keyWindow = UIApplication.shared.keyWindow
        // 把这个view在它的父控件中的frame(即默认的frame)转换成在window的frame
        let convertFrame = self.superview?.convert(self.frame, to: keyWindow)
        if let windowBounds = keyWindow?.bounds {
            // 判断这个控件是否在主窗口上（即该控件和keyWindow有没有交叉）
            if let isOnWindow = convertFrame?.intersects(windowBounds) {
                let isShowingOnWindow = self.window == keyWindow && !self.isHidden && self.alpha > 0.01 && isOnWindow
                return isShowingOnWindow
            }
        }
        return false
    }
}
