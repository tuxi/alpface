//
//  AlpEditPublishTableViewCellModel.h
//  Alpface
//
//  Created by swae on 2018/9/24.
//  Copyright © 2018 alpface. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AlpEditPublishTableViewCellModel : NSObject

@property (nonatomic) Class cellClass;
@property (nonatomic, assign) double cellHeight;
@property (nonatomic, strong) id model;
@property (nonatomic, assign) BOOL cellShouldHighlight;

@end

NS_ASSUME_NONNULL_END
