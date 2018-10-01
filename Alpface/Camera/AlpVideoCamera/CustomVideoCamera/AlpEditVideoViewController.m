//
//  AlpEditVideoViewController.m
//  AlpVideoCamera
//
//  Created by xiaoyuan on 2018/9/13.
//  Copyright © 2018 xiaoyuan. All rights reserved.
//

#import "AlpEditVideoViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "AlpMusicItemCollectionViewCell.h"
#import "SDAVAssetExportSession.h"
#import "GPUImage.h"
#import "LFGPUImageEmptyFilter.h"
#import "AlpEditPublishViewController.h"
#import "AlpVideoCameraDefine.h"
#import "AlpVideoCameraResourceItem.h"
#import "AlpEditVideoBar.h"
#import "AlpEditVideoNavigationBar.h"
#import "AlpEditVideoParameter.h"
#import "AlpEditCoverViewController.h"
#import "MBProgressHUD+XYHUD.h"

@interface AlpEditVideoViewController () <UITextFieldDelegate, AlpEditVideoBarDelegate>

@property (nonatomic, strong) AVPlayer *audioPlayer;
@property (nonatomic, strong) AlpEditVideoBar *editVideoBar;
@property (nonatomic, strong) UIButton *musicBtn;
@property (nonatomic, strong) NSString *filtClassName;
@property (nonatomic, assign) BOOL isdoing;
@property (nonatomic, strong) AlpVideoCameraResourceItem *resourceItem;
@property (nonatomic, strong) GPUImageView *filterView;
@property (nonatomic, assign) float saturationValue;
@property (nonatomic, strong) UIImageView *stickersImgView;
@property (nonatomic, weak) NSLayoutConstraint *editVideoBarBottomConstraint;
@property (nonatomic, copy) NSString *showActivityMessage;
//@property (nonatomic, assign) BOOL isPlaying;

@end

@implementation AlpEditVideoViewController {
    GPUImageMovie *_movieFile;
    GPUImageMovie *_endMovieFile;
    GPUImageOutput<GPUImageInput> *_filter;
    
    AVPlayerItem *_audioPlayerItem;
    
    AVPlayer *_mainPlayer;
    AVPlayerLayer *_playerLayer;
    AVPlayerItem *_playerItem;
    GPUImageMovieWriter *_movieWriter;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = YES;
    _resourceItem = [AlpVideoCameraResourceItem new];
    
    _audioPlayer = [[AVPlayer alloc ]init];

    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionMixWithOthers error:nil];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    _mainPlayer = [[AVPlayer alloc] init];
    _playerItem = [[AVPlayerItem alloc] initWithURL:_videoURL];
    [_mainPlayer replaceCurrentItemWithPlayerItem:_playerItem];
    _playerLayer = [AVPlayerLayer playerLayerWithPlayer:_mainPlayer];
    _playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    _movieFile = [[GPUImageMovie alloc] initWithPlayerItem:_playerItem];
    _movieFile.runBenchmark = YES;
    _movieFile.playAtActualSpeed = YES;
    
    _filter = [[LFGPUImageEmptyFilter alloc] init];
    
    _filtClassName = @"LFGPUImageEmptyFilter";
    [_movieFile addTarget:_filter];
    // 创建摄像头显示视图
    _filterView = [[GPUImageView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_filterView];
    [_filter addTarget:_filterView];
    _filterView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;

    _stickersImgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 150, 150)];
    _stickersImgView.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2);
    _stickersImgView.hidden = YES;
    [self.view addSubview:_stickersImgView];
    [_stickersImgView setUserInteractionEnabled:YES];
    [_stickersImgView setMultipleTouchEnabled:YES];
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panView:)];
    [_stickersImgView addGestureRecognizer:panGestureRecognizer];
    
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnVideoPlayerView)];
//    [self.view addGestureRecognizer:tap];
    [self setupUI];
}

- (void)setupUI {
    AlpEditVideoNavigationBar *headerBar = [[AlpEditVideoNavigationBar alloc] init];
    [headerBar.rightButton setTitle:@"下一步" forState:UIControlStateNormal];
    headerBar.titleLabel.text = @"编辑";
    [headerBar.rightButton addTarget:self action:@selector(didClickNextButton) forControlEvents:UIControlEventTouchUpInside];
    [headerBar.leftButton addTarget:self action:@selector(didClickBackButton) forControlEvents:UIControlEventTouchUpInside];
    headerBar.backgroundColor = [UIColor clearColor];
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
    
    _editVideoBar = [AlpEditVideoBar new];
    _editVideoBar.delegate = self;
    _editVideoBar.resourceItem = _resourceItem;
    [self.view addSubview:_editVideoBar];
    _editVideoBar.translatesAutoresizingMaskIntoConstraints = false;
    NSLayoutConstraint *editVideoBarBottomConstraint = editVideoBarBottomConstraint = [NSLayoutConstraint constraintWithItem:_editVideoBar attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0];
    editVideoBarBottomConstraint.active = YES;
    _editVideoBarBottomConstraint = editVideoBarBottomConstraint;
    [NSLayoutConstraint constraintWithItem:_editVideoBar attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0].active = YES;
    [NSLayoutConstraint constraintWithItem:_editVideoBar attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0].active = YES;
    
    UIButton *editCoverButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [editCoverButton setTitle:@"编辑封面" forState:UIControlStateNormal];
    [self.view addSubview:editCoverButton];
    editCoverButton.translatesAutoresizingMaskIntoConstraints = NO;
    editCoverButton.backgroundColor = [UIColor blackColor];
    [editCoverButton addTarget:self action:@selector(editCoverClick) forControlEvents:UIControlEventTouchUpInside];
    [NSLayoutConstraint constraintWithItem:editCoverButton attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0].active = YES;
    [NSLayoutConstraint constraintWithItem:editCoverButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0].active = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self pause];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNeedsStatusBarAppearanceUpdate];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_mainPlayer play];
        [_movieFile startProcessing];
        [self playMusic];
    });
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playingEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onApplicationWillResignActive) name:UIApplicationWillResignActiveNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onApplicationDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)pause {
    [_audioPlayer pause];
    [_mainPlayer pause];
    [_movieFile endProcessing];
}

- (void)compressVideoWithInputVideoUrl:(NSURL *) inputVideoUrl {
    /* Create Output File Url */
    NSString *documentsDirectory = NSTemporaryDirectory();
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMddHHmmss";
    NSString *nowTimeStr = [formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0]];
    NSString *finalVideoURLString = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"compressedVideo%@.mp4",nowTimeStr]];
    NSURL *outputVideoUrl = ([[NSURL URLWithString:finalVideoURLString] isFileURL] == 1)?([NSURL URLWithString:finalVideoURLString]):([NSURL fileURLWithPath:finalVideoURLString]); // Url Should be a file Url, so here we check and convert it into a file Url
    NSDictionary* options = @{AVURLAssetPreferPreciseDurationAndTimingKey:@YES};
    AVAsset* asset = [AVURLAsset URLAssetWithURL:inputVideoUrl options:options];
    NSArray* keys = @[@"tracks",@"duration",@"commonMetadata"];
    __weak typeof(self) weakSelf = self;
    [asset loadValuesAsynchronouslyForKeys:keys completionHandler:^{
        SDAVAssetExportSession *compressionEncoder = [SDAVAssetExportSession.alloc initWithAsset:asset]; // provide inputVideo Url Here
        compressionEncoder.outputFileType = AVFileTypeMPEG4;
        compressionEncoder.outputURL = outputVideoUrl; //Provide output video Url here
        compressionEncoder.videoSettings = @
        {
        AVVideoCodecKey: AVVideoCodecH264,
        AVVideoWidthKey: @720,   //Set your resolution width here
        AVVideoHeightKey: @1280,  //set your resolution height here
        AVVideoCompressionPropertiesKey: @{
                //2000*1000  建议800*1000-5000*1000
                //AVVideoAverageBitRateKey: @2500000, // Give your bitrate here for lower size give low values
            AVVideoAverageBitRateKey: @(weakSelf.videoOptions.bitRate),
            AVVideoProfileLevelKey: AVVideoProfileLevelH264HighAutoLevel,
            AVVideoAverageNonDroppableFrameRateKey: @(weakSelf.videoOptions.frameRate),
            },
        };
        compressionEncoder.audioSettings = @{
        AVFormatIDKey: @(kAudioFormatMPEG4AAC),
        AVNumberOfChannelsKey: @2,
        AVSampleRateKey: @44100,
        AVEncoderBitRateKey: @128000,
        };
        [compressionEncoder exportAsynchronouslyWithCompletionHandler:^{
             dispatch_async(dispatch_get_main_queue(), ^{
                 //更新UI操作
                 //.....
                 if (compressionEncoder.status == AVAssetExportSessionStatusCompleted) {
                     dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                         [MBProgressHUD xy_hideHUD];
                         [[NSNotificationCenter defaultCenter] removeObserver:self];
                         AlpEditPublishViewController* cor = [[AlpEditPublishViewController alloc] init];
                         cor.videoURL = compressionEncoder.outputURL;
                         [self.navigationController pushViewController:cor animated:YES];
                         
                     });
                     
                 } else if (compressionEncoder.status == AVAssetExportSessionStatusCancelled) {
                     [MBProgressHUD xy_showMessage:@"Compression Failed" delayTime:1.5];
                     dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                         [[NSNotificationCenter defaultCenter] removeObserver:self];
                         //                         [[NSNotificationCenter defaultCenter] postNotificationName:kTabBarHiddenNONotification object:self];
                         [self.navigationController popToRootViewControllerAnimated:YES];
                         
                     });
                 } else {
                     [MBProgressHUD xy_showMessage:@"Compression Failed" delayTime:1.5];
                     dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                         [[NSNotificationCenter defaultCenter] removeObserver:self];
                         //                         [[NSNotificationCenter defaultCenter] postNotificationName:kTabBarHiddenNONotification object:self];
                         [self.navigationController popToRootViewControllerAnimated:YES];
                     });
                 }
             });
         }];
    }];
}



- (void)mixFiltWithVideoAndInputVideoURL:(NSURL*)inputURL {
    self.showActivityMessage = @"滤镜合成中...";
    _isdoing = YES;
    NSURL *sampleURL = inputURL;
    _endMovieFile = [[GPUImageMovie alloc] initWithURL:sampleURL];
    _endMovieFile.runBenchmark = YES;
    _endMovieFile.playAtActualSpeed = NO;
    
    GPUImageOutput<GPUImageInput> *endFilter;
    if ([_filtClassName isEqualToString:@"GPUImageSaturationFilter"]) {
        GPUImageSaturationFilter* xxxxfilter = [[NSClassFromString(_filtClassName) alloc] init];
        xxxxfilter.saturation = _saturationValue;
        endFilter = xxxxfilter;
        
    }else{
        endFilter = [[NSClassFromString(_filtClassName) alloc] init];
    }
    
    
    
    [_endMovieFile addTarget:endFilter];
    
    
    NSString *pathToMovie = [NSHomeDirectory() stringByAppendingPathComponent:@"tmp/Movie.mp4"];
    unlink([pathToMovie UTF8String]); // If a file already exists, AVAssetWriter won't let you record new frames, so delete the old movie
    NSURL *movieURL = [NSURL fileURLWithPath:pathToMovie];
    
    _movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:CGSizeMake(720.0, 1280.0)];
    [endFilter  addTarget:_movieWriter];
    _movieWriter.shouldPassthroughAudio = YES;
    _endMovieFile.audioEncodingTarget = _movieWriter;
    [_endMovieFile enableSynchronizedEncodingUsingMovieWriter:_movieWriter];
    [_movieWriter startRecording];
    [_endMovieFile startProcessing];
    __weak GPUImageMovieWriter *weakmovieWriter = _movieWriter;
    //    __weak MBProgressHUD *weakHUD = HUD;
    typeof(self) __weak weakself = self;
    [_movieWriter setCompletionBlock:^{
        [endFilter removeTarget:weakmovieWriter];
        [weakmovieWriter finishRecording];
        if (weakself.editVideoBar.audioPath||!weakself.stickersImgView.hidden) {
            [weakself mixAudioAndVidoWithInputURL:movieURL];
            //音乐混合
        }
        else {
            //压缩
            [weakself compressVideoWithInputVideoUrl:movieURL];
        }
        
        
        
    }];
}

- (void)mixAudioAndVidoWithInputURL:(NSURL*)inputURL; {
    
    if (self.editVideoBar.audioPath) {
        [self mixAudioAndVidoWithInputURL2:inputURL];
    }
    else {
        [self mixAudioAndVidoWithInputURL1:inputURL];
    }
    
}

// 没有音乐
- (void)mixAudioAndVidoWithInputURL1:(NSURL*)inputURL {
    
    // 路径
    self.showActivityMessage = @"贴纸合成中...";
    NSString *documents = [NSHomeDirectory() stringByAppendingPathComponent:@"tmp"];
    
    
    // 视频来源
    
    NSURL *videoInputUrl = inputURL;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMddHHmmss";
    NSString *nowTimeStr = [formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0]];
    NSString *fileName = [[documents stringByAppendingPathComponent:nowTimeStr] stringByAppendingString:@"merge.mp4"];
    
    
    
    //    NSURL *outputFileUrl = [NSURL fileURLWithPath:outPutFilePath];
    NSURL *outputFileUrl = [NSURL fileURLWithPath:fileName];
    
    // 时间起点
    
    CMTime nextClistartTime = kCMTimeZero;
    
    // 创建可变的音视频组合
    
    AVMutableComposition *comosition = [AVMutableComposition composition];
    
    // 视频采集
    NSDictionary* options = @{AVURLAssetPreferPreciseDurationAndTimingKey:@YES};
    AVURLAsset *videoAsset = [[AVURLAsset alloc] initWithURL:videoInputUrl options:options];
    
    // 视频时间范围
    
    CMTimeRange videoTimeRange = CMTimeRangeMake(kCMTimeZero, videoAsset.duration);
    
    // 视频通道 枚举 kCMPersistentTrackID_Invalid = 0
    
    AVMutableCompositionTrack *videoTrack = [comosition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    
    // 视频采集通道
    
    AVAssetTrack *videoAssetTrack = [[videoAsset tracksWithMediaType:AVMediaTypeVideo] firstObject];
    
    //  把采集轨道数据加入到可变轨道之中
    
    [videoTrack insertTimeRange:videoTimeRange ofTrack:videoAssetTrack atTime:nextClistartTime error:nil];
    
    
    
    // 因为视频短这里就直接用视频长度了,如果自动化需要自己写判断
    
    CMTimeRange audioTimeRange = videoTimeRange;
    
    AVMutableCompositionTrack *audioTrack2 = [comosition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    AVAssetTrack *audioAssetTrack2 = [[videoAsset tracksWithMediaType:AVMediaTypeAudio] firstObject];
    [audioTrack2 insertTimeRange:audioTimeRange ofTrack:audioAssetTrack2 atTime:nextClistartTime error:nil];
    
    //视频贴图
    CGSize videoSize = [videoTrack naturalSize];
    CALayer* aLayer = [CALayer layer];
    UIImage* waterImg = _stickersImgView.image;
    aLayer.contents = (id)waterImg.CGImage;
    float bili = 720/SCREEN_WIDTH;
    aLayer.frame = CGRectMake(_stickersImgView.frame.origin.x * bili,1280 - _stickersImgView.frame.origin.y *bili - 150*bili, 150*bili, 150*bili);
    aLayer.opacity = 1;
    
    CALayer *parentLayer = [CALayer layer];
    CALayer *videoLayer = [CALayer layer];
    parentLayer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
    videoLayer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
    [parentLayer addSublayer:videoLayer];
    [parentLayer addSublayer:aLayer];
    AVMutableVideoComposition* videoComp = [AVMutableVideoComposition videoComposition];
    videoComp.renderSize = videoSize;
    
    
    videoComp.frameDuration = CMTimeMake(1, 30);
    videoComp.animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
    AVMutableVideoCompositionInstruction* instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    
    instruction.timeRange = CMTimeRangeMake(kCMTimeZero, [comosition duration]);
    AVAssetTrack* mixVideoTrack = [[comosition tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    AVMutableVideoCompositionLayerInstruction* layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:mixVideoTrack];
    instruction.layerInstructions = [NSArray arrayWithObject:layerInstruction];
    videoComp.instructions = [NSArray arrayWithObject: instruction];
    
    // 创建一个输出
    
    AVAssetExportSession *assetExport = [[AVAssetExportSession alloc] initWithAsset:comosition presetName:AVAssetExportPreset1280x720];
    
    assetExport.videoComposition = videoComp;
    //    assetExport.audioMix = mutableAudioMix;
    // 输出类型
    
    assetExport.outputFileType = AVFileTypeMPEG4;
    
    // 输出地址
    
    assetExport.outputURL = outputFileUrl;
    
    // 优化
    
    assetExport.shouldOptimizeForNetworkUse = YES;
    
    // 合成完毕
    
    [assetExport exportAsynchronouslyWithCompletionHandler:^{
        
        // 回到主线程
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self compressVideoWithInputVideoUrl:outputFileUrl];
            
        });
    }];
}

//有音乐
- (void)mixAudioAndVidoWithInputURL2:(NSURL*)inputURL; {
    
    //    audio529
    
    // 路径
    self.showActivityMessage = @"音乐合成中...";
    NSString *documents = [NSHomeDirectory() stringByAppendingPathComponent:@"tmp"];
    
    // 声音来源
    
    //    NSURL *audioInputUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"audio529" ofType:@"mp3"]];
    
    NSURL *audioInputUrl = [NSURL fileURLWithPath:self.editVideoBar.audioPath];
    
    // 视频来源
    
    NSURL *videoInputUrl = inputURL;
    
    // 最终合成输出路径
    
    //    NSString *outPutFilePath = [documents stringByAppendingPathComponent:@"videoandoudio.mov"];
    
    // 添加合成路径
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMddHHmmss";
    NSString *nowTimeStr = [formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0]];
    NSString *fileName = [[documents stringByAppendingPathComponent:nowTimeStr] stringByAppendingString:@"merge.mp4"];
    
    
    
    //    NSURL *outputFileUrl = [NSURL fileURLWithPath:outPutFilePath];
    NSURL *outputFileUrl = [NSURL fileURLWithPath:fileName];
    
    // 时间起点
    
    CMTime nextClistartTime = kCMTimeZero;
    
    // 创建可变的音视频组合
    
    AVMutableComposition *comosition = [AVMutableComposition composition];
    
    // 视频采集
    NSDictionary* options = @{AVURLAssetPreferPreciseDurationAndTimingKey:@YES};
    AVURLAsset *videoAsset = [[AVURLAsset alloc] initWithURL:videoInputUrl options:options];
    
    // 视频时间范围
    
    CMTimeRange videoTimeRange = CMTimeRangeMake(kCMTimeZero, videoAsset.duration);
    
    // 视频通道 枚举 kCMPersistentTrackID_Invalid = 0
    
    AVMutableCompositionTrack *videoTrack = [comosition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    
    // 视频采集通道
    
    AVAssetTrack *videoAssetTrack = [[videoAsset tracksWithMediaType:AVMediaTypeVideo] firstObject];
    
    //  把采集轨道数据加入到可变轨道之中
    
    [videoTrack insertTimeRange:videoTimeRange ofTrack:videoAssetTrack atTime:nextClistartTime error:nil];
    
    // 声音采集
    
    AVURLAsset *audioAsset = [[AVURLAsset alloc] initWithURL:audioInputUrl options:options];
    
    // 因为视频短这里就直接用视频长度了,如果自动化需要自己写判断
    
    CMTimeRange audioTimeRange = videoTimeRange;
    
    // 音频通道
    
    AVMutableCompositionTrack *audioTrack = [comosition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    
    // 音频采集通道
    
    AVAssetTrack *audioAssetTrack = [[audioAsset tracksWithMediaType:AVMediaTypeAudio] firstObject];
    
    // 加入合成轨道之中
    
    [audioTrack insertTimeRange:audioTimeRange ofTrack:audioAssetTrack atTime:nextClistartTime error:nil];
    
    
    
    /*
     //调整视频音量
     AVMutableAudioMix *mutableAudioMix = [AVMutableAudioMix audioMix];
     // Create the audio mix input parameters object.
     AVMutableAudioMixInputParameters *mixParameters = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:audioTrack];
     // Set the volume ramp to slowly fade the audio out over the duration of the composition.
     //    [mixParameters setVolumeRampFromStartVolume:1.f toEndVolume:0.f timeRange:CMTimeRangeMake(kCMTimeZero, mutableComposition.duration)];
     [mixParameters setVolume:.05f atTime:kCMTimeZero];
     // Attach the input parameters to the audio mix.
     mutableAudioMix.inputParameters = @[mixParameters];
     */
    
    
    // 原音频轨道
    //    AVMutableCompositionTrack *audioTrack2 = [comosition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    //     AVAssetTrack *audioAssetTrack2 = [[videoAsset tracksWithMediaType:AVMediaTypeAudio] firstObject];
    //    [audioTrack2 insertTimeRange:audioTimeRange ofTrack:audioAssetTrack2 atTime:nextClistartTime error:nil];
    
    
    if (!self.editVideoBar.isUseOriginalSound) {
        AVMutableAudioMix *mutableAudioMix = [AVMutableAudioMix audioMix];
        // Create the audio mix input parameters object.
        AVMutableAudioMixInputParameters *mixParameters = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:audioTrack];
        // Set the volume ramp to slowly fade the audio out over the duration of the composition.
        //    [mixParameters setVolumeRampFromStartVolume:1.f toEndVolume:0.f timeRange:CMTimeRangeMake(kCMTimeZero, mutableComposition.duration)];
        [mixParameters setVolume:.5f atTime:kCMTimeZero];
        // Attach the input parameters to the audio mix.
        mutableAudioMix.inputParameters = @[mixParameters];
        
        AVMutableCompositionTrack *audioTrack2 = [comosition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        AVAssetTrack *audioAssetTrack2 = [[videoAsset tracksWithMediaType:AVMediaTypeAudio] firstObject];
        [audioTrack2 insertTimeRange:audioTimeRange ofTrack:audioAssetTrack2 atTime:nextClistartTime error:nil];
        
        
        //视频贴图
        CGSize videoSize = [videoTrack naturalSize];
        CALayer* aLayer = [CALayer layer];
        UIImage* waterImg = _stickersImgView.image;
        aLayer.contents = (id)waterImg.CGImage;
        
        float bili = 720/SCREEN_WIDTH;
        
        
        aLayer.frame = CGRectMake(_stickersImgView.frame.origin.x * bili,1280 - _stickersImgView.frame.origin.y *bili - 150*bili, 150*bili, 150*bili);
        aLayer.opacity = 1;
        
        CALayer *parentLayer = [CALayer layer];
        CALayer *videoLayer = [CALayer layer];
        parentLayer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
        videoLayer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
        [parentLayer addSublayer:videoLayer];
        [parentLayer addSublayer:aLayer];
        AVMutableVideoComposition* videoComp = [AVMutableVideoComposition videoComposition];
        videoComp.renderSize = videoSize;
        
        
        videoComp.frameDuration = CMTimeMake(1, 30);
        videoComp.animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
        AVMutableVideoCompositionInstruction* instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
        
        instruction.timeRange = CMTimeRangeMake(kCMTimeZero, [comosition duration]);
        AVAssetTrack* mixVideoTrack = [[comosition tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
        AVMutableVideoCompositionLayerInstruction* layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:mixVideoTrack];
        instruction.layerInstructions = [NSArray arrayWithObject:layerInstruction];
        videoComp.instructions = [NSArray arrayWithObject: instruction];
        
        AVAssetExportSession *assetExport = [[AVAssetExportSession alloc] initWithAsset:comosition presetName:AVAssetExportPreset1280x720];
        
        assetExport.audioMix = mutableAudioMix;
        
        assetExport.videoComposition = videoComp;
        // 输出类型
        
        assetExport.outputFileType = AVFileTypeMPEG4;
        
        // 输出地址
        
        assetExport.outputURL = outputFileUrl;
        
        // 优化
        
        assetExport.shouldOptimizeForNetworkUse = YES;
        
        // 合成完毕
        
        [assetExport exportAsynchronouslyWithCompletionHandler:^{
            
            // 回到主线程
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self compressVideoWithInputVideoUrl:outputFileUrl];
                
            });
        }];
    }
    else {
        
        //视频贴图
        CGSize videoSize = [videoTrack naturalSize];
        CALayer* aLayer = [CALayer layer];
        UIImage* waterImg = _stickersImgView.image;
        aLayer.contents = (id)waterImg.CGImage;
        float bili = 720/SCREEN_WIDTH;
        aLayer.frame = CGRectMake(_stickersImgView.frame.origin.x * bili,1280 - _stickersImgView.frame.origin.y *bili - 150*bili, 150*bili, 150*bili);
        aLayer.opacity = 1;
        
        CALayer *parentLayer = [CALayer layer];
        CALayer *videoLayer = [CALayer layer];
        parentLayer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
        videoLayer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
        [parentLayer addSublayer:videoLayer];
        [parentLayer addSublayer:aLayer];
        AVMutableVideoComposition* videoComp = [AVMutableVideoComposition videoComposition];
        videoComp.renderSize = videoSize;
        
        
        videoComp.frameDuration = CMTimeMake(1, 30);
        videoComp.animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
        AVMutableVideoCompositionInstruction* instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
        
        instruction.timeRange = CMTimeRangeMake(kCMTimeZero, [comosition duration]);
        AVAssetTrack* mixVideoTrack = [[comosition tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
        AVMutableVideoCompositionLayerInstruction* layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:mixVideoTrack];
        instruction.layerInstructions = [NSArray arrayWithObject:layerInstruction];
        videoComp.instructions = [NSArray arrayWithObject: instruction];
        
        // 创建一个输出
        
        AVAssetExportSession *assetExport = [[AVAssetExportSession alloc] initWithAsset:comosition presetName:AVAssetExportPreset1280x720];
        
        assetExport.videoComposition = videoComp;
        //    assetExport.audioMix = mutableAudioMix;
        // 输出类型
        
        assetExport.outputFileType = AVFileTypeMPEG4;
        
        // 输出地址
        
        assetExport.outputURL = outputFileUrl;
        
        // 优化
        
        assetExport.shouldOptimizeForNetworkUse = YES;
        
        // 合成完毕
        
        [assetExport exportAsynchronouslyWithCompletionHandler:^{
            
            // 回到主线程
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self compressVideoWithInputVideoUrl:outputFileUrl];
                
            });
        }];
        
    }

}


- (void)showEditMusicBar:(UIButton*)sender {
    if (!sender.selected) {
        sender.selected = YES;
        _editVideoBarBottomConstraint.constant = 0.0;
        // 更新约束
        [UIView animateWithDuration:.3 animations:^{
            [self.view layoutIfNeeded];
        }];
    }
    else {
        _editVideoBarBottomConstraint.constant = 160.0;
        // 更新约束
        [UIView animateWithDuration:.3 animations:^{
            [self.view layoutIfNeeded];
        }];
        sender.selected = NO;
    }
}

- (void)playMusic {
    // 路径
    if (self.editVideoBar.audioPath == nil) {
        return;
    }
    NSURL *audioInputUrl = [NSURL fileURLWithPath:self.editVideoBar.audioPath];
    // 声音来源
    _audioPlayerItem =[AVPlayerItem playerItemWithURL:audioInputUrl];
    
    [_audioPlayer replaceCurrentItemWithPlayerItem:_audioPlayerItem];
    
    [_audioPlayer play];
}


/// 重新播放
- (void)replayVideo {
    [_playerItem seekToTime:kCMTimeZero];
    [_mainPlayer play];
    if (self.editVideoBar.audioPath) {
        [_audioPlayerItem seekToTime:kCMTimeZero];
        [_audioPlayer play];
    }
}

- (void)editCoverClick {
    AlpEditCoverViewController *vc = [AlpEditCoverViewController new];
    vc.videoURL = self.videoURL;
    [self presentViewController:vc animated:YES completion:nil];
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Notification methods
////////////////////////////////////////////////////////////////////////

- (void)playingEnd:(NSNotification *)notification {
    [self replayVideo];
}

- (void)onApplicationWillResignActive {
    [_mainPlayer pause];
    [_movieFile endProcessing];
    [_audioPlayer pause];
    if (_isdoing) {
        [_movieWriter cancelRecording];
        [_endMovieFile endProcessing];
        [MBProgressHUD xy_hideHUD];
    }
}

- (void)onApplicationDidBecomeActive {
    [_playerItem seekToTime:kCMTimeZero];
    [_mainPlayer play];
    [_movieFile startProcessing];
    if (_isdoing) {
        
    }
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
////////////////////////////////////////////////////////////////////////
- (void) panView:(UIPanGestureRecognizer *)panGestureRecognizer {
    UIView *view = panGestureRecognizer.view;
    if (panGestureRecognizer.state == UIGestureRecognizerStateBegan) {
        _editVideoBar.hidden = YES;
    }
    
    if ( panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [panGestureRecognizer translationInView:view.superview];
        [view setCenter:(CGPoint){view.center.x + translation.x, view.center.y + translation.y}];
        [panGestureRecognizer setTranslation:CGPointZero inView:view.superview];
    }
    if (panGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        _editVideoBar.hidden = NO;
    }
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Actions
////////////////////////////////////////////////////////////////////////
- (void)didClickNextButton {
    [MBProgressHUD xy_showActivityMessage:@"奋力处理中..."];
    if ([_filtClassName isEqualToString:@"LFGPUImageEmptyFilter"]) {
        //无滤镜效果
        if (self.editVideoBar.audioPath||!_stickersImgView.hidden) {
            //音乐混合
            [self mixAudioAndVidoWithInputURL:_videoURL];
        }
        else {
            [self compressVideoWithInputVideoUrl:_videoURL];
            
        }
    }
    else {
        //添加滤镜效果
        [self mixFiltWithVideoAndInputVideoURL:_videoURL];
    }
}

- (void)didClickBackButton {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.navigationController popViewControllerAnimated:YES];
}

// 点按videoLayer的手势
//- (void)tapOnVideoPlayerView {
//
//    if (self.isPlaying) {
//        [_mainPlayer pause];
//    } else {
//        [_mainPlayer play];
//    }
//
//    self.isPlaying = !self.isPlaying;
//}

////////////////////////////////////////////////////////////////////////
#pragma mark - AlpEditVideoBarDelegate
////////////////////////////////////////////////////////////////////////

- (void)removeOriginalSoundForEditVideoBar:(AlpEditVideoBar *)bar {
     [_mainPlayer setVolume:0];
}

- (void)restoreOriginalSoundForEditVideoBar:(AlpEditVideoBar *)bar {
    [_mainPlayer setVolume:1];
}

- (void)editVideoBar:(AlpEditVideoBar *)bar didSelectFilter:(AlpFilterData *)filterData {
    if ([filterData.name isEqualToString:@"Empty"]) {
        [_movieFile removeAllTargets];
        
        _filtClassName = filterData.fillterName;
        _filter = [[NSClassFromString(_filtClassName) alloc] init];
        [_movieFile addTarget:_filter];
        [_filter addTarget:_filterView];
        
        
    }
    else {
        [_movieFile removeAllTargets];
        
        
        _filtClassName = filterData.fillterName;
        
        if ([filterData.fillterName isEqualToString:@"GPUImageSaturationFilter"]) {
            GPUImageSaturationFilter* xxxxfilter = [[NSClassFromString(_filtClassName) alloc] init];
            xxxxfilter.saturation = [filterData.value floatValue];
            _saturationValue = [filterData.value floatValue];
            _filter = xxxxfilter;
            
        }
        else{
            _filter = [[NSClassFromString(_filtClassName) alloc] init];
        }
        [_movieFile addTarget:_filter];
        
        // Only rotate the video for display, leave orientation the same for recording
        //            GPUImageView *filterView = (GPUImageView *)self.view;
        [_filter addTarget:_filterView];
    }
}

- (void)editVideoBar:(AlpEditVideoBar *)bar didSelectMusic:(AlpMusicData *)musicData {
    if ([musicData.name isEqualToString:@"原始"] && musicData.audioPath.length == 0) {
        [_audioPlayer pause];
        [_mainPlayer setVolume:1];
    }
    else {
        [self playMusic];
        
    }
}

- (void)editVideoBar:(AlpEditVideoBar *)bar didSelectSticker:(AlpStickersData *)stickerData {
    _stickersImgView.image = [UIImage imageWithContentsOfFile:stickerData.StickersImgPaht];
    _stickersImgView.hidden = NO;
}

- (void)dealloc {
    NSLog(@"释放了 %@", NSStringFromClass([self class]));
    [self pause];
    _movieFile = nil;
}

@end
