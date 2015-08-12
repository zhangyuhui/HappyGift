//
//  HGMainViewGlobalOccasionGiftCollectionItemView.m
//  HappyGift
//
//  Created by Yuhui Zhang on 9/30/11.
//  Copyright 2011 Ztelic Inc. All rights reserved.
//

#import "HGMainViewGlobalOccasionGiftCollectionItemView.h"
#import "HappyGiftAppDelegate.h"
#import "HGImageService.h"
#import "UIImage+Addition.h"
#import "HGGift.h"
#import "HGGiftSet.h"
#import <QuartzCore/QuartzCore.h>

#define kMainViewNewsItemViewHighlightTimer 0.05

@interface HGMainViewGlobalOccasionGiftCollectionItemView()
-(void)initSubViews;
@end


@implementation HGMainViewGlobalOccasionGiftCollectionItemView
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
    [overLayView release];
    [descriptionLabel release];
    [priceLabel release];
    [giftSet release];
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

- (void)setGiftSet:(HGGiftSet *)theGiftSet{
    if (giftSet != theGiftSet){
        [giftSet release];
        giftSet = [theGiftSet retain];
        if (giftSet != nil){
            CGRect titleLabelFrame = titleLabel.frame;
            titleLabelFrame.origin.x = coverImageView.frame.origin.x + coverImageView.frame.size.width + 5.0;
            titleLabelFrame.origin.y = 0.0;
            titleLabelFrame.size.width = self.frame.size.width - titleLabelFrame.origin.x - 5.0;
            
            titleLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:[HappyGiftAppDelegate fontSizeSmall]];
            titleLabel.text = giftSet.name;
            titleLabel.textColor = [UIColor blackColor];
            
            CGSize titleLabelSize = [titleLabel.text sizeWithFont:titleLabel.font constrainedToSize:CGSizeMake(titleLabelFrame.size.width , 60.0)];
            titleLabelFrame.size.height = titleLabelSize.height;
            titleLabel.frame = titleLabelFrame;
            
            descriptionLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeTiny]];
            
            HGGift *theGift = [giftSet.gifts objectAtIndex:0];
            if (theGift.sexyName && ![@"" isEqualToString: theGift.sexyName]) {
                descriptionLabel.text = theGift.sexyName;
            } else {
                descriptionLabel.text = giftSet.manufacturer;
            }
            
            descriptionLabel.textColor = [UIColor lightGrayColor];
            
            CGRect descriptionLabelFrame = descriptionLabel.frame;
            descriptionLabelFrame.origin.x = titleLabelFrame.origin.x;
            descriptionLabelFrame.origin.y = titleLabelFrame.origin.y + titleLabelFrame.size.height + 5.0;
            descriptionLabelFrame.size.width = titleLabelFrame.size.width;
            CGSize descriptionLabelSize = [descriptionLabel.text sizeWithFont:descriptionLabel.font constrainedToSize:CGSizeMake(descriptionLabelFrame.size.width, 40.0)];
            descriptionLabelFrame.size.height = descriptionLabelSize.height;
            descriptionLabel.frame = descriptionLabelFrame;
            
            priceLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeTiny]];
            priceLabel.textColor = [UIColor lightGrayColor];
            if ([giftSet.gifts count] > 1){
                float minPrice = CGFLOAT_MAX;
                float maxPrice = CGFLOAT_MIN;
                for (HGGift* gift in giftSet.gifts){
                    if (minPrice > gift.price){
                        minPrice = gift.price;
                    }else if (maxPrice < gift.price){
                        maxPrice = gift.price;
                    }
                } 
                priceLabel.text = [NSString stringWithFormat:@"¥%.2f-%.2f", minPrice, maxPrice];
            }else{
                HGGift* gift = [giftSet.gifts objectAtIndex:0];
                priceLabel.text = [NSString stringWithFormat:@"¥%.2f", gift.price];
            }
            
            CGRect priceLabelFrame = priceLabel.frame;
            priceLabelFrame.origin.x = descriptionLabelFrame.origin.x;
            priceLabelFrame.origin.y = descriptionLabelFrame.origin.y + descriptionLabelFrame.size.height;
            priceLabelFrame.size.width = descriptionLabelFrame.size.width;
            priceLabel.frame = priceLabelFrame;
                        
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
                if (defaultImage == nil){
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
                    
                    UIImage *theDefaultImage = UIGraphicsGetImageFromCurrentImageContext();
                    UIGraphicsEndImageContext();
                    
                    defaultImage = [theDefaultImage retain];
                }
                coverImageView.image = defaultImage;
            }
        }
    }
}

+ (HGMainViewGlobalOccasionGiftCollectionItemView*)mainViewGlobalOccasionGiftCollectionItemView{
    NSArray* nibViews = [[NSBundle mainBundle] loadNibNamed:@"HGMainViewGlobalOccasionGiftCollectionItemView"
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
