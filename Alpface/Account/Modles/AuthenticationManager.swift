//
//  AuthenticationManager.swift
//  Alpface
//
//  Created by swae on 2018/3/25.
//  Copyright © 2018年 alpface. All rights reserved.
//

import UIKit


@objc(ALPAuthenticationManager)
final class AuthenticationManager: NSObject {
    static public let shared = AuthenticationManager()
    public let accountLogin = AccountLogin()
    
    public var csrftoken : String? {
        get {
            return UserDefaults.standard.object(forKey: ALPCsrftokenKey) as? String
        }
        
        set {
            UserDefaults.standard .set(newValue, forKey: ALPCsrftokenKey)
            UserDefaults.standard.synchronize()
        }
    }
    
    public var authToken : String? {
        get {
            return UserDefaults.standard.object(forKey: ALPAuthTokenKey) as? String
        }
        set {
            UserDefaults.standard.set(newValue, forKey: ALPAuthTokenKey)
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
            UserDefaults.standard.setValue(data, forKey: ALPLoginUserInfoKey)
            UserDefaults.standard.synchronize()
        }
        get {
            guard let data = UserDefaults.standard.value(forKey: ALPLoginUserInfoKey) as? Data else {
                return nil
            }
            
            guard let user = NSKeyedUnarchiver.unarchiveObject(with: data) as? User else {
                return nil
            }
            
            return user
        }
    }
    
}
