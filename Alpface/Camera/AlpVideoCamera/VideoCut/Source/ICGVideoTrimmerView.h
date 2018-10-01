//
//  ICGVideoTrimmerView.h
//  ICGVideoTrimmer
//
//  Created by Huong Do on 1/18/15.
//  Copyright (c) 2015 ichigo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@protocol ICGVideoTrimmerDelegate;

NS_ASSUME_NONNULL_BEGIN

@interface ICGVideoTrimmerView : UIView

@property (strong, nonatomic) UIColor *leftOverlayViewColor;
@property (strong, nonatomic) UIColor *rightOverlayViewColor;

// Video to be trimmed 要修剪的视频
@property (strong, nonatomic, nullable) AVAsset *asset;

// Theme color for the trimmer view 修剪器视图的主题颜色
@property (strong, nonatomic) UIColor *themeColor;

// Maximum length for the trimmed video 修剪视频的最大长度
@property (assign, nonatomic) CGFloat maxLength;

// Minimum length for the trimmed video 修剪视频的最小长度
@property (assign, nonatomic) CGFloat minLength;

// Show ruler view on the trimmer view or not 不显示修剪器视图上的标尺视图
@property (assign, nonatomic) BOOL showsRulerView;

// Customize color for tracker 自定义跟踪器的颜色
@property (assign, nonatomic) UIColor *trackerColor;

// Custom image for the left thumb 左侧拇指的自定义图像
@property (strong, nonatomic, nullable) UIImage *leftThumbImage;

// Custom image for the right thumb 右侧拇指的自定义图像
@property (strong, nonatomic, nullable) UIImage *rightThumbImage;

// Custom width for the top and bottom borders 顶部和底部边框的自定义宽度
@property (assign, nonatomic) CGFloat borderWidth;

// Custom width for thumb 自定义宽度的拇指
@property (assign, nonatomic) CGFloat thumbWidth;
// 视频修剪代理
@property (weak, nonatomic, nullable) id<ICGVideoTrimmerDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithAsset:(nullable AVAsset *)asset;

- (instancetype)initWithFrame:(CGRect)frame asset:(nullable AVAsset *)asset NS_DESIGNATED_INITIALIZER;

+ (instancetype)thrimmerViewWithAsset:(nullable AVAsset *)asset;

// 修剪到时间
- (void)seekToTime:(CGFloat)startTime;

// 隐藏跟踪器
- (void)hideTracker:(BOOL)flag;

@end

NS_ASSUME_NONNULL_END

@protocol ICGVideoTrimmerDelegate <NSObject>

// 当左侧开始时间的位置或右侧结束时间的位置发生改变时调用
- (void)trimmerView:(nonnull ICGVideoTrimmerView *)trimmerView didChangeLeftPosition:(CGFloat)startTime rightPosition:(CGFloat)endTime;

@end


