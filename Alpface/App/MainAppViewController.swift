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
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        return controller
        
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupUI()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        /// 防止scrollingContainerd.view的约束被清空，解决左滑打开相机中进入相册后返回，scrollingContainer.view的frame为zero的问题
        if let scrollingContainerSuperview = scrollingContainer.view.superview {
            if scrollingContainerSuperview == self.view {
                view.removeConstraints(view.constraints)
                view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|[view]|", options: [], metrics: nil, views: ["view": scrollingContainer.view]))
                view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|", options: [], metrics: nil, views: ["view": scrollingContainer.view]))
            }
        }
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor.clear
        view.addSubview(scrollingContainer.view)
    }
    
    public func showHomePage() {
        self.scrollingContainer.show(page: 1, animated: true)
        
        guard let disVc = self.scrollingContainer.displayViewController() as? UITabBarController else {
            return
        }
        disVc.selectedIndex = 0
    }
    
    public func isHomePageVisible() -> Bool {
        return self.scrollingContainer.isHomePageVisible()
    }
    
    public func showUserProfilePage(user: User) {
        self.scrollingContainer.userProfileController.user = user
        self.scrollingContainer.show(page: 2, animated: true) { (finished) in
        }
    }
    
    public func show(page: Int, animated: Bool) {
        self.scrollingContainer.show(page: page, animated: animated)
    }
    
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .fade
    }
    
    override var prefersStatusBarHidden: Bool {
        if AppUtils.isIPhoneX() {
            return false
        }
        return scrollingContainer.prefersStatusBarHidden
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return scrollingContainer.preferredStatusBarStyle
    }
    
    
    override var childForStatusBarStyle: UIViewController? {
        return scrollingContainer.childForStatusBarStyle
    }

}
