//
//  PlayVideoViewController.swift
//  Alpface
//
//  Created by swae on 2018/3/12.
//  Copyright © 2018年 alpface. All rights reserved.
//  用于播放视频的控制器，纯净的，不包含任何其他字幕

import UIKit
import AVFoundation

@objc(ALPPlayVideoViewController)
class PlayVideoViewController: UIViewController {
    
    //播放器容器
    var containerView: VideoPlayerView = {
        let  containerView = VideoPlayerView(frame: .zero)
        containerView.backgroundColor = UIColor.gray
        containerView.translatesAutoresizingMaskIntoConstraints = false
        let playerLayer = containerView.layer as! AVPlayerLayer
        playerLayer.videoGravity = .resizeAspect //视频填充模式
        return containerView
    }()
    //播放/暂停按钮
    var playOrPauseButton: UIButton = {
        let playOrPauseButton = UIButton(type: .custom)
        playOrPauseButton.translatesAutoresizingMaskIntoConstraints = false
        return playOrPauseButton
    }()
    // 播放进度
    var progress: UIProgressView = {
        let progress = UIProgressView(frame: .zero)
        progress.translatesAutoresizingMaskIntoConstraints = false
        progress.progressTintColor = UIColor.blue
        progress.trackTintColor = UIColor.red
        return progress
    }()
    //显示播放时间
    var timeLabel: UILabel = {
        let timeLabel = UILabel(frame: .zero)
        timeLabel.font = UIFont.systemFont(ofSize: 12.0)
        timeLabel.textColor = UIColor.red
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        return timeLabel
    }()
    
    //播放器对象
    var player: AVPlayer?
    //播放资源对象
    var playerItem: AVPlayerItem?
    //时间观察者
    var timeObserver: Any?
    
    var url: URL?
    var isViewDidLoad: Bool = false
    var playInViewDidLoad: Bool = false
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isViewDidLoad = true
        createUI()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //UI布局
    private func createUI(){
        
        view.addSubview(containerView)
        containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        containerView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        
        containerView.addSubview(playOrPauseButton)
        playOrPauseButton.widthAnchor.constraint(equalToConstant: 50.0).isActive = true
        playOrPauseButton.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
        playOrPauseButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        playOrPauseButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        
        playOrPauseButton.setImage(UIImage(named:"play"), for: .normal)
        playOrPauseButton.addTarget(self, action: #selector(PlayVideoViewController.playOrPauseButtonClicked(button:)), for: .touchUpInside)
        
        
        view.addSubview(progress)
        progress.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10.0).isActive = true
        progress.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10.0).isActive = true
        progress.heightAnchor.constraint(equalToConstant: 3.0).isActive = true
        progress.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 10.0).isActive = true
        
        
        view.addSubview(timeLabel)
        timeLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20.0).isActive = true
        timeLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20.0).isActive = true
        
        if (playInViewDidLoad == true) {
            playInViewDidLoad = false
            playerBack(url: self.url!)
        }
        
    }
    
    /// 获取本地资源，并添加观察者，等资源准备完毕，开始播放
    public func playerBack(url: URL) {
        removeObserver()
        //获取本地视频资源
        guard let path = Bundle.main.path(forResource: "test", ofType: "mov") else {
            return
        }
        //播放本地视频
        let url = NSURL(fileURLWithPath: path)
        //播放网络视频
        //        let url = NSURL(string: "http://10.211.55.3:8889/media/media_itemsqbh3SumU_QkNFk97.mp4")!
        playerItem = AVPlayerItem(url: url as URL)
        if isViewDidLoad == false {
            playInViewDidLoad = true
            self.url = url as URL
            return
        }
        
        //创建视频播放器图层对象
        let playerLayer = containerView.layer as! AVPlayerLayer
        if playerLayer.player != nil{
            if playerLayer.player?.currentItem != nil {
                playerLayer.player?.replaceCurrentItem(with: playerItem)
            }
        }
        else {
            player = AVPlayer(playerItem: playerItem)
            playerLayer.player = player
        }
        player?.play()
        
        addObserver()
        addProgressObserver()
    }
    
    //给播放器添加进度更新
    func addProgressObserver(){
        //这里设置每秒执行一次.
        timeObserver =  player?.addPeriodicTimeObserver(forInterval: CMTimeMake(Int64(1.0), Int32(1.0)), queue: DispatchQueue.main) { [weak self](time: CMTime) in
            //CMTimeGetSeconds函数是将CMTime转换为秒，如果CMTime无效，将返回NaN
            let currentTime = CMTimeGetSeconds(time)
            let totalTime = CMTimeGetSeconds(self!.playerItem!.duration)
            //更新显示的时间和进度条
            self!.timeLabel.text = self!.formatPlayTime(seconds: CMTimeGetSeconds(time))
            self!.progress.setProgress(Float(currentTime/totalTime), animated: true)
            print("当前已经播放\(self!.formatPlayTime(seconds: CMTimeGetSeconds(time)))")
        }
    }
    
    //给AVPlayerItem、AVPlayer添加监控
    func addObserver(){
        //为AVPlayerItem添加status属性观察，得到资源准备好，开始播放视频
        playerItem?.addObserver(self, forKeyPath: "status", options: .new, context: nil)
        //监听AVPlayerItem的loadedTimeRanges属性来监听缓冲进度更新
        playerItem?.addObserver(self, forKeyPath: "loadedTimeRanges", options: .new, context: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(PlayVideoViewController.playerItemDidReachEnd(notification:)), name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
    }
    
    
    ///  通过KVO监控播放器状态
    ///
    /// - parameter keyPath: 监控属性
    /// - parameter object:  监视器
    /// - parameter change:  状态改变
    /// - parameter context: 上下文
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let object = object as? AVPlayerItem  else { return }
        guard let keyPath = keyPath else { return }
        if keyPath == "status"{
            if object.status == .readyToPlay { //当资源准备好播放，那么开始播放视频
                player?.play()
                print("正在播放...，视频总长度:\(formatPlayTime(seconds: CMTimeGetSeconds(object.duration)))")
                playOrPauseButton.isHidden = true
                playOrPauseButton.setImage(UIImage(named:"play"), for: .normal)
            }
            else if object.status == .failed || object.status == .unknown {
                playOrPauseButton.isHidden = false
                print("播放出错")
                playOrPauseButton.setImage(UIImage(named:"pause"), for: .normal)
            }
        } else if keyPath == "loadedTimeRanges" {
            let loadedTime = avalableDurationWithplayerItem()
            print("当前加载进度\(loadedTime)")
        }
    }
    
    //将秒转成时间字符串的方法，因为我们将得到秒。
    func formatPlayTime(seconds: Float64)->String{
        let Min = Int(seconds / 60)
        let Sec = Int(seconds.truncatingRemainder(dividingBy: 60))
        return String(format: "%02d:%02d", Min, Sec)
    }
    
    // 计算当前的缓冲进度
    func avalableDurationWithplayerItem()->TimeInterval{
        guard let loadedTimeRanges = player?.currentItem?.loadedTimeRanges,let first = loadedTimeRanges.first else {fatalError()}
        // 本次缓冲时间范围
        let timeRange = first.timeRangeValue
        let startSeconds = CMTimeGetSeconds(timeRange.start)//本次缓冲起始时间
        let durationSecound = CMTimeGetSeconds(timeRange.duration)//缓冲时间
        let result = startSeconds + durationSecound//缓冲总长度
        return result
    }
    
    // 播放结束，回到最开始位置，播放按钮显示带播放图标
    @objc func playerItemDidReachEnd(notification: Notification){
        player?.seek(to: kCMTimeZero, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)
        progress.progress = 0.0
        playOrPauseButton.setImage(UIImage(named:"play"), for: .normal)
        playOrPauseButton.isHidden = false
    }
    
    //点击播放/暂停按钮
    @objc private func playOrPauseButtonClicked(button: UIButton){
        if let player = player {
            // 没有专门的pause或者playing状态，可以利用rate属性:
            // rate的值为0.0表示暂停视频
            if player.rate == 0 {//点击时已暂停
                button.setImage(UIImage(named:"pause"), for: .normal)
                player.play()
            }
            else if player.rate == 1 {//点击时正在播放
                player.pause()
                button.setImage(UIImage(named:"play"), for: .normal)
            }
        }
    }
    
    //去除观察者
    func removeObserver() {
        playerItem?.removeObserver(self, forKeyPath: "status")
        playerItem?.removeObserver(self, forKeyPath: "loadedTimeRanges")
        if let timeObserver = timeObserver {
            player?.removeTimeObserver(timeObserver)
        }
        NotificationCenter.default.removeObserver(self, name:  Notification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
    }
    
    deinit {
        removeObserver()
    }
    
}
