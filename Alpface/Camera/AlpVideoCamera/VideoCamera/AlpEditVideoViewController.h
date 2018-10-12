//
//  AlpEditVideoViewController.h
//  AlpVideoCamera
//
//  Created by xiaoyuan on 2018/9/13.
//  Copyright © 2018 xiaoyuan. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class AlpEditVideoParameter;

@interface AlpEditVideoViewController : UIViewController

@property (nonatomic, strong) NSURL *videoURL;

@property (nonatomic, strong) AlpEditVideoParameter *videoOptions;

@end

NS_ASSUME_NONNULL_END
