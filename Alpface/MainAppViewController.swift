//
//  MainAppViewController.swift
//  Alpface
//
//  Created by xiaoyuan on 2018/3/11.
//  Copyright © 2018年 alpface. All rights reserved.
//

import UIKit

class MainAppViewController: UIViewController {

    private lazy var scrollingContainerController: MainAppScrollingContainerViewController = {
        let controller = MainAppScrollingContainerViewController()
        return controller
        
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupUI()
        
    }
    
    private func setupUI() {
        view.addSubview(scrollingContainerController.view)
        scrollingContainerController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|[view]|", options: [], metrics: nil, views: ["view": scrollingContainerController.view]))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|", options: [], metrics: nil, views: ["view": scrollingContainerController.view]))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
