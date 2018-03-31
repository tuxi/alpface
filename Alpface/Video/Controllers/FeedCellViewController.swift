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
    
    public var videoItem: VideoItem? {
        didSet {
            guard let url = videoItem?.getVideoURL() else { return }
            playVideoVc.playerBack(url: url)
            interactionController.videoItem = videoItem
        }
    }
    
    public var url: URL? {
        didSet {
            guard let url = self.url else { return }
            playVideoVc.playerBack(url: url)
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
        setup()
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
    
    fileprivate func setup() {
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
       
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
