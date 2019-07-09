//
//  HomeViewController.swift
//  Alpface
//
//  Created by swae on 2018/3/11.
//  Copyright © 2018年 alpface. All rights reserved.
//

import UIKit



@objc(ALPMainFeedViewController)
class MainFeedViewController: HomeRefreshViewController {
    
    public var initialPage = 0
    
    public lazy var videoItems: [PlayVideoModel] = {
        let items = [PlayVideoModel]()
        return items
    }()
    
    public var isVisibleInDisplay: Bool = false
    fileprivate var willPlayIndex: Int = 0
    fileprivate var currentPlayIndex: Int?
    
    public lazy var tableView: GestureCoordinatingTableView = {
        let tableView = GestureCoordinatingTableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.isPagingEnabled = true
        tableView.bounces = false
        tableView.separatorStyle = .none
        tableView.showsHorizontalScrollIndicator = false
        tableView.showsVerticalScrollIndicator = false
        tableView.register(MainFeedViewCell.classForCoder(), forCellReuseIdentifier: "MainFeedViewCell")
        tableView.backgroundColor = UIColor.clear
        return tableView
    }()
    
    public func displayViewController() -> UIViewController? {
        if let cell = tableView.visibleCells.first as? MainFeedViewCell {
            return cell.viewController.playVideoVc
        }
        return nil
    }
    
    public func displayVideoItem() -> VideoItem? {
        if let cell = tableView.visibleCells.first as? MainFeedViewCell {
            guard let model = cell.model else {
                return nil
            }
            guard let video = model.model as? VideoItem else {
                return nil
            }
            return video
        }
        return nil
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        addObservers()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.isVisibleInDisplay = true
        
        show(page: initialPage, animated: false)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.play()
        DispatchQueue.main.async {
            UIApplication.shared.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.isVisibleInDisplay = false
        self.stop()
    }
    
    fileprivate func addObservers() -> Void {
        NotificationCenter.default.addObserver(self, selector: #selector(resetPlayer), name: NSNotification.Name.ALPPlayerStopAll, object: nil)
    }
    
    public func show(page index: Int, animated: Bool) {
        if self.videoItems.count == 0 {
            return
        }
        if tableView.indexPathsForVisibleRows?.first?.row == index {
            return
        }
        tableView.scrollToRow(at: IndexPath.init(row: index, section: 0), at: UITableView.ScrollPosition.none, animated: animated)
    }
    
    // 未显示的资源停止播放，已显示的资源开始播放
    public func play() {
        guard let visibleIndexPath = tableView.indexPathsForVisibleRows?.first else {
            return
        }
        if visibleIndexPath.row >= videoItems.count {
            return
        }
        if self.currentPlayIndex == visibleIndexPath.row {
            return
        }
        // 取出当前显示的model，执行播放
        let model = videoItems[visibleIndexPath.row]
        
        if isVisibleInDisplay == false {
            model.stop()
            return
        }
        DispatchQueue.main.async {        
            model.play()
            self.currentPlayIndex = visibleIndexPath.row
        }
    }
    
    // 停止所有在显示的cell的播放
    fileprivate func stop() {
        
        guard let indexPathsForVisibleRows = tableView.indexPathsForVisibleRows else {
            return
        }
        if let currentIndex = self.currentPlayIndex {
            let currentModel = videoItems[currentIndex]
            currentModel.stop()
        }
        
        indexPathsForVisibleRows.forEach { (indexPath) in
            if indexPath.row >= videoItems.count {
                return
            }
            
            // 取出当前显示的model,停止播放
            let model = videoItems[indexPath.row]
            model.stop()
        }
    }
    
    fileprivate func setupUI() {
        view.backgroundColor = UIColor.clear
        automaticallyAdjustsScrollViewInsets = false
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        }
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        // iPhone x 系列 底部内容显示在安全区域以上
        // 其他系列 底部内容显示在屏幕底部以上，tabBar透明显示，可以看到全屏内容
        if #available(iOS 11.0, *), AppUtils.isIPhoneX() {
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        } else {
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        }
        
        
        setupNavigation()
        
    }
    
    fileprivate func setupNavigation() {
        // 设置导航栏标题属性：设置标题字体
        let font = UIFont(name: "MedulaOne-Regular", size: 20.0)
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: font ?? UIFont.systemFont(ofSize: 20.0), NSAttributedString.Key.foregroundColor: UIColor.white]
        
        // 设置导航栏前景色：设置item指示色
        navigationController?.navigationBar.tintColor = UIColor.white
        
        // 设置导航栏半透明
        navigationController?.navigationBar.isTranslucent = true
        
        // 设置导航栏背景图片
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        
        // 设置导航栏阴影图片
        navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    
    // 预加载更多列表
    fileprivate func prefetchFeedListIfNeeded(cell: MainFeedViewCell) {
        cell.viewController.prepareToPlay(model: cell.model)
    }
}



extension MainFeedViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var childForStatusBarStyle: UIViewController? {
        return nil
    }
}

extension MainFeedViewController : UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videoItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MainFeedViewCell", for: indexPath) as! MainFeedViewCell
        
        let model = videoItems[indexPath.row]
        cell.model = model
        cell.viewController.interactionController.delegate = self
        cell.model?.indexPath = indexPath
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.size.height
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        self.willPlayIndex = indexPath.row
        self.prefetchFeedListIfNeeded(cell: cell as! MainFeedViewCell)
    }
    
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {

        if (initialPage > 0) {
            self.show(page: self.initialPage, animated: false)
            initialPage = 0
        }
        
        let c = cell as! MainFeedViewCell
        c.model?.stop()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //        let offset = scrollView.contentOffset.y
        //        if offset < -100 {
        //            tableView.refreshControl?.tintColor = UIColor.white
        //            tableView.refreshControl?.attributedTitle = NSAttributedString(string: "现在可以松手了", attributes: [.foregroundColor : UIColor.orange])
        //            tableView.refreshControl?.backgroundColor = UIColor.darkGray
        //        } else {
        //            tableView.refreshControl?.tintColor = UIColor.white
        //            tableView.refreshControl?.attributedTitle = NSAttributedString(string: "下拉刷新...", attributes: [.foregroundColor : UIColor.orange])
        //            tableView.refreshControl?.backgroundColor = UIColor.darkGray
        //        }
    }
    
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        _onScrollDidEnd()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate == false {
            _onScrollDidEnd()
        }
    }
    
    // 滚动完毕就会调用（如果不是人为拖拽scrollView导致滚动完毕，比如设置setContentOffset时改变会调用)
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        _onScrollDidEnd()
    }
    
    fileprivate func _onScrollDidEnd() -> Void {
        
        self.play()
    }
    
}

extension MainFeedViewController: PlayInteractionViewControllerDelegate {
    func playInteractionViewController(playInteraction controller: PlayInteractionViewController, didClickUserAvatarFrom video: VideoItem) {
        
    }
}

extension MainFeedViewController {
    
    // 关闭appearance callbacks的自动传递的特性呢
    //    override var shouldAutomaticallyForwardAppearanceMethods: Bool {
    //        return false
    //    }
    fileprivate func cellHeightForScreenHeight(screenHeight: CGFloat) -> CGFloat {
        return screenHeight
    }
    
    fileprivate func cellHeight() -> CGFloat {
        return cellHeightForScreenHeight(screenHeight: UIScreen.main.bounds.size.height)
    }
}
extension MainFeedViewController {
    @objc fileprivate func resetPlayer() {
        self.stop()
    }
    
}
