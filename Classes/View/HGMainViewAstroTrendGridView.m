//
//  HGMainViewAstroTrendGridView.h
//  HappyGift
//
//  Created by Yujian Weng on 12-7-4.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//

#import "HGMainViewAstroTrendGridView.h"
#import "HGGift.h"
#import "HGMainViewAstroTrendGridViewItemView.h"
#import "HGTrackingService.h"
#import <QuartzCore/QuartzCore.h>
#import "HGDefines.h"
#import "HGAstroTrend.h"
#import "HappyGiftAppDelegate.h"

#define kMainViewGiftCollectionItemViewSpacing 10.0
#define kMainViewGiftCollectionItemViewVerticalSpacing 5.0

@interface HGMainViewAstroTrendGridView()
-(void)initSubViews;
@end

@implementation HGMainViewAstroTrendGridView
@synthesize astroTrends;
@synthesize delegate;

- (void)awakeFromNib {
	[self initSubViews];
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
		[self initSubViews];
    }
    return self;
}

- (void)initSubViews{
    [headActionButton addTarget:self action:@selector(handleHeadActionClick:) forControlEvents:UIControlEventTouchUpInside];
    [headActionButton addTarget:self action:@selector(handleHeadActionDown:) forControlEvents:UIControlEventTouchDown];
    [headActionButton addTarget:self action:@selector(handleHeadActionUp:) forControlEvents:UIControlEventTouchUpInside|UIControlEventTouchUpOutside|UIControlEventTouchCancel];    
}

- (void)dealloc{
    [headView release];
    [headLogoImageView release];
    [headBackgroundImageView release];
    [headTitleLabel release];
    [headActionButton release];
    [contentView release];
    [astroTrends release];
    [super dealloc];
}

+ (HGMainViewAstroTrendGridView*)mainViewAstroTrendGridView{
    NSArray* nibViews = [[NSBundle mainBundle] loadNibNamed:@"HGMainViewAstroTrendGridView"
                                                      owner:self
                                                    options:nil];
    return [nibViews objectAtIndex:0];    
}

- (void)setAstroTrends:(NSArray *)theAstroTrends {
    if (astroTrends != theAstroTrends){
        [astroTrends release];
        astroTrends = [theAstroTrends retain];
    }
    
    // update UI in case that some orders has been changed
    headTitleLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:[HappyGiftAppDelegate fontSizeLarge]];
    headTitleLabel.textColor = UIColorFromRGB(0xde5a1b);
    headTitleLabel.text = @"星座运势";
    
    NSArray* subviews = [contentView subviews];
    for (UIView* subview in subviews) {
        [subview removeFromSuperview];
    }
    
    if (astroTrends != nil) {
        CGFloat itemViewX = kMainViewGiftCollectionItemViewSpacing;
        CGFloat itemViewY = kMainViewGiftCollectionItemViewVerticalSpacing;
        int columnCount = 3;
        int displayCount = 6;
        if ([astroTrends count] == 4) {
            displayCount = 3;
        }
        
        CGRect contentFrame = contentView.frame;
        contentView.autoresizesSubviews = NO;
       
        int giftSetIndex = 0;
        for (HGAstroTrend* astroTrend in astroTrends) {
            HGMainViewAstroTrendGridViewItemView* itemView = [HGMainViewAstroTrendGridViewItemView mainViewAstroTrendGridViewItemView];
            
            itemView.astroTrend = astroTrend;
           
            CGRect itemViewFrame = itemView.frame;
            itemViewFrame.origin.x = itemViewX;
            itemViewFrame.origin.y = itemViewY;
            itemView.frame = itemViewFrame;
            
            [itemView addTarget:self action:@selector(handleAstroTrendGridViewItemView:) forControlEvents:UIControlEventTouchUpInside];
            
            [contentView addSubview:itemView];
            
            contentFrame.size.height = itemViewY + itemViewFrame.size.height + kMainViewGiftCollectionItemViewSpacing;
            
            itemView.tag = giftSetIndex++;
            
            if (giftSetIndex % columnCount == 0) {
                itemViewX = kMainViewGiftCollectionItemViewSpacing;
                itemViewY += itemViewFrame.size.height + kMainViewGiftCollectionItemViewVerticalSpacing;
            } else {
                itemViewX += itemViewFrame.size.width + kMainViewGiftCollectionItemViewSpacing;
            }
            if (giftSetIndex == displayCount) {
                break;
            }
        }
        
        contentView.frame = contentFrame;
        CGRect backgroundFrame = backgroundImageView.frame;
        backgroundFrame.size.height = contentFrame.size.height;
        backgroundImageView.frame = backgroundFrame;
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width,
                                contentFrame.size.height + headView.frame.size.height);
    }
}

- (void)handleHeadActionClick:(id)sender{
    if ([delegate respondsToSelector:@selector(mainViewAstroTrendGridView:didSelectAstroTrends:)]){
        [delegate mainViewAstroTrendGridView:self didSelectAstroTrends:astroTrends];
    }
}

- (void)handleHeadActionDown:(id)sender{
    headBackgroundImageView.highlighted = YES;
}

- (void)handleHeadActionUp:(id)sender {
    headBackgroundImageView.highlighted = NO;
}

- (void)handleAstroTrendGridViewItemView:(id)sender {
    HGMainViewAstroTrendGridViewItemView* itemView = (HGMainViewAstroTrendGridViewItemView*)sender;
    if ([delegate respondsToSelector:@selector(mainViewAstroTrendGridView:didSelectAstroTrend:)]){
        [delegate mainViewAstroTrendGridView:self didSelectAstroTrend:itemView.astroTrend];
    }
}


@end
