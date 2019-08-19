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
    
    public func getHomeRecommendedVideos(success: ALPHttpResponseBlock?, failure: ALPHttpErrorBlock?){
        
        let url = ALPConstans.HttpRequestURL.getAllVideos
        // 按照上传时间排序
        let parameters = ["ordering": "-upload_time"]
        // needsToken 不需要传token， 不然因为token无效而抛出异常，导致无法获取到视频列表
        HttpRequestHelper.request(method: .get, url: url, parameters: parameters as NSDictionary, needsToken: false) { (response, error) in
            
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
            let statusCode = response.statusCode;
            if statusCode == 200  {
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
            print(response.data?.debugDescription ?? "未知错误")
            // response.data == ["detail": Signature has expired.]
            // statusCode 401
            // jwt token 已经过期，解决方法是，已经过期的token 不应该添加到headers中
            guard let fail = failure else { return }
            DispatchQueue.main.async {
                fail(NSError(domain: NSURLErrorDomain, code: response.statusCode, userInfo: response.data))
            }
            
        }
    }
    
    /**
     分页获取用户点赞的数据
     
     - parameter contentType: 要获取的收藏的内容类型， 6为视频
     - parameter userId: 查询的用户id
     - parameter page: 获取的的页码，从1开始
     - parameter pageSize: 分页的数量，默认20
     - parameter success:
     - parameter failure: 修改失败的回调
     
     - returns:
     */
    public func getUserLikes(contentType: Int, userId: Int64, page: Int=1, pageSize: Int=20, success: ALPHttpResponseBlock?, failure: ALPHttpErrorBlock?){
        let url = ALPConstans.HttpRequestURL.getUserLikes
        let parameters = ["receiver_content_type": contentType, "sender": userId, "page": page, "page_size": pageSize] as [String : Any]
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
                if let results = data["results"] as? [[String : Any]] {
                    guard let succ = success else { return }
                    print(results)
                    var list = [VideoItem]()
                    results.forEach { (dict) in
                        guard let video_dict = dict["receiver"] as? [String : Any] else { return }
                        let video = VideoItem(dict: video_dict)
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
    
    /**
     点赞
     
     - parameter contentType: 要收藏的内容类型， 6为视频
     - parameter objectId: 视频的id
     - parameter pageSize: 分页的数量，默认20
     - parameter success:
     - parameter failure: 修改失败的回调
     
     - returns:
     */
    public func createLike(contentType: Int, objectId: Int64, success: ALPHttpResponseBlock?, failure: ALPHttpErrorBlock?){
        let url = ALPConstans.HttpRequestURL.getUserLikes
        let parameters = ["receiver_content_type": contentType, "receiver_object_id": objectId] as [String : Any]
        HttpRequestHelper.request(method: .post, url: url, parameters: parameters as NSDictionary) { (response, error) in
            
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
            
            // post 方法的201 为创建成功
            if response.statusCode == 201  {
                guard let data = response.data else {
                    DispatchQueue.main.async {
                        guard let fail = failure else { return }
                        fail(NSError(domain: NSURLErrorDomain, code: 500, userInfo:nil))
                    }
                    return
                }
                guard let succ = success else { return }
                print(data)
                DispatchQueue.main.async {
                    succ(data)
                }
                return
            }
            guard let fail = failure else { return }
            DispatchQueue.main.async {
                fail(NSError(domain: NSURLErrorDomain, code: response.statusCode, userInfo: response.data))
            }
            
        }
    }
    
    /**
     取消点赞
     
     - parameter likeId: 要取消的id
     - parameter success:
     - parameter failure: 修改失败的回调
     
     - returns:
     */
    public func deleteLike(likeId: Int64, success: ALPHttpResponseBlock?, failure: ALPHttpErrorBlock?){
        let url = ALPConstans.HttpRequestURL.deleteLikeById + "\(likeId)/"
        HttpRequestHelper.request(method: .delete, url: url, parameters: nil) { (response, error) in
            
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
            
            // delete 204删除成功
            if response.statusCode == 204  {
                guard let succ = success else { return }
                DispatchQueue.main.async {
                    succ(response.statusCode)
                }
                return
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
        parameters["cover_start_second"] = Int(coverStartTime)
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
                    print(response.response?.statusCode ?? 0)
                    print(response.result.value ?? "未知")
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
                    fail(NSError(domain: NSURLErrorDomain, code: response.response?.statusCode ?? 0, userInfo: response.result.value as? [String : Any]))
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
