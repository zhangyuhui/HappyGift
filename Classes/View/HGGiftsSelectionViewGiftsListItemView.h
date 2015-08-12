//
//  HGGiftsSelectionViewGiftsListItemView.h
//  HappyGift
//
//  Created by Yuhui Zhang on 9/30/11.
//  Copyright 2011 Ztelic Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HGGiftSet;  
@class HGEraseLineLabel;

@interface HGGiftsSelectionViewGiftsListItemView : UIControl{
    IBOutlet UIImageView* coverImageView;
    IBOutlet UILabel*     titleLabel;
    IBOutlet UILabel*     descriptionLabel;
    IBOutlet UILabel*     priceLabel;
    IBOutlet UIImageView* likeCountImageView;
    IBOutlet UILabel*     likeCountLabel;
    IBOutlet UIView*      overLayView;
    IBOutlet UIImageView* priceImageView;
    IBOutlet UIImageView* freeShippingCostImageView;
    IBOutlet HGEraseLineLabel*     basePriceLabel;
    
    HGGiftSet*  giftSet;
    NSTimer* highlightTimer;
}
@property (nonatomic, retain) HGGiftSet* giftSet;
    
+ (HGGiftsSelectionViewGiftsListItemView*)giftsSelectionViewGiftsListItemView;
@end
