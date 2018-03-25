//
//  CustomTransitionViewController.swift
//  Instagram
//
//  Created by Bobby Negoat on 12/28/17.
//  Copyright © 2017 Mac. All rights reserved.
//

import UIKit

class CustomTransitionViewController: UIViewController,UIViewControllerTransitioningDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
setDelegate()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}//CustomTransitionViewController class over line

//custom functions
extension CustomTransitionViewController{
    
    private func setDelegate(){
        self.transitioningDelegate = self
    }
}

//UIViewControllerTransitioningDelegate
extension CustomTransitionViewController{
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
  return FadeTransition(transitionDuration: 0.5, startingAlpha: 0.8)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return FadeTransition(transitionDuration: 0.5, startingAlpha: 0.8)
    }
}


