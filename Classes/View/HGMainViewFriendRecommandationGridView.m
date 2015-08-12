//
//  HGMainViewFriendRecommandationGridView.h
//  HappyGift
//
//  Created by Yujian Weng on 12-6-11.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//

#import "HGMainViewFriendRecommandationGridView.h"
#import "HGGift.h"
#import "HGMainViewFriendRecommandationGridViewItemView.h"
#import "HGTrackingService.h"
#import <QuartzCore/QuartzCore.h>
#import "HGDefines.h"
#import "HGFriendRecommandation.h"
#import "HappyGiftAppDelegate.h"

#define kMainViewGiftCollectionItemViewSpacing 10.0
#define kMainViewGiftCollectionItemViewVerticalSpacing 5.0

@interface HGMainViewFriendRecommandationGridView()
-(void)initSubViews;
@end

@implementation HGMainViewFriendRecommandationGridView
@synthesize recommandations;
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
    [recommandations release];
    [super dealloc];
}

+ (HGMainViewFriendRecommandationGridView*)mainViewRecommandationGridView{
    NSArray* nibViews = [[NSBundle mainBundle] loadNibNamed:@"HGMainViewFriendRecommandationGridView"
                                                      owner:self
                                                    options:nil];
    return [nibViews objectAtIndex:0];    
}

- (void)setRecommandations:(NSArray *)theRecommandations {
    if (recommandations != theRecommandations){
        [recommandations release];
        recommandations = [theRecommandations retain];
    }
    
    // update UI in case that some orders has been changed
    headTitleLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:[HappyGiftAppDelegate fontSizeLarge]];
    headTitleLabel.textColor = UIColorFromRGB(0xde5a1b);
    headTitleLabel.text = @"猜TA喜欢";
    
    NSArray* subviews = [contentView subviews];
    for (UIView* subview in subviews) {
        [subview removeFromSuperview];
    }
    
    if (recommandations != nil) {
        CGFloat itemViewX = kMainViewGiftCollectionItemViewSpacing;
        CGFloat itemViewY = kMainViewGiftCollectionItemViewVerticalSpacing;
        int columnCount = 3;
        
        CGRect contentFrame = contentView.frame;
        contentView.autoresizesSubviews = NO;
       
        int giftSetIndex = 0;
        for (HGFriendRecommandation* recommandation in recommandations) {
            HGMainViewFriendRecommandationGridViewItemView* itemView = [HGMainViewFriendRecommandationGridViewItemView mainViewRecommandationGridViewItemView];
            
            itemView.recommandation = recommandation;
           
            CGRect itemViewFrame = itemView.frame;
            itemViewFrame.origin.x = itemViewX;
            itemViewFrame.origin.y = itemViewY;
            itemView.frame = itemViewFrame;
            
            [itemView addTarget:self action:@selector(handleRecommandationGridViewItemView:) forControlEvents:UIControlEventTouchUpInside];
            
            [contentView addSubview:itemView];
            
            contentFrame.size.height = itemViewY + itemViewFrame.size.height + kMainViewGiftCollectionItemViewSpacing;
            
            itemView.tag = giftSetIndex++;
            
            if (giftSetIndex % columnCount == 0) {
                itemViewX = kMainViewGiftCollectionItemViewSpacing;
                itemViewY += itemViewFrame.size.height + kMainViewGiftCollectionItemViewVerticalSpacing;
            } else {
                itemViewX += itemViewFrame.size.width + kMainViewGiftCollectionItemViewSpacing;
            }
            if (giftSetIndex == 6) {
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
    if ([delegate respondsToSelector:@selector(mainViewRecommandationGridView:didSelectRecommandations:)]){
        [delegate mainViewRecommandationGridView:self didSelectRecommandations:recommandations];
    }
}

- (void)handleHeadActionDown:(id)sender{
    headBackgroundImageView.highlighted = YES;
}

- (void)handleHeadActionUp:(id)sender {
    headBackgroundImageView.highlighted = NO;
}

- (void)handleRecommandationGridViewItemView:(id)sender {
    HGMainViewFriendRecommandationGridViewItemView* friendRecommandationGridViewItemView = (HGMainViewFriendRecommandationGridViewItemView*)sender;
    HGGift* theGift = friendRecommandationGridViewItemView.recommandation.gift;
    
    [HGTrackingService logEvent:kTrackingEventSelectFriendRecommendation withParameters:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", friendRecommandationGridViewItemView.tag], @"index", theGift.identifier, @"productId", nil]];
    
    HGMainViewFriendRecommandationGridViewItemView* itemView = (HGMainViewFriendRecommandationGridViewItemView*)sender;
    if ([delegate respondsToSelector:@selector(mainViewRecommandationGridView:didSelectRecommandation:)]){
        [delegate mainViewRecommandationGridView:self didSelectRecommandation:itemView.recommandation];
    }
}


@end
