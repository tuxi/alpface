//
//  AlpEditVideoBottomView.h
//  Alpface
//
//  Created by swae on 2018/10/5.
//  Copyright © 2018 alpface. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AlpEditVideoBottomView : UIView


// 特效
@property (nonatomic, strong, readonly) UIButton *specialEffectsButton;
// 选封面
@property (nonatomic, strong, readonly) UIButton *chooseCoverButton;
// 滤镜
@property (nonatomic, strong, readonly) UIButton *filterButton;

// 下一步
@property (nonatomic, strong, readonly) UIButton *nextButton;

@end

NS_ASSUME_NONNULL_END
