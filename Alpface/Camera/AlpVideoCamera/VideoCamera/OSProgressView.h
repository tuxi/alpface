//
//  OSProgressView.h
//  ProgressBarDemo
//
//  Created by alpface on 15/08/2017.
//  Copyright © 2017 alpface. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OSProgressView : UIImageView

@property (nonatomic, strong) UIImageView *progressBar;

@property (nonatomic, assign) CGFloat progress;

@property (nonatomic, strong) UIColor *progressTintColor;

@property (nonatomic, strong) UIColor *trackTintColor;

@property (nonatomic, assign) CGFloat progressHeight;

- (instancetype)initWithFrame:(CGRect)frame;

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated;

- (void)cancelProgress;

- (void)finishProgress;

@end
