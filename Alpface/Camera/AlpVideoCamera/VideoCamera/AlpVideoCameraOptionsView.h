//
//  AlpVideoCameraOptionsView.h
//  Alpface
//
//  Created by swae on 2018/9/23.
//  Copyright © 2018 alpface. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AlpVideoCameraPermissionView.h"
#import "OSProgressView.h"

NS_ASSUME_NONNULL_BEGIN

/// 相机录制视频的状态
typedef NS_ENUM(NSInteger, AlpVideoCameraRecordState) {
    AlpVideoCameraRecordStateNotStart,  // 相机还未开始录制
    AlpVideoCameraRecordStateStart,     // 已经开始，正在录制中
    AlpVideoCameraRecordStatePause,     // 已经开始，录制暂停
    AlpVideoCameraRecordStateDone,      // 已经开始，录制完成
};

@interface AlpVideoCameraOptionsView : UIView 

/// 显示当前录制的时间
@property (nonatomic, strong) UIButton *timeButton;
/// 开启或暂停录制按钮
@property (nonatomic, strong) UIButton *photoCaptureButton;
/// 录制完成按钮
@property (nonatomic, strong) UIButton *cameraChangeButton;
/// 删除当前已录制的视频按钮
@property (nonatomic, strong) UIButton *deleteButton;
/// 从相册导入视频按钮
@property (nonatomic, strong) UIButton *inputLocalVieoBtn;
/// 返回按钮
@property (nonatomic, strong) UIButton *backBtn;
/// 开启关闭美颜按钮
@property (nonatomic ,strong) UIButton *camerafilterChangeButton;
/// 前后摄像头切换按钮
@property (nonatomic ,strong) UIButton *cameraPositionChangeButton;
/// 闪光灯按钮
@property (nonatomic, strong) UIButton *shootingLightingButton;
/// 录制的进度
@property (nonatomic, strong) OSProgressView *progressPreView;
/// 相机及麦克风权限关闭时显示此权限视图
@property (nonatomic, strong) AlpVideoCameraPermissionView *permissionView;
/// 视频录制的状态，根据此状态更新UI
@property (nonatomic, assign) AlpVideoCameraRecordState recordState;
@property (nonatomic, strong) UIView *rightView;

@end

NS_ASSUME_NONNULL_END
