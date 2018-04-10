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
        label.font = UIFont.boldSystemFont(ofSize: 13.0)
        return label
    }()
    
    fileprivate lazy var textField : UITextField = {
        let tf = UITextField()
        tf.attributedPlaceholder = NSAttributedString(string: "添加你的姓名", attributes: [NSAttributedStringKey.foregroundColor: UIColor.lightGray])
        tf.addTarget(self, action: #selector(textFieldsEditingChanged),for: .editingChanged)
        tf.font = UIFont.systemFont(ofSize: 13.0)
        return tf
    }()
    
    fileprivate lazy var bottomLineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 220/255.0, green: 220/255.0, blue: 220/255.0, alpha: 1.0)
        return view
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
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
        
        self.titleLabel.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor).isActive = true
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
        
    }
}
