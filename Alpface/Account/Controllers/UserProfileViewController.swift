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
        return self.homeModel?.segments?.count ?? 0
    }
    
    override func segmentTitle(forSegment index: Int) -> String {
       return self.homeModel?.segments?[index].title ?? ""
    }
    
    
    fileprivate var _user: User?
    public var user: User? {
        get {
            return _user
        }
        set {
            if _user?.username != newValue?.username {
                _user = newValue
                if isViewDidLoad == false { return }
                self.reloadCollectionData()
                self.getUserHomeData()
            }
        }
    }
    
    public var homeModel: UserHomeModel?
    
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
        self.getUserHomeData()
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
    
    override func controller(forSegment index: Int) -> BaseProfileViewChildControllr {
        switch index {
        case 0:
            let vc = MyReleaseViewController()
            vc.segmentModel = self.homeModel?.segments?[index]
            return vc
        case 1:
            let vc = MyFavoriteViewController()
            vc.segmentModel = self.homeModel?.segments?[index]
            return vc
        case 2:
            return MyStoryViewController()
        default:
            return BaseProfileViewChildControllr()
        }
    }
    
    @objc func reloadCollectionData() -> Void {
        self.reloadPage()
        self.profileHeaderView.locationLabel.text = self.user?.address ?? "还未设置地址"
        self.profileHeaderView.nicknameLabel.text = self.user?.nickname
        self.profileHeaderView.summaryLabel.text = self.user?.summary ?? "该用户什么都没有留下"
        if let cover_url = self.user?.getCoverURL() {
            self.stickyHeaderView.headerCoverView.sd_setImage(with: cover_url)
        }
        else {
            self.stickyHeaderView.headerCoverView.image = nil
        }
        self.navigationTitleLabel.text = self.user?.username
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
                    c.segmentModel = self.homeModel?.segments?.first
                }
                else if c.isMember(of: MyFavoriteViewController.classForCoder()) {
                    c.segmentModel = self.homeModel?.segments?.last
                }
                else {
                    c.segmentModel = nil
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
        if user.mobile == self.user?.mobile {
            self.user = user
            self.reloadCollectionData()
        }
    }
    
    @objc fileprivate func publushVideoSuccess() {
        self.getUserHomeData()
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
    fileprivate func getUserHomeData() {
        if self.user == nil {
            return
        }
        guard let id = self.user?.id else { return }
        self.controllers.forEach { (controller) in
            controller.childScrollView()?.xy_loading = true
        }
        self.view.xy_showActivity()
        VideoRequest.shared.getUserHomeByUserId(id: id, success: {[weak self] (response) in
            self?.view.xy_hideHUD()
            guard let homeModel = response as? UserHomeModel else {
                return
            }
            self?._user = homeModel.user
            self?.homeModel = homeModel
            self?.reloadCollectionData()
        }) {[weak self] (error) in
            self?.view.xy_hideHUD()
            if let e = error as NSError? {
                MBProgressHUD.xy_show(e.userInfo.debugDescription)
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



