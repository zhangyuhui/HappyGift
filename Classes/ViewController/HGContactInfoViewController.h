//
//  HGContactInfoViewController.m
//  HappyGift
//
//  Created by Yujian Weng on 12-5-25.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//


#import <UIKit/UIKit.h>
@class HGProgressView;
@class HGAccount;
@class HGGiftOrder;

@interface HGContactInfoViewController : UIViewController {
    IBOutlet UINavigationBar*  navigationBar;
    IBOutlet UIScrollView*     contactInfoScrollView;
    IBOutlet UILabel*          contactTagLabel;
    
    IBOutlet UILabel*          pageDescriptionLabel;
    IBOutlet UIImageView*      seperatorView;
    
    IBOutlet UIView*           userInfoView;
    IBOutlet UILabel*          userNameLabel;
    IBOutlet UILabel*          userEmailLabel;
    IBOutlet UILabel*          userPhoneLabel;
    IBOutlet UITextField*      userNameTextField;
    IBOutlet UITextField*      userEmailTextField;
    IBOutlet UITextField*      userPhoneTextField;
    
    UIBarButtonItem* leftBarButtonItem;
    UIBarButtonItem* rightBarButtonItem;
    UIView* datePickerOverLayView;
    HGProgressView*  progressView;
    
    HGAccount* editingAccount;
    HGGiftOrder* giftOrder;
}

- (id)initWithGiftOrder:(HGGiftOrder*)giftOrder;
@end