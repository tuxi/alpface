//
//  AppUtils.swift
//  Alpface
//
//  Created by swae on 2018/4/14.
//  Copyright © 2018年 alpface. All rights reserved.
//

import UIKit
import UserNotifications
class AppUtils: NSObject {
    
    // 禁止实例化
    private override init(){
    }
    
    // 用户通知权限请求
    static func requestUserNotification() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (accepted, error) in
            if !accepted {
                print("用户不允许消息通知!")
            }
        }
    }

    
    // 震动反馈
    @available(iOS 10.0, *)
    static func tapped(type: Int) {
        switch type {
        case 1:
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
        case 2:
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        case 3:
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.warning)
        case 4:
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        case 5:
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
        case 6:
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
        default:
            let generator = UISelectionFeedbackGenerator()
            generator.selectionChanged()
        }
    }
    
    // Bundle ID
    static func bundleId() -> String {
        return Bundle.main.bundleIdentifier!
    }
    
    /// 判断机型是否为 iPhone X、XR、XS、XS Max 的方法
    /// 原理是根据手机底部安全区的高度 判断是否为 iPhone X、XR、XS、XS Max 几款机型
    static func isIPhoneX() -> Bool {
        if #available(iOS 11.0, *) {
            if let delegate = UIApplication.shared.delegate {
                if let window = delegate.window {
                    let safeAreaInsets = window?.safeAreaInsets
                    if let bottom = safeAreaInsets?.bottom  {
                        if bottom > 0.0 {
                            return true
                        }
                    }
                }
            }
        }
        return false
    }
}
