//
//  HGMainViewFriendEmotionGridView.h
//  HappyGift
//
//  Created by Yujian Weng on 12-7-10.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HGFriendEmotion;

@protocol HGMainViewFriendEmotionGridViewDelegate;

@interface HGMainViewFriendEmotionGridView : UIView {
    IBOutlet UIView*        headView;
    IBOutlet UIImageView*   headLogoImageView;
    IBOutlet UIImageView*   headBackgroundImageView;
    IBOutlet UILabel*       headTitleLabel;
    IBOutlet UIButton*      headActionButton;
    IBOutlet UIView*        contentView;
    IBOutlet UIImageView* backgroundImageView;
    
    id<HGMainViewFriendEmotionGridViewDelegate> delegate;
    NSArray* friendEmotions;
}

@property (nonatomic, assign) id<HGMainViewFriendEmotionGridViewDelegate> delegate;
@property (nonatomic, retain) NSArray* friendEmotions;

+ (HGMainViewFriendEmotionGridView*)mainViewFriendEmotionGridView;
@end

@protocol HGMainViewFriendEmotionGridViewDelegate <NSObject>
- (void)mainViewFriendEmotionGridView:(HGMainViewFriendEmotionGridView *)mainViewFriendEmotionGridView didSelectFriendEmotions:(NSArray*)friendEmotions;

- (void)mainViewFriendEmotionGridView:(HGMainViewFriendEmotionGridView *)mainViewFriendEmotionGridView didSelectFriendEmotion:(HGFriendEmotion*)friendEmotion;
@end