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
    
    init(dict: [String: Any]) {
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
                list.append(VideoItem(dict: dict))
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
                list.append(UserHomeSegmentModel(dict: dict))
            }
            self.segments = list
        }
    }
}
