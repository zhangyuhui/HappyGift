//
//  HGMainViewAstroTrendGridViewItemView.h
//  HappyGift
//
//  Created by Yujian Weng on 12-7-4.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HGUserImageView;
@class HGAstroTrend;

@interface HGMainViewAstroTrendGridViewItemView : UIControl{
    IBOutlet HGUserImageView* recipientImageView;
    IBOutlet UILabel*     recipientNameLabel;
    IBOutlet UIView*      overLayView;
    
    HGAstroTrend*  astroTrend;
}
@property (nonatomic, retain) HGAstroTrend* astroTrend;
@property (nonatomic, retain) UILabel* recipientNameLabel;
@property (nonatomic, retain) HGUserImageView* recipientImageView;
    
+ (HGMainViewAstroTrendGridViewItemView*)mainViewAstroTrendGridViewItemView;
@end
