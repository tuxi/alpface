//
//  AlpEditPublishViewController.h
//  Alpface
//
//  Created by swae on 2018/9/18.
//  Copyright © 2018 alpface. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AlpEditPublishViewController : UIViewController

@property (nonatomic, strong) NSURL *videoURL;
@property (nonatomic, assign) CGFloat startSecondsOfCover;
@property (nonatomic, assign) CGFloat endSecondsOfCover;

@end

NS_ASSUME_NONNULL_END
