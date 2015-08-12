//
//  HGMainViewSentGiftsItemView.m
//  HappyGift
//
//  Created by Yuhui Zhang on 9/30/11.
//  Copyright 2011 Ztelic Inc. All rights reserved.
//

#import "HGMainViewSentGiftsItemView.h"
#import "HappyGiftAppDelegate.h"
#import "HGImageService.h"
#import "UIImage+Addition.h"
#import "HGGift.h"
#import "HGGiftOrder.h"
#import <QuartzCore/QuartzCore.h>
#import "HGGiftOrderService.h"
#import "HGUserImageView.h"

#define kMainViewNewsItemViewHighlightTimer 0.05

@interface HGMainViewSentGiftsItemView()
-(void)initSubViews;
@end


@implementation HGMainViewSentGiftsItemView
@synthesize giftOrder;

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
    [giftOrder release];
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

- (void)setGiftOrder:(HGGiftOrder *)theGiftOrder{
    if (giftOrder != theGiftOrder){
        [giftOrder release];
        giftOrder = [theGiftOrder retain];
        if (giftOrder != nil){
            CGRect titleLabelFrame = titleLabel.frame;
            titleLabelFrame.origin.x = coverImageView.frame.origin.x + coverImageView.frame.size.width + 5.0;
            titleLabelFrame.origin.y = 0.0;
            titleLabelFrame.size.width = self.frame.size.width - titleLabelFrame.origin.x - 5.0;
            
            
            titleLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:[HappyGiftAppDelegate fontSizeSmall]];
            titleLabel.text = giftOrder.giftRecipient.recipientName;
            titleLabel.textColor = [UIColor blackColor];
            
            CGSize titleLabelSize = [titleLabel.text sizeWithFont:titleLabel.font constrainedToSize:CGSizeMake(titleLabelFrame.size.width , 60.0)];
            titleLabelFrame.size.height = titleLabelSize.height;
            titleLabel.frame = titleLabelFrame;
            
            descriptionLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeTiny]];
            
            NSString* statusDisplay = nil;
            statusDisplay = [HGGiftOrderService formatOrderStatusText:giftOrder];
            descriptionLabel.text = statusDisplay;
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
            
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            NSDate *date = [formatter dateFromString:giftOrder.orderCreatedDate];
            [formatter setDateFormat:@"M月d日"];
            priceLabel.text = [formatter stringFromDate:date];    
            [formatter release];
            
            CGRect priceLabelFrame = priceLabel.frame;
            priceLabelFrame.origin.x = descriptionLabelFrame.origin.x;
            priceLabelFrame.origin.y = descriptionLabelFrame.origin.y + descriptionLabelFrame.size.height;
            priceLabelFrame.size.width = descriptionLabelFrame.size.width;
            priceLabel.frame = priceLabelFrame;
            
            [coverImageView updateUserImageViewWithRecipient:giftOrder.giftRecipient];
        }
    }
}

+ (HGMainViewSentGiftsItemView*)mainViewSentGiftsItemView{
    NSArray* nibViews = [[NSBundle mainBundle] loadNibNamed:@"HGMainViewSentGiftsItemView"
                                                      owner:self
                                                    options:nil];
    return [nibViews objectAtIndex:0];
}

@end
