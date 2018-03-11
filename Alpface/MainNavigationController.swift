//
//  MainNavigationController.swift
//  Alpface
//
//  Created by swae on 2018/3/11.
//  Copyright © 2018年 alpface. All rights reserved.
//

import UIKit

class MainNavigationController: UINavigationController {

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setNavBarAtrributes()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override var preferredStatusBarStyle: UIStatusBarStyle {
        guard let topVc = topViewController else { return .default }
        return topVc.preferredStatusBarStyle
    }
    
    override var childViewControllerForStatusBarStyle: UIViewController? {
        guard let topVc = topViewController else { return nil }
        return topVc
    }

}

extension MainNavigationController{
    
    fileprivate func setNavBarAtrributes(){
        
        navigationBar.setGradientBackground(colors: [UIColor(hex: "833AB4"), UIColor(hex: "FD1D1D"), UIColor(hex: "FCB045")])
        
        navigationBar.isTranslucent = false
    }
    
}
