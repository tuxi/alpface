//
//  AlpVideoCameraUtils.m
//  AlpVideoCamera
//
//  Created by swae on 2018/9/16.
//  Copyright © 2018 xiaoyuan. All rights reserved.
//

#import "AlpVideoCameraUtils.h"
#import <AVFoundation/AVFoundation.h>
#import "AlpVideoCameraDefine.h"

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
    
    //创建视频水印layer 并添加到视频layer上
    //2017 年 04 月 19 日 视频水印由后台统一转码添加   del by hyy；
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
//    __weak typeof(self) weakSelf = self;
//    __weak typeof(_videoCamera) weakVideoCamera = _videoCamera;
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            NSURL *outURL = [NSURL fileURLWithPath:outpath];
            if (completion) {
                completion(outURL);
            }
//            [weakVideoCamera stopCameraCapture];
//
//            AlpEditVideoViewController* vc = [[AlpEditVideoViewController alloc]init];
//            vc.width = weakSelf.width;
//            vc.hight = weakSelf.hight;
//            vc.bit = weakSelf.bit;
//            vc.frameRate = weakSelf.frameRate;
//            vc.videoURL = [NSURL fileURLWithPath:outpath];;
//            [[NSNotificationCenter defaultCenter] removeObserver:weakSelf];
//            //            [[AppDelegate sharedAppDelegate] pushViewController:view animated:YES];
//            if (weakSelf.delegate&&[weakSelf.delegate respondsToSelector:@selector(videoCamerView:pushViewCotroller:)]) {
//                [weakSelf.delegate videoCamerView:weakSelf pushViewCotroller:vc];
//            }
//            [weakSelf removeFromSuperview];
        });
        
        
    }];
    
    
    ////    UIImage* waterImg = [UIImage imageNamed:@"LDWatermark"];
    //    CMTime totalDuration = kCMTimeZero;
    //    for (int i = 0; i < videosPathArray.count; i++) {
    ////        AVURLAsset *asset = [AVURLAsset assetWithURL:[NSURL URLWithString:videosPathArray[i]]];
    //        NSDictionary* options = @{AVURLAssetPreferPreciseDurationAndTimingKey:@YES};
    //        AVAsset* asset = [AVURLAsset URLAssetWithURL:videosPathArray[i] options:options];
    //
    //        NSError *erroraudio = nil;
    //        //获取AVAsset中的音频 或者视频
    //        AVAssetTrack *assetAudioTrack = [[asset tracksWithMediaType:AVMediaTypeAudio] firstObject];
    //        //向通道内加入音频或者视频
    //        BOOL ba = [audioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration)
    //                                      ofTrack:assetAudioTrack
    //                                       atTime:totalDuration
    //                                        error:&erroraudio];
    //
    //        NSLog(@"erroraudio:%@%d",erroraudio,ba);
    //        NSError *errorVideo = nil;
    //        AVAssetTrack *assetVideoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo]firstObject];
    //        BOOL bl = [videoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration)
    //                                      ofTrack:assetVideoTrack
    //                                       atTime:totalDuration
    //                                        error:&errorVideo];
    //
    //        NSLog(@"errorVideo:%@%d",errorVideo,bl);
    //        totalDuration = CMTimeAdd(totalDuration, asset.duration);
    //    }
    //    NSLog(@"%@",NSHomeDirectory());
    //
    //    //创建视频水印layer 并添加到视频layer上
    //    //2017 年 04 月 19 日 视频水印由后台统一转码添加   del by hyy；
    ////    CGSize videoSize = [videoTrack naturalSize];
    ////    CALayer* aLayer = [CALayer layer];
    ////    aLayer.contents = (id)waterImg.CGImage;
    ////    aLayer.frame = CGRectMake(videoSize.width - waterImg.size.width - 30, videoSize.height - waterImg.size.height*3, waterImg.size.width, waterImg.size.height);
    ////    aLayer.opacity = 0.9;
    ////
    ////    CALayer *parentLayer = [CALayer layer];
    ////    CALayer *videoLayer = [CALayer layer];
    ////    parentLayer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
    ////    videoLayer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
    ////    [parentLayer addSublayer:videoLayer];
    ////    [parentLayer addSublayer:aLayer];
    ////    AVMutableVideoComposition* videoComp = [AVMutableVideoComposition videoComposition];
    ////    videoComp.renderSize = videoSize;
    ////
    ////
    ////    videoComp.frameDuration = CMTimeMake(1, 30);
    ////    videoComp.animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
    ////    AVMutableVideoCompositionInstruction* instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    ////
    ////    instruction.timeRange = CMTimeRangeMake(kCMTimeZero, [mixComposition duration]);
    ////    AVAssetTrack* mixVideoTrack = [[mixComposition tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    ////    AVMutableVideoCompositionLayerInstruction* layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:mixVideoTrack];
    ////    instruction.layerInstructions = [NSArray arrayWithObject:layerInstruction];
    ////    videoComp.instructions = [NSArray arrayWithObject: instruction];
    //
    //
    //    NSURL *mergeFileURL = [NSURL fileURLWithPath:outpath];
    //
    //    //视频导出工具
    //    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:mixComposition
    //                                                                      presetName:AVAssetExportPreset1280x720];
    ////    exporter.videoComposition = videoComp;
    //    /*
    //    exporter.progress
    //     导出进度
    //     This property is not key-value observable.
    //     不支持kvo 监听
    //     只能用定时器监听了  NStimer
    //     */
    //    exporter.outputURL = mergeFileURL;
    //    exporter.outputFileType = AVFileTypeQuickTimeMovie;
    //    exporter.shouldOptimizeForNetworkUse = YES;
    //    [exporter exportAsynchronouslyWithCompletionHandler:^{
    //        dispatch_async(dispatch_get_main_queue(), ^{
    //
    //            [videoCamera stopCameraCapture];
    //
    //            EditVideoViewController* view = [[EditVideoViewController alloc]init];
    //            view.width = _width;
    //            view.hight = _hight;
    //            view.bit = _bit;
    //            view.frameRate = _frameRate;
    //            view.videoURL = [NSURL fileURLWithPath:outpath];;
    //            [[NSNotificationCenter defaultCenter] removeObserver:self];
    //            [[AppDelegate sharedAppDelegate] pushViewController:view animated:YES];
    //            [self removeFromSuperview];
    //        });
    //
    //
    //        }];
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

@end
