//
//  HGProgressView.m
//  HappyGift
//
//  Created by Yuhui Zhang on 7/27/11.
//  Copyright 2011 Ztelic Inc. All rights reserved.
//

#import "HGProgressView.h"
#import <QuartzCore/QuartzCore.h>

#define PROGRESS_VIEW_HIDE_ANIMATION @"progressViewHideAnimation"

@interface HGProgressView(private)
-(void)initSubViews;
@end

@implementation HGProgressView
@synthesize overlayView;
@synthesize indicatorView;

- (void)awakeFromNib {
	[self initSubViews];
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
		[self initSubViews];
    }
    return self;
}

- (void)initSubViews{
    [self.overlayView.layer setCornerRadius:10.0f];
    [self.overlayView.layer setMasksToBounds:YES];
}

- (void)dealloc{
    [indicatorView release];
    [super dealloc];
}

+ (HGProgressView*)progressView:(CGRect)parentFrame {
    NSArray* nibViews = [[NSBundle mainBundle] loadNibNamed:@"HGProgressView"
                                                      owner:self
                                                    options:nil];
    HGProgressView* progressView = [nibViews objectAtIndex:0];

    CGFloat navigationBarHeight = 44.0;
    
    progressView.autoresizesSubviews = NO;
    
    CGRect progressViewFrame = parentFrame;
    progressViewFrame.origin.x = 0;
    progressViewFrame.origin.y = navigationBarHeight;
    progressViewFrame.size.height = parentFrame.size.height - progressViewFrame.origin.y;
    progressViewFrame.size.width = parentFrame.size.width;
    
    progressView.frame = progressViewFrame;
    
    CGRect indicatorFrame = progressView.indicatorView.frame;
    indicatorFrame.origin.x = (parentFrame.size.width - indicatorFrame.size.width) / 2.0f;
    indicatorFrame.origin.y = (parentFrame.size.height - indicatorFrame.size.height) / 2.0f;
    progressView.indicatorView.frame = indicatorFrame;
    
    CGRect overlayViewFrame = progressView.overlayView.frame;
    overlayViewFrame.origin.x = (parentFrame.size.width - overlayViewFrame.size.width) / 2.0f;
    overlayViewFrame.origin.y = (parentFrame.size.height - overlayViewFrame.size.height) / 2.0f;
    progressView.overlayView.frame = overlayViewFrame;
    
    return progressView;
}

+ (HGProgressView*)progressView{
    NSArray* nibViews = [[NSBundle mainBundle] loadNibNamed:@"HGProgressView"
                                                      owner:self
                                                    options:nil];
    HGProgressView* progressView = [nibViews objectAtIndex:0];
    return progressView;
}


- (void)startAnimation{
    if (self.hidden == YES) {
        self.hidden = NO;
        [indicatorView startAnimating];
    }else{
        if ([indicatorView isAnimating] == NO){
            [indicatorView startAnimating];
        }
    }
}

- (void)stopAnimation{
    if (self.hidden == NO) {
        self.hidden = YES;
        [indicatorView stopAnimating];
    } else {
        if ([indicatorView isAnimating] == YES){
            [indicatorView stopAnimating];
        }
    }
}

- (BOOL)animating{
    return (self.hidden == NO);
}

@end
