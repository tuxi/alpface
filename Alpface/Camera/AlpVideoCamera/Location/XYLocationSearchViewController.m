//
//  XYLocationSearchViewController.m
//  WeChatExtensions
//
//  Created by Swae on 2017/10/28.
//  Copyright © 2017年 alpface. All rights reserved.
//

#import "XYLocationSearchViewController.h"

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/**
 *  动态位置cell。包含地方名字和地址信息。
 */
@interface XYLocationCell(){
    UIImageView *_iconView;
    UILabel *_titleLabel;
    UILabel *_addressLabel;
}

@end

@implementation XYLocationCell : UITableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // icon
        _iconView = [[UIImageView alloc] init];
        _iconView.tintColor = [UIColor blackColor];
        _iconView.image = [UIImage imageNamed:@"XYLocationSearch.bundle/LegacyPinDown3Sat"];
        [self.contentView addSubview:_iconView];
        _iconView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_iconView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_iconView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeading multiplier:1.0 constant:15.0]];
        
        // title
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:16];
        [self.contentView addSubview:_titleLabel];
        _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_titleLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1.0 constant:8.0]];
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_titleLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeading multiplier:1.0 constant:45.0]];
         [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_titleLabel attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:-8.0]];
        
        _addressLabel = [[UILabel alloc] init];
        _addressLabel.font = [UIFont systemFontOfSize:10];
        [self.contentView addSubview:_addressLabel];
        _addressLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_addressLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-4.0]];
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_addressLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeading multiplier:1.0 constant:45.0]];
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_addressLabel attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:-8.0]];
    }
    return self;
}

- (void)updateCellWithTitle:(NSString *)title address:(NSString *)address {
    _titleLabel.text = title;
    _addressLabel.text = address;
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/**
 *  静态Cell。
 *  输入位置的Cell，当前位置Cell
 */
@interface XYLocationStaticCell() {
    UIImageView *_iconView;
    UILabel *_titleLabel;
}

@property (nonatomic, strong) UIActivityIndicatorView *indicator;

@end

@implementation XYLocationStaticCell : UITableViewCell
#pragma mark -
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.separatorInset = UIEdgeInsetsMake(0, 45, 0, 0);
        // icon
        _iconView = [[UIImageView alloc] init];
        [self.contentView addSubview:_iconView];
        _iconView.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_iconView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_iconView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeading multiplier:1.0 constant:15.0]];
        
        // title
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:16];
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
        _iconView.tintColor = [UIColor blackColor];
        _titleLabel.text = @"Current";
    }else {
        _iconView.image = [[UIImage imageNamed:@"XYLocationSearch.bundle/LegacyPinDown3Sat"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        _iconView.tintColor = [UIColor grayColor];
        _titleLabel.text = nil;
    }
}

@end


@interface XYLocationSearchViewController () <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, UISearchBarDelegate, XYLocationSearchTableViewModelDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) XYLocationSearchTableViewModel *viewModel;
@property (nonatomic, strong) NSArray<MKMapItem *> *xy_searchResults;

@end

@implementation XYLocationSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"搜索位置";
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.searchBar];
    [self makeConstarints];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                          target:self
                                                                          action:@selector(onClickedCancelItem)];
    self.navigationItem.rightBarButtonItem = item;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self.viewModel fetchNearbyInfoCompletionHandler:^(NSArray<MKMapItem *> *searchResult, NSError *error) {
        self.xy_searchResults = [searchResult mutableCopy];
        [self reloadTableData];
    }];
    
}

- (void)makeConstarints {
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.searchBar attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.topLayoutGuide attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.searchBar attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0]];
     [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.searchBar attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.searchBar attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]];
    
}


////////////////////////////////////////////////////////////////////////
#pragma mark - Action
////////////////////////////////////////////////////////////////////////
- (void)onClickedCancelItem {
//    [self dismissViewControllerAnimated:YES completion:NULL];
    [self.navigationController popViewControllerAnimated:YES];
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
    self.xy_searchResults = @[];
    [self reloadTableData];
    [self.viewModel searchFromServer];
}

- (void)reloadTableData {
    if (self.viewModel.searchResultType == XYLocationSearchResultTypeSearchPoi && !self.searchBar.text.length) {
        self.xy_searchResults = @[];
    }
    [self.tableView reloadData];
}

////////////////////////////////////////////////////////////////////////
#pragma mark - UIScrollViewDelegate
////////////////////////////////////////////////////////////////////////
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if ([_searchBar isFirstResponder]) {
        [_searchBar resignFirstResponder];
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
        if (indexPath.row < self.xy_searchResults.count) {
           item = self.xy_searchResults[indexPath.row];
        }
        
        NSString *title = @"";
        NSString *address = @"";
        NSArray *strs = [XYLocationSearchTableViewModel stringsForItem:item];
        if ([strs.firstObject isKindOfClass:[NSString class]]) {
            title = strs.firstObject;
        }
        if ([strs.lastObject isKindOfClass:[NSString class]]) {
            address = strs.lastObject;
        }
        
        [cell updateCellWithTitle:title address:address];
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

////////////////////////////////////////////////////////////////////////
#pragma mark - UITableViewDelegate
////////////////////////////////////////////////////////////////////////
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
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
        nameAndAddress = [XYLocationSearchTableViewModel stringsForItem:self.xy_searchResults[indexPath.row]];
        currentMap = self.xy_searchResults[indexPath.row];
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
    if (self.xy_searchResults.count > 0) {
        return 2;
    }
    else {
        return 1;
    }
}

- (NSInteger)numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        if (self.searchBar.text.length > 0) {
            return 2;
        }
        else {
            return 1;
        }
    }
    else {
        return self.xy_searchResults.count;
    }
}

////////////////////////////////////////////////////////////////////////
#pragma mark - XYLocationSearchTableViewModelDelegate
////////////////////////////////////////////////////////////////////////

- (void)locationSearchTableViewModel:(XYLocationSearchTableViewModel *)viewModel searchResultChange:(NSArray *)searchResult error:(NSError *)error {
    self.xy_searchResults = [searchResult mutableCopy];
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

- (UISearchBar *)searchBar {
    if (!_searchBar) {
        _searchBar = [[UISearchBar alloc] init];
        _searchBar.placeholder = @"Enter Location";
        _searchBar.delegate = self;
        _searchBar.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _searchBar;
}

- (void)dealloc {
#if ! __has_feature(objc_arc)
    [super dealloc];
#endif
    self.delegate = nil;
}

@end
