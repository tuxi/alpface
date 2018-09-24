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
/// 选择的视频最大支持的大小,MB
static CGFloat const AlpVideoCameraMaxVideoSize = 8.0;
static CGFloat const TIMER_INTERVAL = 0.05;

static NSString * const AlpContentTextFieldPlaceholder = @"点击添加描述(最多20个字)";

// 判断机型是否为 iPhone X、XR、XS、XS Max 的方法
// 原理是根据手机底部安全区的高度 判断是否为 iPhone X、XR、XS、XS Max 几款机型
#define kIPHONE_X (@available(iOS 11.0, *) ? [[[UIApplication sharedApplication] delegate] window].safeAreaInsets.bottom > 0.0 : NO )

//判断是否是ipad
#define isPad ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
//判断iPhone4系列
#define kiPhone4 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 960), [[UIScreen mainScreen] currentMode].size) && !isPad : NO)
//判断iPhone5系列
#define kiPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) && !isPad : NO)
//判断iPhone6系列
#define kiPhone6 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(750, 1334), [[UIScreen mainScreen] currentMode].size) && !isPad : NO)
//判断iphone6+系列
#define kiPhone6Plus ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2208), [[UIScreen mainScreen] currentMode].size) && !isPad : NO)
//判断iPhoneX
#define IS_IPHONE_X ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) && !isPad : NO)
//判断iPHoneXr
#define IS_IPHONE_Xr ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(828, 1792), [[UIScreen mainScreen] currentMode].size) && !isPad : NO)
//判断iPhoneXs
#define IS_IPHONE_Xs ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) && !isPad : NO)
//判断iPhoneXs Max
#define IS_IPHONE_Xs_Max ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2688), [[UIScreen mainScreen] currentMode].size) && !isPad : NO)

//iPhoneX系列
#define k_Height_NavContentBar 44.0f
#define k_Height_StatusBar ((IS_IPHONE_X==YES || IS_IPHONE_Xr ==YES || IS_IPHONE_Xs== YES || IS_IPHONE_Xs_Max== YES) ? 44.0 : 20.0)
#define k_Height_NavBar ((IS_IPHONE_X==YES || IS_IPHONE_Xr ==YES || IS_IPHONE_Xs== YES || IS_IPHONE_Xs_Max== YES) ? 88.0 : 64.0)
#define k_Height_TabBar ((IS_IPHONE_X==YES || IS_IPHONE_Xr ==YES || IS_IPHONE_Xs== YES || IS_IPHONE_Xs_Max== YES) ? 83.0 : 49.0)

#endif /* AlpVideoCameraDefine_h */
