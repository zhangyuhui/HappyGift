//
//  HGGiftsSelectionViewGiftsListCellView.h
//  HappyGift
//
//  Created by Yujian Weng on 12-7-18.
//  Copyright 2011 Ztelic Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HGGiftSet;  
@class HGEraseLineLabel;

@interface HGGiftsSelectionViewGiftsListCellView : UITableViewCell {
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
}
@property (nonatomic, retain) HGGiftSet* giftSet;
    
+ (HGGiftsSelectionViewGiftsListCellView*)giftsSelectionViewGiftsListItemView;
@end
