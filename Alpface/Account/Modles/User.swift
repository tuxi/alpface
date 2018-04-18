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
    public var userid : Int = 0
    public var username : String?
    public var avatar : String?
    public var nickname : String?
    public var phone : String?
    public var gender : String?
    public var address : String?
    public var following : Int64 = 0
    public var followers : Int64 = 0
    public var is_active: Bool = false
    public var my_videos: [VideoItem]?
    public var my_likes: [VideoItem]?
    public var summary: String?
    public var email: String?
    public var cover: String?
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(userid, forKey: "userid")
        aCoder.encode(username, forKey: "username")
        aCoder.encode(nickname, forKey: "nickname")
        aCoder.encode(avatar, forKey: "avatar")
        aCoder.encode(phone, forKey: "phone")
        aCoder.encode(gender, forKey: "gender")
        aCoder.encode(address, forKey: "address")
        
        aCoder.encode(following, forKey: "following")
        aCoder.encode(followers, forKey: "followers")
        aCoder.encode(is_active, forKey: "is_active")
        aCoder.encode(my_videos, forKey: "my_videos")
        aCoder.encode(my_likes, forKey: "my_likes")
        aCoder.encode(summary, forKey: "summary")
        aCoder.encode(email, forKey: "email")
        aCoder.encode(cover, forKey: "cover")
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init()
        userid = aDecoder.decodeInteger(forKey: "userid")
        username = aDecoder.decodeObject(forKey: "username") as? String
        nickname = aDecoder.decodeObject(forKey: "nickname") as? String
        avatar = aDecoder.decodeObject(forKey: "avatar") as? String
        phone = aDecoder.decodeObject(forKey: "phone") as? String
        gender = aDecoder.decodeObject(forKey: "gender") as? String
        address = aDecoder.decodeObject(forKey: "address") as? String
        following = aDecoder.decodeInt64(forKey: "following")
        followers = aDecoder.decodeInt64(forKey: "followers")
        is_active = aDecoder.decodeBool(forKey: "is_active")
        my_videos = aDecoder.decodeObject(forKey: "my_videos") as? [VideoItem]
        my_likes = aDecoder.decodeObject(forKey: "my_likes") as? [VideoItem]
        summary = aDecoder.decodeObject(forKey: "summary") as? String
        email = aDecoder.decodeObject(forKey: "email") as? String
        cover = aDecoder.decodeObject(forKey: "cover") as? String
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
        if let c = self.cover {
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
        /// id和userid返回的都是用户唯一标示符，有些接口字段没统一，我现在这里处理了
       if let id = dict["userid"] as? NSNumber {
            self.userid = id.intValue
        }
        if let id = dict["id"] as? NSNumber {
            self.userid = id.intValue
        }
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
        if let phone = dict["phone"] as? String {
            self.phone = phone
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
        if let cover = dict["cover"] as? String {
            self.cover = cover
        }
    }
    
    
}
