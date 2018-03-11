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
        return collectionView
    }()
    
    private lazy var collectionViewItems: [CollectionViewSection] = [CollectionViewSection]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupUI()
        setupCollectionViewItems()
    }
    
    private func setupUI() {
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
                item.model = createVc
                break
            case 1:
                // 主页
                let tabBarVc = MainTabBarController()
                let homeVc = HomeViewController()
                homeVc.title = "home"
                let searchVc = SearchViewController()
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
                break
            case 2:
                let vc = UIViewController()
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
        let c1: CGFloat = CGFloat(arc4random_uniform(256))/255.0
        let c2: CGFloat = CGFloat(arc4random_uniform(256))/255.0
        let c3: CGFloat = CGFloat(arc4random_uniform(256))/255.0
        
        let sec = collectionViewItems[indexPath.section]
        cell.model = sec.items[indexPath.row] as? MainAppScrollingContainerItem
        
        cell.backgroundColor = UIColor.init(red: c1, green: c2, blue: c3, alpha: 1.0)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return collectionViewItems[indexPath.section].items[indexPath.row].size
    }
}
