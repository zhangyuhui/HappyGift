//
//  HGAstroTrendListViewCellView.m
//  HappyGift
//
//  Created by Yujian Weng on 12-7-5.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//

#import "HGAstroTrendListViewCellView.h"
#import "HGImageService.h"
#import "UIImage+Addition.h"
#import "HappyGiftAppDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import "HGUserImageView.h"
#import "HGRecipient.h"
#import "HGUtility.h"
#import "HGAstroTrend.h"
#import "HGAstroTrendService.h"

@interface HGAstroTrendListViewCellView()

@end

@implementation HGAstroTrendListViewCellView;
@synthesize astroTrend;
@synthesize nameLabel;
@synthesize descriptionLabel;
@synthesize astroImageView;
@synthesize userImageView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initSubViews];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)initSubViews {
    if (backgroundImageView.image == nil){
        UIImage* backgroundImage = [[UIImage imageNamed:@"gift_group_description_background"] stretchableImageWithLeftCapWidth:6.0 topCapHeight:6.0];
        backgroundImageView.image = backgroundImage;
        UIImage* backgroundHighlightImage = [[UIImage imageNamed:@"gift_group_description_selected_background"] stretchableImageWithLeftCapWidth:6.0 topCapHeight:6.0];
        backgroundImageView.highlightedImage = backgroundHighlightImage;
    }
    
    nameLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:[HappyGiftAppDelegate fontSizeNormal]];
    nameLabel.textColor = [UIColor blackColor];
    descriptionLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeNormal]];
    descriptionLabel.textColor = [UIColor darkGrayColor];
}

- (void)dealloc{
    [backgroundImageView release];
    [userImageView release];
    [nameLabel release];
    [descriptionLabel release];
    [astroTrend release];
    [super dealloc];
}

+ (HGAstroTrendListViewCellView*)astroTrendListViewCellView {
    NSArray* nibViews = [[NSBundle mainBundle] loadNibNamed:@"HGAstroTrendListViewCellView"
                                                      owner:self
                                                    options:nil];
    HGAstroTrendListViewCellView* view = [nibViews objectAtIndex:0];
    [view initSubViews];
    return view;
}


- (void)setAstroTrend:(HGAstroTrend *)theAstroTrend {
    if (astroTrend != theAstroTrend){
        if (astroTrend != nil){
            [astroTrend release];
            astroTrend = nil;
        }
        astroTrend = [theAstroTrend retain];
    }
   
    if (astroTrend != nil) {
        NSDictionary* astroConfig = [[[HGAstroTrendService sharedService] astroConfig] objectForKey:astroTrend.astroId];
        NSString* astroName = [astroConfig objectForKey:@"kAstroName"];

        descriptionLabel.text = astroName;
        
        nameLabel.text = astroTrend.recipient.recipientName;

        [userImageView updateUserImageViewWithAstroTrend:astroTrend];
        
        NSString* astroImage = [astroConfig objectForKey:@"kAstroIcon"];
        astroImageView.image = [UIImage imageNamed:astroImage];
    }
}

@end
