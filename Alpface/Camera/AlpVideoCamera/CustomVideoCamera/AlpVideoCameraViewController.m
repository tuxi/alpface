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

@interface AlpVideoCameraViewController () <ALPVideoCameraViewDelegate>

@property (nonatomic, weak) id<AlpVideoCameraViewControllerDelegate> delegate;

@end

@implementation AlpVideoCameraViewController

- (instancetype)initWithDelegate:(id<AlpVideoCameraViewControllerDelegate>)delegate {
    if (self = [super init]) {
        _delegate = delegate;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [self setupViewCameraView];
    if (self.delegate && [self.delegate respondsToSelector:@selector(videoCameraViewController:viewWillAppear:)]) {
        [self.delegate videoCameraViewController:self viewWillAppear:animated];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.delegate && [self.delegate respondsToSelector:@selector(videoCameraViewController:viewWillDisappear:)]) {
        [self.delegate videoCameraViewController:self viewWillDisappear:animated];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.delegate && [self.delegate respondsToSelector:@selector(videoCameraViewController:viewDidAppear:)]) {
        [self.delegate videoCameraViewController:self viewDidAppear:animated];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if (self.delegate && [self.delegate respondsToSelector:@selector(videoCameraViewController:viewDidDisappear:)]) {
        [self.delegate videoCameraViewController:self viewDidDisappear:animated];
    }
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
        NSLog(@"new VideoCameraView");
        videoCameraView.width = [NSNumber numberWithInteger:width];
        videoCameraView.hight = [NSNumber numberWithInteger:hight];
        videoCameraView.bit = [NSNumber numberWithInteger:bit];
        videoCameraView.frameRate = [NSNumber numberWithInteger:framRate];
        
        typeof(self) __weak weakself = self;
        videoCameraView.backToHomeBlock = ^(){
            [weakself.navigationController dismissViewControllerAnimated:YES completion:nil];
            
            [[UIApplication sharedApplication] setStatusBarHidden:NO];
            NSLog(@"clickBackToHomg2");
        };
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

@end
