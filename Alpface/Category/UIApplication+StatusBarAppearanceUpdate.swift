//
//  UIApplication+StatusBarAppearanceUpdate.swift
//  Alpface
//
//  Created by swae on 2018/3/12.
//  Copyright © 2018年 alpface. All rights reserved.
//

import UIKit

extension UIApplication {
    
    func setNeedsStatusBarAppearanceUpdate() {
        windows.forEach {
             $0.rootViewController?.setNeedsStatusBarAppearanceUpdate()
        }
    }
}
