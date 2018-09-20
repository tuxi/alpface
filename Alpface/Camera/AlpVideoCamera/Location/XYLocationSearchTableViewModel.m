
//
//  XYLocationSearchTableViewModel.m
//  WeChatExtensions
//
//  Created by Swae on 2017/10/28.
//  Copyright © 2017年 alpface. All rights reserved.
//

#import "XYLocationSearchTableViewModel.h"
#import <CoreLocation/CoreLocation.h>
#import <AddressBookUI/AddressBookUI.h>
#import "XYLocationManager.h"

#pragma GCC diagnostic ignored "-Wdeprecated-declarations"

@interface XYLocationSearchTableViewModel () <CLLocationManagerDelegate> {
    MKLocalSearch *_search;
}

@end

@implementation XYLocationSearchTableViewModel

////////////////////////////////////////////////////////////////////////
#pragma mark - Initializer
////////////////////////////////////////////////////////////////////////
- (instancetype)init {
    self = [super init];
    if (self) {
        [self cleanSearch];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUpdateLocations:) name:XYUpdateLocationsNotification object:nil];
    }
    return self;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - CLLocationManagerDelegate
////////////////////////////////////////////////////////////////////////
- (void)didUpdateLocations:(NSNotification *)note {
    NSArray *locations = note.object;
    id currentLocation = locations.lastObject;
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    self.reversing = YES;
    [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
         self.reversing = NO;
         if (!(error))
         {
             CLPlacemark *placemark = [placemarks objectAtIndex:0];
             self.currentName = [placemark performSelector:@selector(name)];
             
             NSString *address = ABCreateStringWithAddressDictionary(placemark.addressDictionary, NO);
             address = [address stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
             //             address = [[address componentsSeparatedByString:@"\n"] lastObject];
             self.currentAddress = address;
         }
         else  {
             self.currentName = @"";
             self.currentAddress = @"";
         }
         
     }];

}
    

////////////////////////////////////////////////////////////////////////
#pragma mark - Private
////////////////////////////////////////////////////////////////////////
+ (NSString *)addressForItem:(MKMapItem *)item {
    NSString *address = ABCreateStringWithAddressDictionary(item.placemark.addressDictionary, NO);
    return [address stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
    //    return [[address componentsSeparatedByString:@"\n"] lastObject];
}

+ (NSString *)titleForItem:(MKMapItem *)item {
    return item.name;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Public
////////////////////////////////////////////////////////////////////////
- (void)searchFromServer {
    if (!self.searchText.length) {
        [self cleanSearch];
    }
    else {
        self.reversing = YES;
        self.searchResultType = XYLocationSearchResultTypeSearchPoi;
        // 初始化一个检索请求对象
        MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];
        
        // 创建一个位置信息对象，第一个参数为经纬度，第二个为纬度检索范围，单位为米，第三个为经度检索范围，单位为米
//        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(tocoor, 5000, 5000);
        
        //设置检索参数
//        request.region=region;
        request.naturalLanguageQuery = self.searchText;
        if (_search) {
            [_search cancel];
        }
        _search = [[MKLocalSearch alloc] initWithRequest:request];
        [_search startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
            self.reversing = NO;
            self.searchResultType = XYLocationSearchResultTypeSearchPoi;
            if (self.delegate && [self.delegate respondsToSelector:@selector(locationSearchTableViewModel:searchResultChange:error:)]) {
                [self.delegate locationSearchTableViewModel:self searchResultChange:response.mapItems error:error];
            }
        }];
    }
}

- (void)fetchNearbyInfoCompletionHandler:(void (^)(NSArray<MKMapItem *> *, NSError *))completionHandle {
    [self fetchNearbyInfoWithCoordinate:[XYLocationManager sharedManager].coordinate completionHandler:completionHandle];
}

/// 根据经纬度检索附近poi
- (void)fetchNearbyInfoWithCoordinate:(CLLocationCoordinate2D)coordinate
                    completionHandler:(void (^)(NSArray<MKMapItem *> *, NSError *))completionHandle {
    self.reversing = YES;
    self.searchResultType = XYLocationSearchResultTypeNearBy;
    if (_search) {
        [_search cancel];
    }
    CLLocationCoordinate2D location = coordinate;
    // 创建一个位置信息对象，第一个参数为经纬度，第二个为纬度检索范围，单位为米，第三个为经度检索范围，单位为米
    // 每次只能获取到10e个poi 如果想获取更多可以将1+1
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(location, 1 , 1);
    MKLocalSearchRequest *requst = [[MKLocalSearchRequest alloc] init];
    requst.region = region;
    // poi检索： 就是在指定的区域去搜索 美食、电影、酒店 等服务, 注意最多只有10条数据，数据条数有限制
    requst.naturalLanguageQuery = @"美食"; // 想要检索附近poi的关键词
    _search = [[MKLocalSearch alloc] initWithRequest:requst];
    [_search startWithCompletionHandler:^(MKLocalSearchResponse * _Nullable response, NSError * _Nullable error) {
        self.reversing = NO;
        self.searchResultType = XYLocationSearchResultTypeNearBy;
        if (completionHandle) {
            completionHandle(response.mapItems, error);
        }
    }];
}

+ (NSArray *)stringsForItem:(MKMapItem *)item {
    id name = [self titleForItem:item];
    id address = [self addressForItem:item];
    if (name == nil) {
        name = [NSNull null];
    }
    if (address == nil) {
        address = [NSNull null];
    }
    return @[name, address];
    
}

- (void)cleanSearch {
    self.searchText = @"";
    self.currentName = @"";
    self.currentAddress = @"";
    self.reversing = NO;
    self.searchResultType = XYLocationSearchResultTypeNotKnow;
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
#if ! __has_feature(objc_arc)
    [super dealloc];
#endif
    self.delegate = nil;
}

@end
