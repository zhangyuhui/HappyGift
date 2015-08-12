//
//  HGOccasionsDetailViewListRowView.m
//  HappyGift
//
//  Created by Yujian Weng on 12-6-3.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//

#import "HGOccasionsDetailViewListRowView.h"
#import "HGOccasionDetailViewListItemView.h"
#import "HGGift.h"
#import "HGTrackingService.h"
#import "HGGiftDetailViewController.h"

@implementation HGOccasionsDetailViewListRowView
@synthesize giftSetViews;
@synthesize giftSets;
@synthesize delegate;

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initSubViews];
    }
    
    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initSubViews];
    }
    return self;
}

-(void) initSubViews {
    HGOccasionDetailViewListItemView* leftCellView = [HGOccasionDetailViewListItemView occasionDetailViewListItemView];
    CGRect tmpFrame = leftCellView.frame;
    tmpFrame.origin.x = 0.0;
    tmpFrame.origin.y = 10.0;
    leftCellView.frame = tmpFrame;
    
    [leftCellView addTarget:self action:@selector(handleOccasionDetailViewListItemViewAction:) forControlEvents:UIControlEventTouchUpInside];
    
    HGOccasionDetailViewListItemView* rightCellView = [HGOccasionDetailViewListItemView occasionDetailViewListItemView];
    tmpFrame = rightCellView.frame;
    tmpFrame.origin.x = leftCellView.frame.origin.x + leftCellView.frame.size.width + 10.0;
    tmpFrame.origin.y = 10.0;
    rightCellView.frame = tmpFrame;
    
    [rightCellView addTarget:self action:@selector(handleOccasionDetailViewListItemViewAction:) forControlEvents:UIControlEventTouchUpInside];
        
    giftSetViews = [[NSArray arrayWithObjects:leftCellView, rightCellView, nil] retain];
    self.contentView.frame = CGRectMake(0, 0, 300, 195);
    [self.contentView addSubview:leftCellView];
    [self.contentView addSubview:rightCellView];
}

- (void)layoutSubviews {
	[super layoutSubviews];
}

- (void)dealloc{
    [giftSets release];
    [giftSetViews release];
    [super dealloc];
}

- (void)setGiftSets:(NSArray *)theGiftSets {
    if (giftSets != theGiftSets){
        if (giftSets != nil){
            [giftSets release];
            giftSets = nil;
        }
        giftSets = [theGiftSets retain];
    }
   
    if (giftSets != nil) {
        int count = [giftSets count];
        for (int i = 0; i < count; ++i) {
            HGOccasionDetailViewListItemView* view = [giftSetViews objectAtIndex:i];
            view.giftSet = [giftSets objectAtIndex:i];
            view.hidden = NO;
        }
        int viewCount = [giftSetViews count];
        for (int i = count; i < viewCount; ++i) {
            HGOccasionDetailViewListItemView* view = [giftSetViews objectAtIndex:i];
            view.hidden = YES;
        }
    }
}

- (void)handleOccasionDetailViewListItemViewAction:(id)sender{
    HGOccasionDetailViewListItemView* occasionDetailViewListItemView = (HGOccasionDetailViewListItemView*)sender;
    if ([delegate respondsToSelector:@selector(handleOccasionsDetailViewListRowViewGiftSelected:)]) {
        [delegate handleOccasionsDetailViewListRowViewGiftSelected:occasionDetailViewListItemView.giftSet];
    }
}
@end
