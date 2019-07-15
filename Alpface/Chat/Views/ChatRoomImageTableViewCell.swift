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
        return imageView
    }()
    
    fileprivate lazy var bubbleImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.isOpaque = true
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
        contentView.addSubview(bubbleImageView)
        
        contentImageView.translatesAutoresizingMaskIntoConstraints = false
        bubbleImageView.translatesAutoresizingMaskIntoConstraints = false
        
        contentImageViewLeft = contentImageView.leadingAnchor.constraint(equalTo: self.avatarImageView.trailingAnchor, constant: 20.0)
        contentImageViewRight = contentImageView.trailingAnchor.constraint(equalTo: self.avatarImageView.leadingAnchor, constant: -20.0)
        contentImageView.topAnchor.constraint(equalTo: self.avatarImageView.topAnchor, constant: 0.0).isActive = true
        contentImageView.bottomAnchor.constraint(equalTo: bubbleImageView.bottomAnchor, constant: -2.0).isActive = true
        contentImageViewWidth = contentImageView.widthAnchor.constraint(equalToConstant: kChatRoomImageMinWidth)
        contentImageViewHeight = contentImageView.heightAnchor.constraint(equalToConstant: kChatRoomImageMinHeight)
        contentImageViewWidth?.isActive = true
        contentImageViewHeight?.isActive = true
        
        bubbleImageView.leadingAnchor.constraint(equalTo: self.contentImageView.leadingAnchor, constant: -1.0).isActive = true
        bubbleImageView.topAnchor.constraint(equalTo: self.contentImageView.topAnchor).isActive = true
        bubbleImageView.trailingAnchor.constraint(equalTo: contentImageView.trailingAnchor, constant: 1.0).isActive = true
        bubbleImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10.0).isActive = true
        
    }
    override func setContent(_ cellModel: ChatRoomBaseCellModel) {
        super.setContent(cellModel)
        
        // 根据原图尺寸等比获取缩略图的 size
        let originalSize = CGSize(width: cellModel.model!.imageModel!.imageWidth, height: cellModel.model!.imageModel!.imageHeight)
        let size =  ChatRoomBaseCellModel.getThumbImageSize(originalSize)
        contentImageViewWidth?.constant = size.width
        contentImageViewHeight?.constant = size.height
        
        if cellModel.isFromSelf {
            contentImageViewLeft?.isActive = false
            contentImageViewRight?.isActive = true
        }
        else {
            contentImageViewLeft?.isActive = true
            contentImageViewRight?.isActive = false
        }
        
        self.contentImageView.layer.mask = cellModel.imageContentMaskLayer
        
        self.bubbleImageView.image = cellModel.imageContentBubbleImage
        
        if let localThumbnailImage = cellModel.model!.imageModel!.localThumbnailImage {
            self.contentImageView.image = localThumbnailImage
        } else {
            self.contentImageView.sd_setImage(with: URL(string: cellModel.model!.imageModel!.thumbURL!))
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
