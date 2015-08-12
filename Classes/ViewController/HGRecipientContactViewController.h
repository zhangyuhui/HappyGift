//
//  HGRecipientContactViewController.h
//  HappyGift
//
//  Created by Zhang Yuhui on 2/11/11.
//  Copyright 2011 Ztelic Inc Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HGProgressView;
@class HGGiftOrder;
@class HGUserImageView;
@class ABPeoplePickerNavigationController;

@interface HGRecipientContactViewController : UIViewController{
    IBOutlet UINavigationBar*  navigationBar;
    IBOutlet UIScrollView*     deliveryDetailScrollView;
    IBOutlet UILabel*          senderTitleLabel;
    IBOutlet UILabel*          senderValueLabel;
    IBOutlet HGUserImageView*  senderImageView;
    
    IBOutlet UILabel*          notifyTitleLabel;
    IBOutlet UIButton*         notifyAddressbookButton;
    
    IBOutlet UIView*           notifyPhoneView;
    IBOutlet UIButton*         notifyPhoneButton;
    IBOutlet UITextField*      notifyPhoneTextFiled;
    IBOutlet UIView*           notifyPhoneOverlayView;
    
    IBOutlet UIView*           notifyEmailView;
    IBOutlet UIButton*         notifyEmailButton;
    IBOutlet UITextField*      notifyEmailTextFiled;
    IBOutlet UIView*           notifyEmailOverlayView;
    
    UIBarButtonItem* leftBarButtonItem;
    UIBarButtonItem* rightBarButtonItem;
    
    HGProgressView*  progressView;
    HGGiftOrder* giftOrder;
    ABPeoplePickerNavigationController* peoplePickerViewController;
}
- (id)initWithGiftOrder:(HGGiftOrder*)giftOrder;
@end