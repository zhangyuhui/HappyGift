//
//  HGMainViewFriendRecommandationGridView.h
//  HappyGift
//
//  Created by Yujian Weng on 12-6-11.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HGGiftOrder;
@class HGFriendRecommandation;

@protocol HGMainViewRecommandationGridViewDelegate;

@interface HGMainViewFriendRecommandationGridView : UIView {
    IBOutlet UIView*        headView;
    IBOutlet UIImageView*   headLogoImageView;
    IBOutlet UIImageView*   headBackgroundImageView;
    IBOutlet UILabel*       headTitleLabel;
    IBOutlet UIButton*      headActionButton;
    IBOutlet UIView*        contentView;
    IBOutlet UIImageView* backgroundImageView;
    
    id<HGMainViewRecommandationGridViewDelegate> delegate;
    NSArray* recommandations;
}

@property (nonatomic, assign) id<HGMainViewRecommandationGridViewDelegate> delegate;
@property (nonatomic, retain) NSArray* recommandations;

+ (HGMainViewFriendRecommandationGridView*)mainViewRecommandationGridView;
@end

@protocol HGMainViewRecommandationGridViewDelegate <NSObject>
- (void)mainViewRecommandationGridView:(HGMainViewFriendRecommandationGridView *)mainViewRecommandationGridView didSelectRecommandations:(NSArray*)recommandations;

- (void)mainViewRecommandationGridView:(HGMainViewFriendRecommandationGridView *)mainViewRecommandationGridView didSelectRecommandation:(HGFriendRecommandation*)recommandation;
@end