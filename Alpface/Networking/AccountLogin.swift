//
//  AccountLogin.swift
//  Alpface
//
//  Created by swae on 2018/3/25.
//  Copyright © 2018年 alpface. All rights reserved.
//

import UIKit
import Alamofire

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
    @objc var status: Int
    @objc var user: User?
    @objc init(status: Int, user: User?) {
        self.status = status
        self.user = user
    }
}


@objc(ALPAccountLogin)
public class AccountLogin: NSObject {
    
    /// 登录解决，会先获取一个新的csrftoken，再进行登录操作
    public func login(mobile: String, password: String, success: ALPAccountLoginResultBlock?, failure: ALPErrorHandler?){
        
        let urlString = ALPConstans.HttpRequestURL.login
        let parameters = [
            "mobile": mobile,
            "password": password,
        ]
        
        HttpRequestHelper.request(method: .post, url: urlString, parameters: parameters as NSDictionary) { (response, error) in
            
            if let error = error {
                guard let fail = failure else { return }
                DispatchQueue.main.async {
                    fail(error)
                }
                return
            }
            
            
            guard let userInfo = response as? String else {
                guard let fail = failure else { return }
                DispatchQueue.main.async {
                    fail(NSError(domain: NSURLErrorDomain, code: 403, userInfo: nil))
                }
                
                return
            }
            
            let jsonDict =  self.getDictionaryFromJSONString(jsonString: userInfo)
            if let userDict = jsonDict["user"] as? [String : Any], let token = jsonDict["token"] as? String {
                guard let succ = success else { return }
                AuthenticationManager.shared.authToken = token
                let user = User(dict: userDict)
                let result = AccountLoginResult(status: 200, user: user)
                
                // 记录当前登录的用户
                AuthenticationManager.shared.loginUser = user
                DispatchQueue.main.async {
                    succ(result)
                }
            }
            else {
                guard let fail = failure else { return }
                DispatchQueue.main.async {
                    fail(NSError(domain: NSURLErrorDomain, code: 403, userInfo: nil))
                }
            }
            
            
        }

        
    }
    
    
    /// 登录解决，会先获取一个新的csrftoken，再进行登录操作
    public func register(username: String, password: String, phone: String, code: String, email: String?, avate: UIImage? ,success: ALPHttpResponseBlock?, failure: ALPErrorHandler?){
        
        let urlString = ALPConstans.HttpRequestURL.register
        var parameters = [
            "username": username,
            "password": password,
            "nickname": username,
            "mobile": phone,
            "code": code
        ]
        if let email = email {
            parameters["email"] = email
        }
        
        
        let url = URL(string: urlString)
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            if let avatar = avate {
                let _data = UIImageJPEGRepresentation((avatar), 0.5)
                multipartFormData.append(_data!, withName:"avatar", fileName:  "\(username).jpg", mimeType:"image/jpeg")
            }
            
            // 遍历字典
            for (key, value) in parameters {
                
                let str: String = value
                let _datas: Data = str.data(using:String.Encoding.utf8)!
                multipartFormData.append(_datas, withName: key as String)
                
            }
            
        }, to: url!) { (result) in
            switch result {
            case .success(let upload,_, _):
                upload.responseJSON(completionHandler: { (response) in
                    
                    if let value = response.result.value as? NSDictionary {
                        if let token = value["token"] as? String, let  user_dict = value["user"] as? [String : Any] {
                            guard let succ = success else { return }
                            AuthenticationManager.shared.authToken = token
                            let user = User(dict: user_dict)
                            let result = AccountLoginResult(status: 200, user: user)
                            
                            // 记录当前登录的用户
                            AuthenticationManager.shared.loginUser = user
                            DispatchQueue.main.async {
                                succ(result)
                            }
                            return
                        }
                    }
                    guard let fail = failure else {
                        return
                    }
                    DispatchQueue.main.async {
                        fail(NSError(domain: NSURLErrorDomain, code: 403, userInfo: nil))
                    }
                })
            case .failure(let error):
                
                guard let fail = failure else { return }
                DispatchQueue.main.async {
                    fail(error)
                }
            }
        }
        
        
    }
    
    /// 获取authtoken
    public func getAuthToken(success: ALPSuccessHandler?, failure: ALPErrorHandler?) {
        let urlString = ALPConstans.HttpRequestURL.getAuthToken
//        guard let token = AuthenticationManager.shared.authToken else {
//            return
//        }
//        let parameters = ["authToken": token] as NSDictionary
        HttpRequestHelper.request(method: .get, url: urlString, parameters: nil) { (response, error) in
            DispatchQueue.main.async {
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
                
                if res == "<h1>Server Error (500)</h1>" { // 处理nginx服务器频繁访问崩溃问题
                    if let fail = failure {
                        fail(NSError.init(domain: NSURLErrorDomain, code: 500, userInfo: nil))
                    }
                    return
                }
                
                let jsonDict =  self.getDictionaryFromJSONString(jsonString: res)
                
                let authtoken = jsonDict[ALPConstans.AuthKeys.ALPAuthTokenKey] as? String
                print("authtoken:" + (authtoken ?? "") )
                guard let succ = success else {
                    return
                }
                succ(authtoken)
            }
        }
    }
    
    public func update(user: User, avatar: UIImage?, cover: UIImage?, success: ALPHttpResponseBlock?, failure: ALPHttpErrorBlock?) {
        
        guard let loginUser = AuthenticationManager.shared.loginUser else {
            if let fail = failure {
                fail(NSError.init(domain: "用户未登录", code: 404, userInfo: nil))
                return
            }
            return
        }
        if loginUser.username != user.username {
            if let fail = failure {
                fail(NSError.init(domain: "没有权限", code: 404, userInfo: nil))
                return
            }
        }
        
        let urlString = ALPConstans.HttpRequestURL.updateProfile
        var parameters = Dictionary<String, Any>.init()
        if let email = user.email {
            parameters["email"] = email
        }
        if let gender = user.gender {
            parameters["gender"] = gender
        }
        if let address = user.address {
            parameters["address"] = address
        }
        else {
            parameters["address"] = ""
        }
        if let summary = user.summary {
            parameters["summary"] = summary
        }
        else {
            parameters["summary"] = ""
        }
        
        let url = URL(string: urlString)
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            if let avatar = avatar {
                let _data = UIImageJPEGRepresentation((avatar), 0.5)
                multipartFormData.append(_data!, withName:"avatar", fileName:  "\(user.username!).jpg", mimeType:"image/jpeg")
            }
            if let cover = cover {
                let _data = UIImageJPEGRepresentation((cover), 1.0)
                multipartFormData.append(_data!, withName:"cover", fileName:  "\(user.username!).jpg", mimeType:"image/jpeg")
            }
            
            // 遍历字典
            for (key, value) in parameters {
                
                let str: String = value as! String
                let _datas: Data = str.data(using:String.Encoding.utf8)!
                multipartFormData.append(_datas, withName: key)
                
            }
            
        }, to: url!) { (result) in
            switch result {
            case .success(let upload,_, _):
                upload.responseJSON(completionHandler: { (response) in
                    if let value = response.result.value as? NSDictionary {
                        if value["status"] as? String == "success" {
                            
                            if let userDict = value["user"] as? [String : Any] {
                                // 登录成功后保存cookies
                                guard let succ = success else { return }
                                let user = User(dict: userDict)
                                
                                // 记录修改后的user
                                AuthenticationManager.shared.loginUser = user
                                NotificationCenter.default.post(name: NSNotification.Name.AuthenticationAccountProfileChanged, object: nil, userInfo: ["user": user])
                                succ(user)
                            }
                            else {
                                guard let fail = failure else { return }
                                fail(NSError(domain: NSURLErrorDomain, code: 403, userInfo: nil))
                            }
                        }
                        return
                    }
                    guard let fail = failure else { return }
                    fail(NSError(domain: NSURLErrorDomain, code: 403, userInfo: nil))
                })
            case .failure(let error):
                
                guard let fail = failure else { return }
                DispatchQueue.main.async {
                    fail(error)
                }
            }
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
        let data : NSData! = try? JSONSerialization.data(withJSONObject: dictionary, options: []) as NSData
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
