//
//  XYCutVideoView.h
//  XYVideoCut
//
//  Created by xiaoyuan on 16/11/14.
//  Copyright © 2016年 alpface. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ICGVideoTrimmerView.h"
#import "XYVideoPlayerView.h"

NS_ASSUME_NONNULL_BEGIN
@interface XYCutVideoView : UIView

@property (nonatomic, weak) XYVideoPlayerView *videoPlayerView;
@property (nonatomic, weak) ICGVideoTrimmerView *cutView;

@end
NS_ASSUME_NONNULL_END
