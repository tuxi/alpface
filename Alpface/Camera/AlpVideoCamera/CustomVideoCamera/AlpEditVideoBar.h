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

typedef NS_ENUM(NSUInteger , AlpChooseEditType) {
    AlpChooseEditTypeFilter = 1, //
    AlpChooseEditTypeMusic = 2,
    AlpChooseEditTypeStickers = 3,//
};

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

@property (nonatomic, strong) UICollectionView *musicCollectionView;
@property (nonatomic, strong) UICollectionView *filterCollectionView;
@property (nonatomic, strong) UICollectionView *stickersCollectionView;
@property (nonatomic, assign) AlpChooseEditType chooseEditType;
@property (nonatomic, strong) AlpVideoCameraResourceItem *resourceItem;
@property (nonatomic, strong) NSIndexPath* lastFilterIndex;
@property (nonatomic, strong) NSIndexPath* lastMusicIndex;
@property (nonatomic, strong) NSIndexPath* nowMusicIndex;
@property (nonatomic, strong) NSIndexPath* nowFilterIndex;
@property (nonatomic, strong) NSIndexPath* lastStickersIndex;
@property (nonatomic, strong) NSIndexPath* nowStickersIndex;
@property (nonatomic, strong) UIButton* editTheOriginaBtn;
@property (nonatomic, strong, readonly) NSString *audioPath;

@property (nonatomic, weak) id<AlpEditVideoBarDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
