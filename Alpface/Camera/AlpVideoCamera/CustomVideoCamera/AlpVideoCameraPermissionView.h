//
//  AlpVideoCameraPermissionView.h
//  Alpface
//
//  Created by swae on 2018/9/19.
//  Copyright © 2018 alpface. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AlpVideoCameraPermissionView : UIView

- (void)updateHidden;

@property (nonatomic, strong) void (^ requestCameraAccessBlock)(BOOL granted);
@property (nonatomic, strong) void (^ requestAudioAccessBlock)(BOOL granted);

@end

NS_ASSUME_NONNULL_END
