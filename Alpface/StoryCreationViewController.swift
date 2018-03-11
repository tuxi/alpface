//
//  StoryCreationViewController.swift
//  Alpface
//
//  Created by swae on 2018/3/11.
//  Copyright © 2018年 alpface. All rights reserved.
//

import UIKit

class StoryCreationViewController: UIViewController {

    private lazy var cameraVc = StoryCameraViewController()
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setupUI() {
        view.addSubview(cameraVc.view)
        cameraVc.view.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|[view]|", options: [], metrics: nil, views: ["view": cameraVc.view]))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|", options: [], metrics: nil, views: ["view": cameraVc.view]))
        
        let rightButton = UIButton()
        rightButton.setImage(UIImage.init(named: "chevron-right"), for: .normal)
        // 触摸按钮时发光
        rightButton.showsTouchWhenHighlighted = true
        rightButton.addTarget(self, action: #selector(rightBarButtonClick(_:)), for: .touchUpInside)
        var frame = rightButton.frame
        frame.size = CGSize(width: 44.0, height: 44.0)
        rightButton.frame = frame
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: rightButton)
        
        // 设置导航栏标题属性：设置标题颜色
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        // 设置导航栏前景色：设置item指示色
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        // 设置导航栏半透明
        self.navigationController?.navigationBar.isTranslucent = true
        
        // 设置导航栏背景图片
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        
        // 设置导航栏阴影图片
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    
    @objc private func rightBarButtonClick(_ button: UIButton) {
        
    }

}
