//
//  AlpEditVideoBottomView.m
//  Alpface
//
//  Created by swae on 2018/10/5.
//  Copyright © 2018 alpface. All rights reserved.
//

#import "AlpEditVideoBottomView.h"
#import "AlpVideoCameraButton.h"
#import "UIImage+AlpExtensions.h"

@interface AlpEditVideoBottomView ()

// 特效
@property (nonatomic, strong) AlpVideoCameraButton *specialEffectsButton;
// 选封面
@property (nonatomic, strong) AlpVideoCameraButton *chooseCoverButton;
// 滤镜
@property (nonatomic, strong) AlpVideoCameraButton *filterButton;

// 下一步
@property (nonatomic, strong) UIButton *nextButton;

@end

@implementation AlpEditVideoBottomView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    self.backgroundColor = UIColor.clearColor;
    [self addSubview:self.filterButton];
    [self addSubview:self.chooseCoverButton];
    [self addSubview:self.specialEffectsButton];
    [self addSubview:self.nextButton];
    
    self.filterButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.chooseCoverButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.specialEffectsButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.nextButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    CGFloat padding = 15.0;
    [NSLayoutConstraint constraintWithItem:self.specialEffectsButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0].active = YES;
    [NSLayoutConstraint constraintWithItem:self.specialEffectsButton attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1.0 constant:padding].active = YES;
    [NSLayoutConstraint constraintWithItem:self.specialEffectsButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:50.0].active = YES;
    if (@available(iOS 11.0, *)) {
        [NSLayoutConstraint constraintWithItem:self.specialEffectsButton attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.safeAreaLayoutGuide attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-25.0].active = YES;
    } else {
        [NSLayoutConstraint constraintWithItem:self.specialEffectsButton attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-25.0].active = YES;
    }
    
    [NSLayoutConstraint constraintWithItem:self.chooseCoverButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.specialEffectsButton attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0].active = YES;
    [NSLayoutConstraint constraintWithItem:self.chooseCoverButton attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.specialEffectsButton attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:padding].active = YES;
    [NSLayoutConstraint constraintWithItem:self.chooseCoverButton attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.specialEffectsButton attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0].active = YES;
    [NSLayoutConstraint constraintWithItem:self.chooseCoverButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.specialEffectsButton attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0].active = YES;

    [NSLayoutConstraint constraintWithItem:self.filterButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.specialEffectsButton attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0].active = YES;
    [NSLayoutConstraint constraintWithItem:self.filterButton attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.chooseCoverButton attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:padding].active = YES;
    [NSLayoutConstraint constraintWithItem:self.filterButton attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.specialEffectsButton attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0].active = YES;
    [NSLayoutConstraint constraintWithItem:self.filterButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.specialEffectsButton attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0].active = YES;
    
    [NSLayoutConstraint constraintWithItem:self.nextButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:10.0].active = YES;
    [NSLayoutConstraint constraintWithItem:self.nextButton attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:-padding].active = YES;
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
////////////////////////////////////////////////////////////////////////

- (AlpVideoCameraButton *)specialEffectsButton {
    if (!_specialEffectsButton) {
        _specialEffectsButton = [AlpVideoCameraButton new];
        [_specialEffectsButton setTitle:@"特效" forState:UIControlStateNormal];
        [_specialEffectsButton setImage:[UIImage alp_videoCameraBundleImageNamed:@"iconSpecial2_40x40_"] forState:UIControlStateNormal];
        _specialEffectsButton.titleLabel.font = [UIFont systemFontOfSize:12.0];
        
    }
    return _specialEffectsButton;
}

- (AlpVideoCameraButton *)chooseCoverButton {
    if (!_chooseCoverButton) {
        _chooseCoverButton = [AlpVideoCameraButton new];
        [_chooseCoverButton setTitle:@"选封面" forState:UIControlStateNormal];
        [_chooseCoverButton setImage:[UIImage alp_videoCameraBundleImageNamed:@"iconCover_40x40_"] forState:UIControlStateNormal];
        _chooseCoverButton.titleLabel.font = [UIFont systemFontOfSize:12.0];
    }
    return _chooseCoverButton;
}

- (AlpVideoCameraButton *)filterButton {
    if (!_filterButton) {
        _filterButton = [AlpVideoCameraButton new];
        [_filterButton setTitle:@"滤镜" forState:UIControlStateNormal];
        [_filterButton setImage:[UIImage alp_videoCameraBundleImageNamed:@"iconFilterA_40x40_"] forState:UIControlStateNormal];
        _filterButton.titleLabel.font = [UIFont systemFontOfSize:12.0];
    }
    return _filterButton;
}

- (UIButton *)nextButton {
    if (!_nextButton) {
        _nextButton = [UIButton new];
        [_nextButton setTitle:@"下一步" forState:UIControlStateNormal];
        _nextButton.backgroundColor = [UIColor redColor];
        _nextButton.layer.cornerRadius = 2.0;
        _nextButton.layer.masksToBounds = YES;
        [_nextButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _nextButton.contentEdgeInsets = UIEdgeInsetsMake(5.0, 5.0, 5.0, 5.0);
        _nextButton.titleLabel.font = [UIFont systemFontOfSize:13.0];
    }
    return _nextButton;
}

@end
