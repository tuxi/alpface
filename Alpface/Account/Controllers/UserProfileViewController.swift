//
//  UserProfileViewController.swift
//  Alpface
//
//  Created by swae on 2018/3/11.
//  Copyright © 2018年 alpface. All rights reserved.
//

import UIKit
import SDWebImage

let ALPSegmentHeight: CGFloat = 44.0
let ALPNavigationBarHeight: CGFloat = 44.0
let ALPStatusBarHeight: CGFloat = UIApplication.shared.statusBarFrame.height

@objc(ALPUserProfileViewController)
class UserProfileViewController: BaseProfileViewController {
    
    fileprivate var isViewDidLoad: Bool = false

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
    fileprivate var _user: User?
    public var user: User? {
        get {
            return _user
        }
        set {
            if _user?.username != newValue?.username {
                if isViewDidLoad == false { return }
                _user = newValue
                self.reloadCollectionData()
                self.discoverUserByUsername()
            }
        }
    }
    
    convenience init(user: User?) {
        self.init()
        _user = user
    }
    
    deinit {
        self.removeObserver()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.reloadCollectionData()
        self.discoverUserByUsername()
        self.addObserver()
        isViewDidLoad = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.1) {        
            UIApplication.shared.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func controller(forSegment index: Int) -> ProfileViewChildControllerProtocol {
        var vc = UserProfileChildCollectionViewController()
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
    
    @objc func reloadCollectionData() -> Void {
        self.profileHeaderView.locationLabel.text = self.user?.address
        self.profileHeaderView.nicknameLabel.text = self.user?.nickname
        self.profileHeaderView.summaryLabel.text = self.user?.summary
        if let cover_url = self.user?.getCoverURL() {
            self.stickyHeaderView.headerCoverView.sd_setImage(with: cover_url)
        }
        else {
            self.stickyHeaderView.headerCoverView.image = nil
        }
        self.navigationTitleLabel.text = self.user?.nickname
        if let userName = self.user?.username {
            self.profileHeaderView.usernameLabel.text = "用户号" + ":" + userName
        }
        let avatarPlaceImage = UIImage.init(named: "icon.png")
        let avatar = self.user?.getAvatarURL()
        if let url = avatar {
            self.profileHeaderView.iconImageView.sd_setImage(with: url, placeholderImage: avatarPlaceImage)
        }
        else {
            self.profileHeaderView.iconImageView.image = avatarPlaceImage
        }
        
        self.profileHeaderView.followButton.setTitle("Follow", for: .normal)
        if self.user?.username == AuthenticationManager.shared.loginUser?.username {
            // 用户自己的个人页面
            self.profileHeaderView.followButton.setTitle("Settings", for: .normal)
            self.profileHeaderView.followButton.addTarget(self, action: #selector(gotoSettings), for: .touchUpInside)
        }
        
        self.view.layoutIfNeeded()
        self.setNeedsUpdateHeaderLayout()
        self.updateHeaderLayoutIfNeeded()
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
        
        self.controllers.forEach { (controller) in
            if let c = controller as? UserProfileChildCollectionViewController {
                if c.isMember(of: MyReleaseViewController.classForCoder()) {
                    c.collectionItems = self.user?.my_videos
                }
                else if c.isMember(of: MyFavoriteViewController.classForCoder()) {
                    c.collectionItems = self.user?.my_likes
                }
                else {
                    c.collectionItems = []
                }
                controller.childScrollView()?.xy_loading = false
                let collectionView = controller.childScrollView() as? UICollectionView
                collectionView?.reloadData()
            }
        }
    }
}

extension UserProfileViewController {
    fileprivate func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(authenticationAccountProfileChanged(notification:)), name: NSNotification.Name.AuthenticationAccountProfileChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(publushVideoSuccess), name: NSNotification.Name.PublushVideoSuccess, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(loginSuccess(notification:)), name: NSNotification.Name.ALPLoginSuccess, object: nil)
    }
    
    @objc fileprivate func authenticationAccountProfileChanged(notification: NSNotification) {
        guard let userIno = notification.userInfo else {
            return
        }
        guard let user = userIno["user"] as? User else {
            return
        }
        if user.userid == self.user?.userid {
            self.user = user
            self.reloadCollectionData()
        }
    }
    
    @objc fileprivate func publushVideoSuccess() {
        self.discoverUserByUsername()
    }
    
    @objc fileprivate func loginSuccess(notification: NSNotification) {
        guard let userIno = notification.userInfo else {
            return
        }
        guard let user = userIno[ALPConstans.AuthKeys.ALPAuthenticationUserKey] as? User else {
            return
        }
        self.user = user
        self.reloadCollectionData()
    }
    
    fileprivate func removeObserver() {
        NotificationCenter.default.removeObserver(self)
    }
}

extension UserProfileViewController {
    @objc fileprivate func gotoSettings() {
        let settings = SettingsViewController()
        self.navigationController?.pushViewController(settings, animated: true)
    }
}

extension UserProfileViewController {
    fileprivate func discoverUserByUsername() {
        if self.user == nil {
            self.user = AuthenticationManager.shared.loginUser
        }
        self.controllers.forEach { (controller) in
            controller.childScrollView()?.xy_loading = true
        }
        guard let username = self.user?.username else { return }
        VideoRequest.shared.discoverUserByUsername(username: username, success: {[weak self] (response) in
            guard let user = response as? User else {
                return
            }
            self?._user = user
            self?.reloadCollectionData()
        }) {[weak self] (error) in
            self?.reloadCollectionData()
            if let e = error as NSError? {
                if e.domain == ALPConstans.AuthKeys.ALPAuthPermissionErrorValue {
                    AuthenticationManager.shared.logout()
                    if let rootVc = self?.navigationController?.viewControllers.first {
                        self?.navigationController?.viewControllers = [rootVc]
                        let delegate = UIApplication.shared.delegate as? AppDelegate
                        delegate?.rootViewController?.showHomePage()
                    }
                    
                }
            }
        }
    }
}



