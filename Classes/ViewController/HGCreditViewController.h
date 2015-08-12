//
//  HGCreditViewController.h
//  HappyGift
//
//  Created by Zhang Yuhui on 2/11/11.
//  Copyright 2011 Ztelic Inc Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HGProgressView;
@class HGRecipient;
@class MFMailComposeViewController;
@class MFMessageComposeViewController;

@interface HGCreditViewController : UIViewController{
    IBOutlet UINavigationBar*  navigationBar;
    
    IBOutlet UIView*           creditHeaderView;
    IBOutlet UILabel*          creditTitleLabel;
    IBOutlet UILabel*          creditValueLabel;
    IBOutlet UILabel*          creditDescriptionLabel;
    IBOutlet UIButton*         creditStartButton;
    
    IBOutlet UIView*           creditHistoryView;
    IBOutlet UIImageView*      creditHistoryBackgroundView;
    IBOutlet UILabel*          creditHistoryTitleLabel;
    IBOutlet UIScrollView*     creditHistoryScrollView;
    
    IBOutlet UIView*           creditRedeemView;
    IBOutlet UIView*           creditRedeemInputView;
    IBOutlet UILabel*          creditRedeemNameLabel;
    IBOutlet UITextField*      creditRedeemTextField;
    IBOutlet UIButton*         creditRedeemSubmitButton;
    IBOutlet UIButton*         creditRedeemCancelButton;
    
    UIBarButtonItem* leftBarButtonItem;
    HGProgressView*  progressView;
    
    int                                 recommendAction;
    HGRecipient*                        recommendRecipient;
    BOOL                                recommendRecipientSelected;
    MFMailComposeViewController *mailViewController; 
    MFMessageComposeViewController *messageViewController;
}
@end
