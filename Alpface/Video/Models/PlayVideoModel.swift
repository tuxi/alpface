//
//  PlayVideoModel.swift
//  Alpface
//
//  Created by swae on 2018/4/1.
//  Copyright © 2018年 alpface. All rights reserved.
//

import UIKit

class PlayVideoModel: BaseCellModel {
    fileprivate var _isAllowPlay = false
    
    public var playCallBack: ((_ isAllowPlay: Bool) -> Void)?
    
    public var isAllowPlay : Bool {
        set {
//            if newValue != _isAllowPlay {
                _isAllowPlay = newValue
                if let callBack = playCallBack {
                    callBack(_isAllowPlay)
                }
//            }
        }
        get {
            return _isAllowPlay
        }
    }
    
//    public var isPauseByUser: Bool = false 
    
    convenience init(videoItem: VideoItem) {
        self.init()
        self.model = videoItem
    }
}
