//
//  AccountLogin.swift
//  Alpface
//
//  Created by swae on 2018/3/25.
//  Copyright © 2018年 alpface. All rights reserved.
//

import UIKit

public enum ALPAccountLoginError: LocalizedError {
    case cannotExtractLoginStatus
    case statusNotPass(String?)
    case temporaryPasswordNeedsChange(String?)
    case needsOathTokenFor2FA(String?)
    case wrongPassword
    case wrongToken
    public var errorDescription: String? {
        switch self {
        case .cannotExtractLoginStatus:
            return "Could not extract login status"
        case .statusNotPass(let message?):
            return message
        case .temporaryPasswordNeedsChange(let message?):
            return message
        case .needsOathTokenFor2FA(let message?):
            return message
        case .wrongPassword:
            return "Invalid password"
        case .wrongToken:
            return "Invalid code"
        default:
            return "Unable to login: Reason unknown"
        }
    }
}


public typealias ALPAccountLoginResultBlock = (AccountLoginResult) -> Void
public typealias ALPErrorHandler = (_ error: Error?) -> ()
public typealias ALPSuccessHandler = (_ response: Any?) -> ()

@objc(ALPAccountLoginResult)
public class AccountLoginResult: NSObject {
    @objc var status: String
    @objc var username: String
    @objc var message: String?
    @objc init(status: String, username: String, message: String?) {
        self.status = status
        self.username = username
        self.message = message
    }
}


@objc(ALPAccountLogin)
public class AccountLogin: NSObject {
    
    /// 登录解决，会先获取一个新的csrftoken，再进行登录操作
    public func login(username: String, password: String, success: ALPAccountLoginResultBlock?, failure: ALPErrorHandler?){
        
        /// 登录之前先请求csrftoken
        getCsrfToken(success: { (response) in
            
            let urlString = ALPConstans.HttpRequestURL().login
            let parameters = [
                ALPCsrfmiddlewaretokenKey: AuthenticationManager.shared.csrftoken,
                "username": username,
                "password": password,
                ]
            
            HttpRequestHelper.request(method: .post, url: urlString, parameters: parameters as NSDictionary) { (response, error) in
                
                if let error = error {
                    guard let fail = failure else { return }
                    fail(error)
                    return
                }
                
                
                guard let userInfo = response as? String else {
                    guard let fail = failure else { return }
                    fail(NSError(domain: NSURLErrorDomain, code: 403, userInfo: nil))
                    return
                }
                
                let jsonDict =  self.getDictionaryFromJSONString(jsonString: userInfo)
                if let userDict = jsonDict["user"] as? [String : Any] {
                    guard let succ = success else { return }
                    let user = User(userId: userDict["userId"] as? String, username: userDict["username"] as? String, nickname: userDict["nickname"] as? String, avatar: userDict["avatar"] as? String, phone: userDict["phone"] as? String, gender: userDict["gender"]  as? String, address: userDict["address"]  as? String)
                    if let username = user.username {
                        let result = AccountLoginResult(status: jsonDict["status"] as! String, username:username, message: "")
                        
                        // 记录当前登录的用户
                        AuthenticationManager.shared.loginUser = user
                        succ(result)
                    }
                }
                else {
                    guard let fail = failure else { return }
                    fail(NSError(domain: NSURLErrorDomain, code: 403, userInfo: nil))
                }
                
               
            }
        }) { (error) in
            print(error ?? "")
        }
        

        
    }
    
    /// 获取csrftoken
    public func getCsrfToken(success: ALPSuccessHandler?, failure: ALPErrorHandler?) {
         let urlString = ALPConstans.HttpRequestURL().getCsrfToken
        HttpRequestHelper.request(method: .get, url: urlString, parameters: nil) { (response, error) in
            if let err = error {
                if let fail = failure {
                    fail(err)
                }
                return
            }
            
            guard let res = response as? String else {
                if let fail = failure {
                    fail(NSError.init(domain: NSURLErrorDomain, code: 403, userInfo: nil))
                }
                return
            }
            
           let jsonDict =  self.getDictionaryFromJSONString(jsonString: res)
            
            /// 将csrf存储起来，并回调
            let csrf = jsonDict[ALPCsrftokenKey] as? String
            print(csrf ?? "")
            AuthenticationManager.shared.csrftoken = csrf
            guard let succ = success else {
                return
            }
            succ(csrf)
        }
    }
}

extension NSObject {
    /**
     字典转换为JSONString
     
     - parameter dictionary: 字典参数
     
     - returns: JSONString
     */
    func getJSONStringFromDictionary(dictionary:NSDictionary) -> String {
        if (!JSONSerialization.isValidJSONObject(dictionary)) {
            print("无法解析出JSONString")
            return ""
        }
        let data : NSData! = try? JSONSerialization.data(withJSONObject: dictionary, options: []) as NSData!
        let JSONString = NSString(data:data as Data,encoding: String.Encoding.utf8.rawValue)
        return JSONString! as String
        
    }
    
    /// JSONString转换为字典
    ///
    /// - Parameter jsonString: 需要转换的json字符串
    /// - Returns: 字典
    func getDictionaryFromJSONString(jsonString:String) ->NSDictionary {
        
        let jsonData:Data = jsonString.data(using: .utf8)!
        
        let dict = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers)
        if dict != nil {
            return dict as! NSDictionary
        }
        return NSDictionary()
        
        
    }

}
