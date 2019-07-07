//
//  VideoItem.swift
//  Alpface
//
//  Created by swae on 2018/3/31.
//  Copyright © 2018年 alpface. All rights reserved.
//

import UIKit

public enum VideoItemStatus: String {
    case done = "d" // 审核通过
    case publish = "p" // 已发表，还未审核
}

public enum VideoItemSource: String {
    case camera = "c" // 发表的来源相机
    case album = "a" // 发布的来源相册
}

@objc(ALPVideoItem)
open class VideoItem: NSObject {
    open var id: Int64 = 0
    open var video_height : Double = 0.0
    open var video_width : Double = 0.0
    open var video_rotation : Double = 0.0
    open var video_mimetype : String?
    open var video_duration: Int64 = 0
    open var content: String?
    open var upload_time: String?
    open var user: User?
    open var status: VideoItemStatus?
    open var video_thumbnail: String?
    open var video: String?
    open var video_ogg: String?
    open var video_gif: String?
    open var video_animated_webp: String?
    open var video_mp4: String?
    open var location: LocationItem?
    open var is_hot: Bool = false
    open var is_active: Bool = false
    open var source: VideoItemSource?
    open var is_commentable: Bool = false
    open var click_num: Int64 = 0
    open var view_num: Int64 = 0
    open var audit_completed_time: String?
    open var first_create_time: String?
    open var cover_duration: Int64 = 0
    open var cover_start_second: Int64 = 0
    open var video_cover_image: String?
    open var like_id: Int64 = -1
    open var is_like: Bool  {
        get {
            return self.like_id > -1
        }
    }
    open var like_num: Int64 = 0
    open var isLikeOperationing: Bool = false
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(id, forKey: "id")
        aCoder.encode(video_height, forKey: "video_height")
        aCoder.encode(video_width, forKey: "video_width")
        aCoder.encode(video_rotation, forKey: "video_rotation")
        aCoder.encode(video_mimetype, forKey: "video_mimetype")
        aCoder.encode(video_duration, forKey: "video_duration")
        aCoder.encode(content, forKey: "title")
        aCoder.encode(upload_time, forKey: "upload_time")
        aCoder.encode(status, forKey: "status")
        aCoder.encode(video_thumbnail, forKey: "video_thumbnail")
        aCoder.encode(video, forKey: "video")
        aCoder.encode(video_ogg, forKey: "video_ogg")
        aCoder.encode(user, forKey: "user")
        aCoder.encode(video_gif, forKey: "video_gif")
        aCoder.encode(video_animated_webp, forKey: "video_animated_webp")
        aCoder.encode(video_mp4, forKey: "video_mp4")
        aCoder.encode(location, forKey: "location")
        aCoder.encode(view_num, forKey: "view_num")
        aCoder.encode(is_hot, forKey: "is_hot")
        aCoder.encode(is_active, forKey: "is_active")
        aCoder.encode(source?.rawValue, forKey: "source")
        aCoder.encode(is_commentable, forKey: "is_commentable")
        aCoder.encode(click_num, forKey: "click_num")
        aCoder.encode(view_num, forKey: "view_num")
        aCoder.encode(audit_completed_time, forKey: "audit_completed_time")
        aCoder.encode(first_create_time, forKey: "first_create_time")
        aCoder.encode(cover_duration, forKey: "cover_duration")
        aCoder.encode(cover_start_second, forKey: "cover_start_second")
        aCoder.encode(video_cover_image, forKey: "video_cover_image")
        aCoder.encode(like_num, forKey: "like_num")
        aCoder.encode(like_id, forKey: "like_id")
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init()
        id = aDecoder.decodeInt64(forKey: "id")
        video_height = aDecoder.decodeDouble(forKey: "video_height")
        video_width = aDecoder.decodeDouble(forKey: "video_width")
        video_rotation = aDecoder.decodeDouble(forKey: "video_rotation")
        video_mimetype = aDecoder.decodeObject(forKey: "video_mimetype") as? String
        video_duration = aDecoder.decodeInt64(forKey: "video_duration")
        content = aDecoder.decodeObject(forKey: "content") as? String
        upload_time = aDecoder.decodeObject(forKey: "upload_time") as? String
        status = VideoItemStatus(rawValue: aDecoder.decodeObject(forKey: "status") as? String ?? "p")
        video_thumbnail = aDecoder.decodeObject(forKey: "video_thumbnail") as? String
        video = aDecoder.decodeObject(forKey: "video") as? String
        video_ogg = aDecoder.decodeObject(forKey: "video_ogg") as? String
        user = aDecoder.decodeObject(forKey: "user") as? User
        video_gif = aDecoder.decodeObject(forKey: "video_gif") as? String
        video_animated_webp = aDecoder.decodeObject(forKey: "video_animated_webp") as? String
        video_mp4 = aDecoder.decodeObject(forKey: "video_mp4") as? String
        location = aDecoder.decodeObject(forKey: "location") as? LocationItem
        view_num = aDecoder.decodeInt64(forKey: "view_num")
        is_hot = aDecoder.decodeBool(forKey: "is_hot")
        is_active = aDecoder.decodeBool(forKey: "is_active")
        source = VideoItemSource(rawValue: aDecoder.decodeObject(forKey: "source") as? String ?? "a")
        is_commentable = aDecoder.decodeBool(forKey: "is_commentable")
        click_num = aDecoder.decodeInt64(forKey: "click_num")
        view_num = aDecoder.decodeInt64(forKey: "view_num")
        audit_completed_time = aDecoder.decodeObject(forKey: "audit_completed_time") as? String
        first_create_time = aDecoder.decodeObject(forKey: "first_create_time") as? String
        cover_duration = aDecoder.decodeInt64(forKey: "cover_duration")
        cover_start_second = aDecoder.decodeInt64(forKey: "cover_start_second")
        video_cover_image = aDecoder.decodeObject(forKey: "video_cover_image") as? String
        like_num = aDecoder.decodeInt64(forKey: "like_num")
        like_id = aDecoder.decodeInt64(forKey: "like_id")
    }
    
    override init() {
        super.init()
    }
    convenience init(dict: [String: Any]) {
        self.init()
        if let id = dict["id"] as? NSNumber {
            self.id = id.int64Value
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
        if let video_duration = dict["video_duration"] as? Int64 {
            self.video_duration = video_duration
        }
        if let content = dict["content"] as? String {
            self.content = content
        }
        if let upload_time = dict["upload_time"] as? String {
            self.upload_time = upload_time
        }
        if let status = dict["status"] as? String {
            self.status = VideoItemStatus(rawValue: status)
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
        if let video_gif = dict["video_gif"] as? String {
            self.video_gif = video_gif
        }
        if let video_animated_webp = dict["video_animated_webp"] as? String {
            self.video_animated_webp = video_animated_webp
        }
        if let video_mp4 = dict["video_mp4"] as? String {
            self.video_mp4 = video_mp4
        }
        if let poi_name = dict["poi_name"] as? String, let longitude = dict["longitude"] as? Double, let latitude = dict["latitude"] as? Double {
            var location_dict = ["poi_name": poi_name, "longitude": longitude, "latitude": latitude] as [String : Any]
            if let poi_address = dict["poi_address"] as? String {
                location_dict["poi_address"] = poi_address
            }
            self.location = LocationItem(dict: location_dict)
        }
        
        if let first_create_time = dict["first_create_time"] as? String {
            self.first_create_time = first_create_time
        }
        if let audit_completed_time = dict["audit_completed_time"] as? String {
            self.audit_completed_time = audit_completed_time
        }
        if let cover_duration = dict["cover_duration"] as? Int64 {
            self.cover_duration = cover_duration
        }
        if let video_cover_image = dict["video_cover_image"] as? String {
            self.video_cover_image = video_cover_image
        }
        if let view_num = dict["view_num"] as? Int64 {
            self.view_num = view_num
        }
        if let is_hot = dict["is_hot"] as? Bool {
            self.is_hot = is_hot
        }
        if let is_active = dict["is_active"] as? Bool {
            self.is_active = is_active
        }
        if let source = dict["source"] as? String {
            self.source = VideoItemSource(rawValue: source)
        }
        if let is_commentable = dict["is_commentable"] as? Bool {
            self.is_commentable = is_commentable
        }
        if let is_commentable = dict["is_commentable"] as? Bool {
            self.is_commentable = is_commentable
        }
        if let click_num = dict["click_num"] as? Int64 {
            self.click_num = click_num
        }
        if let cover_start_second = dict["cover_start_second"] as? Int64 {
            self.cover_start_second = cover_start_second
        }
        if let like_num = dict["like_num"] as? Int64 {
            self.like_num = like_num
        }
        if let like_id = dict["like_id"] as? Int64 {
            self.like_id = like_id
        }
    }
    
    open func getVideoURL() -> URL? {
        guard let video = self.video else {
           return nil
        }
        if video.hasPrefix("http") {
            return URL.init(string: video)
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
    
    open func getVideoMP4URL() -> URL? {
        guard let mp4 = self.video_mp4 else {
            return nil
        }
        if mp4.hasPrefix("http") {
            return URL.init(string: mp4)
        }
        if mp4.hasPrefix("/media") == true {
            return URL.init(string: ALPConstans.HttpRequestURL.ALPSiteURLString + mp4)
        }
        return nil
    }
}
