//
//  AlpVideoCameraResourceItem.m
//  Alpface
//
//  Created by xiaoyuan on 2018/9/17.
//  Copyright © 2018 alpface. All rights reserved.
//

#import "AlpVideoCameraResourceItem.h"
#import "AlpVideoCameraUtils.h"

@implementation AlpVideoCameraResourceItem

- (instancetype)init
{
    self = [super init];
    if (self) {
        _musicAry = [NSMutableArray arrayWithArray:[self creatMusicData]];
        _filterAry = [NSMutableArray arrayWithArray:[self creatFilterData]];
        _stickersAry = [NSMutableArray arrayWithArray:[self creatStickersData]];
    }
    return self;
}
-(NSArray<AlpMusicData *>*)creatMusicData {
    
    /// musics.json 来自 爱动小视频的音乐页面抓取
    NSString *configPath = [[AlpVideoCameraUtils alpVideoCameraBundle] pathForResource:@"music/musics" ofType:@"json"];
    NSData *configData = [NSData dataWithContentsOfFile:configPath];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:configData options:NSJSONReadingAllowFragments error:nil];
    NSArray *items = dic[@"data"][@"musics"];
    NSMutableArray *array = [NSMutableArray array];
    
    AlpMusicData *effect = [[AlpMusicData alloc] init];
    effect.name = @"原始";
    effect.iconPath = [[AlpVideoCameraUtils alpVideoCameraBundle] pathForResource:@"camera_icon/nilMusic" ofType:@"png"];
    effect.isSelected = YES;
    [array addObject:effect];
    
    
    for (NSDictionary *item in items) {
        AlpMusicData *effect = [[AlpMusicData alloc] init];
        effect.name = item[@"name"];
        effect.eid = [item[@"id"] integerValue];
        effect.start_time = item[@"start_time"];
        effect.artists = item[@"artists"];
        effect.audioPath = [[AlpVideoCameraUtils alpVideoCameraBundle] pathForResource:[NSString stringWithFormat:@"music/%ld",effect.eid] ofType:@"mp3"];
        effect.iconPath = [[AlpVideoCameraUtils alpVideoCameraBundle] pathForResource:[NSString  stringWithFormat:@"music/%ld",effect.eid] ofType:@"jpeg"];
        NSParameterAssert(effect.audioPath || effect.iconPath);
        effect.type = [item[@"type"] integerValue];
        effect.duration = [item[@"duration"] doubleValue];
        effect.lid = [item[@"lid"] integerValue];
        effect.uid = [item[@"uid"] integerValue];
        effect.total = [item[@"total"] integerValue];
        [array addObject:effect];
    }
    
    return array;
}
- (NSArray<AlpStickersData *>*)creatStickersData {
    NSString *configPath = [[AlpVideoCameraUtils alpVideoCameraBundle] pathForResource:@"stickers_icon/stickers" ofType:@"json"];
    NSData *configData = [NSData dataWithContentsOfFile:configPath];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:configData options:NSJSONReadingAllowFragments error:nil];
    NSArray *items = dic[@"stickers"];
    int i = 529 ;
    NSMutableArray *array = [NSMutableArray array];
    
    for (NSDictionary *item in items) {
        //        NSString *path = [baseDir stringByAppendingPathComponent:item[@"resourceUrl"]];iimag
        AlpStickersData* stickersItem = [[AlpStickersData alloc] init];
        stickersItem.name = item[@"name"];
        stickersItem.stickersImgPath = [[AlpVideoCameraUtils alpVideoCameraBundle] pathForResource:[NSString stringWithFormat:@"stickers_icon/stickers%d",i] ofType:@"jpg"];
        [array addObject:stickersItem];
        i++;
    }
    
    return array;
}

-(NSArray<AlpFilterData *>*)creatFilterData {
    AlpFilterData* filter1 = [self createWithName:@"Empty" andFlieName:@"LFGPUImageEmptyFilter" andValue:nil];
    filter1.isSelected = YES;
    AlpFilterData* filter2 = [self createWithName:@"Amatorka" andFlieName:@"GPUImageAmatorkaFilter" andValue:nil];
    AlpFilterData* filter3 = [self createWithName:@"MissEtikate" andFlieName:@"GPUImageMissEtikateFilter" andValue:nil];
    AlpFilterData* filter4 = [self createWithName:@"Sepia" andFlieName:@"GPUImageSepiaFilter" andValue:nil];
    AlpFilterData* filter5 = [self createWithName:@"Sketch" andFlieName:@"GPUImageSketchFilter" andValue:nil];
    AlpFilterData* filter6 = [self createWithName:@"SoftElegance" andFlieName:@"GPUImageSoftEleganceFilter" andValue:nil];
    AlpFilterData* filter7 = [self createWithName:@"Toon" andFlieName:@"GPUImageToonFilter" andValue:nil];
    
    AlpFilterData* filter8 = [[AlpFilterData alloc] init];
    filter8.name = @"Saturation0";
    filter8.iconPath = [[AlpVideoCameraUtils alpVideoCameraBundle] pathForResource:@"GPUImageSaturationFilter0" ofType:@"png"];
    filter8.fillterName = @"GPUImageSaturationFilter";
    filter8.value = @"0";
    
    AlpFilterData* filter9 = [[AlpFilterData alloc] init];
    filter9.name = @"Saturation2";
    filter9.iconPath = [[AlpVideoCameraUtils alpVideoCameraBundle] pathForResource:@"GPUImageSaturationFilter2" ofType:@"png"];
    filter9.fillterName = @"GPUImageSaturationFilter";
    filter9.value = @"2";
    
    return [NSArray arrayWithObjects:filter1,filter2,filter3,filter4,filter5,filter6,filter7,filter8,filter9, nil];
    
}

- (AlpFilterData *)createWithName:(NSString* )name andFlieName:(NSString*)fileName andValue:(NSString*)value
{
    AlpFilterData* filter1 = [[AlpFilterData alloc] init];
    filter1.name = name;
    filter1.iconPath =  [[AlpVideoCameraUtils alpVideoCameraBundle] pathForResource:fileName ofType:@"png"];
    filter1.fillterName = fileName;
    if (value) {
        filter1.value = value;
    }
    return filter1;
}

@end

@implementation AlpMusicData

@end

@implementation AlpFilterData

@end

@implementation AlpStickersData

@end

@implementation AlpResourceData

@end
