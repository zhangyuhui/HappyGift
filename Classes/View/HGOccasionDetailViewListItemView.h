//
//  HGOccasionDetailViewListItemView.h
//  HappyGift
//
//  Created by Yuhui Zhang on 9/30/11.
//  Copyright 2011 Ztelic Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HGGiftSet;  

@interface HGOccasionDetailViewListItemView : UIControl{
    IBOutlet UIImageView* coverImageView;
    IBOutlet UILabel*     titleLabel;
    IBOutlet UILabel*     descriptionLabel;
    IBOutlet UIView*      overLayView;
    IBOutlet UIImageView* priceImageView;
    IBOutlet UILabel*     priceLabel;
    
    HGGiftSet*  giftSet;
    NSTimer* highlightTimer;
}
@property (nonatomic, retain) HGGiftSet* giftSet;
    
+ (HGOccasionDetailViewListItemView*)occasionDetailViewListItemView;
@end
