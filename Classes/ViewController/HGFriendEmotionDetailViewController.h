//
//  HGFriendEmotionDetailViewController.h
//  HappyGift
//
//  Created by Yujian Weng on 12-7-10.
//  Copyright 2011 Ztelic Inc Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HGProgressView;
@class HGFriendEmotion;
@class HGRecipient;
@class HGUserImageView;
@class HGDragToUpdateTableView;
@class HGTweetListView;

@interface HGFriendEmotionDetailViewController : UIViewController{
    IBOutlet UINavigationBar*  navigationBar;
    IBOutlet HGDragToUpdateTableView*      tableView;
    IBOutlet UILabel*          userNameLabel;
    IBOutlet UILabel*          userDescriptionLabel;
    IBOutlet HGUserImageView*      userImageView;
    IBOutlet UILabel* giftRecommendationLabel;
    IBOutlet UIView* giftRecommendationHeaderView;
    IBOutlet UIImageView* backgroundImageView;
    
    IBOutlet UIView*           astroTrendView;
    IBOutlet UIImageView*      astroTrendImageView;
    IBOutlet UILabel*          astroTrendSummaryLabel;
    IBOutlet UIView*           topSeperator;
    IBOutlet UIView*           bottomSeperator;
    IBOutlet UIButton*         startButton;
    
    IBOutlet UILabel*          emotionDescriptionLabel;
    
    IBOutlet UIImageView*      emotionScoreBarImageView;
    
    IBOutlet UIButton*         showMoreTweetsButton;
    IBOutlet UIButton* tweetsOverlayView;
    
    IBOutlet UIView* headerView;
    IBOutlet UIView* virtualGiftsView;
    
    UIBarButtonItem* leftBarButtonItem;
    HGProgressView*  progressView;
    HGTweetListView* tweetListView;
    
    HGFriendEmotion* friendEmotion;
    
    UIImage* imageForCompose;
    UIImage* imageForShare;
}

- (id)initWithFriendEmotion:(HGFriendEmotion*)theFriendEmotion;
@end
