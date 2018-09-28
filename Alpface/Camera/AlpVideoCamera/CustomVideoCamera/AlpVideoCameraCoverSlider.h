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
    CGFloat location;
    CGFloat length;
} AlpVideoCameraCoverSliderRange;

NS_INLINE AlpVideoCameraCoverSliderRange AlpVideoCameraCoverSliderMakeRange(CGFloat loc,
                                                                            CGFloat len) {
    AlpVideoCameraCoverSliderRange r;
    r.location = loc;
    r.length = len;
    return r;
}

NS_INLINE CGFloat AlpVideoCameraCoverSliderMaxRange(AlpVideoCameraCoverSliderRange range) {
    return (range.location + range.length);
}

IB_DESIGNABLE
@interface AlpVideoCameraCoverSlider : UIControl

@property (nonatomic) IBInspectable CGFloat maximumValue;
@property (nonatomic) IBInspectable UIImage *thumbImage;
@property (nonatomic) IBInspectable AlpVideoCameraCoverSliderRange range;

@end


NS_ASSUME_NONNULL_END
