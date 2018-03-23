//
//  PlayInteractionViewController.swift
//  Alpface
//
//  Created by swae on 2018/3/12.
//  Copyright © 2018年 alpface. All rights reserved.
//  和PlayVideoViewController配合使用，用于处理及展示视频的描述、字幕、点赞数、作者信息等等

import UIKit

@objc(ALPPlayInteractionViewController)
class PlayInteractionViewController: UIViewController {
    
    open var playerController: PlayVideoViewController?
    
    /// 播放/暂停按钮
    var playOrPauseButton: UIButton = {
        let playOrPauseButton = UIButton(type: .custom)
        playOrPauseButton.translatesAutoresizingMaskIntoConstraints = false
        playOrPauseButton.setImage(UIImage(named:"pause"), for: .selected)
        playOrPauseButton.setImage(UIImage(named:"play"), for: .normal)
        return playOrPauseButton
    }()
    /// 播放进度
    var progress: UIProgressView = {
        let progress = UIProgressView(frame: .zero)
        progress.translatesAutoresizingMaskIntoConstraints = false
        progress.progressTintColor = UIColor.blue
        progress.trackTintColor = UIColor.red
        return progress
    }()
    /// 显示播放时间
    var timeLabel: UILabel = {
        let timeLabel = UILabel(frame: .zero)
        timeLabel.font = UIFont.systemFont(ofSize: 12.0)
        timeLabel.textColor = UIColor.red
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        return timeLabel
    }()
    
    convenience init(playerController: PlayVideoViewController) {
        self.init()
        playerController.delegate = self
        self.playerController = playerController
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupUI()
    }
    
    fileprivate func setupUI() {
        view.addSubview(playOrPauseButton)
        playOrPauseButton.widthAnchor.constraint(equalToConstant: 50.0).isActive = true
        playOrPauseButton.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
        playOrPauseButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        playOrPauseButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        playOrPauseButton.setImage(UIImage(named:"play"), for: .normal)
        playOrPauseButton.addTarget(self, action: #selector(PlayInteractionViewController.playOrPauseButtonClicked(button:)), for: .touchUpInside)
        
        
        view.addSubview(progress)
        progress.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10.0).isActive = true
        progress.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10.0).isActive = true
        progress.heightAnchor.constraint(equalToConstant: 3.0).isActive = true
        progress.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 10.0).isActive = true
        
        
        view.addSubview(timeLabel)
        timeLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20.0).isActive = true
        timeLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20.0).isActive = true
    }

    /// 点击播放/暂停按钮
    @objc private func playOrPauseButtonClicked(button: UIButton) {
        guard let playerController = playerController else { return }
        if playerController.state == .playing {
            button.isSelected = false
            playerController.pauseToPlay()
        }
        else {
            button.isSelected = true
            playerController.startToPlay()
        }
    }
    

}

extension PlayInteractionViewController : PlayVideoViewControllerDelegate {
    /// 播放进度改变时调用
    func playVideoViewController(didChangePlayerProgress player:PlayVideoViewController, time: String, progress: Float) -> Void {
        
    }
    /// 缓冲进度改变时调用
    func playVideoViewController(didChangebufferedProgress player:PlayVideoViewController, loadedTime: Double, bufferedProgress: Float) -> Void {
        
    }
    /// 播放状态改变时调用
    func playVideoViewController(didChangePlayerState player:PlayVideoViewController, state: PlayerState) -> Void {
        if state == .failure || state == .stopped || state == .paused {
            playOrPauseButton.isSelected = false
            playOrPauseButton.isHidden = false
        }
        else if state == .playing {
            playOrPauseButton.isHidden = true
            playOrPauseButton.isSelected = true
        }
    }
    /// 播放完毕时调用
    func playVideoViewController(didPlayToEnd player: PlayVideoViewController) -> Void {
        
        progress.progress = 0.0
        playOrPauseButton.isSelected = false
        playOrPauseButton.isHidden = false
    }
}
