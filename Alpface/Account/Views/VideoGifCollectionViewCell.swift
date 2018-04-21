//
//  VideoGifCollectionViewCell.swift
//  Alpface
//
//  Created by swae on 2018/4/6.
//  Copyright © 2018年 alpface. All rights reserved.
//

import UIKit
import SDWebImage

class VideoGifCollectionViewCell: UICollectionViewCell {
    
    lazy var gifView: UIImageView = {
        let imageView = UIImageView()
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
        self.contentView.backgroundColor = UIColor.randomColor()
    }
}
