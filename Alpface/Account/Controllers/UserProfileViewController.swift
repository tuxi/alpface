//
//  UserProfileViewController.swift
//  Alpface
//
//  Created by swae on 2018/3/11.
//  Copyright © 2018年 alpface. All rights reserved.
//

import UIKit

let ALPSegmentHeight: CGFloat = 44.0
let ALPNavigationBarHeight: CGFloat = 44.0
let ALPStatusBarHeight: CGFloat = UIApplication.shared.statusBarFrame.height

@objc(ALPProfileViewController)
class UserProfileViewController: ProfileViewController {
    
    fileprivate lazy var videosTableView: UITableView = {
        let tableView = UITableView(frame: CGRect.zero, style: .plain)
        return tableView
    }()
    fileprivate lazy var favoritesTableView: UITableView = {
        let tableView = UITableView(frame: CGRect.zero, style: .plain)
        return tableView
    }()
    fileprivate lazy var storysTableView: UITableView = {
        let tableView = UITableView(frame: CGRect.zero, style: .plain)
        return tableView
    }()
    
    var custom: UIView!
    var label: UILabel!

    override func numberOfSegments() -> Int {
        return 3
    }
    
    override func segmentTitle(forSegment index: Int) -> String {
        return "Segment \(index)"
    }
    
    override func prepareForLayout() {
        
        self.automaticallyAdjustsScrollViewInsets = false
        if #available(iOS 11.0, *) {
            videosTableView.contentInsetAdjustmentBehavior = .never
            favoritesTableView.contentInsetAdjustmentBehavior = .never
            storysTableView.contentInsetAdjustmentBehavior = .never
        } else {
            // Fallback on earlier versions
        }
        
        videosTableView.delegate = self
        videosTableView.dataSource = self
        videosTableView.register(UITableViewCell.self, forCellReuseIdentifier: "tweetCell")
        
        favoritesTableView.delegate = self
        favoritesTableView.dataSource = self
        favoritesTableView.register(UITableViewCell.self, forCellReuseIdentifier: "photoCell")
        
        storysTableView.delegate = self
        storysTableView.dataSource = self
        storysTableView.register(UITableViewCell.self, forCellReuseIdentifier: "favCell")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.locationString = "Beijing"
        self.username = AuthenticationManager.shared.loginUser?.username
        if let userid = AuthenticationManager.shared.loginUser?.userid {
            self.nickname = "用户号" + ":\(userid)"
        }
        
        self.profileImage = UIImage.init(named: "icon.png")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func scrollView(forSegment index: Int) -> UIScrollView {
        switch index {
        case 0:
            return videosTableView
        case 1:
            return favoritesTableView
        case 2:
            return storysTableView
        default:
            return videosTableView
        }
    }
}



// MARK: UITableViewDelegates & DataSources
extension UserProfileViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView {
        case videosTableView:
            return 30
        case favoritesTableView:
            return 10
        case storysTableView:
            return 0
        default:
            return 10
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch tableView {
        case videosTableView:
            let cell = tableView.dequeueReusableCell(withIdentifier: "tweetCell", for: indexPath)
            cell.textLabel?.text = "Row \(indexPath.row)"
            return cell
            
        case favoritesTableView:
            let cell = tableView.dequeueReusableCell(withIdentifier: "photoCell", for: indexPath)
            cell.textLabel?.text = "Photo \(indexPath.row)"
            return cell
            
        case storysTableView:
            let cell = tableView.dequeueReusableCell(withIdentifier: "favCell", for: indexPath)
            cell.textLabel?.text = "Fav \(indexPath.row)"
            return cell
            
        default:
            return UITableViewCell()
        }
    }

}

