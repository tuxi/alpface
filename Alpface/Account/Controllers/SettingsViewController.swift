//
//  SettingsViewController.swift
//  Alpface
//
//  Created by swae on 2018/4/15.
//  Copyright © 2018年 alpface. All rights reserved.
//

import UIKit

@objc(ALPSettingsViewController)
class SettingsViewController: UIViewController {
    
    fileprivate lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.clear
        tableView.register(SettingsTableViewCell.classForCoder(), forCellReuseIdentifier: "SettingsTableViewCell")
        tableView.separatorStyle = .none
        return tableView
    }()
    
    fileprivate lazy var logoutButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("退出登录", for: .normal)
        button.backgroundColor = AppTheme.globalTint
        button.setTitleColor(UIColor.white, for: .normal)
        button.setTitleColor(UIColor.lightGray, for: .highlighted)
        button.addTarget(self, action: #selector(logout), for: .touchUpInside)
        return button
    }()
    
    fileprivate var settings: [SettingsTableViewCellModel] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.prepareSettings()
        self.prepareViews()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        UIApplication.shared.setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension SettingsViewController {
    fileprivate func prepareViews() {
        self.view.backgroundColor = UIColor.white
        self.hidesBottomBarWhenPushed = true
        self.view.addSubview(self.tableView)
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        self.tableView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        
        let footerView = UIView()
        footerView.addSubview(self.logoutButton)
        self.logoutButton.translatesAutoresizingMaskIntoConstraints = false
        self.logoutButton.centerXAnchor.constraint(equalTo: footerView.centerXAnchor).isActive = true
        self.logoutButton.centerYAnchor.constraint(equalTo: footerView.centerYAnchor).isActive = true
        self.logoutButton.heightAnchor.constraint(equalTo: footerView.heightAnchor, constant: -10.0).isActive = true
        self.logoutButton.leadingAnchor.constraint(equalTo: footerView.leadingAnchor, constant: 10.0).isActive = true
        footerView.frame = CGRect(x: 0, y: 0, width: 0, height: 45.0)
        self.logoutButton.layer.cornerRadius = (45.0 - 10.0) * 0.5
        self.logoutButton.layer.masksToBounds = true
        self.tableView.tableFooterView = footerView
    }
    
    fileprivate func prepareSettings() {
        let item1 = SettingsTableViewCellModel(name: "编辑个人资料") { (model) in
            if let user = AuthenticationManager.shared.loginUser {
                let editVc = EditUserProfileViewController(user: user)
                let nac = UINavigationController(rootViewController: editVc)
                self.showDetailViewController(nac, sender: self)
            }
            
        }
        self.settings.append(item1)
        
        let item2 = SettingsTableViewCellModel(name: "上传视频") { (model) in
            if AuthenticationManager.shared.isLogin == true {
                let publishVc = PublishViewController()
                let nac = UINavigationController(rootViewController: publishVc)
                self.showDetailViewController(nac, sender: self)
            }
        }
        self.settings.append(item2)
    }
}

extension SettingsViewController {
    @objc fileprivate func logout() {
        AuthenticationManager.shared.logout()
        let rootVc = (self.navigationController?.viewControllers.first)!
        self.navigationController?.viewControllers = [rootVc]
        let delegate = UIApplication.shared.delegate as? AppDelegate
        delegate?.rootViewController?.showHomePage()
    }
}

extension SettingsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.settings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsTableViewCell", for: indexPath) as! SettingsTableViewCell
        cell.item = self.settings[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45.0
    }
}

extension SettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = self.settings[indexPath.row]
        if let clickArrowCallBack = item.clickArrowCallBack {
            clickArrowCallBack(item)
        }
        
    }
}

extension SettingsViewController {
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}
