//
//  HGMainViewController.h
//  HappyGift
//
//  Created by Zhang Yuhui on 2/11/11.
//  Copyright 2011 Ztelic Inc Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HGProgressView;
@class HGFeaturedGiftCollection;
@class HGMainViewSentGiftsGridView;

@interface HGMainViewController : UIViewController{
    IBOutlet UIScrollView*  contentView;
    IBOutlet UIButton* creditButton;
    IBOutlet UINavigationBar*  navigationBar;
    
    IBOutlet UIView* giftStartView;
    IBOutlet UIButton* giftStartButton;
    IBOutlet UILabel* giftStartLabel;
    IBOutlet UIImageView* giftStartIndicator;
    
    IBOutlet UIView* giftContinueView;
    IBOutlet UIButton* giftContinueButton;
    IBOutlet UILabel* giftContinueUpLabel;
    IBOutlet UILabel* giftContinueBottomLabel;
    IBOutlet UIImageView* giftContinueImageView;
    
    IBOutlet UIView* accountBindView;
    IBOutlet UIButton* accountBindButton;

    UIBarButtonItem* leftBarButtonItem;
    HGProgressView*  progressView;
    IBOutlet UIActivityIndicatorView* smallProgressView;
    IBOutlet UIButton* reloadButton;
    
    int  giftCollectionsRequest;
    
    NSMutableArray* contentSubViews;
    
    BOOL weiboExpired;
    BOOL renrenExpired;
    BOOL shouldNotifiyExpiration;
    
    UIImage* imageForCompose;
    UIImage* imageForShare;
}
@end
