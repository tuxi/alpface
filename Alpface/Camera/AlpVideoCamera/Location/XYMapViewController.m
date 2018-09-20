//
//  XYMapViewController.m
//  WeChatExtensions
//
//  Created by Swae on 2017/10/11.
//  Copyright © 2017年 alpface. All rights reserved.
//

#import "XYMapViewController.h"
#import <MapKit/MapKit.h>
#import "XYLocationManager.h"
#import "LocationConverter.h"
#import "XYLocationSearchViewController.h"

#define UIColorHexFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define UIColorHexFromRGBAlpha(rgbValue,alp) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:alp]

@interface XYMapBottomBackgroundView : UIView

@property (nonatomic, strong) UILabel *addressLabel;
@property (nonatomic, strong) UILabel *longitudeLabel;//经度
@property (nonatomic, strong) UILabel *latitudeLabel;//纬度

@end

@interface XYMyAnotation : NSObject <MKAnnotation>
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, copy) NSString *icon;

+ (UIImage *)circularDoubleCircleWithDiamter:(NSUInteger)diameter;
@end


@interface XYMapViewController () <MKMapViewDelegate, XYLocationSearchViewControllerDelegate>

@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, strong) LocationConverter *locManager;
@property (nonatomic, strong) XYMapBottomBackgroundView *bottomView;
@property (nonatomic, strong) UIButton *mapCenterBtn;
@property (nonatomic, strong) UIButton *searchBtn;

@end

@implementation XYMapViewController

- (MKMapView *)mapView {
    if (!_mapView) {
        _mapView = [[MKMapView alloc] init];
        _mapView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _mapView;
}

- (XYMapBottomBackgroundView *)bottomView {
    if (!_bottomView) {
        _bottomView = [XYMapBottomBackgroundView new];
        _bottomView.backgroundColor = UIColorHexFromRGBAlpha(0xffffff, 0.7);
        _bottomView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _bottomView;
}
- (UIButton *)mapCenterBtn {
    if (!_mapCenterBtn) {
        _mapCenterBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _mapCenterBtn.titleLabel.font = [UIFont systemFontOfSize:10];
        [_mapCenterBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_mapCenterBtn setTitle:@"地图中心" forState:UIControlStateNormal];
        [_mapCenterBtn addTarget:self action:@selector(currentLocationBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        _mapCenterBtn.translatesAutoresizingMaskIntoConstraints = NO;
        _mapCenterBtn.layer.cornerRadius = 50.0*0.5;
        _mapCenterBtn.layer.masksToBounds = YES;
        _mapCenterBtn.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    }
    return _mapCenterBtn;
}

- (UIButton *)searchBtn {
    if (!_searchBtn) {
        _searchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _searchBtn.titleLabel.font = [UIFont systemFontOfSize:10];
        [_searchBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_searchBtn setTitle:@"搜索位置" forState:UIControlStateNormal];
        [_searchBtn addTarget:self action:@selector(searchBtnClick) forControlEvents:UIControlEventTouchUpInside];
        _searchBtn.translatesAutoresizingMaskIntoConstraints = NO;
        _searchBtn.layer.cornerRadius = 50.0*0.5;
        _searchBtn.layer.masksToBounds = YES;
        _searchBtn.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    }
    return _searchBtn;
}



- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"地图";
    [self.view addSubview:self.mapView];
    [self.view addSubview:self.bottomView];
    [self.view addSubview:self.mapCenterBtn];
    [self.view addSubview:self.searchBtn];
    [self setupConstraints];
    
    
    XYLocationManager *loc = [XYLocationManager sharedManager];
    [loc getAuthorization];//授权
    [loc startLocation];//开始定位
    
    //跟踪用户位置
    self.mapView.userTrackingMode = MKUserTrackingModeFollow;
    //地图类型
    //    self.mapView.mapType = MKMapTypeSatellite;
    self.mapView.delegate = self;
    
    
    XYMyAnotation *anno = [[XYMyAnotation alloc] init];
    anno.coordinate = CLLocationCoordinate2DMake([XYLocationManager sharedManager].latitude, [XYLocationManager sharedManager].longitude);
    anno.title = [NSString stringWithFormat:@"经度：%f",[XYLocationManager sharedManager].longitude];
    anno.subtitle = [NSString stringWithFormat:@"纬度：%f",[XYLocationManager sharedManager].latitude];
    
    self.bottomView.longitudeLabel.text = [NSString stringWithFormat:@"经度：%f",[XYLocationManager sharedManager].longitude];
    self.bottomView.latitudeLabel.text = [NSString stringWithFormat:@"纬度：%f",[XYLocationManager sharedManager].latitude];
    //反地理编码
    _locManager = [[LocationConverter alloc] init];
    [_locManager reverseGeocodeWithlatitude:[XYLocationManager sharedManager].latitude longitude:[XYLocationManager sharedManager].longitude success:^(NSString *address) {
        self.bottomView.addressLabel.text = [NSString stringWithFormat:@"%@",address];
    } failure:^{
        
    }];
    
    [self.mapView addAnnotation:anno];
    
    
    [self.mapView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)]];
}


- (void)currentLocationBtnAction:(id)sender {
    [self.mapView setCenterCoordinate:self.mapView.userLocation.coordinate animated:YES];
}

- (void)searchBtnClick {
    XYLocationSearchViewController *vc = [XYLocationSearchViewController new];
    vc.delegate = self;
    [self.navigationController showViewController:vc sender:self];
}


- (void)setupConstraints {
    NSDictionary *viewDict = @{@"bottomView": self.bottomView, @"mapView": self.mapView};
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[mapView]|" options:kNilOptions metrics:nil views:viewDict]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[mapView]|" options:kNilOptions metrics:nil views:viewDict]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[bottomView]|" options:kNilOptions metrics:nil views:viewDict]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[bottomView]|" options:kNilOptions metrics:nil views:viewDict]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.mapCenterBtn attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:-10.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.mapCenterBtn attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.bottomView attribute:NSLayoutAttributeTop multiplier:1.0 constant:-10.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.mapCenterBtn attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:50.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.mapCenterBtn attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:50.0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.searchBtn attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:10.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.searchBtn attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.bottomView attribute:NSLayoutAttributeTop multiplier:1.0 constant:-10.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.searchBtn attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:50.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.searchBtn attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:50.0]];
    
    [self.view layoutIfNeeded];
}

/**
 * 当用户位置更新，就会调用
 *
 * userLocation 表示地图上面那可蓝色的大头针的数据
 */
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    CLLocationCoordinate2D center = userLocation.location.coordinate;
    userLocation.title = [NSString stringWithFormat:@"经度：%f",center.longitude];
    userLocation.subtitle = [NSString stringWithFormat:@"纬度：%f",center.latitude];
    
    NSLog(@"定位：%f %f --- %i",center.latitude,center.longitude,mapView.showsUserLocation);
    
    
    
    
    //设置地图的中心点，（以用户所在的位置为中心点）
    //    [mapView setCenterCoordinate:userLocation.location.coordinate animated:YES];
    
    //设置地图的显示范围
    //    MKCoordinateSpan span = MKCoordinateSpanMake(0.023666, 0.016093);
    //    MKCoordinateRegion region = MKCoordinateRegionMake(center, span);
    //    [mapView setRegion:region animated:YES];
    
}

//- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
//{
//    //获取跨度
//    NSLog(@"%f  %f",mapView.region.span.latitudeDelta,mapView.region.span.longitudeDelta);
//}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    //如果是定位的大头针就不用自定义
    if (![annotation isKindOfClass:[XYMyAnotation class]]) {
        return nil;
    }
    
    static NSString *ID = @"anno";
    MKAnnotationView *annoView = [mapView dequeueReusableAnnotationViewWithIdentifier:ID];
    if (annoView == nil) {
        annoView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:ID];
    }
    
    XYMyAnotation *anno = annotation;
    UIImage *img = [XYMyAnotation circularDoubleCircleWithDiamter:20];
    annoView.image = img;
    annoView.annotation = anno;
    
    return annoView;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    NSLog(@"didSelectAnnotationView--%@",view);
}


- (void)tap:(UITapGestureRecognizer *)tap {
    [self.view layoutIfNeeded];
    CGPoint touchPoint = [tap locationInView:tap.view];
    CLLocationCoordinate2D coordinate = [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];
    [self updateLocationWithCoordinate:coordinate];
    
}

- (void)updateLocationWithCoordinate:(CLLocationCoordinate2D)coordinate {
    [XYLocationManager sharedManager].latitude = coordinate.latitude;
    [XYLocationManager sharedManager].longitude = coordinate.longitude;
    
    NSLog(@"%@",self.mapView.annotations);
    NSMutableArray *array = [NSMutableArray array];
    NSUInteger count = self.mapView.annotations.count;
    if (count > 1) {
        for (id obj in self.mapView.annotations) {
            if (![obj isKindOfClass:[MKUserLocation class]]) {
                [array addObject:obj];
            }
        }
        [self.mapView removeAnnotations:array];
    }
    
    XYMyAnotation *anno = [[XYMyAnotation alloc] init];
    
    anno.coordinate = coordinate;
    anno.title = [NSString stringWithFormat:@"经度：%f",coordinate.longitude];
    anno.subtitle = [NSString stringWithFormat:@"纬度：%f",coordinate.latitude];
    
    self.bottomView.longitudeLabel.text = [NSString stringWithFormat:@"经度：%f",coordinate.longitude];
    self.bottomView.latitudeLabel.text = [NSString stringWithFormat:@"纬度：%f",coordinate.latitude];
    //反地理编码
    [_locManager reverseGeocodeWithlatitude:coordinate.latitude longitude:coordinate.longitude success:^(NSString *address) {
        self.bottomView.addressLabel.text = [NSString stringWithFormat:@"%@",address];
    } failure:^{
        
    }];
    
    
    [self.mapView addAnnotation:anno];
    [self.mapView setCenterCoordinate:coordinate animated:YES];
}


////////////////////////////////////////////////////////////////////////
#pragma mark - XYLocationSearchViewControllerDelegate
////////////////////////////////////////////////////////////////////////
- (void)locationSearchViewController:(UIViewController *)sender didSelectLocationWithName:(NSString *)name address:(NSString *)address mapItem:(MKMapItem *)mapItm {
    
    CLLocationCoordinate2D coordinate;
    if (mapItm == nil) {
        coordinate = CLLocationCoordinate2DMake([XYLocationManager sharedManager].latitude, [XYLocationManager sharedManager].longitude);
    }
    else {
        CLLocation *location = [mapItm.placemark performSelector:@selector(location)];
        coordinate  = location.coordinate;
    }
    
    [self updateLocationWithCoordinate:coordinate];
    
//    [self.presentedViewController dismissViewControllerAnimated:YES completion:NULL];
    [[sender navigationController] popViewControllerAnimated:YES];
}


@end


@implementation XYMyAnotation
+ (UIImage *)circularDoubleCircleWithDiamter:(NSUInteger)diameter {
    
    NSParameterAssert(diameter > 0);
    CGRect frame = CGRectMake(0.0f, 0.0f, diameter + diameter/4, diameter);
    
    UIScreen *screen = [UIScreen mainScreen];
    CGFloat scale = screen.scale;
    
    UIGraphicsBeginImageContextWithOptions(frame.size, NO, scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    CGRect frameBlue = CGRectMake(diameter/4, 0, diameter, diameter);
    CGRect frameRed = CGRectMake(0, 0, diameter, diameter);
    
    
    //蓝色的渐变圆
    CGContextSaveGState(context);
    UIBezierPath *imgPath = [UIBezierPath bezierPathWithOvalInRect:frameBlue];
    [imgPath addClip];
    [self drawLinearGradient:context colorBottom:UIColorHexFromRGBAlpha(0x0874e8,0.95) topColor:UIColorHexFromRGBAlpha(0x028fe8,0.95) frame:frameBlue];
    CGContextRestoreGState(context);
    
    //红色圆的边框
    CGContextSaveGState(context);
    CGFloat lineWidth = 0.5;
    CGContextSetLineWidth(context, lineWidth);
    UIBezierPath *outlinePath = [UIBezierPath bezierPathWithOvalInRect:frameRed];
    UIColor *colorWhite = UIColorHexFromRGBAlpha(0xf5f3f0, 1.0);
    CGContextSetStrokeColorWithColor(context, colorWhite.CGColor);
    CGContextAddPath(context, outlinePath.CGPath);
    CGContextStrokePath(context);
    CGContextRestoreGState(context);
    
    
    //红色的渐变圆
    CGRect framered2 = CGRectInset(frameRed, 0.25, 0.25);
    CGContextSaveGState(context);
    UIBezierPath *imgPath2 = [UIBezierPath bezierPathWithOvalInRect:framered2];
    [imgPath2 addClip];
    [self drawLinearGradient:context colorBottom:UIColorHexFromRGBAlpha(0xf34f18,0.95) topColor:UIColorHexFromRGBAlpha(0xfb6701,0.95) frame:framered2];
    CGContextRestoreGState(context);
    
    
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    CGContextRestoreGState(context);
    UIGraphicsEndImageContext();
    return newImage;
}

+ (void)drawLinearGradient:(CGContextRef)context colorBottom:(UIColor *)colorBottom topColor:(UIColor *)topColor frame:(CGRect)frame{
    //使用rgb颜色空间
    CGColorSpaceRef colorSpace=CGColorSpaceCreateDeviceRGB();
    
    //创建起点颜色
    CGColorRef
    beginColor = colorBottom.CGColor;
    
    //创建终点颜色
    CGColorRef
    endColor = topColor.CGColor;
    
    //创建颜色数组
    CFArrayRef
    colorArray = CFArrayCreate(kCFAllocatorDefault, (const void*[]){beginColor,
        endColor}, 2, nil);
    
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef)colorArray, NULL);
    
    
    /*绘制线性渐变
     context:图形上下文
     gradient:渐变色
     startPoint:起始位置
     endPoint:终止位置
     options:绘制方式,kCGGradientDrawsBeforeStartLocation 开始位置之前就进行绘制，到结束位置之后不再绘制，
     kCGGradientDrawsAfterEndLocation开始位置之前不进行绘制，到结束点之后继续填充
     */
    CGContextDrawLinearGradient(context, gradient, CGPointZero, CGPointMake(frame.size.width, frame.size.height), kCGGradientDrawsAfterEndLocation);
    CFRelease(gradient);
    //释放颜色空间
    CFRelease(colorArray);
    CGColorSpaceRelease(colorSpace);
}

@end

@implementation XYMapBottomBackgroundView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (!self) {
        return nil;
    }
    
    [self setupViews];
    [self setupConstraints];
    return self;
}

- (void)setupViews {
    [self addSubview:self.addressLabel];
    [self addSubview:self.longitudeLabel];
    [self addSubview:self.latitudeLabel];
    [self setupConstraints];
}

- (void)setupConstraints {
    
    self.translatesAutoresizingMaskIntoConstraints = NO;
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_longitudeLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_longitudeLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:20.0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_longitudeLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_longitudeLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.0]];
    
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_addressLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_longitudeLabel attribute:NSLayoutAttributeTop multiplier:1.0 constant:-5.0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_addressLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_addressLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_addressLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:20.0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_latitudeLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_longitudeLabel attribute:NSLayoutAttributeBottom multiplier:1.0 constant:5.0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_latitudeLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_latitudeLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_latitudeLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:20.0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_addressLabel attribute:NSLayoutAttributeTop multiplier:1.0 constant:-10.0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_latitudeLabel attribute:NSLayoutAttributeBottom multiplier:1.0 constant:10.0]];
}

- (UILabel *)addressLabel {
    if (!_addressLabel) {
        
        _addressLabel = [UILabel new];
        _addressLabel.textColor = [UIColor blackColor];
        _addressLabel.font = [UIFont systemFontOfSize:12];
        _addressLabel.textAlignment = NSTextAlignmentCenter;
        _addressLabel.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _addressLabel;
}

- (UILabel *)longitudeLabel {
    if (!_longitudeLabel) {
        _longitudeLabel = [UILabel new];
        _longitudeLabel.textColor = [UIColor blackColor];
        _longitudeLabel.font = [UIFont systemFontOfSize:12];
        _longitudeLabel.textAlignment = NSTextAlignmentCenter;
        _longitudeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _longitudeLabel;
}

- (UILabel *)latitudeLabel {
    if (!_latitudeLabel) {
        _latitudeLabel = [UILabel new];
        _latitudeLabel.textColor = [UIColor blackColor];
        _latitudeLabel.font = [UIFont systemFontOfSize:12];
        _latitudeLabel.textAlignment = NSTextAlignmentCenter;
        _latitudeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _latitudeLabel;
}

@end

