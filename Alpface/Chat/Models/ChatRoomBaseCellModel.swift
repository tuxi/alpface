//
//  ChatRoomBaseCellModel.swift
//  Alpface
//
//  Created by swae on 2019/7/13.
//  Copyright © 2019 alpface. All rights reserved.
//

import UIKit
import YYText

public let kChatRoomAvatarImageViewWidth: CGFloat = 40.0
public let kChatRoomGlobalMargin: CGFloat = 10.0
public let kChatRoomTextMinMargin: CGFloat = 80.0
public let kChatRoomTextMaxWidth: CGFloat = UIScreen.main.bounds.size.width - kChatRoomTextMinMargin - kChatRoomAvatarImageViewWidth - kChatRoomGlobalMargin - kChatRoomGlobalMargin * 2

class ChatRoomBaseCellModel {
    public var model: ChatRoomModel?
    public var indexPath: IndexPath?
    var cellHeight: CGFloat = 0
    public var cellId: String
    
    // 以下是为了配合 UI 来使用
    public var isFromSelf : Bool {
        get {        
            return self.model?.sendId == AuthenticationManager.shared.loginUser?.id
        }
    }
    public var attributedText: NSMutableAttributedString?
    public var messageSendSuccessType: MessageSendSuccessType = .failed //发送消息的状态
    public var contentTextFont: UIFont?
    public var attributedTextLinePositionModifier: CustomYYTextLinePositionModifier?
    public var attributedTextLayout: YYTextLayout?
    // 气泡图片
    public var bubbleImage: UIImage? {
        get {
            let image = isFromSelf ? UIImage(named: "icon_chat_senderTextNodeBkg")! : UIImage(named: "icon_chat_receiverTextNodeBkg")!
            // 拉伸图片区域
            let bubbleImage = image.resizableImage(withCapInsets: UIEdgeInsets.init(top: 30, left: 28, bottom: 85, right: 28), resizingMode: .stretch)
            return bubbleImage
        }
        
    }
    
    init(model: ChatRoomModel, cellId: String, contentTextFont: UIFont = UIFont.systemFont(ofSize: 16)) {
        self.model = model
        self.contentTextFont = contentTextFont
        self.cellId = cellId
        if model.messageContentType == .Text {
            // 解析富文本
            let attributedString = ChatRoomTextParser.parse(model.messageContent!, font: contentTextFont)!
            self.attributedText = attributedString
            
            //初始化排版布局对象
            let modifier = CustomYYTextLinePositionModifier(font: contentTextFont)
            self.attributedTextLinePositionModifier = modifier
            
            //初始化 YYTextContainer
            let textContainer: YYTextContainer = YYTextContainer()
            textContainer.size = CGSize(width: kChatRoomTextMaxWidth, height: CGFloat.greatestFiniteMagnitude)
            textContainer.linePositionModifier = modifier
            textContainer.maximumNumberOfRows = 0
            
            // 设置 layout
            let textLayout = YYTextLayout(container: textContainer, text: attributedString)
            self.attributedTextLayout = textLayout
        }
        
    }
}
