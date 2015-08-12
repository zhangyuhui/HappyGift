//
//  HGCardSelectionTemplateListItemView.m
//  HappyGift
//
//  Created by Yuhui Zhang on 9/30/11.
//  Copyright 2011 Ztelic Inc. All rights reserved.
//

#import "HGCardSelectionTemplateListItemView.h"
#import "HappyGiftAppDelegate.h"
#import "HGImageService.h"
#import "UIImage+Addition.h"
#import "HGGiftCard.h"
#import "HGGiftCardTemplate.h"
#import <QuartzCore/QuartzCore.h>
#import "HGUtility.h"

@interface HGCardSelectionTemplateListItemView()
-(void)initSubViews;
@end


@implementation HGCardSelectionTemplateListItemView
@synthesize giftCardTemplate;
@synthesize isCoverImageRequestStarted;

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
    [coverImageView release];
    [super dealloc];
}

- (void)requestCoverImage {
    if (!isCoverImageRequestStarted) {
        isCoverImageRequestStarted = YES;
        HGImageService *imageService = [HGImageService sharedService];
        UIImage *coverImage = [imageService requestImage:giftCardTemplate.coverImageUrl target:self selector:@selector(didImageLoaded:)];
        if (coverImage != nil) {
            coverImageView.image = [coverImage imageWithFrame:coverImageView.frame.size color:[UIColor clearColor]];
            CATransition *animation = [CATransition animation];
            [animation setDelegate:self];
            [animation setType:kCATransitionFade];
            [animation setDuration:0.2];
            [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
            [coverImageView.layer addAnimation:animation forKey:@"updateCoverAnimation"];
        } else {
            coverImageView.image = [HGUtility defaultImage:coverImageView.frame.size];
        }
    }
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    return [super beginTrackingWithTouch:touch withEvent:event];
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    return NO;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    [super endTrackingWithTouch:touch withEvent:event];
}

- (void)cancelTrackingWithEvent:(UIEvent *)event{
    [super cancelTrackingWithEvent:event];
}

- (void)setGiftCardTemplate:(HGGiftCardTemplate *)theGiftCardTemplate {
    if (giftCardTemplate != theGiftCardTemplate){
        [giftCardTemplate release];
        giftCardTemplate = [theGiftCardTemplate retain];
        if (giftCardTemplate != nil){
            coverImageView.layer.shadowColor = [UIColor blackColor].CGColor;
            coverImageView.layer.shadowOffset = CGSizeMake(0, 5.0);
            coverImageView.layer.shadowOpacity = 1;
            coverImageView.layer.shadowRadius = 5.0;
            coverImageView.clipsToBounds = NO;
            
            if ([HGUtility wifiReachable]) {
                [self requestCoverImage];
            } else {
                isCoverImageRequestStarted = NO;
                coverImageView.image = [HGUtility defaultImage:coverImageView.frame.size];
            }
        }
    }
}

+ (HGCardSelectionTemplateListItemView*)cardSelectionTemplateListItemView{
    NSArray* nibViews = [[NSBundle mainBundle] loadNibNamed:@"HGCardSelectionTemplateListItemView"
                                                      owner:self
                                                    options:nil];
    return [nibViews objectAtIndex:0];
}

#pragma mark  HGImagesService selector
- (void)didImageLoaded:(HGImageData*)image{
    UIImage *coverImage = image.image;
    coverImageView.image = [coverImage imageWithFrame:coverImageView.frame.size color:[HappyGiftAppDelegate imageFrameColor]];
    
    CATransition *animation = [CATransition animation];
    [animation setDelegate:self];
    [animation setType:kCATransitionFade];
    [animation setDuration:0.2];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [coverImageView.layer addAnimation:animation forKey:@"updateCoverAnimation"];
}

@end
