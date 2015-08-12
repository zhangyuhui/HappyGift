//
//  HGRecipientSelectionViewCellView.h
//  HappyGift
//
//  Created by Yujian Weng on 12-5-22.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HGRecipient;
@class HGUserImageView;

@interface HGSentGiftsViewCellView : UITableViewCell {
    IBOutlet HGUserImageView* userImageView;
    
    IBOutlet UILabel* recipientNameLabelView;
    IBOutlet UILabel* orderCreatedDateLabelView;
    IBOutlet UILabel* statusLabelView;
    IBOutlet UIImageView* statusImageView;
    IBOutlet UIImageView* backgroundImageView;
}

@property (nonatomic, retain) HGUserImageView*  userImageView;
@property (nonatomic, retain) UILabel* recipientNameLabelView;
@property (nonatomic, retain) UILabel* orderCreatedDateLabelView;
@property (nonatomic, retain) UILabel* statusLabelView;
@property (nonatomic, retain) UIImageView* statusImageView;
@property (nonatomic, retain) UIImageView* backgroundImageView;

+ (HGSentGiftsViewCellView*)sentGiftCellView;
- (void) updateUserImageViewWithRecipient: (HGRecipient*) recipient;

@end