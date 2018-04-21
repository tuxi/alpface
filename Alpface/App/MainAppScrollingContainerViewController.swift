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
        collectionView.backgroundColor = UIColor.black
        return collectionView
    }()
    
    private lazy var collectionViewItems: [CollectionViewSection] = [CollectionViewSection]()
    public var initialPage = 0
    public func displayViewController() -> UIViewController? {
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
                homeVc.title = "首页"
                homeVc.navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "potd-mini"), style: .plain, target: self, action: #selector(openStoryCreationPage))
                let searchVc = ExploreViewController()
                searchVc.title = "关注"
                let messageVc = MessageViewController()
                messageVc.title = "消息"
                let userProfileVc = UserProfileViewController(user: nil)
                userProfileVc.title = "我"
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
        // 获取当前显示已经显示的控制器
        guard let displayIndexPath = collectionView.indexPathsForVisibleItems.first else { return }
        guard let displayIndexPathController = collectionViewItems[0].items[displayIndexPath.row].model as? UIViewController else {return}
        displayIndexPathController.endAppearanceTransition()
        
        // 获取已离开屏幕的cell上控制器，执行其view消失的生命周期方法
        guard let endDisplayingViewController = collectionViewItems[indexPath.section].items[indexPath.row].model as? UIViewController else {return}
        if displayIndexPathController != endDisplayingViewController {
            // 如果完全显示的控制器和已经离开屏幕的控制器是同一个就return，防止初始化完成后是同一个
            endDisplayingViewController.endAppearanceTransition()
        }
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.3) {
                UIApplication.shared.setNeedsStatusBarAppearanceUpdate()
            }
        }
        
    }
    
    /// cell 即将显示在屏幕时调用
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if initialPage > 0 {
            show(page: initialPage, animated: false)
            initialPage = 0
        }

        /// 获取即将显示的cell上的控制器，执行其view显示的生命周期方法
        guard let willDisplayController = collectionViewItems[0].items[indexPath.row].model as? UIViewController else {return}
        willDisplayController.beginAppearanceTransition(true, animated: true)
        
        /// 获取即将消失的控制器（当前collectionView显示的cell就是即将要离开屏幕的cell）
        guard let willEndDisplayingIndexPath = collectionView.indexPathsForVisibleItems.first else { return }
        guard let willEndDisplayingController = collectionViewItems[0].items[willEndDisplayingIndexPath.row].model as? UIViewController else {return}
        if willEndDisplayingController != willDisplayController {
            // 如果是同一个控制器return，防止初始化完成后是同一个
            willEndDisplayingController.beginAppearanceTransition(false, animated: true)
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return collectionViewItems[indexPath.section].items[indexPath.row].size
    }
    
//    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        if scrollView != collectionView {
//            return
//        }
//        self.collectionView(didEndScroll: scrollView as! UICollectionView)
//    }
//
//    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
//        if decelerate == false {
//            if scrollView != collectionView {
//                return
//            }
//            self.collectionView(didEndScroll: scrollView as! UICollectionView)
//        }
//    }
//
//    fileprivate func collectionView(didEndScroll collectionView: UICollectionView) {
//
//        let row = Int(ceil(collectionView.contentOffset.y / collectionView.frame.height))
//        let indexPath = IndexPath(item: row, section: 0)
//        let cell = self.collectionView.cellForItem(at: indexPath) as? ScrollingContainerCell
//        self.collectionView(self.collectionView, didDisplay: cell, forItemAt: indexPath)
//    }
//
//    /// collectionView cell 完全显示后回调
//    fileprivate func collectionView(_ collectionView: UICollectionView, didDisplay cell: ScrollingContainerCell?, forItemAt indexPath: IndexPath) {
//        // 对于willDisplay 时的 beginAppearanceTransition(true)
//        displayViewController()?.endAppearanceTransition()
//    }
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
        if viewController.title != "首页" {
            /// 用户点击的只要不是首页，当前如果未登录则弹出登录页面
            if AuthenticationManager.shared.isLogin == false {
                showLoginViewController()
                return false
            }
        }
        return true
    }

    
    public func showLoginViewController() {
        if AuthenticationManager.shared.isLogin == false {
            let loginVc = LoginViewController()
            loginVc.delegate = self
            let nav = MainNavigationController(rootViewController: loginVc)
            /// 模态出来的控制器半透明
            nav.modalPresentationStyle = .overCurrentContext
            showDetailViewController(nav, sender: self)
        }
    }
}

extension MainAppScrollingContainerViewController: LoginViewControllerDelegate {
    func loginViewController(loginSuccess user: User) {
      
    }
    
    func loginViewController(loginFailure error: Error) {
        
    }
}
