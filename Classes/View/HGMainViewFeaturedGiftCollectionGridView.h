//
//  HGMainViewFeaturedGiftCollectionGridView.h
//  HappyGift
//
//  Created by Yujian Weng on 12-6-10.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HGFeaturedGiftCollection;
@class HGGiftSet;
@protocol HGMainViewFeaturedGiftCollectionGridViewDelegate;

@interface HGMainViewFeaturedGiftCollectionGridView : UIView {
    IBOutlet UIView*        headView;
    IBOutlet UIImageView*   headBackgroundImageView;
    IBOutlet UILabel*       headTitleLabel;
    IBOutlet UIButton*      headActionButton;
    IBOutlet UIView*        contentView;
    IBOutlet UIImageView*   backgroundImageView;
    
    id<HGMainViewFeaturedGiftCollectionGridViewDelegate> delegate;
    HGFeaturedGiftCollection* giftCollection;
}
@property (nonatomic, assign) id<HGMainViewFeaturedGiftCollectionGridViewDelegate> delegate;
@property (nonatomic, retain) HGFeaturedGiftCollection* giftCollection;

+ (HGMainViewFeaturedGiftCollectionGridView*)mainViewFeaturedGiftCollectionGridView;
@end

@protocol HGMainViewFeaturedGiftCollectionGridViewDelegate <NSObject>
- (void)mainViewFeaturedGiftCollectionGridView:(HGMainViewFeaturedGiftCollectionGridView *)mainViewFeaturedGiftCollectionGridView didSelectFeaturedGiftCollection:(HGFeaturedGiftCollection*)giftCollection;
- (void)mainViewFeaturedGiftCollectionGridView:(HGMainViewFeaturedGiftCollectionGridView *)mainViewFeaturedGiftCollectionGridView didSelectFeaturedGiftSet:(HGGiftSet*)giftSet;
- (void)mainViewFeaturedGiftCollectionGridViewDidSelectGIFGifts:(HGMainViewFeaturedGiftCollectionGridView*)mainViewFeaturedGiftCollectionGridView;
- (void)mainViewFeaturedGiftCollectionGridViewDidSelectDIYGifts:(HGMainViewFeaturedGiftCollectionGridView*)mainViewFeaturedGiftCollectionGridView;
@end