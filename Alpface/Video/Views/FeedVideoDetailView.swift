//
//  FeedVideoDetailView.swift
//  Alpface
//
//  Created by swae on 2018/4/1.
//  Copyright © 2018年 alpface. All rights reserved.
//

import UIKit
import SDWebImage

@objc(ALPVideoDetailView)
class FeedVideoDetailView: UIView {
    
    public var videoItem: VideoItem? {
        didSet {
            titleButton.text = "@" + (videoItem?.user?.nickname)!
            describeButton.text = videoItem?.describe
            musicButton.text = "大家爱看巨大的空间阿卡"
            avatarButton.sd_setImage(with: videoItem?.user?.getAvatarURL(), for: .normal)
        }
    }

    fileprivate lazy var avatarButton: RoundButton = {
        let view = RoundButton()
        return view
    }()
    
    fileprivate lazy var praiseButton: FeedVideoButton = {
        let view = FeedVideoButton()
        view.imageColorOn = UIColor(red: 254/255, green: 110/255, blue: 111/255, alpha: 1.0)
        view.circleColor = UIColor(red: 254/255, green: 110/255, blue: 111/255, alpha: 1.0)
        view.lineColor = UIColor(red: 226/255, green: 96/255, blue: 96/255, alpha: 1.0)
        return view
    }()
    
    fileprivate lazy var commentButton: FeedVideoButton = {
        let view = FeedVideoButton()
        view.imageColorOn = UIColor(red: 255.0/255, green: 255.0/255, blue: 255.0/255, alpha: 1.0)
        view.circleColor = UIColor(red: 255.0/255, green: 255.0/255, blue: 255.0/255, alpha: 1.0)
        view.lineColor = UIColor(red: 255.0/255, green: 255.0/255, blue: 255.0/255, alpha: 1.0)
        return view
    }()
    fileprivate lazy var forwardButton: FeedVideoButton = {
        let view = FeedVideoButton()
        view.imageColorOn = UIColor(red: 255.0/255, green: 255.0/255, blue: 255.0/255, alpha: 1.0)
        view.circleColor = UIColor(red: 255.0/255, green: 255.0/255, blue: 255.0/255, alpha: 1.0)
        view.lineColor = UIColor(red: 255.0/255, green: 255.0/255, blue: 255.0/255, alpha: 1.0)
        return view
    }()
    
    fileprivate lazy var musicAvatarButton: UIButton = {
        let view = UIButton()
        view.imageView?.contentMode = .scaleAspectFill
        return view
    }()
    
    fileprivate lazy var titleButton: UILabel = {
        let view = UILabel()
        view.textColor = UIColor.white
        view.font = UIFont.systemFont(ofSize: 13.0)
        return view
    }()
    
    fileprivate lazy var describeButton: UILabel = {
        let view = UILabel()
        view.textColor = UIColor.white
        view.numberOfLines = 0
        view.font = UIFont.systemFont(ofSize: 13.0)
        return view
    }()
    
    fileprivate lazy var musicButton: UILabel = {
        let view = UILabel()
        view.textColor = UIColor.white
        view.font = UIFont.systemFont(ofSize: 13.0)
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    fileprivate func setupUI() {
        addSubview(avatarButton)
        addSubview(praiseButton)
        addSubview(commentButton)
        addSubview(forwardButton)
        addSubview(musicAvatarButton)
        addSubview(titleButton)
        addSubview(describeButton)
        addSubview(musicButton)
        
        avatarButton.translatesAutoresizingMaskIntoConstraints = false
        praiseButton.translatesAutoresizingMaskIntoConstraints = false
        commentButton.translatesAutoresizingMaskIntoConstraints = false
        forwardButton.translatesAutoresizingMaskIntoConstraints = false
        musicAvatarButton.translatesAutoresizingMaskIntoConstraints = false
        titleButton.translatesAutoresizingMaskIntoConstraints = false
        describeButton.translatesAutoresizingMaskIntoConstraints = false
        musicButton.translatesAutoresizingMaskIntoConstraints = false
        
        let width: CGFloat = 49.0
        let padding: CGFloat = 10.0
        avatarButton.widthAnchor.constraint(equalToConstant: width).isActive = true
        avatarButton.heightAnchor.constraint(equalTo: avatarButton.widthAnchor, multiplier: 1.0).isActive = true
        avatarButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 0.0).isActive = true
        avatarButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10.0).isActive = true
        
        
        praiseButton.widthAnchor.constraint(equalToConstant: width).isActive = true
        praiseButton.topAnchor.constraint(equalTo: avatarButton.bottomAnchor, constant: 25.0).isActive = true
        praiseButton.centerXAnchor.constraint(equalTo: avatarButton.centerXAnchor, constant: 0.0).isActive = true
        
        commentButton.widthAnchor.constraint(equalToConstant: width).isActive = true
        commentButton.topAnchor.constraint(equalTo: praiseButton.bottomAnchor, constant: padding).isActive = true
        commentButton.centerXAnchor.constraint(equalTo: avatarButton.centerXAnchor, constant: 0.0).isActive = true
        
        forwardButton.widthAnchor.constraint(equalToConstant: width).isActive = true
        forwardButton.topAnchor.constraint(equalTo: commentButton.bottomAnchor, constant: padding).isActive = true
        forwardButton.centerXAnchor.constraint(equalTo: avatarButton.centerXAnchor, constant: 0.0).isActive = true
        
        musicAvatarButton.widthAnchor.constraint(equalToConstant: 75.0).isActive = true
        musicAvatarButton.topAnchor.constraint(equalTo: forwardButton.bottomAnchor, constant: 25.0).isActive = true
        musicAvatarButton.centerXAnchor.constraint(equalTo: avatarButton.centerXAnchor, constant: 0.0).isActive = true
        
        
        titleButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10.0).isActive = true
        titleButton.trailingAnchor.constraint(lessThanOrEqualTo: self.trailingAnchor, constant: -160.0).isActive = true
        titleButton.bottomAnchor.constraint(equalTo: self.describeButton.topAnchor, constant: -5.0).isActive = true
        
        describeButton.leadingAnchor.constraint(equalTo: titleButton.leadingAnchor, constant: 0.0).isActive = true
        describeButton.trailingAnchor.constraint(lessThanOrEqualTo: self.trailingAnchor, constant: -160.0).isActive = true
        describeButton.bottomAnchor.constraint(equalTo: self.musicButton.topAnchor, constant: -5.0).isActive = true
        
        musicButton.leadingAnchor.constraint(equalTo: titleButton.leadingAnchor, constant: 0.0).isActive = true
        musicButton.trailingAnchor.constraint(lessThanOrEqualTo: self.trailingAnchor, constant: -160.0).isActive = true
        musicButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10.0).isActive = true
        
        avatarButton.setBackgroundImage(UIImage.init(named: "icon"), for: .normal)
        praiseButton.alpTitle = "100"
        praiseButton.alpImage = UIImage.init(named: "icon_home_like_after")
        
        commentButton.alpTitle = "100"
        commentButton.alpImage = UIImage.init(named: "icon_home_comment")
        
        forwardButton.alpTitle = "100"
        forwardButton.alpImage = UIImage.init(named: "icon_home_share")
        
        musicAvatarButton.setImage(UIImage.init(named: "icon"), for: .normal)
        
//        titleButton.text = "@常灯台"
//        describeButton.text = "建设大道就爱看大家爱看的后来就好了就好了就好了就好了京津冀了解科技；科技考虑考虑"
//        musicButton.text = "大家爱看巨大的空间阿卡"
        
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if let touchView = super.hitTest(point, with: event) {
            if touchView.isKind(of: UIButton.classForCoder()) {
                return touchView
            }
        }
        return nil
    }
}
