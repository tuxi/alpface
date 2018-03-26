//
//  RoundButton.swift
//  Alpface
//
//  Created by swae on 2018/3/27.
//  Copyright © 2018年 alpface. All rights reserved.
//

import UIKit

internal class RoundButton: UIButton {
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.borderWidth = 1.0
        self.layer.borderColor = ProfileViewController.globalTint.cgColor
        self.layer.cornerRadius = 4.0
    }
}

