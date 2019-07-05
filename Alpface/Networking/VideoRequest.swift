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
public typealias ALPProgressHandler = (Progress) -> Void
open class VideoRequest: NSObject {
    static public let shared = VideoRequest()
    
    public func getRadomVideos(success: ALPHttpResponseBlock?, failure: ALPHttpErrorBlock?){
        
        let url = ALPConstans.HttpRequestURL.getRadomVideos
        // 按照上传时间排序
        let parameters = ["ordering": "-upload_time"]
        HttpRequestHelper.request(method: .get, url: url, parameters: parameters as NSDictionary) { (response, error) in
            
            if let error = error {
                guard let fail = failure else { return }
                DispatchQueue.main.async {
                    fail(error)
                }
                return
            }
            
            guard let response = response else {
                guard let fail = failure else { return }
                DispatchQueue.main.async {
                    fail(NSError(domain: NSURLErrorDomain, code: 500, userInfo: nil))
                }
                return
            }
            
            // get 方法的200 为请求成功
            if response.statusCode == 200  {
                guard let data = response.data else {
                    DispatchQueue.main.async {
                        guard let fail = failure else { return }
                        fail(NSError(domain: NSURLErrorDomain, code: 500, userInfo:nil))
                    }
                    return
                }
                if let videos = data["results"] as? [[String : Any]] {
                    guard let succ = success else { return }
                    var list = [VideoItem]()
                    videos.forEach { (item) in
                        let video = VideoItem(dict: item)
                        list.append(video)
                    }
                    
                    DispatchQueue.main.async {
                        succ(list)
                    }
                    return
                }
            }
            guard let fail = failure else { return }
            DispatchQueue.main.async {
                fail(NSError(domain: NSURLErrorDomain, code: response.statusCode, userInfo: response.data))
            }
            
        }
    }
    
    
    public func getUserHomeByUserId(id: Int64, success: ALPHttpResponseBlock?, failure: ALPHttpErrorBlock?){
        let url = ALPConstans.HttpRequestURL.userHome + "\(id)/"
        
//        let parameters = [
//            "id": id,
//
//        ]  as NSDictionary

        HttpRequestHelper.request(method: .get, url: url, parameters: nil) { (response, error) in
            if let error = error {
                guard let fail = failure else { return }
                DispatchQueue.main.async {
                    fail(error)
                }
                return
            }
            guard let response = response else {
                guard let fail = failure else { return }
                DispatchQueue.main.async {
                    fail(NSError(domain: NSURLErrorDomain, code: 500, userInfo: nil))
                }
                return
            }
            
            // get 方法的200 为请求成功
            if response.statusCode == 200  {
                guard let data = response.data else {
                    DispatchQueue.main.async {
                        guard let fail = failure else { return }
                        fail(NSError(domain: NSURLErrorDomain, code: 500, userInfo:nil))
                    }
                    return
                }
                guard let succ = success else { return }
                let home = UserHomeModel(dict: data)
                
                DispatchQueue.main.async {
                    succ(home)
                }
                return
            }
            guard let fail = failure else { return }
            DispatchQueue.main.async {
                fail(NSError(domain: NSURLErrorDomain, code: response.statusCode, userInfo: response.data))
            }
            
        }
    }
    /// 发布视频
    /// @param title 发布的标题
    /// @param describe 发布的内容
    /// @param videoPath 视频文件w本地路径
    /// @param progress 进度回调
    /// @param success 成功回调
    /// @param failure 失败回调
    /// @param coverStartTime 封面从某秒开始
    public func releaseVideo(content: String, coverStartTime: TimeInterval, videoPath: String,longitude: Double = 0, latitude: Double = 0 , poi_name: String="", poi_address: String="", progress: ALPProgressHandler?, success: ALPHttpResponseBlock?, failure: ALPHttpErrorBlock?) {
        guard let token = AuthenticationManager.shared.authToken else {
            guard let fail = failure else { return }
            fail(NSError(domain: NSURLErrorDomain, code: 403, userInfo: nil))
            return
        }
        if AuthenticationManager.shared.isLogin == false {
            guard let fail = failure else { return }
            fail(NSError(domain: NSURLErrorDomain, code: 403, userInfo: nil))
            return
        }
        
        let file = VideoFile(path: videoPath)
        guard let data = file.readAll() else {
            guard let fail = failure else { return }
            fail(NSError(domain: NSURLErrorDomain, code: 403, userInfo: nil))
            return
        }
        file.close()
        
        let urlString = ALPConstans.HttpRequestURL.uploadVideo
        var parameters = Dictionary<String, Any>.init()
        parameters["content"] = content
        // 播放封面的时间戳 默认5秒
        parameters["cover_duration"] = 3
        // 封面起始的时间戳
        parameters["cover_start_second"] = coverStartTime
        parameters["source"] = "a"
        
        let dateFormatter = DateFormatter()
        //设置时间格式（这里的dateFormatter对象在上一段代码中创建）
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        //调用string方法进行转换
        let dateStr = dateFormatter.string(from: Date())
        //输出转换结果
        parameters["first_create_time"] = dateStr
        
        if longitude != 0 &&
            latitude != 0 &&
            poi_name.count > 0 &&
            poi_address.count > 0 {
            parameters["longitude"] = longitude
            parameters["latitude"] = latitude
            parameters["poi_name"] = poi_name
            parameters["poi_address"] = poi_address
        }

        
        let url = URL(string: urlString)
        // 将jwt传递给服务端，用于身份验证
        var headers: HTTPHeaders = [:]
        headers["Authorization"] = "JWT \(token)"
       Alamofire.upload( multipartFormData: { (multipartFormData) in
            
            multipartFormData.append(data, withName:"video", fileName:file.displayName!, mimeType:"video/mp4")
            
            // 遍历字典
            for (key, value) in parameters {
                var value_string: String!
                if value is String {
                    value_string = value as? String
                }
                else {
                    value_string = "\(value)"
                }
                
                let _datas: Data = value_string.data(using:String.Encoding.utf8)!
                multipartFormData.append(_datas, withName: key)
                
            }
            
       }, to: url!, headers: headers) { (result) in
            switch result {
            case .success(let upload,_, _):
                upload.uploadProgress(queue: DispatchQueue.main, closure: { (p) in
                    if let prog = progress {
                        prog(p)
                    }
                }).responseJSON(completionHandler: { (response) in
                    // 201 创建成功
                    if response.response?.statusCode == 201 {
                        if let value = response.result.value as? NSDictionary {
                            if let suc = success {
                                let v = VideoItem(dict: value as! [String : Any])
                                suc(v)
                                return
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
    
    public func getVideoByUserId(userId: String, success: ALPHttpResponseBlock?, failure: ALPHttpErrorBlock?){
        
        let url = ALPConstans.HttpRequestURL.getVideoByUserId
        HttpRequestHelper.request(method: .get, url: url, parameters: ["user_id": userId]) { (response, error) in
            
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
}
