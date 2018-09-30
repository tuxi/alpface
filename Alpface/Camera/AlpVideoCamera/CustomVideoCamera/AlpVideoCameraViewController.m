//
//  AlpVideoCameraViewController.m
//  AlpVideoCamera
//
//  Created by swae on 2018/9/12.
//  Copyright © 2018 xiaoyuan. All rights reserved.
//

#import "AlpVideoCameraViewController.h"
#import "ALPVideoCameraView.h"
#import "AlpVideoCameraDefine.h"
#import "AlpEditVideoParameter.h"

@interface AlpVideoCameraViewController () <ALPVideoCameraViewDelegate>

@property (nonatomic, weak) ALPVideoCameraView *videoCameraView;

@end

@implementation AlpVideoCameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(publishVideoNotification:) name:AlpPublushVideoNotification object:nil];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [self setupViewCameraView];
    [_videoCameraView startCameraCapture];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_videoCameraView stopCameraCapture];
}

- (void)setupViewCameraView {
    int bit,framRate; {
        bit = 2500000;
        framRate = 30;
    }
    if (!_videoCameraView) {
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
        CGRect frame = [[UIScreen mainScreen] bounds];
        ALPVideoCameraView *videoCameraView = [[ALPVideoCameraView alloc] initWithFrame:frame];
        videoCameraView.translatesAutoresizingMaskIntoConstraints = false;
        [self.view addSubview:videoCameraView];
        [NSLayoutConstraint constraintWithItem:videoCameraView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0].active = YES;
        [NSLayoutConstraint constraintWithItem:videoCameraView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0].active = YES;
        [NSLayoutConstraint constraintWithItem:videoCameraView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0].active = YES;
        [NSLayoutConstraint constraintWithItem:videoCameraView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0].active = YES;
       
        videoCameraView.delegate = self;
        _videoCameraView = videoCameraView;
        AlpEditVideoParameter *videoOptions = [[AlpEditVideoParameter alloc] initWithBitRate:bit frameRate:framRate];
        videoCameraView.videoOptions = videoOptions;
        if ([self.delegate respondsToSelector:@selector(hiddenBackButtonForVideoCameraViewController:)]) {
            videoCameraView.optionsView.backBtn.hidden = [self.delegate hiddenBackButtonForVideoCameraViewController:self];
        }
    }
}

- (void)removeCamerView {
    [_videoCameraView removeFromSuperview];
    _videoCameraView = nil;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - VideoCameraDelegate
////////////////////////////////////////////////////////////////////////

- (void)videoCamerView:(ALPVideoCameraView *)view pushViewCotroller:(UIViewController *)viewController {
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)videoCamerView:(ALPVideoCameraView *)view presentViewCotroller:(UIViewController *)viewController {
    [self presentViewController:viewController animated:YES completion:nil];
}

- (void)videoCamerView:(ALPVideoCameraView *)view didClickBackButton:(UIButton *)btn {
    [self.navigationController dismissViewControllerAnimated:NO completion:nil];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Notification
////////////////////////////////////////////////////////////////////////

- (void)publishVideoNotification:(NSNotification *)notification {
    NSDictionary *videoInfo =  notification.userInfo;
    if (self.delegate && [self.delegate respondsToSelector:@selector(videoCameraViewController:publishWithVideoURL:title:content:longitude:latitude:poi_name:poi_address:)]) {
        [self.delegate videoCameraViewController:self publishWithVideoURL:videoInfo[@"video"] title:videoInfo[@"title"] content:videoInfo[@"content"] longitude:[videoInfo[@"longitude"] doubleValue] latitude:[videoInfo[@"latitude"] doubleValue] poi_name:videoInfo[@"poi_name"] poi_address:videoInfo[@"poi_address"]];
    }
}

@end
