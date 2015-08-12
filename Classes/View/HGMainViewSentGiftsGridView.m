//
//  HGMainViewSentGiftsGridView.h
//  HappyGift
//
//  Created by Yujian Weng on 12-6-10.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//

#import "HGMainViewSentGiftsGridView.h"
#import "HGGift.h"
#import "HGGiftOccasion.h"
#import "HGOccasionGiftCollection.h"
#import "HGMainViewSentGiftsGridViewItemView.h"
#import "HGGiftCollectionService.h"
#import "HGTrackingService.h"
#import <QuartzCore/QuartzCore.h>
#import "HGOccasionCategory.h"
#import "HGDefines.h"
#import "HappyGiftAppDelegate.h"

#define kMainViewGiftCollectionItemViewSpacing 10.0
#define kMainViewGiftCollectionItemViewVerticalSpacing 5.0

@interface HGMainViewSentGiftsGridView()
-(void)initSubViews;
@end

@implementation HGMainViewSentGiftsGridView
@synthesize giftOrders;
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
    [giftOrders release];
    [super dealloc];
}

+ (HGMainViewSentGiftsGridView*)mainViewSentGiftsGridView{
    NSArray* nibViews = [[NSBundle mainBundle] loadNibNamed:@"HGMainViewSentGiftsGridView"
                                                      owner:self
                                                    options:nil];
    return [nibViews objectAtIndex:0];    
}

- (void)setGiftOrders:(NSArray *)theGiftOrders {
    if (giftOrders != theGiftOrders){
        [giftOrders release];
        giftOrders = [theGiftOrders retain];
        
    }
    
    // update UI in case that some orders has been changed
    headTitleLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:[HappyGiftAppDelegate fontSizeLarge]];
    headTitleLabel.text = @"已送出的礼物";
    headTitleLabel.textColor = UIColorFromRGB(0xe23974);
    
    NSArray* subviews = [contentView subviews];
    for (UIView* subview in subviews) {
        [subview removeFromSuperview];
    }
    
    if (giftOrders != nil) {
        CGFloat itemViewX = kMainViewGiftCollectionItemViewSpacing;
        CGFloat itemViewY = kMainViewGiftCollectionItemViewVerticalSpacing;
        int columnCount = 3;
        
        CGRect contentFrame = contentView.frame;
        contentView.autoresizesSubviews = NO;
       
        int giftSetIndex = 0;
        for (HGGiftOrder* giftOrder in giftOrders) {
            HGMainViewSentGiftsGridViewItemView* sentGiftsGridViewItemView = [HGMainViewSentGiftsGridViewItemView mainViewSentGiftsGridViewItemView];
            
            sentGiftsGridViewItemView.giftOrder = giftOrder;
           
            CGRect sentGiftsItemViewFrame = sentGiftsGridViewItemView.frame;
            sentGiftsItemViewFrame.origin.x = itemViewX;
            sentGiftsItemViewFrame.origin.y = itemViewY;
            sentGiftsGridViewItemView.frame = sentGiftsItemViewFrame;
            
            [sentGiftsGridViewItemView addTarget:self action:@selector(handleSentGiftsGridViewItemView:) forControlEvents:UIControlEventTouchUpInside];
            
            [contentView addSubview:sentGiftsGridViewItemView];
            
            contentFrame.size.height = itemViewY + sentGiftsItemViewFrame.size.height + kMainViewGiftCollectionItemViewSpacing;
            
            sentGiftsGridViewItemView.tag = giftSetIndex++;
            
            if (giftSetIndex % columnCount == 0) {
                itemViewX = kMainViewGiftCollectionItemViewSpacing;
                itemViewY += sentGiftsItemViewFrame.size.height + kMainViewGiftCollectionItemViewVerticalSpacing;
            } else {
                itemViewX += sentGiftsItemViewFrame.size.width + kMainViewGiftCollectionItemViewSpacing;
            }
            if (giftSetIndex == 3) {
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
    if ([delegate respondsToSelector:@selector(mainViewSentGiftsGridView:didSelectSentGiftOrders:)]){
        [delegate mainViewSentGiftsGridView:self didSelectSentGiftOrders:giftOrders];
    }
}

- (void)handleHeadActionDown:(id)sender{
    headBackgroundImageView.highlighted = YES;
}

- (void)handleHeadActionUp:(id)sender {
    headBackgroundImageView.highlighted = NO;
}

- (void)handleSentGiftsGridViewItemView:(id)sender {
    HGMainViewSentGiftsGridViewItemView* mainViewSentGiftsItemView = (HGMainViewSentGiftsGridViewItemView*)sender;
    if ([delegate respondsToSelector:@selector(mainViewSentGiftsGridView:didSelectSentGiftOrder:)]){
        [delegate mainViewSentGiftsGridView:self didSelectSentGiftOrder:mainViewSentGiftsItemView.giftOrder];
    }
}


@end
