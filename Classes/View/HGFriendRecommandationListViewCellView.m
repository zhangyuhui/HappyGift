//
//  HGFriendRecommandationListViewCellView.m
//  HappyGift
//
//  Created by Yujian Weng on 12-6-11.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//

#import "HGFriendRecommandationListViewCellView.h"
#import "HGImageService.h"
#import "UIImage+Addition.h"
#import "HappyGiftAppDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import "HGUserImageView.h"
#import "HGRecipient.h"
#import "HGUtility.h"
#import "HGFriendRecommandation.h"

@interface HGFriendRecommandationListViewCellView()

@end

@implementation HGFriendRecommandationListViewCellView;
@synthesize friendRecommandation;

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
    [userImageView release];
    [nameLabel release];
    [descriptionLabel release];
    [friendRecommandation release];
    [super dealloc];
}

+ (HGFriendRecommandationListViewCellView*)friendRecommandationListViewCellView {
    NSArray* nibViews = [[NSBundle mainBundle] loadNibNamed:@"HGFriendRecommandationListViewCellView"
                                                      owner:self
                                                    options:nil];
    return [nibViews objectAtIndex:0];
}


- (void)setFriendRecommandation:(HGFriendRecommandation *)theFriendRecommandation {
    if (friendRecommandation != theFriendRecommandation){
        if (friendRecommandation != nil){
            [friendRecommandation release];
            friendRecommandation = nil;
        }
        friendRecommandation = [theFriendRecommandation retain];
    }
   
    if (friendRecommandation != nil) {
        if (backgroundImageView.image == nil){
            UIImage* backgroundImage = [[UIImage imageNamed:@"gift_group_description_background"] stretchableImageWithLeftCapWidth:6.0 topCapHeight:6.0];
            backgroundImageView.image = backgroundImage;
            UIImage* backgroundHighlightImage = [[UIImage imageNamed:@"gift_group_description_selected_background"] stretchableImageWithLeftCapWidth:6.0 topCapHeight:6.0];
            backgroundImageView.highlightedImage = backgroundHighlightImage;
        }
        nameLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:[HappyGiftAppDelegate fontSizeNormal]];
        nameLabel.textColor = [UIColor blackColor];
        
        descriptionLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeSmall]];
        descriptionLabel.textColor = [UIColor grayColor];
        
        nameLabel.text = friendRecommandation.recipient.recipientName;

        [userImageView updateUserImageViewWithRecipient:friendRecommandation.recipient];
    }
}

@end
