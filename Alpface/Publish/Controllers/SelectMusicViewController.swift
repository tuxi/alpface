//
//  SelectMusicViewController.swift
//  Alpface
//
//  Created by swae on 2018/4/22.
//  Copyright © 2018年 alpface. All rights reserved.
//

import UIKit

@objc(ALPSelectMusicViewController)
class SelectMusicViewController: UIViewController {
    
    fileprivate var publishController : PublishViewController = {
       let vc = PublishViewController()
        return vc
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        
        self.publishController.alp_navigationController = self.navigationController
        self.publishController.view.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.publishController.view)
        self.publishController.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.publishController.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        self.publishController.view.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.publishController.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            if let rootViewController = delegate.rootViewController {
                rootViewController.appViewController.scrollingContainer.displayViewController()?.beginAppearanceTransition(false, animated: true)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            if let rootViewController = delegate.rootViewController {
                rootViewController.appViewController.scrollingContainer.displayViewController()?.endAppearanceTransition()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            if let rootViewController = delegate.rootViewController {
                rootViewController.appViewController.scrollingContainer.displayViewController()?.beginAppearanceTransition(true, animated: true)
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            if let rootViewController = delegate.rootViewController {
                rootViewController.appViewController.scrollingContainer.displayViewController()?.endAppearanceTransition()
            }
        }
    }
    
}
