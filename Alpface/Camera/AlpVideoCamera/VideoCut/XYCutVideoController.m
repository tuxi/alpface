//
//  XYCutVideoController.m
//  XYVideoCut
//
//  Created by xiaoyuan on 16/11/14.
//  Copyright © 2016年 alpface. All rights reserved.
//

#import "XYCutVideoController.h"
#import "XYCutVideoView.h"
#import "MBProgressHUD+XYHUD.h"
#import "AlpEditVideoNavigationBar.h"
#import "AlpEditVideoViewController.h"

@interface XYCutVideoController () <ICGVideoTrimmerDelegate>

@property (nonatomic, assign) BOOL isPlaying;
@property (nonatomic, assign) CGFloat startTime;
@property (nonatomic, assign) CGFloat stopTime;
@property (nonatomic, assign) CGFloat videoPlaybackPosition;
@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, copy) NSString *tempVideoPath;

@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVAsset *asset;

@property (nonatomic, strong) XYCutVideoView *view;

@end

@implementation XYCutVideoController

@dynamic view;

- (XYCutVideoView *)view {
    return (id)[super view];
}

#pragma mark - View Controller View Life
- (void)loadView {
    
    XYCutVideoView *view = [[XYCutVideoView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.view = view;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tempVideoPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"tempVideo.mov"];
    self.view.backgroundColor = [UIColor colorWithRed:56/255.0 green:55/255.0 blue:53/255.0 alpha:1];
    
    [self initMedia];
    [self setupNavigationBar];
}

- (void)setupNavigationBar {
    // 禁止系统手势
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    self.navigationController.navigationBarHidden = YES;
    AlpEditVideoNavigationBar *headerBar = [[AlpEditVideoNavigationBar alloc] init];
    [headerBar.rightButton setTitle:@"下一步" forState:UIControlStateNormal];
    headerBar.titleLabel.text = @"";
    headerBar.rightButton.backgroundColor = [UIColor redColor];
    headerBar.rightButton.layer.cornerRadius = 3.0;
    headerBar.rightButton.layer.masksToBounds = YES;
    headerBar.backgroundColor = [UIColor clearColor];
    headerBar.rightButton.contentEdgeInsets = UIEdgeInsetsMake(5.0, 5.0, 5.0, 5.0);
    [headerBar.rightButton addTarget:self action:@selector(didClickNextButton) forControlEvents:UIControlEventTouchUpInside];
    [headerBar.leftButton addTarget:self action:@selector(didClickBackButton) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:headerBar];
    headerBar.translatesAutoresizingMaskIntoConstraints = false;
    if (@available(iOS 11.0, *)) {
        [NSLayoutConstraint constraintWithItem:headerBar attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view.safeAreaLayoutGuide attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0].active = YES;
    } else {
        [NSLayoutConstraint constraintWithItem:headerBar attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0].active = YES;
    }
    [NSLayoutConstraint constraintWithItem:headerBar attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0].active = YES;
    [NSLayoutConstraint constraintWithItem:headerBar attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0].active = YES;
    [NSLayoutConstraint constraintWithItem:headerBar attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:44.0].active = YES;
}

- (void)viewWillDisappear:(BOOL)animated {

    [super viewWillDisappear:animated];
    [self tapOnVideoPlayerView];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];
    [self tapOnVideoPlayerView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onApplicationWillResignActive) name:UIApplicationWillResignActiveNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector() name:UIApplicationDidBecomeActiveNotification object:nil];
}


- (void)initMedia {

     // 1.取出选中视频的URL
    NSURL *videoURL = self.videoURL;
    
    // 2.设置playerLayer
    AVAsset *asset = [AVAsset assetWithURL:videoURL];
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:asset];
    AVPlayer *player = [AVPlayer playerWithPlayerItem:playerItem];
    // 将videoPlayerView的layer转换为AVPlayerLayer
    AVPlayerLayer *playerLayer = (AVPlayerLayer *)self.view.videoPlayerView.layer;
    [playerLayer setPlayer:player];
    
    // 设置视频播放的拉伸效果\等比例拉伸
//    playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    // 填充
    playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;;
    // 当播放完成时不做任何事情
    player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    
    // 3.添加手势到videoPlayerView
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnVideoPlayerView)];
    [self.view.videoPlayerView addGestureRecognizer:tap];
    
    // 4.设置cutView
    self.view.cutView.themeColor = [UIColor lightGrayColor]; // 设置视频修剪器的主题颜色
    [self.view.cutView setAsset:asset]; // 设置要剪辑的媒体资源
    [self.view.cutView setShowsRulerView:NO]; // 显示视图修剪器上的标尺
    self.view.cutView.trackerColor = [UIColor yellowColor]; // 设置跟踪器上的颜色
    [self.view.cutView setDelegate:self];
    
    
    self.player = player;
    self.asset = asset;
    
}


////////////////////////////////////////////////////////////////////////
#pragma mark - Notification methods
////////////////////////////////////////////////////////////////////////

- (void)onApplicationWillResignActive {
    [self pause];
}

//- (void)onApplicationDidBecomeActive {
//    [self play];
//}

#pragma mark - ICGVideoTrimmerDelegate
- (void)trimmerView:(ICGVideoTrimmerView *)trimmerView didChangeLeftPosition:(CGFloat)startTime rightPosition:(CGFloat)endTime {

    if (startTime != self.startTime) {
        [self seekVideoToPos:startTime];
    }
    
    // 记录开始时间和结束时间
    self.startTime = startTime;
    self.stopTime = endTime;
}

#pragma mark - Actions
/**
 AVAssetExportPreset640x480 快速导出
 AVAssetExportPreset1280x720 高清导出
 AVAssetExportPreset1920x1080 超清c导出
 */
- (void)exportVideoWithPressName:(NSString *)pressName {
    [MBProgressHUD xy_hideHUD];
    [MBProgressHUD xy_showActivityMessage:@"努力奋斗中..."];
    // 删除缓存中的临时视频文件
    [self deleteTempVideoFile];
    
    // 获取渲染参数预设的标识符
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:self.asset];
    if ([compatiblePresets containsObject:AVAssetExportPresetMediumQuality]) {
        // 如果包含中等质量 就配置渲染参数并导出视频AVAssetExportPresetPassthrough
        AVAssetExportSession *exportSession = [AVAssetExportSession exportSessionWithAsset:self.asset presetName:pressName];
        
        // 设置输出的路径
        exportSession.outputURL = [NSURL fileURLWithPath:self.tempVideoPath];
        // 设置输出文件的格式
        exportSession.outputFileType = AVFileTypeQuickTimeMovie;
        
        // 设置导出视频的range
        // 视频的开始位置
        CMTime start = CMTimeMakeWithSeconds(self.startTime, self.asset.duration.timescale);
        // 视频的持续时间
        CMTime duration = CMTimeMakeWithSeconds(self.stopTime - self.startTime, self.asset.duration.timescale);
        exportSession.timeRange = CMTimeRangeMake(start, duration);
        
        __weak typeof(self) weakSelf = self;
        // 异步导出视频
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            // 根据导出的状态做响应的操作，当导出成功时，回到主线程保存视频
            switch (exportSession.status) {
                case AVAssetExportSessionStatusFailed:
                    NSLog(@"Export failed - %@", [exportSession.error localizedDescription]);
                    break;
                case AVAssetExportSessionStatusCancelled:
                    NSLog(@"Export canceled");
                    break;
                case AVAssetExportSessionStatusExporting:
                    NSLog(@"Exporting now");
                    break;
                default:
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [MBProgressHUD xy_hideHUD];
                        // 跳转到编辑视频页面
                        NSURL *movieURL = [NSURL fileURLWithPath:weakSelf.tempVideoPath];
                        AlpEditVideoViewController *vc = [AlpEditVideoViewController new];
                        vc.videoURL = movieURL;
                        vc.videoOptions = weakSelf.videoOptions;
                        [weakSelf.navigationController pushViewController:vc animated:YES];
                        // 保存相册
//                        UISaveVideoAtPathToSavedPhotosAlbum([movieURL relativePath], self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
                    });
                    break;
            }
        }];
    }

}


// 点按videoLayer的手势
- (void)tapOnVideoPlayerView {
    
    if (self.isPlaying) {
        [self.player pause];
        [self stopPlaybackTimeChecker];
    } else {
        [self.player play];
        // 开始播放时间检测
        [self startPlaybackTimeChecker];
    }
    
    self.isPlaying = !self.isPlaying;
    // 当不在播放时隐藏跟踪器
    [self.view.cutView hideTracker:!self.isPlaying];
}

- (void)pause {
    [self.player pause];
    [self stopPlaybackTimeChecker];
    self.isPlaying = NO;
    // 当不在播放时隐藏跟踪器
    [self.view.cutView hideTracker:self.isPlaying];
}

- (void)play {
    [self.player play];
    // 开始播放时间检测
    [self startPlaybackTimeChecker];
    self.isPlaying = YES;
    // 当不在播放时隐藏跟踪器
    [self.view.cutView hideTracker:self.isPlaying];
}

#pragma mark - 视频播放时间的检测
- (void)stopPlaybackTimeChecker {
    if (self.displayLink) {
        [self.displayLink invalidate];
        self.displayLink = nil;
    }
}

- (void)startPlaybackTimeChecker {
    
    [self stopPlaybackTimeChecker]; // 停止检测
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(onPlaybackTimeCheckerTimer)];
    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)onPlaybackTimeCheckerTimer {
    // 让视频当前播放的时间跟随播放器
    self.videoPlaybackPosition = CMTimeGetSeconds([self.player currentTime]);
    [self.view.cutView seekToTime:CMTimeGetSeconds([self.player currentTime])];
    
    // 当视频播放完后，重置开始时间
    if (self.videoPlaybackPosition >= self.stopTime) {
        self.videoPlaybackPosition = self.startTime;
        [self.view.cutView seekToTime:self.startTime];
        [self seekVideoToPos:self.startTime];
    }
}

- (void)seekVideoToPos:(CGFloat)pos {

    self.videoPlaybackPosition = pos;
    CMTime time = CMTimeMakeWithSeconds(self.videoPlaybackPosition, self.player.currentTime.timescale);
    [self.player seekToTime:time toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
}

#pragma mark - Private 
- (void)deleteTempVideoFile {
    
    NSURL *url = [NSURL fileURLWithPath:self.tempVideoPath];
    BOOL exist = [[NSFileManager defaultManager] fileExistsAtPath:self.tempVideoPath];
    NSError *error;
    // 判断文件是否存在
    if (exist) {
        [[NSFileManager defaultManager] removeItemAtURL:url error:&error];
        NSLog(@"file delected");
        if (error) {
            NSLog(@"file remove error - %@", error.localizedDescription);
        }
    } else {
        NSLog(@"no file by that time");
    }
}
- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    
    [self.player pause];
    
    NSLog(@"%@", videoPath);
    
    if (error) {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Video Saving Failed" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Video Saved" message:@"Save To Photo Album" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    }
}
////////////////////////////////////////////////////////////////////////
#pragma mark - Actions
////////////////////////////////////////////////////////////////////////
- (void)didClickNextButton {
    [MBProgressHUD xy_hideHUD];
    [MBProgressHUD xy_showActivityMessage:@"奋力处理中..."];
    [self exportVideoWithPressName:AVAssetExportPreset1280x720];
}

- (void)didClickBackButton {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)dealloc {

    NSLog(@"%s", __func__);
    [self pause];
    _player = nil;
}
@end
