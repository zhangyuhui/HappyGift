//
//  HGTweetCommentService.h
//  HappyGift
//
//  Created by Yujian Weng on 12-8-8.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
@class HGTweet;
@class HGTweetComment;

@interface HGTweetCommentService : NSObject {
    NSMutableDictionary* tweetComments;
}

@property(nonatomic, retain) NSMutableDictionary* tweetComments;

+ (HGTweetCommentService*)sharedService;
- (NSArray*) commentsToTweet:(HGTweet*)tweet;
- (void) addComment:(HGTweetComment*)comment toTweet:(HGTweet*)tweet;


@end
