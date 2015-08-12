//
//  HGMainViewPersonlizedOccasionGiftCollectionGridViewItemView.h
//  HappyGift
//
//  Created by Yujian Weng on 12-6-5.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//

#import "HGMainViewPersonlizedOccasionGiftCollectionGridViewItemView.h"
#import "HappyGiftAppDelegate.h"
#import "HGImageService.h"
#import "UIImage+Addition.h"
#import "HGGift.h"
#import "HGOccasionGiftCollection.h"
#import "HGGiftSet.h"
#import <QuartzCore/QuartzCore.h>
#import "HGUserImageView.h"
#import "HGRecipient.h"
#import "HGUtility.h"
#import "HGOccasionTag.h"
#import "HGOccasionCategory.h"

@interface HGMainViewPersonlizedOccasionGiftCollectionGridViewItemView()
-(void)initSubViews;
@end


@implementation HGMainViewPersonlizedOccasionGiftCollectionGridViewItemView
@synthesize giftCollection;

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
    [coverImageView release];
    [userNameLabel release];
    [overLayView release];
    [eventDescriptionLabel release];
    [giftCollection release];
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

- (void)setGiftCollection:(HGOccasionGiftCollection *)theGiftCollection{
    if (giftCollection != theGiftCollection){
        [giftCollection release];
        giftCollection = [theGiftCollection retain];
        if (giftCollection != nil){
            HGGiftOccasion* giftOccasion = giftCollection.occasion;
            
            userNameLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:[HappyGiftAppDelegate fontSizeSmall]];
            userNameLabel.text = giftOccasion.recipient.recipientName;
            userNameLabel.textColor = [UIColor blackColor];
            eventDescriptionLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeTiny]];
            
            if ([@"birthday" isEqualToString: giftOccasion.occasionCategory.identifier]) {
                eventDescriptionLabel.text = [HGUtility formatBirthdayText:giftOccasion.eventDate forShortDescription:YES];
                [coverImageView updateUserImageViewWithRecipient:giftOccasion.recipient];
            } else {
                eventDescriptionLabel.text = [HGUtility formatShortDate:giftOccasion.eventDate];
                [coverImageView updateUserImageViewWithOccasion:giftOccasion];
            }
            eventDescriptionLabel.textColor = [UIColor lightGrayColor];
        }
    }
}

+ (HGMainViewPersonlizedOccasionGiftCollectionGridViewItemView*)mainViewPersonlizedOccasionGiftCollectionGridViewItemView{
    NSArray* nibViews = [[NSBundle mainBundle] loadNibNamed:@"HGMainViewPersonlizedOccasionGiftCollectionGridViewItemView"
                                                      owner:self
                                                    options:nil];
    return [nibViews objectAtIndex:0];
}

@end
