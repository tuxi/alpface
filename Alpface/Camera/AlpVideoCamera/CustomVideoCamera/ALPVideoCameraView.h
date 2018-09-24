//
//  ALPVideoCameraView.h
//  AlpVideoCamera
//
//  Created by swae on 2018/9/12.
//  Copyright © 2018 xiaoyuan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AlpVideoCameraOptionsView.h"

NS_ASSUME_NONNULL_BEGIN

@class ALPVideoCameraView, AlpEditVideoParameter;

@protocol ALPVideoCameraViewDelegate <NSObject>

/// 需要以modal的方式弹出某个控制器时回调，此事件交给控制器处理
- (void)videoCamerView:(ALPVideoCameraView *)view presentViewCotroller:(UIViewController *)viewController;
/// 需要以push的方式跳转到某个控制器时回调，此事件交给控制器处理
- (void)videoCamerView:(ALPVideoCameraView *)view pushViewCotroller:(UIViewController *)viewController;
/// 点击返回按钮的回调
- (void)videoCamerView:(ALPVideoCameraView *)view didClickBackButton:(UIButton *)btn;

@end

@interface ALPVideoCameraView : UIView

@property (nonatomic, weak) id<ALPVideoCameraViewDelegate> delegate;
@property (nonatomic, strong) AlpEditVideoParameter *videoOptions;
@property (nonatomic, strong, readonly) AlpVideoCameraOptionsView *optionsView;

- (void)stopCameraCapture;
- (void)startCameraCapture;

@end

NS_ASSUME_NONNULL_END
