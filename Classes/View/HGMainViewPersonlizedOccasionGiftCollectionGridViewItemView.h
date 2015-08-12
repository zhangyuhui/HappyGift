//
//  HGMainViewPersonlizedOccasionGiftCollectionGridViewItemView.h
//  HappyGift
//
//  Created by Yujian Weng on 12-6-5.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HGOccasionGiftCollection;  
@class HGUserImageView;

@interface HGMainViewPersonlizedOccasionGiftCollectionGridViewItemView : UIControl{
    IBOutlet HGUserImageView* coverImageView;
    IBOutlet UILabel*     userNameLabel;
    IBOutlet UILabel*     eventDescriptionLabel;
    IBOutlet UIView*      overLayView;
    
    HGOccasionGiftCollection*  giftCollection;
}
@property (nonatomic, retain) HGOccasionGiftCollection* giftCollection;
    
+ (HGMainViewPersonlizedOccasionGiftCollectionGridViewItemView*)mainViewPersonlizedOccasionGiftCollectionGridViewItemView;
@end
