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
        static let ALPSiteURLString = "http://10.211.55.3"
//        static let ALPSiteURLString = "http://39.105.79.94"
        
        // 登录
        static let login = "\(ALPSiteURLString)" + "/login/"
        // 注册 必须是post方法 成功返回 201
        static let register = "\(ALPSiteURLString)" + "/users/"
        // 根据用户id修改用户部分信息，后面拼上用户id，必须是PATCH方法 200 成功
        static let updateProfile = "\(ALPSiteURLString)" + "/users/"
        static let getRadomVideos = "\(ALPSiteURLString)" + "/videos/"
        static let uploadVideo = "\(ALPSiteURLString)" + "/videos/"
        static let discoverUserByUsername = "\(ALPSiteURLString)" + "/account/discover/search"
        static let getVideoByUserId = "\(ALPSiteURLString)" + "/video/getVideoByUserId"
        
    }
}


