//
//  VideoRequest.swift
//  Alpface
//
//  Created by swae on 2018/3/31.
//  Copyright © 2018年 alpface. All rights reserved.
//

import UIKit
import Alamofire

public typealias ALPHttpResponseBlock = (Any?) -> Void
public typealias ALPHttpErrorBlock = (_ error: Error?) -> ()

class VideoRequest: NSObject {
    static public let shared = VideoRequest()
    
    public func getRadomVideos(success: ALPHttpResponseBlock?, failure: ALPHttpErrorBlock?){
        
        let url = ALPConstans.HttpRequestURL.getRadomVideos
        HttpRequestHelper.request(method: .get, url: url, parameters: nil) { (response, error) in
            
            if error != nil {
                guard let fail = failure else {
                    return
                }
                DispatchQueue.main.async {
                    fail(error)
                }
                return
            }
            
            guard let succ = success else {
                return
            }
            guard let jsonString = response as? String else {
                DispatchQueue.main.async {
                    succ(nil)
                }
                return
            }
            
            let jsonDict =  self.getDictionaryFromJSONString(jsonString: jsonString)
            guard let dataDict = jsonDict["data"] as? [String : Any] else {
                DispatchQueue.main.async {
                    succ(nil)
                }
                print("data不存在或者不是字典类型")
                return
            }
            guard let videoList = dataDict["videos"] as? [[String : Any]] else {
                DispatchQueue.main.async {
                    succ(nil)
                }
                print("videos不存在或者不是字典类型")
                return
            }
            var list: [VideoItem] = [VideoItem]()
            for dict in videoList {
                let video = VideoItem(dict: dict)
                list.append(video)
            }
            DispatchQueue.main.async {
                succ(list)
            }
            
        }
    }
    
    
    public func discoverUserByUsername(username: String, success: ALPHttpResponseBlock?, failure: ALPHttpErrorBlock?){
        let url = ALPConstans.HttpRequestURL.discoverUserByUsername
        guard let authUser = AuthenticationManager.shared.loginUser else {
            if let fail = failure {
                let e = NSError(domain: "ErrorNOTFoundauthUser", code: 404, userInfo: nil)
                fail(e)
            }
            return
        }
        let parameters = [
            "username": username,
            "auth_username": authUser.username!,
            "type": "1",
            
        ]  as NSDictionary
        
        HttpRequestHelper.request(method: .get, url: url, parameters: parameters) { (response, error) in
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
            if let userDict = jsonDict["data"] as? [String : Any] {
                guard let succ = success else { return }
                let user = User(dict: userDict)
                DispatchQueue.main.async {
                    succ(user)
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
    
    public func upload(title: String, describe: String, videoPath: String, success: ALPHttpResponseBlock?, failure: ALPHttpErrorBlock?) {
        
        if AuthenticationManager.shared.isLogin == false {
            return
        }
        
        let file = VideoFile(path: videoPath)
        guard let data = file.readAll() else {
            return
        }
        file.close()
        
        let urlString = ALPConstans.HttpRequestURL.uoloadVideo
        var parameters = Dictionary<String, Any>.init()
        if let csrfToken = AuthenticationManager.shared.csrftoken {
            parameters[ALPCsrfmiddlewaretokenKey] = csrfToken
        }
        parameters["title"] = title
        parameters["describe"] = describe
        
        
        let url = URL(string: urlString)
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            
            multipartFormData.append(data, withName:"video", fileName:file.displayName!, mimeType:"video/mp4")
            
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
                            DispatchQueue.main.async {
                                if let suc = success {
                                    if let data = value["data"] as? NSDictionary {
                                        if let video = data["video"] as? NSDictionary {
                                            let v = VideoItem(dict: video as! [String : Any])
                                            suc(v)
                                            return
                                        }
                                    }
                                    
                                }
                            }
                        }
                    }
                    guard let fail = failure else { return }
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
}
