//
//  HGGIFGiftListViewRowView.m
//  HappyGift
//
//  Created by Yujian Weng on 12-7-27.
//  Copyright 2011 Ztelic Inc Inc. All rights reserved.
//

#import "HGGIFGiftListViewRowView.h"
#import "HGGIFGiftListViewListItemView.h"
#import "HGGift.h"
#import "HGTrackingService.h"
#import "HGGiftDetailViewController.h"

@implementation HGGIFGiftListViewRowView
@synthesize gifGiftViews;
@synthesize gifGifts;
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
    HGGIFGiftListViewListItemView* leftCellView = [HGGIFGiftListViewListItemView gifGiftListViewListItemView];
    CGRect tmpFrame = leftCellView.frame;
    tmpFrame.origin.x = 0.0;
    tmpFrame.origin.y = 5.0;
    leftCellView.frame = tmpFrame;
    
    [leftCellView addTarget:self action:@selector(handleGIFGiftListViewListItemViewAction:) forControlEvents:UIControlEventTouchUpInside];
    
    HGGIFGiftListViewListItemView* midCellView = [HGGIFGiftListViewListItemView gifGiftListViewListItemView];
    tmpFrame = midCellView.frame;
    tmpFrame.origin.x = leftCellView.frame.origin.x + leftCellView.frame.size.width;
    tmpFrame.origin.y = 5.0;
    midCellView.frame = tmpFrame;
    
    [midCellView addTarget:self action:@selector(handleGIFGiftListViewListItemViewAction:) forControlEvents:UIControlEventTouchUpInside];
    
    HGGIFGiftListViewListItemView* rightCellView = [HGGIFGiftListViewListItemView gifGiftListViewListItemView];
    tmpFrame = rightCellView.frame;
    tmpFrame.origin.x = midCellView.frame.origin.x + midCellView.frame.size.width;
    tmpFrame.origin.y = 5.0;
    rightCellView.frame = tmpFrame;
    
    [rightCellView addTarget:self action:@selector(handleGIFGiftListViewListItemViewAction:) forControlEvents:UIControlEventTouchUpInside];
        
    gifGiftViews = [[NSArray arrayWithObjects:leftCellView, midCellView, rightCellView, nil] retain];
    self.contentView.frame = CGRectMake(0, 0, 300, 120);
    [self.contentView addSubview:leftCellView];
    [self.contentView addSubview:midCellView];
    [self.contentView addSubview:rightCellView];
}

- (void)layoutSubviews {
	[super layoutSubviews];
}

- (void)dealloc{
    [gifGifts release];
    [gifGiftViews release];
    [super dealloc];
}

- (void)setGifGifts:(NSArray *)theGifGifts {
    if (gifGifts != theGifGifts){
        if (gifGifts != nil){
            [gifGifts release];
            gifGifts = nil;
        }
        gifGifts = [theGifGifts retain];
    }
   
    if (gifGifts != nil) {
        int count = [gifGifts count];
        for (int i = 0; i < count; ++i) {
            HGGIFGiftListViewListItemView* view = [gifGiftViews objectAtIndex:i];
            view.gifGift = [gifGifts objectAtIndex:i];
            view.hidden = NO;
        }
        int viewCount = [gifGiftViews count];
        for (int i = count; i < viewCount; ++i) {
            HGGIFGiftListViewListItemView* view = [gifGiftViews objectAtIndex:i];
            view.hidden = YES;
        }
    }
}

- (void)handleGIFGiftListViewListItemViewAction:(id)sender{
    HGGIFGiftListViewListItemView* view = (HGGIFGiftListViewListItemView*)sender;
    if ([delegate respondsToSelector:@selector(handleGIGGiftSelected:)]) {
        [delegate handleGIGGiftSelected:view.gifGift];
    }
}
@end
