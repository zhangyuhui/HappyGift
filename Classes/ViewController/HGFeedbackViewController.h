//
//  HGFeedbackViewController.m
//  HappyGift
//
//  Created by Yujian Weng on 12-5-25.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//


#import <UIKit/UIKit.h>
@class HGProgressView;

@interface HGFeedbackViewController : UIViewController {
    IBOutlet UINavigationBar*  navigationBar;
    IBOutlet UIScrollView*     feedbackInfoScrollView;
    IBOutlet UILabel*          feedbackTagLabel;
    
    IBOutlet UILabel*          pageDescriptionLabel;
    IBOutlet UIImageView*      seperatorView;
    
    IBOutlet UIView*           feedbackContentView;
    IBOutlet UITextView*       feedbackContentTextView;
    
    UIBarButtonItem* leftBarButtonItem;
    UIBarButtonItem* rightBarButtonItem;
    HGProgressView*  progressView;
}

@end