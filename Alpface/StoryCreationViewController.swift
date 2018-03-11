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
    }


}
