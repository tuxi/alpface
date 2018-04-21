//
//  FeedCellViewController.swift
//  Alpface
//
//  Created by swae on 2018/3/12.
//  Copyright © 2018年 alpface. All rights reserved.
//

import UIKit

@objc(ALPFeedCellViewController)
class FeedCellViewController: UIViewController {
    
    fileprivate var observerSet: Set<String> = Set()
    fileprivate var hasPlayCallBack: Bool = false
    public var model: PlayVideoModel? {
        didSet {
            guard let m = model else {
                return
            }
            // 准备资源
            if let videoItem = m.model as? VideoItem {
                guard let url = videoItem.getVideoURL() else { return }
                interactionController.videoItem = videoItem
                playVideoVc.preparePlayback(url: url)
            }
            // 视图显示的时候播放
            m.playCallBack = { [weak self] (canPlay: Bool) in
                self?.playVideoVc.isEndDisplaying = (canPlay == false)
                if canPlay {
                    self?.playVideoVc.autoPlay()
                }
                else {
                    self?.playVideoVc.pause(autoPlay: true)
                }
            }
            if hasPlayCallBack == false {
                // 这里执行下block是为了防止PlayVideoModel的isAllowPlay被初始化时，cell没有显示，导致playCallBack没有执行的机会
                m.playCallBack!(m.isAllowPlay)
                hasPlayCallBack = true
            }
            
        }
    }
    
    /// 播放视频控制器
    public lazy var playVideoVc: PlayVideoViewController = {
        let playVideoVc = PlayVideoViewController()
        playVideoVc.view.translatesAutoresizingMaskIntoConstraints = false
        return playVideoVc
    }()
    /// 处理及展示视频的描述、字幕、点赞数、作者信息的控制器
    public lazy var interactionController: PlayInteractionViewController = {
        let interactionController = PlayInteractionViewController(playerController: self.playVideoVc)
        interactionController.view.translatesAutoresizingMaskIntoConstraints = false
        return interactionController
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        playVideoVc.beginAppearanceTransition(true, animated: animated)
        interactionController.beginAppearanceTransition(true, animated: animated)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        playVideoVc.endAppearanceTransition()
        interactionController.endAppearanceTransition()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        playVideoVc.beginAppearanceTransition(false, animated: animated)
        interactionController.beginAppearanceTransition(false, animated: animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        playVideoVc.endAppearanceTransition()
        interactionController.endAppearanceTransition()
    }
    
    fileprivate func setupUI() {
        view.backgroundColor = UIColor.clear
        view.addSubview((playVideoVc.view)!)
        playVideoVc.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        playVideoVc.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        playVideoVc.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        playVideoVc.view.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        
        view.addSubview(interactionController.view)
        interactionController.view.leadingAnchor.constraint(equalTo: playVideoVc.view.leadingAnchor).isActive = true
        interactionController.view.trailingAnchor.constraint(equalTo: playVideoVc.view.trailingAnchor).isActive = true
        interactionController.view.bottomAnchor.constraint(equalTo: playVideoVc.view.bottomAnchor).isActive = true
        interactionController.view.topAnchor.constraint(equalTo: playVideoVc.view.topAnchor).isActive = true
        
    }
    
}


