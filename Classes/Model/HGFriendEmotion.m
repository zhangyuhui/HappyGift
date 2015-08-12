//
//  HGAstroTrend.m
//  HappyGift
//
//  Created by Yujian Weng on 12-7-9.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//

#import "HGFriendEmotion.h"
#import "HGRecipient.h"

NSString* const kFriendEmotionRecipient = @"friend_emotion_recipient";
NSString* const kFriendEmotionGiftSets = @"friend_emotion_giftsets";
NSString* const kFriendEmotionTweets = @"friend_emotion_tweets";
NSString* const kFriendEmotionEmotionType = @"friend_emotion_emotion_type";
NSString* const kFriendEmotionScore = @"friend_emotion_score";
NSString* const kFriendEmotionGIFGifts = @"friend_emotion_gif_gifts";

const int kFriendEmotionTypePositive = 0;
const int kFriendEmotionTypeNegative = 1;


@implementation HGFriendEmotion

@synthesize recipient;
@synthesize giftSets;
@synthesize gifGifts;
@synthesize tweets;
@synthesize emotionType;
@synthesize score;


- (void)dealloc {
    [recipient release];
    [giftSets release];
    [gifGifts release];
    [tweets release];
    [super dealloc];
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        recipient = [[coder decodeObjectForKey:kFriendEmotionRecipient] retain];
        giftSets = [[coder decodeObjectForKey:kFriendEmotionGiftSets] retain];
        gifGifts = [[coder decodeObjectForKey:kFriendEmotionGIFGifts] retain];
        tweets = [[coder decodeObjectForKey:kFriendEmotionTweets] retain];
        emotionType = [coder decodeIntForKey:kFriendEmotionEmotionType];
        score = [coder decodeIntForKey:kFriendEmotionScore];
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder*)encoder {
    [encoder encodeObject:recipient forKey:kFriendEmotionRecipient]; 
    [encoder encodeObject:giftSets forKey:kFriendEmotionGiftSets]; 
    [encoder encodeObject:gifGifts forKey:kFriendEmotionGIFGifts];
    [encoder encodeObject:tweets forKey:kFriendEmotionTweets];
    [encoder encodeInt:emotionType forKey:kFriendEmotionEmotionType]; 
    [encoder encodeInt:score forKey:kFriendEmotionScore];
}

@end