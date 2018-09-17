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
    
    private override init() {
        super.init()
        self.startHeartbeat()
    }
    
    private var _loginUser: User?
    
    public var loginUser: User? {
        set {
            _loginUser = newValue
            if newValue != nil {
                // 登录成功开启心跳包，监测token是否过期，或者用户是否被挤下线
                startHeartbeat()
            }
            else {
                stopHeartBeat()
            }
            let data = NSKeyedArchiver.archivedData(withRootObject: newValue as Any)
            UserDefaults.standard.setValue(data, forKey: ALPConstans.AuthKeys.ALPLoginUserInfoKey)
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
    
    private lazy var timerQueue : DispatchQueue = {
       let queue = DispatchQueue(label: "HeartBeat")
        return queue
    }()
    
    public func logout() {
        self.loginUser = nil
        self.csrftoken = nil
        self.authToken = nil
        HttpRequestHelper.clearCookies()
        stopHeartBeat()
    }
    
    private func startHeartbeat() {
//        if self.timer == nil {
            // note: Timer 事件不执行
//            self.timer = Timer.init(timeInterval: 2.0, target: self, selector:  #selector(AuthenticationManager.checkToken), userInfo: nil, repeats: true)
//            RunLoop.current.add(self.timer!, forMode: RunLoopMode.commonModes)
//            self.timer = Timer.every(2.seconds) {[weak self](timer: Timer) in
//                self?.checkToken()
////                if finished {
////                    timer.invalidate()
////                }
//            }
            
//        }
      
        _ = MCGCDTimer.shared.scheduledDispatchTimer(WithTimerName: "HeartBeat", timeInterval: 20, queue: self.timerQueue, repeats: true) {
            self.checkToken()
        }
    }
    private func stopHeartBeat() {
        MCGCDTimer.shared.cancleTimer(WithTimerName: "HeartBeat")
    }
    @objc private func checkToken() {
        guard let loginUser = self.loginUser else {
            // 未登录
            print("用户未登录，停止心跳包")
            self .stopHeartBeat()
            DispatchQueue.main.async {
                MBProgressHUD.xy_show("您未登录, 请登录")
            }
            return
        }
        //        if 无网络 {return}
        accountLogin.getAuthToken(success: { (response) in
            guard let token = response as? String else {
                self.logout()
                MBProgressHUD.xy_show("您已被挤下线, 请重新登录")
                return
            }
            if token != AuthenticationManager.shared.authToken {
                self.logout()
                MBProgressHUD.xy_show("您已被挤下线, 请重新登录")
            }
            
            }) { (error) in
//                guard let error = error as NSError? else {
//                    return
//                }
//                if error.code == 500 {
//                    self.logout()
//                    MBProgressHUD.xy_show("登录状态异常, 请重新登录")
//                }
            
        }
    }
}
