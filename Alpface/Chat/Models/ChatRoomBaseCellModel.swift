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

public let kChatRoomImageMaxWidth: CGFloat = 125
public let kChatRoomImageMinWidth: CGFloat = 50
public let kChatRoomImageMaxHeight: CGFloat = 150
public let kChatRoomImageMinHeight: CGFloat = 50

fileprivate func CGRectCenterRectForResizableImage(_ image: UIImage) -> CGRect {
    return CGRect(
        x: image.capInsets.left / image.size.width,
        y: image.capInsets.top / image.size.height,
        width: (image.size.width - image.capInsets.right - image.capInsets.left) / image.size.width,
        height: (image.size.height - image.capInsets.bottom - image.capInsets.top) / image.size.height
    )
}

class ChatRoomBaseCellModel {
    public var model: ChatRoomModel?
    public var indexPath: IndexPath?
    var cellHeight: CGFloat = 0
    public var cellId: String
    
    // 以下是为了配合 UI 来使用
    // 1 文本内容的ui相关
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
    // 文本内容的气泡图片
    public lazy var textContentBubbleImage: UIImage = {
        let image = isFromSelf ? UIImage(named: "icon_chat_senderTextNodeBkg")! : UIImage(named: "icon_chat_receiverTextNodeBkg")!
        // 拉伸图片区域
        let bubbleImage = image.resizableImage(withCapInsets: UIEdgeInsets.init(top: 30, left: 28, bottom: 85, right: 28), resizingMode: .stretch)
        return bubbleImage
    }()
    
    // 2 图片内容的ui相关
    public let imageContentStretchInsets = UIEdgeInsets.init(top: 30, left: 28, bottom: 23, right: 28)
    // 图片内容的气泡图片
    public lazy var imageContentBubbleImage: UIImage = {
        let image = isFromSelf ? UIImage(named: "icon_chat_senderImageNodeBorder")! : UIImage(named: "icon_chat_receiverImageNodeBorder")!
        // 拉伸图片区域
        let bubbleImage = image.resizableImage(withCapInsets: imageContentStretchInsets, resizingMode: .stretch)
        return bubbleImage
    }()
    
    public lazy var imageContentMaskLayer: CALayer = {
        let layer = CALayer()
        layer.contents = imageContentBubbleImage.cgImage
        layer.contentsCenter = CGRectCenterRectForResizableImage(imageContentBubbleImage)
        layer.frame = CGRect(x: 0, y: 0, width:  model!.imageModel!.imageWidth, height: model!.imageModel!.imageHeight)
        layer.contentsScale = UIScreen.main.scale
        layer.opacity = 1
        return layer
    }()
    
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
        else if model.messageContentType == .Image {
            
        }
        
    }
    
    /**
     获取缩略图的尺寸
     
     - parameter originalSize: 原始图的尺寸 size
     
     - returns: 返回的缩略图尺寸
     */
    class func getThumbImageSize(_ originalSize: CGSize) -> CGSize {
        
        let imageRealHeight = originalSize.height
        let imageRealWidth = originalSize.width
        
        var resizeThumbWidth: CGFloat
        var resizeThumbHeight: CGFloat
        /**
         *  1）如果图片的高度 >= 图片的宽度 , 高度就是最大的高度，宽度等比
         *  2）如果图片的高度 < 图片的宽度 , 以宽度来做等比，算出高度
         */
        if imageRealHeight >= imageRealWidth {
            let scaleWidth = imageRealWidth * kChatRoomImageMaxHeight / imageRealHeight
            resizeThumbWidth = (scaleWidth > kChatRoomImageMinWidth) ? scaleWidth : kChatRoomImageMinWidth
            resizeThumbHeight = kChatRoomImageMaxHeight
        } else {
            let scaleHeight = imageRealHeight * kChatRoomImageMaxWidth / imageRealWidth
            resizeThumbHeight = (scaleHeight > kChatRoomImageMinHeight) ? scaleHeight : kChatRoomImageMinHeight
            resizeThumbWidth = kChatRoomImageMaxWidth
        }
        
        return CGSize(width: resizeThumbWidth, height: resizeThumbHeight)
    }
    
    
}
