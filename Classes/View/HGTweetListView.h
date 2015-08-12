//
//  HGTweetListView.h
//  HappyGift
//
//  Created by Yujian Weng on 12-7-10.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HGTweet;
@protocol HGTweetListViewDelegate;

#define TWEET_LIST_SHOW_COMMENT_OPTION_ALL 0
#define TWEET_LIST_SHOW_COMMENT_OPTION_NONE 1
#define TWEET_LIST_SHOW_COMMENT_OPTION_ONLY_FIRST 2

@interface HGTweetListView : UIView {
    IBOutlet UIButton* closeButton;
    IBOutlet UIScrollView* scrollView;
    NSArray* tweets;
    id<HGTweetListViewDelegate> delegate;
    int showCommentOption;
}

@property (nonatomic, retain) NSArray* tweets;
@property (nonatomic, assign) id<HGTweetListViewDelegate> delegate;
@property (nonatomic, assign) int showCommentOption;

+ (HGTweetListView*)tweetListView;

@end

@protocol HGTweetListViewDelegate<NSObject> 
- (void)tweetListView:(HGTweetListView *)tweetListView didCloseTweetListView:(NSString*)result;
- (void)tweetListView:(HGTweetListView *)tweetListView didCommentTweetAction:(HGTweet *)tweet;
- (void)tweetListView:(HGTweetListView *)tweetListView didForwardTweetAction:(HGTweet *)tweet;
@end
