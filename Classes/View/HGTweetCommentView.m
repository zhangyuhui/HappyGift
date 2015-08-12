//
//  HGTweetCommentView.m
//  HappyGift
//
//  Created by Yujian Weng on 12-8-7.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//

#import "HGTweetCommentView.h"
#import "NSDate+Addition.h"
#import "NSString+Addition.h"
#import "HappyGiftAppDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import "HGTweetComment.h"
#import "HGUserImageView.h"
#import "HGRecipient.h"
#import "HGLogging.h"
#import "HGUtility.h"


@interface HGTweetCommentView(private)
-(void)initSubViews;
@end

@implementation HGTweetCommentView
@synthesize comment;

- (void)awakeFromNib {
	[self initSubViews];
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
		[self initSubViews];
    }
    return self;
}

- (void)initSubViews {
    userNameLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:[HappyGiftAppDelegate fontSizeNormal]];
    userNameLabel.textColor = [UIColor blackColor];
    
    tweetDateLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeTiny]];
    tweetDateLabel.textColor = [UIColor lightGrayColor];
    
    tweetTextLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeSmall]];
    tweetTextLabel.textColor = [UIColor darkGrayColor];
}

- (void)dealloc {
    [comment release];
    [userImageView release];
    [super dealloc];
}

+ (HGTweetCommentView*)tweetCommentView{
    NSArray* nibViews = [[NSBundle mainBundle] loadNibNamed:@"HGTweetCommentView"
                                                      owner:self
                                                    options:nil];
    
    HGTweetCommentView* view = [nibViews objectAtIndex:0];
    [view initSubViews];
    
    return view;
}

-(void) setComment:(HGTweetComment*)theComment {
    if (comment != theComment) {
        [comment release];
        comment = [theComment retain];
    }
    
    tweetDateLabel.text = [HGUtility formatTweetDateWithTime:comment.createTime];
    
    CGSize dateSize = [tweetDateLabel.text sizeWithFont:tweetDateLabel.font];
    CGRect tweetDateLabelFrame = tweetDateLabel.frame;
    tweetDateLabelFrame.origin.x = self.frame.size.width - dateSize.width - 5.0;
    tweetDateLabelFrame.size.width = dateSize.width;
    tweetDateLabel.frame = tweetDateLabelFrame;
    
    CGRect userNameLabelFrame = userNameLabel.frame;
    userNameLabelFrame.size.width = tweetDateLabelFrame.origin.x - userNameLabelFrame.origin.x;
    userNameLabel.frame = userNameLabelFrame;
    
    userNameLabel.text = comment.senderName;
    tweetTextLabel.text = comment.text;
    
    if (comment.senderImageUrl && ![@"" isEqualToString:comment.senderImageUrl]) {
        HGRecipient* recipient = [[HGRecipient alloc] init];
        recipient.recipientNetworkId = comment.originTweetNetwork;
        recipient.recipientProfileId = comment.senderId;
        recipient.recipientImageUrl = comment.senderImageUrl;
        [userImageView updateUserImageViewWithRecipient:recipient];
        [userImageView removeTagImage];
        [recipient release];
    }
    
    CGRect tweetTextFrame = tweetTextLabel.frame;
     tweetTextFrame.size.width = self.frame.size.width - 15.0 - userImageView.frame.size.width;
    
    CGSize textSize = [tweetTextLabel.text sizeWithFont:tweetTextLabel.font constrainedToSize:CGSizeMake(tweetTextFrame.size.width, 500.0)];
    tweetTextFrame.size.height = textSize.height;
    tweetTextLabel.frame = tweetTextFrame;
    
    CGFloat viewY = tweetTextFrame.origin.y + tweetTextFrame.size.height + 5.0;
    
    CGRect selfFrame = self.frame;
    selfFrame.size.height = viewY;
    self.frame = selfFrame;   
}
@end
