//
//  HGAstroTrendListViewCellView.h
//  HappyGift
//
//  Created by Yujian Weng on 12-7-5.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HGUserImageView;
@class HGAstroTrend;

@interface HGAstroTrendListViewCellView : UITableViewCell {
    IBOutlet UIImageView*     backgroundImageView;
    IBOutlet HGUserImageView*    userImageView;
    IBOutlet UILabel*        nameLabel;
    IBOutlet UILabel*        descriptionLabel;
    IBOutlet UIImageView* astroImageView;
    HGAstroTrend*        astroTrend;
}

@property (nonatomic, retain) HGAstroTrend* astroTrend;
@property (nonatomic, retain) HGUserImageView* userImageView;
@property (nonatomic, retain) UILabel* nameLabel;
@property (nonatomic, retain) UILabel* descriptionLabel;
@property (nonatomic, retain) UIImageView* astroImageView;

+ (HGAstroTrendListViewCellView*)astroTrendListViewCellView;

@end