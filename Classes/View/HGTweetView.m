//
//  HGTweetView.m
//  HappyGift
//
//  Created by Yujian Weng on 12-7-10.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//

#import "HGTweetView.h"
#import "HGTweetCommentView.h"
#import "HGProgressView.h"
#import "NSDate+Addition.h"
#import "NSString+Addition.h"
#import "HappyGiftAppDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import "HGTweet.h"
#import "HGTweetComment.h"
#import "HGUserImageView.h"
#import "HGRecipient.h"
#import "HGLogging.h"
#import "HGUtility.h"
#import "HGShareViewController.h"


@interface HGTweetView(private)
-(void)initSubViews;
@end

@implementation HGTweetView
@synthesize tweet;
@synthesize delegate;
@synthesize showCommentButton;
@synthesize showForwardButton;
@synthesize showComments;

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
    [tweet release];
    [userImageView release];
    [commentButton release];
    [forwardButton release];
    [super dealloc];
}

+ (HGTweetView*)tweetView{
    NSArray* nibViews = [[NSBundle mainBundle] loadNibNamed:@"HGTweetView"
                                                      owner:self
                                                    options:nil];
    
    HGTweetView* view = [nibViews objectAtIndex:0];
    [view initSubViews];
    view.showCommentButton = YES;
    view.showForwardButton = YES;
    view.showComments = YES;
    
    return view;
}

-(void) setShowCommentButton:(BOOL)flag {
    showCommentButton = flag;
    if (!showCommentButton) {
        commentButton.hidden = YES;
    }
}

-(void) setShowForwardButton:(BOOL)flag {
    showForwardButton = flag;
    if (!showForwardButton) {
        forwardButton.hidden = YES;
    }
}

-(void) setTweet:(HGTweet*)theTweet {
    if (tweet != theTweet) {
        [tweet release];
        tweet = [theTweet retain];
    }
    
    tweetDateLabel.text = [HGUtility formatTweetDateWithTime:tweet.createTime];
    
    CGSize dateSize = [tweetDateLabel.text sizeWithFont:tweetDateLabel.font];
    CGRect tweetDateLabelFrame = tweetDateLabel.frame;
    tweetDateLabelFrame.origin.x = self.frame.size.width - dateSize.width - 5.0;
    tweetDateLabelFrame.size.width = dateSize.width;
    tweetDateLabel.frame = tweetDateLabelFrame;
    
    CGRect userNameLabelFrame = userNameLabel.frame;
    userNameLabelFrame.size.width = tweetDateLabelFrame.origin.x - userNameLabelFrame.origin.x;
    userNameLabel.frame = userNameLabelFrame;
    
    userNameLabel.text = tweet.senderName;
    tweetTextLabel.text = tweet.text;
    
    if (tweet.senderImageUrl && ![@"" isEqualToString:tweet.senderImageUrl]) {
        HGRecipient* recipient = [[HGRecipient alloc] init];
        recipient.recipientNetworkId = tweet.tweetNetwork;
        recipient.recipientProfileId = tweet.senderId;
        recipient.recipientImageUrl = tweet.senderImageUrl;
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
    if (tweet.originTweet) {
        
        UILabel* originTweetTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(userImageView.frame.origin.x + userImageView.frame.size.width + 5.0 + 5.0, viewY + 7, tweetTextFrame.size.width - 10, 60.0)];
        originTweetTextLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeSmall]];
        originTweetTextLabel.textColor = [UIColor darkGrayColor];
        originTweetTextLabel.backgroundColor = [UIColor clearColor];
        originTweetTextLabel.numberOfLines = 0;
        
        if (tweet.originTweet.senderName && ![@"" isEqualToString:tweet.originTweet.senderName]) {
            originTweetTextLabel.text = [NSString stringWithFormat:@"%@：%@", tweet.originTweet.senderName, tweet.originTweet.text];
        } else {
            originTweetTextLabel.text = tweet.originTweet.text;
        }
        
        CGRect tmpFrame = originTweetTextLabel.frame;
        
        textSize = [originTweetTextLabel.text sizeWithFont:originTweetTextLabel.font constrainedToSize:CGSizeMake(originTweetTextLabel.frame.size.width, 500.0)];
        tmpFrame.size.height = textSize.height;
        originTweetTextLabel.frame = tmpFrame;
        
        UIImageView* backgroundImage = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"friend_emotion_forward_tweet_background"] stretchableImageWithLeftCapWidth:25.0 topCapHeight:12.0]];
        tmpFrame = backgroundImage.frame;
        tmpFrame.origin.x = userImageView.frame.origin.x + userImageView.frame.size.width + 5.0;
        tmpFrame.origin.y = viewY;
        tmpFrame.size.height = textSize.height + 12.0;
        tmpFrame.size.width = tweetTextLabel.frame.size.width;
        backgroundImage.frame = tmpFrame;
        
        [self addSubview:backgroundImage];
        
        [self addSubview:originTweetTextLabel];
        
        viewY += backgroundImage.frame.size.height + 5.0;
        [originTweetTextLabel release];
        [backgroundImage release];
    }
    
    // Test code:
    //tweet.tweetType = TWEET_TYPE_PHOTO;
    //tweet.tweetId = @"6356084605";
//    tweet.tweetType = TWEET_TYPE_STATUS;
//    tweet.tweetId = @"3756637551";
//    tweet.senderId = @"460126224";
    
//    tweet.tweetType = TWEET_TYPE_BLOG;
//    tweet.tweetId = @"864065427";
    if (showCommentButton && (tweet.tweetNetwork == NETWORK_SNS_WEIBO ||
                              (tweet.tweetNetwork == NETWORK_SNS_RENREN && tweet.tweetType != TWEET_TYPE_UNKNOWN))) {
        [commentButton addTarget:self action:@selector(handleCommentButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [commentButton.titleLabel setFont:[UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeSmall]]];
        CGRect tmpFrame = commentButton.frame;
        tmpFrame.origin.y = viewY;
        tmpFrame.origin.x = self.frame.size.width - tmpFrame.size.width - 5.0;
        viewY += tmpFrame.size.height + 2.0;
        commentButton.frame = tmpFrame;
        commentButton.hidden = NO;
    } else {
        commentButton.hidden = YES;
    }
    
    if (showForwardButton && commentButton.hidden == NO) {
        [forwardButton addTarget:self action:@selector(handleForwardButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [forwardButton.titleLabel setFont:[UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeSmall]]];
        CGRect tmpFrame = forwardButton.frame;
        tmpFrame.origin.x = commentButton.frame.origin.x - tmpFrame.size.width - 5.0;
        tmpFrame.origin.y = commentButton.frame.origin.y;
        forwardButton.frame = tmpFrame;
        forwardButton.hidden = NO;
    } else {
        forwardButton.hidden = YES;
    }
    
    if (showComments && [tweet.comments count] > 0) {
        if (commentButton.hidden == YES) {
            UILabel* commentTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, viewY, self.frame.size.width - 10, 21)];
            [commentTitle setFont:[UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeSmall]]];
            commentTitle.text = @"评论";
            commentTitle.textAlignment = UITextAlignmentRight;
            commentTitle.backgroundColor = [UIColor clearColor];
            [self addSubview:commentTitle];
            viewY += commentTitle.frame.size.height;
            [commentTitle release];
        }
        
        int marginLeft = 10;
        int marginRight = 10;
        UIView* commentsView = [[UIView alloc] initWithFrame:CGRectMake(marginLeft, viewY, self.frame.size.width - marginLeft - marginRight, 40)];
        commentsView.autoresizesSubviews = NO;
        
        int commentsViewY = 10;
        for (HGTweetComment* comment in tweet.comments) {
            HGTweetCommentView* view = [HGTweetCommentView tweetCommentView];
            CGRect tmpFrame = view.frame;
            tmpFrame.origin.y = commentsViewY;
            tmpFrame.origin.x = 0;
            tmpFrame.size.width = commentsView.frame.size.width;
            view.frame = tmpFrame;
            
            view.comment = comment;
            
            [commentsView addSubview:view];
            commentsViewY += view.frame.size.height;
            
            if (![comment isEqual:[tweet.comments lastObject]]) {
                UIImageView* sepratorView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"gift_delivery_input_line"]];
                tmpFrame = sepratorView.frame;
                tmpFrame.origin.x = 3;
                tmpFrame.origin.y = commentsViewY;
                tmpFrame.size.width = commentsView.frame.size.width - 6;
                
                sepratorView.frame = tmpFrame;
                [commentsView addSubview:sepratorView];
                [sepratorView release];
            }
            commentsViewY += 5;
        }
        
        CGRect tmpFrame = commentsView.frame;
        tmpFrame.size.height = commentsViewY;
        commentsView.frame = tmpFrame;
        
        UIImageView* backgroundImage = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"friend_emotion_comments_background"] stretchableImageWithLeftCapWidth:25.0 topCapHeight:12.0]];
        tmpFrame = backgroundImage.frame;
        tmpFrame.origin.x = 0;
        tmpFrame.origin.y = 0;
        tmpFrame.size.height = commentsView.frame.size.height;
        tmpFrame.size.width = commentsView.frame.size.width;
        backgroundImage.frame = tmpFrame;
        
        [commentsView addSubview:backgroundImage];
        [commentsView sendSubviewToBack:backgroundImage];
        
        [self addSubview:commentsView];
        viewY += commentsView.frame.size.height + 5;
    }
    
    CGRect selfFrame = self.frame;
    selfFrame.size.height = viewY;
    self.frame = selfFrame;   
}

-(void) handleCommentButtonAction:(id)sender {
    HGDebug(@"handleCommentButtonAction");
    if ([delegate respondsToSelector:@selector(tweetView:didCommentTweetAction:)]) {
        [delegate tweetView:self didCommentTweetAction:tweet];
    }
}

-(void) handleForwardButtonAction:(id)sender {
    HGDebug(@"handleForwardButtonAction");
    if ([delegate respondsToSelector:@selector(tweetView:didForwardTweetAction:)]) {
        [delegate tweetView:self didForwardTweetAction:tweet];
    }
}
@end
