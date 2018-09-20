//
//  XYLocationSearchViewController.m
//  WeChatExtensions
//
//  Created by Swae on 2017/10/28.
//  Copyright © 2017年 alpface. All rights reserved.
//

#import "XYLocationSearchViewController.h"
#import "XYLocationSearchTopView.h"
#import "XYLocationManager.h"
#import "LocationConverter.h"

@interface XYLocationCell()

@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *addressLabel;
@property (nonatomic, strong) UIView *bottomLineView;
@property (nonatomic, strong) UILabel *distanceLabel;

@end

@implementation XYLocationCell : UITableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = [UIColor clearColor];
        self.backgroundColor = [UIColor clearColor];
        
        _iconView = [[UIImageView alloc] init];
        _iconView.tintColor = [UIColor blackColor];
        _iconView.contentMode = UIViewContentModeScaleAspectFill;
        _iconView.image = [UIImage imageNamed:@"XYLocationSearch.bundle/LegacyPinDown3Sat"];
        [self.contentView addSubview:_iconView];
        _iconView.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self.contentView addSubview:self.bottomLineView];
        [NSLayoutConstraint constraintWithItem:self.bottomLineView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0].active = YES;
        [NSLayoutConstraint constraintWithItem:self.bottomLineView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:_iconView attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0].active = YES;
        [NSLayoutConstraint constraintWithItem:self.bottomLineView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0].active = YES;
        [NSLayoutConstraint constraintWithItem:self.bottomLineView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:0.3].active = YES;
        
        
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_iconView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_iconView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeading multiplier:1.0 constant:15.0]];
        [self.iconView addConstraint:[NSLayoutConstraint constraintWithItem:_iconView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:15.0]];
        [self.iconView addConstraint:[NSLayoutConstraint constraintWithItem:_iconView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:_iconView attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0]];
        
        self.distanceLabel = [UILabel new];
        [self.contentView addSubview:self.distanceLabel];
        self.distanceLabel.font = [UIFont systemFontOfSize:13];
        self.distanceLabel.textColor = [UIColor lightGrayColor];
        self.distanceLabel.translatesAutoresizingMaskIntoConstraints = false;
        [self.distanceLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [self.distanceLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [NSLayoutConstraint constraintWithItem:self.distanceLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0].active = YES;
        [NSLayoutConstraint constraintWithItem:self.distanceLabel attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:-10.0].active = YES;
        self.distanceLabel.text = @"100米";
        
        UIView *textContentView = [UIView new];
        textContentView.translatesAutoresizingMaskIntoConstraints = false;
        textContentView.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:textContentView];
        [NSLayoutConstraint constraintWithItem:textContentView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0].active = YES;
        [NSLayoutConstraint constraintWithItem:textContentView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:_iconView attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:10.0].active = YES;
        [NSLayoutConstraint constraintWithItem:textContentView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationLessThanOrEqual toItem:self.distanceLabel attribute:NSLayoutAttributeLeading multiplier:1.0 constant:-10.0].active = YES;
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:15];
        _titleLabel.textColor = [UIColor whiteColor];
        [textContentView addSubview:_titleLabel];
        _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        
        [textContentView addConstraint:[NSLayoutConstraint constraintWithItem:_titleLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:textContentView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0]];
        [textContentView addConstraint:[NSLayoutConstraint constraintWithItem:_titleLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:textContentView attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0]];
         [textContentView addConstraint:[NSLayoutConstraint constraintWithItem:_titleLabel attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:textContentView attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0]];
        
        _addressLabel = [[UILabel alloc] init];
        _addressLabel.font = [UIFont systemFontOfSize:12];
        _addressLabel.textColor = [UIColor lightGrayColor];
        [textContentView addSubview:_addressLabel];
        _addressLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [textContentView addConstraint:[NSLayoutConstraint constraintWithItem:_addressLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_titleLabel attribute:NSLayoutAttributeBottom multiplier:1.0 constant:5.0]];
        [textContentView addConstraint:[NSLayoutConstraint constraintWithItem:_addressLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:textContentView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]];
        [textContentView addConstraint:[NSLayoutConstraint constraintWithItem:_addressLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:textContentView attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0]];
        [textContentView addConstraint:[NSLayoutConstraint constraintWithItem:_addressLabel attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:textContentView attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0]];
    }
    return self;
}

- (void)setItem:(MKMapItem *)item {
    _item = item;
    NSArray *address = [XYLocationSearchTableViewModel stringsForItem:item];
    [self updateCellWithTitle:address.firstObject address:address.lastObject];
    
    double distance = [LocationConverter countLineDistanceDest:[XYLocationManager sharedManager].coordinate.longitude dest_Lat:[XYLocationManager sharedManager].coordinate.latitude self_Lon:item.placemark.coordinate.longitude self_Lat:item.placemark.coordinate.latitude];
    NSString *distanceStr;
    if (distance < 1000) {
        distanceStr = [NSString stringWithFormat:@"%ld m", (long)distance];
    }
    else {
        distanceStr = [NSString stringWithFormat:@"%.2f km", distance/1000.0];
    }
    self.distanceLabel.text = distanceStr;
}

- (void)updateCellWithTitle:(NSString *)title address:(NSString *)address {
    _titleLabel.text = title;
    _addressLabel.text = address;
}
- (UIView *)bottomLineView {
    if (!_bottomLineView) {
        _bottomLineView = [UIView new];
        _bottomLineView.backgroundColor = [UIColor colorWithRed:235/255.0f green:235/255.0f blue:235/255.0f alpha:0.6f];
        _bottomLineView.translatesAutoresizingMaskIntoConstraints = false;
    }
    return _bottomLineView;
}
@end

@interface XYLocationStaticCell()

@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong)  UILabel *titleLabel;
@property (nonatomic, strong) UIView *bottomLineView;
@property (nonatomic, strong) UIActivityIndicatorView *indicator;

@end

@implementation XYLocationStaticCell : UITableViewCell
#pragma mark -
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = [UIColor clearColor];
        self.backgroundColor = [UIColor clearColor];
        // icon
        _iconView = [[UIImageView alloc] init];
        [self.contentView addSubview:_iconView];
        _iconView.translatesAutoresizingMaskIntoConstraints = NO;
        _iconView.contentMode = UIViewContentModeScaleAspectFill;
        
        [self.contentView addSubview:self.bottomLineView];
        [NSLayoutConstraint constraintWithItem:self.bottomLineView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0].active = YES;
        [NSLayoutConstraint constraintWithItem:self.bottomLineView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:_iconView attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0].active = YES;
        [NSLayoutConstraint constraintWithItem:self.bottomLineView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0].active = YES;
        [NSLayoutConstraint constraintWithItem:self.bottomLineView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:0.3].active = YES;
        
        
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_iconView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_iconView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeading multiplier:1.0 constant:15.0]];
        [self.iconView addConstraint:[NSLayoutConstraint constraintWithItem:_iconView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:15.0]];
        [self.iconView addConstraint:[NSLayoutConstraint constraintWithItem:_iconView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:_iconView attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0]];
        
        // title
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:16];
        _titleLabel.textColor = [UIColor whiteColor];
        [self.contentView addSubview:_titleLabel];
        _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_titleLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_titleLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeading multiplier:1.0 constant:45.0]];
        
        self.indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        self.indicator.hidesWhenStopped = YES;
        [self.contentView addSubview:self.indicator];
        _indicator.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_indicator attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_indicator attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:_titleLabel attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:8.0]];
        
    }
    return self;
}

#pragma mark - Public
- (void)setTitle:(NSString *)title {
    _titleLabel.text = title;
}

#pragma mark - Getter/Setter
- (void)setType:(XYLocationStaticCellType)type {
    _type = type;
    if (_type == XYLocationStaticCellTypeCurrent) {
        _iconView.image = [[UIImage imageNamed:@"XYLocationSearch.bundle/TrackingLocation"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        _iconView.tintColor = [UIColor whiteColor];
        _titleLabel.text = @"当前位置";
    }else {
        _iconView.image = [[UIImage imageNamed:@"XYLocationSearch.bundle/LegacyPinDown3Sat"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        _iconView.tintColor = [UIColor whiteColor];
        _titleLabel.text = nil;
    }
}
- (UIView *)bottomLineView {
    if (!_bottomLineView) {
        _bottomLineView = [UIView new];
        _bottomLineView.backgroundColor = [UIColor colorWithRed:235/255.0f green:235/255.0f blue:235/255.0f alpha:0.6f];
        _bottomLineView.translatesAutoresizingMaskIntoConstraints = false;
    }
    return _bottomLineView;
}
@end


@interface XYLocationSearchViewController () <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, UISearchBarDelegate, XYLocationSearchTableViewModelDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) XYLocationSearchTopView *topView;
@property (nonatomic, strong) XYLocationSearchTableViewModel *viewModel;
@property (nonatomic, strong) NSArray<MKMapItem *> *searchResults;


@end

@implementation XYLocationSearchViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.navigationController.view.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.topView];
    [self makeConstarints];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateLocationsNotification) name:XYUpdateLocationsNotification object:nil];
    
}

- (void)updateLocationsNotification {
    __weak typeof(self) weakSelf = self;
    [self.viewModel fetchNearbyInfoCompletionHandler:^(NSArray<MKMapItem *> *searchResult, NSError *error) {
        weakSelf.searchResults = [searchResult mutableCopy];
        [weakSelf reloadTableData];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)makeConstarints {
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.topView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.topLayoutGuide attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.topView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0]];
     [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.topView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.topView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]];
    
}


////////////////////////////////////////////////////////////////////////
#pragma mark - Action
////////////////////////////////////////////////////////////////////////

- (void)backAction:(UIButton *)sender {
    [self.navigationController dismissViewControllerAnimated:self completion:nil];
}

////////////////////////////////////////////////////////////////////////
#pragma mark - UISearchBarDelegate
////////////////////////////////////////////////////////////////////////
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    self.viewModel.searchText = searchText;
    [self startSearch];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    [self startSearch];
}

- (void)startSearch {
    self.searchResults = @[];
    [self reloadTableData];
    [self.viewModel searchFromServer];
}

- (void)reloadTableData {
    if (self.viewModel.searchResultType == XYLocationSearchResultTypeSearchPoi && !self.topView.searchBar.text.length) {
        self.searchResults = @[];
    }
    [self.tableView reloadData];
}

////////////////////////////////////////////////////////////////////////
#pragma mark - UIScrollViewDelegate
////////////////////////////////////////////////////////////////////////
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if ([self.topView.searchBar isFirstResponder]) {
        [self.topView resignFirstResponder];
    }
}

////////////////////////////////////////////////////////////////////////
#pragma mark - UITableViewDataSource
////////////////////////////////////////////////////////////////////////
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self numberOfSections];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if ([self numberOfRowsInSection:0] == 2 && indexPath.row == 0) {
            XYLocationStaticCell *cell = [tableView dequeueReusableCellWithIdentifier:@"XYLocationStaticCell"];
            cell.type = XYLocationStaticCellTypeUserInput;
            [cell setTitle:self.viewModel.searchText];
            return cell;
        }
        else {
            XYLocationStaticCell *cell = [tableView dequeueReusableCellWithIdentifier:@"XYLocationStaticCell"];
            cell.type = XYLocationStaticCellTypeCurrent;
            if (self.viewModel.reversing) {
                [cell.indicator startAnimating];
            }else {
                [cell.indicator stopAnimating];
            }
            return cell;
        }
    }
    else {
        XYLocationCell *cell = [tableView dequeueReusableCellWithIdentifier:@"XYLocationCell"];
        MKMapItem *item = nil;
        if (indexPath.row < self.searchResults.count) {
           item = self.searchResults[indexPath.row];
        }
        cell.item = item;
        return cell;
    }
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self numberOfRowsInSection:section];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 1) {
        switch (self.viewModel.searchResultType) {
            case XYLocationSearchResultTypeNearBy:
                return @"附近地点";
                break;
            case XYLocationSearchResultTypeSearchPoi: {
                return @"搜索结果";
                break;
            }
            default:
                break;
        }
    }
    else {
        return nil;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 66.0;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - UITableViewDelegate
////////////////////////////////////////////////////////////////////////
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (![self.delegate respondsToSelector:@selector(locationSearchViewController:didSelectLocationWithName:address:mapItem:)]) {
        return;
    }
    
    NSArray *nameAndAddress = nil;
    NSString *name = nil;
    NSString *address = nil;
    MKMapItem *currentMap = nil;
    if (indexPath.section == 0) {
        if (indexPath.row == 0 && [self numberOfRowsInSection:0] == 2) {
            nameAndAddress = @[self.viewModel.searchText, [NSNull null]];
        } else {
            // 正在解析地址，当前位置不可用
            if (self.viewModel.reversing) {
                return;
            }
            
            if (self.viewModel.currentName.length) {
                name = self.viewModel.currentName;
            }
            if (self.viewModel.currentAddress.length) {
                address = self.viewModel.currentAddress;
            }
        }
    } else {
        nameAndAddress = [XYLocationSearchTableViewModel stringsForItem:self.searchResults[indexPath.row]];
        currentMap = self.searchResults[indexPath.row];
    }
    
    if ([nameAndAddress.firstObject isKindOfClass:[NSString class]]) {
        name = nameAndAddress.firstObject;
    }
    if ([nameAndAddress.lastObject isKindOfClass:[NSString class]]) {
        address = nameAndAddress.lastObject;
    }
    [self.delegate locationSearchViewController:self didSelectLocationWithName:name address:address mapItem:currentMap];
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
////////////////////////////////////////////////////////////////////////
- (NSInteger)numberOfSections {
    if (self.searchResults.count > 0) {
        return 2;
    }
    else {
        return 1;
    }
}

- (NSInteger)numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        if (self.topView.searchBar.text.length > 0) {
            return 2;
        }
        else {
            return 1;
        }
    }
    else {
        return self.searchResults.count;
    }
}

////////////////////////////////////////////////////////////////////////
#pragma mark - XYLocationSearchTableViewModelDelegate
////////////////////////////////////////////////////////////////////////

- (void)locationSearchTableViewModel:(XYLocationSearchTableViewModel *)viewModel searchResultChange:(NSArray *)searchResult error:(NSError *)error {
    self.searchResults = [searchResult mutableCopy];
    [self reloadTableData];
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Getter/Setter
////////////////////////////////////////////////////////////////////////
- (XYLocationSearchTableViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [XYLocationSearchTableViewModel new];
        _viewModel.delegate = self;
    }
    return _viewModel;
}


- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.translatesAutoresizingMaskIntoConstraints = NO;
        _tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        [_tableView registerClass:[XYLocationStaticCell class] forCellReuseIdentifier:@"XYLocationStaticCell"];
        [_tableView registerClass:[XYLocationCell class] forCellReuseIdentifier:@"XYLocationCell"];
    }
    return _tableView;
}

- (XYLocationSearchTopView *)topView {
    if (!_topView) {
        _topView = [[XYLocationSearchTopView alloc] init];
        _topView.searchBar.placeholder = @"搜索地点";
        _topView.searchBar.delegate = self;
        _topView.translatesAutoresizingMaskIntoConstraints = NO;
        [_topView.leftButton addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
        _topView.rightButton.hidden = YES;
    }
    return _topView;
}


@end
