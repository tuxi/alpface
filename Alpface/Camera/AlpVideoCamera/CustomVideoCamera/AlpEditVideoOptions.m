//
//  AlpEditVideoOptions.m
//  Alpface
//
//  Created by xiaoyuan on 2018/9/18.
//  Copyright © 2018 alpface. All rights reserved.
//

#import "AlpEditVideoOptions.h"

@implementation AlpEditVideoOptions

- (instancetype)initWithBitRate:(long long)bitRate frameRate:(long long)frameRate {
    if (self = [super init]) {
        self.bitRate = bitRate;
        self.frameRate = frameRate;
    }
    return self;
}

@end
