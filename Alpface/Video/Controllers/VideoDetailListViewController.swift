//
//  VideoDetailListViewController.swift
//  Alpface
//
//  Created by swae on 2018/4/21.
//  Copyright © 2018年 alpface. All rights reserved.
//

import UIKit
import MBProgressHUD

class VideoDetailListViewController: MainFeedViewController {
    
    fileprivate var isViewDidLoad: Bool = false
    public var userId: String? {
        didSet {
            if isViewDidLoad == false { return }
            guard let userId = userId else { return }
            getVideoByUserId(userId: userId)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        isViewDidLoad = true
        if let userId = userId {        
            getVideoByUserId(userId: userId)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.isVisibleInDisplay = true
        super.viewWillAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.isVisibleInDisplay = false
    }
    
    fileprivate func setupUI() {
        
        let backImage = UIImage(named: "icon_arrow")
        //翻转图片
        let flipImage = UIImage(cgImage: backImage!.cgImage!, scale: backImage!.scale, orientation: .down)
        
        let backButton = UIButton()
        backButton.setImage(flipImage, for: .normal)
        // 触摸按钮时发光
        backButton.showsTouchWhenHighlighted = true
        var frame = backButton.frame
        frame.size = CGSize(width: 44.0, height: 44.0)
        backButton.frame = frame
        backButton.addTarget(self, action: #selector(dismissVideoDetail), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: backButton)
        
    }
    
    @objc fileprivate func dismissVideoDetail() {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension VideoDetailListViewController {
    fileprivate func getVideoByUserId(userId: String) {
        VideoRequest.shared.getVideoByUserId(userId:userId, success: {[weak self] (response) in
            guard let list = response as? [VideoItem] else {
                MBProgressHUD.xy_show("没有获取到视频")
                return
            }
            self?.videoItems.removeAll()
            var array : [PlayVideoModel] = [PlayVideoModel]()
            for video in list {
                let cellModel = PlayVideoModel(videoItem: video)
                array.append(cellModel)
            }
            self?.videoItems += array
            self?.collectionView.reloadData()
            DispatchQueue.main.async {
                self?.updatePlayControl()
            }
        }) { (error) in
            print(error?.localizedDescription ?? "请求随机视频失败!")
        }
    }
}
