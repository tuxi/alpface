//
//  PublishViewController.swift
//  Alpface
//
//  Created by swae on 2018/4/16.
//  Copyright © 2018年 alpface. All rights reserved.
//

import UIKit
import MobileCoreServices

class PublishViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.white
        
        let button = UIButton(type: .custom)
        self.view.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        button.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        button.widthAnchor.constraint(equalToConstant: 120.0).isActive = true
        button.layer.cornerRadius = 20.0
        button.layer.masksToBounds = true
        button.backgroundColor = AppTheme.globalTint
        button.setTitle("上传视频", for: .normal)
        button.addTarget(self, action: #selector(openLibrary), for: .touchUpInside)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @objc fileprivate func openLibrary() {
        guard UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.savedPhotosAlbum) else {
            print("not support library")
            return
        }
        
        let imagePick = UIImagePickerController()
        imagePick.delegate = self;
        imagePick.sourceType = UIImagePickerControllerSourceType.photoLibrary
        imagePick.mediaTypes = [kUTTypeMovie as String, kUTTypeVideo as String, kUTTypeAudio as String]
        imagePick.view.backgroundColor = UIColor.init(white: 0.5, alpha: 0.5)
        self.present(imagePick, animated: true) {
            print("present ImagePicker --> ")
            
        }
    }

}

extension PublishViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
       
        print(info["UIImagePickerControllerMediaURL"] ?? "")
        picker.popViewController(animated: true)
    }
    
}
