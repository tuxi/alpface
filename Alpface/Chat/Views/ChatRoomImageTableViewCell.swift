//
//  ChatRoomImageTableViewCell.swift
//  Alpface
//
//  Created by swae on 2019/7/13.
//  Copyright © 2019 alpface. All rights reserved.
//

import UIKit

class ChatRoomImageTableViewCell: ChatRoomBaseTableViewCell {

    fileprivate lazy var contentImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.isOpaque = true
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 6.0
        return imageView
    }()
    
    
    fileprivate var contentImageViewLeft: NSLayoutConstraint?
    fileprivate var contentImageViewRight: NSLayoutConstraint?
    fileprivate var contentImageViewWidth: NSLayoutConstraint?
    fileprivate var contentImageViewHeight: NSLayoutConstraint?
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setupUI() {
        contentView.addSubview(contentImageView)
        
        contentImageView.translatesAutoresizingMaskIntoConstraints = false
        
        contentImageViewLeft = contentImageView.leadingAnchor.constraint(equalTo: self.avatarImageView.trailingAnchor, constant: kChatRoomGlobalMargin)
        contentImageViewRight = contentImageView.trailingAnchor.constraint(equalTo: self.avatarImageView.leadingAnchor, constant: -kChatRoomGlobalMargin)
        contentImageView.topAnchor.constraint(equalTo: self.avatarImageView.topAnchor, constant: 0.0).isActive = true
        contentImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -kChatRoomGlobalMargin).isActive = true
        contentImageViewWidth = contentImageView.widthAnchor.constraint(equalToConstant: kChatRoomImageMinWidth)
        contentImageViewHeight = contentImageView.heightAnchor.constraint(equalToConstant: kChatRoomImageMinHeight)
        contentImageViewWidth?.isActive = true
        contentImageViewHeight?.isActive = true
        contentImageViewLeft?.isActive = true
        
    }
    override func setContent(_ cellModel: ChatRoomBaseCellModel) {
        super.setContent(cellModel)
        
        // 根据原图尺寸等比获取缩略图的 size
        let originalSize = CGSize(width: cellModel.model!.imageModel!.imageWidth, height: cellModel.model!.imageModel!.imageHeight)
        let image_size =  ChatRoomBaseCellModel.getThumbImageSize(originalSize)
        contentImageViewWidth?.constant = image_size.width
        contentImageViewHeight?.constant = image_size.height
        
        if cellModel.isFromSelf {
            contentImageViewLeft?.isActive = false
            contentImageViewRight?.isActive = true
        }
        else {
            contentImageViewLeft?.isActive = true
            contentImageViewRight?.isActive = false
        }
        
        if let localThumbnailImage = cellModel.model!.imageModel!.localThumbnailImage {
            self.contentImageView.image = localThumbnailImage
        } else {
            self.contentImageView.sd_setImage(with: URL(string: cellModel.model!.imageModel!.thumbURL!))
        }
        
    }
    
}
