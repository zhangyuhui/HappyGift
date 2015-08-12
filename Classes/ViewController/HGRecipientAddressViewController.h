//
//  HGRecipientAddressViewController.h
//  HappyGift
//
//  Created by Yujian Weng on 12-6-27.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HGProgressView;
@class HGGiftOrder;

@interface HGRecipientAddressViewController : UIViewController{
    IBOutlet UINavigationBar*  navigationBar;
    IBOutlet UIScrollView*     recipientAddressScrollView;    
    
    IBOutlet UILabel*          recipientLabel;
    IBOutlet UILabel*          provinceLabel;
    IBOutlet UILabel*          streetAddressLabel;
    IBOutlet UILabel*          postCodeLabel;
    IBOutlet UILabel*          phoneLabel;
    IBOutlet UILabel*          notificationTitleLabel;
    IBOutlet UILabel*          notificationSubTitleLabel;
    
    IBOutlet UITextField*      recipientTextField;
    IBOutlet UITextField*      provinceTextField;
    IBOutlet UITextField*      streetAddressTextField;
    IBOutlet UITextField*      postCodeTextField;
    IBOutlet UITextField*      phoneTextField;
    
    IBOutlet UIImageView*      recipientNameBackground;
    IBOutlet UIImageView*      provinceBackground;
    IBOutlet UIImageView*      streetAddressBackground;
    IBOutlet UIImageView*      postCodeBackground;
    IBOutlet UIImageView*      phoneBackground;
    
    IBOutlet UIButton*         provinceButton;
    
    IBOutlet UIButton*         nextStepButton;
    
    IBOutlet UIImageView*      notifyCalendarImageView;
    IBOutlet UILabel*          notifyCalendarLabel;
    IBOutlet UIButton*         notifyCalendarButton;
    UIDatePicker *datePickerControlView;
    
    UIBarButtonItem* leftBarButtonItem;
    UIBarButtonItem* rightBarButtonItem;
    HGProgressView*  progressView;
    HGGiftOrder* giftOrder;
    
    NSString* selectedProvince;
    NSString* selectedCity;
}
- (id)initWithGiftOrder:(HGGiftOrder*)giftOrder;
@property (strong, nonatomic) UIPickerView *provincePicker;
@property (strong, nonatomic) NSDictionary *provinceCities;
@property (strong, nonatomic) NSArray *provinces;
@property (strong, nonatomic) NSArray *cities;
@end