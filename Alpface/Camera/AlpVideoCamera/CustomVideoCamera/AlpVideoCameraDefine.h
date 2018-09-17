//
//  AlpVideoCameraDefine.h
//  AlpVideoCamera
//
//  Created by swae on 2018/9/15.
//  Copyright © 2018 xiaoyuan. All rights reserved.
//

#ifndef AlpVideoCameraDefine_h
#define AlpVideoCameraDefine_h

#define VIDEO_FOLDER @"videoFolder"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define TIMER_INTERVAL 0.05
#define SCREEN_LayoutScaleBaseOnIPHEN6(x) (([UIScreen mainScreen].bounds.size.width)/375.00 * x)
#define kSignatureContextLengths 20

#define COLOR_FONT_LIGHTGRAY 0x999999
#define COLOR_LINEVIEW_DARKGRAY  0x666666
#define COLOR_BACKBG_DARKGRAY 0x666666
#define COLOR_FONT_YELLOW 0xFDD854
#define COLOR_FONT_WHITE 0xFFFFFF

/// 需要发布视频的通知
static NSNotificationName const AlpPublushVideoNotification = @"AlpPublushVideoNotification";
/// 关闭相机
static NSNotificationName const AlpVideoCameraCloseNotification = @"AlpVideoCameraCloseNotification";
/// 允许录制视频的最大时间
static NSTimeInterval const AlpVideoRecordingMaxTime = 20.0;


#endif /* AlpVideoCameraDefine_h */
