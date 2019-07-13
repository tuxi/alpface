//
//  MessageTableViewCell.swift
//  Alpface
//
//  Created by swae on 2019/7/13.
//  Copyright © 2019 alpface. All rights reserved.
//

import UIKit

fileprivate class UnreadNumButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.titleLabel?.numberOfLines = 1
        self.isUserInteractionEnabled = false
        self.titleLabel?.font = UIFont.systemFont(ofSize: 12.0)
        self.setTitleColor(UIColor.init(white: 1.0, alpha: 1.0), for: .normal)
        self.titleLabel?.lineBreakMode = NSLineBreakMode.byTruncatingTail
        self.backgroundColor = UIColor.init(red: 0.95, green: 0.2, blue: 0.11, alpha: 1.0)
        self.contentEdgeInsets = UIEdgeInsets(top: 0.0, left: 2.0, bottom: 0.0, right: 2.0)
        self.layer.masksToBounds = true
        
        self.layer.cornerRadius = 14.0 / 2
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class MessageTableViewCell: UITableViewCell {
    
    fileprivate lazy var avatarView: UIImageView = {
       let imageView = UIImageView()
        return imageView
    }()
    
    fileprivate lazy var unreadNumButton: UnreadNumButton = {
       let button = UnreadNumButton()
        
        return button
    }()
    
    fileprivate lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12.0)
        label.numberOfLines = 1
        label.textColor = UIColor.init(white: 0.7, alpha: 1.0)
        label.lineBreakMode = NSLineBreakMode.byTruncatingTail
        return label
    }()
    
    fileprivate lazy var nickNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15.0)
        label.numberOfLines = 1
        label.textColor = UIColor.init(white: 1.0, alpha: 1.0)
        label.lineBreakMode = NSLineBreakMode.byTruncatingTail
        return label
    }()
    
    fileprivate lazy var lastMessageLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12.0)
        label.numberOfLines = 1
        label.textColor = UIColor.init(white: 0.7, alpha: 1.0)
        label.lineBreakMode = NSLineBreakMode.byTruncatingTail
        return label
    }()
    
    public var model: MessageModel? {
        didSet {
            guard let model = model else {
                self.unreadNumButton.setTitle(nil, for: .normal)
                    self.nickNameLabel.text = nil
                self.lastMessageLabel.text = nil
                self.avatarView.image = UIImage(named: "icon_avatar")
                self.dateLabel.text = nil
                return
            }
            if model.unReadNum > 99 {
                self.unreadNumButton.setTitle("\(99)+", for: .normal)
            }
            else {
                self.unreadNumButton.setTitle("\(model.unReadNum)+", for: .normal)
            }
            
            self.nickNameLabel.text = model.nickname
            self.lastMessageLabel.text = model.latestMessage
            self.avatarView.image = model.messageFromType.placeHolderImage
            self.dateLabel.text = model.dateString
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setupUI() {
        contentView.addSubview(avatarView)
        contentView.addSubview(unreadNumButton)
        contentView.addSubview(dateLabel)
        contentView.addSubview(nickNameLabel)
        contentView.addSubview(lastMessageLabel)
        
        contentView.backgroundColor = .clear
        backgroundColor = .clear
        
        avatarView.translatesAutoresizingMaskIntoConstraints = false
        unreadNumButton.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        nickNameLabel.translatesAutoresizingMaskIntoConstraints = false
        lastMessageLabel.translatesAutoresizingMaskIntoConstraints = false

        avatarView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10.0).isActive = true
        avatarView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12.0).isActive = true
        avatarView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12.0).isActive = true
        avatarView.widthAnchor.constraint(equalToConstant: 50.0).isActive = true
        avatarView.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
        
        dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10.0).isActive = true
        dateLabel.centerYAnchor.constraint(equalTo: nickNameLabel.centerYAnchor, constant: 0.0).isActive = true
        
        nickNameLabel.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 10.0).isActive = true
        nickNameLabel.bottomAnchor.constraint(equalTo: avatarView.centerYAnchor, constant: -2.0).isActive = true
        nickNameLabel.trailingAnchor.constraint(lessThanOrEqualTo: dateLabel.leadingAnchor, constant: -10.0).isActive = true
        
        lastMessageLabel.topAnchor.constraint(equalTo: avatarView.centerYAnchor, constant: 2.0).isActive = true
        lastMessageLabel.leadingAnchor.constraint(equalTo: nickNameLabel.leadingAnchor, constant: 0.0).isActive = true
        lastMessageLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -10.0).isActive = true
        
        unreadNumButton.centerYAnchor.constraint(equalTo: avatarView.topAnchor, constant: 5.0).isActive = true
        unreadNumButton.centerXAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: -5.0).isActive = true
        

        self.avatarView.layer.masksToBounds = true
        self.avatarView.layer.cornerRadius = 50.0 / 2
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
