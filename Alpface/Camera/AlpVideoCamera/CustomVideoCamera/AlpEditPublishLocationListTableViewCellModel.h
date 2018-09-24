//
//  AlpEditPublishLocationListTableViewCellModel.h
//  Alpface
//
//  Created by swae on 2018/9/24.
//  Copyright © 2018 alpface. All rights reserved.
//

#import "AlpEditPublishTableViewCellModel.h"

NS_ASSUME_NONNULL_BEGIN

@class MKMapItem;

@interface AlpEditPublishLocationModel : NSObject

@property (nonatomic, strong) MKMapItem *item;
@property (nonatomic, getter=isSelected) BOOL selected;
@property (nonatomic, copy) void (^ clickLocationButtonBlock)(AlpEditPublishLocationModel *model);
@end

@interface AlpEditPublishLocationListTableViewCellModel : AlpEditPublishTableViewCellModel

@property (nonatomic, copy) void (^ selectMapItemBlock)(AlpEditPublishLocationModel *item);

@end

NS_ASSUME_NONNULL_END
