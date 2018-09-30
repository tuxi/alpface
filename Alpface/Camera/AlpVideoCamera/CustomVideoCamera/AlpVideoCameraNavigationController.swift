//
//  AlpVideoCameraNavigationController.swift
//  Alpface
//
//  Created by swae on 2018/9/16.
//  Copyright © 2018 alpface. All rights reserved.
//

import UIKit

class AlpVideoCameraNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
