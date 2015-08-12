//
//  HGMainViewSentGiftsGridViewItemView.h
//  HappyGift
//
//  Created by Yujian Weng on 12-6-10.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//

#import "HGMainViewSentGiftsGridViewItemView.h"
#import "HGGiftOrder.h"
#import <QuartzCore/QuartzCore.h>
#import "HGUserImageView.h"
#import "HGUtility.h"
#import "HGGiftOrderService.h"
#import "HappyGiftAppDelegate.h"

@interface HGMainViewSentGiftsGridViewItemView()
-(void)initSubViews;
@end


@implementation HGMainViewSentGiftsGridViewItemView
@synthesize giftOrder;

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
}

- (void)dealloc{
    [recipientImageView release];
    [recipientNameLabel release];
    [overLayView release];
    [orderStatusLabel release];
    [giftOrder release];
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

- (void)setGiftOrder:(HGGiftOrder *)theGiftOrder {
    if (giftOrder != theGiftOrder){
        [giftOrder release];
        giftOrder = [theGiftOrder retain];
    }
    
    // update UI in case that the order content has been changed
    if (giftOrder != nil) {
        recipientNameLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:[HappyGiftAppDelegate fontSizeSmall]];
        recipientNameLabel.text = giftOrder.giftRecipient.recipientDisplayName;
        recipientNameLabel.textColor = [UIColor blackColor];
        orderStatusLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeTiny]];
        orderStatusLabel.textColor = [UIColor lightGrayColor];

        orderStatusLabel.text = [HGGiftOrderService formatOrderStatusText:giftOrder];
        
        [recipientImageView updateUserImageViewWithRecipient:giftOrder.giftRecipient];
    }
}

+ (HGMainViewSentGiftsGridViewItemView*)mainViewSentGiftsGridViewItemView{
    NSArray* nibViews = [[NSBundle mainBundle] loadNibNamed:@"HGMainViewSentGiftsGridViewItemView"
                                                      owner:self
                                                    options:nil];
    return [nibViews objectAtIndex:0];
}

@end
