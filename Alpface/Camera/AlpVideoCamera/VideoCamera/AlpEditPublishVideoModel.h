//
//  AlpEditPublishVideoModel.h
//  Alpface
//
//  Created by xiaoyuan on 2018/10/8.
//  Copyright © 2018 alpface. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, AlpPublishVideoPermissionType) {
    AlpPublishVideoPermissionTypePublic,
    AlpPublishVideoPermissionTypePrivate,
    AlpPublishVideoPermissionTypeFriend,
};

@interface AlpEditPublishVideoModel : NSObject

@property (nonatomic, strong) NSURL *videoURL;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *address;
@property (nonatomic, copy) NSString *locationName;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, assign) AlpPublishVideoPermissionType permissionType;
@property (nonatomic, assign, getter=isSaveAlbum) BOOL saveAlbum;
@property (nonatomic, assign) double startSecondsOfCover;
@property (nonatomic, assign) double endSecondsOfCover;

@end

NS_ASSUME_NONNULL_END
