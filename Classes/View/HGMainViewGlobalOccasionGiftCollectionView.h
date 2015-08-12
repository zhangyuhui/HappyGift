//
//  HGMainViewGlobalOccasionGiftCollectionView.h
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
@protocol HGMainViewGlobalOccasionGiftCollectionViewDelegate;

@interface HGMainViewGlobalOccasionGiftCollectionView : UIView {
    IBOutlet UIView*        headView;
    IBOutlet UIImageView*   headLogoImageView;
    IBOutlet UIImageView*   headBackgroundImageView;
    IBOutlet UILabel*       headTitleLabel;
    IBOutlet UIButton*      headActionButton;
    IBOutlet UIScrollView*  contentScrollView;
    IBOutlet HGPageControl* pageControl;
    
    id<HGMainViewGlobalOccasionGiftCollectionViewDelegate> delegate;
    HGOccasionGiftCollection* giftCollection;
    NSMutableArray* contentScrollSubViews;
    
    CGFloat dragOffsetX;
    NSTimeInterval dragOffsetInterval;
    int     dragoffsetSpeed;
}
@property (nonatomic, assign) id<HGMainViewGlobalOccasionGiftCollectionViewDelegate> delegate;
@property (nonatomic, retain) HGOccasionGiftCollection* giftCollection;

+ (HGMainViewGlobalOccasionGiftCollectionView*)mainViewGlobalOccasionGiftCollectionView;
@end

@protocol HGMainViewGlobalOccasionGiftCollectionViewDelegate <NSObject>
- (void)mainViewGlobalOccasionGiftCollectionView:(HGMainViewGlobalOccasionGiftCollectionView *)mainViewGlobalOccasionGiftCollectionView didSelectGlobalOccasionGiftCollection:(HGOccasionGiftCollection*)giftCollection;
- (void)mainViewGlobalOccasionGiftCollectionView:(HGMainViewGlobalOccasionGiftCollectionView *)mainViewGlobalOccasionGiftCollectionView didSelectGlobalOccasionGiftSet:(HGGiftSet*)giftSet;
@end