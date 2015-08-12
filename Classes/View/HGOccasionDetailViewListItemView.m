//
//  HGOccasionDetailViewListItemView.m
//  HappyGift
//
//  Created by Yuhui Zhang on 9/30/11.
//  Copyright 2011 Ztelic Inc. All rights reserved.
//

#import "HGOccasionDetailViewListItemView.h"
#import "HappyGiftAppDelegate.h"
#import "HGImageService.h"
#import "UIImage+Addition.h"
#import "HGGiftSet.h"
#import "HGGift.h"
#import <QuartzCore/QuartzCore.h>

#define kGiftsGroupSelectionViewGiftsListItemViewHighlightTimer 0.05

@interface HGOccasionDetailViewListItemView()
-(void)initSubViews;
@end


@implementation HGOccasionDetailViewListItemView
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
    [giftSet release];
    [priceImageView release];
    [priceLabel release];
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

- (void)setGiftSet:(HGGiftSet *)theGiftSet{
    if (giftSet != theGiftSet){
        [giftSet release];
        giftSet = [theGiftSet retain];
        if (giftSet != nil){
            titleLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:[HappyGiftAppDelegate fontSizeSmall]];
            titleLabel.text = giftSet.name;
            titleLabel.textColor = [UIColor blackColor];
            
            descriptionLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeTiny]];
            
            HGGift *theGift = [giftSet.gifts objectAtIndex:0];
            if (theGift.sexyName && ![@"" isEqualToString: theGift.sexyName]) {
                descriptionLabel.text = theGift.sexyName;
            } else {
                descriptionLabel.text = giftSet.manufacturer;
            }
            
            descriptionLabel.textColor = [UIColor grayColor];
            
            priceLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeTiny]];
            if ([giftSet.gifts count] > 1){
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
                }else{
                    if (fabs(minPrice) < 0.005){
                        priceLabel.text = @"免费";
                    }else{
                        priceLabel.text = [NSString stringWithFormat:@"¥%.2f", minPrice];
                    }
                }
            }else{
                if (fabs(theGift.price) < 0.005){
                    priceLabel.text = @"免费";
                }else{
                    priceLabel.text = [NSString stringWithFormat:@"¥%.2f", theGift.price];
                }
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
            UIImage *coverImage = [imageService requestImage:giftSet.thumb target:self selector:@selector(didImageLoaded:)];
            if (coverImage != nil){
                coverImageView.image = [coverImage imageWithFrame:coverImageView.frame.size color:[HappyGiftAppDelegate imageFrameColor]];
                
                CATransition *animation = [CATransition animation];
                [animation setDelegate:self];
                [animation setType:kCATransitionFade];
                [animation setDuration:0.2];
                [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
                [coverImageView.layer addAnimation:animation forKey:@"updateCoverAnimation"];
            }else{
                CGSize defaultImageSize = coverImageView.frame.size;
                UIGraphicsBeginImageContext(defaultImageSize);
                
                CGContextRef context = UIGraphicsGetCurrentContext();
                
                CGContextSetAllowsAntialiasing(context, YES);
                CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
                CGContextAddRect(context, CGRectMake(0, 0, defaultImageSize.width, defaultImageSize.height));
                CGContextClosePath(context);
                CGContextFillPath(context);
                
                CGContextSetLineWidth(context, 1.0);
                CGContextSetStrokeColorWithColor(context, [HappyGiftAppDelegate imageFrameColor].CGColor);
                CGContextAddRect(context, CGRectMake(0.0, 0.0, defaultImageSize.width, defaultImageSize.height));
                CGContextClosePath(context);
                CGContextStrokePath(context);
                
                UIImage *defaultImage = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                
                coverImageView.image = defaultImage;
            }
        }
    }
}

+ (HGOccasionDetailViewListItemView*)occasionDetailViewListItemView{
    NSArray* nibViews = [[NSBundle mainBundle] loadNibNamed:@"HGOccasionDetailViewListItemView"
                                                      owner:self
                                                    options:nil];
    return [nibViews objectAtIndex:0];
}

#pragma mark  HGImagesService selector
- (void)didImageLoaded:(HGImageData*)image {
    if ([image.url isEqualToString:giftSet.thumb]) {
        UIImage *coverImage = image.image;
        coverImageView.image = [coverImage imageWithFrame:coverImageView.frame.size color:[HappyGiftAppDelegate imageFrameColor]];
        
        CATransition *animation = [CATransition animation];
        [animation setDelegate:self];
        [animation setType:kCATransitionFade];
        [animation setDuration:0.2];
        [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        [coverImageView.layer addAnimation:animation forKey:@"updateCoverAnimation"];
    }
}

@end
