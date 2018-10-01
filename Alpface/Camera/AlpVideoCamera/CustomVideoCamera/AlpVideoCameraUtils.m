//
//  AlpVideoCameraUtils.m
//  AlpVideoCamera
//
//  Created by swae on 2018/9/16.
//  Copyright © 2018 xiaoyuan. All rights reserved.
//

#import "AlpVideoCameraUtils.h"
#import "AlpVideoCameraDefine.h"
#import <Photos/Photos.h>
//#import <YYImage/YYImageCoder.h>

@implementation AlpVideoCameraUtils

+ (void)mergeVideos:(NSArray *)videosPathArray
         exportPath:(NSString *)outpath
       watermarkImg:(UIImage *)watermarkImage
         completion:(nonnull void (^)(NSURL * _Nonnull))completion {
    if (videosPathArray.count == 0) {
        return;
    }
    //音频视频合成体
    AVMutableComposition *mixComposition = [[AVMutableComposition alloc] init];
    
    //创建音频通道容器
    AVMutableCompositionTrack *audioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio
                                                                        preferredTrackID:kCMPersistentTrackID_Invalid];
    //创建视频通道容器
    AVMutableCompositionTrack *videoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo
                                                                        preferredTrackID:kCMPersistentTrackID_Invalid];
    
    
    // 水印
    UIImage* waterImg = watermarkImage;
    CMTime totalDuration = kCMTimeZero;
    for (int i = 0; i < videosPathArray.count; i++) {
        //        AVURLAsset *asset = [AVURLAsset assetWithURL:[NSURL URLWithString:videosPathArray[i]]];
        NSDictionary* options = @{AVURLAssetPreferPreciseDurationAndTimingKey:@YES};
        AVAsset* asset = [AVURLAsset URLAssetWithURL:videosPathArray[i] options:options];
        
        NSError *erroraudio = nil;
        //获取AVAsset中的音频 或者视频
        AVAssetTrack *assetAudioTrack = [[asset tracksWithMediaType:AVMediaTypeAudio] firstObject];
        //向通道内加入音频或者视频
        BOOL ba = [audioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration)
                                      ofTrack:assetAudioTrack
                                       atTime:totalDuration
                                        error:&erroraudio];
        
        NSLog(@"erroraudio:%@%d",erroraudio,ba);
        NSError *errorVideo = nil;
        AVAssetTrack *assetVideoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo]firstObject];
        BOOL bl = [videoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration)
                                      ofTrack:assetVideoTrack
                                       atTime:totalDuration
                                        error:&errorVideo];
        
        NSLog(@"errorVideo:%@%d",errorVideo,bl);
        totalDuration = CMTimeAdd(totalDuration, asset.duration);
    }
    NSLog(@"%@",NSHomeDirectory());
    
    // 创建视频水印layer 并添加到视频layer上
    CGSize videoSize = [videoTrack naturalSize];
    
    CALayer *parentLayer = [CALayer layer];
    CALayer *videoLayer = [CALayer layer];
    parentLayer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
    videoLayer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
    [parentLayer addSublayer:videoLayer];
    
    // 添加水印
    if (waterImg) {
        CALayer* watermarkLayer = [CALayer layer];
        watermarkLayer.contents = (id)waterImg.CGImage;
        watermarkLayer.frame = CGRectMake(videoSize.width - waterImg.size.width - 30, videoSize.height - waterImg.size.height*3, waterImg.size.width, waterImg.size.height);
        watermarkLayer.opacity = 0.9;
        [parentLayer addSublayer:watermarkLayer];
    }
    AVMutableVideoComposition* videoComp = [AVMutableVideoComposition videoComposition];
    videoComp.renderSize = videoSize;
    
    
    videoComp.frameDuration = CMTimeMake(1, 30);
    videoComp.animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
    AVMutableVideoCompositionInstruction* instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    
    instruction.timeRange = CMTimeRangeMake(kCMTimeZero, [mixComposition duration]);
    AVAssetTrack* mixVideoTrack = [[mixComposition tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    AVMutableVideoCompositionLayerInstruction* layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:mixVideoTrack];
    instruction.layerInstructions = [NSArray arrayWithObject:layerInstruction];
    videoComp.instructions = [NSArray arrayWithObject: instruction];
    
    
    NSURL *mergeFileURL = [NSURL fileURLWithPath:outpath];
    
    //视频导出工具
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:mixComposition
                                                                      presetName:AVAssetExportPreset1280x720];
    exporter.videoComposition = videoComp;
    /*
     exporter.progress
     导出进度
     This property is not key-value observable.
     不支持kvo 监听
     只能用定时器监听了  NStimer
     */
    exporter.outputURL = mergeFileURL;
    exporter.outputFileType = AVFileTypeQuickTimeMovie;
    exporter.shouldOptimizeForNetworkUse = YES;
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            NSURL *outURL = [NSURL fileURLWithPath:outpath];
            if (completion) {
                completion(outURL);
            }
        });
        
        
    }];
    
}


+ (NSString *)getVideoMergeFilePathString {
    //    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    //    NSString *path = [paths objectAtIndex:0];
    
    //沙盒中Temp路径
    NSString *tempPath = NSTemporaryDirectory();
    
    NSString* path = [tempPath stringByAppendingPathComponent:VIDEO_FOLDER];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMddHHmmss";
    NSString *nowTimeStr = [formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0]];
    
    NSString *fileName = [[path stringByAppendingPathComponent:nowTimeStr] stringByAppendingString:@"merge.mov"];
    
    return fileName;
}


+ (CGPoint)convertToPointOfInterestFromViewCoordinates:(CGPoint)viewCoordinates frameSize:(CGSize)frameSize {
    CGPoint pointOfInterest = CGPointMake(.5f, .5f);
    CGSize apertureSize = CGSizeMake(1280, 720);//设备采集分辨率
    CGPoint point = viewCoordinates;
    CGFloat apertureRatio = apertureSize.height / apertureSize.width;
    CGFloat viewRatio = frameSize.width / frameSize.height;
    CGFloat xc = .5f;
    CGFloat yc = .5f;
    
    if (viewRatio > apertureRatio) {
        CGFloat y2 = frameSize.height;
        CGFloat x2 = frameSize.height * apertureRatio;
        CGFloat x1 = frameSize.width;
        CGFloat blackBar = (x1 - x2) / 2;
        if (point.x >= blackBar && point.x <= blackBar + x2) {
            xc = point.y / y2;
            yc = 1.f - ((point.x - blackBar) / x2);
        }
    }else {
        CGFloat y2 = frameSize.width / apertureRatio;
        CGFloat y1 = frameSize.height;
        CGFloat x2 = frameSize.width;
        CGFloat blackBar = (y1 - y2) / 2;
        if (point.y >= blackBar && point.y <= blackBar + y2) {
            xc = ((point.y - blackBar) / y2);
            yc = 1.f - (point.x / x2);
        }
    }
    pointOfInterest = CGPointMake(xc, yc);
    return pointOfInterest;
}

+ (void)createVideoFolderIfNotExist {
    //    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    //    NSString *path = [paths objectAtIndex:0];
    
    //沙盒中Temp路径
    NSString *tempPath = NSTemporaryDirectory();
    NSString *folderPath = [tempPath stringByAppendingPathComponent:VIDEO_FOLDER];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = NO;
    BOOL isDirExist = [fileManager fileExistsAtPath:folderPath isDirectory:&isDir];
    
    if(!(isDirExist && isDir))
    {
        BOOL bCreateDir = [fileManager createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:nil];
        if(!bCreateDir){
            NSLog(@"创建保存视频文件夹失败");
        }
    }
}

+ (void)convertMovTypeIntoMp4TypeWithSourceUrl:(NSURL *)sourceUrl convertSuccess:(void (^)(NSURL *path))convertSuccess {
    
    [self createVideoFolderIfNotExist];
    
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:sourceUrl options:nil];
    
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];
    
    //    BWJLog(@"%@",compatiblePresets);
    
    if ([compatiblePresets containsObject:AVAssetExportPresetHighestQuality]) {
        
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:avAsset presetName:AVAssetExportPresetHighestQuality];
        
        
        NSString * resultPath = [self getVideoMergeFilePathString];
        
        NSLog(@"resultPath = %@",resultPath);
        
        
        exportSession.outputURL = [NSURL fileURLWithPath:resultPath];
        
        exportSession.outputFileType = AVFileTypeMPEG4;
        
        exportSession.shouldOptimizeForNetworkUse = YES;
        
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                if (exportSession.status == AVAssetExportSessionStatusCompleted) {
                    if (convertSuccess) {
                        convertSuccess([NSURL fileURLWithPath:resultPath]);
                    }
                } else {
                    
                    
                }
            });
            
        }];
    }
}

+ (NSDictionary *)getLocalVideoSizeAndTimeWithSourcePath:(NSString *)path{
    AVURLAsset * asset = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:path]];
    CMTime   time = [asset duration];
    int seconds = ceil(time.value/time.timescale);
    
    NSInteger fileSize = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil].fileSize;
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"size"] = @(fileSize);
    dic[@"duration"] = @(seconds);
    return dic;
}

+ (void)getCoversByVideoURL:(NSURL *)videoURL
               coverSeconds:(NSInteger)coverSeconds
                   callBack:(void (^)(CMTime, NSArray<AlpVideoCameraCover *> * _Nonnull, NSError * _Nonnull))callBack {
    
    AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:videoURL options:nil];
    CMTime time = [urlAsset duration];
    CMTimeValue coverFrame = time.timescale * coverSeconds;
    [self getCoversByVideoURL:videoURL numberOfCoverFrame:coverFrame callBack:callBack];
}



+ (void)getCoversByVideoURL:(NSURL *)videoURL
         numberOfCoverFrame:(NSInteger)numberOfCoverFrame
                   callBack:(void (^)(CMTime  time, NSArray<AlpVideoCameraCover *> *images, NSError *error))callBack {
    
    NSDictionary *opts = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:videoURL options:opts];
    CMTime  time = [urlAsset duration];
    
    // 输出视频的时间
    CMTimeShow(time);
    
    if (time.value < 1) {
        NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:404 userInfo:@{@"info": [NSString stringWithFormat:@"[%@]读取的视频总帧数为0", videoURL]}];
        if (callBack) {
            callBack(time, nil, error);
        }
        return;
    }
    
    // 要求：每个封面截取5秒的帧数
    // 一秒的帧数= time.timescale
    // 视频的帧数= time.value
    // 视频的秒数= time.value/time.timescale
    // 一个封面5秒的帧数 = 5 * time.timescale
    
    AVAssetImageGenerator *generator = [AVAssetImageGenerator assetImageGeneratorWithAsset:urlAsset];
    generator.appliesPreferredTrackTransform = YES;
    // 封面的数量 = 总帧数/ 每个封面的帧数
    long long baseCount = time.value / numberOfCoverFrame;
    NSMutableArray *images = [NSMutableArray array] ;
    @autoreleasepool {
        for (NSInteger i = 0 ; i < baseCount; i++) {
            
            NSError *error = nil;
            CMTime coverTime = CMTimeMake(i * numberOfCoverFrame, time.timescale);
            CGImageRef img = [generator copyCGImageAtTime:coverTime actualTime:NULL error:&error];
            {
                if (!error) {
                    UIImage *image = [UIImage imageWithCGImage:img];
                    AlpVideoCameraCover *imageObj = [AlpVideoCameraCover new];
                    imageObj.firstFrameImage = image;
                    imageObj.coverTime = coverTime;
                    imageObj.videoURL = videoURL;
                    [images addObject:imageObj];
                }
                else {
                    NSLog(@"%@", error.localizedDescription);
                }
            }
            CGImageRelease(img);
        }
    }
    
    if (callBack) {
        callBack(time, images, nil);
    }
}

+ (void)getCoversByVideoURL:(NSURL *)videoURL
                 photoCount:(NSInteger)photoCount
                   callBack:(void (^)(CMTime  time, NSArray<AlpVideoCameraCover *> *images, NSError *error))callBack {
    NSDictionary *opts = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:videoURL options:opts];
    CMTime  time = [urlAsset duration];
    
    // 输出视频的时间
    CMTimeShow(time);
    
    if (time.value < 1) {
        NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:404 userInfo:@{@"info": [NSString stringWithFormat:@"[%@]读取的视频总帧数为0", videoURL]}];
        if (callBack) {
            callBack(time, nil, error);
        }
        return;
    }
    
    // 要求：每个封面截取5秒的帧数
    // 一秒的帧数= time.timescale
    // 视频的帧数= time.value
    // 视频的秒数= time.value/time.timescale
    // 一个封面5秒的帧数 = 5 * time.timescale
    
    AVAssetImageGenerator *generator = [AVAssetImageGenerator assetImageGeneratorWithAsset:urlAsset];
    generator.appliesPreferredTrackTransform = YES;
    // 每个封面的帧数 = 总帧数/ 图片的数量
    long long coverFrameCount = time.value / photoCount;
    NSMutableArray *images = [NSMutableArray array] ;
    @autoreleasepool {
        for (NSInteger i = 0 ; i < photoCount; i++) {
            
            NSError *error = nil;
            CMTime coverTime = CMTimeMake(i * coverFrameCount, time.timescale);
            CGImageRef img = [generator copyCGImageAtTime:coverTime actualTime:NULL error:&error];
            {
                if (!error) {
                    UIImage *image = [UIImage imageWithCGImage:img];
                    AlpVideoCameraCover *imageObj = [AlpVideoCameraCover new];
                    imageObj.firstFrameImage = image;
                    imageObj.coverTime = coverTime;
                    imageObj.videoURL = videoURL;
                    [images addObject:imageObj];
                }
                else {
                    NSLog(@"%@", error.localizedDescription);
                }
            }
            CGImageRelease(img);
        }
    }
    
    if (callBack) {
        callBack(time, images, nil);
    }
}


+ (void)getCoverByVideoURL:(NSURL *)videoURL timeValue:(CMTimeValue)value callBack:(void (^)(AlpVideoCameraCover *image))callBack {
    @autoreleasepool {
        NSDictionary *opts = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
        AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:videoURL options:opts];
        CMTime videoTime = [urlAsset duration];
        AVAssetImageGenerator *generator = [AVAssetImageGenerator assetImageGeneratorWithAsset:urlAsset];
        generator.appliesPreferredTrackTransform = YES;
        NSError *error = nil;
        CMTime coverTime = CMTimeMake(value, videoTime.timescale);
        CGImageRef img = [generator copyCGImageAtTime:coverTime actualTime:NULL error:&error];
        UIImage *image = [UIImage imageWithCGImage:img];
        CGImageRelease(img);
        AlpVideoCameraCover *cover = [AlpVideoCameraCover new];
        cover.firstFrameImage = image;
        cover.coverTime = coverTime;
        cover.videoURL = videoURL;
        if (callBack) {
            callBack(cover);
        }
    }
}

//+ (void)getImagesByCover:(AlpVideoCameraCover *)cover callBack:(void (^)(NSArray<UIImage *> * _Nonnull))callBack {
//    
//}
//
//+ (NSData * )webpDataByVideoPath:(NSURL *)videoUrl {
//    //    NSString * filePath = [self createWebpFilePath];
//    YYImageEncoder *gifEncoder = [[YYImageEncoder alloc] initWithType:YYImageTypeWebP];
//    gifEncoder.loopCount = 0;
//    gifEncoder.quality = 0.8;
//
//    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoUrl options:nil];
//    int64_t value = asset.duration.value;
//    int64_t scale = asset.duration.timescale;
//
//    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
//    generator.appliesPreferredTrackTransform = YES;
//    //下面两个值设为0表示精确取帧，否则系统会有优化取出来的帧时间间隔不对等
//    generator.requestedTimeToleranceAfter = kCMTimeZero;
//    generator.requestedTimeToleranceBefore = kCMTimeZero;
//    @autoreleasepool {
//        for (NSInteger i = 0; i <=4; i++) {
//            CGFloat starttime = i*0.1+0.5;
//            CMTime time = CMTimeMakeWithSeconds(starttime, (int)scale);
//            NSError *error = nil;
//            CMTime actualTime;
//            CGImageRef image = [generator copyCGImageAtTime:time actualTime:&actualTime error:&error];
//            UIImage * img = [UIImage imageWithCGImage:image];
//            //        img = [self resizeToMaxHeight:480 img:img];
//            [gifEncoder addImage:img duration:0.1];
//            CGImageRelease(image);
//        }
//        for (NSInteger i=3; i>=0; i--) {
//            CGFloat starttime = i*0.1+0.5;
//            CMTime time = CMTimeMakeWithSeconds(starttime, (int)scale);
//            NSError *error = nil;
//            CMTime actualTime;
//            CGImageRef image = [generator copyCGImageAtTime:time actualTime:&actualTime error:&error];
//            UIImage * img = [UIImage imageWithCGImage:image];
//            [gifEncoder addImage:img duration:0.1];
//            CGImageRelease(image);
//        }
//
//    }
//
//
//    //    [gifEncoder encodeToFile:filePath];
//    NSData *webpData = [gifEncoder encode];
//    NSLog(@"生成webp成功!");
//    return webpData;
//}


/// 获取系统相册最后一个视频缩略图
+ (void)getLatestAssetFromAlbum:(void (^)(UIImage *image))callBack {
    if (![self isCanUsePhotos]) {
        if (callBack) {
            callBack(nil);
        }
        return;
    }
    // 获取所有资源的集合，并按资源的创建时间排序
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.sortDescriptors = @[[NSSortDescriptor
                                 sortDescriptorWithKey:@"creationDate"
                                 ascending:YES]];
    options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld",
                                         PHAssetMediaTypeVideo];
    
    PHFetchResult *assetsFetchResults = [PHAsset fetchAssetsWithOptions:options];
    // 在资源的集合中获取第一个集合，并获取其中的图片
    // 修复获取图片时出现的瞬间内存过高问题
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
    option.resizeMode = PHImageRequestOptionsResizeModeFast;
    PHCachingImageManager *imageManager = [[PHCachingImageManager alloc] init];
    PHAsset *asset = [assetsFetchResults lastObject];
    if (!asset) {
        if (callBack) {
            callBack(nil);
        }
        return;
    }
    [imageManager requestImageForAsset:asset targetSize:CGSizeMake(100.0, 100.0)
                           contentMode:PHImageContentModeAspectFill options:option resultHandler:^(UIImage *result, NSDictionary *info) {
                               if (callBack) {
                                   callBack(result);
                               }
                           }];
    
    
    
    
    
}
+ (BOOL)isCanUsePhotos {
    
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusRestricted ||
        status == PHAuthorizationStatusDenied) {
        //无权限
        return NO;
    }
    return YES;
}

@end

@implementation AlpVideoCameraCover



@end
