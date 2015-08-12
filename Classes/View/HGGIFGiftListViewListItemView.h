//
//  HGGIFGiftListViewListItemView.m
//  HappyGift
//
//  Created by Yujian Weng on 12-7-27.
//  Copyright 2011 Ztelic Inc Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HGGIFGift;

@interface HGGIFGiftListViewListItemView : UIControl{
    IBOutlet UIImageView* coverImageView;
    IBOutlet UILabel*     titleLabel;
    IBOutlet UILabel*     descriptionLabel;
    IBOutlet UIView*      overLayView;
    
    HGGIFGift* gifGift;
    NSTimer* highlightTimer;
}
@property(nonatomic, retain) HGGIFGift* gifGift;
    
+ (HGGIFGiftListViewListItemView*)gifGiftListViewListItemView;
@end
