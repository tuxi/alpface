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
    class func request(method: HTTPMethod, url: String, parameters: NSDictionary?, finishedCallBack: @escaping (_ result: AnyObject?, _ _error: Error?) -> ()) {
        
        let config:URLSessionConfiguration = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = NetworkTimeoutInterval
        sessionManager = SessionManager(configuration: config)
        setCookie()
        let headers: HTTPHeaders = [
            "Accept":"text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8" ,
            "Content-Type": "application/x-www-form-urlencoded",
            "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/65.0.3325.181 Safari/537.36",
            "Accept-Encoding": "gzip,deflate",
            "Accept-Language": "zh-CN,zh;q=0.9",
            "Upgrade-Insecure-Requests": "1"
        ]
        
//        if let csrftoken = AuthenticationManager.shared.csrftoken {
//            headers["Cookie"] = "csrftoken=\(csrftoken)"
//        }
        
        Alamofire.request(url, method: method, parameters: parameters as? Parameters, encoding: URLEncoding.default, headers: headers).responseString(queue: DispatchQueue.global(), encoding: String.Encoding.utf8, completionHandler: { (response) in
            let data = response.result.value
            var error = response.result.error
            if data == ALPConstans.AuthKeys.ALPAuthPermissionErrorValue {
                error = NSError(domain: ALPConstans.AuthKeys.ALPAuthPermissionErrorValue, code: 403, userInfo: nil)
            }
            if (response.result.isSuccess && error == nil) {
                
                // 如果是登录成功后保存cookies
                let url = response.request?.url
                if url?.absoluteString == ALPConstans.HttpRequestURL.login {
                    self.saveCookie(response: response)
                }
                finishedCallBack(data as AnyObject, nil)
            }
            else {
                finishedCallBack(data as AnyObject, error)
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
