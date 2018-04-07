//
//  UserProfileViewController.swift
//  Alpface
//
//  Created by swae on 2018/3/11.
//  Copyright © 2018年 alpface. All rights reserved.
//

import UIKit
import Kingfisher

let ALPSegmentHeight: CGFloat = 44.0
let ALPNavigationBarHeight: CGFloat = 44.0
let ALPStatusBarHeight: CGFloat = UIApplication.shared.statusBarFrame.height

@objc(ALPProfileViewController)
class UserProfileViewController: BaseProfileViewController {
    

    override func numberOfSegments() -> Int {
        return 3
    }
    
    override func segmentTitle(forSegment index: Int) -> String {
        switch index {
        case 0:
            return "作品"
        case 1:
            return "喜欢"
        default:
            return "故事"
        }
    }
    
    fileprivate var user: User?
    
    convenience init(user: User?) {
        self.init()
        if user == nil {
           self.user = AuthenticationManager.shared.loginUser
        }
        else {
            self.user = user
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.reloadCollectionData()
        self.discoverUserByUsername()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func controller(forSegment index: Int) -> ProfileViewChildControllerProtocol {
        var vc = ChildListViewController()
        switch index {
        case 0:
            vc = MyReleaseViewController()
            vc.collectionItems = self.user?.my_videos
            return vc
        case 1:
            vc = MyFavoriteViewController()
            vc.collectionItems = self.user?.my_likes
            return vc
        case 2:
            return MyStoryViewController()
        default:
            return vc
        }
    }
    
    func reloadCollectionData() -> Void {
        self.locationString = self.user?.address
        self.nickname = self.user?.nickname
        if let userName = self.user?.username {
            self.username = "用户号" + ":" + userName
        }
        let avatarPlaceImage = UIImage.init(named: "icon.png")
        let avatar = self.user?.getAvatarURL()
        if let url = avatar {
            self.profileHeaderView.iconImageView.kf.setImage(with: url, placeholder: avatarPlaceImage, options: nil, progressBlock: nil, completionHandler: nil)
        }
        else {
            self.profileHeaderView.iconImageView.image = avatarPlaceImage
        }
        
        self.setNeedsUpdateHeaderLayout = true
        self.updateHeaderLayoutIfNeeded()
        
        self.controllers.forEach { (controller) in
            if let c = controller as? ChildListViewController {
                if c.isMember(of: MyReleaseViewController.classForCoder()) {
                    c.collectionItems = self.user?.my_videos
                }
                else if c.isMember(of: MyFavoriteViewController.classForCoder()) {
                    c.collectionItems = self.user?.my_likes
                }
                else {
                    c.collectionItems = []
                }
            }
        }
    }
}

extension UserProfileViewController {
    fileprivate func discoverUserByUsername() {
        if self.user == nil {
            self.user = AuthenticationManager.shared.loginUser
        }
        guard let username = self.user?.username else { return }
        VideoRequest.shared.discoverUserByUsername(username: username, success: { (response) in
            guard let user = response as? User else {
                return
            }
            self.user = user
            self.reloadCollectionData()
        }) { (error) in
            
        }
    }
}



