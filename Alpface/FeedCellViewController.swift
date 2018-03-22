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
    
    public var url: URL? {
        didSet {
            guard let url = self.url else { return }
            playVideoVc?.playerBack(url: url)
        }
    }
    /// 播放视频控制器
    private var playVideoVc: PlayVideoViewController?
    /// 处理及展示视频的描述、字幕、点赞数、作者信息的控制器
    public var interactionController: PlayInteractionViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        playVideoVc = PlayVideoViewController()
        view.addSubview((playVideoVc?.view)!)
        playVideoVc?.view.translatesAutoresizingMaskIntoConstraints = false
        playVideoVc?.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        playVideoVc?.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        playVideoVc?.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        playVideoVc?.view.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        
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
