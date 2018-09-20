//
//  XYLocationManager.m
//  WeChatExtensions
//
//  Created by Swae on 2017/10/11.
//  Copyright © 2017年 alpface. All rights reserved.
//

#import "XYLocationManager.h"

#pragma clang diagnostic ignored "-Wdeprecated-declarations"

NSNotificationName const XYUpdateLocationsNotification = @"XYUpdateLocationsNotification";

@interface XYLocationManager () <UIAlertViewDelegate>

@end

@implementation XYLocationManager

+(instancetype)sharedManager
{
    static id  _sharedGps = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedGps = [[self alloc] init];
    });
    return _sharedGps;
}


//kCLAuthorizationStatusNotDetermined： 用户尚未做出决定是否启用定位服务
//kCLAuthorizationStatusRestricted： 没有获得用户授权使用定位服务
//kCLAuthorizationStatusDenied ：用户已经明确禁止应用使用定位服务或者当前系统定位服务处于关闭状态
//kCLAuthorizationStatusAuthorizedAlways： 应用获得授权可以一直使用定位服务，即使应用不在使用状态
//kCLAuthorizationStatusAuthorizedWhenInUse： 使用此应用过程中允许访问定位服务
- (void)getAuthorization
{
    // Setup location services
    if (![CLLocationManager locationServicesEnabled]) {
        NSLog(@"Please enable location services");
        return;
    }
    
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
        NSLog(@"Please authorize location services");
        return;
    }
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        
        switch ([CLLocationManager authorizationStatus]) {
            case kCLAuthorizationStatusAuthorizedAlways:
            case kCLAuthorizationStatusAuthorizedWhenInUse:
                break;
                
            case kCLAuthorizationStatusNotDetermined:
                [self.locationManager requestWhenInUseAuthorization];
                break;
            case kCLAuthorizationStatusDenied:
                [self alertOpenLocationSwitch];
                break;
            default:
                break;
        }
    }
    
}

///提示用户打开定位开关
- (void)alertOpenLocationSwitch
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请在隐私设置中打开定位开关" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
    
    
}

- (void)startLocation {
    [_locationManager startUpdatingLocation];
}

- (void)stopUpdatingLocation {
    [_locationManager stopUpdatingLocation];
}

#pragma mark - LocationManager
- (CLLocationManager *)locationManager {
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;//定位精确度
        _locationManager.distanceFilter = 10;//10米定位一次
    }
    return _locationManager;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - UIAlertViewDelegate
////////////////////////////////////////////////////////////////////////

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
}

////////////////////////////////////////////////////////////////////////
#pragma mark - CLLocationManagerDelegate

/// 跟踪定位代理方法，每次位置发生变化即会执行（只要定位到相应位置）
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation *location = [locations lastObject];
    // 取出经纬度
    CLLocationCoordinate2D coordinate = location.coordinate;
    self.coordinate = coordinate;
    // 获取到位置后停止定位
    [_locationManager stopUpdatingLocation];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:XYUpdateLocationsNotification object:locations];
}

/// 定位权限改变时调用
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    
    if (status == kCLAuthorizationStatusDenied) {
        [self alertOpenLocationSwitch];
    }
    if (status == kCLAuthorizationStatusAuthorizedAlways || status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        [manager startUpdatingLocation];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CLLocationChangeAuthorizationStatusNotification" object:self userInfo:@{@"CLAuthorizationStatus": @(status)}];
}
@end
