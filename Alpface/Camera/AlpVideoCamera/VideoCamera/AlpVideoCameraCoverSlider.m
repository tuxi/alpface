//
//  AlpVideoCameraCoverSlider.m
//  AlpVideoCameraCoverSlider
//
//  Created by xiaoyuan on 2018/9/28.
//  Copyright © 2018 xiaoyuan. All rights reserved.
//

#import "AlpVideoCameraCoverSlider.h"
#import <float.h>
#import <AVFoundation/AVFoundation.h>

@interface AlpRangeThumbView : UIView

@end

@interface AlpVideoCameraCoverSlider ()

@property (nonatomic) AlpRangeThumbView *rangeThumbView;

@property (nonatomic) NSLayoutConstraint *rangeThumbViewLeftConstraint;
@property (nonatomic) NSLayoutConstraint *rangeThumbViewWidthConstraint;
@property (nonatomic) NSMutableDictionary *runtimeAttributes;
@property (nonatomic) BOOL shouldCaptureRuntimeAttributes;

@end

@implementation AlpVideoCameraCoverSlider

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(!self) {
        return nil;
    }
    
    [self setup];
    
#if TARGET_INTERFACE_BUILDER
    
    /*
     Interface builder calls -initWithFrame: instead of -initWithCoder:
     */
    self.runtimeAttributes = [[NSMutableDictionary alloc] init];
    self.shouldCaptureRuntimeAttributes = YES;
    
#endif
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(!self) {
        return nil;
    }
    
    [self setup];
    
    self.runtimeAttributes = [[NSMutableDictionary alloc] init];
    self.shouldCaptureRuntimeAttributes = YES;
    
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self applyRuntimeAttributes];
}

- (void)prepareForInterfaceBuilder {
    [super prepareForInterfaceBuilder];
    
    [self applyRuntimeAttributes];
}

- (void)applyRuntimeAttributes {
    /*
     Apply runtime attributes in specific order
     */
    
    NSDictionary *runtimeAttributes = self.runtimeAttributes;
    
    self.runtimeAttributes = nil;
    self.shouldCaptureRuntimeAttributes = NO;
    NSValue *rangeValue = runtimeAttributes[NSStringFromSelector(@selector(range))];
    AlpVideoCameraCoverSliderRange range; // 声明一个结构体
    [rangeValue getValue:&range]; // 赋值给结构体
    NSNumber *value = runtimeAttributes[NSStringFromSelector(@selector(value))];
    
    if (rangeValue) {
        self.range = range;
        self.maximumValue = AlpVideoCameraCoverSliderMaxRange(range);
    }
    if (value) {
        self.maximumValue = value.doubleValue;
    }
}

- (void)setBounds:(CGRect)bounds {
    CGRect oldBounds = self.bounds;
    
    [super setBounds:bounds];
    
    if(!CGRectEqualToRect(oldBounds, bounds)) {
        [self setNeedsUpdateConstraints];
    }
}

- (void)updateConstraints {
    [super updateConstraints];
    
    CGFloat multiplier = self.range.location / (self.maximumValue * 1.0) ;
    CGFloat rangeLeft = self.frame.size.width * multiplier;
    self.rangeThumbViewLeftConstraint.constant = rangeLeft;
    CGFloat rangeMultiplier = self.range.length / (self.maximumValue * 1.0);
    CGFloat rangeWidth = rangeMultiplier * self.frame.size.width;
    
    self.rangeThumbViewWidthConstraint.constant = rangeWidth;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat multiplier = self.range.location / (self.maximumValue * 1.0) ;
    CGFloat rangeLeft = self.frame.size.width * multiplier;
    self.rangeThumbViewLeftConstraint.constant = rangeLeft;
    CGFloat rangeMultiplier = self.range.length / (self.maximumValue * 1.0);
    CGFloat rangeWidth = rangeMultiplier * self.frame.size.width;
    
    self.rangeThumbViewWidthConstraint.constant = rangeWidth;
}

- (void)tintColorDidChange {
    [super tintColorDidChange];
    

}

- (void)setup {
    
    _range = AlpVideoCameraCoverSliderMakeRange(0, 0.2);
    _maximumValue = 1;
    
    
    self.rangeThumbView = [[AlpRangeThumbView alloc] init];
    self.rangeThumbView.translatesAutoresizingMaskIntoConstraints = NO;
    self.rangeThumbView.userInteractionEnabled = NO;
    self.rangeThumbView.layer.cornerRadius = 2.0;
    self.rangeThumbView.layer.masksToBounds = YES;
    self.rangeThumbView.layer.borderWidth = 2.0;
    self.rangeThumbView.layer.borderColor = [UIColor redColor].CGColor;
    
    [self addSubview:self.rangeThumbView];
    
    [self.rangeThumbView.topAnchor constraintGreaterThanOrEqualToAnchor:self.topAnchor].active = YES;
    [self.rangeThumbView.bottomAnchor constraintGreaterThanOrEqualToAnchor:self.bottomAnchor].active = YES;
    [self.rangeThumbView.centerYAnchor constraintEqualToAnchor:self.centerYAnchor].active = YES;
    self.rangeThumbViewWidthConstraint = [self.rangeThumbView.widthAnchor constraintEqualToConstant:0.0];
    self.rangeThumbViewWidthConstraint.active = YES;
    
    self.rangeThumbViewLeftConstraint = [self.rangeThumbView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor];
    
    self.rangeThumbViewLeftConstraint.active = YES;
    
}

#pragma mark - Accessors
#pragma mark -


- (void)setMaximumValue:(NSInteger)maximumValue {
    if(self.shouldCaptureRuntimeAttributes) {
        self.runtimeAttributes[NSStringFromSelector(@selector(value))] = @(maximumValue);
        return;
    }
    
    if( labs(_maximumValue) < FLT_EPSILON ) {
        return;
    }
    
    _maximumValue = maximumValue;
    [self setNeedsUpdateConstraints];
}

- (void)setRange:(AlpVideoCameraCoverSliderRange)range {
    if(self.shouldCaptureRuntimeAttributes) {
        //结构体转换成对象
        
        NSValue *value = [NSValue valueWithBytes:&range objCType:@encode(AlpVideoCameraCoverSliderRange)];
        self.runtimeAttributes[NSStringFromSelector(@selector(range))] = value;
        return;
    }
    
    if( labs(range.location - _range.location) < FLT_EPSILON &&
       labs(AlpVideoCameraCoverSliderMaxRange(range) - AlpVideoCameraCoverSliderMaxRange(_range)) < FLT_EPSILON ) {
        return;
    }
    _range = range;
    
    [self setNeedsUpdateConstraints];
}


- (void)updateRangeWithTouch:(UITouch *)touch {
    // 当前手指所在的位置
    CGPoint point = [touch locationInView:self];
    // 让thumb的中心点x = 手指所在的点
    CGFloat currentX = point.x;
    // 限制手指拖动的最左侧和最后侧
    currentX = MAX(self.rangeThumbView.frame.size.width*0.5, MIN(currentX, self.frame.size.width - self.rangeThumbView.frame.size.width * 0.5));
    // rangeThumbView 的左侧距离父控件的约束值
    CGFloat rangThumbViewLeft = currentX - self.rangeThumbView.frame.size.width * 0.5;
    self.rangeThumbViewLeftConstraint.constant = rangThumbViewLeft;
    
    CGFloat multiplier = rangThumbViewLeft / self.frame.size.width;
    _range.location = multiplier * self.maximumValue;
}


//- (void)updateRangeWithTouch:(UITouch *)touch {
//    // 当前手指所在的位置
//    CGPoint point = [touch locationInView:self];
//    CGFloat currentX = point.x;
//    // 限制手指拖动的最左侧和最后侧
//    currentX = MAX(self.rangeThumbView.frame.size.width*0.5, MIN(currentX, self.frame.size.width - self.rangeThumbView.frame.size.width * 0.5));
//    // rangeThumbView 的左侧距离父控件的约束值
//    CGFloat rangThumbViewLeft = currentX - self.rangeThumbView.frame.size.width * 0.5;
//    self.rangeThumbViewLeftConstraint.constant = rangThumbViewLeft;
//
//    CGFloat multiplier = rangThumbViewLeft / self.frame.size.width;
//    _range.location = multiplier * self.value;
//    NSLog(@"%2.f", _range.location);
//}

- (void)updateWithRange:(AlpVideoCameraCoverSliderRange)range {
    
}


#pragma mark - Events handling
#pragma mark -

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    
    // 先检查是否在thumbView上面，如果在就rentun NO
    //    CGPoint pointInRangeThumbView = [touch locationInView:self.rangeThumbView];
    //    if ([self.rangeThumbView pointInside:pointInRangeThumbView withEvent:event]) {
    //        return NO;
    //    }
    
    [self updateRangeWithTouch:touch];
    [self setNeedsUpdateConstraints];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    return YES;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    
    //    // 先检查是否在thumbView上面，如果不是就rentun NO
    //    CGPoint pointInRangeThumbView = [touch locationInView:self.rangeThumbView];
    //    if (![self.rangeThumbView pointInside:pointInRangeThumbView withEvent:event]) {
    //        return NO;
    //    }
    //
    
    [self updateRangeWithTouch:touch];
    
    [self setNeedsUpdateConstraints];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    
    return YES;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    
}

- (void)cancelTrackingWithEvent:(UIEvent *)event {
    
}


@end

@implementation AlpRangeThumbView

+ (Class)layerClass {
    return [AVPlayerLayer class];
}

@end
