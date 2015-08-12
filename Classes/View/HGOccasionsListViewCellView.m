//
//  HGOccasionsListViewCellView.m
//  HappyGift
//
//  Created by Yuhui Zhang on 8/25/11.
//  Copyright 2011 Ztelic Inc. All rights reserved.
//

#import "HGOccasionsListViewCellView.h"
#import "HGImageService.h"
#import "HGGiftCollectionService.h"
#import "UIImage+Addition.h"
#import "HappyGiftAppDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import "HGUserImageView.h"
#import "HGRecipient.h"
#import "HGUtility.h"
#import "HGOccasionCategory.h"
#import "HGOccasionTag.h"

@interface HGOccasionsListViewCellView()

@end

@implementation HGOccasionsListViewCellView
@synthesize giftCollection;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)layoutSubviews{
	[super layoutSubviews];
}

- (void)dealloc{
    [backgroundImageView release];
    [coverImageView release];
    [nameLabel release];
    [contentLabel release];  
    [giftCollection release];
    [super dealloc];
}

+(HGOccasionsListViewCellView*)occasionsListViewCellView {
    NSArray* nibViews = [[NSBundle mainBundle] loadNibNamed:@"HGOccasionsListViewCellView"
                                                      owner:self
                                                    options:nil];
    return [nibViews objectAtIndex:0];
}


- (void)setGiftCollection:(HGOccasionGiftCollection *)theGiftCollection{
    if (giftCollection != theGiftCollection){
        if (giftCollection != nil){
            [giftCollection release];
            giftCollection = nil;
        }
        giftCollection = [theGiftCollection retain];
    }
   
    if (giftCollection!= nil){
        if (backgroundImageView.image == nil){
            UIImage* backgroundImage = [[UIImage imageNamed:@"gift_group_description_background"] stretchableImageWithLeftCapWidth:6.0 topCapHeight:6.0];
            backgroundImageView.image = backgroundImage;
            UIImage* backgroundHighlightImage = [[UIImage imageNamed:@"gift_group_description_selected_background"] stretchableImageWithLeftCapWidth:6.0 topCapHeight:6.0];
            backgroundImageView.highlightedImage = backgroundHighlightImage;
        }
        nameLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:[HappyGiftAppDelegate fontSizeNormal]];
        nameLabel.textColor = [UIColor blackColor];
        
        contentLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeSmall]];
        contentLabel.textColor = [UIColor grayColor];
        
        nameLabel.text = giftCollection.occasion.recipient.recipientName;
        CGRect contentLabelFrame = contentLabel.frame;
        contentLabelFrame.origin.y = nameLabel.frame.origin.y + nameLabel.frame.size.height + 5.0;
        contentLabel.frame = contentLabelFrame;

        if ([@"birthday" isEqualToString: giftCollection.occasion.occasionCategory.identifier]) {
            contentLabel.text = [HGUtility formatBirthdayText:giftCollection.occasion.eventDate forShortDescription:NO];
            [coverImageView updateUserImageViewWithRecipient:giftCollection.occasion.recipient];
        } else {
            contentLabel.text = [HGUtility formatLongDate:giftCollection.occasion.eventDate];
            [coverImageView updateUserImageViewWithOccasion:giftCollection.occasion];
        }
    }
}

@end
