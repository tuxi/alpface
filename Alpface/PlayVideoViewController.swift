//
//  PlayVideoViewController.swift
//  Alpface
//
//  Created by swae on 2018/3/12.
//  Copyright © 2018年 alpface. All rights reserved.
//  用于播放视频的控制器，纯净的，不包含任何其他字幕

import UIKit
import AVFoundation

//播放器的几种状态
@objc(ALPPlayerState)
enum PlayerState : Int {
    case buffering     = 1
    case playing       = 2
    case stopped       = 3
    case paused        = 4
    case failure       = 5
}

@objc(ALPPlayVideoViewControllerDelegate)
protocol PlayVideoViewControllerDelegate: NSObjectProtocol {
    /// 播放进度改变时调用
    @objc optional func playVideoViewController(didChangePlayerProgress player:PlayVideoViewController, time: String, progress: Float) -> Void
    /// 缓冲进度改变时调用
    @objc optional func playVideoViewController(didChangebufferedProgress player:PlayVideoViewController, loadedTime: Double, bufferedProgress: Float) -> Void
    /// 播放状态改变时调用
    @objc optional func playVideoViewController(didChangePlayerState player:PlayVideoViewController, state: PlayerState) -> Void
    /// 播放到结束位置调用
    @objc optional func playVideoViewController(didPlayToEnd player:PlayVideoViewController) -> Void
}

@objc(ALPPlayVideoViewController)
class PlayVideoViewController: UIViewController {
    
    /// 播放代理对象
    open weak var delegate: PlayVideoViewControllerDelegate?
    /// 播放状态， 默认为停止
    open var state : PlayerState = .stopped {
        didSet {
            if oldValue == state {
                return
            }
            guard let delegate = delegate else {
                return
            }
            if delegate.responds(to: #selector(PlayVideoViewControllerDelegate.playVideoViewController(didChangePlayerState:state:))) {
                delegate.playVideoViewController!(didChangePlayerState: self, state: state)
            }
        }
    }
    
    /// 播放的url
    fileprivate var url : URL?
    /// 视频缓冲的进度
    open var bufferedProgress : Float = 0.0
    /// 视频播放的进度
    open var playerProgress : Float = 0.0
    /// 视频总时长
    open var totalDuration : Float = 0.0
    /// 播放器容器视图
    lazy var containerView: VideoPlayerView = {
        let  containerView = VideoPlayerView(frame: .zero)
        containerView.backgroundColor = UIColor.gray
        containerView.translatesAutoresizingMaskIntoConstraints = false
        let playerLayer = containerView.layer as! AVPlayerLayer
        playerLayer.videoGravity = .resizeAspect //视频填充模式
        return containerView
    }()
    
    /// 加载指示器
    lazy var indicator : UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    /// 播放器对象
    var player: AVPlayer?
    /// 播放资源对象
    var playerItem: AVPlayerItem?
    /// 播放时间观察者
    var timeObserver: Any?
    
    var isViewDidLoad: Bool = false
    var playInViewDidLoad: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isViewDidLoad = true
        setupUI()
        if (playInViewDidLoad == true) {
            playInViewDidLoad = false
            playerBack(url: self.url!)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        pauseToPlay()
    }
    
    
    private func setupUI(){
        
        view.addSubview(containerView)
        containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        containerView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        
        containerView.addSubview(indicator)
        indicator.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        indicator.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        
    }
    
    /// 播放一个url
    open func playerBack(url: URL) {
//        removeObserver()
        //获取本地视频资源
        guard let path = Bundle.main.path(forResource: "test", ofType: "mov") else {
            return
        }
        //播放本地视频
        let url = NSURL(fileURLWithPath: path)
        //播放网络视频
//        let url = URL(string: "https://d1.xia12345.com/down/201708/08/pt029.mp4")!
//        self.url = url
        let playerItem = AVPlayerItem(url: url as URL)
        playerBack(playerItem: playerItem)
    }
    
    /// 播放一个AVPlayerItem对象
    open func playerBack(playerItem: AVPlayerItem) {
        self.playerItem = playerItem
        if isViewDidLoad == false {
            playInViewDidLoad = true
            return
        }
        
        /// 创建视频播放器视图
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
    }
    
    // 给播放器添加播放进度更新
    func addPlayProgressObserver(){
        if let timeObserver = timeObserver {
            player?.removeTimeObserver(timeObserver)
        }
        //这里设置每秒执行一次.
        timeObserver =  player?.addPeriodicTimeObserver(forInterval: CMTimeMake(Int64(1.0), Int32(1.0)), queue: DispatchQueue.main) { [weak self](time: CMTime) in
            //CMTimeGetSeconds函数是将CMTime转换为秒，如果CMTime无效，将返回NaN
            let currentTime = CMTimeGetSeconds(time)
            let totalTime = CMTimeGetSeconds(self!.playerItem!.duration)
            // 更新显示的时间和进度条
            let timeStr = self!.formatPlayTime(seconds: CMTimeGetSeconds(time))
            let playProgress = Float(currentTime/totalTime)
            if let delegate = self?.delegate {
                if delegate.responds(to: #selector(PlayVideoViewControllerDelegate.playVideoViewController(didChangePlayerProgress:time:progress:))) {
                    delegate.playVideoViewController!(didChangePlayerProgress: self!, time: timeStr, progress: playProgress)
                }
            }
            
            print("当前已经播放\(self!.formatPlayTime(seconds: CMTimeGetSeconds(time)))")
        }
    }
    
    //给AVPlayerItem、AVPlayer添加监控
    func addObserver(){
        //为AVPlayerItem添加status属性观察，得到资源准备好，开始播放视频
        playerItem?.addObserver(self, forKeyPath: "status", options: .new, context: nil)
        //监听AVPlayerItem的loadedTimeRanges属性来监听缓冲进度更新
        playerItem?.addObserver(self, forKeyPath: "loadedTimeRanges", options: .new, context: nil)
        playerItem?.addObserver(self, forKeyPath: "playbackBufferEmpty", options: .new, context: nil)
        playerItem?.addObserver(self, forKeyPath: "playbackLikelyToKeepUp", options: .new, context: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(PlayVideoViewController.playerItemDidPlayToEnd(notification:)), name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
    }
    
    
    ///  通过KVO监控播放器状态
    ///
    /// - parameter keyPath: 监控属性
    /// - parameter object:  监视器
    /// - parameter change:  状态改变
    /// - parameter context: 上下文
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let playerItem = object as? AVPlayerItem  else { return }
        guard let keyPath = keyPath else { return }
        if keyPath == "status"{
            if playerItem.status == .readyToPlay { //当资源准备好播放，那么开始播放视频
                monitoringPlayback()
                print("正在播放...，视频总长度:\(formatPlayTime(seconds: CMTimeGetSeconds(playerItem.duration)))")
            }
            else if playerItem.status == .failed || playerItem.status == .unknown {
                state = .failure
            }
        }
        else if keyPath == "loadedTimeRanges" {
            let loadedTime = avalableDurationWithplayerItem(playerItem)
            print("当前加载进度\(loadedTime)")
        }
        else if keyPath == "playbackBufferEmpty" && playerItem.isPlaybackBufferEmpty {    //监听播放器在缓冲数据的状态
            state = .buffering
            indicator.startAnimating()
            indicator.isHidden = false
            pauseToPlay()
        } else if keyPath == "playbackLikelyToKeepUp" {
            // 缓存足够了，可以播放
            indicator.stopAnimating()
            indicator.isHidden = true
        }
    }
    
    //将秒转成时间字符串的方法，因为我们将得到秒。
    func formatPlayTime(seconds: Float64)->String{
        let min = Int(seconds / 60)
        let sec = Int(seconds.truncatingRemainder(dividingBy: 60))
        return String(format: "%02d:%02d", min, sec)
    }
    
    // 计算当前的缓冲进度
    func avalableDurationWithplayerItem(_ playerItem: AVPlayerItem?)->TimeInterval{
        guard let loadedTimeRanges = playerItem?.loadedTimeRanges, let first = loadedTimeRanges.first else {fatalError()}
        // 本次缓冲时间范围
        let timeRange = first.timeRangeValue
        let startSeconds = CMTimeGetSeconds(timeRange.start)//本次缓冲起始时间
        let durationSecound = CMTimeGetSeconds(timeRange.duration)//缓冲时间
        let timeInterval = startSeconds + durationSecound//缓冲总长度
        let duration = playerItem!.duration
        let totalDuration = CMTimeGetSeconds(duration)
        bufferedProgress = Float(timeInterval)/Float(totalDuration)
        if let delegate = delegate {
            if delegate.responds(to: #selector(PlayVideoViewControllerDelegate.playVideoViewController(didChangebufferedProgress:loadedTime:bufferedProgress:))) {
                delegate.playVideoViewController!(didChangebufferedProgress: self, loadedTime: timeInterval, bufferedProgress: bufferedProgress)
            }
        }
        return timeInterval
    }
    
    // 播放结束，回到最开始位置，播放按钮显示带播放图标
    @objc func playerItemDidPlayToEnd(notification: Notification){
        player?.seek(to: kCMTimeZero, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)
        releasePlayer()
        if let delegate = delegate {
            if delegate.responds(to: #selector(PlayVideoViewControllerDelegate.playVideoViewController(didPlayToEnd:))) {
                delegate.playVideoViewController!(didPlayToEnd: self)
            }
        }
    }
    
    /// 即将播放
    fileprivate func monitoringPlayback() {
        // 视频总时间
        totalDuration = Float(Float64(playerItem!.duration.value) / Float64(playerItem!.duration.timescale))
//        let totalDurationString = formatPlayTime(seconds: totalDuration)
        startToPlay()
    }
    
    /// 开始播放
    open func startToPlay() {
        if player == nil {
            indicator.startAnimating()
            indicator.isHidden = false
            guard let url = url else { return }
            playerBack(url: url)
        }
        addPlayProgressObserver()
        state = .playing
        player?.play()
    }
    
    /// 暂停播放
    open func pauseToPlay() {
        removeObserver()
        indicator.stopAnimating()
        indicator.isHidden = true
        player?.pause()
        state = .paused
    }
    /// 播放某个时间点
    open func seekToTime(seconds : Float) {
        guard state != .stopped else { return }
        var second = max(0, seconds)
        second = min(seconds, totalDuration)
        pauseToPlay()
        player?.seek(to: CMTimeMakeWithSeconds(Float64(second), Int32(NSEC_PER_SEC)) , completionHandler: { [weak self](_) in
            self?.startToPlay()
            if !self!.playerItem!.isPlaybackLikelyToKeepUp {
                self?.state = .buffering
            }
        })
    }
    
    /// 重置播放器
    open func releasePlayer() {
        guard playerItem != nil else { return }
        removeObserver()
//        player?.replaceCurrentItem(with: nil)
//        player = nil
//        playerItem = nil
        state = .stopped
    }
    
    /// 移除观察者
    func removeObserver() {
        playerItem?.removeObserver(self, forKeyPath: "loadedTimeRanges")
        playerItem?.removeObserver(self, forKeyPath: "playbackBufferEmpty")
        playerItem?.removeObserver(self, forKeyPath: "playbackLikelyToKeepUp")
        if let timeObserver = timeObserver {
            player?.removeTimeObserver(timeObserver)
        }
        timeObserver = nil
        NotificationCenter.default.removeObserver(self, name:  Notification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
    }
    
    deinit {
        releasePlayer()
    }
    
}
