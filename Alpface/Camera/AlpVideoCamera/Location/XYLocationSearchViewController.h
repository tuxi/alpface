//
//  XYLocationSearchViewController.h
//  WeChatExtensions
//
//  Created by Swae on 2017/10/28.
//  Copyright © 2017年 alpface. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XYLocationSearchTableViewModel.h"

typedef enum : NSUInteger {
    XYLocationStaticCellTypeCurrent,
    XYLocationStaticCellTypeUserInput,
} XYLocationStaticCellType;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
@protocol XYLocationSearchViewControllerDelegate <NSObject>

@optional
- (void)locationSearchViewController:(UIViewController *)sender didSelectLocationWithName:(NSString *)name address:(NSString *)address mapItem:(MKMapItem *)mapItm;

@end

/**
 *  动态位置cell。包含地方名字和地址信息。
 */
@interface XYLocationCell : UITableViewCell

- (void)updateCellWithTitle:(NSString *)title address:(NSString *)address;

@end


/**
 *  静态Cell。
 *  输入位置的Cell，当前位置Cell
 */
@interface XYLocationStaticCell : UITableViewCell

@property (assign, nonatomic) XYLocationStaticCellType type;

- (void)setTitle:(NSString *)title;

@end

@interface XYLocationSearchViewController : UIViewController
#if ! __has_feature(objc_arc)
@property (nonatomic, assign) id<XYLocationSearchViewControllerDelegate> delegate;
#else
@property (nonatomic, weak) id<XYLocationSearchViewControllerDelegate> delegate;
#endif

@end
