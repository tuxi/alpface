//
//  UIImage+AlpExtensions.h
//  AlpVideoCamera
//
//  Created by swae on 2018/9/16.
//  Copyright © 2018 xiaoyuan. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (AlpExtensions)

/// 根据视频本地路径截取缩略图
+ (UIImage *)getThumbnailByVideoPath:(NSString *)videoPath;
/// 颜色转换图片
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;
@end

NS_ASSUME_NONNULL_END
