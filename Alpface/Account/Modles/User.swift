//
//  User.swift
//  Alpface
//
//  Created by swae on 2018/3/25.
//  Copyright © 2018年 alpface. All rights reserved.
//

import Foundation

@objc(ALPUser)
open class User: NSObject, NSCoding {
    public var username : String?
    public var nickname : String?
    public var avatar : String?
    public var mobile : String?
    public var gender : String?
    public var address : String?
    public var following : Int64 = 0
    public var followers : Int64 = 0
    public var is_active: Bool = false
    public var my_videos: [VideoItem]?
    public var my_likes: [VideoItem]?
    public var summary: String?
    public var email: String?
    public var head_background: String?
    public var website: String?
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(username, forKey: "username")
        aCoder.encode(username, forKey: "nickname")
        aCoder.encode(avatar, forKey: "avatar")
        aCoder.encode(mobile, forKey: "mobile")
        aCoder.encode(gender, forKey: "gender")
        aCoder.encode(address, forKey: "address")
        
        aCoder.encode(following, forKey: "following")
        aCoder.encode(followers, forKey: "followers")
        aCoder.encode(is_active, forKey: "is_active")
        aCoder.encode(my_videos, forKey: "my_videos")
        aCoder.encode(my_likes, forKey: "my_likes")
        aCoder.encode(summary, forKey: "summary")
        aCoder.encode(email, forKey: "email")
        aCoder.encode(head_background, forKey: "head_background")
        aCoder.encode(website, forKey: "website")
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init()
        username = aDecoder.decodeObject(forKey: "username") as? String
        nickname = aDecoder.decodeObject(forKey: "nickname") as? String
        avatar = aDecoder.decodeObject(forKey: "avatar") as? String
        mobile = aDecoder.decodeObject(forKey: "mobile") as? String
        gender = aDecoder.decodeObject(forKey: "gender") as? String
        address = aDecoder.decodeObject(forKey: "address") as? String
        following = aDecoder.decodeInt64(forKey: "following")
        followers = aDecoder.decodeInt64(forKey: "followers")
        is_active = aDecoder.decodeBool(forKey: "is_active")
        my_videos = aDecoder.decodeObject(forKey: "my_videos") as? [VideoItem]
        my_likes = aDecoder.decodeObject(forKey: "my_likes") as? [VideoItem]
        summary = aDecoder.decodeObject(forKey: "summary") as? String
        email = aDecoder.decodeObject(forKey: "email") as? String
        head_background = aDecoder.decodeObject(forKey: "head_background") as? String
        website = aDecoder.decodeObject(forKey: "website") as? String
    }
    
    public func getAvatarURL() -> URL? {
        if let a = self.avatar {
            if a.hasPrefix("http://") == true {
                return URL.init(string: a)
            }
            else if a.hasPrefix("/media") == true {
                return URL.init(string: ALPConstans.HttpRequestURL.ALPSiteURLString + a)
            }
        }
        return nil
    }
    
    public func getCoverURL() -> URL? {
        if let c = self.head_background {
            if c.hasPrefix("http://") == true {
                return URL.init(string: c)
            }
            else if c.hasPrefix("/media") == true {
                return URL.init(string: ALPConstans.HttpRequestURL.ALPSiteURLString + c)
            }
        }
        return nil
    }
    override init() {
        super.init()
    }
    convenience init(dict: [String: Any]) {
        self.init()
        if let username = dict["username"] as? String {
            self.username = username
        }
        if let nickname = dict["nickname"] as? String {
            self.nickname = nickname
        }
        
        /// avatar和image返回的都是头像，有些接口字段没统一，我现在这里处理了
        if let avatar = dict["avatar"] as? String {
            self.avatar = avatar
        }
        if let image = dict["image"] as? String {
            self.avatar = image
        }
        if let mobile = dict["mobile"] as? String {
            self.mobile = mobile
        }
        if let gender = dict["gender"] as? String {
            self.gender = gender
        }
        if let address = dict["address"] as? String {
            self.address = address
        }
        if let my_videos = dict["my_videos"] as? [[String: Any]] {
            var items = [VideoItem]()
            for video in my_videos {
                let item = VideoItem(dict: video)
                item.user = self
                items.append(item)
            }
            self.my_videos = items
        }
        if let my_likes = dict["my_likes"] as? [[String: Any]] {
            var items = [VideoItem]()
            for video in my_likes {
                let item = VideoItem(dict: video)
                items.append(item)
            }
            self.my_likes = items
        }
        if let summary = dict["summary"] as? String {
            self.summary = summary
        }
        if let head_background = dict["head_background"] as? String {
            self.head_background = head_background
        }
        if let website = dict["website"] as? String {
            self.website = website
        }
    }
    
    
}
