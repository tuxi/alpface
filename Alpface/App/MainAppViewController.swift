//
//  MainAppViewController.swift
//  Alpface
//
//  Created by xiaoyuan on 2018/3/11.
//  Copyright © 2018年 alpface. All rights reserved.
//

import UIKit

@objc(ALPMainAppViewController)
class MainAppViewController: UIViewController {

    public lazy var scrollingContainer: MainAppScrollingContainerViewController = {
        let controller = MainAppScrollingContainerViewController()
        controller.initialPage = 1
        return controller
        
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupUI()
        
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor.clear
        view.addSubview(scrollingContainer.view)
        scrollingContainer.view.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|[view]|", options: [], metrics: nil, views: ["view": scrollingContainer.view]))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|", options: [], metrics: nil, views: ["view": scrollingContainer.view]))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return scrollingContainer.preferredStatusBarStyle
    }
    
    override var prefersStatusBarHidden: Bool {
        return scrollingContainer.prefersStatusBarHidden
    }
    
    override var childViewControllerForStatusBarStyle: UIViewController? {
        return scrollingContainer.childViewControllerForStatusBarStyle
    }

}
