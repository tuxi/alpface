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
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension HomeFeedViewController {
    
    fileprivate func requestRandomVideos() -> Void {
        VideoRequest.shared.getRadomVideos(success: {[weak self] (response) in
            guard let list = response as? [VideoItem] else {
                #if DEBUG
                self?.videoItems.removeAll()
                let videoItem = VideoItem()
                let cellModel = PlayVideoModel(videoItem: videoItem)
                self?.videoItems.append(cellModel)
                self?.collectionView.reloadData()
                DispatchQueue.main.async {
                    self?.collectionView(didEndScroll: (self?.collectionView)!)
                }
                #endif
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
                self?.collectionView(didEndScroll: (self?.collectionView)!)
            }
        }) { (error) in
            print(error?.localizedDescription ?? "请求随机视频失败!")
        }
    }
}
