//
//  ProfileHeaderView.swift
//  Alpface
//
//  Created by swae on 2018/3/27.
//  Copyright © 2018年 alpface. All rights reserved.
//

import UIKit

class ProfileHeaderView: UIView {
    @IBOutlet weak var iconHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var usernameLabel:
    UILabel!
    @IBOutlet weak var nicknameLabel:
    UILabel!
    
    let maxHeight: CGFloat = 80
    let minHeight: CGFloat = 50
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.iconHeightConstraint.constant = maxHeight
    }
    
    func animator(t: CGFloat) {
        //    print(t)
        
        if t < 0 {
            iconHeightConstraint.constant = maxHeight
            return
        }
        
        let height = max(maxHeight - (maxHeight - minHeight) * t, minHeight)
        
        iconHeightConstraint.constant = height
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        descriptionLabel.sizeToFit()
        let bottomFrame = descriptionLabel.frame
        let iSize = descriptionLabel.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
        let resultSize = CGSize.init(width: size.width, height: bottomFrame.origin.y + iSize.height)
        return resultSize
    }
}

