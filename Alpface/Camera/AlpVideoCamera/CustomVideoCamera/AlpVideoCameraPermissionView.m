//
//  AlpVideoCameraPermissionView.m
//  Alpface
//
//  Created by swae on 2018/9/19.
//  Copyright © 2018 alpface. All rights reserved.
//

#import "AlpVideoCameraPermissionView.h"
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>

@interface AlpVideoCameraPermissionView ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *describeTextLabel;
@property (nonatomic, strong) UIButton *cameraAuthorButton;
@property (nonatomic, strong) UIButton *microAuthorButton;

@end

@implementation AlpVideoCameraPermissionView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}


- (void)setup {
    
    UIBlurEffect *blurEffrct =[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    // 毛玻璃视图
    UIVisualEffectView* visualEffectView = [[UIVisualEffectView alloc]initWithEffect:blurEffrct];
    visualEffectView.alpha = .7;
    [self addSubview:visualEffectView];
    visualEffectView.userInteractionEnabled = NO;
    visualEffectView.translatesAutoresizingMaskIntoConstraints = false;
    [NSLayoutConstraint constraintWithItem:visualEffectView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0].active = YES;
    [NSLayoutConstraint constraintWithItem:visualEffectView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0].active = YES;
    [NSLayoutConstraint constraintWithItem:visualEffectView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0].active = YES;
    [NSLayoutConstraint constraintWithItem:visualEffectView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0].active = YES;
    
    UIView *contentView = [UIView new];
    contentView.backgroundColor = [UIColor clearColor];
    contentView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:contentView];
    [contentView addSubview:self.titleLabel];
    [contentView addSubview:self.describeTextLabel];
    [contentView addSubview:self.cameraAuthorButton];
    [contentView addSubview:self.microAuthorButton];
    [self.titleLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.titleLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    
    [self.describeTextLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.cameraAuthorButton setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [self.microAuthorButton setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(5.0)-[titleLabel]-(8.0)-[describeTextLabel]-(50.0)-[cameraAuthorButton]-(25.0)-[microAuthorButton]-(5.0)-|" options:NSLayoutFormatAlignAllCenterX metrics:nil views:@{@"titleLabel": self.titleLabel, @"describeTextLabel": self.describeTextLabel, @"cameraAuthorButton": self.cameraAuthorButton, @"microAuthorButton": self.microAuthorButton}]];
    
    [NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0].active = YES;
    [NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0].active = YES;
    
    [NSLayoutConstraint constraintWithItem:contentView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0].active = YES;
    [NSLayoutConstraint constraintWithItem:contentView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0].active = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActiveNotification) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    [self updateHidden];
}

- (void)updateHidden {
    /// 检查相机权限
    AVAuthorizationStatus cameraStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    self.cameraAuthorButton.selected = cameraStatus == AVAuthorizationStatusAuthorized;
    /// 检查麦克风权限
    AVAuthorizationStatus audioStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    self.microAuthorButton.selected = audioStatus == AVAuthorizationStatusAuthorized;
    if (cameraStatus == AVAuthorizationStatusAuthorized &&
        audioStatus == AVAuthorizationStatusAuthorized) {
        self.hidden = YES;
    }
    else {
        self.hidden = NO;
    }
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Actions
////////////////////////////////////////////////////////////////////////

- (void)microAuthorButtonClick:(UIButton *)sender {
    AVAuthorizationStatus audioStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    if (audioStatus == AVAuthorizationStatusAuthorized) {
        return;
    }
    else if (audioStatus == AVAuthorizationStatusDenied ||
             audioStatus == AVAuthorizationStatusRestricted) {
        /// 已經被用戶拒絕了, 跳轉到設置
        NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            [[UIApplication sharedApplication] openURL:url];
            
        }
    }
    
    /// 请求麦克风权限
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
        dispatch_async(dispatch_get_main_queue(), ^{
            sender.selected = granted;
            [self updateHidden];
        });
    }];
}

- (void)cameraAuthorButtonClick:(UIButton *)sender {
    AVAuthorizationStatus videoStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (videoStatus == AVAuthorizationStatusAuthorized) {
        return;
    }
    else if (videoStatus == AVAuthorizationStatusDenied ||
             videoStatus == AVAuthorizationStatusRestricted) {
        /// 已經被用戶拒絕了, 跳轉到設置
        NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            [[UIApplication sharedApplication] openURL:url];
            
        }
    }
    /// 请求相机权限
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        dispatch_async(dispatch_get_main_queue(), ^{
            sender.selected = granted;
            [self updateHidden];
        });
    }];
}

- (void)appDidBecomeActiveNotification {
    [self updateHidden];
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Lazy
////////////////////////////////////////////////////////////////////////

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        UILabel *label = UILabel.new;
        label.translatesAutoresizingMaskIntoConstraints = false;
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont systemFontOfSize:25.0];
        label.text = @"拍摄你的生活故事";
        label.textAlignment = NSTextAlignmentCenter;
        _titleLabel = label;
    }
    return _titleLabel;
}

- (UILabel *)describeTextLabel {
    if (!_describeTextLabel) {
        UILabel *label = UILabel.new;
        label.translatesAutoresizingMaskIntoConstraints = false;
        label.textColor = [UIColor lightGrayColor];
        label.font = [UIFont systemFontOfSize:14.0];
        label.text = @"允许访问即可进入拍摄";
        label.textAlignment = NSTextAlignmentCenter;
        _describeTextLabel = label;
    }
    return _describeTextLabel;
}

- (UIButton *)cameraAuthorButton {
    if (!_cameraAuthorButton) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        button.translatesAutoresizingMaskIntoConstraints = false;
        [button setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
        [button setTitle:@"启用相机访问权限" forState:UIControlStateNormal];
        [button setTitle:@"✅启用相机访问权限" forState:UIControlStateSelected];
        [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateSelected];
        [button addTarget:self action:@selector(cameraAuthorButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        _cameraAuthorButton = button;
    }
    return _cameraAuthorButton;
}

- (UIButton *)microAuthorButton {
    if (!_microAuthorButton) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        button.translatesAutoresizingMaskIntoConstraints = false;
        [button setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
        [button setTitle:@"启用麦克风访问权限" forState:UIControlStateNormal];
        [button setTitle:@"✅启用麦克风访问权限" forState:UIControlStateSelected];
        [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateSelected];
        [button addTarget:self action:@selector(microAuthorButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        _microAuthorButton = button;
        
    }
    return _microAuthorButton;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
