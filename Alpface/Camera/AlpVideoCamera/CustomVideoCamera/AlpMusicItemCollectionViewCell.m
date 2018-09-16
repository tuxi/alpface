//
//  AlpMusicItemCollectionViewCell.m
//  AlpVideoCamera
//
//  Created by xiaoyuan on 2018/9/13.
//  Copyright © 2018 xiaoyuan. All rights reserved.
//

#import "AlpMusicItemCollectionViewCell.h"
#import "UIView+Tools.h"

@implementation AlpMusicItemCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    
    [self.contentView addSubview:self.iconImgView];
    [NSLayoutConstraint constraintWithItem:self.iconImgView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1.0 constant:10.0].active = YES;
    [NSLayoutConstraint constraintWithItem:self.iconImgView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0].active = YES;
    [NSLayoutConstraint constraintWithItem:self.iconImgView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:70.0].active = YES;
    [NSLayoutConstraint constraintWithItem:self.iconImgView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:_iconImgView attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0].active = YES;
    
    [_iconImgView makeCornerRadius:35 borderColor:nil borderWidth:0];
    

    [self.contentView addSubview:self.nameLabel];
    [NSLayoutConstraint constraintWithItem:self.nameLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0].active = YES;
    [NSLayoutConstraint constraintWithItem:self.nameLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.iconImgView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:5.0].active = YES;
    [NSLayoutConstraint constraintWithItem:self.nameLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.iconImgView attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0].active = YES;
    [NSLayoutConstraint constraintWithItem:self.nameLabel attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.iconImgView attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0].active = YES;
    
    [self.contentView addSubview:self.checkMarkImgView];
    self.checkMarkImgView.hidden = YES;
    [NSLayoutConstraint constraintWithItem:self.checkMarkImgView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0].active = YES;
    [NSLayoutConstraint constraintWithItem:self.checkMarkImgView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0].active = YES;
    [NSLayoutConstraint constraintWithItem:self.checkMarkImgView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0].active = YES;
    [NSLayoutConstraint constraintWithItem:self.checkMarkImgView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0].active = YES;
    [NSLayoutConstraint constraintWithItem:self.checkMarkImgView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:83.0].active = YES;
    [NSLayoutConstraint constraintWithItem:self.checkMarkImgView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:115.0].active = YES;
    
}

////////////////////////////////////////////////////////////////////////
#pragma mark - getter
////////////////////////////////////////////////////////////////////////

- (UIImageView *)iconImgView {
    if (!_iconImgView) {
       _iconImgView = [[UIImageView alloc] init];
        _iconImgView.layer.masksToBounds = YES;
        _iconImgView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _iconImgView;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.textColor = [UIColor grayColor];
        [_nameLabel setFont:[UIFont systemFontOfSize:11]];
        _nameLabel.textAlignment = NSTextAlignmentCenter;
        _nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _nameLabel;
}

- (UIImageView *)checkMarkImgView {
    if (!_checkMarkImgView) {
        _checkMarkImgView = [[UIImageView alloc] init];
        _checkMarkImgView.image = [UIImage imageNamed:@"GiftCheckmarkIcon"];
        _checkMarkImgView.translatesAutoresizingMaskIntoConstraints = NO;
        _checkMarkImgView.contentMode = UIViewContentModeScaleToFill;
    }
    return _checkMarkImgView;
}

@end
