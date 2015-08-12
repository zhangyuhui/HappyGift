//
//  HGMainViewFeaturedGiftCollectionView.h
//  HappyGift
//
//  Created by Yuhui Zhang on 7/20/11.
//  Copyright 2011 Ztelic Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HGPageControl;
@class HGFeaturedGiftCollection;
@class HGGift;
@class HGGiftSet;
@protocol HGMainViewFeaturedGiftCollectionViewDelegate;

@interface HGMainViewFeaturedGiftCollectionView : UIView {
    IBOutlet UIView*        headView;
    IBOutlet UIImageView*   headLogoImageView;
    IBOutlet UIImageView*   headBackgroundImageView;
    IBOutlet UILabel*       headTitleLabel;
    IBOutlet UIButton*      headActionButton;
    IBOutlet UIScrollView*  contentScrollView;
    IBOutlet HGPageControl* pageControl;
    
    id<HGMainViewFeaturedGiftCollectionViewDelegate> delegate;
    HGFeaturedGiftCollection* giftCollection;
    NSMutableArray* contentScrollSubViews;
    
    CGFloat dragOffsetX;
    NSTimeInterval dragOffsetInterval;
    int     dragoffsetSpeed;
}
@property (nonatomic, assign) id<HGMainViewFeaturedGiftCollectionViewDelegate> delegate;
@property (nonatomic, retain) HGFeaturedGiftCollection* giftCollection;

+ (HGMainViewFeaturedGiftCollectionView*)mainViewFeaturedGiftCollectionView;
@end

@protocol HGMainViewFeaturedGiftCollectionViewDelegate <NSObject>
- (void)mainViewFeaturedGiftCollectionView:(HGMainViewFeaturedGiftCollectionView *)mainViewFeaturedGiftCollectionView didSelectFeaturedGiftCollection:(HGFeaturedGiftCollection*)giftCollection;
- (void)mainViewFeaturedGiftCollectionView:(HGMainViewFeaturedGiftCollectionView *)mainViewFeaturedGiftCollectionView didSelectFeaturedGiftSet:(HGGiftSet*)giftSet;
@end