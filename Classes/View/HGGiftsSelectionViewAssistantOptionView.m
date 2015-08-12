//
//  HGGiftsSelectionViewAssistantOptionView.m
//  HappyGift
//
//  Created by Yuhui Zhang on 9/30/11.
//  Copyright 2011 Ztelic Inc. All rights reserved.
//

#import "HGGiftsSelectionViewAssistantOptionView.h"
#import "HappyGiftAppDelegate.h"
#import "HGImageService.h"
#import "HGDefines.h"
#import "UIImage+Addition.h"
#import "HGGiftAssistantOption.h"
#import <QuartzCore/QuartzCore.h>

#define kGiftsSelectionViewAssistantOptionViewHighlightTimer 0.05

@interface HGGiftsSelectionViewAssistantOptionView()
-(void)initSubViews;
@end


@implementation HGGiftsSelectionViewAssistantOptionView
@synthesize giftAssistantOption;

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
    [giftAssistantOption release];
    [super dealloc];
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    highlightTimer = [NSTimer scheduledTimerWithTimeInterval:kGiftsSelectionViewAssistantOptionViewHighlightTimer target:self selector:@selector(handleHighlightTimer:) userInfo:nil repeats:NO];
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

- (void)setSelected:(BOOL)selected{
    [super setSelected:selected];
    if (selected == YES){
        titleLabel.textColor = UIColorFromRGB(0xd53d3b);
    }else{
        titleLabel.textColor = [UIColor blackColor];
    }
}

- (void)setGiftAssistantOption:(HGGiftAssistantOption *)theGiftAssistantOption{
    if (giftAssistantOption != theGiftAssistantOption){
        [giftAssistantOption release];
        giftAssistantOption = [theGiftAssistantOption retain];
        if (giftAssistantOption != nil){
            titleLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:[HappyGiftAppDelegate fontSizeSmall]];
            titleLabel.text = giftAssistantOption.text;
            titleLabel.textColor = [UIColor blackColor];
                        
            HGImageService *imageService = [HGImageService sharedService];
            UIImage *coverImage = [imageService requestImage:giftAssistantOption.image target:self selector:@selector(didImageLoaded:)];
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

+ (HGGiftsSelectionViewAssistantOptionView*)giftsSelectionViewAssistantOptionView{
    NSArray* nibViews = [[NSBundle mainBundle] loadNibNamed:@"HGGiftsSelectionViewAssistantOptionView"
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
