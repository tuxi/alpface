//
//  MainAppScrollingContainerViewController.swift
//  Alpface
//
//  Created by xiaoyuan on 2018/3/11.
//  Copyright © 2018年 alpface. All rights reserved.
//

import UIKit
import MBProgressHUD

extension NSNotification.Name {
    static let ALPRefreshHomePage = NSNotification.Name(rawValue: "ALPRefreshHomePage")
    static let ALPPlayerStopAll = NSNotification.Name(rawValue: "ALPPlayerStopAll")
}

@objc(ALPMainAppScrollingContainerViewController)
class MainAppScrollingContainerViewController: UIViewController {
    
    struct MainAppScrollingTitles {
        static let home = "首页"
        static let explore = "关注"
        static let message = "消息"
        static let myProfile = "我的"
    }
    
    fileprivate lazy var pageController: UIPageViewController = {
        let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pageViewController.dataSource = self
        pageViewController.delegate = self
        pageViewController.view.backgroundColor = UIColor.black
        return pageViewController
    }()

    /// 记录上次选中tabbarItem的时间，做双击刷新功能
    fileprivate var lastSelectedTabbarItemDate: Date?
    private lazy var collectionSection: CollectionViewSection = {
        return CollectionViewSection()
    }()
    
    public var initialPage = 0
    public var currentIndex = NSNotFound
    public func displayViewController() -> UIViewController? {
        let vc = viewControllerAtIndex(currentIndex)
        return vc
    }
    public func displayIndex() -> NSInteger {
        return currentIndex
    }
    
    public func isHomePageVisible() -> Bool {
        return self.homeFeedController.isVisibleInDisplay
    }

    public var homeFeedController: HomeFeedViewController!
    public var mainTabbarController: MainTabBarController!
    public var userProfileController: UserProfileViewController!
    public var cameraController: AlpVideoCameraViewController!
    
    fileprivate var backgroundViewTopC: NSLayoutConstraint!
    fileprivate var backgroundViewTopC1: NSLayoutConstraint!
    
    public func show(page index: NSInteger, animated: Bool, completion: ((_ finished: Bool) -> Void)? = nil) {

        if currentIndex == index {
            return
        }
        let direction: UIPageViewControllerNavigationDirection = (index > currentIndex) ? .forward : .reverse
        
        if let controller = collectionSection.items[index].model as? UIViewController {
            currentIndex = index
            pageController.setViewControllers([controller], direction: direction, animated: animated, completion: completion)
            
        }
        
    }
   
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupUI()
        setupCollectionViewItems()
        
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor.clear
        pageController.view.layer.cornerRadius = 3.0
        pageController.view.layer.masksToBounds = true
        view.addSubview(pageController.view)
        addChildViewController(pageController)
        pageController.didMove(toParentViewController: self)
        pageController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|[collectionView]|", options: [], metrics: nil, views: ["collectionView": pageController.view]))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[collectionView]|", options: [], metrics: nil, views: ["collectionView": pageController.view]))
        let scrollView = pageScrollView()
//        scrollView?.bounces = false
        // 设置delaysContentTouches为false目的是为了防止UIButton快速按不产生高亮效果
        scrollView?.delaysContentTouches = false;
        scrollView?.canCancelContentTouches = true;
        scrollView?.backgroundColor = UIColor.clear
    }
    
    private func setupCollectionViewItems() {
        let section = collectionSection
        for i in 0...2 {
            let item = MainAppScrollingContainerItem()
            switch i {
            case 0:
                // 创建故事
                let cameraVc = AlpVideoCameraViewController()
                cameraVc.delegate = self
                let nac = MainCameraNavigationController(rootViewControllerNoWrapping: cameraVc)
                item.model = nac
                cameraController = cameraVc
                break
            case 1:
                // 主页
                let tabBarVc = MainTabBarController()
                mainTabbarController = tabBarVc
                tabBarVc.delegate = self
                let homeVc = HomeFeedViewController()
                homeFeedController = homeVc
                homeVc.title = MainAppScrollingTitles.home
                homeVc.navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "potd-mini"), style: .plain, target: self, action: #selector(openStoryCreationPage))
                let searchVc = ExploreViewController()
                searchVc.title = MainAppScrollingTitles.explore
                let messageVc = MessageViewController()
                let selectMusicVC = TabbarPlaceholderViewController()
                messageVc.title = MainAppScrollingTitles.message
                let userProfileVc = MyProfileViewController(user: AuthenticationManager.shared.loginUser)
                userProfileVc.title = MainAppScrollingTitles.myProfile
                let nac1 = MainNavigationController.init(rootViewController: homeVc)
                let nac2 = MainNavigationController(rootViewController: searchVc)
                let nac4 = MainNavigationController(rootViewController: messageVc)
                let nac5 = MainNavigationController(rootViewController: userProfileVc)
                tabBarVc.setViewControllers([nac1, nac2, selectMusicVC, nac4, nac5], animated: true)
                item.model = tabBarVc
                tabBarVc.tabBar.backgroundColor = .clear
                tabBarVc.tabBar.backgroundImage = UIImage()
                tabBarVc.tabBar.shadowImage = UIImage()
                tabBarVc.tabBar.isTranslucent = true
                // 设置tabbarItem的文本向上偏移15.0，因为无图片，所以尽量居中显示
                let offSet = UIOffsetMake(0.0, -15.0)
                nac1.tabBarItem.titlePositionAdjustment = offSet
                nac2.tabBarItem.titlePositionAdjustment = offSet
                selectMusicVC.tabBarItem.titlePositionAdjustment = offSet
                nac4.tabBarItem.titlePositionAdjustment = offSet
                nac5.tabBarItem.titlePositionAdjustment = offSet
                selectMusicVC.tabBarItem.image = UIImage(named: "btn_home_add")
                addTabbarBackgroundView(tabbar: tabBarVc.tabBar)
                updateTabBarBackgroundView(tabbar: tabBarVc.tabBar, selectedIndex: 0)
                break
            case 2:
                userProfileController = UserProfileViewController()
//                let nac = MainNavigationController.init(rootViewController: userProfileController)
                item.model = userProfileController
                break
            default:
                break
            }
            item.size = view.frame.size
            section.items.append(item)
        }
        
//        collectionView.reloadData()
        show(page: initialPage, animated: false)
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
        show(page: 0, animated: true, completion: nil)
    }
    
    fileprivate func pageScrollView() -> UIScrollView? {
        for subview in pageController.view.subviews {
            if let subview = subview as? UIScrollView {
                return subview
            }
        }
        return nil
    }
    
    fileprivate func indexOfViewController(_ controller: UIViewController) -> Int {
        var idx = 0
        for item in collectionSection.items {
            if let vc = item.model as? UIViewController, vc == controller {
                return idx
            }
            idx += 1
        }
        return NSNotFound
    }
    
    fileprivate func viewControllerAtIndex(_ index: Int) -> UIViewController? {
        if self.collectionSection.items.count == 0 || index >= self.collectionSection.items.count {
            return nil
        }
        
        return self.collectionSection.items[index].model as? UIViewController
    }
}


extension MainAppScrollingContainerViewController: StoryCreationViewControllerDelegate {
    func storyCreationViewController(didClickBackButton button: UIButton) {
        show(page: 1, animated: true, completion: nil)
    }
}


extension MainAppScrollingContainerViewController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        /// 只有首页才支持左右滑动切换控制器，向左滑动到创建故事页面，向右滑动到我的个人主页
        if tabBarController.selectedIndex == 0 {
            pageScrollView()?.isScrollEnabled = true
//            collectionView.isScrollEnabled = true
            homeFeedController.isVisibleInDisplay = true
//            tabBarController.tabBar.backgroundImage = UIImage()
        }
        else {
            homeFeedController.isVisibleInDisplay = false
//            collectionView.isScrollEnabled = false
            pageScrollView()?.isScrollEnabled = false
//            tabBarController.tabBar.backgroundImage = UIImage(color: UIColor(white: 0.1, alpha: 0.8))
        }
        updateTabBarBackgroundView(tabbar: tabBarController.tabBar, selectedIndex: tabBarController.selectedIndex)
        UIApplication.shared.setNeedsStatusBarAppearanceUpdate()
        
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if viewController.title != MainAppScrollingTitles.home {
            /// 用户点击的只要不是首页，当前如果未登录则弹出登录页面
            if AuthenticationManager.shared.isLogin == false {
                showLoginViewController()
                return false
            }
            if viewController.isKind(of: TabbarPlaceholderViewController.classForCoder()) == true {
                self.presentSelectMusic()
                return false
            }
            // 如果是我的页面，就传递model
            if viewController.title == MainAppScrollingTitles.myProfile {
                if let nac = viewController as? MainNavigationController {
                    if let vc = nac.viewControllers.first as? MyProfileViewController {
                        vc.user = AuthenticationManager.shared.loginUser
                    }
                }
            }
        }
        
        // 确定是否是homeFeedController在显示着
        if let nac = viewController as? MainNavigationController {
            if nac.isKind(of: MainNavigationController.classForCoder()) {
                if nac.visibleViewController == self.homeFeedController {
                    self.homeFeedController.isVisibleInDisplay = true
                }
            }
        }
        else {
            self.homeFeedController.isVisibleInDisplay = false
        }
        
        // 双击首页刷新
        // 即将选中的页面是之前上一次选中的控制器页面
        if viewController.isEqual(tabBarController.selectedViewController) == false {
            return true
        }
        
        // 获取当前点击时间
        let currentDate = Date()
        if let lastSelectedTabbarItemDate = self.lastSelectedTabbarItemDate {
            let timeInterval = currentDate.timeIntervalSince1970 - lastSelectedTabbarItemDate.timeIntervalSince1970
            
            // 两次点击时间间隔少于 0.5S 视为一次双击
            if timeInterval < 0.5 {
                // 通知首页刷新数据
                guard let nac = viewController as? MainNavigationController else {
                    return true
                }
                if nac.viewControllers.count == 0 {
                    return false
                }
                if self.homeFeedController.isVisibleInDisplay == true {
                    NotificationCenter.default.post(name: NSNotification.Name.ALPRefreshHomePage, object: nil)
                    // 双击之后将上次选中时间置为1970年0点0时0分0秒,用以避免连续三次或多次点击
                    self.lastSelectedTabbarItemDate = Date(timeIntervalSince1970: 0)
                    return false
                }
            }
        }
        // 若是单击将当前点击时间复制给上一次单击时间
        self.lastSelectedTabbarItemDate = currentDate
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

    
    fileprivate func addTabbarBackgroundView(tabbar: UITabBar) {
        let backgroundView = UIView(frame: .zero)
        backgroundView.tag = 222
        backgroundView.alpha = 0
        tabbar.addSubview(backgroundView)
        tabbar.insertSubview(backgroundView, at: 0)
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.leadingAnchor.constraint(equalTo: tabbar.leadingAnchor).isActive = true
        backgroundView.trailingAnchor.constraint(equalTo: tabbar.trailingAnchor).isActive = true
        backgroundViewTopC = backgroundView.topAnchor.constraint(equalTo: tabbar.topAnchor)
        backgroundViewTopC.isActive = true
        backgroundView.bottomAnchor.constraint(equalTo: tabbar.bottomAnchor).isActive = true
        backgroundViewTopC1 = backgroundView.topAnchor.constraint(equalTo: tabbar.topAnchor)
        backgroundView.backgroundColor = UIColor(white: 0.1, alpha: 0.8)
        
        let topLine = UIView(frame: .zero)
        topLine.tag = 223
        topLine.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        tabbar.addSubview(topLine)
        topLine.translatesAutoresizingMaskIntoConstraints = false
        topLine.leadingAnchor.constraint(equalTo: tabbar.leadingAnchor).isActive = true
        topLine.trailingAnchor.constraint(equalTo: tabbar.trailingAnchor).isActive = true
        topLine.bottomAnchor.constraint(equalTo: tabbar.topAnchor).isActive = true
        topLine.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        
    }
    
    fileprivate func updateTabBarBackgroundView(tabbar: UITabBar, selectedIndex: Int) {
        let backgroundView = tabbar.viewWithTag(222)
        let topLine = tabbar.viewWithTag(223)
        if selectedIndex == 0 {
            backgroundView?.alpha = 0.0
            topLine?.isHidden = false
            backgroundViewTopC.isActive = true
            backgroundViewTopC1.isActive = false
            UIView.animate(withDuration: 0.1) {
                tabbar.layoutIfNeeded()
            }
        }
        else {
            backgroundView?.alpha = 1.0
            topLine?.isHidden = true
            backgroundViewTopC1.isActive = true
            backgroundViewTopC.isActive = false
            UIView.animate(withDuration: 0.1) {
                tabbar.layoutIfNeeded()
            }
        }
    }
}

extension MainAppScrollingContainerViewController {
    fileprivate func presentSelectMusic() {
        let cameraVc = AlpVideoCameraViewController()
        cameraVc.delegate = self
        let nac = AlpVideoCameraNavigationController(rootViewControllerNoWrapping: cameraVc)
        nac?.modalPresentationStyle =  UIModalPresentationStyle.custom
//        nac?.zf_usingCustomModalTransitioningAnimator()
//        nac?.zf_modalAnimator.topViewScale = ZFModalTransitonSizeScale.init(widthScale: 1.0, heightScale: 1.0)
        self.present(nac!, animated: true, completion: nil)
    
    }
    
}


extension MainAppScrollingContainerViewController: LoginViewControllerDelegate {
    func loginViewController(controller: LoginViewController?, loginSuccess user: User) {
        
        controller?.dismiss(animated: true, completion: {
            
        })
    }
    
    func loginViewController(controller: LoginViewController?, loginFailure error: Error) {
        
        
    }
}

extension MainAppScrollingContainerViewController: AlpVideoCameraViewControllerDelegate {
    
    func videoCameraViewController(_ viewController: AlpVideoCameraViewController, publishWithVideoURL url: URL, title: String, content: String, longitude: Double, latitude: Double, poi_name: String, poi_address: String) {
        
        MBProgressHUD.xy_showActivity()
        VideoRequest.shared.releaseVideo(title: title, describe: content, coverStartTime: 2.5, videoPath: url.path, longitude: longitude, latitude: latitude , poi_name: poi_name, poi_address: poi_address,progress: { (p) in
            print("上传进度\(p.completedUnitCount)")
        }, success: {[weak self] (response) in
            guard let video = response as? VideoItem else { return }
            NotificationCenter.default.post(name: NSNotification.Name.PublushVideoSuccess, object: self, userInfo: ["video": video])
            MBProgressHUD.xy_hide()
            MBProgressHUD.xy_show("视频上传完成")
            viewController.rt_navigationController.dismiss(animated: true, completion: nil)
            
        }) { (error) in
            MBProgressHUD.xy_hide()
            MBProgressHUD.xy_show("请重新登录")
        }
    }
    
    func hiddenBackButton(for viewController: AlpVideoCameraViewController) -> Bool {
        if viewController == cameraController {
            return true
        }
        return false
    }
}

extension MainAppScrollingContainerViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        guard completed else {
            return
        }
        
        guard let viewController = pageViewController.viewControllers?.last else {
            return
        }
        
        let index = indexOfViewController(viewController)
        if index == NSNotFound {
            return
        }
        
        currentIndex = index
        
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.3) {
                UIApplication.shared.setNeedsStatusBarAppearanceUpdate()
            }
        }
    }
}

extension MainAppScrollingContainerViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
    
        var index = self.indexOfViewController(viewController)
        
        if (index == 0) || (index == NSNotFound) {
            return nil
        }
        
        index -= 1
        
        return viewControllerAtIndex(index)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        var index = self.indexOfViewController(viewController)
        
        if index == NSNotFound {
            return nil
        }
        
        index += 1
        
        return viewControllerAtIndex(index)
    }
    
    
}
