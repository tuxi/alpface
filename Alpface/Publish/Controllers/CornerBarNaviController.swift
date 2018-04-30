//
//  CornerBarNaviController.swift
//  Alpface
//
//  Created by swae on 2018/4/22.
//  Copyright © 2018年 alpface. All rights reserved.
//

import UIKit

@objc(ALPCornerBarNaviController)
class CornerBarNaviController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.layer.cornerRadius = 8.0
        self.view.layer.masksToBounds = true
    }
}

