//
//  ChatRoomDateTimeTableViewCell.swift
//  Alpface
//
//  Created by swae on 2019/7/13.
//  Copyright © 2019 alpface. All rights reserved.
//

import UIKit

class ChatRoomDateTimeTableViewCell: UITableViewCell {
    
    fileprivate lazy var timeLabel: UIButton = {
        let label = UIButton()
        label.layer.cornerRadius = 4
        label.layer.masksToBounds = true
        label.setTitleColor(UIColor.white, for: .normal)
        label.titleLabel?.font = UIFont.systemFont(ofSize: 11.0)
        label.titleLabel?.numberOfLines = 1
        label.isUserInteractionEnabled = false
        label.backgroundColor = UIColor (red: 190/255.0, green: 190/255.0, blue: 190/255.0, alpha: 0.6 )
        label.contentEdgeInsets = UIEdgeInsets(top: 2.0, left: 2.0, bottom: 2.0, right: 2.0)
        return label
    }()
    
    public var cellModel: ChatRoomBaseCellModel? {
        didSet {
            self.timeLabel.setTitle(cellModel?.model?.messageContent, for: .normal)
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setupUI() {
        selectionStyle = .none
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        
        contentView.addSubview(timeLabel)
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        timeLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: 0.0).isActive = true
        timeLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor, constant: 0.0).isActive = true
        timeLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: kChatRoomGlobalMargin).isActive = true
        timeLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -kChatRoomGlobalMargin).isActive = true
        timeLabel.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: kChatRoomGlobalMargin).isActive = true
        timeLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -kChatRoomGlobalMargin).isActive = true
    }
}
