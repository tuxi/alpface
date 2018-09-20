
#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface LocationConverter : NSObject

/**
*  世界标准地理坐标(WGS-84) 转换成 中国国测局地理坐标（GCJ-02）<火星坐标>
*
*  @warning 只在中国大陆的范围的坐标有效，以外直接返回世界标准坐标
*
*  @param     location     世界标准地理坐标(WGS-84)
*  @return    中国国测局地理坐标（GCJ-02）<火星坐标>
*/
+ (CLLocationCoordinate2D)wgs84ToGcj02:(CLLocationCoordinate2D)location;


/**
 *  中国国测局地理坐标（GCJ-02） 转换成 世界标准地理坐标（WGS-84）
 *
 *  @warning 此接口有1－2米左右的误差，需要精确定位情景慎用
 *
 *  @param     location     中国国测局地理坐标（GCJ-02）
 *  @return    世界标准地理坐标（WGS-84）
 */
+ (CLLocationCoordinate2D)gcj02ToWgs84:(CLLocationCoordinate2D)location;


/**
 *  世界标准地理坐标(WGS-84) 转换成 百度地理坐标（BD-09)
 *
 *  @param     location     世界标准地理坐标(WGS-84)
 *  @return    百度地理坐标（BD-09)
 */
+ (CLLocationCoordinate2D)wgs84ToBd09:(CLLocationCoordinate2D)location;


/**
 *  中国国测局地理坐标（GCJ-02）<火星坐标> 转换成 百度地理坐标（BD-09)
 *
 *  @param     location     中国国测局地理坐标（GCJ-02）<火星坐标>
 *  @return    百度地理坐标（BD-09)
 */
+ (CLLocationCoordinate2D)gcj02ToBd09:(CLLocationCoordinate2D)location;


/**
 *  百度地理坐标（BD-09) 转换成 中国国测局地理坐标（GCJ-02）<火星坐标>
 *
 *  @param     location     百度地理坐标（BD-09)
 *  @return    中国国测局地理坐标（GCJ-02）<火星坐标>
 */
+ (CLLocationCoordinate2D)bd09ToGcj02:(CLLocationCoordinate2D)location;


/**
 *  百度地理坐标（BD-09) 转换成 世界标准地理坐标（WGS-84）
 *
 * @warning 此接口有1－2米左右的误差，需要精确定位情景慎用
 *
 *  @param     location     百度地理坐标（BD-09)
 *  @return    世界标准地理坐标（WGS-84）
 */
+ (CLLocationCoordinate2D)bd09ToWgs84:(CLLocationCoordinate2D)location;

/**
 *  地理编码 （通过地址获取经纬度）
 *
 *  @param address       输入的地址
 *  @param success       成功block，返回pm
 *  @param failure       失败block
 */
- (void)geocode:(NSString *)address success:(void(^)(CLPlacemark *pm))success failure:(void(^)(void))failure;


/**
 *  反地理编码 （通过经纬度获取地址）
 *
 *  @param latitude      输入的纬度
 *  @param longitude     输入经度
 *  @param success       成功block，返回pm
 *  @param failure       失败block
 */
- (void)reverseGeocodeWithlatitude:(CLLocationDegrees )latitude longitude:(CLLocationDegrees)longitude success:(void(^)(NSString *address))success failure:(void(^)(void))failure;

/**
 *  经纬度计算两地之间距离
 *
 *  @param lon1      目标的的经度
 *  @param lat1      目标的纬度
 *  @param lon2      自己的经度
 *  @param lat2      自己的纬度
 *  @return 返回值     距离（米）
 */
+ (double)LantitudeLongitudeDist:(double)lon1 other_Lat:(double)lat1 self_Lon:(double)lon2 self_Lat:(double)lat2;


+ (double)countLineDistanceDest:(double)lon1 dest_Lat:(double)lat1 self_Lon:(double)lon2 self_Lat:(double)lat2;

@end
