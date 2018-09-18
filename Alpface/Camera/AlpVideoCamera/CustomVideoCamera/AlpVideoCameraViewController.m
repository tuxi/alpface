//
//  AlpVideoCameraViewController.m
//  AlpVideoCamera
//
//  Created by swae on 2018/9/12.
//  Copyright © 2018 xiaoyuan. All rights reserved.
//

#import "AlpVideoCameraViewController.h"
#import "ALPVideoCameraView.h"
#import "RTRootNavigationController.h"
#import "AlpVideoCameraDefine.h"
#import "AlpEditingPublishingViewController.h"
#import "AlpEditVideoParameter.h"

@interface AlpVideoCameraViewController () <ALPVideoCameraViewDelegate>


@end

@implementation AlpVideoCameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(publishVideoNotification:) name:AlpPublushVideoNotification object:nil];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [self setupViewCameraView];
}

- (void)setupViewCameraView {
    int width,hight,bit,framRate;
    {
        width = 720;
        hight = 1280;
        bit = 2500000;
        framRate = 30;
    }
    BOOL needNewVideoCamera = YES;
    for (UIView* subView in self.view.subviews) {
        if ([subView isKindOfClass:[ALPVideoCameraView class]]) {
            needNewVideoCamera = NO;
        }
    }
    if (needNewVideoCamera) {
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
        CGRect frame = [[UIScreen mainScreen] bounds];
        ALPVideoCameraView* videoCameraView = [[ALPVideoCameraView alloc] initWithFrame:frame];
        videoCameraView.delegate = self;
        AlpEditVideoParameter *videoOptions = [[AlpEditVideoParameter alloc] initWithBitRate:bit frameRate:framRate];
        videoCameraView.videoOptions = videoOptions;
        [self.view addSubview:videoCameraView];
    }
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - VideoCameraDelegate
////////////////////////////////////////////////////////////////////////

- (void)videoCamerView:(ALPVideoCameraView *)view pushViewCotroller:(UIViewController *)viewController {
    [self.rt_navigationController pushViewController:viewController animated:YES complete:nil];
}

- (void)videoCamerView:(ALPVideoCameraView *)view presentViewCotroller:(UIViewController *)viewController {
    [self presentViewController:viewController animated:YES completion:nil];
}

- (void)videoCamerView:(ALPVideoCameraView *)view didClickBackButton:(UIButton *)btn {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Notification
////////////////////////////////////////////////////////////////////////

- (void)publishVideoNotification:(NSNotification *)notification {
    NSDictionary *videoInfo =  notification.userInfo;
    if (self.delegate && [self.delegate respondsToSelector:@selector(videoCameraViewController:publishWithVideoURL:title:content:)]) {
        [self.delegate videoCameraViewController:self publishWithVideoURL:videoInfo[@"video"] title:videoInfo[@"title"] content:videoInfo[@"content"]];
    }
}

@end
