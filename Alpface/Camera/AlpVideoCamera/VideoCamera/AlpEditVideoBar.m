//
//  AlpEditVideoBar.m
//  Alpface
//
//  Created by swae on 2018/9/17.
//  Copyright © 2018 alpface. All rights reserved.
//

#import "AlpEditVideoBar.h"
#import "AlpMusicItemCollectionViewCell.h"
#import "AlpVideoCameraDefine.h"

typedef NS_ENUM(NSUInteger , AlpChooseEditType) {
    AlpChooseEditTypeFilter = 1,
    AlpChooseEditTypeMusic = 2,
    AlpChooseEditTypeStickers = 3,
};

@interface AlpEditVideoBar () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *musicCollectionView;
@property (nonatomic, strong) UICollectionView *filterCollectionView;
@property (nonatomic, strong) UICollectionView *stickersCollectionView;
@property (nonatomic, strong) UIVisualEffectView *visualEffectView;
@property (nonatomic, strong) UIButton *filterButton;
@property (nonatomic, strong) UIButton *musicButton;
@property (nonatomic, strong) UIButton *stickersBtn;
@property (nonatomic, strong) UISwitch *editTheOriginaSwitch;
@property (nonatomic, strong) UIButton *editTheOriginaBtn;
@property (nonatomic, strong) NSString *audioPath;
@property (nonatomic, strong) NSIndexPath *lastFilterIndex;
@property (nonatomic, strong) NSIndexPath *lastMusicIndex;
@property (nonatomic, strong) NSIndexPath *nowMusicIndex;
@property (nonatomic, strong) NSIndexPath *nowFilterIndex;
@property (nonatomic, strong) NSIndexPath *lastStickersIndex;
@property (nonatomic, strong) NSIndexPath *nowStickersIndex;
@property (nonatomic, assign) AlpChooseEditType chooseEditType;

@end

@implementation AlpEditVideoBar

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void) setup {
    
    _lastMusicIndex = [NSIndexPath indexPathForRow:0 inSection:0];
    _lastFilterIndex = [NSIndexPath indexPathForRow:0 inSection:0];
    _lastStickersIndex = [NSIndexPath indexPathForRow:0 inSection:0];
    
    
    UIBlurEffect *blurEffrct =[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    
    //毛玻璃视图
    _visualEffectView = [[UIVisualEffectView alloc]initWithEffect:blurEffrct];
    //    _visualEffectView.alpha = 1;
    [self addSubview:_visualEffectView];
    _visualEffectView.translatesAutoresizingMaskIntoConstraints = false;
    [NSLayoutConstraint constraintWithItem:_visualEffectView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0].active = YES;
    [NSLayoutConstraint constraintWithItem:_visualEffectView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0].active = YES;
    [NSLayoutConstraint constraintWithItem:_visualEffectView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0].active = YES;
    [NSLayoutConstraint constraintWithItem:_visualEffectView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0].active = YES;
    
    _filterButton = [[UIButton alloc] init];
    [_filterButton setTitle:@"滤镜" forState:UIControlStateNormal];
    [_filterButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
    [_filterButton setTitleColor:[UIColor colorWithRed:250/256.0 green:211/256.0 blue:75/256.0 alpha:1] forState:UIControlStateSelected];
    [_filterButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    _filterButton.backgroundColor = [UIColor clearColor];
    [_filterButton addTarget:self action:@selector(clickCancleBtn) forControlEvents:UIControlEventTouchUpInside];
     _filterButton.translatesAutoresizingMaskIntoConstraints = false;
    [self addSubview:_filterButton];
    [NSLayoutConstraint constraintWithItem:_filterButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0].active = YES;
    [NSLayoutConstraint constraintWithItem:_filterButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:45.0].active = YES;
    [NSLayoutConstraint constraintWithItem:_filterButton attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0].active = YES;
    [NSLayoutConstraint constraintWithItem:_filterButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:SCREEN_LayoutScaleBaseOnIPHEN6(83)].active = YES;
   
    _filterButton.selected = YES;
    self.chooseEditType = AlpChooseEditTypeFilter;
    
    _musicButton = [[UIButton alloc] init];
    [_musicButton setTitle:@"音乐" forState:UIControlStateNormal];
    [_musicButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
    [_musicButton setTitleColor:[UIColor colorWithRed:250/256.0 green:211/256.0 blue:75/256.0 alpha:1] forState:UIControlStateSelected];
    [_musicButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    _musicButton.backgroundColor = [UIColor clearColor];
    [_musicButton addTarget:self action:@selector(clickOKBtn) forControlEvents:UIControlEventTouchUpInside];
    _musicButton.translatesAutoresizingMaskIntoConstraints = false;
    [self addSubview:_musicButton];
    [NSLayoutConstraint constraintWithItem:_musicButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:.0].active = YES;
    [NSLayoutConstraint constraintWithItem:_musicButton attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:_filterButton attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:.0].active = YES;
    [NSLayoutConstraint constraintWithItem:_musicButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:_filterButton attribute:NSLayoutAttributeHeight multiplier:1.0 constant:.0].active = YES;
    [NSLayoutConstraint constraintWithItem:_musicButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:_filterButton attribute:NSLayoutAttributeWidth multiplier:1.0 constant:.0].active = YES;
    
    
    _stickersBtn = [[UIButton alloc] init];
    [_stickersBtn setTitle:@"贴纸" forState:UIControlStateNormal];
    [_stickersBtn.titleLabel setFont:[UIFont systemFontOfSize:15]];
    [_stickersBtn setTitleColor:[UIColor colorWithRed:250/256.0 green:211/256.0 blue:75/256.0 alpha:1] forState:UIControlStateSelected];
    [_stickersBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    _stickersBtn.backgroundColor = [UIColor clearColor];
    [_stickersBtn addTarget:self action:@selector(clickStickersBtn) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_stickersBtn];
    _stickersBtn.translatesAutoresizingMaskIntoConstraints = false;
    [NSLayoutConstraint constraintWithItem:_stickersBtn attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:.0].active = YES;
    [NSLayoutConstraint constraintWithItem:_stickersBtn attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:_musicButton attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:.0].active = YES;
    [NSLayoutConstraint constraintWithItem:_stickersBtn attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:_filterButton attribute:NSLayoutAttributeHeight multiplier:1.0 constant:.0].active = YES;
    [NSLayoutConstraint constraintWithItem:_stickersBtn attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:_filterButton attribute:NSLayoutAttributeWidth multiplier:1.0 constant:.0].active = YES;
    
    _editTheOriginaSwitch = [[UISwitch alloc] init];
    _editTheOriginaSwitch.onTintColor = [UIColor colorWithRed:253.0 / 255 green:215.0 / 255 blue:4.0 / 255 alpha:1.0];
    [_editTheOriginaSwitch addTarget:self action:@selector(clickEditOriginalBtn) forControlEvents:UIControlEventTouchUpInside];
    _editTheOriginaSwitch.translatesAutoresizingMaskIntoConstraints = false;
    [self addSubview:_editTheOriginaSwitch];
    [NSLayoutConstraint constraintWithItem:_editTheOriginaSwitch attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_musicButton attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0].active = YES;
    [NSLayoutConstraint constraintWithItem:_editTheOriginaSwitch attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:-8.0].active = YES;
    [NSLayoutConstraint constraintWithItem:_editTheOriginaSwitch attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:50.0].active = YES;
    [NSLayoutConstraint constraintWithItem:_editTheOriginaSwitch attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:30.0].active = YES;

    _editTheOriginaSwitch.hidden = YES;
    
    _editTheOriginaBtn = [[UIButton alloc] init];
    [_editTheOriginaBtn setTitle:@"去除原声" forState:UIControlStateNormal];
    [_editTheOriginaBtn.titleLabel setFont:[UIFont systemFontOfSize:15]];
    [_editTheOriginaBtn setTitleColor:[UIColor colorWithRed:250/256.0 green:211/256.0 blue:75/256.0 alpha:1] forState:UIControlStateSelected];
    [_editTheOriginaBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    _editTheOriginaBtn.backgroundColor = [UIColor clearColor];
    [self addSubview:_editTheOriginaBtn];
    _editTheOriginaBtn.translatesAutoresizingMaskIntoConstraints = false;
    [NSLayoutConstraint constraintWithItem:_editTheOriginaBtn attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:.0].active = YES;
    [NSLayoutConstraint constraintWithItem:_editTheOriginaBtn attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:_editTheOriginaSwitch attribute:NSLayoutAttributeLeading multiplier:1.0 constant:.0].active = YES;
    [NSLayoutConstraint constraintWithItem:_editTheOriginaBtn attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:_filterButton attribute:NSLayoutAttributeHeight multiplier:1.0 constant:.0].active = YES;
    [NSLayoutConstraint constraintWithItem:_editTheOriginaBtn attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:_filterButton attribute:NSLayoutAttributeWidth multiplier:1.0 constant:.0].active = YES;
    _editTheOriginaBtn.hidden = YES;
    
    
    
    UIView* lineView = [[UIView alloc] init];
    lineView.backgroundColor = [UIColor grayColor];
    [self addSubview:lineView];
    lineView.translatesAutoresizingMaskIntoConstraints = false;
    [NSLayoutConstraint constraintWithItem:lineView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_musicButton attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0].active = YES;
    [NSLayoutConstraint constraintWithItem:lineView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0].active = YES;
    [NSLayoutConstraint constraintWithItem:lineView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0].active = YES;
    [NSLayoutConstraint constraintWithItem:lineView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:.5].active = YES;
    
    //collectionView
    UICollectionViewFlowLayout* layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(83, 115);
    layout.estimatedItemSize = CGSizeMake(83, 115);
    
    //设置分区的头视图和尾视图是否始终固定在屏幕上边和下边
    //    layout.sectionFootersPinToVisibleBounds = YES;
    //    layout.sectionHeadersPinToVisibleBounds = YES;
    
    // 设置水平滚动方向
    //水平滚动
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    // 设置额外滚动区域
    layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    
    // 设置cell间距
    //设置水平间距, 注意点:系统可能会跳转(计算不准确)
    layout.minimumInteritemSpacing = 0;
    //设置垂直间距
    layout.minimumLineSpacing = 0;
    
    
    
    _filterCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 45, SCREEN_WIDTH, 115) collectionViewLayout:layout];
    [self addSubview:_filterCollectionView];
    _filterCollectionView.translatesAutoresizingMaskIntoConstraints = false;
    [NSLayoutConstraint constraintWithItem:_filterCollectionView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:lineView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0].active = YES;
    [NSLayoutConstraint constraintWithItem:_filterCollectionView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0].active = YES;
    [NSLayoutConstraint constraintWithItem:_filterCollectionView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0].active = YES;
    [NSLayoutConstraint constraintWithItem:_filterCollectionView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1.0 constant:115.0].active = YES;
    if (@available(iOS 11.0, *)) {
        [NSLayoutConstraint constraintWithItem:_filterCollectionView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.safeAreaLayoutGuide attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0].active = YES;
    } else {
        [NSLayoutConstraint constraintWithItem:_filterCollectionView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0].active = YES;
    }
    
    //设置背景颜色
    _filterCollectionView.backgroundColor = [UIColor clearColor];
    
    
    // 设置数据源,展示数据
    _filterCollectionView.dataSource = self;
    //设置代理,监听
    _filterCollectionView.delegate = self;
    
    // 注册cell
    [_filterCollectionView registerClass:[AlpMusicItemCollectionViewCell class] forCellWithReuseIdentifier:@"MyCollectionCell"];
    
    /* 设置UICollectionView的属性 */
    //设置滚动条
    _filterCollectionView.showsHorizontalScrollIndicator = NO;
    _filterCollectionView.showsVerticalScrollIndicator = NO;
    
    //设置是否需要弹簧效果
    _filterCollectionView.bounces = YES;
    
    
    //collectionView
    UICollectionViewFlowLayout* layout2 = [[UICollectionViewFlowLayout alloc] init];
    //    layout2.itemSize = CGSizeMake(83, 115);
    layout2.estimatedItemSize = CGSizeMake(83, 115);
    
    //设置分区的头视图和尾视图是否始终固定在屏幕上边和下边
    //    layout2.sectionFootersPinToVisibleBounds = YES;
    //    layout2.sectionHeadersPinToVisibleBounds = YES;
    
    // 设置水平滚动方向
    //水平滚动
    layout2.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    // 设置额外滚动区域
    layout2.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    
    // 设置cell间距
    //设置水平间距, 注意点:系统可能会跳转(计算不准确)
    layout2.minimumInteritemSpacing = 0;
    //设置垂直间距
    layout2.minimumLineSpacing = 0;
    
    
    
    _musicCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 45, SCREEN_WIDTH, 115) collectionViewLayout:layout2];
    [self addSubview:_musicCollectionView];
    _musicCollectionView.translatesAutoresizingMaskIntoConstraints = false;
    [NSLayoutConstraint constraintWithItem:_musicCollectionView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:lineView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0].active = YES;
    [NSLayoutConstraint constraintWithItem:_musicCollectionView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0].active = YES;
    [NSLayoutConstraint constraintWithItem:_musicCollectionView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0].active = YES;
    [NSLayoutConstraint constraintWithItem:_musicCollectionView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1.0 constant:115.0].active = YES;
    if (@available(iOS 11.0, *)) {
        [NSLayoutConstraint constraintWithItem:_musicCollectionView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.safeAreaLayoutGuide attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0].active = YES;
    } else {
        [NSLayoutConstraint constraintWithItem:_musicCollectionView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0].active = YES;
    }
    
    //设置背景颜色
    _musicCollectionView.backgroundColor = [UIColor clearColor];
    
    
    // 设置数据源,展示数据
    _musicCollectionView.dataSource = self;
    //设置代理,监听
    _musicCollectionView.delegate = self;
    
    // 注册cell
    [_musicCollectionView registerClass:[AlpMusicItemCollectionViewCell class] forCellWithReuseIdentifier:@"MyCollectionCell2"];
    
    /* 设置UICollectionView的属性 */
    //设置滚动条
    _musicCollectionView.showsHorizontalScrollIndicator = NO;
    _musicCollectionView.showsVerticalScrollIndicator = NO;
    
    //设置是否需要弹簧效果
    _musicCollectionView.bounces = YES;
    _musicCollectionView.hidden = YES;
    
    
    
    //贴纸collectionView
    UICollectionViewFlowLayout* layout3 = [[UICollectionViewFlowLayout alloc] init];
    layout3.itemSize = CGSizeMake(83, 115);
    layout3.estimatedItemSize = CGSizeMake(83, 115);
    
    //设置分区的头视图和尾视图是否始终固定在屏幕上边和下边
    //    layout2.sectionFootersPinToVisibleBounds = YES;
    //    layout2.sectionHeadersPinToVisibleBounds = YES;
    
    // 设置水平滚动方向
    //水平滚动
    layout3.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    // 设置额外滚动区域
    layout3.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    
    // 设置cell间距
    //设置水平间距, 注意点:系统可能会跳转(计算不准确)
    layout3.minimumInteritemSpacing = 0;
    //设置垂直间距
    layout3.minimumLineSpacing = 0;
    
    
    
    _stickersCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 45, SCREEN_WIDTH, 115) collectionViewLayout:layout3];
    [self addSubview:_stickersCollectionView];
    _stickersCollectionView.translatesAutoresizingMaskIntoConstraints = false;
    [NSLayoutConstraint constraintWithItem:_stickersCollectionView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:lineView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0].active = YES;
    [NSLayoutConstraint constraintWithItem:_stickersCollectionView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0].active = YES;
    [NSLayoutConstraint constraintWithItem:_stickersCollectionView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0].active = YES;
    [NSLayoutConstraint constraintWithItem:_stickersCollectionView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1.0 constant:115.0].active = YES;
    if (@available(iOS 11.0, *)) {
        [NSLayoutConstraint constraintWithItem:_stickersCollectionView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.safeAreaLayoutGuide attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0].active = YES;
    } else {
        [NSLayoutConstraint constraintWithItem:_stickersCollectionView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0].active = YES;
    }
    //设置背景颜色
    _stickersCollectionView.backgroundColor = [UIColor clearColor];
    
    
    // 设置数据源,展示数据
    _stickersCollectionView.dataSource = self;
    //设置代理,监听
    _stickersCollectionView.delegate = self;
    
    // 注册cell
    [_stickersCollectionView registerClass:[AlpMusicItemCollectionViewCell class] forCellWithReuseIdentifier:@"MyCollectionCell3"];
    
    /* 设置UICollectionView的属性 */
    //设置滚动条
    _stickersCollectionView.showsHorizontalScrollIndicator = NO;
    _stickersCollectionView.showsVerticalScrollIndicator = NO;
    
    //设置是否需要弹簧效果
    _stickersCollectionView.bounces = YES;
    
    _stickersCollectionView.hidden = YES;
    
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Actions
////////////////////////////////////////////////////////////////////////

/// 点击滤镜
- (void)clickCancleBtn {
    //    [self showEditMusicBar:_musicBtn];
    //    _audioPath = nil;
    //    [_audioPlayer pause];
    _editTheOriginaBtn.hidden = YES;
    _editTheOriginaSwitch.hidden = YES;
    if (self.chooseEditType == AlpChooseEditTypeFilter) {
        
    }
    else {
        self.chooseEditType = AlpChooseEditTypeFilter;
        
        _musicButton.selected = NO;
        _filterButton.selected = YES;
        _stickersBtn.selected = NO;
        _filterCollectionView.hidden = NO;
        _musicCollectionView.hidden = YES;
        _stickersCollectionView.hidden = YES;
        [_filterCollectionView reloadData];
    }
}

/// 点击音乐
- (void)clickOKBtn {
    //    [self showEditMusicBar:_musicBtn];
    if (self.chooseEditType == AlpChooseEditTypeMusic) {
        
    }
    else {
        self.chooseEditType = AlpChooseEditTypeMusic;
        
        _musicButton.selected = YES;
        _filterButton.selected = NO;
        _stickersBtn.selected = NO;
        _filterCollectionView.hidden = YES;
        _musicCollectionView.hidden = NO;
        _stickersCollectionView.hidden = YES;
        
        
        
    }
    if (_audioPath) {
        _editTheOriginaBtn.hidden = NO;
        _editTheOriginaSwitch.hidden = NO;
    }
}

- (void)clickStickersBtn {
    _editTheOriginaBtn.hidden = YES;
    _editTheOriginaSwitch.hidden = YES;
    if (self.chooseEditType == AlpChooseEditTypeStickers) {
        
    }
    else {
        self.chooseEditType = AlpChooseEditTypeStickers;
        
        _musicButton.selected = NO;
        _filterButton.selected = NO;
        _stickersBtn.selected = YES;
        _filterCollectionView.hidden = YES;
        _musicCollectionView.hidden = YES;
        _stickersCollectionView.hidden = NO;
    }
}


- (void)clickEditOriginalBtn {
    if (!_editTheOriginaBtn.selected) {
        _editTheOriginaBtn.selected = YES;
        if (self.delegate && [self.delegate respondsToSelector:@selector(removeOriginalSoundForEditVideoBar:)]) {
            [self.delegate removeOriginalSoundForEditVideoBar:self];
        }
    }
    else {
        _editTheOriginaBtn.selected = NO;
        if (self.delegate && [self.delegate respondsToSelector:@selector(restoreOriginalSoundForEditVideoBar:)]) {
            [self.delegate restoreOriginalSoundForEditVideoBar:self];
        }
    }
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
////////////////////////////////////////////////////////////////////////


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

// 告诉系统每组多少个
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    if (collectionView == _filterCollectionView) {
        return self.resourceItem.filterAry.count;
        
    }
    else if (collectionView == _stickersCollectionView) {
        return self.resourceItem.stickersAry.count;
    }
    else {
        return self.resourceItem.musicAry.count;
    }
    
    
}

// 告诉系统每个Cell如何显示
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    // 1.从缓存池中取
    if (collectionView == _filterCollectionView) {
        static NSString *cellID = @"MyCollectionCell";
        AlpMusicItemCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
        AlpFilterData* data = [self.resourceItem.filterAry objectAtIndex:indexPath.row];
        cell.iconImgView.image = [UIImage imageWithContentsOfFile:data.iconPath];
        cell.nameLabel.text = data.name;
        
        cell.checkMarkImgView.hidden = !data.isSelected;
        return cell;
    }else if (collectionView == _stickersCollectionView)
    {
        static NSString *cellID = @"MyCollectionCell3";
        AlpMusicItemCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
        AlpStickersData* data = [self.resourceItem.stickersAry objectAtIndex:indexPath.row];
        cell.iconImgView.image = [UIImage imageWithContentsOfFile:data.stickersImgPath];
        cell.nameLabel.text = data.name;
        
        cell.checkMarkImgView.hidden = !data.isSelected;
        return cell;
    }else{
        static NSString *cellID2 = @"MyCollectionCell2";
        AlpMusicItemCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellID2 forIndexPath:indexPath];
        AlpMusicData* data = [self.resourceItem.musicAry objectAtIndex:indexPath.row];
        UIImage* image = [UIImage imageWithContentsOfFile:data.iconPath];
        cell.iconImgView.image = image;
        cell.nameLabel.text = data.name;
        cell.checkMarkImgView.hidden = !data.isSelected;
        return cell;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    
    if (collectionView == _filterCollectionView) {
        _nowFilterIndex = indexPath;
        if (_lastFilterIndex.row != _nowFilterIndex.row) {
            
            //1.修改数据源
            AlpFilterData* dataNow = [self.resourceItem.filterAry objectAtIndex:indexPath.row];
            dataNow.isSelected = YES;
            [self.resourceItem.filterAry replaceObjectAtIndex:indexPath.row withObject:dataNow];
            AlpFilterData* dataLast = [self.resourceItem.filterAry objectAtIndex:_lastFilterIndex.row];
            dataLast.isSelected = NO;
            [self.resourceItem.filterAry replaceObjectAtIndex:_lastFilterIndex.row withObject:dataLast];
            //2.刷新collectionView
            [_filterCollectionView reloadData];
            _lastFilterIndex = indexPath;
            
        }
        
        AlpFilterData* data = [self.resourceItem.filterAry objectAtIndex:indexPath.row];
        [self.delegate editVideoBar:self didSelectFilter:data];
        
    }else if (collectionView == _stickersCollectionView){
        _nowStickersIndex = indexPath;
        if (_lastStickersIndex.row != _nowStickersIndex.row) {
            
            //1.修改数据源
            //            FilterData* dataNow = [_filterAry objectAtIndex:indexPath.row];
            AlpStickersData* dataNow = [self.resourceItem.stickersAry objectAtIndex:indexPath.row];
            dataNow.isSelected = YES;
            [self.resourceItem.stickersAry replaceObjectAtIndex:indexPath.row withObject:dataNow];
            AlpStickersData* dataLast = [self.resourceItem.stickersAry objectAtIndex:_lastStickersIndex.row];
            dataLast.isSelected = NO;
            [self.resourceItem.stickersAry replaceObjectAtIndex:_lastStickersIndex.row withObject:dataLast];
            //2.刷新collectionView
            [_stickersCollectionView reloadData];
            _lastStickersIndex = indexPath;
            
        }
//        else
//        {
//            _stickersImgView.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2);
//        }
        AlpStickersData* data = [self.resourceItem.stickersAry objectAtIndex:indexPath.row];
        [self.delegate editVideoBar:self didSelectSticker:data];

//        _stickersImgView.image = [UIImage imageWithContentsOfFile:data.StickersImgPaht];
//        _stickersImgView.hidden = NO;
        
    }else{
        
        _nowMusicIndex = indexPath;
        if (_lastMusicIndex.row != _nowMusicIndex.row) {
            
            //1.修改数据源
            AlpMusicData* dataNow = [self.resourceItem.musicAry objectAtIndex:indexPath.row];
            dataNow.isSelected = YES;
            [self.resourceItem.musicAry replaceObjectAtIndex:indexPath.row withObject:dataNow];
            AlpMusicData* dataLast = [self.resourceItem.musicAry objectAtIndex:_lastMusicIndex.row];
            dataLast.isSelected = NO;
            [self.resourceItem.musicAry replaceObjectAtIndex:_lastMusicIndex.row withObject:dataLast];
            //刷新collectionView
            [_musicCollectionView reloadData];
            _lastMusicIndex = indexPath;
            
        }
        AlpMusicData* data = [self.resourceItem.musicAry objectAtIndex:indexPath.row];
        
        if (indexPath.row == 0) { // 使用原始声音
            _audioPath = nil;
            _editTheOriginaBtn.hidden = YES;
            _editTheOriginaSwitch.hidden = YES;
            _editTheOriginaBtn.selected = NO;
            _editTheOriginaSwitch.on = NO;
            
        }
        else {
            // 加入选中的声音
            _audioPath = data.audioPath;
            _editTheOriginaBtn.hidden = NO;
            _editTheOriginaSwitch.hidden = NO;
            
        }
        [self.delegate editVideoBar:self didSelectMusic:data];
    }
    
    
}

- (BOOL)isUseOriginalSound {
    return self.editTheOriginaBtn.isSelected;
}

@end
