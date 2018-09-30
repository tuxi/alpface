//
//  XYCutVideoController.h
//  XYVideoCut
//
//  Created by xiaoyuan on 16/11/14.
//  Copyright © 2016年 alpface. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AlpEditVideoParameter;

@interface XYCutVideoController : UIViewController

@property (nonatomic, copy) NSURL *videoURL;
@property (nonatomic, strong) AlpEditVideoParameter *videoOptions;

@end
