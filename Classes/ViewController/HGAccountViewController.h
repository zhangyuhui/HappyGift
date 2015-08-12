//
//  HGAccountViewController.h
//  HappyGift
//
//  Created by Yuhui Zhang on 8/21/11.
//  Copyright 2011 Ztelic Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HGProgressView;
@class HGAccount;
@class HGRecipient;
@class MFMailComposeViewController;
@class MFMessageComposeViewController;
@protocol HGAccountViewControllerDelegate;

@interface HGAccountViewController : UIViewController {
    IBOutlet UINavigationBar*           navigationBar;
    
    IBOutlet UIScrollView*              contentScrollView;
    
    IBOutlet UIView*                    weiboAccountInfoView;
    IBOutlet UIButton*                  weiboLogoutButton;
    IBOutlet UIImageView*               weiboUserIconImageView;
    IBOutlet UILabel*                   weiboUserNameLabel;
    
    IBOutlet UIView*                    weiboAccountLoginView;
    IBOutlet UILabel*                   weiboLoginLabel;
    IBOutlet UIButton*                  weiboLoginButton;
    
    IBOutlet UIView*                    renrenAccountInfoView;
    IBOutlet UIButton*                  renrenLogoutButton;
    IBOutlet UIImageView*               renrenUserIconImageView;
    IBOutlet UILabel*                   renrenUserNameLabel;

    IBOutlet UIView*                    renrenAccountLoginView;
    IBOutlet UILabel*                   renrenLoginLabel;
    IBOutlet UIButton*                  renrenLoginButton;
    
    IBOutlet UIView*                    contactView;
    IBOutlet UIButton*                  contactButton;
    IBOutlet UILabel*                   contactLabel;
    
    IBOutlet UIView*                    myLikesView;
    IBOutlet UIButton*                  myLikesButton;
    IBOutlet UILabel*                   myLikesLabel;
    
    IBOutlet UIView*                    myGiftsView;
    IBOutlet UIButton*                  myGiftsButton;
    IBOutlet UILabel*                   myGiftsLabel;
    
    IBOutlet UIView*                    aboutView;
    IBOutlet UIButton*                  aboutButton;
    IBOutlet UILabel*                   aboutLabel;
    
    IBOutlet UIView*                    tutorialView;
    IBOutlet UIButton*                  tutorialButton;
    IBOutlet UILabel*                   tutorialLabel;
    
    IBOutlet UIView*                    feedbackView;
    IBOutlet UIButton*                  feedbackButton;
    IBOutlet UILabel*                   feedbackLabel;
    
    IBOutlet UIView*                    recommendView;
    IBOutlet UIButton*                  recommendButton;
    IBOutlet UILabel*                   recommendLabel;
    
    IBOutlet UIButton*                  clearCacheButton;
    
    IBOutlet UIButton*                  globalLogoutButton;
    
    UIImageView*                        accountTutorialView;
    
    UIBarButtonItem*                    leftBarButtonItem;
    UIBarButtonItem*                    rightBarButtonItem;
    HGProgressView*                     progressView;
    HGAccount*                          loginAccount;
    
    int                                 bindUserRequestType;
    
    int                                 recommendAction;
    HGRecipient*                        recommendRecipient;
    BOOL                                recommendRecipientSelected;
    MFMailComposeViewController *mailViewController; 
    MFMessageComposeViewController *messageViewController;
    id<HGAccountViewControllerDelegate> delegate;
    
    BOOL                                launchForLogin;
    BOOL                                launchForLoginBindRequest;
    BOOL                                launchForLoginBindCancel;
    int                                 launchForLoginNetwork;
}
@property (nonatomic, assign) id<HGAccountViewControllerDelegate> delegate;

- (id)initWithLoginNetwork:(int)network;

@end

@protocol HGAccountViewControllerDelegate <NSObject>
- (void)didGlobalLogout;
@end
