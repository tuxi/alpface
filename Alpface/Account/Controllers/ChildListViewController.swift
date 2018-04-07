//
//  ChildListViewController.swift
//  UserProfileExample
//
//  Created by swae on 2018/4/5.
//  Copyright © 2018年 alpface. All rights reserved.
//

import UIKit

@objc(ALPChildTableViewController)
class ChildListViewController: UIViewController, ProfileViewChildControllerProtocol {
    
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
        collectionView.register(VideoGifCollectionViewCell.classForCoder(), forCellWithReuseIdentifier: "cell")
        return collectionView
    }()
    
    public var collectionItems: [VideoItem]? {
        didSet {
            if oldValue != collectionItems {
                self.collectionView.reloadData()
            }
        }
    }
    
    func childScrollView() -> UIScrollView? {
        return self.collectionView
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    
    fileprivate func setupUI() {
        self.collectionView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.collectionView)
        self.collectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.collectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        self.collectionView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.collectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        
//        self.collectionView.visibleCells.forEach { (cell) in
//            guard let c = cell as? VideoGifCollectionViewCell else { return }
//            if c.gifView.isAnimatingGIF == false {
//                c.gifView.startAnimatingGIF()
//            }
//        }
//    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.collectionView.visibleCells.forEach { (cell) in
            guard let c = cell as? VideoGifCollectionViewCell else { return }
//            if c.gifView.isAnimatingGIF == false {
//                c.gifView.startAnimatingGIF()
//            }
        }
    }
    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        self.collectionView.visibleCells.forEach { (cell) in
//            guard let c = cell as? VideoGifCollectionViewCell else { return }
//            if c.gifView.isAnimatingGIF == true {
//                c.gifView.prepareForReuse()
//                c.gifView.stopAnimatingGIF()
//            }
//        }
//    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.collectionView.visibleCells.forEach { (cell) in
            guard let c = cell as? VideoGifCollectionViewCell else { return }
//            if c.gifView.isAnimatingGIF == true {
//                c.gifView.prepareForReuse()
//                c.gifView.stopAnimatingGIF()
//            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
 
}

extension ChildListViewController: UICollectionViewDataSource, UICollectionViewDelegate, ETCollectionViewDelegateWaterfallLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let items = self.collectionItems else { return 0 }
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! VideoGifCollectionViewCell
        cell.contentView.backgroundColor = UIColor.randomColor()
        guard let items = self.collectionItems else { return cell }
        let video = items[indexPath.row]
        guard let gifURL = video.getVideoGifURL() else {
            return cell
        }
        cell.gifView.animate(withGIFURL: gifURL, loopCount: 10) {
            
        }
        return cell
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

