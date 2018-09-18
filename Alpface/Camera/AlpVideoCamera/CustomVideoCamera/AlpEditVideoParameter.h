//
//  AlpEditVideoParameter.h
//  Alpface
//
//  Created by xiaoyuan on 2018/9/18.
//  Copyright © 2018 alpface. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AlpEditVideoParameter : NSObject

/// 比特率
@property (nonatomic , assign) long long bitRate;
/// 帧率
@property (nonatomic , assign) long long frameRate;

- (instancetype)initWithBitRate:(long long)bitRate frameRate:(long long)frameRate;

@end

NS_ASSUME_NONNULL_END
