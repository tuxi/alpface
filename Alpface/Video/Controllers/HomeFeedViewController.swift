//
//  HomeFeedViewController.swift
//  Alpface
//
//  Created by swae on 2018/4/21.
//  Copyright © 2018年 alpface. All rights reserved.
//

import UIKit

class HomeFeedViewController: MainFeedViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        requestRandomVideos()
        self.navigationItem.title = "推荐"
        addObserver()
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
            guard let list = response as? [VideoItem] else {
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
