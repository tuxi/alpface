//
//  VideoGifCollectionViewCell.swift
//  Alpface
//
//  Created by swae on 2018/4/6.
//  Copyright © 2018年 alpface. All rights reserved.
//

import UIKit
import Gifu

class VideoGifCollectionViewCell: UICollectionViewCell {
    
    lazy var gifView: GIFImageView = {
        let imageView = GIFImageView()
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    fileprivate func setupUI() {
        self.contentView.addSubview(gifView)
        gifView.translatesAutoresizingMaskIntoConstraints = false
        gifView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor).isActive = true
        gifView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor).isActive = true
        gifView.topAnchor.constraint(equalTo: self.contentView.topAnchor).isActive = true
        gifView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor).isActive = true
        gifView.animate(withGIFURL: URL.init(string: "http://www.alpface.com:8889/media/media_itemsdaed8ee08069428aa1e3605e1dd5a34a.mp4.thumb.gif")!, loopCount: 10) {
            
        }
//        gifView.animate(withGIFNamed: "niconiconi@2x.gif")
    }
}
