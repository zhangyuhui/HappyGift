//
//  HGMainViewSentGiftsItemView.h
//  HappyGift
//
//  Created by Yuhui Zhang on 9/30/11.
//  Copyright 2011 Ztelic Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HGGiftOrder;    
@class HGUserImageView;

@interface HGMainViewSentGiftsItemView : UIControl{
    IBOutlet HGUserImageView* coverImageView;
    IBOutlet UILabel*     titleLabel;
    IBOutlet UILabel*     descriptionLabel;
    IBOutlet UILabel*     priceLabel;
    IBOutlet UIView*      overLayView;
    
    HGGiftOrder*  giftOrder;
    NSTimer* highlightTimer;
    UIImage* defaultImage;
}
@property (nonatomic, retain) HGGiftOrder* giftOrder;

+ (HGMainViewSentGiftsItemView*)mainViewSentGiftsItemView;
@end
