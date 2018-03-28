//
//  User.swift
//  Alpface
//
//  Created by swae on 2018/3/25.
//  Copyright © 2018年 alpface. All rights reserved.
//

import Foundation

@objc(ALPUser)
class User: NSObject, NSCoding {
    public var username : String?
    public var nickname : String?
    public var avatar : String?
    public var phone : String?
    public var gender : String?
    public var address : String?
    public var userid : Int = 0
    public var following : Int = 0
    public var followers : Int = 0
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(userid, forKey: "userid")
        aCoder.encode(username, forKey: "username")
        aCoder.encode(avatar, forKey: "avatar")
        aCoder.encode(phone, forKey: "phone")
        aCoder.encode(gender, forKey: "gender")
        aCoder.encode(address, forKey: "address")
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init()
        userid = aDecoder.decodeInteger(forKey: "userid")
        username = aDecoder.decodeObject(forKey: "username") as? String
        nickname = aDecoder.decodeObject(forKey: "nickname") as? String
        avatar = aDecoder.decodeObject(forKey: "avatar") as? String
        phone = aDecoder.decodeObject(forKey: "phone") as? String
        gender = aDecoder.decodeObject(forKey: "gender") as? String
        address = aDecoder.decodeObject(forKey: "address") as? String
    }
    
    convenience init(userid: Int,
                     username: String?  = "",
                     nickname: String?  = "",
                     avatar: String?  = "",
                     phone: String?  = "",
                     gender: String?  = "",
                     address: String?  = "" ) {
        self.init()
        self.userid = userid
        self.username = username
        self.nickname = nickname
        self.avatar = avatar
        self.phone = phone
        self.gender = gender
        self.address = address
    }
    override init() {
        super.init()
    }
//    convenience init(dict: [String: Any]) {
//        self.init()
//       if let id = dict["userid"] as? String {
//            self.userId = id
//        }
//        if let username = dict["username"] as? String {
//            self.username = username
//        }
//        if let nickname = dict["nickname"] as? String {
//            self.nickname = nickname
//        }
//        if let avatar = dict["avatar"] as? String {
//            self.avatar = avatar
//        }
//        if let phone = dict["phone"] as? String {
//            self.phone = phone
//        }
//        if let gender = dict["gender"] as? String {
//            self.gender = gender
//        }
//        if let address = dict["address"] as? String {
//            self.address = address
//        }
//        
//    }
    
}
