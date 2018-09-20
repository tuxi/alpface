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
@property (nonatomic,assign) double longitude;//经度
@property (nonatomic,assign) double latitude;//纬度
//定位结束的回调
@property (nonatomic,strong) void(^locationCompleteBlock)(double longitude,double latitude);
- (void)getAuthorization;//授权
//- (void)alertOpenLocationSwitch;//提示用户打开定位开关
- (void)startLocation;//点击某个按钮开始定位

@end
