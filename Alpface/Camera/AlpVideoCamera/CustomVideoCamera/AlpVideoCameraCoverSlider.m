//
//  AlpVideoCameraCoverSlider.m
//  AlpVideoCameraCoverSlider
//
//  Created by xiaoyuan on 2018/9/28.
//  Copyright © 2018 xiaoyuan. All rights reserved.
//

#import "AlpVideoCameraCoverSlider.h"
#import <float.h>

static CGFloat const kShadowVerticalOffset = 1.0;

static CGFloat const kThumbDimension = 24.0;

@interface AlpVideoCameraCoverSlider ()

@property (nonatomic) UIImageView *rangeThumbView;

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
    
    CGFloat multiplier = self.range.location / self.maximumValue ;
    CGFloat rangeLeft = self.frame.size.width * multiplier;
    self.rangeThumbViewLeftConstraint.constant = rangeLeft;
    CGFloat rangeMultiplier = self.range.length / self.maximumValue;
    CGFloat rangeWidth = rangeMultiplier * self.frame.size.width;
    
    self.rangeThumbViewWidthConstraint.constant = rangeWidth;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat multiplier = self.range.location / self.maximumValue ;
    CGFloat rangeLeft = self.frame.size.width * multiplier;
    self.rangeThumbViewLeftConstraint.constant = rangeLeft;
    
    CGFloat rangeMultiplier = self.range.length / self.maximumValue;
    CGFloat rangeWidth = rangeMultiplier * self.frame.size.width;
    
    self.rangeThumbViewWidthConstraint.constant = rangeWidth;
}

- (void)tintColorDidChange {
    [super tintColorDidChange];
    
    //    [self updateThumbImages];
}

- (void)setup {
    
    _range = AlpVideoCameraCoverSliderMakeRange(0, 0.2);
    _maximumValue = 1;
    
    
    self.rangeThumbView = [[UIImageView alloc] initWithImage:nil];
    self.rangeThumbView.translatesAutoresizingMaskIntoConstraints = NO;
    self.rangeThumbView.backgroundColor = [UIColor redColor];
    
    [self addSubview:self.rangeThumbView];
    
    [self.rangeThumbView.topAnchor constraintGreaterThanOrEqualToAnchor:self.topAnchor].active = YES;
    [self.rangeThumbView.bottomAnchor constraintGreaterThanOrEqualToAnchor:self.bottomAnchor].active = YES;
    [self.rangeThumbView.centerYAnchor constraintEqualToAnchor:self.centerYAnchor].active = YES;
    self.rangeThumbViewWidthConstraint = [self.rangeThumbView.widthAnchor constraintEqualToConstant:0.0];
    self.rangeThumbViewWidthConstraint.active = YES;
    
    self.rangeThumbViewLeftConstraint = [self.rangeThumbView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor];
    
    self.rangeThumbViewLeftConstraint.active = YES;
    
    //    [self updateThumbImages];
}

#pragma mark - Accessors
#pragma mark -


- (void)setMaximumValue:(CGFloat)maximumValue {
    if(self.shouldCaptureRuntimeAttributes) {
        self.runtimeAttributes[NSStringFromSelector(@selector(value))] = @(maximumValue);
        return;
    }
    
    if( fabs(_maximumValue) < FLT_EPSILON ) {
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
    
    if( fabs(range.location - _range.location) < FLT_EPSILON &&
       fabs(AlpVideoCameraCoverSliderMaxRange(range) - AlpVideoCameraCoverSliderMaxRange(_range)) < FLT_EPSILON ) {
        return;
    }
    _range = range;
    
    [self setNeedsUpdateConstraints];
}


- (void)setThumbImage:(UIImage *)thumbImage {
    _thumbImage = thumbImage;
    self.rangeThumbView.image = thumbImage;
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
    NSLog(@"%2.f", _range.location);
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

#pragma mark - Asset generator
#pragma mark -

- (void)updateThumbImages {
    UIImage *thumbImage = self.thumbImage;
    if (!thumbImage) {
        thumbImage = [self thumbImageWithFillColor:self.tintColor];
    }
    self.rangeThumbView.image = thumbImage;
}

- (UIImage *)thumbImageWithFillColor:(UIColor *)fillColor {
    CGSize size = CGSizeMake(kThumbDimension, kThumbDimension);
    CGFloat radius = size.width * 0.5;
    CGFloat shadowBlur = 2.0;
    UIColor *shadowColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    
    size.width += shadowBlur * 2;
    size.height += shadowBlur * 2 + kShadowVerticalOffset;
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(size.width * 0.5, size.height * 0.5) radius:radius startAngle:0 endAngle:M_PI * 2 clockwise:YES];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetShadowWithColor(context, CGSizeMake(0, kShadowVerticalOffset), shadowBlur, shadowColor.CGColor);
    
    [fillColor setFill];
    [bezierPath fill];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
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
