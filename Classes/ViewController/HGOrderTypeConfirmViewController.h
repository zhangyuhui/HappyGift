//
//  HGOrderTypeConfirmViewController.h
//  HappyGift
//
//  Created by Yujian Weng on 12-6-28.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HGProgressView;
@class HGGiftOrder;
@class HGUserImageView;

@interface HGOrderTypeConfirmViewController : UIViewController{
    IBOutlet UINavigationBar*  navigationBar;
    IBOutlet UIScrollView*     orderTypeConfirmScrollView;    
    
    IBOutlet HGUserImageView*  recipientImageView;
    
    IBOutlet UILabel*          sendToLabel;
    IBOutlet UILabel*          recipientNameLabel;
    IBOutlet UILabel*          orderTypeSelectionTitleLabel;
    IBOutlet UILabel*          quickOrderDescriptionLabel;
    IBOutlet UILabel*          customizedOrderDescriptionLabel;
    
    IBOutlet UIButton*         quickOrderButton;
    IBOutlet UIButton*         customizedOrderButton;
    
    UIBarButtonItem* leftBarButtonItem;
    HGProgressView*  progressView;
    HGGiftOrder* giftOrder;
}
- (id)initWithGiftOrder:(HGGiftOrder*)giftOrder;
@end