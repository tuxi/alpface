//
//  PlayVideoModel.swift
//  Alpface
//
//  Created by swae on 2018/4/1.
//  Copyright © 2018年 alpface. All rights reserved.
//

import UIKit

@objc(ALPPlayVideoModel)
class PlayVideoModel: BaseCellModel {
    
    public var playCallBack: ((_ isAllowPlay: Bool) -> Void)?
    
    public func play() {
        if let callBack = playCallBack {
            callBack(true)
        }
    }
    
    public func stop() {
        if let callBack = playCallBack {
            callBack(false)
        }
    }
    
    convenience init(videoItem: VideoItem) {
        self.init()
        self.model = videoItem
    }
}
