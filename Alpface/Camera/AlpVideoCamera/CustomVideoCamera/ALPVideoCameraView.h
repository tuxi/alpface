//
//  ALPVideoCameraView.h
//  AlpVideoCamera
//
//  Created by swae on 2018/9/12.
//  Copyright © 2018 xiaoyuan. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^clickBackToHomeBtnBlock)(void);

@class ALPVideoCameraView;

@protocol ALPVideoCameraViewDelegate <NSObject>

- (void)videoCamerView:(ALPVideoCameraView *)view presentViewCotroller:(UIViewController *)viewController;
- (void)videoCamerView:(ALPVideoCameraView *)view pushViewCotroller:(UIViewController *)viewController;

@end

@interface ALPVideoCameraView : UIView

@property (nonatomic , copy) clickBackToHomeBtnBlock backToHomeBlock;

@property (nonatomic , strong) NSNumber* width;
@property (nonatomic , strong) NSNumber* hight;
@property (nonatomic , strong) NSNumber* bit;
@property (nonatomic , strong) NSNumber* frameRate;
@property (nonatomic, weak) id<ALPVideoCameraViewDelegate> delegate;


@end

NS_ASSUME_NONNULL_END
