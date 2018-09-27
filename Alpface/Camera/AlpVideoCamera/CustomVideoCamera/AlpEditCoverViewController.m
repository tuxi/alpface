//
//  AlpEditCoverViewController.m
//  Alpface
//
//  Created by xiaoyuan on 2018/9/27.
//  Copyright © 2018 alpface. All rights reserved.
//

#import "AlpEditCoverViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "AlpVideoCameraUtils.h"

@interface AlpCoverImageCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *imageView;

@end

@interface AlpEditCoverViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>
@property(nonatomic,strong)UIImageView *coverImage;
@property(nonatomic,strong)UICollectionView *coverImageCollectionView;
///照片数组
@property (nonatomic, strong) NSMutableArray *photoArrays;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;

@end

@implementation AlpEditCoverViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor blackColor];
    self.selectedIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    self.photoArrays = [[NSMutableArray alloc] init];
    [self initView];
    [self getVideoTotalValueAndScale];
}
- (void)initView {
    
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelButton setBackgroundColor:[UIColor blackColor]];
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [cancelButton setTitle:@"取消" forState:UIControlStateSelected];
    [cancelButton setTitleColor:[UIColor whiteColor] forState:0];
    [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    cancelButton.titleLabel.font = [UIFont systemFontOfSize:16.0];
    cancelButton.tag = 1;
    [self.view addSubview:cancelButton];
    cancelButton.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint constraintWithItem:cancelButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:50.0].active = YES;
    [NSLayoutConstraint constraintWithItem:cancelButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:30.0].active = YES;
    [NSLayoutConstraint constraintWithItem:cancelButton attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:20.0].active = YES;
    [NSLayoutConstraint constraintWithItem:cancelButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:30.0].active = YES;
    
    UIButton *sureButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [sureButton setBackgroundColor:[UIColor blackColor]];
    [sureButton setTitle:@"确定" forState:UIControlStateNormal];
    [sureButton setTitle:@"确定" forState:UIControlStateSelected];
    [sureButton setTitleColor:[UIColor whiteColor] forState:0];
    [sureButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    sureButton.titleLabel.font = [UIFont systemFontOfSize:16.0];
    sureButton.tag = 2;
    [self.view addSubview:sureButton];
    sureButton.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint constraintWithItem:sureButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:50.0].active = YES;
    [NSLayoutConstraint constraintWithItem:sureButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:30.0].active = YES;
    [NSLayoutConstraint constraintWithItem:sureButton attribute:NSLayoutAttributeTrailing    relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:-20.0].active = YES;
    [NSLayoutConstraint constraintWithItem:sureButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:30.0].active = YES;
    
    [cancelButton addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
    [sureButton addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
    
    //选定的封面图
    _coverImage = [[UIImageView alloc] init];
    _coverImage.contentMode = UIViewContentModeScaleAspectFill;
    _coverImage.clipsToBounds  = YES;
    [self.view addSubview:_coverImage];
    _coverImage.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint constraintWithItem:_coverImage attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:0.6 constant:0.0].active = YES;
    [NSLayoutConstraint constraintWithItem:_coverImage attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:0.6 constant:0.0].active = YES;
    [NSLayoutConstraint constraintWithItem:_coverImage attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0].active = YES;
    [NSLayoutConstraint constraintWithItem:_coverImage attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:-50.0].active = YES;
    
    UILabel *label = [[UILabel alloc] init];
        label.backgroundColor = [UIColor blackColor];
    label.textColor = [UIColor whiteColor];
    label.text = @"选择封面图";
    label.numberOfLines = 0;
    label.textAlignment = NSTextAlignmentLeft;
    label.font = [UIFont systemFontOfSize:14];
    [self.view addSubview:label];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:20.0].active = YES;
    [NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-140].active = YES;
    [NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:200.0].active = YES;
    [NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:20.0].active = YES;
    [self.view addSubview:self.coverImageCollectionView];
    _coverImageCollectionView.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint constraintWithItem:self.coverImageCollectionView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:20.0].active = YES;
    [NSLayoutConstraint constraintWithItem:self.coverImageCollectionView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-(80+34)].active = YES;
    [NSLayoutConstraint constraintWithItem:self.coverImageCollectionView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1.0 constant:-40.0].active = YES;
    [NSLayoutConstraint constraintWithItem:self.coverImageCollectionView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:80.0].active = YES;
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}
#pragma mark-methods
-(void)clickButton:(UIButton *)button
{
    if (button.tag == 1) {
        //取消
        [self.navigationController popViewControllerAnimated:YES];
    }else
    {
        //确定
//        PublishVideoViewController *vc = [[PublishVideoViewController alloc] init];
//        vc.videoPath = self.videoPath;
//        vc.coverImage = self.coverImage.image;
//        [self.navigationController pushViewController:vc animated:YES];
    }
}



- (void)getVideoTotalValueAndScale {
    
    [AlpVideoCameraUtils getImagesByVideoURL:self.videoURL numberOfCoverFrame:10 callBack:^(CMTime time, NSArray<UIImage *> * _Nonnull images, NSError * _Nonnull error) {
        if (time.value < 1) {
            
            [self dismissViewControllerAnimated:YES completion:nil];
            return;
        }
        [self.photoArrays removeAllObjects];
        [self.photoArrays addObjectsFromArray:images];
    }];
}


#pragma mark-collectionview

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return _photoArrays.count;
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    AlpCoverImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AlpCoverImageCollectionViewCell" forIndexPath:indexPath];
    
    cell.imageView.image = _photoArrays[indexPath.item];
    if ([self.selectedIndexPath isEqual:indexPath]) {
        cell.imageView.layer.cornerRadius = 2.0;
        cell.imageView.layer.borderWidth = 1.0;
        _coverImage.image = _photoArrays[indexPath.item];
    }
    else {
        cell.imageView.layer.cornerRadius = 0.0;
        cell.imageView.layer.borderWidth = 0.0;
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSIndexPath *firstSelectedIndexPath = self.selectedIndexPath;
    [collectionView deselectItemAtIndexPath:firstSelectedIndexPath animated:YES];
    
    UICollectionViewScrollPosition position = UICollectionViewScrollPositionNone;
    if (firstSelectedIndexPath.item > indexPath.item) {
        position = UICollectionViewScrollPositionRight;
    }
    else if (firstSelectedIndexPath.item < indexPath.item) {
        position = UICollectionViewScrollPositionLeft;
    }
    else {
        position = UICollectionViewScrollPositionNone;
    }
    [self.coverImageCollectionView selectItemAtIndexPath:indexPath animated:YES scrollPosition:position];
    self.selectedIndexPath = indexPath;
    [_coverImageCollectionView reloadData];
}

- (UICollectionView *)coverImageCollectionView {
    if (!_coverImageCollectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.itemSize = CGSizeMake(60, 80);
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        flowLayout.sectionInset = UIEdgeInsetsMake(0, 0,0 ,0 );
        flowLayout.minimumInteritemSpacing = 0;
        flowLayout.minimumLineSpacing = 0;
        _coverImageCollectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _coverImageCollectionView.backgroundColor = [UIColor blackColor];
        _coverImageCollectionView.showsVerticalScrollIndicator = NO;
        _coverImageCollectionView.showsHorizontalScrollIndicator = NO;
        [_coverImageCollectionView registerClass:[AlpCoverImageCollectionViewCell class] forCellWithReuseIdentifier:@"AlpCoverImageCollectionViewCell"];
        _coverImageCollectionView.delegate = self;
        _coverImageCollectionView.dataSource = self;
        
    }
    return _coverImageCollectionView;
}


@end

@implementation AlpCoverImageCollectionViewCell
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor blackColor];
        _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds  = YES;
        [self.contentView addSubview:_imageView];
        _imageView.translatesAutoresizingMaskIntoConstraints = NO;
        [NSLayoutConstraint constraintWithItem:_imageView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0].active = YES;
        [NSLayoutConstraint constraintWithItem:_imageView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0].active = YES;
        [NSLayoutConstraint constraintWithItem:_imageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0].active = YES;
        [NSLayoutConstraint constraintWithItem:_imageView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0].active = YES;
        [self.imageView.layer setMasksToBounds:YES];
        self.imageView.layer.borderColor = [UIColor whiteColor].CGColor;
    }
    return self;
}

@end
