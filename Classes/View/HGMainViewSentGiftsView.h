//
//  HGMainViewSentGiftsView.h
//  HappyGift
//
//  Created by Yuhui Zhang on 7/20/11.
//  Copyright 2011 Ztelic Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HGPageControl;
@class HGGift;
@class HGGiftOrder;
@protocol HGMainViewSentGiftsViewDelegate;

@interface HGMainViewSentGiftsView : UIView {
    IBOutlet UIView*        headView;
    IBOutlet UIImageView*   headLogoImageView;
    IBOutlet UIImageView*   headBackgroundImageView;
    IBOutlet UILabel*       headTitleLabel;
    IBOutlet UIButton*      headActionButton;
    IBOutlet UIScrollView*  contentScrollView;
    IBOutlet HGPageControl* pageControl;
    
    id<HGMainViewSentGiftsViewDelegate> delegate;
    NSArray* giftOrders;
    NSMutableArray* contentScrollSubViews;
    
    CGFloat dragOffsetX;
    NSTimeInterval dragOffsetInterval;
    int     dragoffsetSpeed;
}
@property (nonatomic, assign) id<HGMainViewSentGiftsViewDelegate> delegate;
@property (nonatomic, retain) NSArray* giftOrders;

+ (HGMainViewSentGiftsView*)mainViewSentGiftsView;
@end

@protocol HGMainViewSentGiftsViewDelegate <NSObject>
- (void)mainViewSentGiftsView:(HGMainViewSentGiftsView *)mainViewSentGiftsView didSelectSentGiftOrders:(NSArray*)giftOrders;
- (void)mainViewSentGiftsView:(HGMainViewSentGiftsView *)mainViewSentGiftsView didSelectSentGiftOrder:(HGGiftOrder*)giftOrder;
@end