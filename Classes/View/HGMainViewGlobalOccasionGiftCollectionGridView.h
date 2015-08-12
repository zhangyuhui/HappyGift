//
//  HGMainViewGlobalOccasionGiftCollectionGridView.h
//  HappyGift
//
//  Created by Yujian Weng on 12-6-10.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HGOccasionGiftCollection;
@class HGGift;
@class HGGiftSet;
@class HGGiftOccasion;
@protocol HGMainViewGlobalOccasionGiftCollectionGridViewDelegate;

@interface HGMainViewGlobalOccasionGiftCollectionGridView : UIView {
    IBOutlet UIView*        headView;
    IBOutlet UIImageView*   headLogoImageView;
    IBOutlet UIImageView*   headBackgroundImageView;
    IBOutlet UILabel*       headTitleLabel;
    IBOutlet UIButton*      headActionButton;
    IBOutlet UIView*        contentView;
    IBOutlet UIImageView*   backgroundImageView;
    
    id<HGMainViewGlobalOccasionGiftCollectionGridViewDelegate> delegate;
    HGOccasionGiftCollection* giftCollection;
}
@property (nonatomic, assign) id<HGMainViewGlobalOccasionGiftCollectionGridViewDelegate> delegate;
@property (nonatomic, retain) HGOccasionGiftCollection* giftCollection;

+ (HGMainViewGlobalOccasionGiftCollectionGridView*)mainViewGlobalOccasionGiftCollectionGridView;
@end

@protocol HGMainViewGlobalOccasionGiftCollectionGridViewDelegate <NSObject>
- (void)mainViewGlobalOccasionGiftCollectionGridView:(HGMainViewGlobalOccasionGiftCollectionGridView *)mainViewGlobalOccasionGiftCollectionGridView didSelectGlobalOccasionGiftCollection:(HGOccasionGiftCollection*)giftCollection;
- (void)mainViewGlobalOccasionGiftCollectionGridView:(HGMainViewGlobalOccasionGiftCollectionGridView *)mainViewGlobalOccasionGiftCollectionGridView didSelectGlobalOccasionGiftSet:(HGGiftSet*)giftSet;
@end