//
//  AlpVideoCameraUtils.h
//  AlpVideoCamera
//
//  Created by swae on 2018/9/16.
//  Copyright © 2018 xiaoyuan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AlpVideoCameraCover: NSObject

@property (nonatomic, strong) UIImage *firstFrameImage;
@property (nonatomic, assign) CMTime coverTime;
@property (nonatomic, copy) NSURL *videoURL;

@end

@interface AlpVideoCameraUtils : NSObject

/// 合并并导出视频
/// @param videosPathArray 需要合并的一组视频路径
/// @param outpath 合并完成后视频输出路径
/// @param watermarkImage 视频添加水印的图，没有则不添加，水印最好还是后台添加
/// @param completion 完成后的回调
+ (void)mergeVideos:(NSArray *)videosPathArray
                 exportPath:(NSString *)outpath
       watermarkImg:(UIImage * _Nullable )watermarkImage
                  completion:(nonnull void (^)(NSURL *outLocalURL))completion;

/// 在videoFolder文件中生成需要导入视频的路径字符串
+ (NSString *)getVideoMergeFilePathString;

/// 将UI的坐标转换成相机坐标
+ (CGPoint)convertToPointOfInterestFromViewCoordinates:(CGPoint)viewCoordinates frameSize:(CGSize)frameSize;

+ (void)createVideoFolderIfNotExist;

// mov视频转换成mp4格式
+ (void)convertMovTypeIntoMp4TypeWithSourceUrl:(NSURL *)sourceUrl convertSuccess:(void (^)(NSURL *path))convertSuccess;
// 获取视频的大小和时间
+ (NSDictionary *)getLocalVideoSizeAndTimeWithSourcePath:(NSString *)path;

/// 根据视频的路径取出图片存放到数组 图片的数量 = 总帧数/封面展示的帧数
/// @param videoURL 视频的URL
/// @param numberOfCoverFrame 每一个封面展示的帧数
+ (void)getCoversByVideoURL:(NSURL *)videoURL
         numberOfCoverFrame:(NSInteger)numberOfCoverFrame
                   callBack:(void (^)(CMTime  time, NSArray<AlpVideoCameraCover *> *images, NSError *error))callBack;

/// 根据视频的路径取出图片存放到数组 图片的数量 = 总帧数/封面展示的帧数
/// @param videoURL 视频的URL
/// @param coverSeconds 每一个封面截取视频的秒数
+ (void)getCoversByVideoURL:(NSURL *)videoURL
               coverSeconds:(NSInteger)coverSeconds
                   callBack:(void (^)(CMTime  time, NSArray<AlpVideoCameraCover *> *images, NSError *error))callBack;

/// 根据视频的路径取出图片存放到数组 图片的数量 = 总帧数/封面展示的帧数
/// @param videoURL 视频的URL
/// @param photoCount 获取图片的数量
+ (void)getCoversByVideoURL:(NSURL *)videoURL
               photoCount:(NSInteger)photoCount
                   callBack:(void (^)(CMTime  time, NSArray<AlpVideoCameraCover *> *images, NSError *error))callBack;

/// 根据视频的路径取出图片存放到数组 图片的数量 = 总帧数/封面展示的帧数
//+ (void)getImagesByCover:(AlpVideoCameraCover *)cover callBack:(void (^)(NSArray<UIImage *> *images))callBack;

/// 根据timeValue帧s获取视频的封面
+ (void)getCoverByVideoURL:(NSURL *)videoURL
                 timeValue:(CMTimeValue)value
                  callBack:(void (^)(AlpVideoCameraCover *image))callBack;

/// 获取系统相册最后一个视频缩略图
+ (void)getLatestAssetFromAlbum:(void (^)(UIImage *image))callBack;
@end

NS_ASSUME_NONNULL_END
