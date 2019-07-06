//
//  EditProfileHeaderView.swift
//  Alpface
//
//  Created by swae on 2018/4/10.
//  Copyright © 2018年 alpface. All rights reserved.
//

import UIKit

open class EditProfileHeaderView: UIView {
    
    open var iconImageViewClickAcllBack: (() ->Void)?
    
    open lazy var iconImageView: UIImageView = {
        let imageView = ProfileIconView.init(frame: .zero)
        imageView.backgroundColor = UIColor.lightGray
        imageView.isUserInteractionEnabled =  true
        return imageView
    }()
    
    fileprivate lazy var changeIconButton: UIButton = {
        let button = UIButton(type: .custom)
        button.imageEdgeInsets = UIEdgeInsets(top: 20.0, left: 20.0, bottom: 20.0, right: 20.0)
        button.imageView?.contentMode = .scaleAspectFit
        button.setImage(UIImage(named: "icon_personal_changephoto"), for: .normal)
        button.addTarget(self, action: #selector(changeIconButtonClick), for: .touchUpInside)
        return button
    }()
    
    fileprivate lazy var bottomLineView: UIView = {
        let view = UIView()
        view.backgroundColor = AppTheme.cellBottomLineColor
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
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }

    fileprivate func setupUI() {
        self.addSubview(self.contentView)
        self.contentView.addSubview(self.iconImageView)
        self.contentView.addSubview(self.bottomLineView)
        self.iconImageView.addSubview(self.changeIconButton)
        self.contentView.translatesAutoresizingMaskIntoConstraints = false
        self.iconImageView.translatesAutoresizingMaskIntoConstraints = false
        self.bottomLineView.translatesAutoresizingMaskIntoConstraints = false
        self.changeIconButton.translatesAutoresizingMaskIntoConstraints = false
        
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
        
        self.changeIconButton.centerXAnchor.constraint(equalTo: self.iconImageView.centerXAnchor).isActive = true
        self.changeIconButton.centerYAnchor.constraint(equalTo: self.iconImageView.centerYAnchor).isActive = true
        self.changeIconButton.widthAnchor.constraint(equalTo: self.iconImageView.widthAnchor, multiplier: 1.0).isActive = true
        self.changeIconButton.heightAnchor.constraint(equalTo: self.iconImageView.heightAnchor, multiplier: 1.0).isActive = true
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
        
        let newSize = self.contentView.systemLayoutSizeFitting(UIView.layoutFittingExpandedSize)
        return CGSize(width: size.width, height: newSize.height)
    }
    
    @objc fileprivate func changeIconButtonClick() {
        if let callback = self.iconImageViewClickAcllBack {
            callback()
        }
    }
}
