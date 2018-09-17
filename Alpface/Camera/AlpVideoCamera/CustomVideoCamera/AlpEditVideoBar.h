//
//  AlpEditVideoBar.h
//  Alpface
//
//  Created by swae on 2018/9/17.
//  Copyright © 2018 alpface. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AlpVideoCameraResourceItem.h"

NS_ASSUME_NONNULL_BEGIN

@class AlpEditVideoBar;
@protocol AlpEditVideoBarDelegate <NSObject>

@optional
/// 移除视频中的原声
- (void)removeOriginalSoundForEditVideoBar:(AlpEditVideoBar  *)bar;
/// 恢复视频中的原声
- (void)restoreOriginalSoundForEditVideoBar:(AlpEditVideoBar  *)bar;

@required
/// 选中滤镜
- (void)editVideoBar:(AlpEditVideoBar *)bar didSelectFilter:(AlpFilterData *)filterData;
/// 选中音乐
- (void)editVideoBar:(AlpEditVideoBar *)bar didSelectMusic:(AlpMusicData *)musicData;
/// 选中贴图
- (void)editVideoBar:(AlpEditVideoBar *)bar didSelectSticker:(AlpStickersData *)stickerData;

@end

@class AlpVideoCameraResourceItem;

@interface AlpEditVideoBar : UIView

@property (nonatomic, strong) AlpVideoCameraResourceItem *resourceItem;
@property (nonatomic, strong, readonly) NSString *audioPath;
@property (nonatomic, getter=isUseOriginalSound, readonly) BOOL useOriginalSound;

@property (nonatomic, weak) id<AlpEditVideoBarDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
