//
//  VideoItem.swift
//  Alpface
//
//  Created by swae on 2018/3/31.
//  Copyright © 2018年 alpface. All rights reserved.
//

import UIKit

@objc(ALPVideoItem)
open class VideoItem: NSObject {
    open var videoid : Int64 = 0
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
    open var comment_status: Int32?
    open var status: Int32?
    open var video_thumbnail: String?
    open var video: String?
    open var video_ogg: String?
    open var user: User?
    open var video_gif: String?
    open var video_animated_webp: String?
//    open var rating: VideoRatingItem?
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(videoid, forKey: "videoid")
        aCoder.encode(video_height, forKey: "video_height")
        aCoder.encode(video_width, forKey: "video_width")
        aCoder.encode(video_rotation, forKey: "video_rotation")
        aCoder.encode(video_mimetype, forKey: "video_mimetype")
        aCoder.encode(video_duration, forKey: "video_duration")
        aCoder.encode(title, forKey: "title")
        aCoder.encode(describe, forKey: "describe")
        aCoder.encode(upload_time, forKey: "upload_time")
        aCoder.encode(pub_time, forKey: "pub_time")
        aCoder.encode(views, forKey: "views")
        aCoder.encode(userid, forKey: "userid")
        aCoder.encode(comment_status, forKey: "comment_status")
        aCoder.encode(status, forKey: "status")
        aCoder.encode(video_thumbnail, forKey: "video_thumbnail")
        aCoder.encode(video, forKey: "video")
        aCoder.encode(video_ogg, forKey: "video_ogg")
        aCoder.encode(user, forKey: "user")
        aCoder.encode(video_gif, forKey: "video_gif")
        aCoder.encode(video_animated_webp, forKey: "video_animated_webp")
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init()
        videoid = aDecoder.decodeInt64(forKey: "videoid")
        video_height = aDecoder.decodeDouble(forKey: "video_height")
        video_width = aDecoder.decodeDouble(forKey: "video_width")
        video_rotation = aDecoder.decodeDouble(forKey: "video_rotation")
        video_mimetype = aDecoder.decodeObject(forKey: "video_mimetype") as? String
        video_duration = aDecoder.decodeInt64(forKey: "video_duration")
        title = aDecoder.decodeObject(forKey: "title") as? String
        describe = aDecoder.decodeObject(forKey: "describe") as? String
        upload_time = aDecoder.decodeDouble(forKey: "upload_time")
        pub_time = aDecoder.decodeDouble(forKey: "pub_time")
        views = aDecoder.decodeInt64(forKey: "views")
        userid = aDecoder.decodeInt64(forKey: "userid")
        comment_status = aDecoder.decodeInt32(forKey: "comment_status")
        status = aDecoder.decodeInt32(forKey: "status")
        video_thumbnail = aDecoder.decodeObject(forKey: "video_thumbnail") as? String
        video = aDecoder.decodeObject(forKey: "video") as? String
        video_ogg = aDecoder.decodeObject(forKey: "video_ogg") as? String
        user = aDecoder.decodeObject(forKey: "user") as? User
        video_gif = aDecoder.decodeObject(forKey: "video_gif") as? String
        video_animated_webp = aDecoder.decodeBool(forKey: "video_animated_webp") as? String
    }
    
    override init() {
        super.init()
    }
    convenience init(dict: [String: Any]) {
        self.init()
        if let id = dict["id"] as? NSNumber {
            self.videoid = id.int64Value
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
            self.comment_status = comment_status.int32Value
        }
        if let status = dict["status"] as? NSNumber {
            self.status = status.int32Value
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
        if let user = dict["author"] as? [String : Any] {
            self.user = User(dict: user)
        }
        if let video_gif = dict["video_gif"] as? String {
            self.video_gif = video_gif
        }
        if let video_animated_webp = dict["video_animated_webp"] as? String {
            self.video_animated_webp = video_animated_webp
        }
    }
    
    open func getVideoURL() -> URL? {
        guard let video = self.video else {
            #if DEBUG
                return URL.init(string: "http://www.alpface.com:8889/media/media_itemsdaed8ee08069428aa1e3605e1dd5a34a.mp4")
            #else
                return nil
            #endif
        }
        return URL.init(string: ALPConstans.HttpRequestURL.ALPSiteURLString + video)
    }
    
    open func getThumbnailURL() -> URL? {
        guard let video_thumbnail = self.video_thumbnail else {
            return nil
        }
        if video_thumbnail.hasPrefix("http") {
            return URL.init(string: video_thumbnail)
        }
        if video_thumbnail.hasPrefix("/media") == true {
            return URL.init(string: ALPConstans.HttpRequestURL.ALPSiteURLString + video_thumbnail)
        }
        return nil
    }
    
    open func getVideoGifURL() -> URL? {
        guard let video_gif = self.video_gif else {
            return nil
        }
        if video_gif.hasPrefix("http") {
            return URL.init(string: video_gif)
        }
        if video_gif.hasPrefix("/media") == true {
            return URL.init(string: ALPConstans.HttpRequestURL.ALPSiteURLString + video_gif)
        }
        return nil
    }
    
    open func getVideoAnimatedWebpURL() -> URL? {
        guard let webp = self.video_animated_webp else {
            return nil
        }
        if webp.hasPrefix("http") {
            return URL.init(string: webp)
        }
        if webp.hasPrefix("/media") == true {
            return URL.init(string: ALPConstans.HttpRequestURL.ALPSiteURLString + webp)
        }
        return nil
    }
}
