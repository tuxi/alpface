//
//  VideoRequest.swift
//  Alpface
//
//  Created by swae on 2018/3/31.
//  Copyright © 2018年 alpface. All rights reserved.
//

import UIKit

public typealias ALPHttpResponseBlock = (Any?) -> Void
public typealias ALPHttpErrorBlock = (_ error: Error?) -> ()

class VideoRequest: NSObject {
    static public let shared = VideoRequest()
    
    public func getRadomVideos(success: ALPHttpResponseBlock?, failure: ALPHttpErrorBlock?){
        
        let url = ALPConstans.HttpRequestURL().getRadomVideos
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
}
