//
//  StickyHeaderContainerView.swift
//  Alpface
//
//  Created by swae on 2018/4/10.
//  Copyright © 2018年 alpface. All rights reserved.
//

import UIKit

/// 头部背景视图的高度 (固定值)
let stickyheaderContainerViewHeight: CGFloat = 150

open class StickyHeaderContainerView: UIView {

    open lazy var headerCoverView: UIImageView = {
        let coverImageView = UIImageView()
        coverImageView.clipsToBounds = true
        coverImageView.translatesAutoresizingMaskIntoConstraints = false
        coverImageView.image = UIImage(named: "Firewatch.png")
        coverImageView.contentMode = .scaleAspectFill
        coverImageView.backgroundColor = BaseProfileViewController.globalTint
        return coverImageView
    }()
    
    open lazy var blurEffectView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .dark)
        let _blurEffectView = UIVisualEffectView(effect: blurEffect)
        _blurEffectView.alpha = 0
        return _blurEffectView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    fileprivate func setupUI() {
        self.clipsToBounds = true
        // Cover Image View
        self.addSubview(headerCoverView)
        headerCoverView.translatesAutoresizingMaskIntoConstraints = false
        headerCoverView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        headerCoverView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        headerCoverView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        headerCoverView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
        
        // blur effect on top of coverImageView
        self.addSubview(blurEffectView)
        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
        blurEffectView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        blurEffectView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        blurEffectView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        blurEffectView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    }
}
