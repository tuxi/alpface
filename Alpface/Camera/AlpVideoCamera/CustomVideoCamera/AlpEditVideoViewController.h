//
//  AlpEditVideoViewController.h
//  AlpVideoCamera
//
//  Created by xiaoyuan on 2018/9/13.
//  Copyright © 2018 xiaoyuan. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AlpEditVideoViewController : UIViewController

@property (nonatomic, strong) NSURL * videoURL;

@property (nonatomic , strong) NSNumber *width;
@property (nonatomic , strong) NSNumber *hight;
@property (nonatomic , strong) NSNumber *bit;
@property (nonatomic , strong) NSNumber *frameRate;

@end

NS_ASSUME_NONNULL_END
