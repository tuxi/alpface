//
//  MyFavoriteViewController.swift
//  Alpface
//
//  Created by swae on 2018/4/6.
//  Copyright © 2018年 alpface. All rights reserved.
//

import UIKit

class MyFavoriteViewController: UserProfileChildCollectionViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.collectionView.xy_loading = true
        VideoRequest.shared.getUserLikes(contentType: 6, userId: 1, success: {[weak self] (response) in
            guard let response = response as? [VideoItem] else {
                return
            }
            self?.segmentModel?.data?.append(contentsOf: response)
            self?.collectionView.reloadData()
            self?.collectionView.xy_loading = false
        }) { (error) in
            
            if let e = error as NSError? {
                MBProgressHUD.xy_show(e.userInfo.debugDescription)
            }
        }
        
    }
    override func titleForEmptyDataView() -> String? {
        return "TA还没有喜欢的作品哦~"
    }
    

}
