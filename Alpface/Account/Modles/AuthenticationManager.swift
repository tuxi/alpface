//
//  AuthenticationManager.swift
//  Alpface
//
//  Created by swae on 2018/3/25.
//  Copyright © 2018年 alpface. All rights reserved.
//

import UIKit
import MBProgressHUD

extension NSNotification.Name {
    /// 账户信息修改
    public static let AuthenticationAccountProfileChanged: NSNotification.Name = NSNotification.Name(rawValue: "AuthenticationAccountProfileChanged")
}

@objc(ALPAuthenticationManager)
final class AuthenticationManager: NSObject {
    static public let shared = AuthenticationManager()
    public let accountLogin = AccountLogin()
    private var timer: Timer?
    
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
            if self.authToken == nil {
                return false;
            }
            if let userId = loginUser?.id, userId > 0 {
                return true
            }
            return false
        }
    }
    
    private override init() {
        super.init()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 5.0) {
            self.startHeartBeatLoop()
        }
    }
    
    private var _loginUser: User?
    
    public var loginUser: User? {
        set {
            _loginUser = newValue
            if newValue != nil {
                startHeartBeatLoop()
            }
            else {
                stopHeartBeatLoop()
            }
            
            if newValue != nil {
               let data = NSKeyedArchiver.archivedData(withRootObject: newValue as Any)
                UserDefaults.standard.setValue(data, forKey: ALPConstans.AuthKeys.ALPLoginUserInfoKey)
            }
            else {
                UserDefaults.standard.setValue(nil, forKey: ALPConstans.AuthKeys.ALPLoginUserInfoKey)
            }
            
            UserDefaults.standard.synchronize()
        }
        get {
            if let user = _loginUser {
                return user
            }
            guard let data = UserDefaults.standard.value(forKey: ALPConstans.AuthKeys.ALPLoginUserInfoKey) as? Data else {
                return nil
            }
            
            guard let user = NSKeyedUnarchiver.unarchiveObject(with: data) as? User else {
                return nil
            }
            _loginUser = user
            return user
        }
    }
    
    // 让登陆状态无效，退出登陆时需要调用此方法
    public func invalidate() {
        loginUser = nil
        authToken = nil
        HttpRequestHelper.clearCookies()
    }

    
    private func startHeartBeatLoop() {
        self.stopHeartBeatLoop()
        if self.timer == nil {
            self.timer = Timer(timeInterval: 10.0, target: self, selector: #selector(AuthenticationManager.checkToken), userInfo: nil, repeats: true)
            
            RunLoop.current.add(self.timer!, forMode: .common)
            
        }
    }
    private func stopHeartBeatLoop() {
        if self.timer != nil {
            self.timer?.invalidate()
            self.timer = nil
        }
    }
    @objc private func checkToken() {
        self.accountLogin.heartbeat { [weak self] (error) in
            if let error = error {
                // 未登录
                print(error.localizedDescription)
                self?.invalidate()
                self?.stopHeartBeatLoop()
                DispatchQueue.main.async {
                    MBProgressHUD.xy_show("登录已失效，停止心跳包！")
                }
            }
        }
    }
}
