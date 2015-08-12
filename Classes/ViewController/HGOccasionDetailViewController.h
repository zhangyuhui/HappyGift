//
//  HGOccasionDetailViewController.h
//  HappyGift
//
//  Created by Zhang Yuhui on 2/11/11.
//  Copyright 2011 Ztelic Inc Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HGProgressView;
@class HGOccasionGiftCollection;
@class HGRecipient;
@class HGUserImageView;
@class HGDragToUpdateTableView;
@class HGTweetListView;
@class HGTweetView;

@interface HGOccasionDetailViewController : UIViewController{
    IBOutlet UINavigationBar*  navigationBar;
    IBOutlet HGDragToUpdateTableView*      tableView;
    IBOutlet UILabel*          userNameLabel;
    IBOutlet UILabel*          userDescriptionLabel;
    IBOutlet HGUserImageView*      userImageView;
    IBOutlet UILabel* giftRecommandationLabel;
    IBOutlet UIView* giftRecommandationHeaderView;
    IBOutlet UIImageView* backgroundImageView;
    
    IBOutlet UIView*           occasionView;
    IBOutlet UIImageView*      occasionImageView;
    IBOutlet UILabel*          occasionNameLabel;
    IBOutlet UILabel*          occasionDescriptionLabel;
    IBOutlet UIView*           occasionSeperatorTop;
    IBOutlet UIView*           occasionSeperatorBottom;
    IBOutlet UIButton*         startButton;
    
    IBOutlet UIView*           headerView;
    IBOutlet UIView*           virtualGiftsView;
    IBOutlet UIButton*         showDetailButton;
    IBOutlet UIButton*         tweetsOverlayView;
    
    UIBarButtonItem* leftBarButtonItem;
    HGProgressView*  progressView;
    
    HGOccasionGiftCollection* giftCollection;
    
    
    HGTweetListView* tweetListView;
    HGTweetView* tweetView;
    
    UIImage* imageForCompose;
    UIImage* imageForShare;
}

- (id)initWithGiftCollection:(HGOccasionGiftCollection*)giftCollection;
@end
