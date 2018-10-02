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

@property (nonatomic) BOOL isRight;
@property (strong, nonatomic, nullable) UIImage *thumbImage;


@end

NS_ASSUME_NONNULL_END
