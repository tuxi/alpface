//
//  AlpVideoCameraButton.m
//  Alpface
//
//  Created by swae on 2018/10/5.
//  Copyright © 2018 alpface. All rights reserved.
//

#import "AlpVideoCameraButton.h"

@implementation AlpVideoCameraButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        self.titleLabel.font = [UIFont systemFontOfSize:11.0];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    return self;
}

// imageRectForContentRect:和titleRectForContentRect:不能互相调用imageView和titleLael,不然会死循环
- (CGRect)imageRectForContentRect:(CGRect)bounds {
    CGRect imageRect = [super imageRectForContentRect:bounds];
    CGFloat x = (bounds.size.width - imageRect.size.width) * 0.5;
    return CGRectMake(x, 0.0, imageRect.size.width, imageRect.size.height);
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect {
    CGRect titleRect = [super titleRectForContentRect:contentRect];
    CGFloat x = (self.bounds.size.width - contentRect.size.width) * 0.5;
    return CGRectMake(x, self.imageView.bounds.size.height, contentRect.size.width, titleRect.size.height);
    
}


@end
