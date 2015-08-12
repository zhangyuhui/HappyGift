//
//  HGTweet.h
//  HappyGift
//
//  Created by Yujian Weng on 12-5-24.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#define TWEET_TYPE_UNKNOWN 0
#define TWEET_TYPE_STATUS 1
#define TWEET_TYPE_PHOTO 2
#define TWEET_TYPE_BLOG 3

@interface HGTweet: NSObject <NSCoding> {
    NSString*  senderId;
    NSString*  senderName;
    NSString*  text;
    NSString*  createTime;
    
    NSString*  tweetId;
    int        tweetNetwork;
    HGTweet*   originTweet;
    NSString*  senderImageUrl;
    int tweetType;
    
    NSArray*   remoteComments;
}

@property (nonatomic, retain) NSString*  senderId;
@property (nonatomic, retain) NSString*  senderName;
@property (nonatomic, retain) NSString*  text;
@property (nonatomic, retain) NSString*  createTime;

@property (nonatomic, retain) NSString*  tweetId;
@property (nonatomic, assign) int        tweetNetwork;
@property (nonatomic, retain) HGTweet*  originTweet;
@property (nonatomic, retain) NSString* senderImageUrl;
@property (nonatomic, assign) int tweetType;
@property (nonatomic, retain) NSArray* remoteComments;

- (NSArray*)comments;

@end
