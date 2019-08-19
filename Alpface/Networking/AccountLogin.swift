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
    public func heartbeat(success: ALPHttpResponseBlock?, failure: ALPErrorHandler?){
        
        guard let token = AuthenticationManager.shared.authToken else {
            if let failure = failure {
                failure(NSError(domain: NSURLErrorDomain, code: 401, userInfo:["detail": "user not login"]))
            }
            return
        }
        
        
        
        let urlString = ALPConstans.HttpRequestURL.heartbeat
        let parameters = [
            "token": token,
        ]
        Alamofire.request(urlString, method: .post, parameters: parameters as Parameters, encoding: URLEncoding.default, headers: nil).responseJSON(queue: DispatchQueue.global(), options: .mutableContainers, completionHandler: { (response) in
            let data = response.result.value
            let error = response.result.error
            
            let res = HttpRequestResponse(statusCode: response.response?.statusCode ?? 500, data: data as? [String : Any])
            
            
            if let error = error {
                guard let fail = failure else { return }
                DispatchQueue.main.async {
                    fail(error)
                }
                return
            }
            
            
            let statusCode = res.statusCode
            if statusCode == 200  {
                guard let data = res.data else {
                    DispatchQueue.main.async {
                        guard let fail = failure else { return }
                        fail(NSError(domain: NSURLErrorDomain, code: 500, userInfo:nil))
                    }
                    return
                }
                if let userDict = data["user"] as? [String : Any], let token = data["token"] as? String {
                    guard let succ = success else { return }
                    DispatchQueue.main.async {
                        succ(userDict)
                    }
                    return
                }
            }
            else if statusCode == 400 {
                // 鉴权失败
                guard let fail = failure else { return }
                DispatchQueue.main.async {
                    fail(NSError(domain: NSURLErrorDomain, code: res.statusCode, userInfo: res.data))
                }
            }
        })
    }
    
    /// 登录解决，会先获取一个新的csrftoken，再进行登录操作
    public func login(mobile: String, password: String, success: ALPAccountLoginResultBlock?, failure: ALPErrorHandler?){
        
        let urlString = ALPConstans.HttpRequestURL.login
        let parameters = [
            "mobile": mobile,
            "password": password,
        ]
        Alamofire.request(urlString, method: .post, parameters: parameters as Parameters, encoding: URLEncoding.default, headers: nil).responseJSON(queue: DispatchQueue.global(), options: .mutableContainers, completionHandler: { (response) in
            let data = response.result.value
            let error = response.result.error
        
            let res = HttpRequestResponse(statusCode: response.response?.statusCode ?? 500, data: data as? [String : Any])
           
            
            if let error = error {
                guard let fail = failure else { return }
                DispatchQueue.main.async {
                    fail(error)
                }
                return
            }
            
            
            if res.statusCode == 200  {
                guard let data = res.data else {
                    DispatchQueue.main.async {
                        guard let fail = failure else { return }
                        fail(NSError(domain: NSURLErrorDomain, code: 500, userInfo:nil))
                    }
                    return
                }
                if let userDict = data["user"] as? [String : Any], let token = data["token"] as? String {
                    print(userDict)
                    AuthenticationManager.shared.authToken = token
                    let user = User(dict: userDict)
                    let result = AccountLoginResult(status: 200, user: user)
                    
                    // 记录当前登录的用户
                    AuthenticationManager.shared.loginUser = user
                    guard let succ = success else { return }
                    DispatchQueue.main.async {
                        succ(result)
                    }
                    return
                }
            }
            
            guard let fail = failure else { return }
            DispatchQueue.main.async {
                fail(NSError(domain: NSURLErrorDomain, code: res.statusCode, userInfo: res.data))
            }
        })
    }
    
    
    /**
     注册用户api
     
     - parameter username: 用户名 具有唯一性，如果服务端数据库已存在此用户名则抛出异常，注册失败，可不传，服务端会自动生成，可修改
     - parameter password: 用户密码
     - parameter phone: 手机号 具有唯一性，可作为登录使用，注册时必须通过手机验证码验证
     - parameter code: 手机验证码
     - parameter nickname: 用户昵称
     - parameter email: 用户邮箱，暂不验证
     - parameter avate: 用户头像
     - parameter success: 注册成功的回调
     - parameter failure: 注册时候的回调
     
     - returns:
     */
    public func register(username: String?, password: String, phone: String, code: String, nickname:String? , email: String?, avate: UIImage? ,success: ALPHttpResponseBlock?, failure: ALPErrorHandler?){
        
        let urlString = ALPConstans.HttpRequestURL.register
        var parameters = [
            "password": password,
            "mobile": phone,
            "code": code
        ]
        if let email = email {
            parameters["email"] = email
        }
        if let nickname = nickname {
            parameters["nickname"] = nickname
        }
        if let username = username {
            parameters["username"] = username
        }
        
        let url = URL(string: urlString)
        return Alamofire.upload(multipartFormData: { (multipartFormData) in
            if let avatar = avate {
                let _data = avatar.jpegData(compressionQuality: 0.5)
                multipartFormData.append(_data!, withName:"avatar", fileName:   "\(phone).jpg", mimeType:"image/jpeg")
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
                    if response.response?.statusCode == 201 {
                        // http status code 201 创建用户成功
                        if let data = response.result.value as? NSDictionary {
                            if let token = data["token"] as? String, let  user_dict = data["user"] as? [String : Any] {
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
                            fail(NSError(domain: NSURLErrorDomain, code: 500, userInfo: nil))
                        }
                    }
                    else {
                        guard let fail = failure else {
                            return
                        }
                        DispatchQueue.main.async {
                            fail(NSError(domain: NSURLErrorDomain, code: response.response?.statusCode ?? 500, userInfo: nil))
                        }
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
    
    /**
     修改用户信息
     
     - parameter user: 需要修改的用户，根据属性修改相关字段，id和username不可更改，支持上传用户头像和顶部背景图
     - parameter success: 修改成功的回调
     - parameter failure: 修改失败的回调
     
     - returns:
     */
    public func update(user: User, avatar: UIImage?, cover: UIImage?, success: ALPHttpResponseBlock?, failure: ALPHttpErrorBlock?) {
        
        
        guard let loginUser = AuthenticationManager.shared.loginUser else {
            guard let fail = failure else {
                return
            }
            fail(NSError.init(domain: "用户未登录", code: 401, userInfo: nil))
            return
        }
        if loginUser.username != user.username {
            guard let fail = failure else {
                return
            }
            fail(NSError.init(domain: "没有权限", code: 401, userInfo: nil))
            return
        }
        guard let token = AuthenticationManager.shared.authToken else {
            guard let fail = failure else {
                return
            }
            fail(NSError.init(domain: "没有token", code: 401, userInfo: nil))
            return
        }
        
        let urlString = ALPConstans.HttpRequestURL.updateProfile + "\(loginUser.id)/"
        var parameters = Dictionary<String, Any>.init()
        if let email = user.email {
            parameters["email"] = email
        }
        if let gender = user.gender?.rawValue {
            parameters["gender"] = gender
        }
//        if let address = user.address {
//            parameters["address"] = address
//        }
        if let summary = user.summary {
            parameters["summary"] = summary
        }
        if let website = user.website {
            parameters["website"] = website
        }
        if let nickname = user.nickname {
            parameters["nickname"] = nickname
        }

        // 将jwt传递给服务端，用于身份验证
        var headers: HTTPHeaders = [:]
        headers["Authorization"] = "JWT \(token)"
        
        let url = URL(string: urlString)
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            if let avatar = avatar {
                let _data = avatar.jpegData(compressionQuality: 0.5)
                multipartFormData.append(_data!, withName:"avatar", fileName:  "avatar_" + "\(user.username!).jpg", mimeType:"image/jpeg")
            }
            if let cover = cover {
                let _data = cover.jpegData(compressionQuality: 1.0)
                multipartFormData.append(_data!, withName:"head_background", fileName:  "head_background_" + "\(user.username!).jpg", mimeType:"image/jpeg")
            }
            
            // 遍历字典
            for (key, value) in parameters {
                
                let str: String = value as! String
                let _datas: Data = str.data(using:String.Encoding.utf8)!
                multipartFormData.append(_datas, withName: key)
                
            }
            
        }, to: url!, method: .patch, headers: headers) { (result) in
            switch result {
            case .success(let upload,_, _):
                upload.responseJSON(completionHandler: { (response) in
                    if response.result.isSuccess {
                        // 200 修改成功
                        print(response.result.debugDescription)
                        if response.response?.statusCode == 200 {
                            if let value = response.result.value as? NSDictionary {
                                if let suc = success {
                                    let user = User(dict: value as! [String : Any])
                                    // 记录修改后的user
                                    AuthenticationManager.shared.loginUser = user
                                    NotificationCenter.default.post(name: NSNotification.Name.AuthenticationAccountProfileChanged, object: nil, userInfo: ["user": user])
                                    suc(user)
                                    return
                                }
                            }
                        }
                            
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
