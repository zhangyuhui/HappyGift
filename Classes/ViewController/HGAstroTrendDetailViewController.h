//
//  HGAstroTrendDetailViewController.h
//  HappyGift
//
//  Created by Yujian Weng on 12-7-5.
//  Copyright 2011 Ztelic Inc Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HGProgressView;
@class HGAstroTrend;
@class HGRecipient;
@class HGUserImageView;
@class HGDragToUpdateTableView;

@interface HGAstroTrendDetailViewController : UIViewController{
    IBOutlet UINavigationBar*  navigationBar;
    IBOutlet HGDragToUpdateTableView*      giftTableView;
    IBOutlet UILabel*          userNameLabel;
    IBOutlet UILabel*          userDescriptionLabel;
    IBOutlet HGUserImageView*      userImageView;
    IBOutlet UILabel* giftRecommendationLabel;
    IBOutlet UIView* giftRecommendationHeaderView;
    IBOutlet UIImageView* backgroundImageView;
    
    IBOutlet UIView*           astroTrendView;
    IBOutlet UIImageView*      astroTrendImageView;
    IBOutlet UILabel*          astroTrendSummaryLabel;
    IBOutlet UILabel*          astroTrendDetailLabel;
    IBOutlet UIView*           topSeperator;
    IBOutlet UIView*           bottomSeperator;
    IBOutlet UIButton*         startButton;
    
    IBOutlet UIImageView*      astroImageView;
    IBOutlet UILabel*          astroNameLabel;
    IBOutlet UILabel*          trendNameLabel;
    
    IBOutlet UIView* headerView;
    IBOutlet UIView* virtualGiftsView;
    
    UIBarButtonItem* leftBarButtonItem;
    HGProgressView*  progressView;
    
    HGAstroTrend* astroTrend;
    
    UIImage* imageForCompose;
    UIImage* imageForShare;
    IBOutlet UIButton* shareAstroTrendButton;
}

- (id)initWithAstroTrend:(HGAstroTrend*)theAstroTrend;
@end
