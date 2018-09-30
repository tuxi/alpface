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
@end

@implementation AlpEditCoverViewController

- (void)dealloc {
    
    NSLog(@"%s", __func__);
    [_mainPlayer pause];
    _mainPlayer = nil;
    [_thumbPlayer pause];
    _thumbPlayer = nil;
    [self stopPlaybackTimeChecker];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor blackColor];
    self.selectedIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    self.photoArrays = [[NSMutableArray alloc] init];
    [self setupUI];
    [self getVideoTotalValueAndScale];
}
- (void)setupUI {
    
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelButton setBackgroundColor:[UIColor blackColor]];
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [cancelButton setTitle:@"取消" forState:UIControlStateSelected];
    [cancelButton setTitleColor:[UIColor whiteColor] forState:0];
    [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    cancelButton.titleLabel.font = [UIFont systemFontOfSize:16.0];
    cancelButton.tag = 1;
    [self.view addSubview:cancelButton];
    cancelButton.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint constraintWithItem:cancelButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:50.0].active = YES;
    [NSLayoutConstraint constraintWithItem:cancelButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:30.0].active = YES;
    [NSLayoutConstraint constraintWithItem:cancelButton attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:20.0].active = YES;
    [NSLayoutConstraint constraintWithItem:cancelButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:30.0].active = YES;
    
    UIButton *sureButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [sureButton setBackgroundColor:[UIColor blackColor]];
    [sureButton setTitle:@"确定" forState:UIControlStateNormal];
    [sureButton setTitle:@"确定" forState:UIControlStateSelected];
    [sureButton setTitleColor:[UIColor whiteColor] forState:0];
    [sureButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    sureButton.titleLabel.font = [UIFont systemFontOfSize:16.0];
    sureButton.tag = 2;
    [self.view addSubview:sureButton];
    sureButton.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint constraintWithItem:sureButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:50.0].active = YES;
    [NSLayoutConstraint constraintWithItem:sureButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:30.0].active = YES;
    [NSLayoutConstraint constraintWithItem:sureButton attribute:NSLayoutAttributeTrailing    relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:-20.0].active = YES;
    [NSLayoutConstraint constraintWithItem:sureButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:30.0].active = YES;
    
    [cancelButton addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
    [sureButton addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
    
    // 选定的封面
    _coverPlayerView = [[AlpVideoCameraCoverPlayerView alloc] init];
    _coverPlayerView.clipsToBounds  = YES;
    [self.view addSubview:_coverPlayerView];
    _coverPlayerView.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint constraintWithItem:_coverPlayerView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:0.6 constant:0.0].active = YES;
    [NSLayoutConstraint constraintWithItem:_coverPlayerView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:0.6 constant:0.0].active = YES;
    [NSLayoutConstraint constraintWithItem:_coverPlayerView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0].active = YES;
    [NSLayoutConstraint constraintWithItem:_coverPlayerView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:-50.0].active = YES;
    
    UILabel *label = [[UILabel alloc] init];
        label.backgroundColor = [UIColor blackColor];
    label.textColor = [UIColor whiteColor];
    label.text = @"选择封面图";
    label.numberOfLines = 0;
    label.textAlignment = NSTextAlignmentLeft;
    label.font = [UIFont systemFontOfSize:14];
    [self.view addSubview:label];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:20.0].active = YES;
    [NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-140].active = YES;
    [NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:200.0].active = YES;
    [NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:20.0].active = YES;
    [self.view addSubview:self.coverImageCollectionView];
    _coverImageCollectionView.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint constraintWithItem:self.coverImageCollectionView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:COLLECTION_VIEW_LEFT].active = YES;
    [NSLayoutConstraint constraintWithItem:self.coverImageCollectionView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-(80+34)].active = YES;
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

- (void)updateRange {
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
    [self startPlaybackTimeChecker];
}

- (void)pause {
    [_mainPlayer pause];
    [self stopPlaybackTimeChecker];
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Notification methods
////////////////////////////////////////////////////////////////////////

- (void)onApplicationWillResignActive {
    [self pause];
}

- (void)onApplicationDidBecomeActive {
    [self play];
}


////////////////////////////////////////////////////////////////////////
#pragma mark - 视频播放时间的检测
////////////////////////////////////////////////////////////////////////
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
//    CMTimeShow(self.mainPlayer.currentTime);
    CMTime currentTime = self.mainPlayer.currentTime;
    if (currentTime.value <= 0) {
        return;
    }
    [self updateRange];
    self.videoPlaybackPosition = CMTimeGetSeconds(currentTime);
    CGFloat startSeconds = CMTimeGetSeconds(self.coverTime);
    CMTime stopTime = CMTimeMake(AlpVideoCameraCoverSliderMaxRange(self.slider.range), self.coverTime.timescale);
    CGFloat stopSeconds = CMTimeGetSeconds(stopTime);
    // 当视频播放完后，重置开始时间
    if (self.videoPlaybackPosition >= stopSeconds) {
        self.videoPlaybackPosition = startSeconds;
        [self seekVideoToPos:startSeconds];
    }
}

- (void)seekVideoToPos:(CGFloat)pos {
    
    self.videoPlaybackPosition = pos;
    CMTime time = CMTimeMakeWithSeconds(self.videoPlaybackPosition, self.coverTime.timescale);
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
    CGFloat seconds = CMTimeGetSeconds(coverTime);
    [self seekVideoToPos:seconds];
}

- (void)clickButton:(UIButton *)button {
    if (button.tag == 1) {
        //取消
        [self.navigationController popViewControllerAnimated:YES];
    }
    else {
        //确定
        AlpEditPublishViewController *vc = [AlpEditPublishViewController new];
        vc.videoURL = self.videoURL;
        [self.navigationController pushViewController:vc animated:YES];
    }
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

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSIndexPath *firstSelectedIndexPath = self.selectedIndexPath;
    [collectionView deselectItemAtIndexPath:firstSelectedIndexPath animated:YES];
    
    UICollectionViewScrollPosition position = UICollectionViewScrollPositionNone;
    if (firstSelectedIndexPath.item > indexPath.item) {
        position = UICollectionViewScrollPositionRight;
    }
    else if (firstSelectedIndexPath.item < indexPath.item) {
        position = UICollectionViewScrollPositionLeft;
    }
    else {
        position = UICollectionViewScrollPositionNone;
    }
    [self.coverImageCollectionView selectItemAtIndexPath:indexPath animated:YES scrollPosition:position];
    self.selectedIndexPath = indexPath;
    [_coverImageCollectionView reloadData];
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
