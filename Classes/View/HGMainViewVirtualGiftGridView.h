//
//  HGMainViewVirtualGiftGridView.h
//  HappyGift
//
//  Created by Yujian Weng on 12-6-10.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol HGMainViewVirtualGiftGridViewDelegate;

@interface HGMainViewVirtualGiftGridView : UIView {
    IBOutlet UIView*        headView;
    IBOutlet UIImageView*   headBackgroundImageView;
    IBOutlet UILabel*       headTitleLabel;
    IBOutlet UIButton*      headActionButton;
    IBOutlet UIView*        contentView;
    IBOutlet UIImageView*   backgroundImageView;
    
    id<HGMainViewVirtualGiftGridViewDelegate> delegate;
}
@property (nonatomic, assign) id<HGMainViewVirtualGiftGridViewDelegate> delegate;

+ (HGMainViewVirtualGiftGridView*)mainViewVirtualGiftGridView;
@end

@protocol HGMainViewVirtualGiftGridViewDelegate <NSObject>
- (void)mainViewVirtualGiftGridViewDidSelectMoreGifts:(HGMainViewVirtualGiftGridView*)mainViewVirtualGiftGridView;
- (void)mainViewVirtualGiftGridViewDidSelectGIFGifts:(HGMainViewVirtualGiftGridView*)mainViewVirtualGiftGridView;
- (void)mainViewVirtualGiftGridViewDidSelectDIYGifts:(HGMainViewVirtualGiftGridView*)mainViewVirtualGiftGridView;
@end