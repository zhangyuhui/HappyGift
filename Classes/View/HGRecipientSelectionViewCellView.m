//
//  HGRecipientSelectionViewCellView.m
//  HappyGift
//
//  Created by Yujian Weng on 12-5-18.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//

#import "HGRecipientSelectionViewCellView.h"
#import "HGImageService.h"
#import "HappyGiftAppDelegate.h"
#import "UIImage+Addition.h"
#import "HGRecipient.h"
#import <AddressBook/AddressBook.h>
#import "HGUserImageView.h"

@implementation HGRecipientSelectionViewCellView

@synthesize userImageView;
@synthesize addRecipientView;
@synthesize userNameLabelView;
@synthesize userBirthdayView;
@synthesize backgroundImageView;

- (void)dealloc{
    self.userImageView = nil;
    self.userNameLabelView = nil;
    self.userBirthdayView = nil;
    self.addRecipientView = nil;
    self.backgroundImageView = nil;
    [super dealloc];
}

+(HGRecipientSelectionViewCellView*)recipientCellView {
    NSArray* nibViews = [[NSBundle mainBundle] loadNibNamed:@"HGRecipientSelectionViewCellView"
                                                      owner:self
                                                    options:nil];
    HGRecipientSelectionViewCellView* recipientSelectionViewCellView = [nibViews objectAtIndex:0];
    
    if (recipientSelectionViewCellView.backgroundImageView.image == nil){
        UIImage* backgroundImage = [[UIImage imageNamed:@"gift_group_description_background"] stretchableImageWithLeftCapWidth:10.0 topCapHeight:10.0];
        recipientSelectionViewCellView.backgroundImageView.image = backgroundImage;
        UIImage* backgroundHighlightImage = [[UIImage imageNamed:@"gift_group_description_selected_background"] stretchableImageWithLeftCapWidth:10.0 topCapHeight:10.0];
        recipientSelectionViewCellView.backgroundImageView.highlightedImage = backgroundHighlightImage;
    }
    
    return recipientSelectionViewCellView;
}

- (void) updateUserImageViewWithRecipient:(HGRecipient *)recipient {
    [userImageView updateUserImageViewWithRecipient:recipient];
}

@end
