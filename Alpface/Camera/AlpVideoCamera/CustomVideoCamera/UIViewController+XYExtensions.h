//
//  UIViewController+XYExtensions.h
//  FileBrowser
//
//  Created by xiaoyuan on 05/08/2014.
//  Copyright © 2014 xiaoyuan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (XYExtensions)

+ (UIViewController *)xy_topViewController;
+ (UINavigationController *)xy_currentNavigationController;
+ (UITabBarController *)xy_tabBarController;

+ (UIViewController *)xy_getCurrentUIVC;
@end
