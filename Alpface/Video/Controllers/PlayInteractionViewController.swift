//
//  PlayInteractionViewController.swift
//  Alpface
//
//  Created by swae on 2018/3/12.
//  Copyright © 2018年 alpface. All rights reserved.
//  和PlayVideoViewController配合使用，处理播放器的UI

import UIKit

@objc(ALPPlayInteractionViewController)
class PlayInteractionViewController: UIViewController {
    
    public var videoItem: VideoItem? {
        didSet {
        }
    }
    
    /// 播放控制器
    open var playerController: PlayVideoViewController?
    
    /// 播放/暂停状态按钮
    fileprivate var playStatusButton: UIButton = {
        let playStatusButton = UIButton(type: .custom)
        playStatusButton.translatesAutoresizingMaskIntoConstraints = false
        playStatusButton.setImage(UIImage(named:"icon_pausemusic"), for: .selected)
        playStatusButton.setImage(UIImage(named:"icon_playmusic"), for: .normal)
        playStatusButton.isUserInteractionEnabled = false
        return playStatusButton
    }()
    /// 播放进度
    fileprivate var progress: UIProgressView = {
        let progress = UIProgressView(frame: .zero)
        progress.translatesAutoresizingMaskIntoConstraints = false
        progress.progressTintColor = UIColor.blue
        progress.trackTintColor = UIColor.red
        return progress
    }()
    
    /// 加载指示器
    fileprivate lazy var indicator : UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    /// 显示播放时间
    fileprivate var timeLabel: UILabel = {
        let timeLabel = UILabel(frame: .zero)
        timeLabel.font = UIFont.systemFont(ofSize: 12.0)
        timeLabel.textColor = UIColor.red
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        return timeLabel
    }()
    
    convenience init(playerController: PlayVideoViewController) {
        self.init()
        self.playerController = playerController
        playerController.delegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupUI()
        
        // 添加单击轻怕手势
        let singleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap(tap:)))
        singleTapGesture.numberOfTapsRequired = 1
        singleTapGesture.numberOfTouchesRequired  = 1
        view.addGestureRecognizer(singleTapGesture)
        
        // 添加双击轻拍手势
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(tap:)))
        doubleTapGesture.numberOfTapsRequired = 2
        doubleTapGesture.numberOfTouchesRequired = 1
        view.addGestureRecognizer(doubleTapGesture)
        
        // 解决单击和双击手势冲突，设置只有双击手势失败时才触发单击手势
        singleTapGesture.require(toFail: doubleTapGesture)
        
    }
}

// MARK: - Actions
extension PlayInteractionViewController {
    /// 单击 播放/暂停
    @objc fileprivate func handleSingleTap(tap: UITapGestureRecognizer) {
        if tap.state == .ended {
            guard let playerController = playerController else { return }
            if playerController.state == .playing {
                playerController.pause()
            }
            else {
                playerController.play()
            }
        }
    }
    
    /// 双击 点赞
    @objc fileprivate func handleDoubleTap(tap: UITapGestureRecognizer) {
        
    }
}

// MARK: - PlayVideoViewControllerDelegate
extension PlayInteractionViewController : PlayVideoViewControllerDelegate {
    /// 播放进度改变时调用
    func playVideoViewController(didChangePlayerProgress player:PlayVideoViewController, time: String, progress: Float) -> Void {
        self.progress.progress = progress
    }
    /// 缓冲进度改变时调用
    func playVideoViewController(didChangebufferedProgress player:PlayVideoViewController, loadedTime: Double, bufferedProgress: Float) -> Void {
        
    }
    /// 播放状态改变时调用
    func playVideoViewController(didChangePlayerState player:PlayVideoViewController, state: PlayerState) -> Void {
        if  state == .paused {
            playStatusButton.isSelected = false
            playStatusButton.isHidden = false
        }
        else if state == .playing || state == .buffering {
            playStatusButton.isHidden = true
            playStatusButton.isSelected = true
            
        }
        else if state == .failure || state == .stopped {
            playStatusButton.isSelected = true
            playStatusButton.isHidden = false
            
        }
        
        if state != .buffering {
            indicator.stopAnimating()
            indicator.isHidden = true
        }
        else {
            indicator.startAnimating()
            indicator.isHidden = false
        }
    }
    /// 播放完毕时调用
    func playVideoViewController(didPlayToEnd player: PlayVideoViewController) -> Void {
        // 播放完毕，重置进度
        progress.progress = 0.0
    }
}

// MARK: - UI
extension PlayInteractionViewController {
    fileprivate func setupUI() {
        view.addSubview(playStatusButton)
        playStatusButton.widthAnchor.constraint(equalToConstant: 120.0).isActive = true
        playStatusButton.heightAnchor.constraint(equalToConstant: 120.0).isActive = true
        playStatusButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        playStatusButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        view.addSubview(progress)
        progress.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10.0).isActive = true
        progress.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10.0).isActive = true
        progress.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50.0).isActive = true
        
        
        view.addSubview(timeLabel)
        timeLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20.0).isActive = true
        timeLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20.0).isActive = true
        
        view.addSubview(indicator)
        indicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        indicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
}
