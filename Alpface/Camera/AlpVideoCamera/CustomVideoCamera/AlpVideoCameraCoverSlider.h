//
//  AlpVideoCameraCoverSlider.h
//  AlpVideoCameraCoverSlider
//
//  Created by xiaoyuan on 2018/9/28.
//  Copyright © 2018 xiaoyuan. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef struct _AlpVideoCameraCoverSliderRange {
    NSInteger location;
    NSInteger length;
} AlpVideoCameraCoverSliderRange;

NS_INLINE AlpVideoCameraCoverSliderRange AlpVideoCameraCoverSliderMakeRange(NSInteger loc,
                                                                            NSInteger len) {
    AlpVideoCameraCoverSliderRange r;
    r.location = loc;
    r.length = len;
    return r;
}

NS_INLINE NSInteger AlpVideoCameraCoverSliderMaxRange(AlpVideoCameraCoverSliderRange range) {
    return (range.location + range.length);
}

IB_DESIGNABLE
@interface AlpVideoCameraCoverSlider : UIControl

@property (nonatomic) IBInspectable NSInteger maximumValue;
@property (nonatomic) IBInspectable UIImage *thumbImage;
@property (nonatomic) IBInspectable AlpVideoCameraCoverSliderRange range;
@property (nonatomic, readonly) UIView *rangeThumbView;

@end


NS_ASSUME_NONNULL_END
