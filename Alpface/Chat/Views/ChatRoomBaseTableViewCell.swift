//
//  ChatRoomBaseTableViewCell.swift
//  Alpface
//
//  Created by swae on 2019/7/13.
//  Copyright © 2019 alpface. All rights reserved.
//

import UIKit
import SDWebImage

@objc protocol ChatRoomTableViewCellDelegate: NSObjectProtocol {
    /**
     点击了url的回调
     */
    @objc optional func chatRoomTabelViewCell(_ cell: ChatRoomBaseTableViewCell, didTapedLink link: String)
    
    /**
     点击了电话的回调
     */
    @objc optional func chatRoomTabelViewCell(_ cell: ChatRoomBaseTableViewCell, didTapedPhone phone: String)
}

@objc(ALPChatRoomBaseTableViewCell)
class ChatRoomBaseTableViewCell: UITableViewCell {
    
    public lazy var avatarImageView: UIImageView = {
       let imageView  = UIImageView()
        imageView.backgroundColor = UIColor.clear
        return imageView
    }()
    
    public weak var delegate: ChatRoomTableViewCellDelegate?
    
    fileprivate var avatarImageViewLeft: NSLayoutConstraint?
    fileprivate var avatarImageViewRight: NSLayoutConstraint?
    
    public var cellModel: ChatRoomBaseCellModel? {
        didSet {
            let placeholderImage = UIImage(named: "icon_avatar")
            if cellModel!.isFromSelf {
                let avatarURL = AuthenticationManager.shared.loginUser?.getAvatarURL()
                self.avatarImageView.sd_setImage(with: avatarURL, placeholderImage: placeholderImage)
                self.avatarImageViewRight?.isActive = true
                self.avatarImageViewLeft?.isActive = false
            } else {
                let avatarURL = AuthenticationManager.shared.loginUser?.getCoverURL()
                self.avatarImageView.sd_setImage(with: avatarURL, placeholderImage: placeholderImage)
                self.avatarImageViewRight?.isActive = false
                self.avatarImageViewLeft?.isActive = true
            }
            setContent(cellModel!)
            self.setNeedsLayout()
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.avatarImageView.image = nil
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setupUI() {
        self.selectionStyle = .none
        self.contentView.backgroundColor = UIColor.clear
        self.backgroundColor = UIColor.clear
        
        contentView.addSubview(avatarImageView)
        
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        
        avatarImageViewLeft = avatarImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10.0)
        avatarImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0.0).isActive = true
        avatarImageView.widthAnchor.constraint(equalToConstant: 40.0).isActive = true
        avatarImageView.heightAnchor.constraint(equalToConstant: 40.0).isActive = true
        avatarImageViewRight = avatarImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10.0)
        
        
    }
    
    public func setContent(_ cellModel: ChatRoomBaseCellModel) {
        
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
