//
//  AlpEditVideoNavigationBar.h
//  Alpface
//
//  Created by xiaoyuan on 2018/9/18.
//  Copyright © 2018 alpface. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class AlpEditVideoNavigationBar;
@protocol AlpEditVideoNavigationBarDelegate <NSObject>

@optional
- (void)editVideoNavigationBar:(AlpEditVideoNavigationBar *)bar didClickNextButton:(UIButton *)nextButton;
- (void)editVideoNavigationBar:(AlpEditVideoNavigationBar *)bar didClickBackButton:(UIButton *)backButton;

@end

@interface AlpEditVideoNavigationBar : UIView

@property (nonatomic, weak) id<AlpEditVideoNavigationBarDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
