//
//  MainAppScrollingContainerViewController.swift
//  Alpface
//
//  Created by xiaoyuan on 2018/3/11.
//  Copyright © 2018年 alpface. All rights reserved.
//

import UIKit

@objc(ALPMainAppScrollingContainerViewController)
class MainAppScrollingContainerViewController: UIViewController {

    fileprivate lazy var collectionView: GestureCoordinatingCollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0.0
        layout.minimumInteritemSpacing = 0.0
        layout.scrollDirection = .horizontal
        let collectionView = GestureCoordinatingCollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isPagingEnabled = true
        collectionView.bounces = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(ScrollingContainerCell.classForCoder(), forCellWithReuseIdentifier: "ScrollingContainerCell")
        // 设置delaysContentTouches为false目的是为了防止UIButton快速按不产生高亮效果
        collectionView.delaysContentTouches = false;
        collectionView.canCancelContentTouches = true;
        return collectionView
    }()
    
    private lazy var collectionViewItems: [CollectionViewSection] = [CollectionViewSection]()
    public var initialPage = 0
    private func displayViewController() -> UIViewController? {
        let indexPath = collectionView.indexPathsForVisibleItems.first
        guard let ip = indexPath else { return nil }
        let vc = collectionViewItems[ip.section].items[ip.row].model as? UIViewController
        return vc
    }
    
    public func show(page index: NSInteger, animated: Bool) {
        if collectionView.indexPathsForVisibleItems.first?.row == index {
            return
        }
        collectionView .scrollToItem(at: IndexPath.init(row: index, section: 0), at: .centeredHorizontally, animated: animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupUI()
        setupCollectionViewItems()
    }
    
    
    private func setupUI() {
        view.backgroundColor = UIColor.clear
        collectionView.layer.cornerRadius = 3.0
        collectionView.layer.masksToBounds = true
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|[collectionView]|", options: [], metrics: nil, views: ["collectionView": collectionView]))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[collectionView]|", options: [], metrics: nil, views: ["collectionView": collectionView]))
    }
    
    private func setupCollectionViewItems() {
        let section = CollectionViewSection()
        collectionViewItems.append(section)
        for i in 0...2 {
            let item = MainAppScrollingContainerItem()
            switch i {
            case 0:
                // 创建故事
                let createVc = StoryCreationViewController()
                createVc.delegate = self as StoryCreationViewControllerDelegate
                let nav = MainNavigationController(rootViewController: createVc)
                item.model = nav
                break
            case 1:
                // 主页
                let tabBarVc = MainTabBarController()
                tabBarVc.delegate = self
                let homeVc = MainFeedViewController()
                homeVc.title = "home"
                homeVc.navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "potd-mini"), style: .plain, target: self, action: #selector(openStoryCreationPage))
                let searchVc = ExploreViewController()
                searchVc.title = "search"
                let messageVc = MessageViewController()
                messageVc.title = "message"
                let userProfileVc = UserProfileViewController()
                userProfileVc.title = "user"
                let nav1 = MainNavigationController.init(rootViewController: homeVc)
                let nav2 = MainNavigationController(rootViewController: searchVc)
                let nav3 = MainNavigationController(rootViewController: messageVc)
                let nav4 = MainNavigationController(rootViewController: userProfileVc)
                tabBarVc.setViewControllers([nav1, nav2, nav3, nav4], animated: true)
                item.model = tabBarVc
                tabBarVc.tabBar.backgroundColor = .clear
                tabBarVc.tabBar.backgroundImage = UIImage()
                tabBarVc.tabBar.shadowImage = UIImage()
                tabBarVc.tabBar.isTranslucent = true
                // 设置tabbarItem的文本向上便宜10.0，因为无图片，所以尽量居中显示
                let offSet = UIOffsetMake(0.0, -10.0)
                nav1.tabBarItem.titlePositionAdjustment = offSet
                nav2.tabBarItem.titlePositionAdjustment = offSet
                nav3.tabBarItem.titlePositionAdjustment = offSet
                nav4.tabBarItem.titlePositionAdjustment = offSet

                break
            case 2:
                let vc = UserProfileViewController()
                item.model = vc
                break
            default:
                break
            }
            item.size = view.frame.size
            section.items.append(item)
        }
        
        collectionView.reloadData()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        guard let displayVc = displayViewController() else { return .default }
        return displayVc.preferredStatusBarStyle
    }
    
    override var prefersStatusBarHidden: Bool {
        guard let displayVc = displayViewController() else { return false }
        return displayVc.prefersStatusBarHidden
    }
    
    // MARK: - Actions
    @objc private func openStoryCreationPage() {
        show(page: 0, animated: true)
    }

}


extension MainAppScrollingContainerViewController : UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return collectionViewItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionViewItems[section].items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ScrollingContainerCell", for: indexPath) as! ScrollingContainerCell
        
        let sec = collectionViewItems[indexPath.section]
        cell.model = sec.items[indexPath.row] as? MainAppScrollingContainerItem

        
        return cell
    }
    
    /// cell 完全离开屏幕后调用
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        /// 获取已离开屏幕的cell上控制器，执行其view消失的生命周期方法
        guard let endDisplayingViewController = collectionViewItems[indexPath.section].items[indexPath.row].model as? UIViewController else {return}
        endDisplayingViewController.beginAppearanceTransition(false, animated: true)
        endDisplayingViewController.endAppearanceTransition()
        UIApplication.shared.setNeedsStatusBarAppearanceUpdate()
    }
    
    /// cell 即将显示在屏幕时调用
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if initialPage > 0 {
            show(page: initialPage, animated: false)
            initialPage = 0
        }

        /// 获取即将显示的cell上的控制器，执行其view显示的生命周期方法
        guard let targetVc = collectionViewItems[0].items[indexPath.row].model as? UIViewController else {return}
        targetVc.beginAppearanceTransition(true, animated: true)
        targetVc.endAppearanceTransition()
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return collectionViewItems[indexPath.section].items[indexPath.row].size
    }
}

extension MainAppScrollingContainerViewController: StoryCreationViewControllerDelegate {
    func storyCreationViewController(didClickBackButton button: UIButton) {
        show(page: 1, animated: true)
    }
}


extension MainAppScrollingContainerViewController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        /// 只有首页才支持左右滑动切换控制器，向左滑动到创建故事页面，向右滑动到我的个人主页
        if tabBarController.selectedIndex == 0 {
            collectionView.isScrollEnabled = true
        }
        else {
            collectionView.isScrollEnabled = false
        }
        UIApplication.shared.setNeedsStatusBarAppearanceUpdate()
        
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if viewController.title != "home" {
            /// 用户点击的只要不是首页，当前如果未登录则弹出登录页面
            if AuthenticationManager.shared.isLogin == false {
                let loginVc = LoginViewController()
                loginVc.delegate = self
                let nav = MainNavigationController(rootViewController: loginVc)
                /// 模态出来的控制器半透明
                nav.modalPresentationStyle = .overCurrentContext
                showDetailViewController(nav, sender: self)
                return false
            }
        }
        return true
    }
    
    public func showLoginViewController() {
        if AuthenticationManager.shared.isLogin == false {
            let loginVc = LoginViewController()
            let nav = MainNavigationController(rootViewController: loginVc)
            showDetailViewController(nav, sender: self)
        }
        else {
            
        }
    }
}

extension MainAppScrollingContainerViewController: LoginViewControllerDelegate {
    func loginViewController(loginSuccess user: User) {
      
    }
    
    func loginViewController(loginFailure error: Error) {
        
    }
}
