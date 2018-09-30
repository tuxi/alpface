//
//  ICGVideoTrimmerLeftOverlay.h
//  ICGVideoTrimmer
//
//  Created by Huong Do on 1/19/15.
//  Copyright (c) 2015 ichigo. All rights reserved.
//  拇指视图

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ICGThumbView : UIView

@property (strong, nonatomic, nullable) UIColor *color;

- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE; // 不可用

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithFrame:(CGRect)frame color:(UIColor *)color right:(BOOL)flag NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithFrame:(CGRect)frame thumbImage:(UIImage *)image NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
