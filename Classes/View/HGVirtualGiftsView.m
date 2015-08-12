//
//  HGVirtualGiftsView.m
//  HappyGift
//
//  Created by Yujian Weng on 12-7-27.
//  Copyright 2011 Ztelic Inc Inc. All rights reserved.
//

#import "HGVirtualGiftsView.h"
#import "HappyGiftAppDelegate.h"
#import "HGImageService.h"
#import "UIImage+Addition.h"
#import "HGUtility.h"
#import <QuartzCore/QuartzCore.h>

#define kGiftsGroupSelectionViewGiftsListItemViewHighlightTimer 0.05

@interface HGVirtualGiftsView()
-(void)initSubViews;
@end


@implementation HGVirtualGiftsView
@synthesize titleLabel;
@synthesize descriptionLabel;
@synthesize coverImageView;

- (void)initSubViews{
    titleLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:[HappyGiftAppDelegate fontSizeSmall]];
    titleLabel.textColor = [UIColor blackColor];
    
    descriptionLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeTiny]];
    
    descriptionLabel.textColor = [UIColor grayColor];
    coverImageView.image = [HGUtility defaultImage:coverImageView.frame.size];
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

+ (HGVirtualGiftsView*)virtualGiftsView {
    NSArray* nibViews = [[NSBundle mainBundle] loadNibNamed:@"HGVirtualGiftsView"
                                                      owner:self
                                                    options:nil];
    HGVirtualGiftsView* view = [nibViews objectAtIndex:0];
    [view initSubViews];
    return view;
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
