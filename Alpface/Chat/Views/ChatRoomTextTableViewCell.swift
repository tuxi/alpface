//
//  ChatRoomTextTableViewCell.swift
//  Alpface
//
//  Created by swae on 2019/7/13.
//  Copyright © 2019 alpface. All rights reserved.
//

import UIKit
import YYText

class ChatRoomTextTableViewCell: ChatRoomBaseTableViewCell {

    // 聊天文本
    fileprivate lazy var contentLabel: ChatRoomTextLabel = {
        let label = ChatRoomTextLabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.debugOption = self.debugYYLabel()
        label.numberOfLines = 0
        label.backgroundColor = UIColor.clear
        label.textVerticalAlignment = YYTextVerticalAlignment.top
        label.displaysAsynchronously = false
        label.ignoreCommonProperties = true
        // 设置此属性， YYLabel使用AutoLayout时才会在intrinsicContentSize方法中自适应宽度和高度
        label.preferredMaxLayoutWidth = kChatRoomTextMaxWidth
        return label
    }()
    
    // 气泡背景
    fileprivate lazy var bubbleImageView: UIImageView = {
       let imageView = UIImageView()
        return imageView
    }()
    
    fileprivate var contentLabelLeft1: NSLayoutConstraint?
    fileprivate var contentLabelRight1: NSLayoutConstraint?
    fileprivate var contentLabelLeft2: NSLayoutConstraint?
    fileprivate var contentLabelRight2: NSLayoutConstraint?
    
    fileprivate func debugYYLabel() -> YYTextDebugOption? {
        return nil
        let debugOptions = YYTextDebugOption()
        debugOptions.baselineColor = UIColor.red;
        debugOptions.ctFrameBorderColor = UIColor.red;
        debugOptions.ctLineFillColor = UIColor ( red: 0.0, green: 0.463, blue: 1.0, alpha: 0.18 )
        debugOptions.cgGlyphBorderColor = UIColor ( red: 0.9971, green: 0.6738, blue: 1.0, alpha: 0.360964912280702 )
        return debugOptions
    }
    
    override func setContent(_ cellModel: ChatRoomBaseCellModel) {
        super.setContent(cellModel)
        
        self.contentLabel.font = cellModel.contentTextFont
        if cellModel.isFromSelf {
            contentLabelLeft2?.isActive = true
            contentLabelRight2?.isActive = true
            contentLabelLeft1?.isActive = false
            contentLabelRight1?.isActive = false
        }
        else {
            contentLabelLeft2?.isActive = false
            contentLabelRight2?.isActive = false
            contentLabelLeft1?.isActive = true
            contentLabelRight1?.isActive = true
        }
        
        if let richTextLinePositionModifier = cellModel.attributedTextLinePositionModifier {
            self.contentLabel.linePositionModifier = richTextLinePositionModifier
        }
        
        if let richTextLayout = cellModel.attributedTextLayout {
            self.contentLabel.textLayout = richTextLayout
        }
        
        if let richTextAttributedString = cellModel.attributedText {
            self.contentLabel.attributedText = richTextAttributedString
        }
        
        
        self.bubbleImageView.image = cellModel.bubbleImage;
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setupUI() {
        contentView.addSubview(bubbleImageView)
        contentView.addSubview(contentLabel)
        
        bubbleImageView.translatesAutoresizingMaskIntoConstraints = false
        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentLabelLeft1 = contentLabel.leadingAnchor.constraint(equalTo: self.avatarImageView.trailingAnchor, constant: kChatRoomGlobalMargin*2)
        contentLabelRight1 = contentLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -kChatRoomTextMinMargin)
        contentLabelRight2 = contentLabel.trailingAnchor.constraint(equalTo: self.avatarImageView.leadingAnchor, constant: -kChatRoomGlobalMargin*2)
        contentLabelLeft2 = contentLabel.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: kChatRoomTextMinMargin)
        
        contentLabel.topAnchor.constraint(equalTo: self.bubbleImageView.topAnchor, constant: kChatRoomGlobalMargin/2).isActive = true
        contentLabel.bottomAnchor.constraint(equalTo: self.bubbleImageView.bottomAnchor, constant: -kChatRoomGlobalMargin).isActive = true
        
        bubbleImageView.topAnchor.constraint(equalTo: self.avatarImageView.topAnchor, constant: 0.0).isActive = true
        bubbleImageView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -kChatRoomGlobalMargin).isActive = true
        bubbleImageView.leadingAnchor.constraint(equalTo: self.contentLabel.leadingAnchor, constant: -kChatRoomGlobalMargin).isActive = true
        bubbleImageView.trailingAnchor.constraint(equalTo: self.contentLabel.trailingAnchor, constant: kChatRoomGlobalMargin).isActive = true
        
        self.contentLabel.highlightTapAction = { [weak self] (containerView, text, range, rect) in
            
            self?.didTapContentLabelText(self?.contentLabel, textRange: range)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    /**
     解析点击文字
     
     - parameter label:     YYLabel
     - parameter textRange: 高亮文字的 NSRange，不是 range
     */
    fileprivate func didTapContentLabelText(_ label: YYLabel?, textRange: NSRange) {
        guard let label = label else {
            return
        }
        //解析 userinfo 的文字
        let attributedString = label.textLayout!.text
        if textRange.location >= attributedString.length {
            return
        }
        guard let hightlight: YYTextHighlight = attributedString.yy_attribute(YYTextHighlightAttributeName, at: UInt(textRange.location)) as? YYTextHighlight else {
            return
        }
        guard let info = hightlight.userInfo, info.count > 0 else {
            return
        }
        
        guard let delegate = self.delegate else {
            return
        }
        
        if let phone: String = info[kChatRoomTextKeyPhone] as? String {
            if delegate.responds(to: #selector(delegate.chatRoomTabelViewCell(_:didTapedPhone:))) {
                delegate.chatRoomTabelViewCell!(self, didTapedPhone: phone)
            }
        }
        
        if let url: String = info[kChatRoomTextKeyURL] as? String {
            if delegate.responds(to: #selector(delegate.chatRoomTabelViewCell(_:didTapedLink:))) {
                delegate.chatRoomTabelViewCell!(self, didTapedLink: url)
            }
        }
    }
}
