//
//  HGMainViewPersonlizedOccasionGiftCollectionGridView.h
//  HappyGift
//
//  Created by Yujian Weng on 12-6-5.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HGOccasionGiftCollection;
@class HGGiftOccasion;
@protocol HGMainViewPersonlizedOccasionGiftCollectionGridViewDelegate;

@interface HGMainViewPersonlizedOccasionGiftCollectionGridView : UIView {
    IBOutlet UIView*        headView;
    IBOutlet UIImageView*   headLogoImageView;
    IBOutlet UIImageView*   headBackgroundImageView;
    IBOutlet UILabel*       headTitleLabel;
    IBOutlet UIButton*      headActionButton;
    IBOutlet UIView*        contentView;
    IBOutlet UIImageView* backgroundImageView;
    
    id<HGMainViewPersonlizedOccasionGiftCollectionGridViewDelegate> delegate;
    NSArray* giftCollections;
}
@property (nonatomic, assign) id<HGMainViewPersonlizedOccasionGiftCollectionGridViewDelegate> delegate;
@property (nonatomic, retain) NSArray* giftCollections;

+ (HGMainViewPersonlizedOccasionGiftCollectionGridView*)mainViewPersonlizedOccasionGiftCollectionGridView;
@end

@protocol HGMainViewPersonlizedOccasionGiftCollectionGridViewDelegate <NSObject>
- (void)mainViewPersonlizedOccasionGiftCollectionGridView:(HGMainViewPersonlizedOccasionGiftCollectionGridView *)mainViewPersonlizedOccasionGiftCollectionGridView didSelectGiftOccasions:(NSArray*)giftCollections;
- (void)mainViewPersonlizedOccasionGiftCollectionGridView:(HGMainViewPersonlizedOccasionGiftCollectionGridView *)mainViewPersonlizedOccasionGiftCollectionGridView didSelectPersonlizedOccasionGiftCollection:(HGOccasionGiftCollection*)giftCollection;
@end