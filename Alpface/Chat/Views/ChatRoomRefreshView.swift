//
//  ChatRoomRefreshView.swift
//  Alpface
//
//  Created by xiaoyuan on 2019/7/16.
//  Copyright © 2019 alpface. All rights reserved.
//

import UIKit

class ChatRoomRefreshView: UIView {

    fileprivate lazy var indicatorView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .gray)
        return view
    }()
    
    fileprivate var isAnimating: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(indicatorView)
        indicatorView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        indicatorView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        indicatorView.topAnchor.constraint(equalTo: self.topAnchor, constant: 10.0).isActive = true
        indicatorView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10.0).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func stat() {
        if isAnimating {
            return
        }
        self.indicatorView.startAnimating()
        isAnimating = true
    }
    
    public func stop() {
        self.indicatorView.stopAnimating()
        isAnimating = false
    }
    
}
