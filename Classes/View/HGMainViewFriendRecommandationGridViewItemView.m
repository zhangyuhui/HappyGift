//
//  HGMainViewFriendRecommandationGridViewItemView.h
//  HappyGift
//
//  Created by Yujian Weng on 12-6-11.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//

#import "HGMainViewFriendRecommandationGridViewItemView.h"
#import <QuartzCore/QuartzCore.h>
#import "HGUserImageView.h"
#import "HGUtility.h"
#import "HGFriendRecommandation.h"
#import "HGRecipient.h"
#import "HappyGiftAppDelegate.h"

@interface HGMainViewFriendRecommandationGridViewItemView()
-(void)initSubViews;
@end


@implementation HGMainViewFriendRecommandationGridViewItemView
@synthesize recommandation;

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
    [recommandation release];
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

- (void)setRecommandation:(HGFriendRecommandation *)theRecommandation {
    if (recommandation != theRecommandation){
        [recommandation release];
        recommandation = [theRecommandation retain];
    }
    
    // update UI in case that the order content has been changed
    if (recommandation != nil) {
        recipientNameLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:[HappyGiftAppDelegate fontSizeSmall]];
        recipientNameLabel.text = recommandation.recipient.recipientName;
        recipientNameLabel.textColor = [UIColor blackColor];
        [recipientImageView updateUserImageViewWithRecipient:recommandation.recipient];
    }
}

+ (HGMainViewFriendRecommandationGridViewItemView*)mainViewRecommandationGridViewItemView{
    NSArray* nibViews = [[NSBundle mainBundle] loadNibNamed:@"HGMainViewFriendRecommandationGridViewItemView"
                                                      owner:self
                                                    options:nil];
    return [nibViews objectAtIndex:0];
}

@end
