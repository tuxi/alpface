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
//    self.alpha = .8;
    self.backgroundColor = [UIColor blackColor];
    UILabel *titleLabel = [[UILabel alloc] init];
    _titleLabel = titleLabel;
    titleLabel.textColor = [UIColor whiteColor];
    [self addSubview:titleLabel];
    titleLabel.translatesAutoresizingMaskIntoConstraints = false;
    [NSLayoutConstraint constraintWithItem:titleLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0].active = YES;
    [NSLayoutConstraint constraintWithItem:titleLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0].active = YES;
    
    
    UIButton *nextBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [nextBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _rightButton = nextBtn;
    [nextBtn.titleLabel setFont:[UIFont systemFontOfSize:15]];
    [self addSubview:nextBtn];
    nextBtn.translatesAutoresizingMaskIntoConstraints = false;
    [NSLayoutConstraint constraintWithItem:nextBtn attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:-10.0].active = YES;
    [NSLayoutConstraint constraintWithItem:nextBtn attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0].active = YES;
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setImage:[UIImage imageNamed:@"BackToVideoCammer"] forState:UIControlStateNormal];
    _leftButton = backButton;
    [self addSubview:backButton];
    backButton.translatesAutoresizingMaskIntoConstraints = false;
    [NSLayoutConstraint constraintWithItem:backButton attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1.0 constant:10.0].active = YES;
    [NSLayoutConstraint constraintWithItem:backButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:nextBtn attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0].active = YES;
    [NSLayoutConstraint constraintWithItem:backButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:35.0].active = YES;
    [NSLayoutConstraint constraintWithItem:titleLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationLessThanOrEqual toItem:nextBtn attribute:NSLayoutAttributeLeading multiplier:1.0 constant:-5.0].active = YES;
}


@end
