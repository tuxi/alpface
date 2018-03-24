//
//  LoginViewController.swift
//  Alpface
//
//  Created by swae on 2018/3/24.
//  Copyright © 2018年 alpface. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    fileprivate lazy var logoLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.white
        label.font = UIFont(name: "MedulaOne-Regular", size: 50.0)
        return label
    }()
    
    fileprivate lazy var usernameLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 14.0)
        return label
    }()
    
    fileprivate lazy var passwordLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 14.0)
        return label
    }()
    
    fileprivate lazy var usernameTf : UITextField = {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    fileprivate lazy var passwordTf : UITextField = {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    fileprivate lazy var loginButton : UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.white.withAlphaComponent(0.03)
        button.setTitleColor(UIColor.white.withAlphaComponent(0.55), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16.0, weight: UIFont.Weight(rawValue: 1.0))
        button.layer.cornerRadius = 3.0
        button.layer.masksToBounds = true
        return button
    }()
    
    fileprivate lazy var contentView : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.clear
        return view
    }()
    
    fileprivate lazy var usernameContentView : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.white.withAlphaComponent(0.22)
        view.layer.cornerRadius = 2.0
        view.layer.masksToBounds = true
        return view
    }()
    
    fileprivate lazy var passwordContentView : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.white.withAlphaComponent(0.22)
        view.layer.cornerRadius = 2.0
        view.layer.masksToBounds = true
        return view
    }()
    
    fileprivate lazy var loginProblemButton : UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    fileprivate lazy var pastelView : PastelView = {
        let pastelView = PastelView(frame: view.bounds)
        pastelView.translatesAutoresizingMaskIntoConstraints = false
        //MARK: -  Custom Direction
        pastelView.startPastelPoint = .bottomLeft
        pastelView.endPastelPoint = .topRight
        //MARK: -  Custom Duration
        pastelView.animationDuration = 3.0
        
        //MARK: -  Custom Color
        pastelView.setColors([UIColor(red: 156/255, green: 39/255, blue: 176/255, alpha: 1.0),
                              UIColor(red: 255/255, green: 64/255, blue: 129/255, alpha: 1.0),
                              UIColor(red: 123/255, green: 31/255, blue: 162/255, alpha: 1.0),
                              UIColor(red: 32/255, green: 76/255, blue: 255/255, alpha: 1.0),
                              UIColor(red: 32/255, green: 158/255, blue: 255/255, alpha: 1.0),
                              UIColor(red: 90/255, green: 120/255, blue: 127/255, alpha: 1.0),
                              UIColor(red: 58/255, green: 255/255, blue: 217/255, alpha: 1.0)])
        
        return pastelView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupUI()
    }
    
    fileprivate func setupUI() {
        view.backgroundColor = UIColor.lightGray
        
        view.addSubview(pastelView)
        view.insertSubview(pastelView, at: 0)
        view.addSubview(contentView)
        contentView.addSubview(usernameContentView)
        contentView.addSubview(passwordContentView)
        contentView.addSubview(logoLabel)
        usernameContentView.addSubview(usernameLabel)
        usernameContentView.addSubview(usernameTf)
        passwordContentView.addSubview(passwordLabel)
        passwordContentView.addSubview(passwordTf)
        contentView.addSubview(loginButton)
        contentView.addSubview(loginProblemButton)
        setupConstraints()
        
        logoLabel.text = "Alpface"
        usernameLabel.text = "賬戶"
        passwordLabel.text = "密碼"
        loginButton.setTitle("登錄", for: .normal)
        loginProblemButton.setTitle("登錄遇到問題", for: .normal)
        
        setupNavigationBar()
    }
    
    fileprivate func setupConstraints() {
        contentView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        contentView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        logoLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        
        usernameContentView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30.0).isActive = true
        usernameContentView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -30.0).isActive = true
        
        passwordContentView.leadingAnchor.constraint(equalTo: usernameContentView.leadingAnchor).isActive = true
        passwordContentView.trailingAnchor.constraint(equalTo: usernameContentView.trailingAnchor).isActive = true
        
        
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|[logoLabel]-(35.0)-[usernameContentView(==62.0)]-(15.0)-[passwordContentView(==62.0)]-(15.0)-[loginButton(==50.0)]-(15.0)-[loginProblemButton]|", options: .alignAllCenterX, metrics: nil, views: ["logoLabel": logoLabel, "usernameContentView": usernameContentView, "passwordContentView": passwordContentView, "loginButton": loginButton, "loginProblemButton": loginProblemButton]))
        
        loginButton.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.3).isActive = true
        
        usernameLabel.setContentHuggingPriority(.required, for: .horizontal)
        usernameLabel.leadingAnchor.constraint(equalTo: usernameContentView.leadingAnchor, constant: 20.0).isActive = true
        usernameLabel.centerYAnchor.constraint(equalTo: usernameContentView.centerYAnchor, constant: 0.0).isActive = true
        usernameTf.leadingAnchor.constraint(equalTo: usernameLabel.trailingAnchor, constant: 10.0).isActive = true
        usernameTf.trailingAnchor.constraint(equalTo: usernameContentView.trailingAnchor, constant: -20.0).isActive = true
        usernameTf.topAnchor.constraint(equalTo: usernameContentView.topAnchor).isActive = true
        usernameTf.bottomAnchor.constraint(equalTo: usernameContentView.bottomAnchor).isActive = true
        
        passwordLabel.setContentHuggingPriority(.required, for: .horizontal)
        passwordLabel.leadingAnchor.constraint(equalTo: passwordContentView.leadingAnchor, constant: 20.0).isActive = true
        passwordLabel.centerYAnchor.constraint(equalTo: passwordContentView.centerYAnchor, constant: 0.0).isActive = true
        passwordTf.leadingAnchor.constraint(equalTo: passwordLabel.trailingAnchor, constant: 10.0).isActive = true
        passwordTf.trailingAnchor.constraint(equalTo: usernameContentView.trailingAnchor, constant: -20.0).isActive = true
        passwordTf.topAnchor.constraint(equalTo: passwordContentView.topAnchor).isActive = true
        passwordTf.bottomAnchor.constraint(equalTo: passwordContentView.bottomAnchor).isActive = true
        
        pastelView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        pastelView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        pastelView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        pastelView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    fileprivate func setupNavigationBar() {
        let backButton = UIButton()
        backButton.setTitle("取消", for: .normal)
        // 触摸按钮时发光
        backButton.showsTouchWhenHighlighted = true
        var frame = backButton.frame
        frame.size = CGSize(width: 44.0, height: 44.0)
        backButton.frame = frame
        backButton.addTarget(self, action: #selector(backBarButtonClick(_:)), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: backButton)
        
        // 设置导航栏标题属性：设置标题颜色
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        // 设置导航栏前景色：设置item指示色
        navigationController?.navigationBar.tintColor = UIColor.white
        
        // 设置导航栏半透明
        navigationController?.navigationBar.isTranslucent = true
        
        // 设置导航栏背景图片
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        
        // 设置导航栏阴影图片
        navigationController?.navigationBar.shadowImage = UIImage()
    
    }
    
    @objc private func backBarButtonClick(_ button: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        pastelView.startAnimation()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

}
