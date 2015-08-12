//
//  HGTweet.m
//  HappyGift
//
//  Created by Yujian Weng on 12-5-24.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//

#import "HGTweet.h"
#import "HGTweetCommentService.h"

NSString* const kTweetSenderId = @"tweet_senderid";
NSString* const kTweetSenderName = @"tweet_sendername";
NSString* const kTweetText = @"tweet_text";
NSString* const kTweetCreateTime = @"tweet_createtime";
NSString* const kTweetId = @"tweet_id";
NSString* const kTweetNetwork = @"tweet_network";
NSString* const kTweetOriginTweet = @"tweet_origin_tweet";
NSString* const kTweetSenderImageUrl = @"tweet_sender_image_url";
NSString* const kTweetType = @"tweet_tweet_type";
NSString* const kTweetRemoteComments = @"tweet_remote_comments";


@implementation HGTweet

@synthesize senderName;
@synthesize text;
@synthesize createTime;
@synthesize senderId;
@synthesize tweetId;
@synthesize tweetNetwork;
@synthesize originTweet;
@synthesize senderImageUrl;
@synthesize tweetType;
@synthesize remoteComments;

- (void)dealloc {
    [senderName release];
    [text release];
    [createTime release];
    [senderId release];
    [tweetId release];
    [originTweet release];
    [senderImageUrl release];
    [remoteComments release];
    [super dealloc];
}

- (NSArray*)comments {
    NSArray* localComments = [[HGTweetCommentService sharedService] commentsToTweet:self];
    NSMutableArray* allComments = [[NSMutableArray alloc] initWithArray:localComments];
    [allComments addObjectsFromArray:remoteComments];
    return [allComments autorelease];
}

- (NSString*)description {
    NSMutableString * description = [NSMutableString string];
	[description appendString:@"tweet = {\n"];
	[description appendFormat:@"senderName=%@\n", self.senderName];
	[description appendFormat:@"text=%@\n", self.text];
	[description appendFormat:@"createTime=%@\n", self.createTime];
	[description appendFormat:@"senderId=%@\n", self.senderId];
    [description appendFormat:@"tweetId=%@\n", self.tweetId];
    [description appendFormat:@"tweetNetwork=%d\n", self.tweetNetwork];
    [description appendFormat:@"originTweet=%@\n", self.originTweet];
    [description appendFormat:@"senderImageUrl=%@\n", self.senderImageUrl];
    [description appendFormat:@"tweetType=%d\n", self.tweetType];
    [description appendFormat:@"remoteComments=%@\n", self.remoteComments];
	[description appendString:@"}\n"];
	return description;
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        self.senderId = [coder decodeObjectForKey:kTweetSenderId];
        self.senderName = [coder decodeObjectForKey:kTweetSenderName];
        self.text = [coder decodeObjectForKey:kTweetText];
        self.createTime = [coder decodeObjectForKey:kTweetCreateTime];
        self.tweetId = [coder decodeObjectForKey:kTweetId];
        self.tweetNetwork = [coder decodeIntForKey:kTweetNetwork];
        self.originTweet = [coder decodeObjectForKey:kTweetOriginTweet];
        self.senderImageUrl = [coder decodeObjectForKey:kTweetSenderImageUrl];
        self.tweetType = [coder decodeIntForKey:kTweetType];
        self.remoteComments = [coder decodeObjectForKey:kTweetRemoteComments];
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder*)encoder {
    [encoder encodeObject:senderId forKey:kTweetSenderId]; 
    [encoder encodeObject:senderName forKey:kTweetSenderName];
    [encoder encodeObject:text forKey:kTweetText];
    [encoder encodeObject:createTime forKey:kTweetCreateTime];
    [encoder encodeObject:tweetId forKey:kTweetId];
    [encoder encodeInt:tweetNetwork forKey:kTweetNetwork];
    [encoder encodeObject:originTweet forKey:kTweetOriginTweet];
    [encoder encodeObject:senderImageUrl forKey:kTweetSenderImageUrl];
    [encoder encodeInt:tweetType forKey:kTweetType];
    [encoder encodeObject:remoteComments forKey:kTweetRemoteComments];
}

@end