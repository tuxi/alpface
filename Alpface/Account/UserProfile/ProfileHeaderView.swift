//
//  ProfileHeaderView.swift
//  Alpface
//
//  Created by swae on 2018/3/27.
//  Copyright © 2018年 alpface. All rights reserved.
//

import UIKit


internal class RoundButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    fileprivate func setupUI() {
        self.backgroundColor = BaseProfileViewController.globalTint
        self.layer.masksToBounds = true
        self.setTitleColor(UIColor.white, for: .normal)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = self.frame.size.height * 0.5
    }
}

internal class ProfileIconView: UIImageView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    fileprivate func setupUI() {
        //        self.layer.cornerRadius = 8.0
        self.layer.borderWidth = 3.0
        self.layer.borderColor = UIColor.white.cgColor
        self.clipsToBounds = true
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = self.frame.size.width * 0.5
    }
}


@objc(ALPProfileHeaderView)
open class ProfileHeaderView: UIView {
    var iconHeightConstraint: NSLayoutConstraint?
    lazy var iconImageView: ProfileIconView = {
        let imageView = ProfileIconView.init(frame: .zero)
        imageView.backgroundColor = UIColor.lightGray
        return imageView
    }()
    lazy var locationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14.0)
        label.textColor = UIColor.brown.withAlphaComponent(0.8)
        return label
    }()
    lazy var contentView: UIView = {
        let contentView = UIView()
        contentView.backgroundColor = UIColor.clear
        return contentView
    }()
    lazy var praiseLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.black
        label.font = UIFont.systemFont(ofSize: 14.0)
        return label
    }()
    lazy var followingLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.black
        label.font = UIFont.systemFont(ofSize: 14.0)
        return label
    }()
    lazy var followersLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.black
        label.font = UIFont.systemFont(ofSize: 14.0)
        return label
    }()
    lazy var nicknameLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.black
        label.font = UIFont.systemFont(ofSize: 17, weight: UIFont.Weight(rawValue: 1.0))
        return label
    }()
    lazy var usernameLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.lightGray
        label.font = UIFont.systemFont(ofSize: 14.0)
        return label
    }()
    
    lazy var summaryLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.darkGray
        label.font = UIFont.systemFont(ofSize: 15.0)
        label.numberOfLines = 0
        return label
    }()
    
    lazy var followButton: RoundButton = {
        let button = RoundButton(type: .system)
        return button
    }()
    
    lazy var labelContentView: UIView = {
        let view = UIView()
        return view
    }()
    
    let maxHeight: CGFloat = 80
    let minHeight: CGFloat = 50
    
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
        self.contentView.addSubview(self.followButton)
        self.addSubview(self.labelContentView)
        self.labelContentView.addSubview(self.locationLabel)
        self.labelContentView.addSubview(self.praiseLabel)
        self.labelContentView.addSubview(self.followingLabel)
        self.labelContentView.addSubview(self.followersLabel)
        self.labelContentView.addSubview(self.nicknameLabel)
        self.labelContentView.addSubview(self.usernameLabel)
        self.labelContentView.addSubview(self.summaryLabel)
        
        self.contentView.translatesAutoresizingMaskIntoConstraints = false
        self.labelContentView.translatesAutoresizingMaskIntoConstraints = false
        self.iconImageView.translatesAutoresizingMaskIntoConstraints = false
        self.followButton.translatesAutoresizingMaskIntoConstraints = false
        self.locationLabel.translatesAutoresizingMaskIntoConstraints = false
        self.praiseLabel.translatesAutoresizingMaskIntoConstraints = false
        self.followingLabel.translatesAutoresizingMaskIntoConstraints = false
        self.followersLabel.translatesAutoresizingMaskIntoConstraints = false
        self.nicknameLabel.translatesAutoresizingMaskIntoConstraints = false
        self.usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        self.summaryLabel.translatesAutoresizingMaskIntoConstraints = false
        self.locationLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        self.praiseLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        self.nicknameLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        self.usernameLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        self.summaryLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        
        self.contentView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        self.contentView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        self.contentView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        self.contentView.heightAnchor.constraint(equalToConstant: 55.0).isActive = true
        
        self.labelContentView.topAnchor.constraint(equalTo: self.contentView.bottomAnchor).isActive = true
        self.labelContentView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        self.labelContentView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        self.labelContentView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0.0).isActive = true
        
        self.iconImageView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 12.0).isActive = true
        self.iconHeightConstraint = self.iconImageView.heightAnchor.constraint(equalToConstant: 50.0)
        self.iconHeightConstraint?.isActive = true
        self.iconImageView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: 0.0).isActive = true
        self.iconImageView.widthAnchor.constraint(equalTo: self.iconImageView.heightAnchor, constant: 0.0).isActive = true
        
        self.followButton.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -16.0).isActive = true
        self.followButton.widthAnchor.constraint(equalToConstant: 100.0).isActive = true
        self.followButton.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor).isActive = true
        
        self.nicknameLabel.leadingAnchor.constraint(equalTo: self.labelContentView.leadingAnchor, constant: 16.0).isActive = true
        self.nicknameLabel.topAnchor.constraint(equalTo: self.labelContentView.topAnchor, constant: 8.0).isActive = true
        self.nicknameLabel.trailingAnchor.constraint(lessThanOrEqualTo: self.labelContentView.trailingAnchor, constant: -16.0).isActive = true
        self.usernameLabel.leadingAnchor.constraint(equalTo: self.nicknameLabel.leadingAnchor).isActive = true
        self.usernameLabel.topAnchor.constraint(lessThanOrEqualTo: self.nicknameLabel.bottomAnchor, constant: 0.0).isActive = true
        self.usernameLabel.trailingAnchor.constraint(lessThanOrEqualTo: self.trailingAnchor, constant: -16.0).isActive = true
        
        self.summaryLabel.leadingAnchor.constraint(equalTo: self.usernameLabel.leadingAnchor).isActive = true
        self.summaryLabel.topAnchor.constraint(equalTo: self.usernameLabel.bottomAnchor, constant: 8.0).isActive = true
        self.summaryLabel.trailingAnchor.constraint(equalTo: self.labelContentView.trailingAnchor, constant: -16.0).isActive = true
        
        self.locationLabel.leadingAnchor.constraint(equalTo: self.nicknameLabel.leadingAnchor).isActive = true
        self.locationLabel.topAnchor.constraint(equalTo: self.summaryLabel.bottomAnchor, constant: 8.0).isActive = true
        self.locationLabel.trailingAnchor.constraint(lessThanOrEqualTo: self.trailingAnchor, constant: -16.0).isActive = true
        
        self.praiseLabel.leadingAnchor.constraint(equalTo: self.nicknameLabel.leadingAnchor).isActive = true
        self.praiseLabel.bottomAnchor.constraint(equalTo: self.labelContentView.bottomAnchor, constant: -8.0).isActive = true
        self.praiseLabel.topAnchor.constraint(equalTo: self.locationLabel.bottomAnchor, constant: 8.0).isActive = true
        
        self.followingLabel.leadingAnchor.constraint(equalTo: self.praiseLabel.trailingAnchor, constant: 8.0).isActive = true
        self.followingLabel.centerYAnchor.constraint(equalTo: self.praiseLabel.centerYAnchor, constant: 0.0).isActive = true
        
        self.followersLabel.leadingAnchor.constraint(equalTo: self.followingLabel.trailingAnchor, constant: 8.0).isActive = true
        self.followersLabel.centerYAnchor.constraint(equalTo: self.praiseLabel.centerYAnchor, constant: 0.0).isActive = true
        self.followersLabel.trailingAnchor.constraint(lessThanOrEqualTo: self.trailingAnchor, constant: -16.0).isActive = true
        
        self.iconHeightConstraint!.constant = maxHeight
        self.praiseLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        self.followingLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        self.followersLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        self.praiseLabel.setContentHuggingPriority(.required, for: .horizontal)
        self.followingLabel.setContentHuggingPriority(.required, for: .horizontal)
        self.followersLabel.setContentHuggingPriority(.required, for: .horizontal)
        
        self.iconImageView.image = UIImage(named: "icon")
        self.followButton.setTitle("Follow", for: .normal)
        self.followingLabel.text = "200关注"
        self.followersLabel.text = "300粉丝"
        self.praiseLabel.text = "100赞"
        self.locationLabel.text = "北京市朝阳区"
        self.nicknameLabel.text = "alpface"
        self.usernameLabel.text = "xiaoyuan"
        self.summaryLabel.text = "This is xiaoyuan. Singer from Beijing. 大家好，我是孝远，欢迎交流"
        
    }

    
    func animator(t: CGFloat) {
        
        if t < 0 {
            iconHeightConstraint!.constant = maxHeight
            return
        }
        
        let height = max(maxHeight - (maxHeight - minHeight) * t, minHeight)
        
        iconHeightConstraint!.constant = height
    }
    
    override open func sizeThatFits(_ size: CGSize) -> CGSize {
        
        let newSize = self.systemLayoutSizeFitting(UILayoutFittingExpandedSize)
        return CGSize(width: size.width, height: newSize.height)
    }
    
}

