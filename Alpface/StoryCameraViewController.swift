//
//  StoryCameraViewController.swift
//  Alpface
//
//  Created by swae on 2018/3/11.
//  Copyright © 2018年 alpface. All rights reserved.
//

import UIKit

class StoryCreationContentView: UIView {
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 25.0)
        label.text = "拍摄你的生活故事"
        label.textAlignment = .center
        return label
    }()
    
    lazy var describeTextLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.lightGray
        label.font = UIFont.systemFont(ofSize: 14.0)
        label.text = "允许访问即可进入拍摄"
        label.textAlignment = .center
        return label
    }()
    
    lazy var cameraAuthorButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.green, for: .normal)
        button.setTitleColor(UIColor.lightGray, for: .selected)
        button.setTitle("启用相机访问权限", for: .normal)
        button.showsTouchWhenHighlighted = true
        return button
    }()
    
    lazy var microAuthorButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.green, for: .normal)
        button.setTitleColor(UIColor.lightGray, for: .selected)
        button.setTitle("启用麦克风访问权限", for: .normal)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }
    
    private func setupViews() {
        
        addSubview(titleLabel)
        addSubview(describeTextLabel)
        addSubview(cameraAuthorButton)
        addSubview(microAuthorButton)
        
        titleLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        describeTextLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        cameraAuthorButton.setContentCompressionResistancePriority(.required, for: .vertical)
        microAuthorButton.setContentCompressionResistancePriority(.required, for: .vertical)
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(5.0)-[titleLabel]-(8.0)-[describeTextLabel]-(50.0)-[cameraAuthorButton]-(30.0)-[microAuthorButton]-(5.0)-|", options:.alignAllCenterX, metrics: nil, views: ["titleLabel": titleLabel, "describeTextLabel": describeTextLabel, "cameraAuthorButton": cameraAuthorButton, "microAuthorButton": microAuthorButton]))
        self.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor).isActive = true
        self.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor).isActive = true
    }
}

class StoryCameraViewController: UIViewController {

    fileprivate lazy var storyCreationContentView: StoryCreationContentView = {
        let creationView = StoryCreationContentView()
        creationView.translatesAutoresizingMaskIntoConstraints = false
        return creationView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupViews()
    }
    
    private func setupViews() -> Void {
        view.backgroundColor = UIColor.black
        view.addSubview(storyCreationContentView)
        storyCreationContentView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        storyCreationContentView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
