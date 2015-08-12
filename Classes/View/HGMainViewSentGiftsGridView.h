//
//  HGMainViewSentGiftsGridView.h
//  HappyGift
//
//  Created by Yujian Weng on 12-6-10.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HGGiftOrder;

@protocol HGMainViewSentGiftsGridViewDelegate;

@interface HGMainViewSentGiftsGridView : UIView {
    IBOutlet UIView*        headView;
    IBOutlet UIImageView*   headLogoImageView;
    IBOutlet UIImageView*   headBackgroundImageView;
    IBOutlet UILabel*       headTitleLabel;
    IBOutlet UIButton*      headActionButton;
    IBOutlet UIView*        contentView;
    IBOutlet UIImageView* backgroundImageView;
    
    id<HGMainViewSentGiftsGridViewDelegate> delegate;
    NSArray* giftOrders;
}
@property (nonatomic, assign) id<HGMainViewSentGiftsGridViewDelegate> delegate;
@property (nonatomic, retain) NSArray* giftOrders;

+ (HGMainViewSentGiftsGridView*)mainViewSentGiftsGridView;
@end

@protocol HGMainViewSentGiftsGridViewDelegate <NSObject>
- (void)mainViewSentGiftsGridView:(HGMainViewSentGiftsGridView *)mainViewSentGiftsGridView didSelectSentGiftOrders:(NSArray*)giftOrders;
- (void)mainViewSentGiftsGridView:(HGMainViewSentGiftsGridView *)mainViewSentGiftsGridView didSelectSentGiftOrder:(HGGiftOrder*)giftOrder;
@end