//
//  AlpEditCoverViewController.h
//  Alpface
//
//  Created by xiaoyuan on 2018/9/27.
//  Copyright © 2018 alpface. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol AlpEditCoverViewControllerDelegate;

@interface AlpEditCoverViewController : UIViewController

@property (nonatomic, weak) id<AlpEditCoverViewControllerDelegate> delegate;

@property(nonatomic, copy) NSURL *videoURL;

@end

NS_ASSUME_NONNULL_END

@protocol AlpEditCoverViewControllerDelegate <NSObject>

@optional

/// 视频封面改变的回调
/// @param controller AlpEditCoverViewController
/// @param start 封面的起始时间 单位为秒
/// @param end 封面的结束时间 单位为秒
- (void)editCoverViewController:(nullable AlpEditCoverViewController *)controller didChangeCoverWithStartTime:(CGFloat)start endTime:(CGFloat)end;

@end
