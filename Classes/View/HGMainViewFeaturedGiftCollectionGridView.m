//
//  HGMainViewFeaturedGiftCollectionGridView.m
//  HappyGift
//
//  Created by Yujian Weng on 12-6-10.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//

#import "HGMainViewFeaturedGiftCollectionGridView.h"
#import "HGGift.h"
#import "HGFeaturedGiftCollection.h"
#import "HGMainViewFeaturedGiftCollectionGridViewItemView.h"
#import "HGGiftCollectionService.h"
#import "HGTrackingService.h"
#import "HGGiftSet.h"
#import <QuartzCore/QuartzCore.h>
#import "HGDefines.h"
#import "HappyGiftAppDelegate.h"
#import "HGVirtualGiftsView.h"

#define kMainViewGiftCollectionItemViewSpacing 10.0
#define kMainViewGiftCollectionItemViewVerticalSpacing 10.0

@interface HGMainViewFeaturedGiftCollectionGridView()
-(void)initSubViews;
@end

@implementation HGMainViewFeaturedGiftCollectionGridView
@synthesize giftCollection;
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
    [headBackgroundImageView release];
    [headTitleLabel release];
    [headActionButton release];
    [contentView release];
    [giftCollection release];
    [super dealloc];
}

+ (HGMainViewFeaturedGiftCollectionGridView*)mainViewFeaturedGiftCollectionGridView{
    NSArray* nibViews = [[NSBundle mainBundle] loadNibNamed:@"HGMainViewFeaturedGiftCollectionGridView"
                                                      owner:self
                                                    options:nil];
    return [nibViews objectAtIndex:0];    
}

- (void)setGiftCollection:(HGFeaturedGiftCollection *)theGiftCollection {
    if (giftCollection != theGiftCollection){
        [giftCollection release];
        giftCollection = [theGiftCollection retain];
        
        headTitleLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:[HappyGiftAppDelegate fontSizeLarge]];
        headTitleLabel.text = @"人气推荐";
        headTitleLabel.textColor = UIColorFromRGB(0x935308);
        
        if (giftCollection != nil) {
            const CGFloat leftPadding = 12.0;
            const CGFloat topPadding = 10.0;
            const CGFloat bottomPadding = 12.0;
            
            CGFloat itemViewX = leftPadding;
            CGFloat itemViewY = topPadding;
            int columnCount = 2;
            
            CGRect contentFrame = contentView.frame;
            contentView.autoresizesSubviews = NO;
            
            
            HGVirtualGiftsView* gifGiftView = [HGVirtualGiftsView virtualGiftsView];
            CGRect gifGiftViewFrame = gifGiftView.frame;
            gifGiftViewFrame.origin.x = itemViewX - 3.0;
            gifGiftViewFrame.origin.y = itemViewY;
            gifGiftView.frame = gifGiftViewFrame;
            gifGiftView.titleLabel.text = @"虚拟礼物";
            gifGiftView.coverImageView.image = [UIImage imageNamed:@"virtual_gift_gif_gift"];
            [gifGiftView addTarget:self action:@selector(handleGIFGiftViewAction:) forControlEvents:UIControlEventTouchUpInside];
            
            HGVirtualGiftsView* diyGiftView = [HGVirtualGiftsView virtualGiftsView];
            CGRect diyGiftViewFrame = diyGiftView.frame;
            diyGiftViewFrame.origin.x = gifGiftView.frame.origin.x + gifGiftView.frame.size.width + kMainViewGiftCollectionItemViewSpacing - 5.0;
            diyGiftViewFrame.origin.y = itemViewY;
            diyGiftView.frame = diyGiftViewFrame;
            diyGiftView.titleLabel.text = @"自制礼物";
            diyGiftView.coverImageView.image = [UIImage imageNamed:@"virtual_gift_diy_gift"];
            [diyGiftView addTarget:self action:@selector(handleDIYGiftViewAction:) forControlEvents:UIControlEventTouchUpInside];
            
            [contentView addSubview:gifGiftView];
            [contentView addSubview:diyGiftView];
            
            itemViewY += gifGiftViewFrame.size.height + kMainViewGiftCollectionItemViewVerticalSpacing;
            
            int giftSetIndex = 0;
            for (HGGiftSet* giftSet in giftCollection.giftSets) {
                HGMainViewFeaturedGiftCollectionGridViewItemView* featuredGiftCollectionGridViewItemView = [HGMainViewFeaturedGiftCollectionGridViewItemView mainViewFeaturedGiftCollectionGridViewItemView];
                
               
                CGRect FeaturedGiftCollectionItemViewFrame = featuredGiftCollectionGridViewItemView.frame;
                FeaturedGiftCollectionItemViewFrame.origin.x = itemViewX;
                FeaturedGiftCollectionItemViewFrame.origin.y = itemViewY;
                featuredGiftCollectionGridViewItemView.frame = FeaturedGiftCollectionItemViewFrame;
                
                
                [featuredGiftCollectionGridViewItemView addTarget:self action:@selector(handleFeaturedGiftCollectionGridViewItemView:) forControlEvents:UIControlEventTouchUpInside];
                
                [contentView addSubview:featuredGiftCollectionGridViewItemView];
                
                contentFrame.size.height = itemViewY + FeaturedGiftCollectionItemViewFrame.size.height + bottomPadding;
                
                featuredGiftCollectionGridViewItemView.giftSet = giftSet;
                featuredGiftCollectionGridViewItemView.tag = giftSetIndex;
                
                ++giftSetIndex;
                
                if (giftSetIndex % columnCount == 0) {
                    itemViewX = leftPadding;
                    itemViewY += FeaturedGiftCollectionItemViewFrame.size.height + kMainViewGiftCollectionItemViewVerticalSpacing;
                } else {
                    itemViewX += FeaturedGiftCollectionItemViewFrame.size.width + kMainViewGiftCollectionItemViewSpacing;
                }
                if (giftSetIndex == 4) {
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
}

- (void)handleHeadActionClick:(id)sender{
    if ([delegate respondsToSelector:@selector(mainViewFeaturedGiftCollectionGridView:didSelectFeaturedGiftCollection:)]){
        [delegate mainViewFeaturedGiftCollectionGridView:self didSelectFeaturedGiftCollection:giftCollection];
    }
}

- (void)handleHeadActionDown:(id)sender{
    headBackgroundImageView.highlighted = YES;
}

- (void)handleHeadActionUp:(id)sender{
    headBackgroundImageView.highlighted = NO;
}

- (void)handleFeaturedGiftCollectionGridViewItemView:(id)sender{
    HGMainViewFeaturedGiftCollectionGridViewItemView* featuredGiftCollectionItemView = (HGMainViewFeaturedGiftCollectionGridViewItemView*)sender;
    
    if ([featuredGiftCollectionItemView.giftSet.gifts count] == 1) {
        HGGift* theGift = [featuredGiftCollectionItemView.giftSet.gifts objectAtIndex:0];
        [HGTrackingService logEvent:kTrackingEventSelectFeaturedGiftOccasion withParameters:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", featuredGiftCollectionItemView.tag], @"index", theGift.identifier, @"productId", nil]];
    } else {
        [HGTrackingService logEvent:kTrackingEventSelectFeaturedGiftOccasion withParameters:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", featuredGiftCollectionItemView.tag], @"index", nil]];
    }
    
    if ([delegate respondsToSelector:@selector(mainViewFeaturedGiftCollectionGridView:didSelectFeaturedGiftSet:)]){
        [delegate mainViewFeaturedGiftCollectionGridView:self didSelectFeaturedGiftSet:featuredGiftCollectionItemView.giftSet];
    }
}

- (void)handleGIFGiftViewAction:(id)sender {
    if ([delegate respondsToSelector:@selector(mainViewVirtualGiftGridViewDidSelectGIFGifts:)]){
        [delegate mainViewFeaturedGiftCollectionGridViewDidSelectGIFGifts:self];
    }
}

- (void)handleDIYGiftViewAction:(id)sender {
    if ([delegate respondsToSelector:@selector(mainViewVirtualGiftGridViewDidSelectDIYGifts:)]){
        [delegate mainViewFeaturedGiftCollectionGridViewDidSelectDIYGifts:self];
    }
}

@end
