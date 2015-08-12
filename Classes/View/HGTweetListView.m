//
//  HGTweetListView.m
//  HappyGift
//
//  Created by Yujian Weng on 12-7-10.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//

#import "HGTweetListView.h"
#import "HGProgressView.h"
#import "NSDate+Addition.h"
#import "NSString+Addition.h"
#import "HappyGiftAppDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import "HGTweet.h"
#import "HGTweetView.h"
#import "HGLogging.h"

@interface HGTweetListView(private) <HGTweetViewDelegate>
-(void)initSubViews;
@end

@implementation HGTweetListView
@synthesize delegate;
@synthesize tweets;
@synthesize showCommentOption;

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
    [closeButton addTarget:self action:@selector(handleCloseButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)dealloc {
    [tweets release];
    [super dealloc];
}

+ (HGTweetListView*)tweetListView {
    NSArray* nibViews = [[NSBundle mainBundle] loadNibNamed:@"HGTweetListView"
                                                      owner:self
                                                    options:nil];
    
    HGTweetListView* view = [nibViews objectAtIndex:0];
    [view initSubViews];
    
    return view;
}

-(void) setTweets:(NSArray*)theTweets {
    if (tweets != theTweets) {
        [tweets release];
        tweets = [theTweets retain];
    }
    
    for (UIView* subView in [scrollView subviews]) {
        if ([subView isKindOfClass:[HGTweetView class]] || [subView isKindOfClass:[UIImageView class]]) {
            [subView removeFromSuperview];
        }
    }
    
    int index = 0;
    CGFloat tweetViewY = 0;
    for (HGTweet* tweet in tweets) {
        HGTweetView* view = [HGTweetView tweetView];
        if (showCommentOption ==  TWEET_LIST_SHOW_COMMENT_OPTION_ALL ||
            (showCommentOption == TWEET_LIST_SHOW_COMMENT_OPTION_ONLY_FIRST && index == 0)) {
            view.showCommentButton = YES;
        } else {
            view.showCommentButton = NO;
        }
        
        CGRect tmpFrame = view.frame;
        tmpFrame.origin.y = tweetViewY;
        tmpFrame.size.width = self.frame.size.width;
        view.frame = tmpFrame;
        
        view.tweet = tweet;
        view.delegate = self;
        
        [scrollView addSubview:view];
        
        tweetViewY += view.frame.size.height;
        
        if (![tweet isEqual:[tweets lastObject]]) {
            UIImageView* sepratorView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"gift_delivery_input_line"]];
            tmpFrame = sepratorView.frame;
            tmpFrame.size.width = self.frame.size.width;
            tmpFrame.origin.y = tweetViewY;
            
            sepratorView.frame = tmpFrame;
            [scrollView addSubview:sepratorView];
            [sepratorView release];
        }
        
        tweetViewY += 5.0;
        ++index;
    }

    CGSize size = scrollView.contentSize;
    if (tweetViewY <= scrollView.frame.size.height) {
        size.height = scrollView.frame.size.height + 1.0;
    } else {
        size.height = tweetViewY;
    }
    scrollView.contentSize = size;
}

-(void) handleCloseButtonTouchUpInside:(id)sender {
    if ([delegate respondsToSelector:@selector(tweetListView:didCloseTweetListView:)]) {
        [delegate tweetListView:self didCloseTweetListView:nil];
    }
}

-(void)tweetView:(HGTweetView*)tweetView didCommentTweetAction:(HGTweet*)tweet {
    if ([delegate respondsToSelector:@selector(tweetListView:didCommentTweetAction:)]) {
        [delegate tweetListView:self didCommentTweetAction:tweet];
    }
}

-(void)tweetView:(HGTweetView*)tweetView didForwardTweetAction:(HGTweet*)tweet {
    if ([delegate respondsToSelector:@selector(tweetListView:didForwardTweetAction:)]) {
        [delegate tweetListView:self didForwardTweetAction:tweet];
    }
}

@end
