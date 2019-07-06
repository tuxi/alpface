//
//  SettingsTableViewCell.swift
//  Alpface
//
//  Created by swae on 2018/4/15.
//  Copyright © 2018年 alpface. All rights reserved.
//

import UIKit

class SettingsTableViewCell: UITableViewCell {
    
    public var item: SettingsTableViewCellModel? {
        didSet {
            self.titleLabel.text = item?.name
        }
    }
    
    fileprivate lazy var titleLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    fileprivate lazy var arrowButton: UIButton = {
        let arrow = UIButton()
        arrow.setImage(UIImage(named: "icArrowDance"), for: .normal)
        return arrow
    }()
    
    fileprivate lazy var bottomLineView: UIView = {
        let view = UIView()
        view.backgroundColor = AppTheme.cellBottomLineColor
        return view
    }()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    fileprivate func setupUI() {
        self.contentView.addSubview(self.titleLabel)
        self.contentView.addSubview(self.arrowButton)
        self.contentView.addSubview(self.bottomLineView)
        self.bottomLineView.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.arrowButton.translatesAutoresizingMaskIntoConstraints = false
        
        self.titleLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        self.titleLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 10.0).isActive = true
        self.titleLabel.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor, constant: 0.0).isActive = true
        self.titleLabel.topAnchor.constraint(greaterThanOrEqualTo: self.contentView.topAnchor, constant: 0.0).isActive = true
        self.titleLabel.bottomAnchor.constraint(lessThanOrEqualTo: self.contentView.bottomAnchor, constant: 0.0).isActive = true
        self.titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: self.arrowButton.leadingAnchor, constant: -10.0).isActive = true
        
        self.arrowButton.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -10.0).isActive = true
        self.arrowButton.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor, constant: 0.0).isActive = true
        self.arrowButton.heightAnchor.constraint(equalToConstant: 20.0).isActive = true
        self.arrowButton.widthAnchor.constraint(equalToConstant: 20.0).isActive = true
        
        self.bottomLineView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 0.0).isActive = true
        self.bottomLineView.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        self.bottomLineView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: 0.0).isActive = true
        self.bottomLineView.widthAnchor.constraint(equalTo: self.contentView.widthAnchor, constant: 0.0).isActive = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
