//
//  HGRecipientSelectionViewCellView.m
//  HappyGift
//
//  Created by Yujian Weng on 12-5-22.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//

#import "HGSentGiftsViewCellView.h"
#import "HGImageService.h"
#import "HappyGiftAppDelegate.h"
#import "UIImage+Addition.h"
#import "HGUserImageView.h"
#import "HGRecipient.h"

@implementation HGSentGiftsViewCellView

@synthesize userImageView;
@synthesize orderCreatedDateLabelView;
@synthesize recipientNameLabelView;
@synthesize statusLabelView;
@synthesize statusImageView;
@synthesize backgroundImageView;

- (void)dealloc{
    self.userImageView = nil;
    self.recipientNameLabelView = nil;
    self.orderCreatedDateLabelView = nil;
    self.statusLabelView = nil;
    self.statusImageView = nil;
    self.backgroundImageView = nil;
    [super dealloc];
}

+(HGSentGiftsViewCellView*)sentGiftCellView {
    NSArray* nibViews = [[NSBundle mainBundle] loadNibNamed:@"HGSentGiftsViewCellView"
                                                      owner:self
                                                    options:nil];
    HGSentGiftsViewCellView* sentGiftsViewCellView = [nibViews objectAtIndex:0];
    if (sentGiftsViewCellView.backgroundImageView.image == nil){
        UIImage* backgroundImage = [[UIImage imageNamed:@"gift_group_description_background"] stretchableImageWithLeftCapWidth:10.0 topCapHeight:10.0];
        sentGiftsViewCellView.backgroundImageView.image = backgroundImage;
        UIImage* backgroundHighlightImage = [[UIImage imageNamed:@"gift_group_description_selected_background"] stretchableImageWithLeftCapWidth:10.0 topCapHeight:10.0];
        sentGiftsViewCellView.backgroundImageView.highlightedImage = backgroundHighlightImage;
    }
    
    return sentGiftsViewCellView;
}

- (void) updateUserImageViewWithRecipient:(HGRecipient*)recipient {
    [userImageView updateUserImageViewWithRecipient:recipient];
}


@end
