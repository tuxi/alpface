//
//  RegisterViewController.swift
//  Alpface
//
//  Created by swae on 2018/4/7.
//  Copyright © 2018年 alpface. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController {
    
    convenience init(completion: @escaping (_ username: String?, _ password: String?, _ error: Error?) -> (Void)) {
        self.init()
        self.registerCompletion = completion
    }
    
    fileprivate var registerCompletion : ((_ username: String?, _ password: String?, _ error: Error?) -> (Void))?
    
    fileprivate lazy var pastelView : PastelView = {
        let pastelView = PastelView(frame: view.bounds)
        pastelView.translatesAutoresizingMaskIntoConstraints = false
        //MARK: -  Custom Direction
        pastelView.startPastelPoint = .bottomLeft
        pastelView.endPastelPoint = .topRight
        //MARK: -  Custom Duration
        pastelView.animationDuration = 3.0
        
        //MARK: -  Custom Color
        pastelView.setColors([UIColor(red: 156/255, green: 39/255, blue: 176/255, alpha: 0.95),
                              UIColor(red: 255/255, green: 64/255, blue: 129/255, alpha: 0.95),
                              UIColor(red: 123/255, green: 31/255, blue: 162/255, alpha: 0.95),
                              UIColor(red: 32/255, green: 76/255, blue: 255/255, alpha: 0.95),
                              UIColor(red: 32/255, green: 158/255, blue: 255/255, alpha: 0.95),
                              UIColor(red: 90/255, green: 120/255, blue: 127/255, alpha: 0.95),
                              UIColor(red: 58/255, green: 255/255, blue: 217/255, alpha: 0.95)])
        return pastelView
    }()
    
    fileprivate lazy var chooseAvatarButton : RoundButton = {
        let btn = RoundButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(chooseAvatarButtonAction),for: .touchUpInside)
        btn.backgroundColor = BaseProfileViewController.globalTint.withAlphaComponent(0.8)
        return btn
    }()
    
    fileprivate lazy var usernameTf : UITextField = {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.addTarget(self, action: #selector(textFieldsEditingChanged),for: .editingChanged)
        return tf
    }()
    
    fileprivate lazy var passwordTf : UITextField = {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.isSecureTextEntry = true
        tf.addTarget(self, action: #selector(textFieldsEditingChanged),for: .editingChanged)
        return tf
    }()
    
    fileprivate lazy var confirm_passwordTf : UITextField = {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.isSecureTextEntry = true
        tf.addTarget(self, action: #selector(textFieldsEditingChanged),for: .editingChanged)
        return tf
    }()
    
    fileprivate lazy var emailTf : UITextField = {
        let tf = UITextField()
        tf.keyboardType = .emailAddress
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.addTarget(self, action: #selector(textFieldsEditingChanged),for: .editingChanged)
        return tf
    }()
    
    fileprivate lazy var phoneTf : UITextField = {
        let tf = UITextField()
        tf.keyboardType = .namePhonePad
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.addTarget(self, action: #selector(textFieldsEditingChanged),for: .editingChanged)
        return tf
    }()
    
    fileprivate lazy var contentView : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.clear
        return view
    }()
    
    fileprivate lazy var registerButton : TransitionButton = {
        let button = TransitionButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.white.withAlphaComponent(0.03)
        button.setTitleColor(UIColor.white.withAlphaComponent(0.55), for: .normal)
        button.setTitleColor(UIColor.white, for: .highlighted)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16.0, weight: UIFont.Weight(rawValue: 1.0))
        button.spinnerColor = UIColor.white
        button.cornerRadius = 25.0
        button.layer.cornerRadius = 3.0
        button.layer.masksToBounds = true
        button.applyGradient(gradient: CAGradientLayer(), colours:[UIColor(hex:"00C3FF"), UIColor(hex:"FFFF1C")], locations:[0.0,1.0], stP:CGPoint(x:0.0,y:0.0), edP:CGPoint(x:1.0,y:0.0), gradientAnimation: CABasicAnimation())
        button.addTarget(self, action: #selector(RegisterViewController.register(_:)), for: .touchUpInside)
        return button
    }()
    
    fileprivate var contentViewCenterYConstraint : NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupObserver()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        pastelView.startAnimation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        releaseObservers()
    }
    
    fileprivate func setupUI() {
        view.backgroundColor = UIColor.clear
        
        view.addSubview(pastelView)
        view.insertSubview(pastelView, at: 0)
        view.addSubview(contentView)
        contentView.addSubview(chooseAvatarButton)
        contentView.addSubview(usernameTf)
        contentView.addSubview(passwordTf)
        contentView.addSubview(confirm_passwordTf)
        contentView.addSubview(registerButton)
        contentView.addSubview(emailTf)
        contentView.addSubview(phoneTf)
        addLines()
        setupConstraints()
        setupNavigationBar()
        
        registerButton.setTitle("完成", for: .normal)
        usernameTf.attributedPlaceholder = NSAttributedString(string: "請輸入賬戶名稱", attributes: [NSAttributedStringKey.foregroundColor: UIColor.lightGray])
        passwordTf.attributedPlaceholder = NSAttributedString(string: "請輸入密碼", attributes: [NSAttributedStringKey.foregroundColor: UIColor.lightGray])
        confirm_passwordTf.attributedPlaceholder = NSAttributedString(string: "請輸入確認密碼", attributes: [NSAttributedStringKey.foregroundColor: UIColor.lightGray])
        emailTf.attributedPlaceholder = NSAttributedString(string: "請輸入郵箱", attributes: [NSAttributedStringKey.foregroundColor: UIColor.lightGray])
        phoneTf.attributedPlaceholder = NSAttributedString(string: "請輸入手機號", attributes: [NSAttributedStringKey.foregroundColor: UIColor.lightGray])
        chooseAvatarButton.setTitle("選擇頭像", for: .normal)
    }
    
    fileprivate func setupConstraints() {
        pastelView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        pastelView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        pastelView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        pastelView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

        contentView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        contentViewCenterYConstraint = contentView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        contentViewCenterYConstraint?.isActive = true
        contentView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20.0).isActive = true
        contentView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20.0).isActive = true


        chooseAvatarButton.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor).isActive = true
        chooseAvatarButton.topAnchor.constraint(equalTo: self.contentView.topAnchor).isActive = true
        chooseAvatarButton.widthAnchor.constraint(equalToConstant: 120.0).isActive = true
        chooseAvatarButton.heightAnchor.constraint(equalToConstant: 120.0).isActive = true

        self.usernameTf.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor).isActive = true
        self.usernameTf.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor).isActive = true
        self.usernameTf.topAnchor.constraint(equalTo: self.chooseAvatarButton.bottomAnchor, constant: 30.0).isActive = true
        self.usernameTf.heightAnchor.constraint(equalToConstant: 50.0).isActive = true

        self.passwordTf.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor).isActive = true
        self.passwordTf.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor).isActive = true
        self.passwordTf.topAnchor.constraint(equalTo: self.usernameTf.bottomAnchor, constant: 5.0).isActive = true
        self.passwordTf.heightAnchor.constraint(equalToConstant: 50.0).isActive = true

        self.confirm_passwordTf.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor).isActive = true
        self.confirm_passwordTf.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor).isActive = true
        self.confirm_passwordTf.topAnchor.constraint(equalTo: self.passwordTf.bottomAnchor, constant: 5.0).isActive = true
        self.confirm_passwordTf.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
        
        self.emailTf.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor).isActive = true
        self.emailTf.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor).isActive = true
        self.emailTf.topAnchor.constraint(equalTo: self.confirm_passwordTf.bottomAnchor, constant: 5.0).isActive = true
        self.emailTf.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
        
        self.phoneTf.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor).isActive = true
        self.phoneTf.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor).isActive = true
        self.phoneTf.topAnchor.constraint(equalTo: self.emailTf.bottomAnchor, constant: 5.0).isActive = true
        self.phoneTf.heightAnchor.constraint(equalToConstant: 50.0).isActive = true

        self.registerButton.topAnchor.constraint(equalTo: self.phoneTf.bottomAnchor, constant: 20.0).isActive = true
        self.registerButton.centerXAnchor.constraint(equalTo: self.chooseAvatarButton.centerXAnchor).isActive = true
        self.registerButton.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
        self.registerButton.widthAnchor.constraint(equalTo: self.contentView.widthAnchor, multiplier: 1.0).isActive = true
        self.registerButton.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: 0.0).isActive = true
        
    }
    
    fileprivate func addLines() {
        let line1 = UIView()
        let line2 = UIView()
        let line3 = UIView()
        let line4 = UIView()
        let line5 = UIView()
        line1.backgroundColor = UIColor.white
        line2.backgroundColor = UIColor.white
        line3.backgroundColor = UIColor.white
        line4.backgroundColor = UIColor.white
        line5.backgroundColor = UIColor.white
        contentView.addSubview(line1)
        contentView.addSubview(line2)
        contentView.addSubview(line3)
        contentView.addSubview(line4)
        contentView.addSubview(line5)
        line1.translatesAutoresizingMaskIntoConstraints = false
        line2.translatesAutoresizingMaskIntoConstraints = false
        line3.translatesAutoresizingMaskIntoConstraints = false
        line4.translatesAutoresizingMaskIntoConstraints = false
        line5.translatesAutoresizingMaskIntoConstraints = false
        
        line1.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        line2.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        line3.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        line4.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        line5.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        
        line1.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 0.0).isActive = true
        line1.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: 0.0).isActive = true
        line1.bottomAnchor.constraint(equalTo: self.usernameTf.bottomAnchor, constant: 0.0).isActive = true
        line2.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 0.0).isActive = true
        line2.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: 0.0).isActive = true
        line2.bottomAnchor.constraint(equalTo: self.passwordTf.bottomAnchor, constant: 0.0).isActive = true
        line3.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 0.0).isActive = true
        line3.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: 0.0).isActive = true
        line3.bottomAnchor.constraint(equalTo: self.confirm_passwordTf.bottomAnchor, constant: 0.0).isActive = true
        line4.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 0.0).isActive = true
        line4.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: 0.0).isActive = true
        line4.bottomAnchor.constraint(equalTo: self.emailTf.bottomAnchor, constant: 0.0).isActive = true
        line5.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 0.0).isActive = true
        line5.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: 0.0).isActive = true
        line5.bottomAnchor.constraint(equalTo: self.phoneTf.bottomAnchor, constant: 0.0).isActive = true
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
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        dismissKeyboard()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let obj = object else { return }
        guard let keyPath = keyPath else { return }
        if keyPath == "highlighted" {
            let button = obj as! UIButton
            if button == self.chooseAvatarButton {
                if button.isHighlighted {
                    button.backgroundColor = BaseProfileViewController.globalTint.withAlphaComponent(0.3)
                }
                else {
                    button.backgroundColor = BaseProfileViewController.globalTint.withAlphaComponent(0.8)
                }
            }
        }
        else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
}

extension RegisterViewController {
    @objc fileprivate func textFieldsEditingChanged() {
        
    }
    
    @objc fileprivate func chooseAvatarButtonAction() {
        let alertController = PCLBlurEffectAlertController(title: nil,
                                                           message: nil,
                                                           effect: UIBlurEffect(style: .extraLight),
                                                           style: .actionSheet)
        alertController.configure(overlayBackgroundColor: UIColor.orange.withAlphaComponent(0.3))
        alertController.configure(titleFont: UIFont.systemFont(ofSize: 24),
                                  titleColor: .red)
        alertController.configure(messageColor: .blue)
        alertController.configure(buttonFont: [.default: UIFont.systemFont(ofSize: 24),
                                               .destructive: UIFont.boldSystemFont(ofSize: 20),
                                               .cancel: UIFont.systemFont(ofSize: 14)],
                                  buttonTextColor: [.default: .brown,
                                                    .destructive: .blue,
                                                    .cancel: .gray])
        let action1 = PCLBlurEffectAlertAction(title: "拍照", style: .default) { _ in
            self.openCamera()
        }
        let action2 = PCLBlurEffectAlertAction(title: "從手機相冊選擇", style: .destructive) { _ in
            self.openLibrary()
        }
        let cancelAction = PCLBlurEffectAlertAction(title: "Cancel", style: .cancel) { _ in
            
        }
        alertController.addAction(action1)
        alertController.addAction(action2)
        alertController.addAction(cancelAction)
        alertController.show()
    }
    
    @objc private func backBarButtonClick(_ button: UIButton) {
        view.endEditing(true)
        dismiss(animated: true, completion: nil)
    }
    
    @objc fileprivate func dismissKeyboard(){
        view.endEditing(true)
    }
    
    @objc fileprivate func register(_ sender: TransitionButton) {
        usernameTf.isEnabled = false
        passwordTf.isEnabled = false
        confirm_passwordTf.isEnabled = false
        chooseAvatarButton.isEnabled = false
        registerButton.isEnabled = false
        
        sender.startAnimation()
        
        guard let username = usernameTf.text else { return }
        guard let password = passwordTf.text else { return }
        guard let confirm_password = confirm_passwordTf.text else { return }
        guard let avatar = chooseAvatarButton.image(for: .normal) else { return }
        guard let email = emailTf.text else { return }
        guard let phone = phoneTf.text else { return }
        AuthenticationManager.shared.accountLogin.register(username: username, password: password, confirm_password: confirm_password, email:email, phone:phone, avate: avatar, success: { [weak self] (response) in
            // 註冊成功
            sender.stopAnimation(animationStyle: .expand, revertAfterDelay: 1, completion: {
                if let registerCom = self?.registerCompletion {
                    registerCom(username, password, nil)
                }
                self?.navigationController?.popViewController(animated: true)
                
            })
        }) { [weak self] (error) in
            // 登录失败
            sender.stopAnimation(animationStyle: .shake, revertAfterDelay: 1, completion: {
                [weak self] in
                
                let alert = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alert.addAction(ok)
                self?.present(alert, animated: true, completion: nil)
                self?.usernameTf.isEnabled = true
                self?.passwordTf.isEnabled = true
                self?.confirm_passwordTf.isEnabled = true
                self?.chooseAvatarButton.isEnabled = true
                self?.registerButton.isEnabled = true
                if let registerCom = self?.registerCompletion {
                    registerCom(username, password, error)
                }
            })
        }
        
    }
}
extension RegisterViewController {
    
    // 监听键盘
    fileprivate  func setupObserver(){
        NotificationCenter.default.addObserver(self, selector: #selector(RegisterViewController.keyboardWillShow(notification:)), name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(RegisterViewController.keyboardWillHide(notification:)), name: Notification.Name.UIKeyboardWillHide, object: nil)
        chooseAvatarButton.addObserver(self, forKeyPath: "highlighted", options: .new, context: nil)
    }
    
    
    fileprivate func releaseObservers(){
        NotificationCenter.default.removeObserver(self)
        chooseAvatarButton.removeObserver(self, forKeyPath: "highlighted")
    }
    
    // MARK: - Actions
    @objc private func keyboardWillShow(notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        // 获取键盘frame
        let keyboardRect = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        // 键盘弹出的时间
        let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as! Double
        
        if contentView.frame.maxY > keyboardRect.origin.y {
            // 键盘遮住文本了，就把contentView往上移
            let offset = contentView.frame.maxY - keyboardRect.origin.y
            contentViewCenterYConstraint?.constant -= offset
            UIView.animate(withDuration: duration, animations: {
                self.view.layoutIfNeeded()
            })
        }
    }
    
    @objc private func keyboardWillHide(notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        
        // 键盘弹出的时间
        let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as! Double
        
        // 键盘遮住文本了，就把contentView往上移
        contentViewCenterYConstraint?.constant = 0
        UIView.animate(withDuration: duration, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
}

extension RegisterViewController {
    
    var croppingParameters: CroppingParameters {
        return CroppingParameters(isEnabled: false, allowResizing: true, allowMoving: false, minimumSize: CGSize(width: 60, height: 60))
    }
    
    fileprivate func openCamera() {
        let cameraViewController = CameraViewController(croppingParameters: croppingParameters, allowsLibraryAccess: true) { [weak self] image, asset in
            self?.chooseAvatarButton.setImage(image, for: .normal)
            self?.dismiss(animated: true, completion: nil)
        }
        
        present(cameraViewController, animated: true, completion: nil)
    }
    
    fileprivate func openLibrary() {
        let libraryViewController = CameraViewController.imagePickerViewController(croppingParameters: croppingParameters) { [weak self] image, asset in
            self?.chooseAvatarButton.setImage(image, for: .normal)
            self?.dismiss(animated: true, completion: nil)
        }
        
        present(libraryViewController, animated: true, completion: nil)
    }
}
