//
//  MainTabBarController.swift
//  Alpface
//
//  Created by swae on 2018/3/11.
//  Copyright © 2018年 alpface. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
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
