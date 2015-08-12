//
//  HGMainViewFeaturedGiftCollectionGridViewItemView.m
//  HappyGift
//
//  Created by Yujian Weng on 12-6-10.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//

#import "HGMainViewFeaturedGiftCollectionGridViewItemView.h"
#import "HappyGiftAppDelegate.h"
#import "HGImageService.h"
#import "UIImage+Addition.h"
#import "HGGift.h"
#import "HGGiftSet.h"
#import <QuartzCore/QuartzCore.h>
#import "HGUtility.h"

@interface HGMainViewFeaturedGiftCollectionGridViewItemView()
-(void)initSubViews;
@end


@implementation HGMainViewFeaturedGiftCollectionGridViewItemView
@synthesize giftSet;

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
    [coverTitleLabel release];
    [overLayView release];
    [priceLabel release];
    [priceTagImageView release];
    [giftSet release];
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

- (void)setGiftSet:(HGGiftSet *)theGiftSet {
    if (giftSet != theGiftSet){
        [giftSet release];
        giftSet = [theGiftSet retain];
        if (giftSet != nil) {
            coverTitleLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeSmall]];
            if (giftSet.manufacturer && ![giftSet.manufacturer isEqualToString:@""]) {
                coverTitleLabel.text = giftSet.manufacturer;
            } else {
                coverTitleLabel.text = giftSet.name;
            }
            
            UIImage* coverImage = [[HGImageService sharedService] requestImage:giftSet.thumb target:self selector:@selector(didImageLoaded:)];
            
            if (coverImage) {
                [self updateCoverImage:coverImage];
            } else {
                coverImageView.image = [HGUtility defaultImage:coverImageView.frame.size];
            }
            
            priceLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeTiny]];
       
            float minPrice = -1;
            float maxPrice = -1;
            for (HGGift* gift in giftSet.gifts){
                if (minPrice == -1 || maxPrice == -1){
                    minPrice = gift.price;
                    maxPrice = gift.price;
                }else{
                    if (minPrice > gift.price){
                        minPrice = gift.price;
                    }else if (maxPrice < gift.price){
                        maxPrice = gift.price;
                    }
                }
            } 
            if (fabs(minPrice - maxPrice) > 0.01) {
                priceLabel.text = [NSString stringWithFormat:@"¥%.2f-¥%.2f", minPrice, maxPrice];
            } else {
                if (fabs(minPrice) < 0.005){
                    priceLabel.text = @"免费";
                }else{
                    priceLabel.text = [NSString stringWithFormat:@"¥%.2f", minPrice];
                }
            }
            priceLabel.textColor = [UIColor whiteColor];
            
            CGSize priceLabelSize = [priceLabel.text sizeWithFont:priceLabel.font];
            CGRect priceLabelFrame = priceLabel.frame;
            priceLabelFrame.origin.x = self.frame.size.width - priceLabelSize.width - 6.0;
            priceLabelFrame.size.width = priceLabelSize.width;
            priceLabel.frame = priceLabelFrame;
            
            [priceTagImageView setImage:[[UIImage imageNamed:@"gift_selection_price_tag"] stretchableImageWithLeftCapWidth:14.0 topCapHeight:0.0]];
            
            CGRect priceImageViewFrame = priceTagImageView.frame;
            priceImageViewFrame.size.width = priceLabelSize.width + 15.0;
            priceImageViewFrame.origin.x = self.frame.size.width - priceImageViewFrame.size.width;
            priceTagImageView.frame = priceImageViewFrame;

        }
    }
}

+ (HGMainViewFeaturedGiftCollectionGridViewItemView*)mainViewFeaturedGiftCollectionGridViewItemView{
    NSArray* nibViews = [[NSBundle mainBundle] loadNibNamed:@"HGMainViewFeaturedGiftCollectionGridViewItemView"
                                                      owner:self
                                                    options:nil];
    return [nibViews objectAtIndex:0];
}

-(void)updateCoverImage:(UIImage*) coverImage {
    coverImageView.image = [coverImage imageWithFrame:coverImageView.frame.size color:[HappyGiftAppDelegate imageFrameColor]];
    
    CATransition *animation = [CATransition animation];
    [animation setDelegate:self];
    [animation setType:kCATransitionFade];
    [animation setDuration:0.2];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [coverImageView.layer addAnimation:animation forKey:@"updateCoverAnimation"];
}

-(void)didImageLoaded:(HGImageData*)image {
    if ([image.url isEqualToString:giftSet.thumb]) {
        [self updateCoverImage:image.image];
    }
}

@end
