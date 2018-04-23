//
//  MainTabBarController.swift
//  Alpface
//
//  Created by swae on 2018/3/11.
//  Copyright © 2018年 alpface. All rights reserved.
//

import UIKit

extension UIImage{
    class func drawTabBarIndicator(color: UIColor, size: CGSize, onTop: Bool) -> UIImage {
        let indicatorHeight = size.height / 30
        let yPosition = onTop ? 0 : (size.height - indicatorHeight - 5.0)
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(CGRect(x: 0, y: yPosition, width: size.width, height: indicatorHeight))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }
}

class MainTabBarController: UITabBarController {
    
    @IBInspectable var indicatorColor: UIColor = UIColor.white

    @IBInspectable var onTopIndicator: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.clear
        // Do any additional setup after loading the view.
        UITabBarItem.appearance(whenContainedInInstancesOf: [MainTabBarController.self]).setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.white.withAlphaComponent(0.8), NSAttributedStringKey.font: UIFont.systemFont(ofSize: 17.0)], for:.normal)
        UITabBarItem.appearance(whenContainedInInstancesOf: [MainTabBarController.self]).setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.white, NSAttributedStringKey.font: UIFont.systemFont(ofSize: 18.0)], for:.selected)
        
        self.view.layer.cornerRadius = 8.0
        self.view.layer.masksToBounds = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        guard let numberOfTabs = tabBar.items?.count else {
            return
        }
        
        let numberOfTabsFloat = CGFloat(numberOfTabs)
        let imageSize = CGSize(width: tabBar.frame.width / numberOfTabsFloat,
                               height: tabBar.frame.height)
        
        
        let indicatorImage = UIImage.drawTabBarIndicator(color: indicatorColor,
                                                         size: CGSize.init(width: imageSize.width-imageSize.width*0.6, height: imageSize.height),
                                                         onTop: onTopIndicator)
        self.tabBar.selectionIndicatorImage = indicatorImage
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override var preferredStatusBarStyle: UIStatusBarStyle {
        guard let selectedViewController = selectedViewController else { return .default }
        return selectedViewController.preferredStatusBarStyle
    }
    
    override var prefersStatusBarHidden: Bool {
        guard let selectedViewController = selectedViewController else { return false }
        return selectedViewController.prefersStatusBarHidden
    }

}


