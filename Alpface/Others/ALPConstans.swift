//
//  ALPConstans.swift
//  Alpface
//
//  Created by swae on 2018/3/25.
//  Copyright © 2018年 alpface. All rights reserved.
//

import Foundation


struct ALPConstans {
    static var animationDuration: Double {
        get {
            return 0.36
        }
    }
    
    struct AuthKeys {
        /// 存储登录用户信息的key，如果此key获取的value为nil则说明用户未登录
        static let ALPLoginUserInfoKey = "LoginUserInfoKey"
        static let ALPCsrfmiddlewaretokenKey = "csrfmiddlewaretoken"
        static let ALPAuthTokenKey = "token"
        static let ALPAuthUserNameKey = "username"
        static let ALPAuthenticationUserKey = "ALPAuthenticationUserKey"
        /// 用户授权出现问题，需要重新登录
        static let ALPAuthPermissionErrorValue = "<h1>403 Forbidden</h1>"
    }
    
    struct HttpRequestURL {
//        static let ALPSiteURLString = "http://10.211.55.4"
        static let ALPSiteURLString = "https://api.enba.com"
        
        // 登录
        static let login = "\(ALPSiteURLString)" + "/login/"
        // 注册 必须是post方法 成功返回 201
        static let register = "\(ALPSiteURLString)" + "/users/"
        // 根据用户id修改用户部分信息，后面拼上用户id，必须是PATCH方法 200 成功
        static let updateProfile = "\(ALPSiteURLString)" + "/users/"
        // get 方法 获取视频系列
        static let getAllVideos = "\(ALPSiteURLString)" + "/videos/"
        // post 方法 上传视频
        static let uploadVideo = "\(ALPSiteURLString)" + "/videos/"
        //
        static let vtimeline = "\(ALPSiteURLString)" + "/vtimeline/"
        // 根据用户id 请求用户主页数据
        static let userHome = "\(ALPSiteURLString)" + "/user_home/"
        static let getVideoByUserId = "\(ALPSiteURLString)" + "/video/getVideoByUserId"
        // get方法 根据content_type 类型获取用户收藏的列表 6为视频
        static let getUserLikes = "\(ALPSiteURLString)" + "/likes/"
        // 点赞 post 方法，成功返回201
        static let createLike = "\(ALPSiteURLString)" + "/likes/"
        // delete方法 根据like id 删除对象，成功返回204
        static let deleteLikeById = "\(ALPSiteURLString)" + "/likes/"
        
    }
}


