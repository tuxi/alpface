//
//  MessageModel.swift
//  Alpface
//
//  Created by swae on 2019/7/13.
//  Copyright © 2019 alpface. All rights reserved.
//

import UIKit

enum MessageContentType: String {
    case Text = "0" // 文本
    case Image = "1" // 图片
    case Voice = "2" // 语音
    case System = "3" // 群组提示信息，例如:A 邀请 B,C 加入群聊
    case File = "4" // 文件
    case Time = "110" // 时间（客户端生成数据）
}


// 消息类型
enum MessageFromType: String {
    //消息来源类型
    case System = "0"   // 0是系统
    case Personal = "1"   // 1是个人
    case Group  = "2" // 2是群组
    case PublicServer = "3"  // 服务号
    case PublicSubscribe = "4"   //订阅号
    
    // 消息类型对应的占位图
    var placeHolderImage: UIImage {
        switch (self) {
        case .Personal:
            return UIImage(named: "icon_avatar")!
        case .System, .Group, .PublicServer, .PublicSubscribe:
            return UIImage(named: "icon_avatar")!
        }
    }
}

//发送消息的状态
enum MessageSendSuccessType: Int {
    case success = 0    //消息发送成功
    case failed     //消息发送失败
    case sending    //消息正在发送
}





class MessageModel: NSObject {
    var image_url : String?
    var unReadNum : Int = 0
    var nickname : String?
    var messageFromType : MessageFromType = MessageFromType.Personal
    var messageContentType : MessageContentType = MessageContentType.Text
    var chatId : String?  //每个人，群，公众帐号都有一个 uid，统一叫 chatId
    var latestMessage : String? //当且仅当消息类型为 Text 的时候，才有数据，其他类型需要本地造
    var dateString: String?
    
}
