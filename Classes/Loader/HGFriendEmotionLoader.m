//
//  HGFriendEmotionLoader.m
//  HappyGift
//
//  Created by Yujian Weng on 12-7-9.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//

#import "HGFriendEmotionLoader.h"
#import "JSON.h"
#import "HGNetworkHost.h"
#import "HGConstants.h"
#import "HappyGiftAppDelegate.h"
#import "HGLogging.h"
#import "NSString+Addition.h"
#import <sqlite3.h>
#import "HGFriendEmotion.h"
#import "HGLoaderCache.h"
#import "HGLogging.h"
#import "HGUtility.h"
#import "HGRecipientService.h"
#import "HGGiftSet.h"
#import "HGTweet.h"
#import "HGGIFGift.h"

#define kRequestTypeFriendEmotion 0
#define kRequestTypeFriendEmotionForFriend 1
#define kRequestTypeFriendEmotionGIFGiftsForFriend 2

static NSString *kFriendEmotionRequestFormat = @"%@/gift/index.php?route=product/emotion&fri_offset=%d&fri_count=%d&fetch_wishes=0&fetch_music=0&fetch_image=1&fetch_image_offset=0&fetch_image_count=9";
static NSString *kFriendEmotionForFriendRequestFormat = @"%@/gift/index.php?route=product/emotion/one_friend&profile_network=%d&profile_id=%@&product_offset=%d&product_count=%d&fetch_wishes=0&fetch_music=0&fetch_image=0&fetch_real_gift=1";

static NSString *kFriendEmotionGIFGiftsForFriendRequestFormat = @"%@/gift/index.php?route=product/emotion/one_friend&profile_network=%d&profile_id=%@&fetch_image_offset=%d&fetch_image_count=%d&fetch_real_gift=0&fetch_wishes=0&fetch_music=0&fetch_image=1";

@implementation HGFriendEmotionLoader
@synthesize delegate;
@synthesize running;

- (void)dealloc {
    [super dealloc];
}

- (void)cancel {	
    [super cancel];
    running = NO;
}

- (void)requestFriendEmotionWithOffset:(int)offset andCount:(int)count  {
    if (running) {
        return;
    }
    [self cancel];
    requestType = kRequestTypeFriendEmotion;
    requestFriendEmotionsOffset = offset;
    
    NSString* requestString = [NSString stringWithFormat:kFriendEmotionRequestFormat, [HappyGiftAppDelegate backendServiceHost], offset, count];
    
    if (![HGUtility wifiReachable]) {
        NSMutableString* newRequestString = [NSMutableString stringWithString:requestString];
        [newRequestString appendFormat:@"&with_detail=0"];
        requestString = newRequestString;
    }
    
    HGDebug(@"%@", requestString);
    NSURL* requestURL = [NSURL URLWithString:[requestString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    NSMutableDictionary* headers = nil;
    NSString* lastModifiedTime = [self getLastModifiedTimeOfFriendEmotions];
    
    if (lastModifiedTime) {
        headers = [NSMutableDictionary dictionaryWithObject:lastModifiedTime forKey:kHttpHeaderIfModifiedSince];
    }
    
    [super requestByGet:requestURL withHeaders:headers];
}

- (void)requestFriendEmotionForFriend:(int)profileNetwork andProfileId:(NSString*)profileId withOffset:(int)offset andCount:(int)count {
    if (running) {
        return;
    }
    [self cancel];
    requestType = kRequestTypeFriendEmotionForFriend;
    
    NSString* requestString = [NSString stringWithFormat:kFriendEmotionForFriendRequestFormat, [HappyGiftAppDelegate backendServiceHost], profileNetwork, profileId, offset, count];
    
    if (![HGUtility wifiReachable]) {
        NSMutableString* newRequestString = [NSMutableString stringWithString:requestString];
        [newRequestString appendFormat:@"&with_detail=0"];
        requestString = newRequestString;
    }
    
    HGDebug(@"%@", requestString);
    NSURL* requestURL = [NSURL URLWithString:[requestString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    [super requestByGet:requestURL];
}

- (void)requestFriendEmotionGIFGiftsForFriend:(int)profileNetwork andProfileId:(NSString*)profileId withOffset:(int)offset andCount:(int)count {
    if (running) {
        return;
    }
    [self cancel];
    requestType = kRequestTypeFriendEmotionGIFGiftsForFriend;
    
    NSString* requestString = [NSString stringWithFormat:kFriendEmotionGIFGiftsForFriendRequestFormat, [HappyGiftAppDelegate backendServiceHost], profileNetwork, profileId, offset, count];
    
    HGDebug(@"%@", requestString);
    NSURL* requestURL = [NSURL URLWithString:[requestString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    [super requestByGet:requestURL];
}

#pragma mark parsers

- (void)handleFriendEmotionGIFGiftsForFriendResponse:(NSData*)friendEmotionForFriendData {
    NSAutoreleasePool * autoReleasePool = [[NSAutoreleasePool alloc] init];
    HGFriendEmotion* friendEmotion = nil;
    
    NSString* jsonString = [NSString stringWithData:self.data];
    HGDebug(@"%@", jsonString);
    
    if (jsonString != nil && [jsonString isEqualToString:@""] == NO) {
        @try {
            NSDictionary *jsonDictionary = [jsonString JSONValue];
            if (jsonDictionary != nil){
                friendEmotion = [self parseFriendEmotion:jsonDictionary];
            }
        } @catch (NSException* e) {
            HGWarning(@"exception: %@, for %@", e, jsonString);
        } 
    }
    
    if (friendEmotion != nil){
        [self performSelectorOnMainThread:@selector(handleNotifyFriendEmotionGIFGiftsForFriendData:) withObject:[NSDictionary dictionaryWithObjectsAndKeys:friendEmotion, @"friendEmotion", nil] waitUntilDone:YES];
    }else{
        [self performSelectorOnMainThread:@selector(handleNotifyFriendEmotionGIFGiftsForFriendData:) withObject:nil waitUntilDone:YES];
    }
    [autoReleasePool release];
}

- (void)handleFriendEmotionForFriendResponse:(NSData*)friendEmotionForFriendData {
    NSAutoreleasePool * autoReleasePool = [[NSAutoreleasePool alloc] init];
    HGFriendEmotion* friendEmotion = nil;
    
    NSString* jsonString = [NSString stringWithData:self.data];
    HGDebug(@"%@", jsonString);
    
    if (jsonString != nil && [jsonString isEqualToString:@""] == NO) {
        @try {
            NSDictionary *jsonDictionary = [jsonString JSONValue];
            if (jsonDictionary != nil){
                friendEmotion = [self parseFriendEmotion:jsonDictionary];
            }
        } @catch (NSException* e) {
            HGWarning(@"exception: %@, for %@", e, jsonString);
        } 
    }
    
    if (friendEmotion != nil){
        [self performSelectorOnMainThread:@selector(handleNotifyFriendEmotionForFriendData:) withObject:[NSDictionary dictionaryWithObjectsAndKeys:friendEmotion, @"friendEmotion", nil] waitUntilDone:YES];
    }else{
        [self performSelectorOnMainThread:@selector(handleNotifyFriendEmotionForFriendData:) withObject:nil waitUntilDone:YES];
    }
    [autoReleasePool release];
}

- (void)handleFriendEmotionResponse:(NSData*)astroTrendsData {
    NSAutoreleasePool * autoReleasePool = [[NSAutoreleasePool alloc] init];
    NSArray* friendEmotionArray = nil;

    NSString* jsonString = [NSString stringWithData:self.data];
    HGDebug(@"%@", jsonString);
    
    if (kHttpStatusCodeNotModified == [self.response statusCode]) {
        HGDebug(@"FriendEmotions - got 304 not modifed");
        if (requestFriendEmotionsOffset == 0) {
            friendEmotionArray = [self loadFriendEmotionsCache];
        }
    } else {
        if (jsonString != nil && [jsonString isEqualToString:@""] == NO) {
            @try {
                NSDictionary *jsonDictionary = [jsonString JSONValue];
                if (jsonDictionary != nil){
                    friendEmotionArray = [self parseFriendEmotions:jsonDictionary];
                }
            } @catch (NSException* e) {
                HGWarning(@"exception: %@, for %@", e, jsonString);
            } 
        }
        
        if (requestFriendEmotionsOffset == 0 && friendEmotionArray && [friendEmotionArray count] > 0) {
            NSString* lastModifiedField = [self getLastModifiedHeader];
            HGDebug(@"new friendEmotionArray data - lastModified: %@, storing data", lastModifiedField);
            [self saveFriendEmotions:friendEmotionArray andLastModifiedTime:lastModifiedField];
        }
    }
    
    if (friendEmotionArray != nil){
        [self performSelectorOnMainThread:@selector(handleNotifyFriendEmotionData:) withObject:[NSDictionary dictionaryWithObjectsAndKeys:friendEmotionArray, @"friendEmotions", nil] waitUntilDone:YES];
    }else{
        [self performSelectorOnMainThread:@selector(handleNotifyFriendEmotionData:) withObject:nil waitUntilDone:YES];
    }
    [autoReleasePool release];
}

-(HGFriendEmotion*) parseFriendEmotion:(NSDictionary*)jsonDictionary {
    HGFriendEmotion* friendEmotion = [[[HGFriendEmotion alloc] init] autorelease];
    NSDictionary* friendEmotionJsonObj = [jsonDictionary objectForKey:@"emotion"];
    
    HGRecipient* recipient = [[HGRecipient alloc] init];
    recipient.recipientNetworkId = [[friendEmotionJsonObj objectForKey:@"network"] intValue];
    recipient.recipientProfileId = [friendEmotionJsonObj objectForKey:@"profile_id"];
    recipient.recipientName = [friendEmotionJsonObj objectForKey:@"name"];
    recipient.recipientImageUrl = [friendEmotionJsonObj objectForKey:@"profile_image"];
    
    HGRecipientService *recipientService = [HGRecipientService sharedService];
    [recipientService updateSNSRecipientWithDBData:recipient];
    
    if (nil == [recipientService getRecipientWithNetworkId:recipient.recipientNetworkId andProfileId:recipient.recipientProfileId]) {
        [recipientService addRecipient:recipient];
    }
    
    friendEmotion.recipient = recipient;
    [recipient release];
    
    NSString* emotionType = [friendEmotionJsonObj objectForKey:@"emotion_type"];
    if ([emotionType isEqualToString:@"正能量"]) {
        friendEmotion.emotionType = kFriendEmotionTypePositive;
    } else {
        friendEmotion.emotionType = kFriendEmotionTypeNegative;
    }
    
    friendEmotion.score = [[friendEmotionJsonObj objectForKey:@"score"] intValue];
    
    NSMutableArray* tweets = nil;
    
    NSArray* tweetsObj = [[friendEmotionJsonObj objectForKey:@"description"] JSONValue];
    for (NSDictionary* tweetObj in tweetsObj) {
        HGTweet* tweet = [[HGTweet alloc] init];
        tweet.tweetId = [tweetObj objectForKey:@"id"];
        tweet.tweetNetwork = recipient.recipientNetworkId;
        tweet.senderId = [tweetObj objectForKey:@"user_id"];
        tweet.senderName = [tweetObj objectForKey:@"screen_name"];
        tweet.text = [tweetObj objectForKey:@"text"];
        tweet.createTime = [tweetObj objectForKey:@"created_at"];
        tweet.senderImageUrl = recipient.recipientImageUrl;
        
        if (tweet.tweetNetwork == NETWORK_SNS_RENREN) {
            tweet.tweetId = [tweetObj objectForKey:@"source_id"];
            NSString* type = [tweetObj objectForKey:@"type"];
            if ([type isEqualToString:@"image"]) {
                tweet.tweetType = TWEET_TYPE_PHOTO;
            } else if ([type isEqualToString:@"blog"]) {
                tweet.tweetType = TWEET_TYPE_BLOG;
            } else if ([type isEqualToString:@"status"]) {
                tweet.tweetType = TWEET_TYPE_STATUS;
            } else {
                tweet.tweetType = TWEET_TYPE_UNKNOWN;
            }
        } else {
            tweet.tweetType = TWEET_TYPE_STATUS;
        }
        
        
        NSDictionary* originObj = [tweetObj objectForKey:@"origin"];
        
        if (originObj) {
            HGTweet* originTweet = [[HGTweet alloc] init];
            originTweet.tweetId = [originObj objectForKey:@"id"];
            originTweet.tweetNetwork = tweet.tweetNetwork;
            originTweet.senderId = [originObj objectForKey:@"user_id"];
            originTweet.senderName = [originObj objectForKey:@"screen_name"];
            originTweet.text = [originObj objectForKey:@"text"];
            originTweet.createTime = [originObj objectForKey:@"created_at"];
            
            tweet.originTweet = originTweet;
            [originTweet release];
        }
        
        if (tweets == nil) {
            tweets = [[NSMutableArray alloc] init];
        }
        [tweets addObject:tweet];
        [tweet release];
    }
    friendEmotion.tweets = tweets;
    [tweets release];
    
    NSMutableArray* giftSets = nil;
    NSArray* productsJsonArray = [jsonDictionary objectForKey:@"products"];
    for (NSDictionary* productJsonDictionary in productsJsonArray){
        HGGiftSet* giftSet = [[HGGiftSet alloc] initWithProductJsonDictionary:productJsonDictionary];
        if (giftSets == nil){
            giftSets = [[NSMutableArray alloc] init];
        }
        [giftSets addObject:giftSet];
        [giftSet release];
    }
    friendEmotion.giftSets = giftSets;
    [giftSets release];
    
    NSArray* gifGiftsJsonDictionary = [jsonDictionary objectForKey:@"gift_images"];
    NSMutableArray* gifGifts = [[NSMutableArray alloc] init];
    for (NSDictionary* gifGiftJsonDictionary in gifGiftsJsonDictionary) {
        HGGIFGift* gifGift = [[HGGIFGift alloc] initWithGIFGiftJsonDictionary:gifGiftJsonDictionary];
        [gifGifts addObject:gifGift];
        [gifGift release];
    }
    friendEmotion.gifGifts = gifGifts;
    [gifGifts release];
    
    return friendEmotion;
}

-(NSArray*) parseFriendEmotions:(NSDictionary*)jsonDictionary {
    NSMutableArray* friendEmotions = [[[NSMutableArray alloc] init] autorelease];
    
    for (NSDictionary* friendEmotionDictionary in jsonDictionary){
        HGFriendEmotion* friendEmotion = [self parseFriendEmotion:friendEmotionDictionary];
        [friendEmotions addObject:friendEmotion];
    }
        
    return friendEmotions;
}

- (void)handleNotifyFriendEmotionGIFGiftsForFriendData:(NSDictionary*)result {
    running = NO;
    
    HGFriendEmotion* friendEmotion  = [result objectForKey:@"friendEmotion"];
    
    if (friendEmotion != nil) {
        if ([(id)self.delegate respondsToSelector:@selector(friendEmotionLoader:didRequestFriendEmotionGIFGiftsForFriendSucceed:)]) {
            [self.delegate friendEmotionLoader:self didRequestFriendEmotionGIFGiftsForFriendSucceed:friendEmotion];
        }
    } else {
        if ([(id)self.delegate respondsToSelector:@selector(friendEmotionLoader:didRequestFriendEmotionGIFGiftsForFriendFail:)]) {
            [self.delegate friendEmotionLoader:self didRequestFriendEmotionGIFGiftsForFriendFail:nil];
        }
    }
    
    [self end];
}

- (void)handleNotifyFriendEmotionForFriendData:(NSDictionary*)result {
    running = NO;
    
    HGFriendEmotion* friendEmotion  = [result objectForKey:@"friendEmotion"];
    
    if (friendEmotion != nil) {
        if ([(id)self.delegate respondsToSelector:@selector(friendEmotionLoader:didRequestFriendEmotionForFriendSucceed:)]) {
            [self.delegate friendEmotionLoader:self didRequestFriendEmotionForFriendSucceed:friendEmotion];
        }
    } else {
        if ([(id)self.delegate respondsToSelector:@selector(friendEmotionLoader:didRequestFriendEmotionForFriendFail:)]) {
            [self.delegate friendEmotionLoader:self didRequestFriendEmotionForFriendFail:nil];
        }
    }
    
    [self end];
}

- (void)handleNotifyFriendEmotionData:(NSDictionary*)result {
    running = NO;
    
    NSArray* astroTrends  = [result objectForKey:@"friendEmotions"];
    
    if (astroTrends != nil) {
        if ([(id)self.delegate respondsToSelector:@selector(friendEmotionLoader:didRequestFriendEmotionSucceed:)]) {
            [self.delegate friendEmotionLoader:self didRequestFriendEmotionSucceed:astroTrends];
        }
    } else {
        if ([(id)self.delegate respondsToSelector:@selector(friendEmotionLoader:didRequestFriendEmotionFail:)]) {
            [self.delegate friendEmotionLoader:self didRequestFriendEmotionFail:nil];
        }
    }
    
    [self end];
}

#pragma mark overrides
- (void)connectionDidFinishLoading:(NSURLConnection *)conn {
    [super connectionDidFinishLoading:conn];
    if (requestType == kRequestTypeFriendEmotion) {
        [self performSelectorInBackground:@selector(handleFriendEmotionResponse:) withObject:self.data];
    } else if (requestType == kRequestTypeFriendEmotionForFriend) {
        [self performSelectorInBackground:@selector(handleFriendEmotionForFriendResponse:) withObject:self.data];
    } else if (requestType == kRequestTypeFriendEmotionGIFGiftsForFriend) {
        [self performSelectorInBackground:@selector(handleFriendEmotionGIFGiftsForFriendResponse:) withObject:self.data];
    }
}

- (void)connection:(NSURLConnection *)conn didFailWithError:(NSError *)error {
    [super connection:conn didFailWithError:error];
	running = NO;
    if (requestType == kRequestTypeFriendEmotion) {
        if ([(id)self.delegate respondsToSelector:@selector(friendEmotionLoader:didRequestFriendEmotionFail:)]) {
            [self.delegate friendEmotionLoader:self didRequestFriendEmotionFail:[error description]];
        }
    } else if (requestType == kRequestTypeFriendEmotionForFriend) {
        if ([(id)self.delegate respondsToSelector:@selector(friendEmotionLoader:didRequestFriendEmotionForFriendFail:)]) {
            [self.delegate friendEmotionLoader:self didRequestFriendEmotionForFriendFail:[error description]];
        }
    } else if (requestType == kRequestTypeFriendEmotionGIFGiftsForFriend) {
        if ([(id)self.delegate respondsToSelector:@selector(friendEmotionLoader:didRequestFriendEmotionGIFGiftsForFriendFail:)]) {
            [self.delegate friendEmotionLoader:self didRequestFriendEmotionGIFGiftsForFriendFail:[error description]];
        }
    }
}

#pragma persistent response data

-(NSArray*)loadFriendEmotionsCache {
    return [HGLoaderCache loadDataFromLoaderCache:@"friendEmotions"];
}

-(NSString*)getLastModifiedTimeOfFriendEmotions {
    return [HGLoaderCache lastModifiedTimeForKey:kCacheKeyLastModifiedTimeOfFriendEmotions];
}

-(NSArray*) friendEmotionsLoaderCache {
    NSString* lastModifiedTimeOfFriendEmotions = [self getLastModifiedTimeOfFriendEmotions];
    if (lastModifiedTimeOfFriendEmotions && ![@"" isEqualToString:lastModifiedTimeOfFriendEmotions]) {
        return [self loadFriendEmotionsCache];
    } else {
        return nil;
    }
}

-(void)saveFriendEmotions:(NSArray*)friendEmotions andLastModifiedTime:(NSString*)lastModifiedTimeOfEmotions {
    [HGLoaderCache saveDataToLoaderCache:friendEmotions forKey:@"friendEmotions"];
    [HGLoaderCache saveLastModifiedTime:lastModifiedTimeOfEmotions forKey:kCacheKeyLastModifiedTimeOfFriendEmotions];
}

@end
