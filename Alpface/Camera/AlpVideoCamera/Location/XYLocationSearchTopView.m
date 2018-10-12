//
//  XYLocationSearchTopView.m
//  Alpface
//
//  Created by xiaoyuan on 2018/9/20.
//  Copyright © 2018 alpface. All rights reserved.
//

#import "XYLocationSearchTopView.h"
#import "UIImage+AlpExtensions.h"

@implementation XYLocationSearchTopView
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
    
    UIButton *nextBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [nextBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _rightButton = nextBtn;
    [nextBtn.titleLabel setFont:[UIFont systemFontOfSize:15]];
    [self addSubview:nextBtn];
    nextBtn.translatesAutoresizingMaskIntoConstraints = false;
    [NSLayoutConstraint constraintWithItem:nextBtn attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0].active = YES;
//    [NSLayoutConstraint constraintWithItem:nextBtn attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0].active = YES;
    [NSLayoutConstraint constraintWithItem:nextBtn attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0].active = YES;
    [NSLayoutConstraint constraintWithItem:nextBtn attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:80.0].active = YES;
    
    UILabel *titleLabel = [[UILabel alloc] init];
    _titleLabel = titleLabel;
    titleLabel.text = @"添加位置";
    titleLabel.textColor = [UIColor whiteColor];
    [self addSubview:titleLabel];
    titleLabel.translatesAutoresizingMaskIntoConstraints = false;
    [NSLayoutConstraint constraintWithItem:titleLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0].active = YES;
    [NSLayoutConstraint constraintWithItem:titleLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:nextBtn attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0].active = YES;
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setImage:[UIImage alp_videoCameraBundleImageNamed:@"BackToVideoCammer"] forState:UIControlStateNormal];
    _leftButton = backButton;
    [self addSubview:backButton];
    backButton.translatesAutoresizingMaskIntoConstraints = false;
    [NSLayoutConstraint constraintWithItem:backButton attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0].active = YES;
    [NSLayoutConstraint constraintWithItem:backButton attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:nextBtn attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0].active = YES;
    [NSLayoutConstraint constraintWithItem:backButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0].active = YES;
    [NSLayoutConstraint constraintWithItem:backButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:60.0].active = YES;
    
    [NSLayoutConstraint constraintWithItem:titleLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationLessThanOrEqual toItem:nextBtn attribute:NSLayoutAttributeLeading multiplier:1.0 constant:-5.0].active = YES;
    
    _searchBar = [[UISearchBar alloc] init];
    _searchBar.placeholder = @"Enter Location";
    _searchBar.translatesAutoresizingMaskIntoConstraints = NO;
    //改变搜索框外部框的颜色（需要隐藏background才能显示背景色）
    _searchBar.backgroundImage = [[UIImage alloc]init];
    [_searchBar sizeToFit];
    //用textfiled代替搜索框
    UITextField *searchField = [_searchBar valueForKey:@"_searchField"];
    searchField.backgroundColor = [UIColor colorWithRed:227/255.0 green:227/255.0 blue:227/255.0 alpha:0.5];
    searchField.textColor = [UIColor whiteColor];
    //渲染模式改变searchBar左侧imag的渲染颜色
    UIImageView *searchImageView = (id)searchField.leftView;
    searchImageView.image = [searchImageView.image imageWithRenderingMode:(UIImageRenderingModeAlwaysTemplate)];
    [searchImageView setTintColor:[UIColor whiteColor]];
    //修改placeholderLabel.textColor的颜色
    [searchField setValue:[UIColor lightGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
//    _searchBar.layer.borderColor = [UIColor lightGrayColor].CGColor;
//    _searchBar.layer.borderWidth = 0.5;
    [self addSubview:self.searchBar];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.searchBar attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:nextBtn attribute:NSLayoutAttributeBottom multiplier:1.0 constant:10.0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.searchBar attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.searchBar attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.searchBar attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]];
}


@end
