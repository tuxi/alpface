//
//  AlpEditVideoNavigationBar.m
//  Alpface
//
//  Created by xiaoyuan on 2018/9/18.
//  Copyright © 2018 alpface. All rights reserved.
//

#import "AlpEditVideoNavigationBar.h"

@implementation AlpEditVideoNavigationBar

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    self.alpha = .8;
    self.backgroundColor = [UIColor blackColor];
    UILabel* titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"编辑";
    titleLabel.textColor = [UIColor whiteColor];
    [self addSubview:titleLabel];
    titleLabel.translatesAutoresizingMaskIntoConstraints = false;
    [NSLayoutConstraint constraintWithItem:titleLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0].active = YES;
    [NSLayoutConstraint constraintWithItem:titleLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0].active = YES;
    
    
    UIButton *nextBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [nextBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [nextBtn setTitle:@"下一步" forState:UIControlStateNormal];
    [nextBtn.titleLabel setFont:[UIFont systemFontOfSize:15]];
    [nextBtn addTarget:self action:@selector(clickNextBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:nextBtn];
    nextBtn.translatesAutoresizingMaskIntoConstraints = false;
    [NSLayoutConstraint constraintWithItem:nextBtn attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0].active = YES;
    [NSLayoutConstraint constraintWithItem:nextBtn attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0].active = YES;
    [NSLayoutConstraint constraintWithItem:nextBtn attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0].active = YES;
    [NSLayoutConstraint constraintWithItem:nextBtn attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:80.0].active = YES;
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setImage:[UIImage imageNamed:@"BackToVideoCammer"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(clickBackBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:backButton];
    backButton.translatesAutoresizingMaskIntoConstraints = false;
    [NSLayoutConstraint constraintWithItem:backButton attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0].active = YES;
    [NSLayoutConstraint constraintWithItem:backButton attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0].active = YES;
    [NSLayoutConstraint constraintWithItem:backButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0].active = YES;
    [NSLayoutConstraint constraintWithItem:backButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:60.0].active = YES;
    
    [NSLayoutConstraint constraintWithItem:titleLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationLessThanOrEqual toItem:nextBtn attribute:NSLayoutAttributeLeading multiplier:1.0 constant:-5.0].active = YES;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Actions
////////////////////////////////////////////////////////////////////////

- (void)clickNextBtn:(UIButton *)btn {
    if (self.delegate && [self.delegate respondsToSelector:@selector(editVideoNavigationBar:didClickNextButton:)]) {
        [self.delegate editVideoNavigationBar:self didClickNextButton:btn];
    }
}

- (void)clickBackBtn:(UIButton *)btn {
    if (self.delegate && [self.delegate respondsToSelector:@selector(editVideoNavigationBar:didClickBackButton:)]) {
        [self.delegate editVideoNavigationBar:self didClickBackButton:btn];
    }
}

@end
