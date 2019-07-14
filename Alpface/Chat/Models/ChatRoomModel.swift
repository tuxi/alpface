//
//  ChatRoomModel.swift
//  Alpface
//
//  Created by swae on 2019/7/13.
//  Copyright © 2019 alpface. All rights reserved.
//

import UIKit
import SDWebImage

@objc(ALPChatAudioModel)
class ChatAudioModel : NSObject {
    var audioId : Int64 = 0
    var audioURL : String?
    var bitRate : String?
    var channels : String?
    var createTime : String?
    var duration : TimeInterval = 0.0
    var fileSize : String?
    var formatName : String?
    var keyHash : String?
    var mimeType : String?
    
    
    
    required init?(dict: [String: AnyObject]) {
        if let audioId = dict["audio_id"] as? Int64 {
            self.audioId = audioId
        }
        if let audioURL = dict["audio_url"] as? String {
            self.audioURL = audioURL
        }
        if let bit_rate = dict["bit_rate"] as? String {
            self.bitRate = bit_rate
        }
        if let channels = dict["channels"] as? String {
            self.channels = channels
        }
        if let ctime = dict["ctime"] as? String {
            self.createTime = ctime
        }
        if let duration = dict["duration"] as? TimeInterval {
            self.duration = duration
        }
        if let fileSize = dict["file_size"] as? String {
            self.fileSize = fileSize
        }
        if let format_name = dict["format_name"] as? String {
            self.formatName = format_name
        }
        if let key_hash = dict["key_hash"] as? String {
            self.keyHash = key_hash
        }
        if let mime_type = dict["mime_type"] as? String {
            self.mimeType = mime_type
        }
    }
}

@objc(ALPChatImageModel)
class ChatImageModel : NSObject {
    var imageHeight : CGFloat?
    var imageWidth : CGFloat?
    var imageId : Int64 = 0
    var originalURL : String?
    var thumbURL : String?
    // 拍照，选择相机的图片的临时名称
    var localStoreName: String?
    // 从 Disk 加载出来的图片
    var localThumbnailImage: UIImage? {
        if let theLocalStoreName = localStoreName {
            guard let path = SDImageCache.shared().defaultCachePath(forKey: theLocalStoreName) else { return nil }
            return UIImage(contentsOfFile: path)
        } else {
            return nil
        }
    }
   
    init(dict: [String: AnyObject]) {
        if let imageHeight = dict["height"] as? CGFloat {
            self.imageHeight = imageHeight
        }
        if let width = dict["width"] as? CGFloat {
            self.imageWidth = width
        }
        if let original_url = dict["original_url"] as? String {
            self.originalURL = original_url
        }
        if let thumb_url = dict["thumb_url"] as? String {
            self.thumbURL = thumb_url
        }
        if let image_id = dict["image_id"] as? Int64 {
            self.imageId = image_id
        }
    }
    
}


class ChatRoomModel: NSObject {
    // 音频的 Model
    var audioModel : ChatAudioModel?
    // 图片的 Model
    var imageModel : ChatImageModel?
    // 发送人 ID
    var sendId : Int64 = 0
    // 接受人 ID
    var receiveId : Int64 = -1
    // 设备类型，iPhone，Android
    var device : String?
    // 消息内容
    var messageContent : String?
    // 消息 ID
    var messageId : Int64 = 0
    // 消息内容的类型
    var messageContentType : MessageContentType = .Text
    var timestamp : String? //同 publishTimestamp
    var messageFromType : MessageFromType = MessageFromType.Group

    
    //自定义时间 model
    init(timestamp: String) {
        super.init()
        self.timestamp = timestamp
        self.messageContent = self.timeDate.chatTimeString
        self.messageContentType = .Time
    }
    
    // 自定义发送文本的 ChatModel
    init(text: String, sendId: Int64, receiveId: Int64) {
        super.init()
        self.timestamp = String(format: "%f", Date.milliseconds)
        self.messageContent = text
        self.messageContentType = .Text
        self.sendId = sendId
        self.receiveId = receiveId
    }
    
    //自定义发送声音的 ChatModel
    init(audioModel: ChatAudioModel, sendId: Int64, receiveId: Int64) {
        super.init()
        self.timestamp = String(format: "%f", Date.milliseconds)
        self.messageContent = "[声音]"
        self.messageContentType = .Voice
        self.audioModel = audioModel
        self.sendId = sendId
        self.receiveId = receiveId
    }
    
    //自定义发送图片的 ChatModel
    init(imageModel: ChatImageModel, sendId: Int64, receiveId: Int64) {
        super.init()
        self.timestamp = String(format: "%f", Date.milliseconds)
        self.messageContent = "[图片]"
        self.messageContentType = .Image
        self.imageModel = imageModel
        self.sendId = sendId
        self.receiveId = receiveId
    }
}


extension ChatRoomModel {
    //后一条数据是否比前一条数据 多了 2 分钟以上
    func isLateForTwoMinutes(_ targetModel: ChatRoomModel) -> Bool {
        //11是秒，服务器时间精确到毫秒，做一次判断
        guard self.timestamp!.count > 11 else {
            return false
        }
        
        guard targetModel.timestamp!.count > 11 else {
            return false
        }
        
        let nextSeconds = Double(self.timestamp!)!/1000
        let previousSeconds = Double(targetModel.timestamp!)!/1000
        return (nextSeconds - previousSeconds) > 120
    }
    
    var timeDate: Date {
        get {
            let seconds = Double(self.timestamp!)!/1000
            let timeInterval: TimeInterval = TimeInterval(seconds)
            return Date(timeIntervalSince1970: timeInterval)
        }
    }
}

// MARK: - 聊天时间的 格式化字符串
extension Date {
    fileprivate var chatTimeString: String {
        get {
            let calendar = Calendar.current
            let now = Date()
            let unit: NSCalendar.Unit = [
                NSCalendar.Unit.minute,
                NSCalendar.Unit.hour,
                NSCalendar.Unit.day,
                NSCalendar.Unit.month,
                NSCalendar.Unit.year,
            ]
            let nowComponents:DateComponents = (calendar as NSCalendar).components(unit, from: now)
            let targetComponents:DateComponents = (calendar as NSCalendar).components(unit, from: self)
            
            let year = nowComponents.year! - targetComponents.year!
            let month = nowComponents.month! - targetComponents.month!
            let day = nowComponents.day! - targetComponents.day!
            
            if year != 0 {
                return String(format: "%zd年%zd月%zd日 %02d:%02d", targetComponents.year!, targetComponents.month!, targetComponents.day!, targetComponents.hour!, targetComponents.minute!)
            } else {
                if (month > 0 || day > 7) {
                    return String(format: "%zd月%zd日 %02d:%02d", targetComponents.month!, targetComponents.day!, targetComponents.hour!, targetComponents.minute!)
                } else if (day > 2) {
                    return String(format: "%@ %02d:%02d",self.week(), targetComponents.hour!, targetComponents.minute!)
                } else if (day == 2) {
                    if targetComponents.hour! < 12 {
                        return String(format: "前天上午 %02d:%02d",targetComponents.hour!, targetComponents.minute!)
                    } else if targetComponents.hour == 12 {
                        return String(format: "前天下午 %02d:%02d",targetComponents.hour!, targetComponents.minute!)
                    } else {
                        return String(format: "前天下午 %02d:%02d",targetComponents.hour! - 12, targetComponents.minute!)
                    }
                } else if (day == 1) {
                    if targetComponents.hour! < 12 {
                        return String(format: "昨天上午 %02d:%02d",targetComponents.hour!, targetComponents.minute!)
                    } else if targetComponents.hour == 12 {
                        return String(format: "昨天下午 %02d:%02d",targetComponents.hour!, targetComponents.minute!)
                    } else {
                        return String(format: "昨天下午 %02d:%02d",targetComponents.hour! - 12, targetComponents.minute!)
                    }
                } else if (day == 0){
                    if targetComponents.hour! < 12 {
                        return String(format: "上午 %02d:%02d",targetComponents.hour!, targetComponents.minute!)
                    } else if targetComponents.hour == 12 {
                        return String(format: "下午 %02d:%02d",targetComponents.hour!, targetComponents.minute!)
                    } else {
                        return String(format: "下午 %02d:%02d",targetComponents.hour! - 12, targetComponents.minute!)
                    }
                } else {
                    return ""
                }
            }
        }
    }
}



public extension Date {
    static var milliseconds: TimeInterval {
        get { return Date().timeIntervalSince1970 * 1000 }
    }
    
    func week() -> String {
        let myWeekday: Int = (Calendar.current as NSCalendar).components([NSCalendar.Unit.weekday], from: self).weekday!
        switch myWeekday {
        case 0:
            return "周日"
        case 1:
            return "周一"
        case 2:
            return "周二"
        case 3:
            return "周三"
        case 4:
            return "周四"
        case 5:
            return "周五"
        case 6:
            return "周六"
        default:
            break
        }
        return "未取到数据"
    }
    
    static func messageAgoSinceDate(_ date: Date) -> String {
        return self.timeAgoSinceDate(date, numericDates: false)
    }
    
    static func timeAgoSinceDate(_ date: Date, numericDates: Bool) -> String {
        let calendar = Calendar.current
        let now = Date()
        let earliest = (now as NSDate).earlierDate(date)
        let latest = (earliest == now) ? date : now
        let components:DateComponents = (calendar as NSCalendar).components([
            NSCalendar.Unit.minute,
            NSCalendar.Unit.hour,
            NSCalendar.Unit.day,
            NSCalendar.Unit.weekOfYear,
            NSCalendar.Unit.month,
            NSCalendar.Unit.year,
            NSCalendar.Unit.second
            ], from: earliest, to: latest, options: NSCalendar.Options())
        
        if (components.year! >= 2) {
            return "\(components.year) 年前"
        } else if (components.year! >= 1){
            if (numericDates){
                return "1 年前"
            } else {
                return "去年"
            }
        } else if (components.month! >= 2) {
            return "\(components.month) 月前"
        } else if (components.month! >= 1){
            if (numericDates){
                return "1 个月前"
            } else {
                return "上个月"
            }
        } else if (components.weekOfYear! >= 2) {
            return "\(components.weekOfYear) 周前"
        } else if (components.weekOfYear! >= 1){
            if (numericDates){
                return "1 周前"
            } else {
                return "上一周"
            }
        } else if (components.day! >= 2) {
            return "\(components.day) 天前"
        } else if (components.day! >= 1){
            if (numericDates){
                return "1 天前"
            } else {
                return "昨天"
            }
        } else if (components.hour! >= 2) {
            return "\(components.hour) 小时前"
        } else if (components.hour! >= 1){
            return "1 小时前"
        } else if (components.minute! >= 2) {
            return "\(components.minute) 分钟前"
        } else if (components.minute! >= 1){
            return "1 分钟前"
        } else if (components.second! >= 3) {
            return "\(components.second) 秒前"
        } else {
            return "刚刚"
        }
    }
}

