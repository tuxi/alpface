//
//  EditProfileHeaderView.swift
//  Alpface
//
//  Created by swae on 2018/4/10.
//  Copyright © 2018年 alpface. All rights reserved.
//

import UIKit

class EditProfileHeaderView: UIView {
    
    fileprivate lazy var iconImageView: ProfileIconView = {
        let imageView = ProfileIconView.init(frame: .zero)
        imageView.backgroundColor = UIColor.lightGray
        return imageView
    }()
    
    fileprivate lazy var bottomLineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 220/255.0, green: 220/255.0, blue: 220/255.0, alpha: 1.0)
        return view
    }()
    
    fileprivate lazy var contentView: UIView = {
        let contentView = UIView()
        contentView.backgroundColor = UIColor.clear
        return contentView
    }()
    fileprivate var iconHeightConstraint: NSLayoutConstraint?
    let iconMaxHeight: CGFloat = 80
    let iconMinHeight: CGFloat = 50
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }

    fileprivate func setupUI() {
        self.addSubview(self.contentView)
        self.contentView.addSubview(self.iconImageView)
        self.contentView.addSubview(self.bottomLineView)
        self.contentView.translatesAutoresizingMaskIntoConstraints = false
        self.iconImageView.translatesAutoresizingMaskIntoConstraints = false
        self.bottomLineView.translatesAutoresizingMaskIntoConstraints = false
        
        self.contentView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        self.contentView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        self.contentView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        self.contentView.heightAnchor.constraint(equalToConstant: 55.0).isActive = true
        

        self.iconImageView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 12.0).isActive = true
        self.iconHeightConstraint = self.iconImageView.heightAnchor.constraint(equalToConstant: 50.0)
        self.iconHeightConstraint?.isActive = true
        self.iconImageView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: 0.0).isActive = true
        self.iconImageView.widthAnchor.constraint(equalTo: self.iconImageView.heightAnchor, constant: 0.0).isActive = true
        
        self.bottomLineView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 0.0).isActive = true
        self.bottomLineView.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        self.bottomLineView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: 0.0).isActive = true
        self.bottomLineView.widthAnchor.constraint(equalTo: self.contentView.widthAnchor, constant: 0.0).isActive = true
    }
    
    func animator(t: CGFloat) {
        
        if t < 0 {
            iconHeightConstraint!.constant = iconMaxHeight
            return
        }
        
        let height = max(iconMaxHeight - (iconMaxHeight - iconMinHeight) * t, iconMinHeight)
        
        iconHeightConstraint!.constant = height
    }
    
    override open func sizeThatFits(_ size: CGSize) -> CGSize {
        
        let newSize = self.contentView.systemLayoutSizeFitting(UILayoutFittingExpandedSize)
        return CGSize(width: size.width, height: newSize.height)
    }
}
