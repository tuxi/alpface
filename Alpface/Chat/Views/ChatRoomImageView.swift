//
//  ChatRoomImageView.swift
//  Alpface
//
//  Created by swae on 2019/7/15.
//  Copyright © 2019 alpface. All rights reserved.
//

import UIKit

class ChatRoomImageView: UIView {

    fileprivate lazy var contentImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.isOpaque = true
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    fileprivate lazy var bubbleImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.isOpaque = true
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setupUI() {
    
    }

}
