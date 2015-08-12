//
//  HGGIFGiftListViewRowView.m
//  HappyGift
//
//  Created by Yujian Weng on 12-7-27.
//  Copyright 2011 Ztelic Inc Inc. All rights reserved.
//


#import <UIKit/UIKit.h>
@class HGGIFGift;
@protocol HGGIFGiftListViewRowViewDelegate;

@interface HGGIFGiftListViewRowView: UITableViewCell {
    NSArray* gifGifts;
    NSArray* gifGiftViews;
    id<HGGIFGiftListViewRowViewDelegate> delegate;
}
@property (nonatomic, retain) NSArray* gifGiftViews;
@property (nonatomic, retain) NSArray* gifGifts;
@property (nonatomic, assign) id<HGGIFGiftListViewRowViewDelegate> delegate;
@end

@protocol HGGIFGiftListViewRowViewDelegate <NSObject>

- (void)handleGIGGiftSelected:(HGGIFGift*)gifGift;

@end