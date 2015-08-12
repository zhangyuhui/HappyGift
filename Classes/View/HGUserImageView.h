//
//  HGRecipientSelectionViewCellView.h
//  HappyGift
//
//  Created by Yujian Weng on 12-5-30.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HGRecipient;
@class HGAstroTrend;
@class HGGiftOccasion;
@class HGFriendEmotion;

@interface HGUserImageView : UIView {
    UIImageView* imageView;
    UIImageView* tagImageView;
    UIImageView* backgroundImageView;
    HGRecipient* recipient;
}

@property (nonatomic, retain) UIImageView*  imageView;
@property (nonatomic, retain) UIImageView*  tagImageView;
@property (nonatomic, retain) UIImageView*  backgroundImageView;

- (void) updateUserImageView: (UIImage *)imageData;
- (void) updateUserImageViewWithRecipient: (HGRecipient *)theRecipient;
- (void) updateUserImageViewWithOccasion:(HGGiftOccasion*) theOccsaion;
- (void) updateUserImageViewWithAstroTrend:(HGAstroTrend*) astroTrend;
- (void) updateUserImageViewWithFriendEmotion:(HGFriendEmotion*) theEmotion;
- (void) removeTagImage;

@end