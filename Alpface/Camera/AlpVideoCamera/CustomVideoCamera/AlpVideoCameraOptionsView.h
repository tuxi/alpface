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

@interface AlpVideoCameraOptionsView : UIView {
    
}

@property (nonatomic, strong) UIButton *timeButton;
//@property (nonatomic, strong) UIView *btView;
@property (nonatomic, strong) UIButton *photoCaptureButton;
@property (nonatomic, strong) UIButton *cameraChangeButton;
@property (nonatomic, strong) UIButton *dleButton;
@property (nonatomic, strong) UIButton *inputLocalVieoBtn;
@property (nonatomic, strong) UIButton *backBtn;
@property (nonatomic ,strong) UIButton *camerafilterChangeButton;
@property (nonatomic ,strong) UIButton *cameraPositionChangeButton;
@property (nonatomic, strong) OSProgressView *progressPreView;
@property (nonatomic, strong) AlpVideoCameraPermissionView *permissionView;
/// 视频录制的状态，根据此状态更新UI
@property (nonatomic, assign) AlpVideoCameraRecordState recordState;


@end

NS_ASSUME_NONNULL_END
