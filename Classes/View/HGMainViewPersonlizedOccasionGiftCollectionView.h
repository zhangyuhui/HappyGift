//
//  HGMainViewPersonlizedOccasionGiftCollectionView.h
//  HappyGift
//
//  Created by Yuhui Zhang on 7/20/11.
//  Copyright 2011 Ztelic Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HGPageControl;
@class HGOccasionGiftCollection;
@class HGGift;
@class HGGiftSet;
@class HGGiftOccasion;
@protocol HGMainViewPersonlizedOccasionGiftCollectionViewDelegate;

@interface HGMainViewPersonlizedOccasionGiftCollectionView : UIView {
    IBOutlet UIView*        headView;
    IBOutlet UIView*        headOverlayView;
    IBOutlet UIImageView*   headLogoImageView;
    IBOutlet UIImageView*   headBackgroundImageView;
    IBOutlet UILabel*       headTitleLabel;
    IBOutlet UIButton*      headActionButton;
    IBOutlet UIScrollView*  contentScrollView;
    IBOutlet HGPageControl* pageControl;
    
    id<HGMainViewPersonlizedOccasionGiftCollectionViewDelegate> delegate;
    NSArray* giftCollections;
    NSMutableArray* contentScrollSubViews;
    
    CGFloat dragOffsetX;
    NSTimeInterval dragOffsetInterval;
    int     dragoffsetSpeed;
}
@property (nonatomic, assign) id<HGMainViewPersonlizedOccasionGiftCollectionViewDelegate> delegate;
@property (nonatomic, retain) NSArray* giftCollections;

+ (HGMainViewPersonlizedOccasionGiftCollectionView*)mainViewPersonlizedOccasionGiftCollectionView;
@end

@protocol HGMainViewPersonlizedOccasionGiftCollectionViewDelegate <NSObject>
- (void)mainViewPersonlizedOccasionGiftCollectionView:(HGMainViewPersonlizedOccasionGiftCollectionView *)mainViewPersonlizedOccasionGiftCollectionView didSelectGiftOccasions:(NSArray*)giftCollections;
- (void)mainViewPersonlizedOccasionGiftCollectionView:(HGMainViewPersonlizedOccasionGiftCollectionView *)mainViewPersonlizedOccasionGiftCollectionView didSelectPersonlizedOccasionGiftCollection:(HGOccasionGiftCollection*)giftCollection;
@end