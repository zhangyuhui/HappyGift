//
//  HGMainViewPersonlizedOccasionGiftCollectionItemView.h
//  HappyGift
//
//  Created by Yuhui Zhang on 9/30/11.
//  Copyright 2011 Ztelic Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HGOccasionGiftCollection;  
@class HGUserImageView;

@interface HGMainViewPersonlizedOccasionGiftCollectionItemView : UIControl{
    IBOutlet HGUserImageView* coverImageView;
    IBOutlet UILabel*     userNameLabel;
    IBOutlet UILabel*     eventNameLabel;
    IBOutlet UILabel*     eventDescriptionLabel;
    IBOutlet UIView*      overLayView;
    
    HGOccasionGiftCollection*  giftCollection;
    NSTimer* highlightTimer;
    UIImage* defaultImage;
}
@property (nonatomic, retain) HGOccasionGiftCollection* giftCollection;
    
+ (HGMainViewPersonlizedOccasionGiftCollectionItemView*)mainViewPersonlizedOccasionGiftCollectionItemView;
@end
