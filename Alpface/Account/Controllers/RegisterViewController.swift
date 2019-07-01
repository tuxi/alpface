//
//  RegisterViewController.swift
//  Alpface
//
//  Created by swae on 2018/4/7.
//  Copyright © 2018年 alpface. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController {
    
    convenience init(completion: @escaping (_ user: User?, _ error: Error?) -> (Void)) {
        self.init()
        self.registerCompletion = completion
    }
    
    fileprivate var registerCompletion : ((_ user: User?, _ error: Error?) -> (Void))?
    
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
        btn.imageView?.contentMode = UIViewContentMode.scaleAspectFit
        return btn
    }()
    
    fileprivate lazy var nicknameTf : UITextField = {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.textColor = UIColor.white
        tf.addTarget(self, action: #selector(textFieldsEditingChanged(tf:)),for: .editingChanged)
        return tf
    }()
    
    fileprivate lazy var passwordTf : UITextField = {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.isSecureTextEntry = true
        tf.textColor = UIColor.white
        tf.addTarget(self, action: #selector(textFieldsEditingChanged(tf:)),for: .editingChanged)
        return tf
    }()
    
    fileprivate lazy var confirm_passwordTf : UITextField = {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.isSecureTextEntry = true
        tf.textColor = UIColor.white
        tf.addTarget(self, action: #selector(textFieldsEditingChanged(tf:)),for: .editingChanged)
        return tf
    }()
    
    fileprivate lazy var emailTf : UITextField = {
        let tf = UITextField()
        tf.keyboardType = .emailAddress
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.textColor = UIColor.white
        tf.addTarget(self, action: #selector(textFieldsEditingChanged(tf:)),for: .editingChanged)
        return tf
    }()
    
    fileprivate lazy var phoneTf : UITextField = {
        let tf = UITextField()
        tf.keyboardType = .phonePad
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.textColor = UIColor.white
        tf.addTarget(self, action: #selector(textFieldsEditingChanged(tf:)),for: .editingChanged)
        return tf
    }()
    
    fileprivate lazy var verificationCodeTf : UITextField = {
        let tf = UITextField()
        tf.keyboardType = .phonePad
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.textColor = UIColor.white
        tf.addTarget(self, action: #selector(textFieldsEditingChanged(tf:)),for: .editingChanged)
        return tf
    }()
    
    fileprivate lazy var verificationCodeButton : VerificationCodeButton = {
        let button = VerificationCodeButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isEnabled = false
        button.addTarget(self, action: #selector(verificationCodeButtonClick), for: .touchUpInside)
        return button
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
        button.setTitleColor(UIColor.white.withAlphaComponent(0.75), for: .normal)
        button.setTitleColor(UIColor.gray.withAlphaComponent(0.85), for: .disabled)
        button.setTitleColor(UIColor.white, for: .highlighted)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16.0, weight: UIFont.Weight(rawValue: 1.0))
        button.spinnerColor = UIColor.white
        button.cornerRadius = 25.0
        button.layer.cornerRadius = 3.0
        button.layer.masksToBounds = true
        button.isEnabled = false
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
        contentView.addSubview(nicknameTf)
        contentView.addSubview(passwordTf)
        contentView.addSubview(confirm_passwordTf)
        contentView.addSubview(registerButton)
        contentView.addSubview(emailTf)
        contentView.addSubview(phoneTf)
        contentView.addSubview(verificationCodeTf)
        contentView.addSubview(verificationCodeButton)
        addLines()
        setupConstraints()
        setupNavigationBar()
        
        registerButton.setTitle("完成", for: .normal)
        
        nicknameTf.attributedPlaceholder = NSAttributedString(string: "请输入用户名", attributes: [NSAttributedStringKey.foregroundColor: UIColor.lightGray])
        passwordTf.attributedPlaceholder = NSAttributedString(string: "请输入密码", attributes: [NSAttributedStringKey.foregroundColor: UIColor.lightGray])
        confirm_passwordTf.attributedPlaceholder = NSAttributedString(string: "请输入确认密码", attributes: [NSAttributedStringKey.foregroundColor: UIColor.lightGray])
        emailTf.attributedPlaceholder = NSAttributedString(string: "请输入邮箱", attributes: [NSAttributedStringKey.foregroundColor: UIColor.lightGray])
        phoneTf.attributedPlaceholder = NSAttributedString(string: "请输入手机号", attributes: [NSAttributedStringKey.foregroundColor: UIColor.lightGray])
        verificationCodeTf.attributedPlaceholder = NSAttributedString(string: "请输入验证码", attributes: [NSAttributedStringKey.foregroundColor: UIColor.lightGray])
        chooseAvatarButton.setTitle("选择头像", for: .normal)
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

        self.nicknameTf.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor).isActive = true
        self.nicknameTf.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor).isActive = true
        self.nicknameTf.topAnchor.constraint(equalTo: self.chooseAvatarButton.bottomAnchor, constant: 30.0).isActive = true
        self.nicknameTf.heightAnchor.constraint(equalToConstant: 50.0).isActive = true

        self.passwordTf.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor).isActive = true
        self.passwordTf.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor).isActive = true
        self.passwordTf.topAnchor.constraint(equalTo: self.nicknameTf.bottomAnchor, constant: 5.0).isActive = true
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
        
        self.verificationCodeTf.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor).isActive = true
        self.verificationCodeTf.topAnchor.constraint(equalTo: self.phoneTf.bottomAnchor, constant: 5.0).isActive = true
        self.verificationCodeTf.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
        
        self.verificationCodeButton.leadingAnchor.constraint(equalTo: self.verificationCodeTf.trailingAnchor, constant: 20.0).isActive = true
//        self.verificationCodeButton.widthAnchor.constraint(equalToConstant: 120.0).isActive = true
        self.verificationCodeButton.centerYAnchor.constraint(equalTo: self.verificationCodeTf.centerYAnchor, constant: 0.0).isActive = true
        self.verificationCodeButton.heightAnchor.constraint(equalTo: self.verificationCodeTf.heightAnchor, constant: 0.0).isActive = true
        self.verificationCodeButton.trailingAnchor.constraint(lessThanOrEqualTo: self.contentView.trailingAnchor, constant: -0.0).isActive = true

        self.registerButton.topAnchor.constraint(equalTo: self.verificationCodeTf.bottomAnchor, constant: 20.0).isActive = true
        self.registerButton.centerXAnchor.constraint(equalTo: self.chooseAvatarButton.centerXAnchor).isActive = true
        self.registerButton.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
        self.registerButton.widthAnchor.constraint(equalTo: self.contentView.widthAnchor, multiplier: 1.0).isActive = true
        self.registerButton.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: 0.0).isActive = true
        
        self.verificationCodeButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        self.verificationCodeButton.setContentHuggingPriority(.required, for: .horizontal)
        
    }
    
    fileprivate func addLines() {
        let line1 = UIView()
        let line2 = UIView()
        let line3 = UIView()
        let line4 = UIView()
        let line5 = UIView()
        let line6 = UIView()
        line1.backgroundColor = UIColor.white
        line2.backgroundColor = UIColor.white
        line3.backgroundColor = UIColor.white
        line4.backgroundColor = UIColor.white
        line5.backgroundColor = UIColor.white
        line6.backgroundColor = UIColor.white
        contentView.addSubview(line1)
        contentView.addSubview(line2)
        contentView.addSubview(line3)
        contentView.addSubview(line4)
        contentView.addSubview(line5)
        contentView.addSubview(line6)
        line1.translatesAutoresizingMaskIntoConstraints = false
        line2.translatesAutoresizingMaskIntoConstraints = false
        line3.translatesAutoresizingMaskIntoConstraints = false
        line4.translatesAutoresizingMaskIntoConstraints = false
        line5.translatesAutoresizingMaskIntoConstraints = false
        line6.translatesAutoresizingMaskIntoConstraints = false
        
        line1.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        line2.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        line3.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        line4.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        line5.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        line6.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        
        line1.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 0.0).isActive = true
        line1.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: 0.0).isActive = true
        line1.bottomAnchor.constraint(equalTo: self.nicknameTf.bottomAnchor, constant: 0.0).isActive = true
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
        line6.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 0.0).isActive = true
        line6.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: 0.0).isActive = true
        line6.bottomAnchor.constraint(equalTo: self.verificationCodeTf.bottomAnchor, constant: 0.0).isActive = true
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
    @objc fileprivate func textFieldsEditingChanged(tf: UITextField) {
        var maxTextNumber = Int.max
        
        if tf == self.phoneTf {
            maxTextNumber = 11
            // 验证码是否可以发送
            self.verificationCodeButton.isEnabled = (tf.text?.utf16.count)! == maxTextNumber
        }
        
        if tf == self.verificationCodeTf {
            maxTextNumber = 4
        }
        
        // 控制手机号输入的最大值， 判断是不是在拼音状态,拼音状态不截取文本
        if let positionRange = tf.markedTextRange {
            guard tf.position(from: positionRange.start, offset: 0) != nil else {
                checkTextFieldText(textField:tf, maxTextNumber: maxTextNumber)
                return
            }
        }
        else {
            checkTextFieldText(textField:tf, maxTextNumber: maxTextNumber)
        }
        
        if self.phoneTf.text?.count == 11 && self.verificationCodeTf.text?.count == 4  && (self.passwordTf.text ?? "").count > 6 && (self.confirm_passwordTf.text ?? "").count > 6 && (self.nicknameTf.text ?? "" ).count > 4 {
            self.registerButton.isEnabled = true
        }
        else {
            self.registerButton.isEnabled = false
        }
        
    }
    
    
    
    /// 检测如果输入数高于设置最大输入数则截取
    private func checkTextFieldText(textField: UITextField, maxTextNumber: Int){
        guard (textField.text?.utf16.count)! <= maxTextNumber  else {
            guard let text = textField.text else {
                return
            }
            /// emoji的utf16.count是2，所以不能以maxTextNumber进行截取，改用text.count-1
            let sIndex = text.index(text
                .startIndex, offsetBy: text.count-1)
            textField.text = String(text[..<sIndex])
            return
        }
    }
    
    @objc fileprivate func verificationCodeButtonClick() {
        guard let phone = phoneTf.text else { return }
        if phone.count != 11 {
            self.view.xy_showMessage("请输入手机号")
            return
        }
        self.verificationCodeButton.countDown(count: 60)
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
        
        guard let nickname = nicknameTf.text else {
            self.view.xy_showMessage("请输入昵称，必填项")
            return
        }
        guard let password = passwordTf.text else {
            self.view.xy_showMessage("请输入密码，必填项")
            return
            
        }
        guard let confirm_password = confirm_passwordTf.text else {
            self.view.xy_showMessage("请输入确认密码，必填项")
            return
        }
        
        if (self.passwordTf.text ?? "").count < 6 {
            self.view.xy_showMessage("密码少于6位")
            return
        }
        
        if password != confirm_password {
            self.view.xy_showMessage("两次输入的密码不一致，请重新输入")
            self.passwordTf.text = nil
            self.confirm_passwordTf.text = nil
            return
        }
        
        guard let phone = phoneTf.text else {
            self.view.xy_showMessage("请输入手机号，必填项")
            return
        }
        guard let code = verificationCodeTf.text else {
            self.view.xy_showMessage("请输入手机验证码，必填项")
            return
        }
        let avatar = chooseAvatarButton.image(for: .normal)
        let email = emailTf.text
        
        nicknameTf.isEnabled = false
        passwordTf.isEnabled = false
        confirm_passwordTf.isEnabled = false
        chooseAvatarButton.isEnabled = false
        registerButton.isEnabled = false
        
        sender.startAnimation()
        AuthenticationManager.shared.accountLogin.register(username: nil, password: password, phone:phone, code: code, nickname: nickname, email:email, avate: avatar, success: { [weak self] (response) in
            
            let result = response as! AccountLoginResult
            // 註冊成功
            sender.stopAnimation(animationStyle: .expand, revertAfterDelay: 1, completion: {
                if let registerCom = self?.registerCompletion {
                    registerCom(result.user, nil)
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
                self?.nicknameTf.isEnabled = true
                self?.passwordTf.isEnabled = true
                self?.confirm_passwordTf.isEnabled = true
                self?.chooseAvatarButton.isEnabled = true
                self?.registerButton.isEnabled = true
                if let registerCom = self?.registerCompletion {
                    registerCom(nil, error)
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
        return CroppingParameters(isEnabled: false, resizableSide: .sideDefault, moveDirection: .moveDefault, minimumSize: CGSize(width: 60, height: 60))
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
