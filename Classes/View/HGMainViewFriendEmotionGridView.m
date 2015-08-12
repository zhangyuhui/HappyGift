//
//  HGMainViewFriendEmotionGridView.h
//  HappyGift
//
//  Created by Yujian Weng on 12-7-10.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//

#import "HGMainViewFriendEmotionGridView.h"
#import "HGGift.h"
#import "HGMainViewAstroTrendGridViewItemView.h"
#import "HGTrackingService.h"
#import <QuartzCore/QuartzCore.h>
#import "HGDefines.h"
#import "HGFriendEmotion.h"
#import "HappyGiftAppDelegate.h"
#import "HGRecipient.h"
#import "HGUserImageView.h"

#define kMainViewGiftCollectionItemViewSpacing 10.0
#define kMainViewGiftCollectionItemViewVerticalSpacing 5.0

@interface HGMainViewFriendEmotionGridView()
-(void)initSubViews;
@end

@implementation HGMainViewFriendEmotionGridView
@synthesize friendEmotions;
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
    [friendEmotions release];
    [super dealloc];
}

+ (HGMainViewFriendEmotionGridView*)mainViewFriendEmotionGridView {
    NSArray* nibViews = [[NSBundle mainBundle] loadNibNamed:@"HGMainViewFriendEmotionGridView"
                                                      owner:self
                                                    options:nil];
    return [nibViews objectAtIndex:0];    
}

- (void)setFriendEmotions:(NSArray *)theFriendEmotions {
    if (friendEmotions != theFriendEmotions){
        [friendEmotions release];
        friendEmotions = [theFriendEmotions retain];
    }
    
    // update UI in case that some orders has been changed
    headTitleLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:[HappyGiftAppDelegate fontSizeLarge]];
    headTitleLabel.textColor = UIColorFromRGB(0xd50247);
    headTitleLabel.text = @"正能量，负能量";
    
    NSArray* subviews = [contentView subviews];
    for (UIView* subview in subviews) {
        [subview removeFromSuperview];
    }
    
    if (friendEmotions != nil) {
        CGFloat itemViewX = kMainViewGiftCollectionItemViewSpacing;
        CGFloat itemViewY = kMainViewGiftCollectionItemViewVerticalSpacing;
        int columnCount = 3;
        int displayCount = 3;
        
        CGRect contentFrame = contentView.frame;
        contentView.autoresizesSubviews = NO;
       
        /*if ([friendEmotions count] == 4) {
            displayCount = 3;
        }*/
        
        int giftSetIndex = 0;
        for (HGFriendEmotion* friendEmotion in friendEmotions) {
            HGMainViewAstroTrendGridViewItemView* itemView = [HGMainViewAstroTrendGridViewItemView mainViewAstroTrendGridViewItemView];
            
            itemView.recipientNameLabel.text = friendEmotion.recipient.recipientName;
            [itemView.recipientImageView updateUserImageViewWithFriendEmotion:friendEmotion];
            
            CGRect itemViewFrame = itemView.frame;
            itemViewFrame.origin.x = itemViewX;
            itemViewFrame.origin.y = itemViewY;
            itemView.frame = itemViewFrame;
            
            [itemView addTarget:self action:@selector(handleFriendEmotionGridViewItemView:) forControlEvents:UIControlEventTouchUpInside];
            
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
    if ([delegate respondsToSelector:@selector(mainViewFriendEmotionGridView:didSelectFriendEmotions:)]){
        [delegate mainViewFriendEmotionGridView:self didSelectFriendEmotions:friendEmotions];
    }
}

- (void)handleHeadActionDown:(id)sender{
    headBackgroundImageView.highlighted = YES;
}

- (void)handleHeadActionUp:(id)sender {
    headBackgroundImageView.highlighted = NO;
}

- (void)handleFriendEmotionGridViewItemView:(id)sender {
    if ([delegate respondsToSelector:@selector(mainViewFriendEmotionGridView:didSelectFriendEmotion:)]) {
        HGMainViewAstroTrendGridViewItemView* itemView = (HGMainViewAstroTrendGridViewItemView*)sender;
        HGFriendEmotion* friendEmotion = [friendEmotions objectAtIndex:itemView.tag];
        [delegate mainViewFriendEmotionGridView:self didSelectFriendEmotion:friendEmotion];
    }
}


@end
