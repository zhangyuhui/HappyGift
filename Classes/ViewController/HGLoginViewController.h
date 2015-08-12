//
//  HGLoginViewController.h
//  HappyGift
//
//  Created by Yujian Weng on 12-7-31.
//  Copyright 2011 Ztelic Inc Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HGProgressView;
@class HGAccount;

@interface HGLoginViewController : UIViewController {
    IBOutlet UIScrollView*              contentScrollView;
    
    IBOutlet UIView*                    weiboAccountInfoView;
    IBOutlet UIImageView*               weiboUserIconImageView;
    IBOutlet UILabel*                   weiboUserNameLabel;
    
    IBOutlet UIButton*                  weiboLoginButton;
    
    IBOutlet UIView*                    renrenAccountInfoView;
    IBOutlet UIImageView*               renrenUserIconImageView;
    IBOutlet UILabel*                   renrenUserNameLabel;

    IBOutlet UIButton*                  renrenLoginButton;
    
    IBOutlet UIButton*                  startLesongButton;
    IBOutlet UILabel*                   loginTitleLabel;
    IBOutlet UILabel*                   loginDescriptionLabel;
    
    HGProgressView*                     progressView;
    HGAccount*                          loginAccount;
    
    int                                 bindUserRequestType;
}

@end
