//
//  AuthenticationManager.swift
//  Alpface
//
//  Created by swae on 2018/3/25.
//  Copyright © 2018年 alpface. All rights reserved.
//

import UIKit

extension NSNotification.Name {
    /// 账户信息修改
    public static let AuthenticationAccountProfileChanged: NSNotification.Name = NSNotification.Name(rawValue: "AuthenticationAccountProfileChanged")
}

@objc(ALPAuthenticationManager)
final class AuthenticationManager: NSObject {
    static public let shared = AuthenticationManager()
    public let accountLogin = AccountLogin()
    
    public var csrftoken : String? {
        get {
            return UserDefaults.standard.object(forKey: ALPConstans.AuthKeys.ALPCsrftokenKey) as? String
        }
        
        set {
            UserDefaults.standard .set(newValue, forKey: ALPConstans.AuthKeys.ALPCsrftokenKey)
            UserDefaults.standard.synchronize()
        }
    }
    
    public var authToken : String? {
        get {
            return UserDefaults.standard.object(forKey: ALPConstans.AuthKeys.ALPAuthTokenKey) as? String
        }
        set {
            UserDefaults.standard.set(newValue, forKey: ALPConstans.AuthKeys.ALPAuthTokenKey)
            UserDefaults.standard.synchronize()
        }
    }
    
    var isLogin : Bool  {
        get {
            if loginUser?.username?.isEmpty == false {
                return true
            }
            return false
        }
    }
    
    private override init() { super.init() }
    
    public var loginUser: User? {
        set {
            
            let data = NSKeyedArchiver.archivedData(withRootObject: newValue as Any)
            UserDefaults.standard.setValue(data, forKey: ALPConstans.AuthKeys.ALPLoginUserInfoKey)
            UserDefaults.standard.synchronize()
        }
        get {
            guard let data = UserDefaults.standard.value(forKey: ALPConstans.AuthKeys.ALPLoginUserInfoKey) as? Data else {
                return nil
            }
            
            guard let user = NSKeyedUnarchiver.unarchiveObject(with: data) as? User else {
                return nil
            }
            
            return user
        }
    }
    
    public func logout() {
        self.loginUser = nil
        self.csrftoken = nil
        self.authToken = nil
        HttpRequestHelper.clearCookies()
    }
    
}
