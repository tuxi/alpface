//
//  PlayInteractionViewController.swift
//  Alpface
//
//  Created by swae on 2018/3/12.
//  Copyright © 2018年 alpface. All rights reserved.
//  和PlayVideoViewController配合使用，用于处理及展示视频的描述、字幕、点赞数、作者信息等等

import UIKit

class PlayInteractionViewController: UIViewController {
    
    fileprivate lazy var progressView: UIProgressView = {
        let progressView = UIProgressView.init(progressViewStyle: .default)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        return progressView
    }()
    
    fileprivate lazy var slider: UISlider = {
        let slider = UISlider.init()
        slider.translatesAutoresizingMaskIntoConstraints = false
        return slider
    }()
    
    fileprivate lazy var playButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button .setTitle("播放", for: .normal)
        return button
    }()
    
    fileprivate lazy var fullButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("全屏", for: .normal)
        return button
    }()
    
    fileprivate lazy var totalDurationLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "00:00"
        return label
    }()
    
    fileprivate lazy var currentDurationLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "00:00"
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
