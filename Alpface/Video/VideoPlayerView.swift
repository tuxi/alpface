//
//  VideoPlayerView.swift
//  Alpface
//
//  Created by swae on 2018/3/16.
//  Copyright © 2018年 alpface. All rights reserved.
//

import UIKit
import AVFoundation

class VideoPlayerView: UIView {
    
    open override class var layerClass: Swift.AnyClass {
        return AVPlayerLayer.self
    }
    

}
