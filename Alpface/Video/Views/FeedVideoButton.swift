//
//  FeedVideoButton.swift
//  Alpface
//
//  Created by swae on 2018/4/1.
//  Copyright © 2018年 alpface. All rights reserved.
//

import UIKit

@objc(ALPFeedVideoButton)
class FeedVideoButton: UIButton {
    
    open lazy var alpImageView: DOFavoriteButton = {
        let button = DOFavoriteButton(frame: .zero)
//        button.imageColorOn = UIColor(red: 45/255, green: 204/255, blue: 112/255, alpha: 1.0)
//        button.circleColor = UIColor(red: 45/255, green: 204/255, blue: 112/255, alpha: 1.0)
//        button.lineColor = UIColor(red: 45/255, green: 195/255, blue: 106/255, alpha: 1.0)
        return button
    }()
    open lazy var alpLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.numberOfLines = 1
        label.lineBreakMode = NSLineBreakMode.byTruncatingTail
        label.font = UIFont.systemFont(ofSize: 10.0)
        return label
    }()
    fileprivate lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        return view
    }()
    
    @IBInspectable open var alpImage: UIImage? {
        didSet {
            alpImageView.image = alpImage
        }
    }
    
    @IBInspectable open var alpTitle: String? {
        didSet {
            alpLabel.text = alpTitle
        }
    }
    
    @IBInspectable open var imageColorOn: UIColor? {
        didSet {
            alpImageView.imageColorOn = imageColorOn
        }
    }
    @IBInspectable open var imageColorOff: UIColor? {
        didSet {
            alpImageView.imageColorOff = imageColorOff
        }
    }
    
    @IBInspectable open var circleColor: UIColor? {
        didSet {
            alpImageView.circleColor = circleColor
        }
    }
    
    @IBInspectable open var lineColor: UIColor? {
        didSet {
            alpImageView.lineColor = lineColor
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    override var isSelected: Bool {
        didSet {
            // 必须先执行layoutIfNeeded 不然 alpImageView会crash
            self.layoutIfNeeded()
            if self.isSelected {
                self.alpImageView.select()
            } else {
                self.alpImageView.deselect()
            }
        }
    }
    
    fileprivate func setupUI() {
        addSubview(containerView)
        containerView.addSubview(alpLabel)
        containerView.addSubview(alpImageView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        alpLabel.translatesAutoresizingMaskIntoConstraints = false
        alpImageView.translatesAutoresizingMaskIntoConstraints = false
        
        alpLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        
        containerView.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 0.0).isActive = true
        containerView.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0.0).isActive = true
         containerView.widthAnchor.constraint(equalTo: self.widthAnchor, constant: 0.0).isActive = true
        
        
        alpImageView.widthAnchor.constraint(equalTo: self.containerView.widthAnchor, multiplier: 1.0).isActive = true
        alpImageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor, constant: 1.0).isActive = true
        alpImageView.topAnchor.constraint(equalTo: self.containerView.topAnchor, constant: 1.0).isActive = true
        alpImageView.heightAnchor.constraint(equalTo: self.containerView.widthAnchor, multiplier: 0.8).isActive = true
        alpImageView.bottomAnchor.constraint(equalTo: self.alpLabel.topAnchor, constant: 1.0).isActive = true
        alpLabel.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor, constant: 0.0).isActive = true
        alpLabel.trailingAnchor.constraint(lessThanOrEqualTo: self.containerView.trailingAnchor, constant: 0.0).isActive = true
        alpLabel.leadingAnchor.constraint(greaterThanOrEqualTo: self.containerView.leadingAnchor, constant: 0.0).isActive = true
        alpLabel.centerXAnchor.constraint(equalTo: self.containerView.centerXAnchor, constant: 0.0).isActive = true
        
        heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 1.0).isActive = true
    }
}
