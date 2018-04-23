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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.green
        
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
