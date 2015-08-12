//
//  HGMainViewSentGiftsGridViewItemView.h
//  HappyGift
//
//  Created by Yujian Weng on 12-6-10.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HGUserImageView;
@class HGGiftOrder;

@interface HGMainViewSentGiftsGridViewItemView : UIControl{
    IBOutlet HGUserImageView* recipientImageView;
    IBOutlet UILabel*     recipientNameLabel;
    IBOutlet UILabel*     orderStatusLabel;
    IBOutlet UIView*      overLayView;
    
    HGGiftOrder*  giftOrder;
}
@property (nonatomic, retain) HGGiftOrder* giftOrder;
    
+ (HGMainViewSentGiftsGridViewItemView*)mainViewSentGiftsGridViewItemView;
@end
