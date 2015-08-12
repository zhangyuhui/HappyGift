//
//  HGMainViewVirtualGiftGridView.m
//  HappyGift
//
//  Created by Yujian Weng on 12-6-10.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//

#import "HGMainViewVirtualGiftGridView.h"
#import "HGTrackingService.h"
#import <QuartzCore/QuartzCore.h>
#import "HGDefines.h"
#import "HappyGiftAppDelegate.h"
#import "HGVirtualGiftsView.h"

#define kMainViewGiftCollectionItemViewSpacing 10.0
#define kMainViewGiftCollectionItemViewVerticalSpacing 10.0

@interface HGMainViewVirtualGiftGridView()
-(void)initSubViews;
@end

@implementation HGMainViewVirtualGiftGridView
@synthesize delegate;

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
    [headActionButton addTarget:self action:@selector(handleHeadActionClick:) forControlEvents:UIControlEventTouchUpInside];
    [headActionButton addTarget:self action:@selector(handleHeadActionDown:) forControlEvents:UIControlEventTouchDown];
    [headActionButton addTarget:self action:@selector(handleHeadActionUp:) forControlEvents:UIControlEventTouchUpInside|UIControlEventTouchUpOutside|UIControlEventTouchCancel];   
    
    headTitleLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:[HappyGiftAppDelegate fontSizeLarge]];
    headTitleLabel.text = @"虚拟送礼";
    headTitleLabel.textColor = UIColorFromRGB(0xe23974);
        
       
    const CGFloat leftPadding = 12.0;
    const CGFloat topPadding = 10.0;
    const CGFloat bottomPadding = 12.0;
    
    CGFloat itemViewX = leftPadding;
    CGFloat itemViewY = topPadding;
    
    CGRect contentFrame = contentView.frame;
    contentView.autoresizesSubviews = NO;
            
    HGVirtualGiftsView* gifGiftView = [HGVirtualGiftsView virtualGiftsView];
    CGRect gifGiftViewFrame = gifGiftView.frame;
    gifGiftViewFrame.origin.x = itemViewX - 4.0;
    gifGiftViewFrame.origin.y = itemViewY;
    gifGiftView.frame = gifGiftViewFrame;
    gifGiftView.titleLabel.text = @"虚拟礼物";
    gifGiftView.coverImageView.image = [UIImage imageNamed:@"virtual_gift_gif_gift"];
    [gifGiftView addTarget:self action:@selector(handleGIFGiftViewAction:) forControlEvents:UIControlEventTouchUpInside];
    
    
    HGVirtualGiftsView* diyGiftView = [HGVirtualGiftsView virtualGiftsView];
    CGRect diyGiftViewFrame = diyGiftView.frame;
    diyGiftViewFrame.origin.x = gifGiftView.frame.origin.x + gifGiftView.frame.size.width + kMainViewGiftCollectionItemViewSpacing - 4.0;
    diyGiftViewFrame.origin.y = itemViewY;
    diyGiftView.frame = diyGiftViewFrame;
    diyGiftView.titleLabel.text = @"自制礼物";
    diyGiftView.coverImageView.image = [UIImage imageNamed:@"virtual_gift_diy_gift"];
    [diyGiftView addTarget:self action:@selector(handleDIYGiftViewAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [contentView addSubview:gifGiftView];
    [contentView addSubview:diyGiftView];
    
    itemViewY += diyGiftViewFrame.size.height + bottomPadding;
    
    
    contentFrame.size.height = itemViewY;
            
    contentView.frame = contentFrame;
    CGRect backgroundFrame = backgroundImageView.frame;
    backgroundFrame.size.height = contentFrame.size.height;
    backgroundImageView.frame = backgroundFrame;
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width,
                            contentFrame.size.height + headView.frame.size.height);
        
}

- (void)dealloc{
    [headView release];
    [headBackgroundImageView release];
    [headTitleLabel release];
    [headActionButton release];
    [contentView release];
    [super dealloc];
}

+ (HGMainViewVirtualGiftGridView*)mainViewVirtualGiftGridView{
    NSArray* nibViews = [[NSBundle mainBundle] loadNibNamed:@"HGMainViewVirtualGiftGridView"
                                                      owner:self
                                                    options:nil];
    return [nibViews objectAtIndex:0];    
}

- (void)handleHeadActionClick:(id)sender{
    if ([delegate respondsToSelector:@selector(mainViewVirtualGiftGridViewDidSelectMoreGifts:)]){
        [delegate mainViewVirtualGiftGridViewDidSelectMoreGifts:self];
    }
}

- (void)handleHeadActionDown:(id)sender{
    headBackgroundImageView.highlighted = YES;
}

- (void)handleHeadActionUp:(id)sender{
    headBackgroundImageView.highlighted = NO;
}

- (void)handleGIFGiftViewAction:(id)sender {
    if ([delegate respondsToSelector:@selector(mainViewVirtualGiftGridViewDidSelectGIFGifts:)]){
        [delegate mainViewVirtualGiftGridViewDidSelectGIFGifts:self];
    }
}

- (void)handleDIYGiftViewAction:(id)sender {
    if ([delegate respondsToSelector:@selector(mainViewVirtualGiftGridViewDidSelectDIYGifts:)]){
        [delegate mainViewVirtualGiftGridViewDidSelectDIYGifts:self];
    }
}

@end
