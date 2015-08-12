//
//  HGMainViewGiftCollectionTinyItemView.h
//  HappyGift
//
//  Created by Yuhui Zhang on 9/30/11.
//  Copyright 2011 Ztelic Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HGGiftSet;           

@interface HGMainViewGlobalOccasionGiftCollectionItemView : UIControl{
    IBOutlet UIImageView* coverImageView;
    IBOutlet UILabel*     titleLabel;
    IBOutlet UILabel*     descriptionLabel;
    IBOutlet UILabel*     priceLabel;
    IBOutlet UIView*      overLayView;
    
    HGGiftSet*  giftSet;
    NSTimer* highlightTimer;
    UIImage* defaultImage;
}
@property (nonatomic, retain) HGGiftSet* giftSet;
    
+ (HGMainViewGlobalOccasionGiftCollectionItemView*)mainViewGlobalOccasionGiftCollectionItemView;
@end
