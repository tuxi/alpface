//
//  HomeNavigationView.swift
//  Alpface
//
//  Created by xiaoyuan on 2018/10/10.
//  Copyright © 2018 alpface. All rights reserved.
//

import UIKit

class HomeNavigationView: UIView {
    
    fileprivate lazy var recommendButton: UIButton = {
        let button = UIButton(type: .custom)
        button.tag = 1;
        button.backgroundColor = UIColor.clear
        button.setTitle("推荐", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16.0)
        button.addTarget(self, action: #selector(selectButton(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    fileprivate lazy var nearbyButton: UIButton = {
        let button = UIButton(type: .custom)
        button.tag = 2;
        button.backgroundColor = UIColor.clear
        button.setTitle("附近", for: .normal)
        button.setTitleColor(UIColor.init(red: 230/255.0, green: 230/255.0, blue: 230/255.0, alpha: 1.0), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16.0)
        button.addTarget(self, action: #selector(selectButton(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    fileprivate lazy var searchButton: UIButton = {
        let button = UIButton(type: .custom)
        button.tag = 3;
        button.backgroundColor = UIColor.clear
        button.setImage(UIImage.init(named: "sousuo"), for: .normal)
        button.addTarget(self, action: #selector(selectButton(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
       setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    fileprivate func setup() {
        let line = UIView()
        line.backgroundColor = UIColor.init(red: 230/255.0, green: 230/255.0, blue: 230/255.0, alpha: 1.0)
        self.addSubview(line)
        line.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: line, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0.0).isActive = true
        NSLayoutConstraint(item: line, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: -18.0).isActive = true
        NSLayoutConstraint(item: line, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 1.0).isActive = true
        NSLayoutConstraint(item: line, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 8.0).isActive = true
        
        self.addSubview(self.recommendButton)
        self.addSubview(self.searchButton)
        self.addSubview(self.nearbyButton)
        
        NSLayoutConstraint(item: recommendButton, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: -46.0).isActive = true
        NSLayoutConstraint(item: recommendButton, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0.0).isActive = true
        
        NSLayoutConstraint(item: nearbyButton, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 46.0).isActive = true
        NSLayoutConstraint(item: nearbyButton, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0.0).isActive = true
        
        NSLayoutConstraint(item: searchButton, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: 0.0).isActive = true
        NSLayoutConstraint(item: searchButton, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0.0).isActive = true
        NSLayoutConstraint(item: searchButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 44.0).isActive = true
        NSLayoutConstraint(item: searchButton, attribute: .height, relatedBy: .equal, toItem: searchButton, attribute: .width, multiplier: 1.0, constant: 0.0).isActive = true

    }
    
    @objc fileprivate func selectButton(_ button: UIButton) {
        if button.tag == 1 {
            self.reset(self.nearbyButton)
            self.choose(button)
        }
        if button.tag == 2 {
            self.reset(self.recommendButton)
            self.choose(button)
        }
    }
    
    // 恢复初始状态
    fileprivate func reset(_ button: UIButton) {
        button.isSelected = false
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16.0)
    }
  
    // 选中按钮
    fileprivate func choose(_ button: UIButton) {
        button.isSelected = true
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18.0)
    }
}
