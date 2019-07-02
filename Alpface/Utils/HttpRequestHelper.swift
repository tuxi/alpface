//
//  HttpRequestHelper.swift
//  PerfectiOS
//
//  Created by swae on 2017/12/10.
//  Copyright © 2017年 alpface. All rights reserved.
//

import UIKit
import Alamofire

// 网络请求超时时间
let NetworkTimeoutInterval:Double = 10
let alp_cookies_key = "alp_cookies_key"

@objc protocol HttpRequestDelegate: NSObjectProtocol {
    
    @objc optional func httpRequestDidSuccess(request: AnyObject?, requestName: String, parameters: NSDictionary?)
    
    @objc optional func httpRequestDidFailure(request: AnyObject?, requestName: String, parameters: NSDictionary?, error: Error)
}

public struct HttpRequestResponse {
    let statusCode: Int
    let data: [String: Any]?
}

final class HttpRequestHelper: NSObject {

    static var sessionManager: SessionManager? = nil
    public var delegate: HttpRequestDelegate?
    
    
    /// 网络请求，闭包回调的方式
    ///
    /// - Parameters:
    ///   - method: 请求方式，get、post..
    ///   - url: 请求的url，可以是String，也可以是URL
    ///   - parameters: 请求参数
    ///   - finishedCallBack: 完成请求的回调
    class func request(method: HTTPMethod, url: String, parameters: NSDictionary?, finishedCallBack: @escaping (_ result: HttpRequestResponse?, _ _error: Error?) -> ()) {
        
        let config:URLSessionConfiguration = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = NetworkTimeoutInterval
        sessionManager = SessionManager(configuration: config)
        setCookie()
        
        // 将jwt传递给服务端，用于身份验证
        var headers: HTTPHeaders = [:]
        if let token = AuthenticationManager.shared.authToken {
            headers["Authorization"] = "JWT \(token)"
        }
        
         Alamofire.request(url, method: method, parameters: parameters as? Parameters, encoding: URLEncoding.default, headers: headers).responseJSON(queue: DispatchQueue.global(), options: .mutableContainers, completionHandler: { (response) in
            let data = response.result.value
            let error = response.result.error
//            if data == ALPConstans.AuthKeys.ALPAuthPermissionErrorValue {
//                error = NSError(domain: ALPConstans.AuthKeys.ALPAuthPermissionErrorValue, code: 403, userInfo: nil)
//            }
            let res = HttpRequestResponse(statusCode: response.response?.statusCode ?? 500, data: data as? [String : Any])
            if (response.result.isSuccess && error == nil) {
                finishedCallBack(res, nil)
            }
            else {
                finishedCallBack(res, error)
            }
        })
        
    }
    
    class func saveCookie(response: DataResponse<String>) -> Void {
        // response 获取 cookie
        let headerFields = response.response?.allHeaderFields as! [String: String]
        let url = response.request?.url
        let cookies = HTTPCookie.cookies(withResponseHeaderFields: headerFields, for: url!)
        var cookieArray = [ [HTTPCookiePropertyKey : Any ] ]()
        for cookie in cookies {
            cookieArray.append(cookie.properties!)
        }
        UserDefaults.standard.set(cookieArray, forKey: alp_cookies_key)
        UserDefaults.standard.synchronize()
        
    }
    
    class func clearCookies() {
        UserDefaults.standard.set(nil, forKey: alp_cookies_key)
        UserDefaults.standard.synchronize()
    }
    
    public class func setCookie() -> Void {
        // 读取并携带 cookie， 一般写在 AppDelegate 中就可以
        if let cookieArray = UserDefaults.standard.array(forKey: alp_cookies_key) {
            for cookieData in cookieArray {
                if let dict = cookieData as? [HTTPCookiePropertyKey : Any] {
                    if let cookie = HTTPCookie.init(properties : dict) {
                        HTTPCookieStorage.shared.setCookie(cookie)
                    }
                }
            }
        }
    }
    
    
    /// 网络请求，代理回调方式
    ///
    /// - Parameters:
    ///   - method: 请求方式，get、post..
    ///   - url: 请求的url，可以是String，也可以是URL
    ///   - requestName: 请求名字，一个成功的代理方法可以处理多个请求，所以用requestName来区分具体请求
    ///   - parameters: 请求参数
    ///   - delegate: 代理对象，实现此代理处理请求成功及失败的回调
    class func requestForDelegate(method: HTTPMethod, url: String, requestName: String, parameters: NSDictionary?, delegate: AnyObject) {
        
        let config:URLSessionConfiguration = URLSessionConfiguration.default
        
        config.timeoutIntervalForRequest = NetworkTimeoutInterval
        
        sessionManager = SessionManager(configuration: config)
        let headers: HTTPHeaders = [
            "Accept": "application/json"
        ]
        Alamofire.request(url, method: method, parameters: parameters as? Parameters, encoding: JSONEncoding.default, headers: headers).responseJSON
            { (response) in
                let data = response.result.value
                if (response.result.isSuccess) {
                    delegate.httpRequestDidSuccess?(request: data as AnyObject, requestName: requestName, parameters: parameters)
                }
                else {
                    delegate.httpRequestDidFailure?(request: data as AnyObject, requestName: requestName, parameters: parameters, error: response.error!)
                    
                }
        }
    }
    
}
