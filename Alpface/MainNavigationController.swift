//
//  MainNavigationController.swift
//  Alpface
//
//  Created by swae on 2018/3/11.
//  Copyright © 2018年 alpface. All rights reserved.
//

import UIKit

class MainNavigationController: UINavigationController {

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setNavBarAtrributes()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
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

extension MainNavigationController{
    
    fileprivate func setNavBarAtrributes(){
        
        navigationBar.setGradientBackground(colors: [UIColor(hex: "833AB4"), UIColor(hex: "FD1D1D"), UIColor(hex: "FCB045")])
        
        navigationBar.isTranslucent = false
    }
    
}
