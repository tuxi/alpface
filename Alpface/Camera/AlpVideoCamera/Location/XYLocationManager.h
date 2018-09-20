//
//  XYLocationManager.h
//  WeChatExtensions
//
//  Created by Swae on 2017/10/11.
//  Copyright © 2017年 alpface. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>

FOUNDATION_EXPORT NSNotificationName const XYUpdateLocationsNotification;

@interface XYLocationManager : NSObject <CLLocationManagerDelegate>

+ (instancetype)sharedManager;

@property (strong, nonatomic) CLLocationManager *locationManager;
/// 当前位置
//@property (nonatomic,assign) double longitude;//经度
//@property (nonatomic,assign) double latitude;//纬度
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
/// 记录是否已获取过位置
@property (nonatomic, assign) BOOL getGpsPostion;

/// 请求定位授权
- (void)getAuthorization;

// 开始定位
- (void)startLocation;
- (void)stopUpdatingLocation;

@end
