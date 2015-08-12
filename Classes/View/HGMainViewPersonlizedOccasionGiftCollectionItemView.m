//
//  HGMainViewPersonlizedOccasionGiftCollectionItemView.m
//  HappyGift
//
//  Created by Yuhui Zhang on 9/30/11.
//  Copyright 2011 Ztelic Inc. All rights reserved.
//

#import "HGMainViewPersonlizedOccasionGiftCollectionItemView.h"
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

#define kMainViewNewsItemViewHighlightTimer 0.05

@interface HGMainViewPersonlizedOccasionGiftCollectionItemView()
-(void)initSubViews;
@end


@implementation HGMainViewPersonlizedOccasionGiftCollectionItemView
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

- (void)initSubViews{
    
}

- (void)dealloc{
    if (highlightTimer != nil){
        [highlightTimer invalidate];
        highlightTimer = nil;
    }
    [coverImageView release];
    [userNameLabel release];
    [overLayView release];
    [eventNameLabel release];
    [eventDescriptionLabel release];
    [giftCollection release];
    [defaultImage release];
    [super dealloc];
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    highlightTimer = [NSTimer scheduledTimerWithTimeInterval:kMainViewNewsItemViewHighlightTimer target:self selector:@selector(handleHighlightTimer:) userInfo:nil repeats:NO];
    return [super beginTrackingWithTouch:touch withEvent:event];
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{

    if (highlightTimer != nil){
        [highlightTimer invalidate];
        highlightTimer = nil;
    }
    overLayView.hidden = YES;
    return NO;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    if (highlightTimer != nil){
        [highlightTimer invalidate];
        highlightTimer = nil;
    }
    overLayView.hidden = YES;
    [super endTrackingWithTouch:touch withEvent:event];
}

- (void)cancelTrackingWithEvent:(UIEvent *)event{
    if (highlightTimer != nil){
        [highlightTimer invalidate];
        highlightTimer = nil;
    }
    overLayView.hidden = YES;
    [super cancelTrackingWithEvent:event];
}

- (void)handleHighlightTimer:(NSTimer*)timer{
    highlightTimer = nil;
    overLayView.hidden = NO;
}

- (void)setGiftCollection:(HGOccasionGiftCollection *)theGiftCollection{
    if (giftCollection != theGiftCollection){
        [giftCollection release];
        giftCollection = [theGiftCollection retain];
        if (giftCollection != nil){
            HGGiftOccasion* giftOccasion = giftCollection.occasion;
            
            CGRect titleLabelFrame = userNameLabel.frame;
            titleLabelFrame.origin.x = coverImageView.frame.origin.x + coverImageView.frame.size.width + 5.0;
            titleLabelFrame.origin.y = 0.0;
            titleLabelFrame.size.width = self.frame.size.width - titleLabelFrame.origin.x - 5.0;
            
            userNameLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:[HappyGiftAppDelegate fontSizeSmall]];
            userNameLabel.text = giftOccasion.recipient.recipientName;
            userNameLabel.textColor = [UIColor blackColor];
            
            CGSize titleLabelSize = [userNameLabel.text sizeWithFont:userNameLabel.font constrainedToSize:CGSizeMake(titleLabelFrame.size.width , 60.0)];
            titleLabelFrame.size.height = titleLabelSize.height;
            userNameLabel.frame = titleLabelFrame;
            
            eventNameLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeTiny]];
            
            if ([@"birthday" isEqualToString: giftOccasion.eventType]) {
                eventNameLabel.text = [HGUtility formatBirthdayText:giftOccasion.eventDate forShortDescription:YES];
            } else {
                eventNameLabel.text = [HGUtility formatShortDate:giftOccasion.eventDate];
            }
            
            eventNameLabel.textColor = [UIColor lightGrayColor];
            
            CGRect descriptionLabelFrame = eventNameLabel.frame;
            descriptionLabelFrame.origin.x = titleLabelFrame.origin.x;
            descriptionLabelFrame.origin.y = titleLabelFrame.origin.y + titleLabelFrame.size.height + 5.0;
            descriptionLabelFrame.size.width = titleLabelFrame.size.width;
            CGSize descriptionLabelSize = [eventNameLabel.text sizeWithFont:eventNameLabel.font constrainedToSize:CGSizeMake(descriptionLabelFrame.size.width, 40.0)];
            descriptionLabelFrame.size.height = descriptionLabelSize.height;
            eventNameLabel.frame = descriptionLabelFrame;
            
            eventDescriptionLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeTiny]];
            eventDescriptionLabel.text = giftOccasion.eventDate;
            eventDescriptionLabel.textColor = [UIColor lightGrayColor];
            
            CGRect priceLabelFrame = eventDescriptionLabel.frame;
            priceLabelFrame.origin.x = descriptionLabelFrame.origin.x;
            priceLabelFrame.origin.y = descriptionLabelFrame.origin.y + descriptionLabelFrame.size.height;
            priceLabelFrame.size.width = descriptionLabelFrame.size.width;
            eventDescriptionLabel.frame = priceLabelFrame;
            
            eventDescriptionLabel.hidden = YES;
                        
            HGRecipient* recipient = [[HGRecipient alloc] init];
            recipient.recipientImageUrl = giftOccasion.recipient.recipientImageUrl;
            recipient.recipientName = giftOccasion.recipient.recipientName;
            recipient.recipientNetworkId = giftOccasion.recipient.recipientNetworkId;
            recipient.recipientProfileId = giftOccasion.recipient.recipientProfileId;
            [coverImageView updateUserImageViewWithRecipient:recipient];
            [recipient release];
        }
    }
}

+ (HGMainViewPersonlizedOccasionGiftCollectionItemView*)mainViewPersonlizedOccasionGiftCollectionItemView{
    NSArray* nibViews = [[NSBundle mainBundle] loadNibNamed:@"HGMainViewPersonlizedOccasionGiftCollectionItemView"
                                                      owner:self
                                                    options:nil];
    return [nibViews objectAtIndex:0];
}

@end
