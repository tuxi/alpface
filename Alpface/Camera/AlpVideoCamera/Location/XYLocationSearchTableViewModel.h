//
//  XYLocationSearchTableViewModel.h
//  WeChatExtensions
//
//  Created by Swae on 2017/10/28.
//  Copyright © 2017年 alpface. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

typedef NS_ENUM(NSInteger, XYLocationSearchResultType) {
    XYLocationSearchResultTypeNotKnow, // 不知道什么类型
    XYLocationSearchResultTypeNearBy, /// 附近poi
    XYLocationSearchResultTypeSearchPoi, /// 关键字搜索的poi
};

@class XYLocationSearchTableViewModel;

@protocol XYLocationSearchTableViewModelDelegate <NSObject>

@optional
- (void)locationSearchTableViewModel:(XYLocationSearchTableViewModel *)viewModel searchResultChange:(NSArray<MKMapItem *> *)searchResult error:(NSError *)error;
- (void)locationSearchTableViewModel:(XYLocationSearchTableViewModel *)viewModel didUpdateCurrentLocation:(CLPlacemark *)placemark currentName:(NSString *)name address:(NSString *)address;

@end

@interface XYLocationSearchTableViewModel : NSObject
#if ! __has_feature(objc_arc)
@property (nonatomic, assign) id<XYLocationSearchTableViewModelDelegate> delegate;
#else
@property (nonatomic, weak) id<XYLocationSearchTableViewModelDelegate> delegate;
#endif
/// 搜索关键字
@property (strong, nonatomic) NSString *searchText;
/// 当前地址
@property (nonatomic, strong) NSString *currentAddress;
/// 当前名称
@property (nonatomic, strong) NSString *currentName;
/// 是否正在解析搜索的地址
@property (nonatomic, assign) BOOL reversing;
/// 当前的结果是附近poi还是搜索poi
@property (nonatomic, assign) XYLocationSearchResultType searchResultType;

+ (NSArray *)stringsForItem:(MKMapItem *)item;
- (void)searchFromServer;
- (void)cleanSearch;
/// 根据经纬度检索附近poi
- (void)fetchNearbyInfoWithCoordinate:(CLLocationCoordinate2D)coordinate
                    completionHandler:(void (^)(NSArray<MKMapItem *> *searchResult, NSError *error))completionHandle;
- (void)fetchNearbyInfoCompletionHandler:(void (^)(NSArray<MKMapItem *> *searchResult, NSError *error))completionHandle;

@end
