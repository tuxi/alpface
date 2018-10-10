//
//  HomeFeedViewController.swift
//  Alpface
//
//  Created by swae on 2018/4/21.
//  Copyright © 2018年 alpface. All rights reserved.
//

import UIKit
import MBProgressHUD

class HomeFeedViewController: MainFeedViewController {
    
    private lazy var navigationBar: HomeNavigationView = {
        var navigationHeight: CGFloat = 66.0;
        if AppUtils.isIPhoneX() {
            navigationHeight = 88.0
        }
        let navigationBar = HomeNavigationView(frame: CGRect.init(x: 0, y: 0, width: self.view.frame.size.width, height: navigationHeight))
        navigationBar.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.2)
        return navigationBar
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "推荐"
        addObserver()
        
        self.addHeaderRefresh(self.collectionView, navigationBar: self.navigationBar) {[weak self] () -> (Void) in
            self?.requestRandomVideos()
        }
        
        self.beginRefresh()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func playInteractionViewController(playInteraction controller: PlayInteractionViewController, didClickUserAvatarFrom video: VideoItem) {
        let delegate = UIApplication.shared.delegate as? AppDelegate
        delegate?.rootViewController?.showUserProfilePage(user: video.user!)
    }
    
    deinit {
        removeObserver()
    }
    
}

extension HomeFeedViewController {
    fileprivate func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(requestRandomVideos), name: NSNotification.Name.ALPRefreshHomePage, object: nil)
    }
    
    fileprivate func removeObserver() {
        NotificationCenter.default.removeObserver(self)
    }
}

extension HomeFeedViewController {
    
    @objc fileprivate func requestRandomVideos() -> Void {
        VideoRequest.shared.getRadomVideos(success: {[weak self] (response) in
            NotificationCenter.default.post(name: NSNotification.Name.ALPPlayerStopAll, object: self)
            guard let list = response as? [VideoItem] else {
                return
            }
            // 刷新数据时，移除资源，但是必须暂停全部
            self?.videoItems.forEach({ (item) in
                item.isAllowPlay = false
            })
            self?.videoItems.removeAll()
            var array : [PlayVideoModel] = [PlayVideoModel]()
            for video in list {
                let cellModel = PlayVideoModel(videoItem: video)
                array.append(cellModel)
            }
            self?.videoItems += array
            self?.collectionView.reloadData()
            self?.endRefresh()
            DispatchQueue.main.async {
                self?.updatePlayControl()
            }
        }) {[weak self] (error) in
            let errorStr = error?.localizedDescription ?? "请求随机视频失败，" + "双击底部[首页]按钮可刷新页面！"
            MBProgressHUD.xy_show(errorStr)
            self?.endRefresh()
        }
    }
}
