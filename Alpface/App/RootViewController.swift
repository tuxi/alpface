//
//  RootViewController.swift
//  Alpface
//
//  Created by xiaoyuan on 2018/3/11.
//  Copyright © 2018年 alpface. All rights reserved.
//

import UIKit

@objc(ALPRootViewController)
class RootViewController: UIViewController {

    private lazy var appViewController: MainAppViewController = {
       let controller = MainAppViewController()
        return controller
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor.clear
        setupUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    public func showHomePage() {
        self.appViewController.scrollingContainer.show(page: 1, animated: true)
        
        guard let disVc = self.appViewController.scrollingContainer.displayViewController() as? UITabBarController else {
            return
        }
        disVc.selectedIndex = 0
    }
    
    public func showUserProfilePage(user: User) {
        self.appViewController.scrollingContainer.show(page: 2, animated: true, willShowCallBack: { (appearVC, disAppearVc) in
//            guard let disVc = appearVC as? UserProfileViewController else {
//                return
//            }
//            disVc.user = user
        })
        
    }
    
    public func show(page: Int, animated: Bool) {
        self.appViewController.scrollingContainer.show(page: page, animated: animated)
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor.clear
        view.addSubview(appViewController.view)
        appViewController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|[appView]|", options: [], metrics: nil, views: ["appView": appViewController.view]))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[appView]|", options: [], metrics: nil, views: ["appView": appViewController.view]))
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return appViewController.preferredStatusBarStyle
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .fade
    }
    
    override var prefersStatusBarHidden: Bool {
        return appViewController.prefersStatusBarHidden
    }
    
    override var childViewControllerForStatusBarStyle: UIViewController? {
        return appViewController.childViewControllerForStatusBarStyle
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
