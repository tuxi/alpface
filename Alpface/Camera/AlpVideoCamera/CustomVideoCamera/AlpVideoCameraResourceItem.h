//
//  AlpVideoCameraResourceItem.h
//  Alpface
//
//  Created by xiaoyuan on 2018/9/17.
//  Copyright © 2018 alpface. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AlpResourceData : NSObject

@property (nonatomic, assign) BOOL isSelected;

@end

@interface AlpMusicData : AlpResourceData

@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) NSInteger eid;
@property (nonatomic, copy) NSString *start_time;
@property (nonatomic, strong) NSArray * artists;
@property (nonatomic, copy) NSString *iconPath;
@property (nonatomic, copy) NSString *audioPath;

@property (nonatomic, assign) NSTimeInterval duration;
@property (nonatomic, assign) NSInteger type;
@property (nonatomic, assign) NSInteger uid;
@property (nonatomic, assign) NSInteger lid;
@property (nonatomic, assign) NSInteger total;

@end

@interface AlpFilterData : AlpResourceData

@property (nonatomic,strong) NSString* name;
@property (nonatomic,strong) NSString* value;
@property (nonatomic,strong) NSString* fillterName;
@property (nonatomic,strong) NSString* iconPath;

@end

@interface AlpStickersData : AlpResourceData

@property (nonatomic,strong) NSString* name;
@property (nonatomic,strong) NSString* StickersImgPaht;

@end

@interface AlpVideoCameraResourceItem : NSObject

@property (nonatomic, strong) NSMutableArray<AlpMusicData *>* musicAry;
@property (nonatomic, strong) NSMutableArray<AlpFilterData *>* filterAry;
@property (nonatomic, strong) NSMutableArray<AlpStickersData *>* stickersAry;

@end
NS_ASSUME_NONNULL_END
