//
//  HomeRefreshNavigitionView.swift
//  Alpface
//
//  Created by xiaoyuan on 2018/10/10.
//  Copyright © 2018 alpface. All rights reserved.
//

import UIKit

enum HomeRefreshAnimationStyle {
    case circle // 转圈动画
    case eye    // 眼睛
}

class HomeRefreshNavigitionView: UIView {
    
    public lazy var animationImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isUserInteractionEnabled = false
        imageView.image = UIImage.init(named: "circle")
        return imageView
    }()
    
    public lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor.clear
        label.textColor = UIColor.white
        label.text = "下拉刷新内容"
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16.0)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    fileprivate lazy var loadingImages: [UIImage] = {
        var images: [UIImage] = []
        for i in 0...59 {
            var num: String = "\(i)"
            if i < 10 {
                num = "0\(i)"
            }
            let name = "Loading__000\(num)_32x32_"
            if let image = UIImage.init(named: name) {
                images.append(image)
            }
            else {
                print(name)
            }
        }
        return images
    }()
    
    fileprivate var animationImageViewWidth : NSLayoutConstraint!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupUI()
    }
    
    private func setupUI() {
        self.addSubview(self.animationImageView)
        animationImageViewWidth =  NSLayoutConstraint(item: animationImageView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 18.0)
        animationImageViewWidth.isActive = true
        NSLayoutConstraint(item: animationImageView, attribute: .height, relatedBy: .equal, toItem: animationImageView, attribute: .width, multiplier: 1.0, constant: 0.0).isActive = true
        NSLayoutConstraint(item: animationImageView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0.0).isActive = true
        NSLayoutConstraint(item: animationImageView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: -20.0).isActive = true
        
        self.addSubview(self.titleLabel)
        NSLayoutConstraint(item: titleLabel, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0.0).isActive = true
        NSLayoutConstraint(item: titleLabel, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0.0).isActive = true
    }
    
    public func startAnimation(style: HomeRefreshAnimationStyle) {
        if style == .circle {
            animationImageViewWidth.constant = 18.0
            self.animationImageView.image = UIImage.init(named: "circle")
            // 要先将transform复位-因为CABasicAnimation动画执行完毕后会自动复位，就是没有执行transform之前的位置，跟transform之后的位置有角度差，会造成视觉上旋转不流畅
            self.animationImageView.transform = .identity
            let rotationAnimation: CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
            rotationAnimation.toValue = Double.pi * 2.0
            rotationAnimation.duration = 0.5
            rotationAnimation.isCumulative = true
            //重复旋转的次数，如果你想要无数次，那么设置成MAXFLOAT
            rotationAnimation.repeatCount = MAXFLOAT
            self.animationImageView.layer.add(rotationAnimation, forKey: "rotationAnimation")
        }
        else if style == .eye {
            animationImageViewWidth.constant = 32.0
            self.animationImageView.image = self.loadingImages.first
            self.animationImageView.animationImages = self.loadingImages
            // 无线循环
            self.animationImageView.animationRepeatCount = 0
            //设置帧动画时长
            self.animationImageView.animationDuration = 1
            self.animationImageView.startAnimating()
        }
    }
    
    /// 根据进度更新image progress 0 ~ 1
    public func animation(progress: CGFloat) {
        let idx = Int(progress * CGFloat(self.loadingImages.count))
        self.animationImageView.image = self.loadingImages[idx]
    }
    
    public func stopAnimation() {
        self.animationImageView.layer .removeAnimation(forKey: "rotationAnimation")
        self.animationImageView.stopAnimating()
    }
    
}
