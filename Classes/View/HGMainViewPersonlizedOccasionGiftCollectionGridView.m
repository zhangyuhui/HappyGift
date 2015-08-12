//
//  HGMainViewPersonlizedOccasionGiftCollectionGridView.h
//  HappyGift
//
//  Created by Yujian Weng on 12-6-5.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//

#import "HGMainViewPersonlizedOccasionGiftCollectionGridView.h"
#import "HGGift.h"
#import "HGGiftOccasion.h"
#import "HGOccasionGiftCollection.h"
#import "HGMainViewPersonlizedOccasionGiftCollectionGridViewItemView.h"
#import "HGGiftCollectionService.h"
#import "HGTrackingService.h"
#import <QuartzCore/QuartzCore.h>
#import "HGOccasionCategory.h"
#import "HGDefines.h"
#import "HappyGiftAppDelegate.h"

#define kMainViewGiftCollectionItemViewSpacing 10.0
#define kMainViewGiftCollectionItemViewVerticalSpacing 5.0

@interface HGMainViewPersonlizedOccasionGiftCollectionGridView()
-(void)initSubViews;
@end

@implementation HGMainViewPersonlizedOccasionGiftCollectionGridView
@synthesize giftCollections;
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
    [giftCollections release];
    [super dealloc];
}

+ (HGMainViewPersonlizedOccasionGiftCollectionGridView*)mainViewPersonlizedOccasionGiftCollectionGridView{
    NSArray* nibViews = [[NSBundle mainBundle] loadNibNamed:@"HGMainViewPersonlizedOccasionGiftCollectionGridView"
                                                      owner:self
                                                    options:nil];
    return [nibViews objectAtIndex:0];    
}

- (void)setGiftCollections:(NSArray *)theGiftCollections {
    if (giftCollections != theGiftCollections){
        [giftCollections release];
        giftCollections = [theGiftCollections retain];
        
        headTitleLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:[HappyGiftAppDelegate fontSizeLarge]];
        
        
        if (giftCollections != nil) {
            HGOccasionGiftCollection* firstOccasionGiftCollection = [giftCollections objectAtIndex:0];
            
            headTitleLabel.text = firstOccasionGiftCollection.occasion.occasionCategory.longName;
            if (!headTitleLabel.text || [@"" isEqualToString: headTitleLabel.text]) {
                headTitleLabel.text = firstOccasionGiftCollection.occasion.occasionCategory.name;
            }
            
            if ([@"birthday" isEqualToString: firstOccasionGiftCollection.occasion.occasionCategory.identifier]) {
                headTitleLabel.textColor = UIColorFromRGB(0xe18106);
            } else {
                headTitleLabel.textColor = UIColorFromRGB(0xe33a3c);
            }
            
            if (firstOccasionGiftCollection.occasion.occasionCategory.headerIcon) {
                headLogoImageView.image = [UIImage imageNamed:firstOccasionGiftCollection.occasion.occasionCategory.headerIcon];
            }
            
            if (firstOccasionGiftCollection.occasion.occasionCategory.headerBackground) {
                headBackgroundImageView.image = [UIImage imageNamed:firstOccasionGiftCollection.occasion.occasionCategory.headerBackground];
            }
            
            CGFloat itemViewX = kMainViewGiftCollectionItemViewSpacing;
            CGFloat itemViewY = kMainViewGiftCollectionItemViewVerticalSpacing;
            int columnCount = 3;
            int displayCount = 3;
            
            /*if ([giftCollections count] == 4) {
                displayCount = 3;
            }*/
            
            CGRect contentFrame = contentView.frame;
            contentView.autoresizesSubviews = NO;
           
            int occasionGiftCollectionIndex = 0;
            for (HGOccasionGiftCollection* occasionGiftCollection in giftCollections) {
                HGMainViewPersonlizedOccasionGiftCollectionGridViewItemView* personalizedOccasionGiftCollectionGridViewItemView = [HGMainViewPersonlizedOccasionGiftCollectionGridViewItemView mainViewPersonlizedOccasionGiftCollectionGridViewItemView];
                
               
                CGRect personalizedOccasionGiftCollectionItemViewFrame = personalizedOccasionGiftCollectionGridViewItemView.frame;
                personalizedOccasionGiftCollectionItemViewFrame.origin.x = itemViewX;
                personalizedOccasionGiftCollectionItemViewFrame.origin.y = itemViewY;
                personalizedOccasionGiftCollectionGridViewItemView.frame = personalizedOccasionGiftCollectionItemViewFrame;
                
                
                [personalizedOccasionGiftCollectionGridViewItemView addTarget:self action:@selector(handlePersonlizedOccasionGiftCollectionGridViewItemView:) forControlEvents:UIControlEventTouchUpInside];
                
                [contentView addSubview:personalizedOccasionGiftCollectionGridViewItemView];
                
                contentFrame.size.height = itemViewY + personalizedOccasionGiftCollectionItemViewFrame.size.height + kMainViewGiftCollectionItemViewSpacing;
                
                personalizedOccasionGiftCollectionGridViewItemView.giftCollection = occasionGiftCollection;
                personalizedOccasionGiftCollectionGridViewItemView.tag = occasionGiftCollectionIndex;
                
                ++occasionGiftCollectionIndex;
                
                if (occasionGiftCollectionIndex % columnCount == 0) {
                    itemViewX = kMainViewGiftCollectionItemViewSpacing;
                    itemViewY += personalizedOccasionGiftCollectionItemViewFrame.size.height + kMainViewGiftCollectionItemViewVerticalSpacing;
                } else {
                    itemViewX += personalizedOccasionGiftCollectionItemViewFrame.size.width + kMainViewGiftCollectionItemViewSpacing;
                }
                if (occasionGiftCollectionIndex == displayCount) {
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
    if ([delegate respondsToSelector:@selector(mainViewPersonlizedOccasionGiftCollectionGridView:didSelectGiftOccasions:)]){
        [delegate mainViewPersonlizedOccasionGiftCollectionGridView:self didSelectGiftOccasions:giftCollections];
    }
}

- (void)handleHeadActionDown:(id)sender{
    headBackgroundImageView.highlighted = YES;
}

- (void)handleHeadActionUp:(id)sender {
    headBackgroundImageView.highlighted = NO;
}

- (void)handlePersonlizedOccasionGiftCollectionGridViewItemView:(id)sender{
    HGMainViewPersonlizedOccasionGiftCollectionGridViewItemView* personalizedOccasionGiftCollectionItemView = (HGMainViewPersonlizedOccasionGiftCollectionGridViewItemView*)sender;
    
    HGOccasionGiftCollection* firstOccasionGiftCollection = [giftCollections objectAtIndex:0];
    [HGTrackingService logEvent:kTrackingEventSelectPersonalGiftOccasion withParameters:[NSDictionary dictionaryWithObjectsAndKeys:firstOccasionGiftCollection.occasion.occasionCategory.name, @"occasion", [NSString stringWithFormat:@"%d", personalizedOccasionGiftCollectionItemView.tag], @"index", nil]];
    
    
    if ([delegate respondsToSelector:@selector(mainViewPersonlizedOccasionGiftCollectionGridView:didSelectPersonlizedOccasionGiftCollection:)]){
        [delegate mainViewPersonlizedOccasionGiftCollectionGridView:self didSelectPersonlizedOccasionGiftCollection:personalizedOccasionGiftCollectionItemView.giftCollection];
    }
}


@end
