//
//  HGGiftsSelectionViewGiftsListCellView.m
//  HappyGift
//
//  Created by Yujian Weng on 12-7-18.
//  Copyright 2011 Ztelic Inc. All rights reserved.
//

#import "HGGiftsSelectionViewGiftsListCellView.h"
#import "HappyGiftAppDelegate.h"
#import "HGImageService.h"
#import "UIImage+Addition.h"
#import "HGGiftSet.h"
#import "HGGift.h"
#import "HGDefines.h"
#import "HGEraseLineLabel.h"
#import <QuartzCore/QuartzCore.h>
#import "HGUtility.h"

@interface HGGiftsSelectionViewGiftsListCellView()
-(void)initSubViews;
@end


@implementation HGGiftsSelectionViewGiftsListCellView
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

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    if (highlighted) {
        if (animated) {
            [UIView animateWithDuration:0.3 animations:^(void) {
                overLayView.alpha = 0.5;
            } ];
        } else {
            overLayView.alpha = 0.5;
        }
    } else {
        if (animated) {
            [UIView animateWithDuration:0.3 animations:^(void) {
                overLayView.alpha =  0.0;
            } ];
        } else {
            overLayView.alpha =  0.0; 
        }
    }
}

- (void)dealloc{
    [coverImageView release];
    [titleLabel release];
    [priceImageView release];
    [descriptionLabel release];
    [overLayView release];
    [giftSet release];
    [priceLabel release];
    [likeCountLabel release];
    [likeCountImageView release];
    [super dealloc];
}

- (void)setGiftSet:(HGGiftSet *)theGiftSet{
    if (giftSet != theGiftSet){
        [giftSet release];
        giftSet = [theGiftSet retain];
        if (giftSet != nil){
            priceLabel.numberOfLines = 1;
            priceLabel.textColor = [UIColor whiteColor];
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
                    priceLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeNormal]];
                }else{
                    if (fabs(minPrice) < 0.005){
                        priceLabel.text = @"免费";
                    }else{
                        priceLabel.text = [NSString stringWithFormat:@"¥%.2f", minPrice];
                    }
                    priceLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeNormal]];
                }
            }else{
                HGGift* gift = [giftSet.gifts objectAtIndex:0];
                if (fabs(gift.price) < 0.005){
                    priceLabel.text = @"免费";
                }else{
                    priceLabel.text = [NSString stringWithFormat:@"¥%.2f", gift.price];
                }
                priceLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeNormal]];
            }
            CGSize priceLabelSize = [priceLabel.text sizeWithFont:priceLabel.font];
            CGRect priceLabelFrame = priceLabel.frame;
            priceLabelFrame.origin.x = self.frame.size.width - priceLabelSize.width - 5.0;
            priceLabelFrame.size.width = priceLabelSize.width;
            priceLabelFrame.origin.y = (48.0 - priceLabelSize.height)/2.0;
            priceLabel.frame = priceLabelFrame;
            
            CGRect priceImageViewFrame = priceImageView.frame;
            priceImageViewFrame.size.width = priceLabelFrame.size.width + 15.0;
            if (priceImageViewFrame.size.width < 50.0){
                priceImageViewFrame.size.width = 50.0;
            }
            priceImageViewFrame.origin.x = self.frame.size.width - priceImageViewFrame.size.width;
            priceImageViewFrame.origin.y = priceLabelFrame.origin.y - 2.0;
            priceImageViewFrame.size.height = priceLabelFrame.size.height + 4.0;
            priceImageView.frame = priceImageViewFrame;
            
            HGGift *theGift = [giftSet.gifts objectAtIndex:0];
            descriptionLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeTiny]];
            descriptionLabel.textColor = [UIColor grayColor];
            if (theGift.sexyName && [@"" isEqualToString: theGift.sexyName] == NO) {
                descriptionLabel.text = theGift.sexyName;
            }else{
                descriptionLabel.text = giftSet.manufacturer;
            }
            if (descriptionLabel.text != nil && [descriptionLabel.text isEqualToString:@""] == NO){
                CGRect descriptionLabelFrame = descriptionLabel.frame;
                descriptionLabelFrame.origin.y = 26.0;
                descriptionLabel.frame = descriptionLabelFrame;
                descriptionLabel.hidden = NO;
            }else{
                descriptionLabel.hidden = YES;
            }
            
            if ([theGift isFreeShippingCost]) {
                freeShippingCostImageView.hidden = NO;
            } else {
                freeShippingCostImageView.hidden = YES;
            }
            
            titleLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:[HappyGiftAppDelegate fontSizeSmall]];
            titleLabel.text = giftSet.name;
            titleLabel.textColor = [UIColor blackColor];
            CGFloat titleLabelWidth = self.frame.size.width - 20.0 - priceLabelSize.width;
            CGRect titleLabelFrame = titleLabel.frame;
            titleLabelFrame.origin.y = 8.0;
            titleLabelFrame.size.width = titleLabelWidth;
            if (descriptionLabel.hidden == YES){
                titleLabel.lineBreakMode = UILineBreakModeClip;
                titleLabel.numberOfLines = 0;
                CGSize titleLabelSize = [titleLabel.text sizeWithFont:titleLabel.font constrainedToSize:CGSizeMake(titleLabelWidth, 40.0) lineBreakMode:UILineBreakModeClip];
                titleLabelFrame.size.height = titleLabelSize.height;
            }else{
                titleLabel.lineBreakMode = UILineBreakModeTailTruncation;
                titleLabel.numberOfLines = 1;
                CGSize titleLabelSize = [@"A" sizeWithFont:titleLabel.font];
                titleLabelFrame.size.height = titleLabelSize.height;
            }
            titleLabel.frame = titleLabelFrame;
            
            int likeCount = 0;
            if ([giftSet.gifts count] > 1){
                for (HGGift* gift in giftSet.gifts){
                    if (likeCount < gift.likeCount){
                        likeCount = gift.likeCount;
                    }
                } 
            }else{
                HGGift* gift = [giftSet.gifts objectAtIndex:0];
                likeCount = gift.likeCount;
            }
            if (likeCount > 0){
                likeCountLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeTiny]];
                likeCountLabel.text = [NSString stringWithFormat:@"%d", likeCount];
                likeCountLabel.textColor = [UIColor grayColor];
                
                likeCountImageView.hidden = NO;
                likeCountLabel.hidden = NO;
                
                CGRect coverImageViewFrame = coverImageView.frame;
                coverImageViewFrame.size.height = self.frame.size.height - 22.0 - coverImageViewFrame.origin.y;
                coverImageView.frame = coverImageViewFrame;
                
                CGRect freeShippingCostImageViewFrame = freeShippingCostImageView.frame;
                freeShippingCostImageViewFrame.origin.y = self.frame.size.height - 22.0 - freeShippingCostImageViewFrame.size.height;
                freeShippingCostImageView.frame = freeShippingCostImageViewFrame;
            }else{
                likeCountImageView.hidden = YES;
                likeCountLabel.hidden = YES;
                
                CGRect coverImageViewFrame = coverImageView.frame;
                coverImageViewFrame.size.height = self.frame.size.height - 7.0 - coverImageViewFrame.origin.y;
                coverImageView.frame = coverImageViewFrame;
                
                CGRect freeShippingCostImageViewFrame = freeShippingCostImageView.frame;
                freeShippingCostImageViewFrame.origin.y = self.frame.size.height - 7.0 - freeShippingCostImageViewFrame.size.height;
                freeShippingCostImageView.frame = freeShippingCostImageViewFrame;
            }
            
            if ([giftSet.gifts count] == 1 && theGift.basePrice > theGift.price){
                basePriceLabel.hidden = NO;
                
                basePriceLabel.textColor = [UIColor whiteColor];
                basePriceLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeTiny]];
                basePriceLabel.textColor = UIColorFromRGB(0xd53d3b);
                basePriceLabel.text = [NSString stringWithFormat:@"¥%.2f", theGift.basePrice];
                
                CGRect tmpFrame = priceLabel.frame;
                tmpFrame.origin.y = 6;
                priceLabel.frame = tmpFrame;
                
                tmpFrame = priceImageView.frame;
                tmpFrame.origin.y = 4;
                priceImageView.frame = tmpFrame;
                
                CGSize basePriceLabelSize = [basePriceLabel.text sizeWithFont:basePriceLabel.font];
                tmpFrame = basePriceLabel.frame;
                tmpFrame.origin.x = self.frame.size.width - basePriceLabelSize.width - 6.0;
                tmpFrame.size.width = basePriceLabelSize.width;
                basePriceLabel.frame = tmpFrame;
            }else{
                basePriceLabel.hidden = YES;
                
                CGRect tmpFrame = priceLabel.frame;
                tmpFrame.origin.y = 10;
                priceLabel.frame = tmpFrame;
                
                tmpFrame = priceImageView.frame;
                tmpFrame.origin.y = 8;
                priceImageView.frame = tmpFrame;
            }
            
            HGImageService *imageService = [HGImageService sharedService];
            UIImage *coverImage = [imageService requestImage:giftSet.cover target:self selector:@selector(didImageLoaded:)];
            if (coverImage != nil){
                coverImageView.image = [coverImage imageWithFrame:coverImageView.frame.size color:[HappyGiftAppDelegate imageFrameColor]];
                coverImageView.alpha = 0.0;
                [UIView animateWithDuration:0.2 animations:^(void) {
                    coverImageView.alpha = 1.0;
                } ];
            }else{
                coverImageView.image = [HGUtility defaultImage:coverImageView.frame.size];
            }
            
            
        }
    }
}

+ (HGGiftsSelectionViewGiftsListCellView*)giftsSelectionViewGiftsListItemView{
    NSArray* nibViews = [[NSBundle mainBundle] loadNibNamed:@"HGGiftsSelectionViewGiftsListCellView"
                                                      owner:self
                                                    options:nil];
    HGGiftsSelectionViewGiftsListCellView* cell = [nibViews objectAtIndex:0];
    [cell initSubViews];
    return [nibViews objectAtIndex:0];
}

#pragma mark  HGImagesService selector
- (void)didImageLoaded:(HGImageData*)image{
    if (image && [image.url isEqualToString:giftSet.cover]) {
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
