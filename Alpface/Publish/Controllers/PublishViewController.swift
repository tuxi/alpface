//
//  PublishViewController.swift
//  Alpface
//
//  Created by swae on 2018/4/16.
//  Copyright © 2018年 alpface. All rights reserved.
//

import UIKit
import MobileCoreServices
import MBProgressHUD

extension NSNotification.Name {
    /// 视频发送成功
    public static let PublushVideoSuccess: NSNotification.Name = NSNotification.Name(rawValue: "PublushVideoSuccess")
}

class PublishViewController: UIViewController {
    @IBOutlet weak var titleTextView: AdaptiveTextView!
    @IBOutlet weak var selectVideoButton: UIButton!
    @IBOutlet weak var describeTextView: AdaptiveTextView!
    @IBOutlet weak var publishButton: UIButton!
    @IBOutlet weak var describeTextViewHeightConstraint: NSLayoutConstraint!
    public lazy var playVideoVc: PlayVideoViewController = {
        let playVideoVc = PlayVideoViewController()
        return playVideoVc
    }()
    
    fileprivate var filePath: String? {
        didSet {
            if let filePath = filePath {
                self.playVideoVc.preparePlayback(url: URL(fileURLWithPath: filePath))
                self.playVideoVc.isEndDisplaying = false
                self.playVideoVc.autoPlay()
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.white
        selectVideoButton.setTitle("选择视频", for: .normal)
        selectVideoButton.addTarget(self, action: #selector(openLibrary), for: .touchUpInside)
        selectVideoButton.backgroundColor = AppTheme.globalTint
        
        publishButton.setTitle("上传", for: .normal)
        publishButton.addTarget(self, action: #selector(upload), for: .touchUpInside)
        publishButton.layer.cornerRadius = 20.0
        publishButton.layer.masksToBounds = true
        publishButton.backgroundColor = AppTheme.globalTint
        
        describeTextView.placeholder = "输入视频描述..."
        titleTextView.placeholder = "输入视频标题..."
        titleTextView.cornerRadius = 4
        titleTextView.placeholderColor = UIColor.black
        describeTextView.placeholderColor = UIColor.black
        describeTextView.maxNumberOfLines = 3
        titleTextView.maxNumberOfLines = 1
        describeTextView.textValueDidChanged {[weak self] (text, textHeight) in
            self?.describeTextViewHeightConstraint.constant = textHeight
        }
        
        playVideoVc.view.translatesAutoresizingMaskIntoConstraints = false
        self.selectVideoButton.addSubview(self.playVideoVc.view)
        playVideoVc.view.leadingAnchor.constraint(equalTo: self.selectVideoButton.leadingAnchor).isActive = true
        playVideoVc.view.trailingAnchor.constraint(equalTo: self.selectVideoButton.trailingAnchor).isActive = true
        playVideoVc.view.topAnchor.constraint(equalTo: self.selectVideoButton.topAnchor).isActive = true
        playVideoVc.view.bottomAnchor.constraint(equalTo: self.selectVideoButton.bottomAnchor).isActive = true
        playVideoVc.view.isUserInteractionEnabled = false
        playVideoVc.view.backgroundColor = UIColor.white
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "取消", style: .plain, target: self, action: #selector(backAction))
        self.navigationItem.title = "上传视频"
        self.view.backgroundColor = UIColor.white
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @objc fileprivate func upload() {
        guard let path = self.filePath else {
            MBProgressHUD.xy_show("还未选择视频...")
            return
        }
        if self.titleTextView.text.isEmpty || self.describeTextView.text.isEmpty {
            MBProgressHUD.xy_show("请添加标题和描述文本")
            return
        }
        MBProgressHUD.xy_showActivity()
        VideoRequest.shared.upload(title: self.titleTextView.text, describe: self.describeTextView.text, videoPath: path, progress: { (p) in
            print("上传进度\(p.completedUnitCount)")
        }, success: {[weak self] (response) in
            guard let video = response as? VideoItem else { return }
            NotificationCenter.default.post(name: NSNotification.Name.PublushVideoSuccess, object: self, userInfo: ["video": video])
            MBProgressHUD.xy_hide()
            MBProgressHUD.xy_show("视频上传完成")
            self?.backAction()
        }) { (error) in
            MBProgressHUD.xy_hide()
        }
        
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
        }
    }
    
    @objc fileprivate func backAction() {
        self.dismiss(animated: true, completion: nil)
    }

}

extension PublishViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
       let fileURL = info["UIImagePickerControllerMediaURL"] as? URL
        self.filePath = fileURL?.path
        picker.dismiss(animated: true) {
            
        }
    }
    
}
