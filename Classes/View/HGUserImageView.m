//
//  HGRecipientSelectionViewCellView.m
//  HappyGift
//
//  Created by Yujian Weng on 12-5-30.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//

#import "HGUserImageView.h"
#import "HGImageService.h"
#import "HappyGiftAppDelegate.h"
#import "UIImage+Addition.h"
#import "HGRecipient.h"
#import <AddressBook/AddressBook.h>
#import "HGGiftOccasion.h"
#import "HGOccasionTag.h"
#import "HGAstroTrend.h"
#import "HGAstroTrendService.h"
#import "HGFriendEmotion.h" 

static UIImage* defaultUserImage = nil;

@implementation HGUserImageView

@synthesize imageView;
@synthesize tagImageView;
@synthesize backgroundImageView;

- (void)dealloc{
    self.imageView = nil;
    self.tagImageView = nil;
    self.backgroundImageView = nil;
    [recipient release];
    [super dealloc];
}

- (void)awakeFromNib {
	[self initSubViews];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initSubViews];
    }
    
    return self;
}

- (void) initSubViews {
    self.userInteractionEnabled = NO;
    
    int tagImageSize = round(self.frame.size.width * 24 / 62.0);
    if (tagImageSize > 29) {
        tagImageSize = 29;
    }
    int padding = round(4 * self.frame.size.width / 62.0);
    int backgroundSize = self.frame.size.width - tagImageSize / 2 + padding;
    
    self.backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, backgroundSize, backgroundSize)];
    backgroundImageView.image = [UIImage imageNamed:@"user_image_bg"];
    [self addSubview:backgroundImageView];
    
	self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(padding, padding, backgroundSize - 2 * padding, backgroundSize - 2 * padding)];
    imageView.image = [UIImage imageNamed:@"user_default"];
    [self addSubview:imageView];
    
    self.tagImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width - tagImageSize, self.frame.size.height - tagImageSize, tagImageSize, tagImageSize)];
    [self addSubview:tagImageView];
}

- (void) removeTagImage {
    int padding = round(4 * self.frame.size.width / 62.0);
    int backgroundSize = self.frame.size.width;
    self.backgroundImageView.frame = CGRectMake(0, 0, backgroundSize, backgroundSize);
    self.imageView.frame = CGRectMake(padding, padding, backgroundSize - 2 * padding, backgroundSize - 2 * padding);
    self.tagImageView.hidden = YES;
}

- (void) updateUserImageView: (UIImage *)imageData {
    imageView.image = [imageData imageWithFrame:CGSizeMake(self.frame.size.width, self.frame.size.height) color:[HappyGiftAppDelegate imageFrameColor]];
    CATransition *animation = [CATransition animation];
    [animation setType:kCATransitionFade];
    [animation setDuration:0.2];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [imageView.layer addAnimation:animation forKey:@"showUserImage"];
}

- (void) updateUserImageViewWithFriendEmotion:(HGFriendEmotion*) theEmotion {
    if (theEmotion.emotionType == kFriendEmotionTypePositive) {
        [self updateUserImageViewWithRecipient:theEmotion.recipient andTagImage:@"friend_emotion_positive_corner_icon"];
    } else {
        [self updateUserImageViewWithRecipient:theEmotion.recipient andTagImage:@"friend_emotion_negative_corner_icon"];
    }
}

- (void) updateUserImageViewWithOccasion:(HGGiftOccasion*) theOccsaion {
    [self updateUserImageViewWithRecipient:theOccsaion.recipient andTagImage:theOccsaion.occasionTag.cornerIcon];
}

- (void) updateUserImageViewWithAstroTrend:(HGAstroTrend*) astroTrend {
    NSDictionary* trendConfig = [[[HGAstroTrendService sharedService] trendConfig] objectForKey:astroTrend.trendId];
    
    NSString* goodOrBadTrendImage;
    if (astroTrend.trendScore == 5) {
        goodOrBadTrendImage = [trendConfig objectForKey:@"kGoodTrendCornerIcon"];
    } else {
        goodOrBadTrendImage = [trendConfig objectForKey:@"kBadTrendCornerIcon"];
    }
    
    [self updateUserImageViewWithRecipient:astroTrend.recipient andTagImage:goodOrBadTrendImage];
}

- (void) updateUserImageViewWithRecipient:(HGRecipient *)theRecipient andTagImage:(NSString*) tagImageFile {
    if (recipient) {
        [recipient release];
        recipient = nil;
    }
    
    recipient = [theRecipient retain];
    
    NSString* url = theRecipient.recipientImageUrl;
    int networkId = theRecipient.recipientNetworkId;
    
    UIImage *imageData = nil;
    if (url && ![@"" isEqualToString:url]) {
        imageData = [[HGImageService sharedService] requestImage:url target:self selector:@selector(didImagesLoaded:)];
    }
    
    if (networkId == NETWORK_PHONE_CONTACT) {
        if (theRecipient.recipientProfileId && ![theRecipient.recipientProfileId isEqualToString:@""]) {
            ABAddressBookRef addressBook = ABAddressBookCreate();
            ABRecordRef person = ABAddressBookGetPersonWithRecordID(addressBook, [theRecipient.recipientProfileId intValue]);
            if (person) {
                NSData* data = (NSData*)ABPersonCopyImageData(person);
                if (data) {
                    imageData = [UIImage imageWithData:data];
                    [data release];
                }
            }
            CFRelease(addressBook);
        }
    }
    
    if (!imageData){
        if (!defaultUserImage) {
            defaultUserImage = [[UIImage imageNamed:@"user_default"] retain];
        }
        
        imageData = defaultUserImage;
    }
    
    [self updateUserImageView:imageData];
    
    if (tagImageFile && ![@"" isEqualToString: tagImageFile]) {
        tagImageView.hidden = NO;
        tagImageView.image = [UIImage imageNamed:tagImageFile];
    } else {
        tagImageView.hidden = YES;
    }
}

- (void) updateUserImageViewWithRecipient:(HGRecipient *)theRecipient {
    NSString* tagImageFile = nil;
    
    int networkId = theRecipient.recipientNetworkId;
    if (networkId == NETWORK_SNS_WEIBO) {
        tagImageFile = @"setting_weibo_logo_corner";
    } else if (networkId == NETWORK_SNS_RENREN) {
        tagImageFile = @"setting_renren_logo_corner";
    }
    
    [self updateUserImageViewWithRecipient:theRecipient andTagImage:tagImageFile];
}

#pragma mark  HGImagesService selector
- (void)didImagesLoaded:(HGImageData*)image {
    if ([recipient.recipientImageUrl isEqualToString: image.url]) {
        [self updateUserImageView:image.image];
    }
}

@end
