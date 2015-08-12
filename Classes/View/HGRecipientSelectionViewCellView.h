//
//  HGRecipientSelectionViewCellView.h
//  HappyGift
//
//  Created by Yujian Weng on 12-5-18.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HGRecipient;
@class HGUserImageView;

@interface HGRecipientSelectionViewCellView : UITableViewCell {
    IBOutlet HGUserImageView* userImageView;
    IBOutlet UILabel* userNameLabelView;
    IBOutlet UILabel* userBirthdayView;
    IBOutlet UIView* addRecipientView;
    IBOutlet UIImageView* backgroundImageView;
}

@property (nonatomic, retain) HGUserImageView*  userImageView;
@property (nonatomic, retain) UIView* addRecipientView;
@property (nonatomic, retain) UILabel*  userNameLabelView;
@property (nonatomic, retain) UILabel* userBirthdayView;
@property (nonatomic, retain) UIImageView* backgroundImageView;

+ (HGRecipientSelectionViewCellView*)recipientCellView;
- (void) updateUserImageViewWithRecipient: (HGRecipient *)recipient;

@end