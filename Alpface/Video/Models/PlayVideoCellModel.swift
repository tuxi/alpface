//
//  PlayVideoCellModel.swift
//  Alpface
//
//  Created by swae on 2018/4/1.
//  Copyright © 2018年 alpface. All rights reserved.
//

import UIKit

class PlayVideoCellModel: BaseCellModel {
    static public let playKeyPath = "_isPlay" // For KVO
    fileprivate var _isPlay = false
    
    public var playCallBack: ((_ isPlay: Bool) -> Void)?
    
    public var isPlay : Bool {
        set {
            if newValue != _isPlay {
                _isPlay = newValue
                if let callBack = playCallBack {
                    callBack(_isPlay)
                }
            }
        }
        get {
            return _isPlay
        }
    }
    convenience init(videoItem: VideoItem) {
        self.init()
        self.model = videoItem
    }
}
