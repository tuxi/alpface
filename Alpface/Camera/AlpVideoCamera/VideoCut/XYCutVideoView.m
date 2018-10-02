//
//  XYCutVideoView.m
//  XYVideoCut
//
//  Created by xiaoyuan on 16/11/14.
//  Copyright © 2016年 alpface. All rights reserved.
//

#import "XYCutVideoView.h"

@implementation XYCutVideoView

- (instancetype)initWithFrame:(CGRect)frame {

    if (self = [super initWithFrame:frame]) {
        
        XYVideoPlayerView *videoPlayerView = [[XYVideoPlayerView alloc] init];
        videoPlayerView.backgroundColor = [UIColor clearColor];
        [self addSubview:videoPlayerView];
        self.videoPlayerView = videoPlayerView;
        
        ICGVideoTrimmerView *cutView = [ICGVideoTrimmerView thrimmerViewWithAsset:nil];
        [self addSubview:cutView];
        cutView.showsRulerView = YES;
        self.cutView = cutView;
        cutView.rightOverlayViewColor = [UIColor clearColor];
        cutView.leftOverlayViewColor = [UIColor clearColor];
        
        self.videoPlayerView.translatesAutoresizingMaskIntoConstraints = NO;
        self.cutView.translatesAutoresizingMaskIntoConstraints = NO;
        [NSLayoutConstraint constraintWithItem:_videoPlayerView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0].active = YES;
        [NSLayoutConstraint constraintWithItem:_videoPlayerView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0].active = YES;
        [NSLayoutConstraint constraintWithItem:_videoPlayerView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0].active = YES;
        [NSLayoutConstraint constraintWithItem:_videoPlayerView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0].active = YES;
        
        if (@available(iOS 11.0, *)) {
            [NSLayoutConstraint constraintWithItem:_cutView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.safeAreaLayoutGuide attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-10.0].active = YES;
            [NSLayoutConstraint constraintWithItem:_cutView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.safeAreaLayoutGuide attribute:NSLayoutAttributeLeading multiplier:1.0 constant:30.0].active = YES;
            [NSLayoutConstraint constraintWithItem:_cutView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.safeAreaLayoutGuide attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:-30.0].active = YES;
        } else {
            [NSLayoutConstraint constraintWithItem:_cutView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-10.0].active = YES;
            [NSLayoutConstraint constraintWithItem:_cutView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1.0 constant:30.0].active = YES;
            [NSLayoutConstraint constraintWithItem:_cutView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:-30.0].active = YES;
        }
        [NSLayoutConstraint constraintWithItem:_cutView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:60.0].active = YES;
    }
    return self;
}

- (void)dealloc {

    NSLog(@"%s", __func__);
}
@end
