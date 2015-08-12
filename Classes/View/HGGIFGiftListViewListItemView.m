//
//  HGGIFGiftListViewListItemView.m
//  HappyGift
//
//  Created by Yujian Weng on 12-7-27.
//  Copyright 2011 Ztelic Inc Inc. All rights reserved.
//

#import "HGGIFGiftListViewListItemView.h"
#import "HappyGiftAppDelegate.h"
#import "HGImageService.h"
#import "UIImage+Addition.h"
#import "HGGIFGift.h"
#import "HGUtility.h"
#import <QuartzCore/QuartzCore.h>
#import "AnimatedGif.h"
#import "HGLogging.h"

#define kGiftsGroupSelectionViewGiftsListItemViewHighlightTimer 0.05

@interface HGGIFGiftListViewListItemView()
-(void)initSubViews;
@end


@implementation HGGIFGiftListViewListItemView
@synthesize gifGift;

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
    [titleLabel release];
    [descriptionLabel release];
    [overLayView release];
    [gifGift release];
    [super dealloc];
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    highlightTimer = [NSTimer scheduledTimerWithTimeInterval:kGiftsGroupSelectionViewGiftsListItemViewHighlightTimer target:self selector:@selector(handleHighlightTimer:) userInfo:nil repeats:NO];
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

- (void)setGifGift:(HGGIFGift *)theGifGift{
    if (gifGift != theGifGift){
        [gifGift release];
        gifGift = [theGifGift retain];
        if (gifGift != nil) {
            titleLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeSmall]];
            titleLabel.text = gifGift.name;
            titleLabel.textColor = [UIColor darkGrayColor];
            
            descriptionLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeTiny]];
            
            descriptionLabel.textColor = [UIColor grayColor];
            
            HGImageService *imageService = [HGImageService sharedService];
            HGImageData *coverImage = [imageService requestImageForRawData:gifGift.gif target:self selector:@selector(didImageLoaded:)];
            
            if (coverImage != nil){
                [self updateCoverImageView:coverImage];
            }else{
                coverImageView.image = [HGUtility defaultImage:coverImageView.frame.size];
            }
        }
    }
    if (![coverImageView isAnimating]) {
        [coverImageView startAnimating];
    }
}

+ (HGGIFGiftListViewListItemView*)gifGiftListViewListItemView {
    NSArray* nibViews = [[NSBundle mainBundle] loadNibNamed:@"HGGIFGiftListViewListItemView"
                                                      owner:self
                                                    options:nil];
    return [nibViews objectAtIndex:0];
}

- (void)updateCoverImageView:(HGImageData*)image {
    [UIView animateWithDuration:0.1 
                          delay:0.0 
                        options:UIViewAnimationOptionCurveEaseInOut 
                     animations:^{
                         coverImageView.alpha = 0.0;
                     }
                     completion:^(BOOL finished) {
                         NSString *url = [image.url lowercaseString];
                         if ([url hasSuffix:@".png"] || [url hasSuffix:@".jpg"]) {
                             coverImageView.image = image.image;
                             coverImageView.animationImages = nil;
                         } else {
                             UIImageView* tempImageView = [AnimatedGif getAnimationForGifWithData:image.data];
                             coverImageView.animationDuration = tempImageView.animationDuration;
                             coverImageView.animationRepeatCount = 0;
                             
                             [coverImageView setImage: [[tempImageView image] imageWithFrame:coverImageView.frame.size color:[HappyGiftAppDelegate imageFrameColor]]];
                             [coverImageView setAnimationImages: [tempImageView animationImages]];
                             [coverImageView startAnimating];
                         }
                         
                         [UIView animateWithDuration:0.1 
                                               delay:0.0 
                                             options:UIViewAnimationOptionCurveEaseInOut 
                                          animations:^{
                                              coverImageView.alpha = 1.0;
                                          }
                                          completion:^(BOOL finished) {
                                              
                                          }];    
                     }];
}

#pragma mark  HGImagesService selector
- (void)didImageLoaded:(HGImageData*)image{
    if ([image.url isEqualToString:gifGift.gif]) {
        [self updateCoverImageView:image];
    }
}

@end
