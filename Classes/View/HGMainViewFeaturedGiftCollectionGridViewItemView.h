//
//  HGMainViewFeaturedGiftCollectionGridViewItemView.h
//  HappyGift
//
//  Created by Yujian Weng on 12-6-10.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HGGiftSet;  
@class HGUserImageView;

@interface HGMainViewFeaturedGiftCollectionGridViewItemView : UIControl{
    IBOutlet UIImageView* coverImageView;
    IBOutlet UILabel*     coverTitleLabel;
    IBOutlet UIView*      overLayView;
    IBOutlet UIImageView* priceTagImageView;
    IBOutlet UILabel*     priceLabel;
    
    HGGiftSet*  giftSet;
}
@property (nonatomic, retain) HGGiftSet*  giftSet;
    
+ (HGMainViewFeaturedGiftCollectionGridViewItemView*)mainViewFeaturedGiftCollectionGridViewItemView;
@end
