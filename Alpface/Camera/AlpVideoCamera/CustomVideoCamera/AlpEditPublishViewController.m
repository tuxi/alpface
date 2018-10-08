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
#import "MBProgressHUD+XYHUD.h"
#import "XYLocationSearchViewController.h"
#import "XYLocationManager.h"
#import "XYLocationSearchTableViewModel.h"
#import <CoreLocation/CoreLocation.h>
#import "AlpEditPublishLocationListTableViewCellModel.h"
#import <AddressBookUI/AddressBookUI.h>
#import "AlpEditPublishVideoModel.h"

@interface AlpEditPublishViewContentCell : UITableViewCell <UITextViewDelegate>

@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UIButton *videoButton;
@property (nonatomic, strong) NSURL *videoURL;
@property (strong, nonatomic) UILabel *limitLabel;
@property BOOL isExceed_cai;

@property (nonatomic, strong) AlpEditPublishTableViewCellModel *cellModel;

@end

@interface AlpEditPublishViewSelectLocationCell : UITableViewCell

@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *arrowIconView;

@property (nonatomic, strong) AlpEditPublishTableViewCellModel *cellModel;

@end

@interface AlpEditPublishViewPermissionCell : UITableViewCell

@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *arrowIconView;
@property (nonatomic, strong) UILabel *resultLabel;

@property (nonatomic, strong) AlpEditPublishTableViewCellModel *cellModel;

@end

@interface AlpEditPublishViewLocationListCell : UITableViewCell <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) AlpEditPublishLocationListTableViewCellModel *cellModel;
@property (nonatomic, strong) UIButton *searchButton;
@property (nonatomic, strong) UICollectionView *collectionView;

@end

@interface AlpEditPublishViewBottomView : UIView

@property (nonatomic, strong) UIButton *draftButton;
@property (nonatomic, strong) UIButton *publishButton;
@property (nonatomic, strong) UIButton *saveAlbumButton;
@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, copy) void (^clickDraftButtonBlock)(UIButton *button);
@property (nonatomic, copy) void (^clickPublishButtonBlock)(UIButton *button);
@property (nonatomic, copy) void (^clickSaveAlbumButtonBlock)(BOOL isSave);

@end

@interface AlpEditPublishViewController () <UITableViewDelegate, UITableViewDataSource, XYLocationSearchViewControllerDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) AlpEditVideoNavigationBar *navigationBar;
@property (nonatomic, strong) AlpEditPublishViewBottomView *bottomView;
@property (nonatomic, strong) AlpEditPublishVideoModel *publishModel;
@property (nonatomic, strong) UIButton *maskView;
@property (nonatomic, weak) UIVisualEffectView* visualEffectView;
@property (nonatomic, weak) NSLayoutConstraint *maskViewTopConstraint;
@property (nonatomic, strong) NSMutableArray *cellModels;
@property (nonatomic, strong) XYLocationSearchTableViewModel *nearbyPoiViewModel;

@end

@implementation AlpEditPublishViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initData];
    [self setupUI];
    [self initObserver];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNeedsStatusBarAppearanceUpdate];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (void)initObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)initData {
    
    {
        // 标题cell
        AlpEditPublishTableViewCellModel *m = [AlpEditPublishTableViewCellModel new];
        m.cellClass = [AlpEditPublishViewContentCell class];
        m.model = self.videoURL;
        m.cellHeight = 160.0;
        m.cellShouldHighlight = NO;
        [self.cellModels addObject:m];
    }
    
    {
        // 添加位置cell
        AlpEditPublishTableViewCellModel *m = [AlpEditPublishTableViewCellModel new];
        m.cellClass = [AlpEditPublishViewSelectLocationCell class];
        m.cellHeight = 60.0;
        [self.cellModels addObject:m];
    }
    {
        // 位置列表cell
        AlpEditPublishLocationListTableViewCellModel *m = [AlpEditPublishLocationListTableViewCellModel new];
        m.cellClass = [AlpEditPublishViewLocationListCell class];
        m.cellHeight = 40.0;
        m.cellShouldHighlight = NO;
        __weak typeof(self) weakSelf = self;
        m.selectMapItemBlock = ^(AlpEditPublishLocationModel *  _Nonnull location) {
            AlpEditPublishLocationListTableViewCellModel *locationListCellModel = weakSelf.cellModels[2];
            for (AlpEditPublishLocationModel *location in (NSArray *)locationListCellModel.model) {
                location.selected = NO;
            }
            location.selected = YES;
            
            // update UI
            AlpEditPublishTableViewCellModel *cellModel = weakSelf.cellModels[1];
            cellModel.model = location.item;
            [weakSelf.tableView reloadData];
            weakSelf.publishModel.locationName = location.item.name;
            NSString *address = ABCreateStringWithAddressDictionary(location.item.placemark.addressDictionary, NO);
            address = [address stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
            weakSelf.publishModel.address = address;
            weakSelf.publishModel.coordinate = location.item.placemark.coordinate;
        };
        [self.cellModels addObject:m];
    }
    {
        // 查看权限cell
        AlpEditPublishTableViewCellModel *m = [AlpEditPublishTableViewCellModel new];
        m.cellClass = [AlpEditPublishViewPermissionCell class];
        m.cellHeight = 60.0;
        [self.cellModels addObject:m];
    }
    
    [[XYLocationManager sharedManager] getAuthorization];
    [[XYLocationManager sharedManager] startLocation];
    self.automaticallyAdjustsScrollViewInsets = NO;
    if ([[XYLocationManager sharedManager] getGpsPostion]) {
        [self updateLocationsNotification];
    }
    else {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateLocationsNotification) name:XYUpdateLocationsNotification object:nil];
        
    }
    self.publishModel.startSecondsOfCover = self.startSecondsOfCover;
    self.publishModel.endSecondsOfCover = self.endSecondsOfCover;
}

- (void)updateLocationsNotification {
    __weak typeof(self) weakSelf = self;
    [self.nearbyPoiViewModel fetchNearbyInfoCompletionHandler:^(NSArray<MKMapItem *> *searchResult, NSError *error) {
        AlpEditPublishLocationListTableViewCellModel *m = weakSelf.cellModels[2];
        NSMutableArray *array = @[].mutableCopy;
        for (MKMapItem *map in searchResult) {
            AlpEditPublishLocationModel *location = [AlpEditPublishLocationModel new];
            location.item = map;
            location.clickLocationButtonBlock = ^(AlpEditPublishLocationModel * _Nonnull model) {
                
                if (m.selectMapItemBlock) {
                    m.selectMapItemBlock(model);
                }
            };
            [array addObject:location];
        }
        m.model = array;
        [weakSelf.tableView reloadData];
    }];
}

- (void)setupUI {
    self.navigationController.navigationBarHidden = YES;
    //    self.view.alpha = .8;
    self.view.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.navigationBar];
    self.navigationBar.titleLabel.text = @"发布";
    self.navigationBar.translatesAutoresizingMaskIntoConstraints = false;
    [self.navigationBar.leftButton addTarget:self action:@selector(didClickBackButton) forControlEvents:UIControlEventTouchUpInside];
    if (@available(iOS 11.0, *)) {
        [NSLayoutConstraint constraintWithItem:self.navigationBar attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view.safeAreaLayoutGuide attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0].active = YES;
    } else {
        [NSLayoutConstraint constraintWithItem:self.navigationBar attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0].active = YES;
    }
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
    if (@available(iOS 11.0, *)) {
        [NSLayoutConstraint constraintWithItem:self.bottomView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view.safeAreaLayoutGuide attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0].active = YES;
    } else {
        [NSLayoutConstraint constraintWithItem:self.bottomView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0].active = YES;
    }
    [NSLayoutConstraint constraintWithItem:self.bottomView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0].active = YES;
    [NSLayoutConstraint constraintWithItem:self.bottomView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0].active = YES;
    
    [self.view addSubview:self.maskView];
    [NSLayoutConstraint constraintWithItem:self.maskView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0].active = YES;
    [NSLayoutConstraint constraintWithItem:self.maskView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0].active = YES;
    [NSLayoutConstraint constraintWithItem:self.maskView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0].active = YES;
    NSLayoutConstraint *maskViewTopConstraint = [NSLayoutConstraint constraintWithItem:self.maskView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.tableView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0];
    maskViewTopConstraint.active = YES;
    _maskViewTopConstraint = maskViewTopConstraint;
    
    UIBlurEffect *blurEffrct =[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    // 毛玻璃视图
    UIVisualEffectView* visualEffectView = [[UIVisualEffectView alloc]initWithEffect:blurEffrct];
    visualEffectView.alpha = 0.8;
    _visualEffectView = visualEffectView;
    [self.maskView addSubview:visualEffectView];
    visualEffectView.userInteractionEnabled = NO;
    visualEffectView.translatesAutoresizingMaskIntoConstraints = false;
    [NSLayoutConstraint constraintWithItem:visualEffectView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.maskView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0].active = YES;
    [NSLayoutConstraint constraintWithItem:visualEffectView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.maskView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0].active = YES;
    [NSLayoutConstraint constraintWithItem:visualEffectView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.maskView attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0].active = YES;
    [NSLayoutConstraint constraintWithItem:visualEffectView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.maskView attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0].active = YES;
    
}

- (void)setVideoURL:(NSURL *)videoURL {
    _videoURL = videoURL;
    self.publishModel.videoURL = videoURL;
    AlpEditPublishTableViewCellModel *cellModel = [self.cellModels firstObject];
    cellModel.model = videoURL;
    [self.tableView reloadData];
}

- (void)setMaskViewHidden:(BOOL)hidden animateDuration:(CGFloat)duration {
    
    if (hidden) {
        self.visualEffectView.alpha = 0.0;
    }
    else {
        self.visualEffectView.hidden = hidden;
        self.visualEffectView.alpha = 0.8;
    }
    
    duration = fabs(duration);
    if (duration) {
        [UIView animateWithDuration:duration animations:^{
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            self.maskView.hidden = hidden;
        }];
    }
    else {
        self.maskView.hidden = hidden;
    }
}

////////////////////////////////////////////////////////////////////////
#pragma mark - UITableViewDelegate, UITableViewDataSource
////////////////////////////////////////////////////////////////////////

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.cellModels.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AlpEditPublishTableViewCellModel *cellModel = self.cellModels[indexPath.row];
    Class cellClass = cellModel.cellClass;
    NSString * cellId = NSStringFromClass(cellClass);
    AlpEditPublishViewContentCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[cellClass alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellId];
    }
    cell.cellModel = cellModel;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    AlpEditPublishTableViewCellModel *cellModel = self.cellModels[indexPath.row];
    if (indexPath.row == 0) {
        self.maskViewTopConstraint.constant = cellModel.cellHeight;
    }
    return cellModel.cellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    AlpEditPublishTableViewCellModel *cellModel = self.cellModels[indexPath.row];
    if (cellModel.cellClass == [AlpEditPublishViewSelectLocationCell class]) {
        XYLocationSearchViewController *vc = [XYLocationSearchViewController new];
        vc.delegate = self;
        // modal 半透明样式
        UINavigationController *nac = [[UINavigationController alloc] initWithRootViewController:vc];
        nac.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        [self presentViewController:nac animated:YES completion:nil];
        vc.title = @"添加位置";
    }
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    AlpEditPublishTableViewCellModel *cellModel = self.cellModels[indexPath.row];
    return cellModel.cellShouldHighlight;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Notification
////////////////////////////////////////////////////////////////////////

/// 键盘显示事件
- (void) keyboardWillShow:(NSNotification *)notification {
    self.tableView.scrollEnabled = NO;
    // 取得键盘的动画时间，这样可以在视图上移的时候更连贯
    double duration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [self setMaskViewHidden:NO animateDuration:duration];
}

/// 键盘消失事件
- (void) keyboardWillHide:(NSNotification *)notification {
    self.tableView.scrollEnabled = YES;
    // 取得键盘的动画时间，这样可以在视图上移的时候更连贯
    double duration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [self setMaskViewHidden:YES animateDuration:duration];
}


////////////////////////////////////////////////////////////////////////
#pragma mark - Actions
////////////////////////////////////////////////////////////////////////

- (void)didClickBackButton {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.navigationController popViewControllerAnimated:YES];
}
////////////////////////////////////////////////////////////////////////
#pragma mark - XYLocationSearchViewControllerDelegate
////////////////////////////////////////////////////////////////////////
- (void)locationSearchViewController:(UIViewController *)sender didSelectLocationWithName:(NSString *)name address:(NSString *)address mapItem:(MKMapItem *)mapItm {
    
    CLLocationCoordinate2D coordinate;
    if (mapItm == nil) {
        // 选择的当前位置
        coordinate = [XYLocationManager sharedManager].coordinate;
        MKPlacemark *placeMark = [[MKPlacemark alloc] initWithCoordinate:coordinate];
        mapItm = [[MKMapItem alloc] initWithPlacemark:placeMark];
        mapItm.name = name;
        
    }
    else {
        CLLocation *location = [mapItm.placemark performSelector:@selector(location)];
        coordinate  = location.coordinate;
    }
    
    // update UI
    AlpEditPublishTableViewCellModel *cellModel = self.cellModels[1];
    cellModel.model = mapItm;
    [self.tableView reloadData];
    [sender.navigationController dismissViewControllerAnimated:YES completion:nil];
    self.publishModel.locationName = name;
    self.publishModel.address = address;
    self.publishModel.coordinate = coordinate;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Actions
////////////////////////////////////////////////////////////////////////

- (void)maskViewClick:(id)sender {
    [self.view endEditing:YES];
}

- (void)releaseVideo {
    AlpEditPublishViewContentCell *contentCell = (id)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
//    AlpEditPublishViewSelectLocationCell *locationCell = (id)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
//    AlpEditPublishViewPermissionCell *permissionCell = (id)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];

    
    if (_videoURL == nil) {
        [self.view xy_showMessage:@"还未选择视频..."];
        return;
    }
    
    if (contentCell.textView.text.length == 0 ||
        [contentCell.textView.text isEqualToString:AlpContentTextFieldPlaceholder]) {
        [self.view xy_showMessage:@"请添加标题和描述文本"];
        return;
    }
    self.publishModel.content = contentCell.textView.text;
    self.publishModel.title = @"test";
    if (self.publishModel.isSaveAlbum) {
        [self.view xy_showMessage:@"正在保存到相册..."];
        NSString *videoPath = [[_videoURL absoluteString ] stringByReplacingOccurrencesOfString:@"file://" withString:@""];
        UISaveVideoAtPathToSavedPhotosAlbum(videoPath, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
        
    } 
    [[NSNotificationCenter defaultCenter] postNotificationName:AlpDidClickPublushVideoNotification object:nil userInfo:@{@"publishKey": self.publishModel}];
}

- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    
    NSLog(@"%@", videoPath);
    
    if (error) {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Video Saving Failed" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Video Saved" message:@"Save To Photo Album" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    }
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
    }
    return _navigationBar;
}

- (AlpEditPublishViewBottomView *)bottomView {
    if (!_bottomView) {
        _bottomView = [AlpEditPublishViewBottomView new];
        _bottomView.backgroundColor = [UIColor clearColor];
        __weak typeof(self) weakSelf = self;
        _bottomView.clickSaveAlbumButtonBlock = ^(BOOL isSave) {
            weakSelf.publishModel.saveAlbum = isSave;
        };
        _bottomView.clickDraftButtonBlock = ^(UIButton *button) {
            
        };
        _bottomView.clickPublishButtonBlock = ^(UIButton *button) {
            [weakSelf releaseVideo];
        };
    }
    return _bottomView;
}

- (AlpEditPublishVideoModel *)publishModel {
    if (!_publishModel) {
        _publishModel = [AlpEditPublishVideoModel new];
    }
    return _publishModel;
}

- (UIButton *)maskView {
    if (!_maskView) {
        _maskView = [UIButton new];
        _maskView.translatesAutoresizingMaskIntoConstraints = false;
        _maskView.backgroundColor = [UIColor clearColor];
        _maskView.hidden = YES;
        [_maskView addTarget:self action:@selector(maskViewClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _maskView;
}

- (NSMutableArray *)cellModels {
    if (!_cellModels) {
        _cellModels = @[].mutableCopy;
    }
    return _cellModels;
}

- (XYLocationSearchTableViewModel *)nearbyPoiViewModel {
    if (!_nearbyPoiViewModel) {
        _nearbyPoiViewModel = [XYLocationSearchTableViewModel new];
    }
    return _nearbyPoiViewModel;
}

@end

@implementation AlpEditPublishViewContentCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
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

- (void)setCellModel:(AlpEditPublishTableViewCellModel *)cellModel {
    _cellModel = cellModel;
    self.videoURL = cellModel.model;
}

- (void)setVideoURL:(NSURL *)videoURL {
    if (_videoURL == videoURL) {
        return;
    }
    _videoURL = videoURL;
    UIImage *thumbImage = [UIImage getThumbnailByVideoPath:[[_videoURL absoluteString ] stringByReplacingOccurrencesOfString:@"file://" withString:@""]];
    // file:///private/var/mobile/Containers/Data/Application/7460F046-6F5F-46F7-BD31-A1F1ADDDD61D/tmp/compressedVideo20180919200614.mp4
    // file:///private/var/mobile/Containers/Data/Application/7460F046-6F5F-46F7-BD31-A1F1ADDDD61D/tmp/compressedVideo20180919200705.mp4
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
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
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

- (void)setCellModel:(AlpEditPublishTableViewCellModel *)cellModel {
    _cellModel = cellModel;
    if (cellModel.model == nil) {
        _titleLabel.text = @"添加位置";
    }
    else {
        MKMapItem *item = cellModel.model;
        _titleLabel.text = item.name;
    }
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
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
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

////////////////////////////////////////////////////////////////////////
#pragma mark - Actions
////////////////////////////////////////////////////////////////////////

- (void)draftButtonClick:(id)sender {
    if (self.clickDraftButtonBlock) {
        self.clickDraftButtonBlock(sender);
    }
}

- (void)publishButtonClick:(id)sender {
    if (self.clickPublishButtonBlock) {
        self.clickPublishButtonBlock(sender);
    }
}

- (void)saveAlbumButtonClick:(UIButton *)sender {
    sender.selected = !sender.isSelected;
    if (self.clickSaveAlbumButtonBlock) {
        self.clickSaveAlbumButtonBlock(!sender.selected);
    }
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Lazy
////////////////////////////////////////////////////////////////////////

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.text = @"同步视频至";
        _titleLabel.textColor = [[[UIColor whiteColor] colorWithAlphaComponent:0.8] colorWithAlphaComponent:0.8];
        _titleLabel.font = [UIFont systemFontOfSize:15.0];
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
        _draftButton.layer.cornerRadius = 1.0;
        _draftButton.layer.masksToBounds = YES;
        [_draftButton addTarget:self action:@selector(draftButtonClick:) forControlEvents:UIControlEventTouchUpInside];
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
        _publishButton.layer.cornerRadius = 1.0;
        _publishButton.layer.masksToBounds = YES;
        [_publishButton addTarget:self action:@selector(publishButtonClick:) forControlEvents:UIControlEventTouchUpInside];
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
        [_saveAlbumButton addTarget:self action:@selector(saveAlbumButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _saveAlbumButton;
}

@end

@interface AlpEditPublishViewLocationListCellCollectionCell : UICollectionViewCell
@property (nonatomic, strong) UIButton *titleButton;
@property (nonatomic) AlpEditPublishLocationModel *locationModel;
@end

@implementation AlpEditPublishViewLocationListCell {
    NSArray<AlpEditPublishLocationModel *> *_pois;
    NSLayoutConstraint *_searchButtonWidthConstraint;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.contentView.backgroundColor = [UIColor clearColor];
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self.contentView addSubview:self.searchButton];
        self.searchButton.translatesAutoresizingMaskIntoConstraints = false;
        [NSLayoutConstraint constraintWithItem:self.searchButton attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeading multiplier:1.0 constant:10.0].active = YES;
        [NSLayoutConstraint constraintWithItem:self.searchButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0].active = YES;
        [NSLayoutConstraint constraintWithItem:self.searchButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:20.0].active = YES;
        _searchButtonWidthConstraint = [NSLayoutConstraint constraintWithItem:self.searchButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:0.0];
        
        [self.contentView addSubview:self.collectionView];
        self.collectionView.translatesAutoresizingMaskIntoConstraints = false;
        [NSLayoutConstraint constraintWithItem:self.collectionView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.searchButton attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0].active = YES;
        [NSLayoutConstraint constraintWithItem:self.collectionView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:-10.0].active = YES;
        [NSLayoutConstraint constraintWithItem:self.collectionView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0].active = YES;
        [NSLayoutConstraint constraintWithItem:self.collectionView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0].active = YES;
    }
    return self;
}

- (UIButton *)searchButton {
    if (!_searchButton) {
        _searchButton = [UIButton new];
        [_searchButton setTitle:@"查看更多" forState:UIControlStateNormal];
        [_searchButton setImage:[UIImage imageNamed:@"icSearshSugbarSearch_24x24_"] forState:UIControlStateNormal];
        _searchButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
        _searchButton.layer.masksToBounds = YES;
        _searchButton.layer.cornerRadius = 10.0;
        _searchButton.layer.borderWidth = 0.5;
        _searchButton.layer.borderColor = [UIColor whiteColor].CGColor;
        [_searchButton setBackgroundColor:[UIColor orangeColor]];
        [_searchButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _searchButton.titleLabel.font = [UIFont systemFontOfSize:10.0];
        [_searchButton setContentEdgeInsets:UIEdgeInsetsMake(0.0, 5.0, 0.0, 10.0)];
    }
    return _searchButton;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        // 设置预估size，真实size自适应
        layout.estimatedItemSize = CGSizeMake(30.0, 20.0);
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.minimumInteritemSpacing = 10.0;
        layout.minimumLineSpacing = 10.0;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [_collectionView registerClass:[AlpEditPublishViewLocationListCellCollectionCell class] forCellWithReuseIdentifier:@"AlpEditPublishViewLocationListCellCollection"];
    }
    return _collectionView;
}

- (void)setCellModel:(AlpEditPublishLocationListTableViewCellModel *)cellModel {
    _cellModel = cellModel;
    _pois = cellModel.model;
    if (_pois) {
        self.searchButton.hidden = YES;
        _searchButtonWidthConstraint.active = YES;
    }
    else {
        _searchButtonWidthConstraint.active = NO;
        self.searchButton.hidden = NO;
    }
    [self.collectionView reloadData];
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
////////////////////////////////////////////////////////////////////////
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _pois.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    AlpEditPublishViewLocationListCellCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AlpEditPublishViewLocationListCellCollection" forIndexPath:indexPath];
    AlpEditPublishLocationModel *location = _pois[indexPath.row];
    cell.locationModel = location;
    return cell;
}
//- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
//    AlpEditPublishLocationModel *location = _pois[indexPath.row];
//    for (AlpEditPublishLocationModel *location in _pois) {
//        location.selected = NO;
//    }
//    location.selected = YES;
//    if (self.cellModel.selectMapItemBlock) {
//        self.cellModel.selectMapItemBlock(location);
//    }
//    [collectionView reloadData];
//}
@end


@implementation AlpEditPublishViewLocationListCellCollectionCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:10.0];
        button.titleLabel.textAlignment = NSTextAlignmentCenter;
        button.titleLabel.numberOfLines = 1;
        button.backgroundColor = [UIColor darkGrayColor];
        button.layer.cornerRadius = 10.0;
        button.layer.masksToBounds = YES;
        [button setContentEdgeInsets:UIEdgeInsetsMake(5.0, 5.0, 5.0, 5.0)];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        _titleButton = button;
        [_titleButton setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
        [_titleButton setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [self.contentView addSubview:_titleButton];
        _titleButton.translatesAutoresizingMaskIntoConstraints = false;
        [NSLayoutConstraint constraintWithItem:_titleButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0].active = YES;
        [NSLayoutConstraint constraintWithItem:_titleButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0].active = YES;
        [NSLayoutConstraint constraintWithItem:_titleButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0].active = YES;
        [NSLayoutConstraint constraintWithItem:_titleButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0].active = YES;
    }
    return self;
}
/// 计算cell的size
- (UICollectionViewLayoutAttributes*)preferredLayoutAttributesFittingAttributes:(UICollectionViewLayoutAttributes*)layoutAttributes {
    
    [self.contentView setNeedsLayout];
    
    [self.contentView layoutIfNeeded];
    
    CGSize size = [self.contentView systemLayoutSizeFittingSize: layoutAttributes.size];
    
    CGRect cellFrame = layoutAttributes.frame;
    
    cellFrame.size.height= size.height;
    cellFrame.size.width = size.width;
    layoutAttributes.frame= cellFrame;
    
    return layoutAttributes;
    
}


- (void)setLocationModel:(AlpEditPublishLocationModel *)locationModel {
    _locationModel = locationModel;
    [self.titleButton setTitle:locationModel.item.name forState:UIControlStateNormal];
    _titleButton.selected = locationModel.isSelected;
    if (locationModel.isSelected) {
        _titleButton.backgroundColor = [UIColor orangeColor];
    }
    else {
        _titleButton.backgroundColor = [UIColor darkGrayColor];
    }
}

- (void)buttonClick:(UIButton *)sender {
    if (self.locationModel.clickLocationButtonBlock) {
        self.locationModel.clickLocationButtonBlock(self.locationModel);
    }
}

@end
