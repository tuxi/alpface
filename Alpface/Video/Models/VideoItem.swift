//
//  VideoItem.swift
//  Alpface
//
//  Created by swae on 2018/3/31.
//  Copyright © 2018年 alpface. All rights reserved.
//

import UIKit

@objc(ALPVideoItem)
class VideoItem: NSObject {
    open var videoid : Int = 0
    open var video_height : Double = 0.0
    open var video_width : Double = 0.0
    open var video_rotation : Double = 0.0
    open var video_mimetype : String?
    open var video_duration: Int64?
    open var title: String?
    open var describe: String?
    open var upload_time: TimeInterval?
    open var pub_time: TimeInterval?
    open var views: Int64 = 0
    open var userid: Int64 = 0
    open var comment_status: Int?
    open var status: Int?
    open var video_thumbnail: String?
    open var video: String?
    open var video_ogg: String?
    open var user: User?
//    open var rating: VideoRatingItem?
    
    convenience init(dict: [String: Any]) {
        self.init()
        if let id = dict["id"] as? NSNumber {
            self.videoid = id.intValue
        }
        if let video_height = dict["video_height"] as? NSNumber {
            self.video_height = video_height.doubleValue
        }
        if let video_width = dict["video_width"] as? NSNumber {
            self.video_width = video_width.doubleValue
        }
        if let video_rotation = dict["video_rotation"] as? NSNumber {
            self.video_rotation = video_rotation.doubleValue
        }
        if let video_mimetype = dict["video_mimetype"] as? String {
            self.video_mimetype = video_mimetype
        }
        if let video_duration = dict["video_duration"] as? NSNumber {
            self.video_duration = video_duration.int64Value
        }
        if let title = dict["title"] as? String {
            self.title = title
        }
        if let describe = dict["describe"] as? String {
            self.describe = describe
        }
        if let upload_time = dict["upload_time"] as? NSNumber {
            self.upload_time = upload_time.doubleValue
        }
        if let pub_time = dict["pub_time"] as? NSNumber {
            self.pub_time = pub_time.doubleValue
        }
        if let views = dict["views"] as? NSNumber {
            self.views = views.int64Value
        }
        if let userid = dict["userid"] as? NSNumber {
            self.userid = userid.int64Value
        }
        if let comment_status = dict["comment_status"] as? NSNumber {
            self.comment_status = comment_status.intValue
        }
        if let status = dict["status"] as? NSNumber {
            self.status = status.intValue
        }
        if let video_thumbnail = dict["video_thumbnail"] as? String {
            self.video_thumbnail = video_thumbnail
        }
        if let video = dict["video"] as? String {
            self.video = video
        }
        if let video_ogg = dict["video_ogg"] as? String {
            self.video_ogg = video_ogg
        }
        if let user = dict["user"] as? [String : Any] {
            self.user = User(dict: user)
        }
        
    }
    
    open func getVideoURL() -> URL? {
        guard let video = self.video else {
            return nil
        }
        return URL.init(string: ALPSiteURLString + video)
    }
    
    open func getThumbnailURL() -> URL? {
        guard let video_thumbnail = self.video_thumbnail else {
            return nil
        }
        return URL.init(string: ALPSiteURLString + video_thumbnail)
    }
}
