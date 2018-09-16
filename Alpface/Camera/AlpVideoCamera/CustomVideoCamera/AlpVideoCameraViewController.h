//
//  AlpVideoCameraViewController.h
//  AlpVideoCamera
//
//  Created by swae on 2018/9/12.
//  Copyright © 2018 xiaoyuan. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class AlpVideoCameraViewController;
@protocol AlpVideoCameraViewControllerDelegate <NSObject>

@optional
- (void)videoCameraViewController:(AlpVideoCameraViewController *)viewController viewWillAppear:(BOOL)animated;
- (void)videoCameraViewController:(AlpVideoCameraViewController *)viewController viewWillDisappear:(BOOL)animated;
- (void)videoCameraViewController:(AlpVideoCameraViewController *)viewController viewDidAppear:(BOOL)animated;
- (void)videoCameraViewController:(AlpVideoCameraViewController *)viewController viewDidDisappear:(BOOL)animated;

@end

@interface AlpVideoCameraViewController : UIViewController

- (instancetype)initWithDelegate:(id<AlpVideoCameraViewControllerDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
