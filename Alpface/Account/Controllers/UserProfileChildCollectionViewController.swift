//
//  UserProfileChildCollectionViewController.swift
//  UserProfileExample
//
//  Created by swae on 2018/4/5.
//  Copyright © 2018年 alpface. All rights reserved.
//

import UIKit

@objc(ALPChildTableViewController)
class UserProfileChildCollectionViewController: BaseProfileViewChildControllr {
    
    /// 弹窗转场
    fileprivate lazy var presentScaleAnimation: MyHomePresentScaleAnimation = {
        return MyHomePresentScaleAnimation()
    }()
    /// 消失转场
    fileprivate lazy var dismissScaleAnimation: MyHomeDismissScaleAnimation = {
        return MyHomeDismissScaleAnimation()
    }()
    fileprivate lazy var leftDragInteractiveTransition: MyHomeDragLeftInteractiveTransition = {
        return MyHomeDragLeftInteractiveTransition()
    }()

    
    public var segmentModel: UserHomeSegmentModel? {
        didSet {
            self.collectionView.reloadData()
        }
    }
    public lazy var collectionView: UICollectionView = {
        let layout = ETCollectionViewWaterfallLayout()
        let padding: CGFloat = 3.0
        layout.minimumColumnSpacing = padding
        layout.minimumInteritemSpacing = padding
        layout.sectionInset = UIEdgeInsets(top: 0.0, left: padding, bottom: padding, right: padding)
        layout.columnCount = 3
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.collectionViewLayout = layout
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(VideoGifCollectionViewCell.classForCoder(), forCellWithReuseIdentifier: "VideoGifCollectionViewCell")
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 55, right: 0)
        return collectionView
    }()
    
    
    override func childScrollView() -> UIScrollView? {
        return self.collectionView
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupEmptyDataView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.collectionView.reloadData()
    }
    
    fileprivate func setupUI() {
        self.collectionView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.collectionView)
        self.collectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.collectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        self.collectionView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.collectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func setupEmptyDataView() {
        collectionView.xy_textLabelBlock = { [weak self] label in
            label.font = UIFont.systemFont(ofSize: 13.0)
            label.text = self?.titleForEmptyDataView()
        }
        
        collectionView.xy_detailTextLabelBlock = { [weak self] label in
            label.text = self?.detailTitleForEmptyDataView()
        }
        
//        collectionView.xy_reloadButtonBlock = { button in
//            button.setTitle("刷新吧", for: .normal)
//            button.backgroundColor = UIColor.blue.withAlphaComponent(0.7)
//            button.layer.cornerRadius = 5.0
//            button.layer.masksToBounds = true
//        }
        
        collectionView.emptyDataDelegate = self
        collectionView.reloadData()
    }
    
    public func titleForEmptyDataView() -> String? {
        return nil
    }
    
    public func detailTitleForEmptyDataView() -> String? {
        return nil
    }
 
}

extension UserProfileChildCollectionViewController: UICollectionViewDataSource, UICollectionViewDelegate, ETCollectionViewDelegateWaterfallLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let model = self.segmentModel else { return 0 }
        guard let data = model.data else { return 0 }
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoGifCollectionViewCell", for: indexPath) as! VideoGifCollectionViewCell
        guard let model = self.segmentModel else { return cell }
        guard let data = model.data else { return cell }
        let video = data[indexPath.row]
        guard let webpURL = video.getVideoAnimatedWebpURL() else {
            return cell
        }

        cell.gifView.sd_setImage(with: webpURL) { (image, error, cacheType, url) in
            
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = VideoDetailListViewController()
        vc.transitioningDelegate = self
        
        guard let cell = collectionView.cellForItem(at: indexPath) else { return }
        let cellFrame = cell.frame
        let cellConvertedFrame = collectionView.convert(cellFrame, to: collectionView.superview)
        // 弹窗转场
        self.presentScaleAnimation.cellConvertFrame = cellConvertedFrame
        
        self.dismissScaleAnimation.selectCell = cell
        self.dismissScaleAnimation.originCellFrame = cellFrame
        self.dismissScaleAnimation.finalCellFrame = cellConvertedFrame
        
        
        //消失转场
        self.dismissScaleAnimation.selectCell = cell; // 5
        self.dismissScaleAnimation.originCellFrame  = cellFrame; //6
        self.dismissScaleAnimation.finalCellFrame = cellConvertedFrame; //7
        
        self.segmentModel?.data?.forEach({ (video) in
            vc.videoItems.append(PlayVideoModel(videoItem: video))
        })

        vc.initialPage = indexPath.row
        
        vc.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        self.modalPresentationStyle = UIModalPresentationStyle.currentContext
        
        self.leftDragInteractiveTransition.prepare(to: vc)
        self.present(vc, animated: true, completion: nil)
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 130)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let c = cell as? VideoGifCollectionViewCell else { return }
        c.gifView.startAnimating()
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let c = cell as? VideoGifCollectionViewCell else { return }
        c.gifView.stopAnimating()
    }
    
}

extension UserProfileChildCollectionViewController: XYEmptyDataDelegate {
    
    func emptyDataView(_ scrollView: UIScrollView, didClickReload button: UIButton) {
        
    }
    
    func emptyDataView(contentOffsetforEmptyDataView scrollView: UIScrollView) -> CGPoint {
        return CGPoint(x: 0, y: -180)
    }
    
    
    func emptyDataView(contentSubviewsGlobalVerticalSpaceForEmptyDataView scrollView: UIScrollView) -> CGFloat {
        return 20.0
    }
    
    func customView(forEmptyDataView scrollView: UIScrollView) -> UIView? {
        if scrollView.xy_loading == true {
            let indicatorView = UIActivityIndicatorView(style: .white)
            indicatorView.startAnimating()
            return indicatorView
        }
        return nil
    }
}

extension UserProfileChildCollectionViewController: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
         return self.presentScaleAnimation
    }
 
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self.dismissScaleAnimation
    }
    
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        if self.leftDragInteractiveTransition.isInteracting {
            return self.leftDragInteractiveTransition
        }
        return nil
    }
}
