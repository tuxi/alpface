//
//  EditUserProfileViewController.swift
//  Alpface
//
//  Created by swae on 2018/4/10.
//  Copyright © 2018年 alpface. All rights reserved.
//

import UIKit
import Kingfisher
import MBProgressHUD

class EditUserProfileViewController: UIViewController {
    
    let EditProfileTableViewCellIdentifier: String = "EditProfileTableViewCell"
    
    fileprivate var editProfileItems: [EditUserProfileModel] = []
    
    public var user: User?
    
    fileprivate lazy var tableView: UITableView = {
        let _tableView = UITableView(frame: self.view.bounds, style: .plain)
        _tableView.delegate = self
        _tableView.dataSource = self
        _tableView.showsHorizontalScrollIndicator = false
        _tableView.backgroundColor = UIColor.white
        _tableView.separatorStyle = .none
        _tableView.scrollsToTop = true
        _tableView.keyboardDismissMode = .onDrag
        _tableView.register(EditProfileTableViewCell.classForCoder(), forCellReuseIdentifier: EditProfileTableViewCellIdentifier)
        return _tableView
    }()
    
    open lazy var profileHeaderView: EditProfileHeaderView = {
        let _profileHeaderView = EditProfileHeaderView(frame: CGRect.init(x: 0, y: 0, width: self.tableView.frame.width, height: 55.0))
        _profileHeaderView.iconImageViewClickAcllBack = {
            self.chooseAvatarAction(isCover: false)
        }
        return _profileHeaderView
    }()
    
    /// 下拉头部放大控件 (头部背景视图)
    fileprivate lazy var stickyHeaderView: StickyHeaderContainerView = {
        let stickyHeaderView = StickyHeaderContainerView()
        return stickyHeaderView
    }()
    
    fileprivate lazy var changeCoverButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "icon_personal_changephoto"), for: .normal)
        button.addTarget(self, action: #selector(chooseCover), for: .touchUpInside)
        return button
    }()
    
    fileprivate lazy var tableHeaderView: UIView = {
        let view = UIView()
        return view
    }()
    
    open lazy var navigationTitleLabel: UILabel = {
        let _navigationTitleLabel = UILabel()
        _navigationTitleLabel.text = "username"
        _navigationTitleLabel.textColor = UIColor.white
        _navigationTitleLabel.font = UIFont.boldSystemFont(ofSize: 17.0)
        
        return _navigationTitleLabel
    }()
    
    /// 头部描述用户信息视图的高度(不固定值)
    open var profileHeaderViewHeight: CGFloat = 160
    
    open let changeCoverButtonHeight : CGFloat = 65.0
    open var changeCoverButtonCenterYConstraint : NSLayoutConstraint?
    open let bouncingThreshold: CGFloat = 100
    /// scrollView 向上滚动时时，固定头部背景视图，此属性为scrollView滚动到contentView.y==这个偏移量时，就固定头部背景视图，将其作为当导航条展示 (固定值)
    open func scrollToScaleDownProfileIconDistance() -> CGFloat {
        return stickyheaderContainerViewHeight - changeCoverButtonHeight
    }
    
    convenience init(user: User) {
        self.init()
        self.user = user
    }
    
    
    /// 更新table header 布局，高度是计算出来的，所以当header上的内容发生改变时，应该执行一次更新header布局
    fileprivate var needsUpdateHeaderLayout = false
    open func setNeedsUpdateHeaderLayout() {
        self.needsUpdateHeaderLayout = true
    }
    open func updateHeaderLayoutIfNeeded() {
        if self.needsUpdateHeaderLayout == true {
            self.profileHeaderViewHeight = profileHeaderView.sizeThatFits(self.tableView.bounds.size).height
            
            /// 只要第一次view布局完成时，再调整下stickyHeaderContainerView的frame，剩余的情况会在scrollViewDidScrollView:时调整
            self.stickyHeaderView.frame = self.computeStickyHeaderContainerViewFrame()
            
            
            /// 更新profileHeaderView和segmentedControlContainer的frame
            self.profileHeaderView.frame = self.computeProfileHeaderViewFrame()
            
            tableHeaderView.frame = CGRect.init(x: 0, y: 0, width: 0, height: stickyHeaderView.frame.height + profileHeaderView.frame.size.height)
            self.tableView.tableHeaderView = tableHeaderView
            profileHeaderView.frame = self.computeProfileHeaderViewFrame()
            self.needsUpdateHeaderLayout = false
        }
    }
    
    func computeStickyHeaderContainerViewFrame() -> CGRect {
        return CGRect(x: 0, y: 0, width: tableView.bounds.width, height: stickyheaderContainerViewHeight)
    }
    
    func computeProfileHeaderViewFrame() -> CGRect {
        return CGRect(x: 0, y: computeStickyHeaderContainerViewFrame().origin.y + stickyheaderContainerViewHeight, width: tableView.bounds.width, height: profileHeaderViewHeight)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupItems()
        self.prepareViews()
    }
    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        updateHeaderLayoutIfNeeded()
    }
    
    @objc fileprivate func backAction() {
        self.dismiss(animated: true, completion: nil)
    }
    
}
extension EditUserProfileViewController {
    
    fileprivate func setupItems() -> Void {
        let item1 = EditUserProfileModel(title: "姓名", content: self.user?.nickname, placeholder: "添加你的姓名")
        let item2 = EditUserProfileModel(title: "简介", content: self.user?.summary, placeholder: "在你的个人资料中添加简介", type: .textFieldMultiLine)
        let item3 = EditUserProfileModel(title: "位置", content: self.user?.address, placeholder: "添加你的位置")
        let item4 = EditUserProfileModel(title: "生日", content: nil, placeholder: "选择你的生日", type: .dateTime)
        editProfileItems.append(item1)
        editProfileItems.append(item2)
        editProfileItems.append(item3)
        editProfileItems.append(item4)
    }
    
    fileprivate func prepareViews() {
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "取消", style: .plain, target: self, action: #selector(backAction))
        self.navigationItem.title = "编辑个人资料"
        self.view.backgroundColor = UIColor.white
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "保存", style: .done, target: self, action: #selector(update(barItem:)))
        
        self.view.addSubview(tableView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        
        tableHeaderView.addSubview(stickyHeaderView)
        tableHeaderView.addSubview(profileHeaderView)
        
        tableView.tableHeaderView = tableHeaderView
        
        
        // 导航标题
        stickyHeaderView.addSubview(self.changeCoverButton)
        self.changeCoverButton.translatesAutoresizingMaskIntoConstraints = false
        self.changeCoverButton.centerXAnchor.constraint(equalTo: stickyHeaderView.centerXAnchor).isActive = true
        changeCoverButtonCenterYConstraint = self.changeCoverButton.centerYAnchor.constraint(equalTo: stickyHeaderView.centerYAnchor)
        changeCoverButtonCenterYConstraint?.isActive = true
        changeCoverButton.widthAnchor.constraint(equalToConstant: changeCoverButtonHeight).isActive = true
        changeCoverButton.heightAnchor.constraint(equalToConstant: changeCoverButtonHeight).isActive = true
        if let avatar = self.user?.getAvatarURL() {
           profileHeaderView.iconImageView.kf.setImage(with: avatar, placeholder: UIImage(named: "icon"), options: nil, progressBlock: nil, completionHandler: nil)
        }
        else {
            profileHeaderView.iconImageView.image = UIImage(named: "icon")
        }
        
        if let cover_url = self.user?.getCoverURL() {
            self.stickyHeaderView.headerCoverView.kf.setImage(with: cover_url)
        }
        else {
            self.stickyHeaderView.headerCoverView.image = nil
        }
    
        animateCoverAt(progress: 0.0)
        setNeedsUpdateHeaderLayout()
    }
    
    fileprivate func updateSaveBarButtonItem() {
        let saveItem = self.navigationItem.rightBarButtonItem
        let nickNameItem = self.editProfileItems.first
        if nickNameItem?.content?.count == 0  {
            saveItem?.isEnabled = false
        }
        else {
            saveItem?.isEnabled = true
        }
    }
    
}

extension EditUserProfileViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
   

    }
    
    /// scrollView滚动时调用
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView.isEqual(self.tableView) == false {
            return
        }
        let contentOffset = scrollView.contentOffset
        let autoOffsetTop : CGFloat = 64.0
        // 当向下滚动时，固定头部视图
        if contentOffset.y <= -autoOffsetTop {
            let bounceProgress = min(1, abs(contentOffset.y+autoOffsetTop) / bouncingThreshold)
            
            let newHeight = abs(contentOffset.y+autoOffsetTop) + stickyheaderContainerViewHeight

            // 调整 stickyHeader 的 frame
            self.stickyHeaderView.frame = CGRect(
                x: 0,
                y: contentOffset.y+autoOffsetTop,
                width: tableView.bounds.width,
                height: newHeight)
            
            // 更新blurEffectView的透明度
            self.stickyHeaderView.blurEffectView.alpha = min(1, bounceProgress * 2)
            
            // 更新headerCoverView的缩放比例
            let scalingFactor = 1 + min(log(bounceProgress + 1), 2)
            //      print(scalingFactor)
            self.stickyHeaderView.headerCoverView.transform = CGAffineTransform(scaleX: scalingFactor, y: scalingFactor)
            
        } else {
            
            self.stickyHeaderView.blurEffectView.alpha = 0
        }
        
        // 普通情况时，适用于contentOffset.y改变时的更新
        let scaleProgress = max(0, min(1, (contentOffset.y + 64) / self.scrollToScaleDownProfileIconDistance()))
        self.profileHeaderView.animator(t: scaleProgress)
        
        self.animateCoverAt(progress: (contentOffset.y + 64) / self.scrollToScaleDownProfileIconDistance())
        if contentOffset.y > -autoOffsetTop {
            
            // 当scrollView滚动到达阈值时scrollToScaleDownProfileIconDistance
            if contentOffset.y >= scrollToScaleDownProfileIconDistance() {
                self.stickyHeaderView.frame = CGRect(x: 0, y: contentOffset.y - scrollToScaleDownProfileIconDistance(), width: tableView.bounds.width, height: stickyheaderContainerViewHeight)
                // 当scrollView 的 segment顶部 滚动到scrollToScaleDownProfileIconDistance时(也就是导航底部及以上位置)，让stickyHeaderContainerView显示在最上面，防止被profileHeaderView遮挡
                tableHeaderView.bringSubview(toFront: self.stickyHeaderView)
                
            } else {
                // 当scrollView 的 segment顶部 滚动到导航底部以下位置，让profileHeaderView显示在最上面,防止用户头像被遮挡, 归位
                self.stickyHeaderView.frame = computeStickyHeaderContainerViewFrame()
                tableHeaderView.bringSubview(toFront: self.profileHeaderView)
            }
            
            
        }
        
    }
    
}

extension EditUserProfileViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.editProfileItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: EditProfileTableViewCellIdentifier, for: indexPath) as! EditProfileTableViewCell
        cell.selectionStyle = .none
        cell.model = self.editProfileItems[indexPath.row]
        cell.contentChangedCallBack = { [weak self] content in
            switch indexPath.row {
            case 0:
                self?.user?.nickname = content
            case 1:
                self?.user?.summary = content
            case 2:
                self?.user?.address = content
            default:
                print(content ?? "content not know!")
            }
            self?.updateSaveBarButtonItem()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let model = self.editProfileItems[indexPath.row]
        if model.type == .textFieldMultiLine {
            return 100.0
        }
        return 50.0
    }
}

// MARK: Animators
extension EditUserProfileViewController {
    func animateCoverAt(progress: CGFloat) {
        let centerYMin: CGFloat = 0.0
        let centerYMax: CGFloat = scrollToScaleDownProfileIconDistance()
        if progress <= 0.0 {
            changeCoverButtonCenterYConstraint?.constant = centerYMin
            changeCoverButton.alpha = 1 + progress
            return
        }
        
        let totalDistance = centerYMin - (centerYMin - centerYMax) * progress
        
        if progress > 0.0 && progress <= 1.0 {
            changeCoverButtonCenterYConstraint?.constant = -totalDistance
        }
    }
}

extension EditUserProfileViewController {
    @objc fileprivate func update(barItem: UIBarButtonItem) {
        barItem.isEnabled = false
        guard let user = self.user else {
            return;
        }
        MBProgressHUD.xy_showActivity()
        AuthenticationManager.shared.accountLogin.update(user: user, avatar: self.profileHeaderView.iconImageView.image, cover: self.stickyHeaderView.headerCoverView.image, success: { [weak self] (response) in
            barItem.isEnabled = true
            MBProgressHUD.xy_hide()
            self?.dismiss(animated: true, completion: {
                
            })
        }) { (error) in
            MBProgressHUD.xy_hide()
            barItem.isEnabled = true
        }
    }
    fileprivate func chooseAvatarAction(isCover: Bool) {
        let alertController = PCLBlurEffectAlertController(title: nil,
                                                           message: nil,
                                                           effect: UIBlurEffect(style: .extraLight),
                                                           style: .actionSheet)
        alertController.configure(overlayBackgroundColor: UIColor.lightGray.withAlphaComponent(0.3))
        alertController.configure(titleFont: UIFont.systemFont(ofSize: 24),
                                  titleColor: .red)
        alertController.configure(messageColor: .blue)
        alertController.configure(buttonFont: [.default: UIFont.systemFont(ofSize: 24),
                                               .destructive: UIFont.boldSystemFont(ofSize: 20),
                                               .cancel: UIFont.systemFont(ofSize: 14)],
                                  buttonTextColor: [.default: .brown,
                                                    .destructive: .blue,
                                                    .cancel: .gray])
        let action1 = PCLBlurEffectAlertAction(title: "拍照", style: .default) { _ in
            self.openCamera(isCover: isCover)
        }
        let action2 = PCLBlurEffectAlertAction(title: "從手機相冊選擇", style: .destructive) { _ in
            self.openLibrary(isCover: isCover)
        }
        let cancelAction = PCLBlurEffectAlertAction(title: "Cancel", style: .cancel) { _ in
            
        }
        alertController.addAction(action1)
        alertController.addAction(action2)
        alertController.addAction(cancelAction)
        alertController.show()
    }
    
    @objc func chooseCover() {
        let alertController = PCLBlurEffectAlertController(title: nil,
                                                           message: nil,
                                                           effect: UIBlurEffect(style: .extraLight),
                                                           style: .actionSheet)
        alertController.configure(overlayBackgroundColor: UIColor.lightGray.withAlphaComponent(0.3))
        alertController.configure(titleFont: UIFont.systemFont(ofSize: 24),
                                  titleColor: .red)
        alertController.configure(messageColor: .blue)
        alertController.configure(buttonFont: [.default: UIFont.systemFont(ofSize: 24),
                                               .destructive: UIFont.boldSystemFont(ofSize: 20),
                                               .cancel: UIFont.systemFont(ofSize: 14)],
                                  buttonTextColor: [.default: .brown,
                                                    .destructive: .blue,
                                                    .cancel: .gray])
        let action1 = PCLBlurEffectAlertAction(title: "拍照", style: .default) { _ in
            self.openCamera(isCover: true)
        }
        let action2 = PCLBlurEffectAlertAction(title: "從手機相冊選擇", style: .destructive) { _ in
            self.openLibrary(isCover: true)
        }
        let cancelAction = PCLBlurEffectAlertAction(title: "Cancel", style: .cancel) { _ in
            
        }
        alertController.addAction(action1)
        alertController.addAction(action2)
        alertController.addAction(cancelAction)
        alertController.show()
    }
    
}

extension EditUserProfileViewController {
    
    func croppingParameters(isCover: Bool) -> CroppingParameters {
        var size = CGSize(width: 60, height: 60)
        if isCover == true {
            size.width = self.view.frame.width
            size.height = stickyheaderContainerViewHeight
                
            }
        return CroppingParameters(isEnabled: true, resizableSide: isCover ? .vertical : .sideDefault, moveDirection: isCover ? .vertical : .moveDefault, minimumSize: size)
    }
    
    fileprivate func openCamera(isCover: Bool) {
        let cameraViewController = CameraViewController(croppingParameters: croppingParameters(isCover: isCover), allowsLibraryAccess: true) { [weak self] image, asset in
            if image != nil {
                if isCover {
                    self?.stickyHeaderView.headerCoverView.image = image
                }
                else {
                    self?.profileHeaderView.iconImageView.image = image
                }
            }
            self?.dismiss(animated: true, completion: nil)
        }
        
        present(cameraViewController, animated: true, completion: nil)
    }
    
    fileprivate func openLibrary(isCover: Bool) {
        let libraryViewController = CameraViewController.imagePickerViewController(croppingParameters: croppingParameters(isCover: isCover)) { [weak self] image, asset in
            if image != nil {
                if isCover {
                    self?.stickyHeaderView.headerCoverView.image = image
                }
                else {
                    self?.profileHeaderView.iconImageView.image = image
                }
            }
            self?.dismiss(animated: true, completion: nil)
        }
        
        present(libraryViewController, animated: true, completion: nil)
    }
}
