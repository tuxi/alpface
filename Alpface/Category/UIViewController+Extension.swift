//
//  UIViewController+Extension.swift
//  Alpface
//
//  Created by swae on 2018/10/5.
//  Copyright © 2018 alpface. All rights reserved.
//

import UIKit

extension UIViewController {
    @objc class func alp_topViewController() -> UIViewController? {
        
        return self.topViewControllerWithRootViewController(viewController: self.getCurrentWindow()?.rootViewController)
    }
    
    @objc class func topViewControllerWithRootViewController(viewController: UIViewController?) -> UIViewController? {
        
        var rootVC = viewController
        
        if let root = rootVC {
            if root.isKind(of: RootViewController.classForCoder()) {
                let vc = viewController as? RootViewController
                let scrollingContainerVC = vc?.appViewController.scrollingContainer
                // 先判断登录控制器是否弹出
                if let presentedViewController = scrollingContainerVC?.presentedViewController {
                    
                    rootVC = self.topViewControllerWithRootViewController(viewController: presentedViewController)
                }
                else {
                    rootVC = vc?.appViewController.scrollingContainer.displayViewController()
                }
                
            }
            
            if root.isKind(of: HomeFeedViewController.classForCoder()) {
                    // 未modal控制器，则返回当前的播放器控制器
                    let vc = viewController as? HomeFeedViewController
                    rootVC = vc?.displayViewController()
                
            }
            
        }
    
        guard let viewController = rootVC else {
            return nil
        }
        
        if viewController.presentedViewController != nil {
            
            return self.topViewControllerWithRootViewController(viewController: viewController.presentedViewController!)
        }
        else if viewController.isKind(of: UITabBarController.self) == true {
            
            return self.topViewControllerWithRootViewController(viewController: (viewController as! UITabBarController).selectedViewController)
        }
        else if viewController.isKind(of: UINavigationController.self) == true {
            
            return self.topViewControllerWithRootViewController(viewController: (viewController as! UINavigationController).visibleViewController)
        }
        else {
            
            return viewController
        }
    }
    
    // 找到当前显示的window
    class func getCurrentWindow() -> UIWindow? {
        
        // 找到当前显示的UIWindow
        var window: UIWindow? = UIApplication.shared.keyWindow
        /**
         window有一个属性：windowLevel
         当 windowLevel == UIWindowLevelNormal 的时候，表示这个window是当前屏幕正在显示的window
         */
        if window?.windowLevel != UIWindowLevelNormal {
            
            for tempWindow in UIApplication.shared.windows {
                
                if tempWindow.windowLevel == UIWindowLevelNormal {
                    
                    window = tempWindow
                    break
                }
            }
        }
        
        return window
    }
}

