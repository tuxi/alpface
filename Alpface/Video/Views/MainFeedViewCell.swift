//
//  MainFeedViewCell.swift
//  Alpface
//
//  Created by swae on 2018/3/12.
//  Copyright © 2018年 alpface. All rights reserved.
//

import UIKit

class MainFeedViewCell: UICollectionViewCell {
    
    public var model: PlayVideoModel? {
        didSet {
            viewController.model = model
        }
    }
    public var viewController: FeedCellViewController = {
        let vc = FeedCellViewController()
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        return vc
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        contentView.addSubview(viewController.view)
        viewController.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        viewController.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        viewController.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        viewController.view.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
    }
    
}
