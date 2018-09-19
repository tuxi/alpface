//
//  AlpVideoCameraPermissionView.m
//  Alpface
//
//  Created by swae on 2018/9/19.
//  Copyright © 2018 alpface. All rights reserved.
//

#import "AlpVideoCameraPermissionView.h"

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
        _microAuthorButton = button;
    }
    return _microAuthorButton;
}

@end
