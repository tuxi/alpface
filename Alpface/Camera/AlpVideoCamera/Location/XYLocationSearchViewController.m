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
        
        self.indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
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

@interface XYLocationSearchTableSection : NSObject

@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, copy) NSString *headerTitle;

@end


@interface XYLocationSearchViewController () <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, UISearchBarDelegate, XYLocationSearchTableViewModelDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) XYLocationSearchTopView *topView;
@property (nonatomic, strong) XYLocationSearchTableViewModel *viewModel;
//@property (nonatomic, strong) NSArray<MKMapItem *> *searchResults;
@property (nonatomic, strong) NSMutableArray<XYLocationSearchTableSection *> *resultSections;

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
    if ([[XYLocationManager sharedManager] getGpsPostion]) {
        [self updateLocations];
    }
    else {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateLocations) name:XYUpdateLocationsNotification object:nil];
    }
    
    [self initData];
    
}

- (void)initData {
    {
        XYLocationSearchTableSection *section = [self sectionWithIdentifier:@"location"];
        if (!section) {
            section = [XYLocationSearchTableSection new];
            section.identifier = @"location";
            section.headerTitle = nil;
            [self.resultSections addObject:section];
        }
    }
    {
        XYLocationSearchTableSection *section1 = [self sectionWithIdentifier:@"result"];
        if (!section1) {
            section1 = [XYLocationSearchTableSection new];
            section1.identifier = @"result";
            section1.headerTitle = @"搜索结果";
            [self.resultSections addObject:section1];
        }
    }
    {
        XYLocationSearchTableSection *section2 = [self sectionWithIdentifier:@"nearby"];
        if (!section2) {
            section2 = [XYLocationSearchTableSection new];
            section2.identifier = @"nearby";
            section2.headerTitle = @"附近地点";
            [self.resultSections addObject:section2];
        }
    }
}

- (XYLocationSearchTableSection *)sectionWithIdentifier:(NSString *)identifier {
    NSUInteger foundIdx = [self.resultSections indexOfObjectPassingTest:^BOOL(XYLocationSearchTableSection *  _Nonnull section, NSUInteger idx, BOOL * _Nonnull stop) {
        BOOL res = NO;
        if ([section.identifier isEqualToString:identifier]) {
            res = YES;
            *stop = YES;
        }
        return res;
    }];
    XYLocationSearchTableSection *section = nil;
    if (foundIdx != NSNotFound) {
        section = self.resultSections[foundIdx];
    }
    return section;
}

- (void)updateLocations {
    __weak typeof(self) weakSelf = self;
    [self.viewModel fetchNearbyInfoCompletionHandler:^(NSArray<MKMapItem *> *searchResult, NSError *error) {
        if ([weakSelf isSearching]) {
            return;
        }
        
        // 添加附近的poi
        XYLocationSearchTableSection *section = [weakSelf sectionWithIdentifier:@"nearby"];
        [section.items removeAllObjects];
        [section.items addObjectsFromArray:searchResult];
        
        // 移除搜索的pois
        XYLocationSearchTableSection *result = [weakSelf sectionWithIdentifier:@"result"];
        [result.items removeAllObjects];
        [weakSelf reloadTableData];
    }];
}

- (BOOL)isSearching {
    return self.topView.searchBar.text.length > 0;
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
    if (searchText.length == 0) {
        [self clearSearch];
    }
    else {
        [self startSearch];
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    if (searchBar.text == 0) {
        [self clearSearch];
    }
    else {
        [self startSearch];
    }
}

- (void)startSearch {
    [self reloadTableData];
    [self.viewModel searchFromServer];
}

- (void)clearSearch {
    XYLocationSearchTableSection *result = [self sectionWithIdentifier:@"result"];
    [result.items removeAllObjects];
    [self updateLocations];
    [self reloadTableData];
}

- (void)reloadTableData {
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
    XYLocationSearchTableSection *secObj = self.resultSections[indexPath.section];
    if ([secObj.identifier isEqualToString:@"result"] ||
        [secObj.identifier isEqualToString:@"nearby"] ) {
        XYLocationCell *cell = [tableView dequeueReusableCellWithIdentifier:@"XYLocationCell"];
        MKMapItem *item = nil;
        if (indexPath.row < secObj.items.count) {
            item = secObj.items[indexPath.row];
        }
        cell.item = item;
        return cell;
    }
    if ([secObj.identifier isEqualToString:@"location"]) {
        XYLocationStaticCell *cell = [tableView dequeueReusableCellWithIdentifier:@"XYLocationStaticCell"];
        id rowObj = secObj.items[indexPath.row];
        if ([rowObj isKindOfClass:[NSString class]]) {
            cell.type = XYLocationStaticCellTypeUserInput;
            [cell setTitle:rowObj];
        }
        else {
            cell.type = XYLocationStaticCellTypeCurrent;
            if (self.viewModel.reversing) {
                [cell.indicator startAnimating];
            }else {
                [cell.indicator stopAnimating];
            }
        }
        return cell;
    }
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self numberOfRowsInSection:section];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    XYLocationSearchTableSection *secObj = self.resultSections[section];
    if (secObj.headerTitle.length && secObj.items.count > 0) {
        return secObj.headerTitle;
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
    XYLocationSearchTableSection *secObj = self.resultSections[indexPath.section];
    MKMapItem *mapItem = secObj.items[indexPath.row];
    if (![mapItem isKindOfClass:[MKMapItem class]]) {
        return;
    }
    nameAndAddress = [XYLocationSearchTableViewModel stringsForItem:mapItem];
    if ([nameAndAddress.firstObject isKindOfClass:[NSString class]]) {
        name = nameAndAddress.firstObject;
    }
    if ([nameAndAddress.lastObject isKindOfClass:[NSString class]]) {
        address = nameAndAddress.lastObject;
    }
    [self.delegate locationSearchViewController:self didSelectLocationWithName:name address:address mapItem:mapItem];
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    XYLocationSearchTableSection *section = self.resultSections[indexPath.section];
    id rowObj = section.items[indexPath.row];
    if ([section.identifier isEqualToString:@"location"] && ![rowObj isKindOfClass:[MKMapItem class]]) {
        return NO;
    }
    return YES;
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
////////////////////////////////////////////////////////////////////////
- (NSInteger)numberOfSections {
    return self.resultSections.count;
}

- (NSInteger)numberOfRowsInSection:(NSInteger)section {
    return self.resultSections[section].items.count;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - XYLocationSearchTableViewModelDelegate
////////////////////////////////////////////////////////////////////////

- (void)locationSearchTableViewModel:(XYLocationSearchTableViewModel *)viewModel searchResultChange:(NSArray *)searchResult error:(NSError *)error {
    if (![self isSearching]) {
        return;
    }
    // 添加附近的poi
    XYLocationSearchTableSection *nearby = [self sectionWithIdentifier:@"nearby"];
    [nearby.items removeAllObjects];
    
    // 移除搜索的pois
    XYLocationSearchTableSection *result = [self sectionWithIdentifier:@"result"];
    [result.items removeAllObjects];
    [result.items addObjectsFromArray:searchResult];
    
    [self reloadTableData];
}

- (void)locationSearchTableViewModel:(XYLocationSearchTableViewModel *)viewModel didUpdateCurrentLocation:(CLPlacemark *)placemark currentName:(NSString *)name address:(NSString *)address {
    XYLocationSearchTableSection *secObj = [self sectionWithIdentifier:@"location"];
    [secObj.items removeAllObjects];
    if (self.topView.searchBar.text.length) {
        [secObj.items addObject:self.topView.searchBar.text];
    }
    if (placemark) {
        // 将CLPlacemark转换为MKPlacemark
        MKPlacemark *mkPlacemark = [[MKPlacemark alloc] initWithPlacemark:placemark];
        MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:mkPlacemark];
        [secObj.items addObject:mapItem];
    }
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

- (NSMutableArray *)resultSections {
    if (!_resultSections) {
        _resultSections = @[].mutableCopy;
    }
    return _resultSections;
}

@end

@implementation XYLocationSearchTableSection

- (NSMutableArray *)items {
    if (!_items) {
        _items = @[].mutableCopy;
    }
    return _items;
}

@end
