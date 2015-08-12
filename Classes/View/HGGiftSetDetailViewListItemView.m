//
//  HGGiftSetDetailViewListItemView.m
//  HappyGift
//
//  Created by Yuhui Zhang on 9/30/11.
//  Copyright 2011 Ztelic Inc. All rights reserved.
//

#import "HGGiftSetDetailViewListItemView.h"
#import "HappyGiftAppDelegate.h"
#import "HGImageService.h"
#import "UIImage+Addition.h"
#import "HGGift.h"
#import "HGUtility.h"
#import <QuartzCore/QuartzCore.h>

#define kGiftsGroupSelectionViewGiftsListItemViewHighlightTimer 0.05

@interface HGGiftSetDetailViewListItemView()
-(void)initSubViews;
@end


@implementation HGGiftSetDetailViewListItemView
@synthesize gift;

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
    [gift release];
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

- (void)setGift:(HGGift *)theGift{
    if (gift != theGift){
        [gift release];
        gift = [theGift retain];
        if (gift != nil){
            titleLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:[HappyGiftAppDelegate fontSizeSmall]];
            titleLabel.text = gift.name;
            titleLabel.textColor = [UIColor blackColor];
            
            descriptionLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeTiny]];
            if (gift.sexyName && ![@"" isEqualToString: gift.sexyName]) {
                descriptionLabel.text = gift.sexyName;
            } else {
                descriptionLabel.text = gift.manufacturer;
            }
            
            descriptionLabel.textColor = [UIColor grayColor];
            
            priceLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeTiny]];
            if (fabs(theGift.price) < 0.005){
                priceLabel.text = @"免费";
            }else{
                priceLabel.text = [NSString stringWithFormat:@"¥%.2f", theGift.price];
            }
            priceLabel.textColor = [UIColor whiteColor];
            
            CGSize priceLabelSize = [priceLabel.text sizeWithFont:priceLabel.font];
            CGRect priceLabelFrame = priceLabel.frame;
            priceLabelFrame.origin.x = self.frame.size.width - priceLabelSize.width - 6.0;
            priceLabelFrame.size.width = priceLabelSize.width;
            priceLabel.frame = priceLabelFrame;
            
            [priceImageView setImage:[[UIImage imageNamed:@"gift_selection_price_tag"] stretchableImageWithLeftCapWidth:14.0 topCapHeight:0.0]];
            
            CGRect priceImageViewFrame = priceImageView.frame;
            priceImageViewFrame.size.width = priceLabelSize.width + 15.0;
            priceImageViewFrame.origin.x = self.frame.size.width - priceImageViewFrame.size.width;
            priceImageView.frame = priceImageViewFrame;
                        
            HGImageService *imageService = [HGImageService sharedService];
            UIImage *coverImage = [imageService requestImage:gift.thumb target:self selector:@selector(didImageLoaded:)];
            if (coverImage != nil){
                coverImageView.image = [coverImage imageWithFrame:coverImageView.frame.size color:[HappyGiftAppDelegate imageFrameColor]];
                
                CATransition *animation = [CATransition animation];
                [animation setDelegate:self];
                [animation setType:kCATransitionFade];
                [animation setDuration:0.2];
                [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
                [coverImageView.layer addAnimation:animation forKey:@"updateCoverAnimation"];
            }else{
                coverImageView.image = [HGUtility defaultImage:coverImageView.frame.size];
            }
        }
    }
}

+ (HGGiftSetDetailViewListItemView*)giftSetDetailViewListItemView{
    NSArray* nibViews = [[NSBundle mainBundle] loadNibNamed:@"HGGiftSetDetailViewListItemView"
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
