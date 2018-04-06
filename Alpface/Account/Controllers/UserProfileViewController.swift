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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.locationString = "Beijing"
        self.username = AuthenticationManager.shared.loginUser?.username
        if let userid = AuthenticationManager.shared.loginUser?.userid {
            self.nickname = "用户号" + ":\(userid)"
        }
        let avatarPlaceImage = UIImage.init(named: "icon.png")
        let avatar = AuthenticationManager.shared.loginUser?.getAvatarURL()
        if let url = avatar {
            self.profileHeaderView.iconImageView.kf.setImage(with: url, placeholder: avatarPlaceImage, options: nil, progressBlock: nil, completionHandler: nil)
        }
        else {
            self.profileHeaderView.iconImageView.image = avatarPlaceImage
        }
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
        switch index {
        case 0:
            return MyReleaseViewController()
        case 1:
            return MyFavoriteViewController()
        case 2:
            return MyStoryViewController()
        default:
            return ChildListViewController()
        }
    }
}



