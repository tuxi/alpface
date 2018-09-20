
#import "LocationConverter.h"

#pragma GCC diagnostic ignored "-Wunused"

#define LAT_OFFSET_0(x,y) -100.0 + 2.0 * x + 3.0 * y + 0.2 * y * y + 0.1 * x * y + 0.2 * sqrt(fabs(x))
#define LAT_OFFSET_1 (20.0 * sin(6.0 * x * M_PI) + 20.0 * sin(2.0 * x * M_PI)) * 2.0 / 3.0
#define LAT_OFFSET_2 (20.0 * sin(y * M_PI) + 40.0 * sin(y / 3.0 * M_PI)) * 2.0 / 3.0
#define LAT_OFFSET_3 (160.0 * sin(y / 12.0 * M_PI) + 320 * sin(y * M_PI / 30.0)) * 2.0 / 3.0

#define LON_OFFSET_0(x,y) 300.0 + x + 2.0 * y + 0.1 * x * x + 0.1 * x * y + 0.1 * sqrt(fabs(x))
#define LON_OFFSET_1 (20.0 * sin(6.0 * x * M_PI) + 20.0 * sin(2.0 * x * M_PI)) * 2.0 / 3.0
#define LON_OFFSET_2 (20.0 * sin(x * M_PI) + 40.0 * sin(x / 3.0 * M_PI)) * 2.0 / 3.0
#define LON_OFFSET_3 (150.0 * sin(x / 12.0 * M_PI) + 300.0 * sin(x / 30.0 * M_PI)) * 2.0 / 3.0

#define RANGE_LON_MAX 137.8347
#define RANGE_LON_MIN 72.004
#define RANGE_LAT_MAX 55.8271
#define RANGE_LAT_MIN 0.8293
// jzA = 6378245.0, 1/f = 298.3
// b = a * (1 - f)
// ee = (a^2 - b^2) / a^2;
#define jzA 6378245.0
#define jzEE 0.00669342162296594323

#define PI 3.141592653

@interface LocationConverter ()
@property (nonatomic,strong) CLGeocoder *geocoder;
@end

@implementation LocationConverter

+ (double)transformLat:(double)x bdLon:(double)y {
    double ret = LAT_OFFSET_0(x, y);
    ret += LAT_OFFSET_1;
    ret += LAT_OFFSET_2;
    ret += LAT_OFFSET_3;
    return ret;
}

+ (double)transformLon:(double)x bdLon:(double)y {
    double ret = LON_OFFSET_0(x, y);
    ret += LON_OFFSET_1;
    ret += LON_OFFSET_2;
    ret += LON_OFFSET_3;
    return ret;
}

+ (BOOL)outOfChina:(double)lat bdLon:(double)lon
{
    if (lon < RANGE_LON_MIN || lon > RANGE_LON_MAX)
        return true;
    if (lat < RANGE_LAT_MIN || lat > RANGE_LAT_MAX)
        return true;
    return false;
}

+ (CLLocationCoordinate2D)gcj02Encrypt:(double)ggLat bdLon:(double)ggLon {
    CLLocationCoordinate2D resPoint;
    double mgLat;
    double mgLon;
    if ([self outOfChina:ggLat bdLon:ggLon]) {
        resPoint.latitude = ggLat;
        resPoint.longitude = ggLon;
        return resPoint;
    }
    double dLat = [self transformLat:(ggLon - 105.0)bdLon:(ggLat - 35.0)];
    double dLon = [self transformLon:(ggLon - 105.0) bdLon:(ggLat - 35.0)];
    double radLat = ggLat / 180.0 * M_PI;
    double magic = sin(radLat);
    magic = 1 - jzEE * magic * magic;
    double sqrtMagic = sqrt(magic);
    dLat = (dLat * 180.0) / ((jzA * (1 - jzEE)) / (magic * sqrtMagic) * M_PI);
    dLon = (dLon * 180.0) / (jzA / sqrtMagic * cos(radLat) * M_PI);
    mgLat = ggLat + dLat;
    mgLon = ggLon + dLon;
    
    resPoint.latitude = mgLat;
    resPoint.longitude = mgLon;
    return resPoint;
}

+ (CLLocationCoordinate2D)gcj02Decrypt:(double)gjLat gjLon:(double)gjLon {
    CLLocationCoordinate2D  gPt = [self gcj02Encrypt:gjLat bdLon:gjLon];
    double dLon = gPt.longitude - gjLon;
    double dLat = gPt.latitude - gjLat;
    CLLocationCoordinate2D pt;
    pt.latitude = gjLat - dLat;
    pt.longitude = gjLon - dLon;
    return pt;
}

+ (CLLocationCoordinate2D)bd09Decrypt:(double)bdLat bdLon:(double)bdLon {
    CLLocationCoordinate2D gcjPt;
    double x = bdLon - 0.0065, y = bdLat - 0.006;
    double z = sqrt(x * x + y * y) - 0.00002 * sin(y * M_PI);
    double theta = atan2(y, x) - 0.000003 * cos(x * M_PI);
    gcjPt.longitude = z * cos(theta);
    gcjPt.latitude = z * sin(theta);
    return gcjPt;
}

+(CLLocationCoordinate2D)bd09Encrypt:(double)ggLat bdLon:(double)ggLon {
    CLLocationCoordinate2D bdPt;
    double x = ggLon, y = ggLat;
    double z = sqrt(x * x + y * y) + 0.00002 * sin(y * M_PI);
    double theta = atan2(y, x) + 0.000003 * cos(x * M_PI);
    bdPt.longitude = z * cos(theta) + 0.0065;
    bdPt.latitude = z * sin(theta) + 0.006;
    return bdPt;
}


+ (CLLocationCoordinate2D)wgs84ToGcj02:(CLLocationCoordinate2D)location {
    return [self gcj02Encrypt:location.latitude bdLon:location.longitude];
}

+ (CLLocationCoordinate2D)gcj02ToWgs84:(CLLocationCoordinate2D)location {
    return [self gcj02Decrypt:location.latitude gjLon:location.longitude];
}


+ (CLLocationCoordinate2D)wgs84ToBd09:(CLLocationCoordinate2D)location {
    CLLocationCoordinate2D gcj02Pt = [self gcj02Encrypt:location.latitude
                                                  bdLon:location.longitude];
    return [self bd09Encrypt:gcj02Pt.latitude bdLon:gcj02Pt.longitude] ;
}

+ (CLLocationCoordinate2D)gcj02ToBd09:(CLLocationCoordinate2D)location {
    return  [self bd09Encrypt:location.latitude bdLon:location.longitude];
}

+ (CLLocationCoordinate2D)bd09ToGcj02:(CLLocationCoordinate2D)location {
    return [self bd09Decrypt:location.latitude bdLon:location.longitude];
}

+ (CLLocationCoordinate2D)bd09ToWgs84:(CLLocationCoordinate2D)location {
    CLLocationCoordinate2D gcj02 = [self bd09ToGcj02:location];
    return [self gcj02Decrypt:gcj02.latitude gjLon:gcj02.longitude];
}

- (CLGeocoder *)geocoder
{
    if (!_geocoder) {
        _geocoder = [[CLGeocoder alloc] init];
    }
    return _geocoder;
}

#pragma mark - 地理编码
- (void)geocode:(NSString *)address success:(void(^)(CLPlacemark *pm))success failure:(void(^)(void))failure
{
    [self.geocoder geocodeAddressString:address completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error) {
            if (failure) {
                failure();
            }
        } else {// 编码成功
            //取出最前面的地址
            CLPlacemark *pm = [placemarks firstObject];
            if (success) {
                success(pm);
            }
        }
    }];
}

#pragma mark - 反地理编码
- (void)reverseGeocodeWithlatitude:(CLLocationDegrees )latitude longitude:(CLLocationDegrees)longitude success:(void(^)(NSString *address))success failure:(void(^)(void))failure
{
    
    CLLocation *loc = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
    [self.geocoder reverseGeocodeLocation:loc completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error) {
            NSLog(@"%@",error.description);
            if (failure) {
                failure();
            }
        } else {
            CLPlacemark *pm = [placemarks firstObject];
            NSString *name = [pm performSelector:@selector(name)];
            if (success) {
                success(name);
            }
        }
    }];
}

#pragma mark - 通过经纬度计算距离
+ (double)LantitudeLongitudeDist:(double)lon1 other_Lat:(double)lat1 self_Lon:(double)lon2 self_Lat:(double)lat2
{
    double er = 6378137; // 6378700.0f;
    //ave. radius = 6371.315 (someone said more accurate is 6366.707)
    //equatorial radius = 6378.388
    //nautical mile = 1.15078
    double radlat1 = PI*lat1/180.0f;
    double radlat2 = PI*lat2/180.0f;
    //now long.
    double radlong1 = PI*lon1/180.0f;
    double radlong2 = PI*lon2/180.0f;
    if( radlat1 < 0 ) radlat1 = PI/2 + fabs(radlat1);// south
    if( radlat1 > 0 ) radlat1 = PI/2 - fabs(radlat1);// north
    if( radlong1 < 0 ) radlong1 = PI*2 - fabs(radlong1);//west
    if( radlat2 < 0 ) radlat2 = PI/2 + fabs(radlat2);// south
    if( radlat2 > 0 ) radlat2 = PI/2 - fabs(radlat2);// north
    if( radlong2 < 0 ) radlong2 = PI*2 - fabs(radlong2);// west
    //spherical coordinates x=r*cos(ag)sin(at), y=r*sin(ag)*sin(at), z=r*cos(at)
    //zero ag is up so reverse lat
    double x1 = er * cos(radlong1) * sin(radlat1);
    double y1 = er * sin(radlong1) * sin(radlat1);
    double z1 = er * cos(radlat1);
    double x2 = er * cos(radlong2) * sin(radlat2);
    double y2 = er * sin(radlong2) * sin(radlat2);
    double z2 = er * cos(radlat2);
    double d = sqrt((x1-x2)*(x1-x2)+(y1-y2)*(y1-y2)+(z1-z2)*(z1-z2));
    //side, side, side, law of cosines and arccos
    double theta = acos((er*er+er*er-d*d)/(2*er*er));
    double dist  = theta*er;
    return dist;
}

#pragma mark - 系统方法计算距离
+ (double)countLineDistanceDest:(double)lon1 dest_Lat:(double)lat1 self_Lon:(double)lon2 self_Lat:(double)lat2
{
    //计算2个经纬度之间的直线距离
    CLLocation *destloc = [[CLLocation alloc] initWithLatitude:lat1 longitude:lon1];
    CLLocation *selfloc = [[CLLocation alloc] initWithLatitude:lat2 longitude:lon2];
    CLLocationDistance distance = [destloc distanceFromLocation:selfloc];
    return distance;
}

@end
