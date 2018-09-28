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
@property (nonatomic, strong)  AVPlayerItem *playerItem;
@property (nonatomic, strong)  id timeObserver;

@end

@implementation AlpEditCoverViewController
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
    
    //选定的封面图
    _coverPlayerView = [[AlpVideoCameraCoverPlayerView alloc] init];
//    _coverImage.contentMode = UIViewContentModeScaleAspectFill;
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
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_mainPlayer play];
    });
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playingEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onApplicationWillResignActive) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onApplicationDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    [self addTimeObserver];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_mainPlayer pause];
    [_mainPlayer removeTimeObserver:_timeObserver];
    _timeObserver = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)getVideoTotalValueAndScale {
    
    [AlpVideoCameraUtils getCoversByVideoURL:self.videoURL photoCount:PHOTO_COUNT callBack:^(CMTime time, NSArray<AlpVideoCameraCover *> * _Nonnull images, NSError * _Nonnull error) {
        self.videoTime = time;
        self.coverTime = CMTimeMake(0, time.timescale);
        AlpVideoCameraCoverSliderRange range = AlpVideoCameraCoverSliderMakeRange(0, time.value/images.count);
        self.slider.maximumValue = time.value;
        self.slider.range = range;
        if (time.value < 1) {
            
            [self dismissViewControllerAnimated:YES completion:nil];
            return;
        }
        [self.photoArrays removeAllObjects];
        [self.photoArrays addObjectsFromArray:images];
        // 默认选择第一帧
        [self chooseWithTime:0];
    }];
}

- (void)addTimeObserver {
//    [_mainPlayer removeTimeObserver:_timeObserver];
//    // 视频播放进度
//    __weak typeof(self) weakSelf = self;
//    _timeObserver = [_mainPlayer addPeriodicTimeObserverForInterval:CMTimeMake(1, self.videoTime.timescale) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
//        NSLog(@"%lld", time.value);
//        if (time.value >= AlpVideoCameraCoverSliderMaxRange(weakSelf.slider.range)) {
//            // 当播放超出封面时，回到c封面起始位置重新播放
//            [weakSelf.mainPlayer pause];
//            [weakSelf.mainPlayer seekToTime:weakSelf.coverTime];
//            [weakSelf.mainPlayer play];
//        }
//    }];
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Notification methods
////////////////////////////////////////////////////////////////////////

- (void)playingEnd:(NSNotification *)notification {
    [self replayVideo];
}
/// 重新播放
- (void)replayVideo {
    [_playerItem seekToTime:self.coverTime];
    [_mainPlayer play];
}
- (void)onApplicationWillResignActive {
    [_mainPlayer pause];
}

- (void)onApplicationDidBecomeActive {
    [_playerItem seekToTime:self.coverTime];
    [_mainPlayer play];
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Actions
////////////////////////////////////////////////////////////////////////

- (void)slidValueChange:(AlpVideoCameraCoverSlider *)slider {
    
    CGFloat timeValue = slider.range.location;
    
    [self chooseWithTime:timeValue];
}


- (void)chooseWithTime:(CMTimeValue)value {
    CMTime coverTime = CMTimeMake(value, self.videoTime.timescale);
    self.coverTime = coverTime;
    [self addTimeObserver];
    [_playerItem seekToTime:self.coverTime];
    [_mainPlayer play];
//    [self addTimeObserver];
//    [AlpVideoCameraUtils getCoverByVideoURL:self.videoURL timeValue:value callBack:^(AlpVideoCameraCover * _Nonnull image) {
//        self.coverImage.image = image.firstFrameImage;
//    }];
    
}

- (void)clickButton:(UIButton *)button
{
    if (button.tag == 1) {
        //取消
        [self.navigationController popViewControllerAnimated:YES];
    }
    else {
        //确定
        //        PublishVideoViewController *vc = [[PublishVideoViewController alloc] init];
        //        vc.videoPath = self.videoPath;
        //        vc.coverImage = self.coverImage.image;
        //        [self.navigationController pushViewController:vc animated:YES];
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
