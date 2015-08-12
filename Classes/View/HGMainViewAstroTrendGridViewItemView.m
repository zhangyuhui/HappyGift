//
//  HGMainViewAstroTrendGridViewItemView.m
//  HappyGift
//
//  Created by Yujian Weng on 12-7-4.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//

#import "HGMainViewAstroTrendGridViewItemView.h"
#import <QuartzCore/QuartzCore.h>
#import "HGUserImageView.h"
#import "HGUtility.h"
#import "HGAstroTrend.h"
#import "HGRecipient.h"
#import "HGAstroTrendService.h"
#import "HappyGiftAppDelegate.h"

@interface HGMainViewAstroTrendGridViewItemView()
-(void)initSubViews;
@end


@implementation HGMainViewAstroTrendGridViewItemView
@synthesize astroTrend;
@synthesize recipientImageView;
@synthesize recipientNameLabel;

-(id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super initWithCoder:decoder])) {
		[self initSubViews];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
		[self initSubViews];
    }
    return self;
}

- (void)initSubViews {
    recipientNameLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:[HappyGiftAppDelegate fontSizeSmall]];
    recipientNameLabel.textColor = [UIColor blackColor];
}

- (void)dealloc{
    [recipientImageView release];
    [recipientNameLabel release];
    [overLayView release];
    [astroTrend release];
    [super dealloc];
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    overLayView.hidden = NO;
    return [super beginTrackingWithTouch:touch withEvent:event];
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    overLayView.hidden = YES;
    return NO;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    overLayView.hidden = YES;
    [super endTrackingWithTouch:touch withEvent:event];
}

- (void)cancelTrackingWithEvent:(UIEvent *)event{
    overLayView.hidden = YES;
    [super cancelTrackingWithEvent:event];
}

- (void)setAstroTrend:(HGAstroTrend *)theAstroTrend {
    if (astroTrend != theAstroTrend){
        [astroTrend release];
        astroTrend = [theAstroTrend retain];
    }
    
    // update UI in case that the order content has been changed
    if (astroTrend != nil) {
        recipientNameLabel.text = astroTrend.recipient.recipientName;
        [recipientImageView updateUserImageViewWithAstroTrend:astroTrend];
    }
}

+ (HGMainViewAstroTrendGridViewItemView*)mainViewAstroTrendGridViewItemView{
    NSArray* nibViews = [[NSBundle mainBundle] loadNibNamed:@"HGMainViewAstroTrendGridViewItemView"
                                                      owner:self
                                                    options:nil];
    HGMainViewAstroTrendGridViewItemView* view = [nibViews objectAtIndex:0];
    [view initSubViews];
    return view;
}

@end
