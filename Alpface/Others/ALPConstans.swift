//
//  ALPConstans.swift
//  Alpface
//
//  Created by swae on 2018/3/25.
//  Copyright © 2018年 alpface. All rights reserved.
//

import Foundation


// 存储登录用户信息的key，如果此key获取的value为nil则说明用户未登录
let ALPLoginUserInfoKey = "LoginUserInfoKey"
public let ALPSiteURLString = "http://www.alpface.com:8889"
let ALPCsrfmiddlewaretokenKey = "csrfmiddlewaretoken"
let ALPCsrftokenKey = "csrftoken"
let ALPAuthTokenKey = "jwttoken"
let ALPAuthenticationUserKey = "ALPAuthenticationUserKey"
let ALPLoginSuccessNotification = "ALPLoginSuccessNotification"
let ALPLoginFailureNotification = "ALPLoginFailureNotification"

struct ALPConstans {
    static var animationDuration: Double {
        get {
            return 0.36
        }
    }
    
    
    struct HttpRequestURL {
        // 登录
        static let login = "\(ALPSiteURLString)" + "/account/auth/login/"
        // 注册
        static let register = "\(ALPSiteURLString)" + "/account/auth/register/"
        static let updateProfile = "\(ALPSiteURLString)" + "/account/user/update/"
        static let getCsrfToken = "\(ALPSiteURLString)" + "/account/auth/csrf"
        static let getRadomVideos = "\(ALPSiteURLString)" + "/video/getAll"
        static let uoloadVideo = "\(ALPSiteURLString)" + "/video/new"
        static let discoverUserByUsername = "\(ALPSiteURLString)" + "/account/discover/search"
        
    }
    
}


