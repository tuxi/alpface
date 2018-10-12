//
//  AlpEditCoverViewController.m
//  Alpface
//
//  Created by xiaoyuan on 2018/9/27.
//  Copyright © 2018 alpface. All rights reserved.
//

#import "AlpEditCoverViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "AlpVideoCameraUtils.h"
#import "UIImage+AlpExtensions.h"
#import "AlpVideoCameraCoverSlider.h"
#import "AlpEditPublishViewController.h"
#import "AlpEditVideoNavigationBar.h"

// 底部显示的个数
#define PHOTO_COUNT  6
#define COLLECTION_VIEW_LEFT 20

@interface AlpVideoCameraCoverPlayerView : UIView


@end

@interface AlpCoverImageCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *imageView;

@end

@interface AlpEditCoverViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>
@property(nonatomic,strong)AlpVideoCameraCoverPlayerView *coverPlayerView;
@property(nonatomic,strong)UICollectionView *coverImageCollectionView;
///照片数组
@property (nonatomic, strong) NSMutableArray<AlpVideoCameraCover *> *photoArrays;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;
@property (nonatomic, strong) AlpVideoCameraCoverSlider *slider;
@property (nonatomic, assign) CMTime coverTime;
@property (nonatomic, assign) CMTime videoTime;

@property (nonatomic, strong) AVPlayer *mainPlayer;
@property (nonatomic, strong) AVPlayerItem *playerItem;

@property (nonatomic, strong) AVPlayer *thumbPlayer;
@property (nonatomic, strong) AVPlayerItem *thumbPlayerItem;
@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, assign) CGFloat videoPlaybackPosition;
@property (nonatomic, strong) AlpEditVideoNavigationBar *navigationBar;

@end

@implementation AlpEditCoverViewController

- (void)dealloc {
    
    NSLog(@"%s", __func__);
    [_mainPlayer pause];
    _mainPlayer = nil;
    [_thumbPlayer pause];
    _thumbPlayer = nil;
    [self stopReplayTimer];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor blackColor];
    self.photoArrays = [[NSMutableArray alloc] init];
    [self setupUI];
    [self getVideoTotalValueAndScale];
}

- (void)setupNavigationBar {
    // 禁止系统手势
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    self.navigationController.navigationBarHidden = YES;
    AlpEditVideoNavigationBar *headerBar = [[AlpEditVideoNavigationBar alloc] init];
    _navigationBar = headerBar;
    [headerBar.rightButton setTitle:@"确定" forState:UIControlStateNormal];
    [headerBar.leftButton setTitle:@"取消" forState:UIControlStateNormal];
    [headerBar.leftButton setImage:nil forState:UIControlStateNormal];
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

- (void)setupUI {
    [self setupNavigationBar];
    // 选定的封面
    _coverPlayerView = [[AlpVideoCameraCoverPlayerView alloc] init];
    _coverPlayerView.clipsToBounds  = YES;
    [self.view addSubview:_coverPlayerView];
    _coverPlayerView.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint constraintWithItem:_coverPlayerView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:35.0].active = YES;
    [NSLayoutConstraint constraintWithItem:_coverPlayerView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0].active = YES;
    [NSLayoutConstraint constraintWithItem:_coverPlayerView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.navigationBar attribute:NSLayoutAttributeBottom multiplier:1.0 constant:10.0].active = YES;
    
    UILabel *label = [[UILabel alloc] init];
    label.backgroundColor = [UIColor blackColor];
    label.textColor = [UIColor whiteColor];
    label.text = @"已选封面";
    label.numberOfLines = 0;
    label.textAlignment = NSTextAlignmentLeft;
    label.font = [UIFont systemFontOfSize:14];
    [self.view addSubview:label];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:20.0].active = YES;
    [NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_coverPlayerView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:10.0].active = YES;
    [NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:20.0].active = YES;
    [self.view addSubview:self.coverImageCollectionView];
    _coverImageCollectionView.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint constraintWithItem:self.coverImageCollectionView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:COLLECTION_VIEW_LEFT].active = YES;
    [NSLayoutConstraint constraintWithItem:self.coverImageCollectionView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:label attribute:NSLayoutAttributeBottom multiplier:1.0 constant:10.0].active = YES;
    if (@available(iOS 11.0, *)) {
        [NSLayoutConstraint constraintWithItem:self.coverImageCollectionView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view.safeAreaLayoutGuide attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0].active = YES;
    } else {
        [NSLayoutConstraint constraintWithItem:self.coverImageCollectionView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0].active = YES;
    }
    [NSLayoutConstraint constraintWithItem:self.coverImageCollectionView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:-COLLECTION_VIEW_LEFT].active = YES;
    [NSLayoutConstraint constraintWithItem:self.coverImageCollectionView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:80.0].active = YES;
    
    
    AlpVideoCameraCoverSlider *slider = [[AlpVideoCameraCoverSlider alloc] init];
    [self.view addSubview:slider];
    slider.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint constraintWithItem:slider attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.coverImageCollectionView attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0].active = YES;
    [NSLayoutConstraint constraintWithItem:slider attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.coverImageCollectionView attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0].active = YES;
    [NSLayoutConstraint constraintWithItem:slider attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.coverImageCollectionView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0].active = YES;
    [NSLayoutConstraint constraintWithItem:slider attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.coverImageCollectionView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0].active = YES;
    
    _slider = slider;
    [slider addTarget:self action:@selector(slidValueChange:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:slider];
    
    [self setupPlayer];
    
}

- (void)setupPlayer {
    _mainPlayer = [[AVPlayer alloc] init];
    _playerItem = [[AVPlayerItem alloc] initWithURL:_videoURL];
    [_mainPlayer replaceCurrentItemWithPlayerItem:_playerItem];
    _mainPlayer.volume = 0; // 静音
    AVPlayerLayer *playerLayer = (id)_coverPlayerView.layer;
    playerLayer.player = _mainPlayer;
    playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    _thumbPlayer = [[AVPlayer alloc] init];
    _thumbPlayerItem = [[AVPlayerItem alloc] initWithURL:_videoURL];
    [_thumbPlayer replaceCurrentItemWithPlayerItem:_thumbPlayerItem];
    _thumbPlayer.volume = 0; // 静音
    AVPlayerLayer *thumbPlayerLayer = (id)_slider.rangeThumbView.layer;
    thumbPlayerLayer.player = _thumbPlayer;
    thumbPlayerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [_thumbPlayer pause];
    [self play];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
    [self play];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onApplicationWillResignActive) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onApplicationDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self pause];
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
////////////////////////////////////////////////////////////////////////

- (void)getVideoTotalValueAndScale {
    
    [AlpVideoCameraUtils getCoversByVideoURL:self.videoURL photoCount:PHOTO_COUNT callBack:^(CMTime time, NSArray<AlpVideoCameraCover *> * _Nonnull images, NSError * _Nonnull error) {
        
        [self.photoArrays removeAllObjects];
        [self.photoArrays addObjectsFromArray:images];
        
    }];
}

- (void)setupVideoCover {
    // 初始化videoTime，选择默认的cover
    if (self.videoTime.value == 0) {
        // 将总的time转换为当前player的timescale相同的time
        CMTime time = self.playerItem.duration;
        CMTimeScale scale = self.mainPlayer.currentTime.timescale;
        CMTime newTime = CMTimeConvertScale(time, scale, kCMTimeRoundingMethod_RoundTowardZero);
        self.videoTime = newTime;
        self.coverTime = CMTimeMake(0, scale);
        AlpVideoCameraCoverSliderRange range = AlpVideoCameraCoverSliderMakeRange(0, self.videoTime.value/self.photoArrays.count);
        self.slider.maximumValue = self.videoTime.value;
        self.slider.range = range;
        // 默认选择第一帧
        [self chooseWithTime:0];
    }
}

- (void)play {
    [_mainPlayer play];
    [self startReplayTimer];
}

- (void)pause {
    [_mainPlayer pause];
    [self stopReplayTimer];
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Notification methods
////////////////////////////////////////////////////////////////////////

- (void)onApplicationWillResignActive {
    [self pause];
}

- (void)onApplicationDidBecomeActive {
    if (self.navigationController.topViewController == self) {
        [self play];
    }
}


////////////////////////////////////////////////////////////////////////
#pragma mark - 视频播放时间的检测
////////////////////////////////////////////////////////////////////////
- (void)stopReplayTimer {
    if (self.displayLink) {
        [self.displayLink invalidate];
        self.displayLink = nil;
    }
}

- (void)startReplayTimer {
    
    [self stopReplayTimer]; // 停止检测
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(onReplayTimer)];
    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)onReplayTimer {
    //    CMTimeShow(self.mainPlayer.currentTime);
    CMTime currentTime = self.mainPlayer.currentTime;
    if (currentTime.value <= 0) {
        return;
    }
    [self setupVideoCover];
    CGFloat replayPosition = CMTimeGetSeconds(currentTime);
    CGFloat startSeconds = CMTimeGetSeconds(self.coverTime);
    CMTime stopTime = CMTimeMake(AlpVideoCameraCoverSliderMaxRange(self.slider.range), self.coverTime.timescale);
    CGFloat stopSeconds = CMTimeGetSeconds(stopTime);
    // 当视频播放完后，重置开始时间
    if (replayPosition >= stopSeconds) {
        [self seekVideoToPos:startSeconds];
    }
}

- (void)seekVideoToPos:(CGFloat)pos {
    
    CMTime time = CMTimeMakeWithSeconds(pos, self.coverTime.timescale);
    [self.mainPlayer seekToTime:time toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    [self.thumbPlayer seekToTime:time toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    [self.mainPlayer play];
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Actions
////////////////////////////////////////////////////////////////////////

- (void)slidValueChange:(AlpVideoCameraCoverSlider *)slider {
    
    NSInteger timeValue = slider.range.location;
    
    [self chooseWithTime:timeValue];
}


- (void)chooseWithTime:(CMTimeValue)value {
    CMTime coverTime = CMTimeMake(value, self.videoTime.timescale);
    self.coverTime = coverTime;
    CGFloat start = CMTimeGetSeconds(coverTime);
    [self seekVideoToPos:start];
}

- (void)setCoverTime:(CMTime)coverTime {
    _coverTime = coverTime;
    if (self.delegate && [self.delegate respondsToSelector:@selector(editCoverViewController:didChangeCoverWithStartTime:endTime:)]) {
        CMTime stopTime = CMTimeMake(AlpVideoCameraCoverSliderMaxRange(self.slider.range), self.coverTime.timescale);
        CGFloat startSeconds = CMTimeGetSeconds(coverTime);
        CGFloat stopSeconds = CMTimeGetSeconds(stopTime);
        [self.delegate editCoverViewController:self
                   didChangeCoverWithStartTime:startSeconds
                                       endTime:stopSeconds];
    }
}

- (void)didClickNextButton {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didClickBackButton {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark-collectionview

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return _photoArrays.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    AlpCoverImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AlpCoverImageCollectionViewCell" forIndexPath:indexPath];
    
    cell.imageView.image = _photoArrays[indexPath.item].firstFrameImage;
    return cell;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Getter
////////////////////////////////////////////////////////////////////////

- (UICollectionView *)coverImageCollectionView {
    if (!_coverImageCollectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        CGFloat width = ([UIScreen mainScreen].bounds.size.width - COLLECTION_VIEW_LEFT*2)/PHOTO_COUNT;
        flowLayout.itemSize = CGSizeMake(width, 80);
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        flowLayout.sectionInset = UIEdgeInsetsMake(0, 0,0 ,0 );
        flowLayout.minimumInteritemSpacing = 0;
        flowLayout.minimumLineSpacing = 0;
        _coverImageCollectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _coverImageCollectionView.backgroundColor = [UIColor blackColor];
        _coverImageCollectionView.showsVerticalScrollIndicator = NO;
        _coverImageCollectionView.showsHorizontalScrollIndicator = NO;
        [_coverImageCollectionView registerClass:[AlpCoverImageCollectionViewCell class] forCellWithReuseIdentifier:@"AlpCoverImageCollectionViewCell"];
        _coverImageCollectionView.delegate = self;
        _coverImageCollectionView.dataSource = self;
        
    }
    return _coverImageCollectionView;
}


@end

@implementation AlpCoverImageCollectionViewCell
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor blackColor];
        _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds  = YES;
        [self.contentView addSubview:_imageView];
        _imageView.translatesAutoresizingMaskIntoConstraints = NO;
        [NSLayoutConstraint constraintWithItem:_imageView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0].active = YES;
        [NSLayoutConstraint constraintWithItem:_imageView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0].active = YES;
        [NSLayoutConstraint constraintWithItem:_imageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0].active = YES;
        [NSLayoutConstraint constraintWithItem:_imageView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0].active = YES;
        [self.imageView.layer setMasksToBounds:YES];
        self.imageView.layer.borderColor = [UIColor whiteColor].CGColor;
    }
    return self;
}

@end

@implementation AlpVideoCameraCoverPlayerView

+ (Class)layerClass {
    return [AVPlayerLayer class];
}

@end
