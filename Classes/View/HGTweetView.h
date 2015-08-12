//
//  HGTweetView.h
//  HappyGift
//
//  Created by Yujian Weng on 12-7-10.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HGUserImageView;
@class HGTweet;
@protocol HGTweetViewDelegate;

@interface HGTweetView : UIView {
    IBOutlet UILabel* userNameLabel;
    IBOutlet UILabel* tweetDateLabel;
    IBOutlet UILabel* tweetTextLabel;
    IBOutlet HGUserImageView* userImageView;
    IBOutlet UIButton* commentButton;
    IBOutlet UIButton* forwardButton;
    HGTweet* tweet;
    
    id<HGTweetViewDelegate> delegate;
    BOOL showCommentButton;
    BOOL showForwardButton;
    BOOL showComments;
}

@property (nonatomic, retain) HGTweet* tweet;
@property (nonatomic, assign) id<HGTweetViewDelegate> delegate;
@property (nonatomic, assign) BOOL showCommentButton;
@property (nonatomic, assign) BOOL showForwardButton;
@property (nonatomic, assign) BOOL showComments;

+ (HGTweetView*)tweetView;
@end

@protocol HGTweetViewDelegate <NSObject>

-(void)tweetView:(HGTweetView*)tweetView didCommentTweetAction:(HGTweet*)tweet;
-(void)tweetView:(HGTweetView*)tweetView didForwardTweetAction:(HGTweet*)tweet;

@end
