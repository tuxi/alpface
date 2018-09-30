//
//  MainCameraNavigationController.swift
//  Alpface
//
//  Created by swae on 2018/9/24.
//  Copyright © 2018 alpface. All rights reserved.
//

import UIKit

@objc(AlpMainCameraNavigationController)
class MainCameraNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
