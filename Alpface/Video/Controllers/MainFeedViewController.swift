//
//  HomeViewController.swift
//  Alpface
//
//  Created by swae on 2018/3/11.
//  Copyright © 2018年 alpface. All rights reserved.
//

import UIKit

class MainFeedViewController: UIViewController {
    
    fileprivate lazy var refreshControl: UIRefreshControl = {
        let refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(afterRefresher), for: .valueChanged)
        return refresher
    }()
    
    fileprivate lazy var videoItems: [VideoItem] = {
        let items = [VideoItem]()
        return items
    }()
    
    fileprivate lazy var collectionView: GestureCoordinatingCollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0.0
        layout.minimumInteritemSpacing = 0.0
        layout.scrollDirection = .vertical
        let collectionView = GestureCoordinatingCollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isPagingEnabled = true
        collectionView.bounces = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(MainFeedViewCell.classForCoder(), forCellWithReuseIdentifier: "MainFeedViewCell")
        collectionView.backgroundColor = UIColor.white
        return collectionView
    }()
    
    public func displayViewController() -> UIViewController? {
        if let cell = collectionView.visibleCells.first as? MainFeedViewCell {
            return cell.viewController
        }
        return nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupUI()
        requestRandomVideos()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        displayViewController()?.beginAppearanceTransition(true, animated: animated)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        displayViewController()?.endAppearanceTransition()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        displayViewController()?.beginAppearanceTransition(false, animated: true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
       super.viewDidDisappear(animated)
        displayViewController()?.endAppearanceTransition()
    }
    
    fileprivate func setupUI() {
        automaticallyAdjustsScrollViewInsets = false
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        }
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|[collectionView]|", options: [], metrics: nil, views: ["collectionView": collectionView]))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[collectionView]|", options: [], metrics: nil, views: ["collectionView": collectionView]))
        
        collectionView.refreshControl = refreshControl
        
        // 设置导航栏标题属性：设置标题字体
        let font = UIFont(name: "MedulaOne-Regular", size: 30.0)
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.font: font ?? UIFont.systemFont(ofSize: 30.0), NSAttributedStringKey.foregroundColor: UIColor.white]
        
        // 设置导航栏前景色：设置item指示色
        navigationController?.navigationBar.tintColor = UIColor.white
        
        // 设置导航栏半透明
        navigationController?.navigationBar.isTranslucent = true
        
        // 设置导航栏背景图片
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        
        // 设置导航栏阴影图片
        navigationController?.navigationBar.shadowImage = UIImage()
    
    }
    
    @objc fileprivate func afterRefresher(){
        
        loadPosts()
    }
    
    fileprivate func loadPosts(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.refreshControl.endRefreshing()
        }
    }
    
}

extension MainFeedViewController {
    
    fileprivate func requestRandomVideos() -> Void {
        VideoRequest.shared.getRadomVideos(success: {[weak self] (response) in
            guard let list = response as? [VideoItem] else {
                #if DEBUG
                    self?.videoItems.removeAll()
                    let videoItem = VideoItem()
                    self?.videoItems.append(videoItem)
                    self?.collectionView.reloadData()
                #endif
                return
            }
            self?.videoItems.removeAll()
            self?.videoItems += list
            self?.collectionView.reloadData()
        }) { (error) in
            print(error?.localizedDescription ?? "请求随机视频失败!")
        }
    }
}

extension MainFeedViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var childViewControllerForStatusBarStyle: UIViewController? {
        return nil
    }
}

extension MainFeedViewController : UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return videoItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MainFeedViewCell", for: indexPath) as! MainFeedViewCell
        let c1: CGFloat = CGFloat(arc4random_uniform(256))/255.0
        let c2: CGFloat = CGFloat(arc4random_uniform(256))/255.0
        let c3: CGFloat = CGFloat(arc4random_uniform(256))/255.0
        
        let video = videoItems[indexPath.row]
//        let url = URL.init(string: "http://10.211.55.3:8888/media/media_itemstest_6yHn4hk.mov")
//        cell.url = url
        cell.videoItem = video
        cell.backgroundColor = UIColor.init(red: c1, green: c2, blue: c3, alpha: 1.0)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return collectionView.frame.size
    }
    
    /// cell 完全离开屏幕后调用
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let didEndDisplayingCell = cell as? MainFeedViewCell else {
            return
        }
        /// 获取已离开屏幕的cell上控制器，执行其view消失的生命周期方法
        didEndDisplayingCell.viewController.beginAppearanceTransition(false, animated: true)
        didEndDisplayingCell.viewController.endAppearanceTransition()
    }
    
    /// cell 即将显示在屏幕时调用
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let didEndDisplayingCell = cell as? MainFeedViewCell else {
            return
        }
        didEndDisplayingCell.viewController.beginAppearanceTransition(true, animated: true)
        didEndDisplayingCell.viewController.endAppearanceTransition()
    }
    
}

extension MainFeedViewController {
    
    /// 关闭appearance callbacks的自动传递的特性呢
    override var shouldAutomaticallyForwardAppearanceMethods: Bool {
        return false
    }
    
    
}
