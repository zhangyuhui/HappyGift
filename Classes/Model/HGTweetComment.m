//
//  HGTweetComment.m
//  HappyGift
//
//  Created by Yujian Weng on 12-8-7.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//

#import "HGTweetComment.h"

NSString* const kTweetCommentCommentId = @"tweet_comment_comment_id";
NSString* const kTweetCommentSenderName = @"tweet_comment_sender_name";
NSString* const kTweetCommentSenderId = @"tweet_comment_sender_id";
NSString* const kTweetCommentSenderImageUrl = @"tweet_comment_sender_image_url";
NSString* const kTweetCommentText = @"tweet_comment_text";
NSString* const kTweetCommentCreateTime = @"tweet_comment_create_time";
NSString* const kTweetCommentOriginTweetNetwork = @"tweet_comment_origin_tweet_network";
NSString* const kTweetCommentOriginTweetId = @"tweet_comment_origin_tweet_id";
NSString* const kTweetCommentOriginTweetType = @"tweet_comment_origin_tweet_type";

@implementation HGTweetComment

@synthesize commentId;
@synthesize senderName;
@synthesize senderId;
@synthesize senderImageUrl;
@synthesize text;
@synthesize createTime;

@synthesize originTweetNetwork;
@synthesize originTweetId;
@synthesize originTweetType;

- (void)dealloc {
    [commentId release];
    [senderName release];
    [senderId release];
    [senderImageUrl release];
    [text release];
    [createTime release];
    [originTweetId release];
    [super dealloc];
}

- (NSString*)description {
    NSMutableString * description = [NSMutableString string];
	[description appendString:@"comment = {\n"];
    [description appendFormat:@"commentId=%@\n", self.commentId];
	[description appendFormat:@"senderName=%@\n", self.senderName];
	[description appendFormat:@"senderId=%@\n", self.senderId];
    [description appendFormat:@"senderImageUrl=%@\n", self.senderImageUrl];
	[description appendFormat:@"text=%@\n", self.text];
	[description appendFormat:@"createTime=%@\n", self.createTime];
    [description appendFormat:@"tweetNetwork=%d\n", self.originTweetNetwork];
    [description appendFormat:@"originTweetId=%@\n", self.originTweetId];
    [description appendFormat:@"originTweetType=%d\n", self.originTweetType];
	[description appendString:@"}\n"];
	return description;
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        self.commentId = [coder decodeObjectForKey:kTweetCommentCommentId];
        self.senderName = [coder decodeObjectForKey:kTweetCommentSenderName];
        self.senderId = [coder decodeObjectForKey:kTweetCommentSenderId];
        self.senderImageUrl = [coder decodeObjectForKey:kTweetCommentSenderImageUrl];
        self.text = [coder decodeObjectForKey:kTweetCommentText];
        self.createTime = [coder decodeObjectForKey:kTweetCommentCreateTime];
        self.originTweetNetwork = [coder decodeIntForKey:kTweetCommentOriginTweetNetwork];
        self.originTweetId = [coder decodeObjectForKey:kTweetCommentOriginTweetId];
        self.originTweetType = [coder decodeIntForKey:kTweetCommentOriginTweetType];
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder*)encoder {
    [encoder encodeObject:commentId forKey:kTweetCommentCommentId];
    [encoder encodeObject:senderName forKey:kTweetCommentSenderName];
    [encoder encodeObject:senderId forKey:kTweetCommentSenderId]; 
    [encoder encodeObject:senderImageUrl forKey:kTweetCommentSenderImageUrl];
    [encoder encodeObject:text forKey:kTweetCommentText];
    [encoder encodeObject:createTime forKey:kTweetCommentCreateTime];
    [encoder encodeInt:originTweetNetwork forKey:kTweetCommentOriginTweetNetwork];
    [encoder encodeObject:originTweetId forKey:kTweetCommentOriginTweetId];
    [encoder encodeInt:originTweetType forKey:kTweetCommentOriginTweetType];
}

@end