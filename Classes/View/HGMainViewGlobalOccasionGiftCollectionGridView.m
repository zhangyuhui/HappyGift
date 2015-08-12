//
//  HGMainViewGlobalOccasionGiftCollectionGridView.m
//  HappyGift
//
//  Created by Yujian Weng on 12-6-10.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//

#import "HGMainViewGlobalOccasionGiftCollectionGridView.h"
#import "HGGift.h"
#import "HGGiftOccasion.h"
#import "HGOccasionGiftCollection.h"
#import "HGMainViewGlobalOccasionGiftCollectionGridViewItemView.h"
#import "HGGiftCollectionService.h"
#import "HGTrackingService.h"
#import <QuartzCore/QuartzCore.h>
#import "HGOccasionCategory.h"
#import "HGGiftSet.h"
#import "HGDefines.h"
#import "HappyGiftAppDelegate.h"

#define kMainViewGiftCollectionItemViewSpacing 10.0
#define kMainViewGiftCollectionItemViewVerticalSpacing 10.0

@interface HGMainViewGlobalOccasionGiftCollectionGridView()
-(void)initSubViews;
@end

@implementation HGMainViewGlobalOccasionGiftCollectionGridView
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
    [headLogoImageView release];
    [headBackgroundImageView release];
    [headTitleLabel release];
    [headActionButton release];
    [contentView release];
    [giftCollection release];
    [super dealloc];
}

+ (HGMainViewGlobalOccasionGiftCollectionGridView*)mainViewGlobalOccasionGiftCollectionGridView{
    NSArray* nibViews = [[NSBundle mainBundle] loadNibNamed:@"HGMainViewGlobalOccasionGiftCollectionGridView"
                                                      owner:self
                                                    options:nil];
    return [nibViews objectAtIndex:0];    
}

- (void)setGiftCollection:(HGOccasionGiftCollection *)theGiftCollection {
    if (giftCollection != theGiftCollection){
        [giftCollection release];
        giftCollection = [theGiftCollection retain];
        
        headTitleLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:[HappyGiftAppDelegate fontSizeLarge]];
        headTitleLabel.textColor = UIColorFromRGB(0xf45200);
        
        if (giftCollection != nil) {
            headTitleLabel.text = giftCollection.occasion.occasionCategory.longName;
            if (!headTitleLabel.text || [@"" isEqualToString: headTitleLabel.text]) {
                headTitleLabel.text = giftCollection.occasion.occasionCategory.name;
            }
            
            if (giftCollection.occasion.occasionCategory.headerIcon) {
                headLogoImageView.image = [UIImage imageNamed:giftCollection.occasion.occasionCategory.headerIcon];
            }
            
            if (giftCollection.occasion.occasionCategory.headerBackground) {
                headBackgroundImageView.image = [UIImage imageNamed:giftCollection.occasion.occasionCategory.headerBackground];
            }
            const CGFloat leftPadding = 12.0;
            const CGFloat topPadding = 10.0;
            const CGFloat bottomPadding = 12.0;
            
            CGFloat itemViewX = leftPadding;
            CGFloat itemViewY = topPadding;
            int columnCount = 2;
            
            CGRect contentFrame = contentView.frame;
            contentView.autoresizesSubviews = NO;
           
            int giftSetIndex = 0;
            for (HGGiftSet* giftSet in giftCollection.giftSets) {
                HGMainViewGlobalOccasionGiftCollectionGridViewItemView* globalOccasionGiftCollectionGridViewItemView = [HGMainViewGlobalOccasionGiftCollectionGridViewItemView mainViewGlobalOccasionGiftCollectionGridViewItemView];
                
               
                CGRect globalOccasionGiftCollectionItemViewFrame = globalOccasionGiftCollectionGridViewItemView.frame;
                globalOccasionGiftCollectionItemViewFrame.origin.x = itemViewX;
                globalOccasionGiftCollectionItemViewFrame.origin.y = itemViewY;
                globalOccasionGiftCollectionGridViewItemView.frame = globalOccasionGiftCollectionItemViewFrame;
                
                
                [globalOccasionGiftCollectionGridViewItemView addTarget:self action:@selector(handleGlobalOccasionGiftCollectionGridViewItemView:) forControlEvents:UIControlEventTouchUpInside];
                
                [contentView addSubview:globalOccasionGiftCollectionGridViewItemView];
                
                contentFrame.size.height = itemViewY + globalOccasionGiftCollectionItemViewFrame.size.height + bottomPadding;
                
                globalOccasionGiftCollectionGridViewItemView.giftSet = giftSet;
                globalOccasionGiftCollectionGridViewItemView.tag = giftSetIndex;
                
                ++giftSetIndex;
                
                if (giftSetIndex % columnCount == 0) {
                    itemViewX = leftPadding;
                    itemViewY += globalOccasionGiftCollectionItemViewFrame.size.height + kMainViewGiftCollectionItemViewVerticalSpacing;
                } else {
                    itemViewX += globalOccasionGiftCollectionItemViewFrame.size.width + kMainViewGiftCollectionItemViewSpacing;
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
    if ([delegate respondsToSelector:@selector(mainViewGlobalOccasionGiftCollectionGridView:didSelectGlobalOccasionGiftCollection:)]){
        [delegate mainViewGlobalOccasionGiftCollectionGridView:self didSelectGlobalOccasionGiftCollection:giftCollection];
    }
}

- (void)handleHeadActionDown:(id)sender{
    headBackgroundImageView.highlighted = YES;
}

- (void)handleHeadActionUp:(id)sender{
    headBackgroundImageView.highlighted = NO;
}

- (void)handleGlobalOccasionGiftCollectionGridViewItemView:(id)sender{
    HGMainViewGlobalOccasionGiftCollectionGridViewItemView* globalOccasionGiftCollectionItemView = (HGMainViewGlobalOccasionGiftCollectionGridViewItemView*)sender;
    
    if ([globalOccasionGiftCollectionItemView.giftSet.gifts count] == 1) {
        HGGift* theGift = [globalOccasionGiftCollectionItemView.giftSet.gifts objectAtIndex:0];
        [HGTrackingService logEvent:kTrackingEventSelectGlobalGiftOccasion withParameters:[NSDictionary dictionaryWithObjectsAndKeys:giftCollection.occasion.occasionCategory.name, @"occasion", [NSString stringWithFormat:@"%d", globalOccasionGiftCollectionItemView.tag], @"index", theGift.identifier, @"productId", nil]];
    } else {
        [HGTrackingService logEvent:kTrackingEventSelectGlobalGiftOccasion withParameters:[NSDictionary dictionaryWithObjectsAndKeys:giftCollection.occasion.occasionCategory.name, @"occasion", [NSString stringWithFormat:@"%d", globalOccasionGiftCollectionItemView.tag], @"index", nil]];
    }
    
    if ([delegate respondsToSelector:@selector(mainViewGlobalOccasionGiftCollectionGridView:didSelectGlobalOccasionGiftSet:)]){
        [delegate mainViewGlobalOccasionGiftCollectionGridView:self didSelectGlobalOccasionGiftSet:globalOccasionGiftCollectionItemView.giftSet];
    }
}

@end
