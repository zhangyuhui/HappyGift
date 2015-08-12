//
//  HGGiftsSelectionViewAssistantOptionView.h
//  HappyGift
//
//  Created by Yuhui Zhang on 9/30/11.
//  Copyright 2011 Ztelic Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HGGiftAssistantOption;  

@interface HGGiftsSelectionViewAssistantOptionView : UIControl{
    IBOutlet UIImageView* coverImageView;
    IBOutlet UILabel*     titleLabel;
    IBOutlet UIView*      overLayView;
    
    HGGiftAssistantOption*  giftAssistantOption;
    NSTimer* highlightTimer;
}
@property (nonatomic, retain) HGGiftAssistantOption* giftAssistantOption;
    
+ (HGGiftsSelectionViewAssistantOptionView*)giftsSelectionViewAssistantOptionView;
@end
