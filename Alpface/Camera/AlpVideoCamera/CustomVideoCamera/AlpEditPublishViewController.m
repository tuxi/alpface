//
//  AlpEditPublishViewController.m
//  Alpface
//
//  Created by swae on 2018/9/18.
//  Copyright © 2018 alpface. All rights reserved.
//

#import "AlpEditPublishViewController.h"
#import "AlpEditVideoNavigationBar.h"
#import "AlpVideoCameraDefine.h"
#import "UIImage+AlpExtensions.h"
#import <CoreLocation/CoreLocation.h>

typedef NS_ENUM(NSInteger, AlpPublishVideoPermissionType) {
    AlpPublishVideoPermissionTypePublic,
    AlpPublishVideoPermissionTypePrivate,
    AlpPublishVideoPermissionTypeFriend,
};

@interface AlpEditPublishVideoModel : NSObject

@property (nonatomic, strong) NSURL *videoURL;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate2D;
@property (nonatomic, copy) NSString *addressTitle;
@property (nonatomic, assign) AlpPublishVideoPermissionType permissionType;
@property (nonatomic, assign, getter=isSaveAlbum) BOOL saveAlbum;

@end

@interface AlpEditPublishViewContentCell : UITableViewCell <UITextViewDelegate>

@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UIButton *videoButton;
@property (nonatomic, strong) NSURL *videoURL;
@property (strong, nonatomic) UILabel *limitLabel;
@property BOOL isExceed_cai;

@end

@interface AlpEditPublishViewSelectLocationCell : UITableViewCell

@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *arrowIconView;

@end

@interface AlpEditPublishViewPermissionCell : UITableViewCell

@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *arrowIconView;
@property (nonatomic, strong) UILabel *resultLabel;

@end

@interface AlpEditPublishViewLocationListCell : UITableViewCell

@end

@interface AlpEditPublishViewBottomView : UIView

@property (nonatomic, strong) UIButton *draftButton;
@property (nonatomic, strong) UIButton *publishButton;
@property (nonatomic, strong) UIButton *saveAlbumButton;
@property (nonatomic, strong) UILabel *titleLabel;

@end

@interface AlpEditPublishViewController () <UITableViewDelegate, UITableViewDataSource, AlpEditVideoNavigationBarDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) AlpEditVideoNavigationBar *navigationBar;
@property (nonatomic, strong) AlpEditPublishViewBottomView *bottomView;
@property (nonatomic, strong) AlpEditPublishVideoModel *publishModel;

@end

@implementation AlpEditPublishViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.navigationBarHidden = YES;
//    self.view.alpha = .8;
    self.view.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.navigationBar];
    self.navigationBar.titleLabel.text = @"发布";
    self.navigationBar.translatesAutoresizingMaskIntoConstraints = false;
    [NSLayoutConstraint constraintWithItem:self.navigationBar attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0].active = YES;
    [NSLayoutConstraint constraintWithItem:self.navigationBar attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0].active = YES;
    [NSLayoutConstraint constraintWithItem:self.navigationBar attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0].active = YES;
    [NSLayoutConstraint constraintWithItem:self.navigationBar attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:44.0].active = YES;
    
    UIView *line = [UIView new];
    [self.view addSubview:line];
    line.translatesAutoresizingMaskIntoConstraints = false;
    line.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
    [NSLayoutConstraint constraintWithItem:line attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.navigationBar attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0].active = YES;
    [NSLayoutConstraint constraintWithItem:line attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:0.3].active = YES;
    [NSLayoutConstraint constraintWithItem:line attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0].active = YES;
    [NSLayoutConstraint constraintWithItem:line attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0].active = YES;
    
    [self.view addSubview:self.tableView];
    self.tableView.translatesAutoresizingMaskIntoConstraints = false;
    [NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:line attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0].active = YES;
    [NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0].active = YES;
    [NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0].active = YES;
    
    [self.view addSubview:self.bottomView];
    self.bottomView.translatesAutoresizingMaskIntoConstraints = false;
    [NSLayoutConstraint constraintWithItem:self.bottomView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.tableView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0].active = YES;
    [NSLayoutConstraint constraintWithItem:self.bottomView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0].active = YES;
    [NSLayoutConstraint constraintWithItem:self.bottomView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0].active = YES;
    [NSLayoutConstraint constraintWithItem:self.bottomView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0].active = YES;
    
}

- (void)setVideoURL:(NSURL *)videoURL {
    _videoURL = videoURL;
    self.publishModel.videoURL = videoURL;
    [self.tableView reloadData];
}

////////////////////////////////////////////////////////////////////////
#pragma mark - UITableViewDelegate, UITableViewDataSource
////////////////////////////////////////////////////////////////////////

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        static NSString * const cellId = @"AlpEditPublishViewContentCell";
        AlpEditPublishViewContentCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        if (cell == nil) {
            cell = [[AlpEditPublishViewContentCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellId];
        }
        cell.videoURL = self.videoURL;
        return cell;
    }
    else if (indexPath.row == 1) {
        static NSString * const cellId = @"AlpEditPublishViewSelectLocationCell";
        AlpEditPublishViewSelectLocationCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        if (cell == nil) {
            cell = [[AlpEditPublishViewSelectLocationCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellId];
        }
        return cell;
    }
    else if (indexPath.row == 2) {
        static NSString * const cellId = @"AlpEditPublishViewPermissionCell";
        AlpEditPublishViewPermissionCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        if (cell == nil) {
            cell = [[AlpEditPublishViewPermissionCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellId];
        }
        return cell;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return 160.0;
    }
    if (indexPath.row == 1) {
        return 60.0;
    }
    if (indexPath.row == 2) {
        return 60.0;
    }
    return 0.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - AlpEditVideoNavigationBarDelegate
////////////////////////////////////////////////////////////////////////

- (void)editVideoNavigationBar:(AlpEditVideoNavigationBar *)bar didClickBackButton:(UIButton *)backButton {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.navigationController popViewControllerAnimated:YES];
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Lazy
////////////////////////////////////////////////////////////////////////

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    }
    return _tableView;
}

- (AlpEditVideoNavigationBar *)navigationBar {
    if (!_navigationBar) {
        _navigationBar = [AlpEditVideoNavigationBar new];
        _navigationBar.delegate = self;
    }
    return _navigationBar;
}

- (AlpEditPublishViewBottomView *)bottomView {
    if (!_bottomView) {
        _bottomView = [AlpEditPublishViewBottomView new];
        _bottomView.backgroundColor = [UIColor clearColor];
    }
    return _bottomView;
}

- (AlpEditPublishVideoModel *)publishModel {
    if (!_publishModel) {
        _publishModel = [AlpEditPublishVideoModel new];
    }
    return _publishModel;
}

@end

@implementation AlpEditPublishViewContentCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.contentView.backgroundColor = [UIColor clearColor];
        self.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.textView];
        [self.contentView addSubview:self.videoButton];
        [self.contentView addSubview:self.limitLabel];
        
        self.textView.translatesAutoresizingMaskIntoConstraints = false;
        self.videoButton.translatesAutoresizingMaskIntoConstraints = false;
        self.limitLabel.translatesAutoresizingMaskIntoConstraints = false;
        
        UIView *line = [UIView new];
        line.translatesAutoresizingMaskIntoConstraints = false;
        line.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
        [self.contentView addSubview:line];
        [NSLayoutConstraint constraintWithItem:line attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0].active = YES;
        [NSLayoutConstraint constraintWithItem:line attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeading multiplier:1.0 constant:10.0].active = YES;
        [NSLayoutConstraint constraintWithItem:line attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:-10.0].active = YES;
        [NSLayoutConstraint constraintWithItem:line attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:0.3].active = YES;
        
        [NSLayoutConstraint constraintWithItem:self.textView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1.0 constant:10.0].active = YES;
        [NSLayoutConstraint constraintWithItem:self.textView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:line attribute:NSLayoutAttributeTop multiplier:1.0 constant:-10.0].active = YES;
        [NSLayoutConstraint constraintWithItem:self.textView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:line attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0].active = YES;
        [NSLayoutConstraint constraintWithItem:self.textView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.videoButton attribute:NSLayoutAttributeLeading multiplier:1.0 constant:-10.0].active = YES;
        
        [NSLayoutConstraint constraintWithItem:self.videoButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.textView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0].active = YES;
        [NSLayoutConstraint constraintWithItem:self.videoButton attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.textView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0].active = YES;
        [NSLayoutConstraint constraintWithItem:self.videoButton attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:line attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0].active = YES;
        [NSLayoutConstraint constraintWithItem:self.videoButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:80.0].active = YES;
        
        [NSLayoutConstraint constraintWithItem:self.limitLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.textView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-SCREEN_LayoutScaleBaseOnIPHEN6(5)].active = YES;
        [NSLayoutConstraint constraintWithItem:self.limitLabel attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.textView attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:-SCREEN_LayoutScaleBaseOnIPHEN6(5)].active = YES;
        
    }
    return self;
}

- (void)setVideoURL:(NSURL *)videoURL {
    if (_videoURL == videoURL) {
        return;
    }
    _videoURL = videoURL;
    UIImage *thumbImage = [UIImage getThumbnailByVideoPath:[[_videoURL absoluteString ] stringByReplacingOccurrencesOfString:@"file://" withString:@""]];
    [self.videoButton setImage:thumbImage forState:UIControlStateNormal];
}

////////////////////////////////////////////////////////////////////////
#pragma mark - UITextViewDelegate
////////////////////////////////////////////////////////////////////////

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    if (textView.tag == 0) {
        textView.text = @"";
        textView.textColor = [UIColor whiteColor];
        textView.tag = 1;
    }
    return YES;
}
- (void)textViewDidChange:(UITextView *)textView {
    if ([textView.text length] == 0) {
        //        textView.text = @"说点什么吧...";
        //        textView.textColor = [UIColor lightGrayColor];
        //        textView.tag = 0 ;
    }
    NSString *lengthString;
    if ([textView.text length] > kSignatureContextLengths) {
        lengthString = [[NSString alloc] initWithFormat:@"内容超出:%lu/%d",(unsigned long)[textView.text length],kSignatureContextLengths];
        _limitLabel.textColor = [UIColor redColor];
        _isExceed_cai = YES;
    }
    else  {
        lengthString = [[NSString alloc] initWithFormat:@"%lu/%d",(unsigned long)[textView.text length],kSignatureContextLengths];
        _limitLabel.textColor = [UIColor blackColor];
        _isExceed_cai = NO;
    }
    _limitLabel.text = lengthString;
}
- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    if ([textView.text length] == 0) {
        textView.text = AlpContentTextFieldPlaceholder;
        textView.textColor = [UIColor lightGrayColor];
        textView.tag = 0 ;
    }
    return YES;
    
}

// 点击键盘完成后 收键盘
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if ([text isEqualToString:@"\n"]) {
        
        [self.textView resignFirstResponder];
        return NO;
    }
    
    return YES;
}


////////////////////////////////////////////////////////////////////////
#pragma mark -
////////////////////////////////////////////////////////////////////////

- (UITextView *)textView {
    if (!_textView) {
        _textView = [[UITextView alloc ] init];
        _textView.returnKeyType = UIReturnKeyDone;
        _textView.text = AlpContentTextFieldPlaceholder;
        _textView.textColor = [UIColor lightGrayColor];
        [_textView setFont:[UIFont systemFontOfSize:SCREEN_LayoutScaleBaseOnIPHEN6(15.0)]];
        [_textView setDelegate:self];
        _textView.backgroundColor = [UIColor clearColor];
    }
    return _textView;
}

- (UIButton *)videoButton {
    if (!_videoButton) {
        UIButton *videoButton = [[UIButton alloc] init];
        _videoButton = videoButton;
        videoButton.imageView.contentMode = UIViewContentModeScaleAspectFill;
        videoButton.clipsToBounds = YES;
        videoButton.layer.masksToBounds = YES;
        videoButton.layer.cornerRadius = 3;
    }
    return _videoButton;
}

- (UILabel *)limitLabel {
    if (!_limitLabel) {
        _limitLabel = [[UILabel alloc] init];
        _limitLabel.text = @"0/20";
        _limitLabel.font = [UIFont systemFontOfSize:SCREEN_LayoutScaleBaseOnIPHEN6(13.0)];
        _limitLabel.textColor = [UIColor blackColor];
    }
    return _limitLabel;
}

@end

@implementation AlpEditPublishViewSelectLocationCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.contentView.backgroundColor = [UIColor clearColor];
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleGray;
        
        [self.contentView addSubview:self.iconView];
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.arrowIconView];
        
        self.iconView.translatesAutoresizingMaskIntoConstraints = false;
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false;
        self.arrowIconView.translatesAutoresizingMaskIntoConstraints = false;
        
        [NSLayoutConstraint constraintWithItem:self.iconView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0].active = YES;
        [NSLayoutConstraint constraintWithItem:self.iconView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeading multiplier:1.0 constant:10.0].active = YES;
        [NSLayoutConstraint constraintWithItem:self.iconView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:20.0].active = YES;
        [NSLayoutConstraint constraintWithItem:self.iconView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:20.0].active = YES;
        
        [NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0].active = YES;
        [NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.iconView attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:10.0].active = YES;
        
        [NSLayoutConstraint constraintWithItem:self.arrowIconView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0].active = YES;
        [NSLayoutConstraint constraintWithItem:self.arrowIconView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:-10.0].active = YES;
        [NSLayoutConstraint constraintWithItem:self.arrowIconView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:20.0].active = YES;
        [NSLayoutConstraint constraintWithItem:self.arrowIconView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:20.0].active = YES;
        [NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationLessThanOrEqual toItem:self.arrowIconView attribute:NSLayoutAttributeLeading multiplier:1.0 constant:-10.0].active = YES;
        
    }
    return self;
}

- (UIImageView *)iconView {
    if (!_iconView) {
        _iconView = [UIImageView new];
        _iconView.contentMode = UIViewContentModeScaleAspectFill;
        _iconView.image = [UIImage imageNamed:@"icPoiNewPublishLocation_20x20_"];
    }
    return _iconView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.text = @"添加位置";
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.font = [UIFont systemFontOfSize:15.0];
    }
    return _titleLabel;
}

- (UIImageView *)arrowIconView {
    if (!_arrowIconView) {
        _arrowIconView = [UIImageView new];
        _arrowIconView.contentMode = UIViewContentModeScaleAspectFill;
        _arrowIconView.image = [UIImage imageNamed:@"arrow_alert_more_18x18_"];
    }
    return _arrowIconView;
}

@end

@implementation AlpEditPublishViewPermissionCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.contentView.backgroundColor = [UIColor clearColor];
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleGray;
        
        [self.contentView addSubview:self.iconView];
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.arrowIconView];
        [self.contentView addSubview:self.resultLabel];
        
        self.iconView.translatesAutoresizingMaskIntoConstraints = false;
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false;
        self.arrowIconView.translatesAutoresizingMaskIntoConstraints = false;
        self.resultLabel.translatesAutoresizingMaskIntoConstraints = false;
        [self.resultLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [self.resultLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        
        [NSLayoutConstraint constraintWithItem:self.iconView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0].active = YES;
        [NSLayoutConstraint constraintWithItem:self.iconView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeading multiplier:1.0 constant:10.0].active = YES;
        [NSLayoutConstraint constraintWithItem:self.iconView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:20.0].active = YES;
        [NSLayoutConstraint constraintWithItem:self.iconView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:20.0].active = YES;
        
        [NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0].active = YES;
        [NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.iconView attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:10.0].active = YES;
        
        [NSLayoutConstraint constraintWithItem:self.arrowIconView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0].active = YES;
        [NSLayoutConstraint constraintWithItem:self.arrowIconView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:-10.0].active = YES;
        [NSLayoutConstraint constraintWithItem:self.arrowIconView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:20.0].active = YES;
        [NSLayoutConstraint constraintWithItem:self.arrowIconView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:20.0].active = YES;
        
        [NSLayoutConstraint constraintWithItem:self.resultLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0].active = YES;
        [NSLayoutConstraint constraintWithItem:self.resultLabel attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.arrowIconView attribute:NSLayoutAttributeLeading multiplier:1.0 constant:-10.0].active = YES;
        
        [NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationLessThanOrEqual toItem:self.resultLabel attribute:NSLayoutAttributeLeading multiplier:1.0 constant:-10.0].active = YES;
        
    }
    return self;
}

- (UIImageView *)iconView {
    if (!_iconView) {
        _iconView = [UIImageView new];
        _iconView.contentMode = UIViewContentModeScaleAspectFill;
        _iconView.image = [UIImage imageNamed:@"icon_publicVideoImage_20x20_"];
    }
    return _iconView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.text = @"谁可以看";
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.font = [UIFont systemFontOfSize:15.0];
    }
    return _titleLabel;
}

- (UIImageView *)arrowIconView {
    if (!_arrowIconView) {
        _arrowIconView = [UIImageView new];
        _arrowIconView.contentMode = UIViewContentModeScaleAspectFill;
        _arrowIconView.image = [UIImage imageNamed:@"arrow_alert_more_18x18_"];
    }
    return _arrowIconView;
}

- (UILabel *)resultLabel {
    if (!_resultLabel) {
        _resultLabel = [UILabel new];
        _resultLabel.text = @"公开";
        _resultLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8];
        _resultLabel.font = [UIFont systemFontOfSize:13.0];
    }
    return _resultLabel;
}

@end

@implementation AlpEditPublishViewBottomView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    [self addSubview:self.titleLabel];
    [self addSubview:self.draftButton];
    [self addSubview:self.publishButton];
    [self addSubview:self.saveAlbumButton];
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = false;
    self.draftButton.translatesAutoresizingMaskIntoConstraints = false;
    self.publishButton.translatesAutoresizingMaskIntoConstraints = false;
    self.saveAlbumButton.translatesAutoresizingMaskIntoConstraints = false;
    
    [NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:10.0].active = YES;
    [NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1.0 constant:10.0].active = YES;
    [NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationLessThanOrEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:-10.0].active = YES;
    
    [NSLayoutConstraint constraintWithItem:self.saveAlbumButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.titleLabel attribute:NSLayoutAttributeBottom multiplier:1.0 constant:10.0].active = YES;
    [NSLayoutConstraint constraintWithItem:self.saveAlbumButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:18.0].active = YES;
    [NSLayoutConstraint constraintWithItem:self.saveAlbumButton attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:-10.0].active = YES;
    
    [NSLayoutConstraint constraintWithItem:self.draftButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.saveAlbumButton attribute:NSLayoutAttributeBottom multiplier:1.0 constant:10.0].active = YES;
    [NSLayoutConstraint constraintWithItem:self.draftButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:50.0].active = YES;
    [NSLayoutConstraint constraintWithItem:self.draftButton attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1.0 constant:10.0].active = YES;
    [NSLayoutConstraint constraintWithItem:self.draftButton attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-20.0].active = YES;
    [NSLayoutConstraint constraintWithItem:self.draftButton attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.publishButton attribute:NSLayoutAttributeLeading multiplier:1.0 constant:-5.0].active = YES;
    
    [NSLayoutConstraint constraintWithItem:self.publishButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.draftButton attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0].active = YES;
    [NSLayoutConstraint constraintWithItem:self.publishButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.draftButton attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0].active = YES;
    [NSLayoutConstraint constraintWithItem:self.publishButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.draftButton attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0].active = YES;
    [NSLayoutConstraint constraintWithItem:self.publishButton attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:-10.0].active = YES;
    [NSLayoutConstraint constraintWithItem:self.publishButton attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.draftButton attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0].active = YES;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.text = @"同步视频至";
        _titleLabel.textColor = [[[UIColor whiteColor] colorWithAlphaComponent:0.8] colorWithAlphaComponent:0.8];
        _titleLabel.font = [UIFont systemFontOfSize:12.0];
    }
    return _titleLabel;
}

- (UIButton *)draftButton {
    if (!_draftButton) {
        _draftButton = [UIButton new];
        [_draftButton setImage:[UIImage imageNamed:@"icon_draft_20x20_"] forState:UIControlStateNormal];
        [_draftButton setTitle:@"草稿" forState:UIControlStateNormal];
        [_draftButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_draftButton setBackgroundColor:[UIColor lightGrayColor]];
        _draftButton.titleLabel.font = [UIFont systemFontOfSize:15.0];
    }
    return _draftButton;
}

- (UIButton *)publishButton {
    if (!_publishButton) {
        _publishButton = [UIButton new];
        [_publishButton setImage:[UIImage imageNamed:@"icon_release_small_20x20_"] forState:UIControlStateNormal];
        [_publishButton setTitle:@"发布" forState:UIControlStateNormal];
        [_publishButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_publishButton setBackgroundColor:[UIColor redColor]];
        _publishButton.titleLabel.font = [UIFont systemFontOfSize:15.0];
    }
    return _publishButton;
}

- (UIButton *)saveAlbumButton {
    if (!_saveAlbumButton) {
        _saveAlbumButton = [UIButton new];
        [_saveAlbumButton setImage:[UIImage imageNamed:@"icon_send_save_yes_12x12_"] forState:UIControlStateNormal];
        [_saveAlbumButton setImage:[UIImage imageNamed:@"icon_send_save_no_12x12_"] forState:UIControlStateSelected];
        [_saveAlbumButton setTitle:@"保存本地" forState:UIControlStateNormal];
        [_saveAlbumButton setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
        _saveAlbumButton.titleLabel.font = [UIFont systemFontOfSize:12.0];
        
    }
    return _saveAlbumButton;
}

@end

@implementation AlpEditPublishVideoModel



@end

@implementation AlpEditPublishViewLocationListCell



@end
