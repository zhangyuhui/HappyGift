//
//  HGTweetCommentView.h
//  HappyGift
//
//  Created by Yujian Weng on 12-8-7.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HGUserImageView;
@class HGTweetComment;

@interface HGTweetCommentView : UIView {
    IBOutlet UILabel* userNameLabel;
    IBOutlet UILabel* tweetDateLabel;
    IBOutlet UILabel* tweetTextLabel;
    IBOutlet HGUserImageView* userImageView;
    HGTweetComment* comment;
}

@property (nonatomic, retain) HGTweetComment* comment;

+ (HGTweetCommentView*)tweetCommentView;
@end