//
//  UserHomeModel.swift
//  Alpface
//
//  Created by swae on 2019/7/5.
//  Copyright © 2019 alpface. All rights reserved.
//

import Foundation

class UserHomeSegmentModel {
    var title: String?
    var data: [VideoItem]?
    var total: Int64 = 0
    var nextpage: Int = 0
    var category: String?
    var currentUser: User?
    
    init(dict: [String: Any], user: User?) {
        self.currentUser = user
        self.title = dict["title"] as? String
        self.category = dict["category"] as? String
        if let total = dict["total"] as? Int64 {
            self.total = total
        }
        if let nextpage = dict["nextpage"] as? Int {
            self.nextpage = nextpage
        }
        if let data = dict["data"] as? [[String: Any]] {
            var list = [VideoItem]()
            data.forEach { (dict) in
                let video = VideoItem(dict: dict)
                if let cate = self.category, cate == "videos" {
                    // videos 为用户发布的视频列表，
                    video.user = currentUser
                }
                list.append(video)
            }
            self.data = list
        }
    }
}

class UserHomeModel {
    var user: User?
    var segments: [UserHomeSegmentModel]?
    
    init(dict: [String: Any]) {
        if let user_dict = dict["user"] as? [String: Any] {
            self.user = User(dict: user_dict)
        }
        if let segments_list = dict["segments"] as? [[String: Any]] {
            var list = [UserHomeSegmentModel]()
            segments_list.forEach { (dict) in
                list.append(UserHomeSegmentModel(dict: dict, user: user))
            }
            self.segments = list
        }
    }
}
