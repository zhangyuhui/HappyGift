//
//  HGDeliveryDetailViewController.h
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

@interface HGDeliveryDetailViewController : UIViewController{
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
    
    IBOutlet UIView*           notifyWeiBoView;
    IBOutlet UIButton*         notifyWeiboButton;
    IBOutlet UITextField*      notifyWeiboTextFiled;
    IBOutlet UIView*           notifyWeiboOverlayView;
    
    IBOutlet UIView*           notifyEmailView;
    IBOutlet UIButton*         notifyEmailButton;
    IBOutlet UITextField*      notifyEmailTextFiled;
    IBOutlet UIView*           notifyEmailOverlayView;
    
    IBOutlet UILabel*          notifyCalendarTitleLabel;
    
    IBOutlet UIImageView*      notifyCalendarImageView;
    IBOutlet UILabel*          notifyCalendarLabel;
    IBOutlet UIButton*         notifyCalendarButton;
    
    UIBarButtonItem* leftBarButtonItem;
    UIBarButtonItem* rightBarButtonItem;
    UIDatePicker *datePickerControlView;
    HGProgressView*  progressView;
    HGGiftOrder* giftOrder;
    ABPeoplePickerNavigationController* peoplePickerViewController;
}
- (id)initWithGiftOrder:(HGGiftOrder*)giftOrder;
@end