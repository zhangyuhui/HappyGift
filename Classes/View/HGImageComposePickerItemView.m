//
//  HGImageComposePickerItemView.m
//  HappyGift
//
//  Created by Yuhui Zhang on 12-7-27.
//  Copyright 2011 Ztelic Inc Inc. All rights reserved.
//

#import "HGImageComposePickerItemView.h"
#import "HappyGiftAppDelegate.h"
#import "UIImage+Addition.h"
#import "HGGift.h"
#import "HGUtility.h"
#import <QuartzCore/QuartzCore.h>

#define kListItemViewHighlightTimer 0.05

@interface HGImageComposePickerItemView()
-(void)initSubViews;
@end


@implementation HGImageComposePickerItemView
@synthesize coverImageView;

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
    [overLayView release];
    [super dealloc];
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    highlightTimer = [NSTimer scheduledTimerWithTimeInterval:kListItemViewHighlightTimer target:self selector:@selector(handleHighlightTimer:) userInfo:nil repeats:NO];
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

+ (HGImageComposePickerItemView*)imageComposePickerItemView {
    NSArray* nibViews = [[NSBundle mainBundle] loadNibNamed:@"HGImageComposePickerItemView"
                                                      owner:self
                                                    options:nil];
    return [nibViews objectAtIndex:0];
}

@end
