//
//  HomeViewController.swift
//  Alpface
//
//  Created by swae on 2018/3/11.
//  Copyright © 2018年 alpface. All rights reserved.
//

import UIKit

@objc(ALPMainFeedViewController)
class MainFeedViewController: UIViewController {
    
    fileprivate lazy var refreshControl: UIRefreshControl = {
        let refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(afterRefresher), for: .valueChanged)
        return refresher
    }()
    
    public lazy var videoItems: [PlayVideoModel] = {
        let items = [PlayVideoModel]()
        return items
    }()
    
    public var isVisibleInDisplay: Bool = false
    
    public lazy var collectionView: GestureCoordinatingCollectionView = {
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
        collectionView.backgroundColor = UIColor.clear
        return collectionView
    }()
    
    public func displayViewController() -> UIViewController? {
        if let cell = collectionView.visibleCells.first as? MainFeedViewCell {
            return cell.viewController
        }
        return nil
    }
    
    public func displayVideoItem() -> VideoItem? {
        if let cell = collectionView.visibleCells.first as? MainFeedViewCell {
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        displayViewController()?.beginAppearanceTransition(true, animated: animated)
        if let vidbleIndexPath = collectionView.indexPathsForVisibleItems.first {
             playControl(indexPath: vidbleIndexPath)
        }
        else {
            playControl(indexPath: IndexPath.init(row: 0, section: 0))
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        displayViewController()?.endAppearanceTransition()
        if let vidbleIndexPath = collectionView.indexPathsForVisibleItems.first {
            playControl(indexPath: vidbleIndexPath)
        }
        else {
            playControl(indexPath: IndexPath.init(row: 0, section: 0))
        }
        DispatchQueue.main.async {
            UIApplication.shared.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        displayViewController()?.beginAppearanceTransition(false, animated: true)
        // 所有model停止播放
        for videoItem in videoItems {
            videoItem.isAllowPlay = false
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
       super.viewDidDisappear(animated)
        displayViewController()?.endAppearanceTransition()
        // 所有model停止播放
        for videoItem in videoItems {
            videoItem.isAllowPlay = false
        }
    }
    
    fileprivate func playControl(indexPath: IndexPath) {
        if indexPath.row >= videoItems.count {
            return
        }
        // 取出当前显示的model,继续播放
        let model = videoItems[indexPath.row]
        // 所有model停止播放
        for videoItem in videoItems {
            if model != videoItem {
                videoItem.isAllowPlay = false
            }
        }
        
        if isVisibleInDisplay == false {
            model.isAllowPlay = false
            return
        }
        
        model.isAllowPlay = true
    }
    
    fileprivate func setupUI() {
        view.backgroundColor = UIColor.clear
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
        let font = UIFont(name: "MedulaOne-Regular", size: 20.0)
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.font: font ?? UIFont.systemFont(ofSize: 20.0), NSAttributedStringKey.foregroundColor: UIColor.white]
        
        // 设置导航栏前景色：设置item指示色
        navigationController?.navigationBar.tintColor = UIColor.white
        
        // 设置导航栏半透明
        navigationController?.navigationBar.isTranslucent = true
        
        // 设置导航栏背景图片
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        
        // 设置导航栏阴影图片
        navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationItem.title = "推荐"
    
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
    override var preferredStatusBarStyle: UIStatusBarStyle {
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
        
        let model = videoItems[indexPath.row]
        cell.model = model
        cell.contentView.backgroundColor = UIColor.init(red: c1, green: c2, blue: c3, alpha: 1.0)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return collectionView.frame.size
    }
    
    /// cell 完全离开屏幕后调用
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
       
        
        // 暂停播放
        let model = videoItems[indexPath.row]
        model.isAllowPlay = false
    }
    
    /// cell 即将显示在屏幕时调用
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
       
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView != collectionView {
            return
        }
        self.collectionView(didEndScroll: scrollView as! UICollectionView)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate == false {
            if scrollView != collectionView {
                return
            }
            self.collectionView(didEndScroll: scrollView as! UICollectionView)
        }
    }
    
    public func collectionView(didEndScroll collectionView: UICollectionView) {
        
        let row = Int(ceil(collectionView.contentOffset.y / collectionView.frame.height))
        let indexPath = IndexPath(item: row, section: 0)
        let cell = self.collectionView.cellForItem(at: indexPath) as? MainFeedViewCell
        self.collectionView(self.collectionView, didDisplay: cell, forItemAt: indexPath)
    }
    
    /// collectionView cell 完全显示后回调
    fileprivate func collectionView(_ collectionView: UICollectionView, didDisplay cell: MainFeedViewCell?, forItemAt indexPath: IndexPath) {
        guard let vidbleIndexPath = collectionView.indexPathsForVisibleItems.first else { return }
        playControl(indexPath: vidbleIndexPath)
    }
}

extension MainFeedViewController {
    
    /// 关闭appearance callbacks的自动传递的特性呢
//    override var shouldAutomaticallyForwardAppearanceMethods: Bool {
//        return false
//    }
    
}
