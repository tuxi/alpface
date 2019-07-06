//
//  EditProfileTableViewCell.swift
//  Alpface
//
//  Created by swae on 2018/4/10.
//  Copyright © 2018年 alpface. All rights reserved.
//

import UIKit

class EditProfileTableViewCell: UITableViewCell {
    
    fileprivate lazy var titleLabel : UILabel = {
        let label = UILabel()
        label.textColor = UIColor.black
        label.text = "姓名"
        label.font = UIFont.boldSystemFont(ofSize: 15.0)
        return label
    }()
    
    fileprivate lazy var textField : UITextField = {
        let tf = UITextField()
        tf.attributedPlaceholder = NSAttributedString(string: "添加你的姓名", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        tf.addTarget(self, action: #selector(textFieldsEditingChanged),for: .editingChanged)
        tf.font = UIFont.systemFont(ofSize: 15.0)
        tf.textColor = BaseProfileViewController.globalTint
        return tf
    }()
    
    fileprivate lazy var bottomLineView: UIView = {
        let view = UIView()
        view.backgroundColor = AppTheme.cellBottomLineColor
        return view
    }()
    
    public var contentChangedCallBack: ((_ content: String?) -> Void)?
    
    fileprivate var titleLabelCenterYContraint: NSLayoutConstraint?
    fileprivate var titleLabelTopContraint: NSLayoutConstraint?
    
    public var model: EditUserProfileModel? {
        didSet {
            self.titleLabel.text = model?.title
            self.textField.placeholder = model?.placeholder
            self.textField.text = model?.content
            if model?.type == EditUserProfileModelType.textFieldMultiLine {
                titleLabelCenterYContraint?.isActive = false
                titleLabelTopContraint?.isActive = true
            }
            else {
                titleLabelCenterYContraint?.isActive = true
                titleLabelTopContraint?.isActive = false
            }
        }
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    fileprivate func setupUI() {
        self.contentView.addSubview(self.titleLabel)
        self.contentView.addSubview(self.textField)
        self.contentView.addSubview(self.bottomLineView)
        
        self.titleLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        self.titleLabel.setContentHuggingPriority(.required, for: .horizontal)
        
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.textField.translatesAutoresizingMaskIntoConstraints = false
        self.bottomLineView.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabelCenterYContraint = self.titleLabel.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor)
        titleLabelCenterYContraint?.isActive = true
        
        titleLabelTopContraint = self.titleLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 10.0)
        
        self.titleLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 12.0).isActive = true
        
        self.textField.leadingAnchor.constraint(equalTo: self.titleLabel.trailingAnchor, constant: 30.0).isActive = true
        self.textField.centerYAnchor.constraint(equalTo: self.titleLabel.centerYAnchor, constant: 0.0).isActive = true
        self.textField.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -12.0).isActive = true
        self.textField.heightAnchor.constraint(equalTo: self.contentView.heightAnchor, multiplier: 0.9).isActive = true
        
        self.bottomLineView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 0.0).isActive = true
        self.bottomLineView.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        self.bottomLineView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: 0.0).isActive = true
        self.bottomLineView.widthAnchor.constraint(equalTo: self.contentView.widthAnchor, constant: 0.0).isActive = true
    }

}

extension EditProfileTableViewCell {
    @objc fileprivate func textFieldsEditingChanged() {
        self.model?.content = self.textField.text
        if let callBack = self.contentChangedCallBack {
            callBack(self.model?.content)
        }
    }
}
