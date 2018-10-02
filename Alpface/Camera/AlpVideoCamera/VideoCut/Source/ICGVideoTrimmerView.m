//
//  ICGVideoTrimmerView.m
//  ICGVideoTrimmer
//
//  Created by Huong Do on 1/18/15.
//  Copyright (c) 2015 ichigo. All rights reserved.
//

#import "ICGVideoTrimmerView.h"
#import "ICGThumbView.h"
#import "ICGRulerView.h"

@interface ICGVideoTrimmerView() <UIScrollViewDelegate>

@property (strong, nonatomic) UIView *contentView;
@property (strong, nonatomic) UIView *frameView;
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) AVAssetImageGenerator *imageGenerator;

@property (strong, nonatomic) UIView *leftOverlayView;
@property (strong, nonatomic) UIView *rightOverlayView;
@property (strong, nonatomic) ICGThumbView *leftThumbView;
@property (strong, nonatomic) ICGThumbView *rightThumbView;

@property (strong, nonatomic) UIView *trackerView;
@property (strong, nonatomic) UIView *topBorder;
@property (strong, nonatomic) UIView *bottomBorder;

@property (nonatomic) CGFloat startTime;
@property (nonatomic) CGFloat endTime;

@property (nonatomic) CGFloat widthPerSecond;

@property (nonatomic) CGPoint leftStartPoint;
@property (nonatomic) CGPoint rightStartPoint;
@property (nonatomic) CGFloat overlayWidth;

@property (nonatomic, strong) ICGRulerView *rulerView;

@end

@implementation ICGVideoTrimmerView


#pragma mark - Initiation

- (instancetype)initWithFrame:(CGRect)frame
{
    NSAssert(NO, nil);
    @throw nil;
}


+ (instancetype)thrimmerViewWithAsset:(AVAsset *)asset {

    return [[self alloc] initWithAsset:asset];
}


- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder
{
    return [super initWithCoder:aDecoder];
}

- (instancetype)initWithAsset:(AVAsset *)asset
{
    return [self initWithFrame:CGRectZero asset:asset];
}

- (instancetype)initWithFrame:(CGRect)frame asset:(AVAsset *)asset
{
    self = [super initWithFrame:frame];
    if (self) {
        if (asset) {
            _asset = asset;
//            [self resetSubviews];
        }
    }
    return self;
}


#pragma mark - Private methods

- (UIColor *)themeColor
{
    return _themeColor ?: [UIColor lightGrayColor];
}

- (CGFloat)maxLength
{
    return _maxLength ?: 15;
}

- (CGFloat)minLength
{
    return _minLength ?: 3;
}

- (UIColor *)trackerColor
{
    return _trackerColor ?: [UIColor whiteColor];
}

- (CGFloat)borderWidth
{
    return _borderWidth ?: 1;
}

- (CGFloat)thumbWidth
{
    return _thumbWidth ?: 10;
}

- (UIColor *)leftOverlayViewColor {
    
    return _leftOverlayViewColor ?: [UIColor colorWithWhite:0 alpha:0.8];
}

- (UIColor *)rightOverlayViewColor {
    
    return _rightOverlayViewColor ?: [UIColor colorWithWhite:0 alpha:0.8];
}

- (void)setBounds:(CGRect)bounds {
    CGRect oldBounds = self.bounds;
    
    [super setBounds:bounds];
    
    if(!CGRectEqualToRect(oldBounds, bounds) && self.superview) {
        [self resetSubviews];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];

}

/// 重置子视图，当bounds发生改变时会重置子视图，
/// 以便适应autolayout或者frame的布局，对于屏幕旋转时bounds发生改变进行处理
- (void)resetSubviews
{
    self.clipsToBounds = YES;

//    [self setBackgroundColor:[UIColor blackColor]];

//    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
//    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    // 更新布局
    self.scrollView.frame = self.bounds;
    self.contentView.frame = self.bounds;
    [self.scrollView setContentSize:self.contentView.frame.size];

    
    CGFloat ratio = self.showsRulerView ? 0.7 : 1.0;
    self.frameView.frame = CGRectMake(self.thumbWidth, 0, CGRectGetWidth(self.contentView.frame)-2*self.thumbWidth, CGRectGetHeight(self.contentView.frame)*ratio);
    
    // 添加每一帧的视频作为图片展示在frameView上
    [self addFrames];
    
    if (self.showsRulerView) {
        CGRect rulerFrame = CGRectMake(0, CGRectGetHeight(self.contentView.frame)*0.7, CGRectGetWidth(self.contentView.frame)+self.thumbWidth, CGRectGetHeight(self.contentView.frame)*0.3);
        self.rulerView.frame = rulerFrame;
    }
    else {
        [_rulerView removeFromSuperview];
        _rulerView = nil;
    }
    // add borders
//    self.topBorder = [[UIView alloc] init];
//    [self.topBorder setBackgroundColor:self.themeColor];
//    [self addSubview:self.topBorder];
//
//    self.bottomBorder = [[UIView alloc] init];
//    [self.bottomBorder setBackgroundColor:self.themeColor];
//    [self addSubview:self.bottomBorder];
    
    // width for left and right overlay views
    self.overlayWidth =  CGRectGetWidth(self.frame) - (self.minLength * self.widthPerSecond);

    // add left overlay view
    self.leftOverlayView.frame = CGRectMake(self.thumbWidth - self.overlayWidth, 0, self.overlayWidth, CGRectGetHeight(self.frameView.frame));
    CGRect leftThumbFrame = CGRectMake(self.overlayWidth-self.thumbWidth, 0, self.thumbWidth, CGRectGetHeight(self.frameView.frame));
    self.leftThumbView.frame = leftThumbFrame;
    self.leftThumbView.isRight = NO;
    if (self.leftThumbImage) {
        self.leftThumbView.thumbImage = self.leftThumbImage;
        self.leftThumbView.color = nil;
    } else {
        self.leftThumbView.color = self.themeColor;
    }
    
    self.trackerView.frame = CGRectMake(self.thumbWidth, -5, 3, CGRectGetHeight(self.frameView.frame) + 10);
    self.trackerView.backgroundColor = self.trackerColor;
    [self bringSubviewToFront:self.trackerView];

    [self.leftOverlayView setBackgroundColor:self.leftOverlayViewColor];
    

    // add right overlay view
    CGFloat rightViewFrameX = CGRectGetWidth(self.frameView.frame) < CGRectGetWidth(self.frame) ? CGRectGetMaxX(self.frameView.frame) : CGRectGetWidth(self.frame) - self.thumbWidth;
    self.rightOverlayView.frame = CGRectMake(rightViewFrameX, 0, self.overlayWidth, CGRectGetHeight(self.frameView.frame));
    self.rightThumbView.frame = CGRectMake(0, 0, self.thumbWidth, CGRectGetHeight(self.frameView.frame));
    if (self.rightThumbImage) {
        self.rightThumbView.thumbImage = self.rightThumbImage;
        self.rightThumbView.color = nil;
        
    } else {
        self.rightThumbView.color = self.themeColor;
        self.rightThumbView.isRight = YES;
    }
    [self.rightOverlayView setBackgroundColor:self.rightOverlayViewColor];
    
    
    [self updateBorderFrames];
    [self notifyDelegate];
}

- (void)updateBorderFrames
{
    CGFloat height = self.borderWidth;
    [self.topBorder setFrame:CGRectMake(CGRectGetMaxX(self.leftOverlayView.frame), 0, CGRectGetMinX(self.rightOverlayView.frame)-CGRectGetMaxX(self.leftOverlayView.frame), height)];
    [self.bottomBorder setFrame:CGRectMake(CGRectGetMaxX(self.leftOverlayView.frame), CGRectGetHeight(self.frameView.frame)-height, CGRectGetMinX(self.rightOverlayView.frame)-CGRectGetMaxX(self.leftOverlayView.frame), height)];
}

- (void)moveLeftOverlayView:(UIPanGestureRecognizer *)gesture
{
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
            self.leftStartPoint = [gesture locationInView:self];
            break;
        case UIGestureRecognizerStateChanged:
        {
            CGPoint point = [gesture locationInView:self];
            
            int deltaX = point.x - self.leftStartPoint.x;
            
            CGPoint center = self.leftOverlayView.center;
            
            CGFloat newLeftViewMidX = center.x += deltaX;;
            CGFloat maxWidth = CGRectGetMinX(self.rightOverlayView.frame) - (self.minLength * self.widthPerSecond);
            CGFloat newLeftViewMinX = newLeftViewMidX - self.overlayWidth/2;
            if (newLeftViewMinX < self.thumbWidth - self.overlayWidth) {
                newLeftViewMidX = self.thumbWidth - self.overlayWidth + self.overlayWidth/2;
            } else if (newLeftViewMinX + self.overlayWidth > maxWidth) {
                newLeftViewMidX = maxWidth - self.overlayWidth / 2;
            }
            
            self.leftOverlayView.center = CGPointMake(newLeftViewMidX, self.leftOverlayView.center.y);
            self.leftStartPoint = point;
            [self updateBorderFrames];
            [self notifyDelegate];
            
            break;
        }
            
        default:
            break;
    }
    
    
}

- (void)moveRightOverlayView:(UIPanGestureRecognizer *)gesture
{
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
            self.rightStartPoint = [gesture locationInView:self];
            break;
        case UIGestureRecognizerStateChanged:
        {
            CGPoint point = [gesture locationInView:self];
            
            int deltaX = point.x - self.rightStartPoint.x;
            
            CGPoint center = self.rightOverlayView.center;
            
            CGFloat newRightViewMidX = center.x += deltaX;
            CGFloat minX = CGRectGetMaxX(self.leftOverlayView.frame) + self.minLength * self.widthPerSecond;
            CGFloat maxX = CMTimeGetSeconds([self.asset duration]) <= self.maxLength + 0.5 ? CGRectGetMaxX(self.frameView.frame) : CGRectGetWidth(self.frame) - self.thumbWidth;
            if (newRightViewMidX - self.overlayWidth/2 < minX) {
                newRightViewMidX = minX + self.overlayWidth/2;
            } else if (newRightViewMidX - self.overlayWidth/2 > maxX) {
                newRightViewMidX = maxX + self.overlayWidth/2;
            }
            
            self.rightOverlayView.center = CGPointMake(newRightViewMidX, self.rightOverlayView.center.y);
            self.rightStartPoint = point;
            [self updateBorderFrames];
            [self notifyDelegate];
            
            break;
        }
            
        default:
            break;
    }
}

- (void)seekToTime:(CGFloat) time
{    
    CGFloat posToMove = time * self.widthPerSecond + self.thumbWidth - self.scrollView.contentOffset.x;
    
    CGRect trackerFrame = self.trackerView.frame;
    trackerFrame.origin.x = posToMove;
    self.trackerView.frame = trackerFrame;
    
}

- (void)hideTracker:(BOOL)flag
{
    self.trackerView.hidden = flag;
}

- (void)notifyDelegate
{
    CGFloat start = CGRectGetMaxX(self.leftOverlayView.frame) / self.widthPerSecond + (self.scrollView.contentOffset.x -self.thumbWidth) / self.widthPerSecond;
    if (!self.trackerView.hidden && start != self.startTime) {
        [self seekToTime:start];
    }
    self.startTime = start;
    self.endTime = CGRectGetMinX(self.rightOverlayView.frame) / self.widthPerSecond + (self.scrollView.contentOffset.x - self.thumbWidth) / self.widthPerSecond;
    [self.delegate trimmerView:self didChangeLeftPosition:self.startTime rightPosition:self.endTime];
}

- (void)addFrames
{
    [self.frameView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    self.imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:self.asset];
    self.imageGenerator.appliesPreferredTrackTransform = YES;
    if ([self isRetina]){
        self.imageGenerator.maximumSize = CGSizeMake(CGRectGetWidth(self.frameView.frame)*2, CGRectGetHeight(self.frameView.frame)*2);
    } else {
        self.imageGenerator.maximumSize = CGSizeMake(CGRectGetWidth(self.frameView.frame), CGRectGetHeight(self.frameView.frame));
    }
    
    CGFloat picWidth = 0;
    
    // First image
    NSError *error;
    CMTime actualTime;
    CGImageRef halfWayImage = [self.imageGenerator copyCGImageAtTime:kCMTimeZero actualTime:&actualTime error:&error];
    UIImage *videoScreen;
    if ([self isRetina]){
        videoScreen = [[UIImage alloc] initWithCGImage:halfWayImage scale:2.0 orientation:UIImageOrientationUp];
    } else {
        videoScreen = [[UIImage alloc] initWithCGImage:halfWayImage];
    }
    if (halfWayImage != NULL) {
        UIImageView *tmp = [[UIImageView alloc] initWithImage:videoScreen];
        CGRect rect = tmp.frame;
        rect.size.width = videoScreen.size.width;
        tmp.frame = rect;
        [self.frameView addSubview:tmp];
        [self layoutIfNeeded];
        
        
        picWidth = tmp.frame.size.width;
        CGImageRelease(halfWayImage);
    }
    
    Float64 duration = CMTimeGetSeconds([self.asset duration]);
    CGFloat screenWidth = CGRectGetWidth(self.frame) - 2*self.thumbWidth; // quick fix to make up for the width of thumb views
    NSInteger actualFramesNeeded;
    
    CGFloat frameViewFrameWidth = (duration / self.maxLength) * screenWidth;
    [self.frameView setFrame:CGRectMake(self.thumbWidth, 0, frameViewFrameWidth, CGRectGetHeight(self.frameView.frame))];
    CGFloat contentViewFrameWidth = CMTimeGetSeconds([self.asset duration]) <= self.maxLength + 0.5 ? screenWidth + 30 : frameViewFrameWidth;
    [self.contentView setFrame:CGRectMake(0, 0, contentViewFrameWidth, CGRectGetHeight(self.contentView.frame))];
    [self.scrollView setContentSize:self.contentView.frame.size];
    NSInteger minFramesNeeded = screenWidth / picWidth + 1;
    actualFramesNeeded =  (duration / self.maxLength) * minFramesNeeded + 1;
    
    Float64 durationPerFrame = duration / (actualFramesNeeded*1.0);
    self.widthPerSecond = frameViewFrameWidth / duration;
    
    int preferredWidth = 0;
    NSMutableArray *times = [[NSMutableArray alloc] init];
    for (int i=1; i<actualFramesNeeded; i++){
        
        CMTime time = CMTimeMakeWithSeconds(i*durationPerFrame, 600);
        [times addObject:[NSValue valueWithCMTime:time]];
        
        UIImageView *tmp = [[UIImageView alloc] initWithImage:videoScreen];
        tmp.tag = i;
        
        CGRect currentFrame = tmp.frame;
        currentFrame.origin.x = i*picWidth;
        
        currentFrame.size.width = picWidth;
        preferredWidth += currentFrame.size.width;
        
        if( i == actualFramesNeeded-1){
            currentFrame.size.width-=6;
        }
        tmp.frame = currentFrame;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.frameView addSubview:tmp];
        });
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @autoreleasepool {
            for (int i=1; i<=[times count]; i++) {
                CMTime time = [((NSValue *)[times objectAtIndex:i-1]) CMTimeValue];
                
                CGImageRef halfWayImage = [self.imageGenerator copyCGImageAtTime:time actualTime:NULL error:NULL];
                
                UIImage *videoScreen;
                if ([self isRetina]){
                    videoScreen = [[UIImage alloc] initWithCGImage:halfWayImage scale:2.0 orientation:UIImageOrientationUp];
                } else {
                    videoScreen = [[UIImage alloc] initWithCGImage:halfWayImage];
                }
                
                CGImageRelease(halfWayImage);
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIImageView *imageView = (UIImageView *)[self.frameView viewWithTag:i];
                    [imageView setImage:videoScreen];
                    
                });
            }
        }
    });
}

- (BOOL)isRetina
{
    return ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] &&
            ([UIScreen mainScreen].scale > 1.0));
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (CMTimeGetSeconds([self.asset duration]) <= self.maxLength + 0.5) {
        [UIView animateWithDuration:0.3 animations:^{
            [scrollView setContentOffset:CGPointZero];
        }];
    }
    [self notifyDelegate];
}


////////////////////////////////////////////////////////////////////////
#pragma mark - lazy
////////////////////////////////////////////////////////////////////////

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [UIScrollView new];
        [self addSubview:_scrollView];
        [_scrollView setDelegate:self];
        [_scrollView setShowsHorizontalScrollIndicator:NO];
        [_scrollView addSubview:self.contentView];
    }
    return _scrollView;
}

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    return _contentView;
}

- (UIView *)frameView {
    if (!_frameView) {
        _frameView = [[UIView alloc] initWithFrame:CGRectZero];
        [_frameView.layer setMasksToBounds:YES];
        [self.contentView addSubview:_frameView];
    }
    return _frameView;
}

- (ICGRulerView *)rulerView {
    if (!_rulerView) {
        _rulerView = [[ICGRulerView alloc] initWithFrame:CGRectZero widthPerSecond:self.widthPerSecond themeColor:self.themeColor];
        [self.contentView addSubview:_rulerView];
        
    }
    return _rulerView;
}
- (UIView *)topBorder {
    if (!_topBorder) {
        _topBorder = [[UIView alloc] init];
        [_topBorder setBackgroundColor:self.themeColor];
        [self addSubview:_topBorder];
    }
    return _topBorder;
}

- (UIView *)bottomBorder {
    if (!_bottomBorder) {
        _bottomBorder = [[UIView alloc] init];
        [_bottomBorder setBackgroundColor:self.themeColor];
        [self addSubview:_bottomBorder];
    }
    return _bottomBorder;
}

- (UIView *)leftOverlayView {
    if (!_leftOverlayView) {
        _leftOverlayView = [[UIView alloc] initWithFrame:CGRectZero];
        [self addSubview:_leftOverlayView];
        UIPanGestureRecognizer *leftPanGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveLeftOverlayView:)];
        [_leftOverlayView addGestureRecognizer:leftPanGestureRecognizer];
        [_leftOverlayView addSubview:self.leftThumbView];
        [_leftOverlayView setUserInteractionEnabled:YES];
    }
    return _leftOverlayView;
}

- (ICGThumbView *)leftThumbView {
    if (!_leftThumbView) {
        _leftThumbView = [[ICGThumbView alloc] init];
        [_leftThumbView.layer setMasksToBounds:YES];
        _leftThumbView.clipsToBounds = YES;
    }
    return _leftThumbView;
}

- (UIView *)trackerView {
    if (!_trackerView) {
        _trackerView = [[UIView alloc] initWithFrame:CGRectZero];
        _trackerView.layer.masksToBounds = true;
        _trackerView.layer.cornerRadius = 2;
        [self addSubview:_trackerView];
    }
    return _trackerView;
}

- (UIView *)rightOverlayView {
    if (!_rightOverlayView) {
        _rightOverlayView = [[UIView alloc] initWithFrame:CGRectZero];
        [self addSubview:_rightOverlayView];
        [_rightOverlayView addSubview:self.rightThumbView];
        [_rightOverlayView setUserInteractionEnabled:YES];
        UIPanGestureRecognizer *rightPanGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveRightOverlayView:)];
        [_rightOverlayView addGestureRecognizer:rightPanGestureRecognizer];
    }
    return _rightOverlayView;
}

- (ICGThumbView *)rightThumbView {
    if (!_rightThumbView) {
        _rightThumbView = [[ICGThumbView alloc] initWithFrame:CGRectZero];
        [_rightThumbView.layer setMasksToBounds:YES];
        _rightThumbView.clipsToBounds = YES;
    }
    return _rightThumbView;
}
@end
