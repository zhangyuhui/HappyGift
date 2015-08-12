//
//  HGOccasionsListViewRowView.h
//  HappyGift
//
//  Created by Yujian Weng on 12-6-3.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HGGiftSet;
@protocol HGOccasionsDetailViewListRowViewDelegate;

@interface HGOccasionsDetailViewListRowView : UITableViewCell {
    NSArray* giftSets;
    NSArray* giftSetViews;
    id<HGOccasionsDetailViewListRowViewDelegate> delegate;
}
@property (nonatomic, retain) NSArray* giftSetViews;
@property (nonatomic, retain) NSArray* giftSets;
@property (nonatomic, assign) id<HGOccasionsDetailViewListRowViewDelegate> delegate;
@end

@protocol HGOccasionsDetailViewListRowViewDelegate <NSObject>

- (void)handleOccasionsDetailViewListRowViewGiftSelected:(HGGiftSet*)giftSet;

@end