//
//  HGMainViewAstroTrendGridView.h
//  HappyGift
//
//  Created by Yujian Weng on 12-7-4.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HGAstroTrend;

@protocol HGMainViewAstroTrendGridViewDelegate;

@interface HGMainViewAstroTrendGridView : UIView {
    IBOutlet UIView*        headView;
    IBOutlet UIImageView*   headLogoImageView;
    IBOutlet UIImageView*   headBackgroundImageView;
    IBOutlet UILabel*       headTitleLabel;
    IBOutlet UIButton*      headActionButton;
    IBOutlet UIView*        contentView;
    IBOutlet UIImageView* backgroundImageView;
    
    id<HGMainViewAstroTrendGridViewDelegate> delegate;
    NSArray* astroTrends;
}

@property (nonatomic, assign) id<HGMainViewAstroTrendGridViewDelegate> delegate;
@property (nonatomic, retain) NSArray* astroTrends;

+ (HGMainViewAstroTrendGridView*)mainViewAstroTrendGridView;
@end

@protocol HGMainViewAstroTrendGridViewDelegate <NSObject>
- (void)mainViewAstroTrendGridView:(HGMainViewAstroTrendGridView *)mainViewAstroTrendGridView didSelectAstroTrends:(NSArray*)astroTrends;

- (void)mainViewAstroTrendGridView:(HGMainViewAstroTrendGridView *)mainViewAstroTrendGridView didSelectAstroTrend:(HGAstroTrend*)astroTrend;
@end