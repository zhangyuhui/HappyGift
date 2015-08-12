//
//  HGPersonlizedOccasionGiftCollectionLoader.m
//  HappyGift
//
//  Created by Zhang Yuhui on 02/09/12.
//  Copyright 2011 Ztelic Inc. All rights reserved.
//

#import "HGPersonlizedOccasionGiftCollectionLoader.h"
#import "JSON.h"
#import "HGNetworkHost.h"
#import "HGConstants.h"
#import "HGGift.h"
#import "HGGiftSet.h"
#import "HGGiftOccasion.h"
#import "HGOccasionGiftCollection.h"
#import "HGFeaturedGiftCollection.h"
#import "HappyGiftAppDelegate.h"
#import "NSString+Addition.h"
#import <sqlite3.h>
#import "HGTweet.h"
#import "HGRecipient.h"
#import "HGGiftCollectionService.h"
#import "HGLoaderCache.h"
#import "HGRecipientService.h"
#import "HGDefines.h"
#import "HGLogging.h"
#import "HGUtility.h"
#import "HGGIFGift.h"
#import "HGTweetComment.h"

#define kRequestTypeRequestAllPersionalizedOcassion 0
#define kRequestTypeRequestGiftsForOccasion 1
#define kRequestTypeRequestGIFGiftsForOccasion 2

static NSString *kPersonlizedOccasionGiftCollectionRequestFormat = @"%@/gift/index.php?route=product/personal_occasion&fetch_wishes=0&fetch_music=0&fetch_image=1&fetch_image_offset=0&fetch_image_count=12";

static NSString *kPersonalizedOccasionGiftsRequestFormat = @"%@/gift/index.php?route=product/personal_occasion/%@&fri_profile_network=%d&fri_profile_id=%@&product_offset=%d&product_count=6&tag_id=%@&fetch_wishes=0&fetch_music=0&fetch_image=0&fetch_real_gift=1";

static NSString *kPersonalizedOccasionGIFGiftsRequestFormat = @"%@/gift/index.php?route=product/personal_occasion/%@&fri_profile_network=%d&fri_profile_id=%@&fetch_image_offset=%d&fetch_image_count=9&tag_id=%@&fetch_real_gift=0&fetch_wishes=0&fetch_music=0&fetch_image=1";

@interface HGPersonlizedOccasionGiftCollectionLoader()
@end

@implementation HGPersonlizedOccasionGiftCollectionLoader
@synthesize delegate;
@synthesize running;


- (void)dealloc {
    [super dealloc];
}

- (void)cancel {	
    [super cancel];
    running = NO;
}

- (void)requestGiftCollection{
    if (running){
        return;
    }
    [self cancel];
    running = YES;
    requestType = kRequestTypeRequestAllPersionalizedOcassion;
    
    NSString* requestString = [NSString stringWithFormat:kPersonlizedOccasionGiftCollectionRequestFormat, [HappyGiftAppDelegate backendServiceHost]];
    
    if (![HGUtility wifiReachable]) {
        NSMutableString* newRequestString = [NSMutableString stringWithString:requestString];
        [newRequestString appendFormat:@"&with_detail=0"];
        requestString = newRequestString;
    }
    
    HGDebug(@"%@", requestString);
    NSURL* requestURL = [NSURL URLWithString:[requestString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    NSMutableDictionary* headers = nil;
    NSString* lastModifiedTime = [self getLastModifiedTimeOfOccasionGiftCollections];
    
    if (lastModifiedTime) {
        headers = [NSMutableDictionary dictionaryWithObject:lastModifiedTime forKey:kHttpHeaderIfModifiedSince];
    }
    
    [super requestByGet:requestURL withHeaders:headers];
}

- (void)requestGIFGiftsForOccasion:(NSString*)occasion andNetworkId:(int)networkId andProfileId:(NSString*)profileId withOffset:(int)offset andTagId:(NSString*)tagId {
    if (running){
        return;
    }
    [self cancel];
    running = YES;
    requestType = kRequestTypeRequestGIFGiftsForOccasion;
    
    NSString* requestString = [NSString stringWithFormat:kPersonalizedOccasionGIFGiftsRequestFormat, [HappyGiftAppDelegate backendServiceHost], occasion, networkId, profileId, offset, tagId];
    
    HGDebug(@"%@", requestString);
    
    NSURL* requestURL = [NSURL URLWithString:[requestString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    [super requestByGet:requestURL];
}

- (void)requestGiftsForOccasion:(NSString*)occasion andNetworkId:(int)networkId andProfileId:(NSString*)profileId withOffset:(int)offset andTagId:(NSString*)tagId {
    if (running){
        return;
    }
    [self cancel];
    running = YES;
    requestType = kRequestTypeRequestGiftsForOccasion;
    
    NSString* requestString = [NSString stringWithFormat:kPersonalizedOccasionGiftsRequestFormat, [HappyGiftAppDelegate backendServiceHost], occasion, networkId, profileId, offset, tagId];
    
    if (![HGUtility wifiReachable]) {
        NSMutableString* newRequestString = [NSMutableString stringWithString:requestString];
        [newRequestString appendFormat:@"&with_detail=0"];
        requestString = newRequestString;
    }
    
    HGDebug(@"%@", requestString);
    
    NSURL* requestURL = [NSURL URLWithString:[requestString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    [super requestByGet:requestURL];
}


#pragma mark parsers

- (void)handleParseOccasionGiftCollections:(NSData*)giftCollectionsData{
    NSAutoreleasePool * autoReleasePool = [[NSAutoreleasePool alloc] init];
    NSString* jsonString = [NSString stringWithData:self.data];
    HGDebug(@"%@", jsonString);
    NSArray* occasionGiftCollectionsArray = nil;
    
    if (kHttpStatusCodeNotModified == [self.response statusCode]) {
        HGDebug(@"personalized occasiont - got 304 not modifed");
        occasionGiftCollectionsArray = [self loadOccasionGiftCollectionsCache];
    } else {
        if (jsonString != nil && [jsonString isEqualToString:@""] == NO){
            NSDictionary *jsonDictionary = [jsonString JSONValue];
            if (jsonDictionary != nil){
                occasionGiftCollectionsArray = [self parseOccasionGiftCollectionsArray:jsonDictionary];
            }
        }
        
        if (occasionGiftCollectionsArray) {
            if ([occasionGiftCollectionsArray count] > 0) {
                NSString* lastModifiedField = [self getLastModifiedHeader];
                HGDebug(@"new occasionGiftCollections data - lastModified: %@, storing data", lastModifiedField);
                [self saveOccasionGiftCollections:occasionGiftCollectionsArray andLastModifiedTime:lastModifiedField];
            }
        } else {
            HGDebug(@"handle response error, use cached data");
            occasionGiftCollectionsArray = [self loadOccasionGiftCollectionsCache];
        }
    }
    if (occasionGiftCollectionsArray != nil){
        [self performSelectorOnMainThread:@selector(handleNotifyOccasionGiftCollections:) withObject:[NSDictionary dictionaryWithObjectsAndKeys:occasionGiftCollectionsArray, @"occasionGiftCollectionsArray", nil] waitUntilDone:YES];
    }else{
        [self performSelectorOnMainThread:@selector(handleNotifyOccasionGiftCollections:) withObject:nil waitUntilDone:YES];
    }
    [autoReleasePool release];
}

- (void)handleParseGIFGiftsForOccasion:(NSData*)gifts {
    NSAutoreleasePool * autoReleasePool = [[NSAutoreleasePool alloc] init];
    NSString* jsonString = [NSString stringWithData:self.data];
    HGDebug(@"handleParseGIFGiftsForOccasion %d", [jsonString length]);
    
    NSArray* gifGifts = nil;
    
    if (jsonString != nil && [jsonString isEqualToString:@""] == NO){
        NSDictionary *jsonDictionary = [jsonString JSONValue];
        if (jsonDictionary != nil){
            @try {
                NSArray* gifGiftsJsonDictionary = [jsonDictionary objectForKey:@"gift_images"];
                
                NSMutableArray* theGifGifts = [[NSMutableArray alloc] init];
                for (NSDictionary* gifGiftJsonDictionary in gifGiftsJsonDictionary) {
                    HGGIFGift* gifGift = [[HGGIFGift alloc] initWithGIFGiftJsonDictionary:gifGiftJsonDictionary];
                    
                    [theGifGifts addObject:gifGift];
                    [gifGift release];
                }
                gifGifts = [theGifGifts retain];
                [theGifGifts release];
            } @catch (NSException *e) {
                HGDebug(@"exception on handleParseGiftsForOccasion: %@", jsonString);
            } @finally {
                
            }            
        }
    }
    
    if (gifGifts != nil){
        [self performSelectorOnMainThread:@selector(handleNotifyGIFGiftsForOccasion:) withObject:[NSDictionary dictionaryWithObjectsAndKeys:gifGifts, @"gifGiftsForOccasion", nil] waitUntilDone:YES];
    }else{
        [self performSelectorOnMainThread:@selector(handleNotifyGIFGiftsForOccasion:) withObject:nil waitUntilDone:YES];
    }
    [gifGifts release];
    [autoReleasePool release];
}

- (void)handleParseGiftsForOccasion:(NSData*)gifts {
    NSAutoreleasePool * autoReleasePool = [[NSAutoreleasePool alloc] init];
    NSString* jsonString = [NSString stringWithData:self.data];
    HGDebug(@"handleParseGiftsForOccasion %d", [jsonString length]);
    
    NSArray* giftSets = nil;
    
    if (jsonString != nil && [jsonString isEqualToString:@""] == NO){
        NSDictionary *jsonDictionary = [jsonString JSONValue];
        if (jsonDictionary != nil){
            @try {
                NSArray* productsJsonDictionary = [jsonDictionary objectForKey:@"products"];
                NSMutableArray* theGiftSets = [[NSMutableArray alloc] init];
                for (NSDictionary* productJsonDictionary in productsJsonDictionary){
                    HGGiftSet* giftSet = [[HGGiftSet alloc] initWithProductJsonDictionary:productJsonDictionary];
                    [theGiftSets addObject:giftSet];
                    [giftSet release];
                } 
                giftSets = [theGiftSets retain];
                [theGiftSets release];
            } @catch (NSException *e) {
                HGDebug(@"exception on handleParseGiftsForOccasion: %@", jsonString);
            } @finally {
                
            }            
        }
    }
        
    if (giftSets != nil){
        [self performSelectorOnMainThread:@selector(handleNotifyGiftsForOccasion:) withObject:[NSDictionary dictionaryWithObjectsAndKeys:giftSets, @"giftsForOccasion", nil] waitUntilDone:YES];
    }else{
        [self performSelectorOnMainThread:@selector(handleNotifyGiftsForOccasion:) withObject:nil waitUntilDone:YES];
    }
    [giftSets release];
    [autoReleasePool release];
}

- (void)handleNotifyOccasionGiftCollections:(NSDictionary*)occasionGiftCollectionsArrayData{
    running = NO;
    NSArray* occasionGiftCollectionsArray = [occasionGiftCollectionsArrayData objectForKey:@"occasionGiftCollectionsArray"];
    if (occasionGiftCollectionsArray != nil){
        if ([(id)self.delegate respondsToSelector:@selector(personlizedOccasionGiftCollectionLoader:didRequestPersonlizedOccasionGiftCollectionsSucceed:)]) {
            [self.delegate personlizedOccasionGiftCollectionLoader:self didRequestPersonlizedOccasionGiftCollectionsSucceed:occasionGiftCollectionsArray];
        }
    }else{
        if ([(id)self.delegate respondsToSelector:@selector(personlizedOccasionGiftCollectionLoader:didRequestPersonlizedOccasionGiftCollectionsFail:)]) {
            [self.delegate personlizedOccasionGiftCollectionLoader:self didRequestPersonlizedOccasionGiftCollectionsFail:nil];
        }
    }
    [self end];
}

- (void)handleNotifyGiftsForOccasion:(NSDictionary*)giftsForOccasionData{
    running = NO;
    NSArray* giftSets = [giftsForOccasionData objectForKey:@"giftsForOccasion"];
    if (giftSets != nil){
        if ([(id)self.delegate respondsToSelector:@selector(personlizedOccasionGiftCollectionLoader:didRequestGiftsForOccasionSucceed:)]) {
            [self.delegate personlizedOccasionGiftCollectionLoader:self didRequestGiftsForOccasionSucceed:giftSets];
        }
    }else{
        if ([(id)self.delegate respondsToSelector:@selector(personlizedOccasionGiftCollectionLoader:didRequestGiftsForOccasionFail:)]) {
            [self.delegate personlizedOccasionGiftCollectionLoader:self didRequestGiftsForOccasionFail:nil];
        }
    }
    [self end];
}

- (void)handleNotifyGIFGiftsForOccasion:(NSDictionary*)gifGiftsForOccasionData{
    running = NO;
    NSArray* gifGifts = [gifGiftsForOccasionData objectForKey:@"gifGiftsForOccasion"];
    if (gifGifts != nil){
        if ([(id)self.delegate respondsToSelector:@selector(personlizedOccasionGiftCollectionLoader:didRequestGIFGiftsForOccasionSucceed:)]) {
            [self.delegate personlizedOccasionGiftCollectionLoader:self didRequestGIFGiftsForOccasionSucceed:gifGifts];
        }
    }else{
        if ([(id)self.delegate respondsToSelector:@selector(personlizedOccasionGiftCollectionLoader:didRequestGIFGiftsForOccasionFail:)]) {
            [self.delegate personlizedOccasionGiftCollectionLoader:self didRequestGIFGiftsForOccasionFail:nil];
        }
    }
    [self end];
}

-(NSArray*) parseOccasionGiftCollectionsArray:(NSDictionary*)jsonDictionary{
    NSMutableArray* occasionGiftCollectionsArray = [[[NSMutableArray alloc] init] autorelease];
    @try {
        //NSString* error = [jsonDictionary objectForKey:@"error"];
        NSArray* birthdayOccasionsJsonArray = [jsonDictionary objectForKey:@"birthday"];
        NSArray* celebrationOccasionsJsonArray = [jsonDictionary objectForKey:@"celebration"];

        NSMutableArray* birthdayOccasionGiftCollections = [[NSMutableArray alloc] init];
        for (NSDictionary* birthdayOccasionJsonDictionary in birthdayOccasionsJsonArray){
            HGOccasionGiftCollection* birthdayOccasionGiftCollection = [self parseOccasionGiftCollection:birthdayOccasionJsonDictionary];
            if (birthdayOccasionGiftCollection != nil){
                [birthdayOccasionGiftCollections addObject:birthdayOccasionGiftCollection];
            }
        }
        NSMutableArray* celebrationOccasionGiftCollections = [[NSMutableArray alloc] init];
        for (NSDictionary* celebrationOccasionJsonDictionary in celebrationOccasionsJsonArray){
            HGOccasionGiftCollection* celebrationOccasionGiftCollection = [self parseOccasionGiftCollection:celebrationOccasionJsonDictionary];
            if (celebrationOccasionGiftCollection != nil){
                [celebrationOccasionGiftCollections addObject:celebrationOccasionGiftCollection];
            }
        }
        
        [occasionGiftCollectionsArray addObject:birthdayOccasionGiftCollections];
        [occasionGiftCollectionsArray addObject:celebrationOccasionGiftCollections];
        
        [birthdayOccasionGiftCollections release];
        [celebrationOccasionGiftCollections release];
    }@catch (NSException* e) {
        HGDebug(@"Exception happened inside parseOccasionGiftCollectionsArray: %@", e);
    }@finally {
        
    }
    return occasionGiftCollectionsArray;
}

-(HGOccasionGiftCollection*) parseOccasionGiftCollection: (NSDictionary*)occasionGiftCollectionJsonDictionary{
    NSDictionary* occasionJsonDictionary = [occasionGiftCollectionJsonDictionary objectForKey:@"occasion"];
    NSArray* productsJsonDictionary = [occasionGiftCollectionJsonDictionary objectForKey:@"products"];
    NSArray* gifGiftsJsonDictionary = [occasionGiftCollectionJsonDictionary objectForKey:@"gift_images"];
    
    NSMutableArray* giftSets = [[NSMutableArray alloc] init];
    for (NSDictionary* productJsonDictionary in productsJsonDictionary){
        HGGiftSet* giftSet = [[HGGiftSet alloc] initWithProductJsonDictionary:productJsonDictionary];
        [giftSets addObject:giftSet];
        [giftSet release];
    }
    HGOccasionGiftCollection* occasionGiftCollection = [HGOccasionGiftCollection alloc];
    occasionGiftCollection.giftSets = giftSets;
    [giftSets release];
    
    NSMutableArray* gifGifts = [[NSMutableArray alloc] init];
    for (NSDictionary* gifGiftJsonDictionary in gifGiftsJsonDictionary) {
        HGGIFGift* gifGift = [[HGGIFGift alloc] initWithGIFGiftJsonDictionary:gifGiftJsonDictionary];
        
        [gifGifts addObject:gifGift];
        [gifGift release];
    }
    occasionGiftCollection.gifGifts = gifGifts;
    [gifGifts release];
    
    occasionGiftCollection.occasion = [self parseGiftOccasion:occasionJsonDictionary];
    return [occasionGiftCollection autorelease];
}

-(HGGiftOccasion*) parseGiftOccasion:(NSDictionary*)occasionJsonDictionary{
    HGGiftOccasion* giftOccasion = [[HGGiftOccasion alloc] init];
    
    NSString* theDescription = [occasionJsonDictionary objectForKey:@"description"];
    NSString* theUserId = [occasionJsonDictionary objectForKey:@"user_id"];
    NSString* theUserNetworkId = [occasionJsonDictionary objectForKey:@"profile_network"];
    NSString* theUserProfileId = [occasionJsonDictionary objectForKey:@"profile_id"];
    NSString* theUserName = [occasionJsonDictionary objectForKey:@"user_name"];
    NSString* theUserProvince = [occasionJsonDictionary objectForKey:@"province"];
    NSString* theUserCity = [occasionJsonDictionary objectForKey:@"city"];
    NSString* theUserGender = [occasionJsonDictionary objectForKey:@"gender"];
    NSString* theUserImage = [occasionJsonDictionary objectForKey:@"profile_image"];
    NSString* theEventType = [occasionJsonDictionary objectForKey:@"event_type"];
    NSString* theEventDate = [occasionJsonDictionary objectForKey:@"event_date"];
    NSString* theTagId = [occasionJsonDictionary objectForKey:@"tag_id"];
    if (theTagId) {
        giftOccasion.occasionTag = [[HGGiftCollectionService sharedService].occasionTags objectForKey:theTagId];
    }
    
    if (giftOccasion.occasionTag == nil) {
        giftOccasion.occasionTag = [[HGGiftCollectionService sharedService].occasionTags objectForKey:@"129"];
    }
    
    HGOccasionCategory* theOccastionCategory = nil;
    if ([@"birthday" isEqualToString: theEventType]) {
        theOccastionCategory = [[HGGiftCollectionService sharedService].occasionCategories objectForKey:@"birthday"];
    } else if ([@"celebration" isEqualToString: theEventType]) {
        theOccastionCategory = [[HGGiftCollectionService sharedService].occasionCategories objectForKey:@"celebration"];
    }
    
    HGRecipient* recipient = [[HGRecipient alloc] init];
    
    recipient.recipientNetworkId = theUserNetworkId ? [theUserNetworkId intValue] : NETWORK_LOCAL_CONTACT;
    recipient.recipientProfileId = theUserProfileId;
    recipient.recipientName = theUserName;
    recipient.recipientImageUrl = theUserImage;
    
    HGRecipientService *recipientService = [HGRecipientService sharedService];
    
    [recipientService updateSNSRecipientWithDBData:recipient];
    
    if (theEventDate && ![@"" isEqualToString:theEventDate] && [@"birthday" isEqualToString:theEventType]) {
        recipient.recipientBirthday = theEventDate;
    }
    
    if (nil == [recipientService getRecipientWithNetworkId:recipient.recipientNetworkId andProfileId:recipient.recipientProfileId]) {
        [recipientService addRecipient:recipient];
    }
    
    giftOccasion.recipient = recipient;
    [recipient release];
    
    if (theDescription && ![theDescription isEqualToString:@""]) {
        @try {
            NSDictionary *jsonDictionary = [theDescription JSONValue];
            
            if (jsonDictionary) {
                HGTweet* tweet = [[HGTweet alloc] init];
                giftOccasion.eventDescription = [jsonDictionary objectForKey:@"description"];
                tweet.text = [jsonDictionary objectForKey:@"text"];
                tweet.createTime = [jsonDictionary objectForKey:@"created_at"];
                tweet.senderId = [jsonDictionary objectForKey:@"sender"];
                tweet.tweetId = [jsonDictionary objectForKey:@"id"];
                tweet.tweetNetwork = giftOccasion.recipient.recipientNetworkId;
                tweet.senderImageUrl = giftOccasion.recipient.recipientImageUrl;
                tweet.senderName = [jsonDictionary objectForKey:@"sender_name"];
                
                if (tweet.tweetNetwork == NETWORK_SNS_RENREN) {
                    tweet.tweetId = [jsonDictionary objectForKey:@"source_id"];
                    NSString* type = [jsonDictionary objectForKey:@"type"];
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
                
                giftOccasion.tweet = tweet;
                [tweet release];
                
                NSArray* commentsArr = [jsonDictionary objectForKey:@"retweets"];
                NSMutableArray* comments = [[NSMutableArray alloc] init];
                for (NSDictionary* commentObj in commentsArr) {
                    HGTweetComment* comment = [[HGTweetComment alloc] init];
                    
                    comment.originTweetId = tweet.tweetId;
                    comment.originTweetNetwork = tweet.tweetNetwork;
                    comment.originTweetType = tweet.tweetType;
                    
                    comment.senderName = [commentObj objectForKey:@"sender_name"];
                    comment.senderId = [commentObj objectForKey:@"sender"];
                    comment.senderImageUrl = [commentObj objectForKey:@"headImg"];
                    
                    comment.text = [commentObj objectForKey:@"text"];
                    comment.createTime = [commentObj objectForKey:@"created_at"];
                    
                    [comments addObject:comment];
                    [comment release];
                }
                giftOccasion.tweet.remoteComments = comments;
                [comments release];
            }
        }
        @catch (NSException *exception) {
            HGDebug(@"error on parseGiftOccasion:%@", theDescription);
        }
        @finally {
        }
    }

    giftOccasion.occasionCategory = theOccastionCategory;
    giftOccasion.userId = theUserId;
    
    giftOccasion.userProvince = theUserProvince;
    giftOccasion.userCity = theUserCity;
    if (theUserGender != nil){
        if ([theUserGender isEqualToString:@"0"]){
            theUserGender = @"女";
        }else{
            theUserGender = @"男";
        }
    }
    giftOccasion.userGender = theUserGender;
    giftOccasion.eventType = theEventType;
    giftOccasion.eventDate = theEventDate;

    return [giftOccasion autorelease];
}

#pragma mark overrides
- (void)connectionDidFinishLoading:(NSURLConnection *)conn {
    [super connectionDidFinishLoading:conn];
    if (requestType == kRequestTypeRequestAllPersionalizedOcassion) { 
        [self performSelectorInBackground:@selector(handleParseOccasionGiftCollections:) withObject:self.data];
    } else if (requestType == kRequestTypeRequestGiftsForOccasion) {
        [self performSelectorInBackground:@selector(handleParseGiftsForOccasion:) withObject:self.data];
    } else if (requestType == kRequestTypeRequestGIFGiftsForOccasion) {
        [self performSelectorInBackground:@selector(handleParseGIFGiftsForOccasion:) withObject:self.data];
    }
}

- (void)connectionDidReceiveResponse:(NSURLConnection *)conn response:(NSHTTPURLResponse*)response{
    [super connectionDidReceiveResponse:conn response:response];
    
    NSDictionary* headerFields = [response allHeaderFields];
    NSNumber* oauthExpiredField = [headerFields objectForKey:@"OAuth-Expired"];
    if (oauthExpiredField != nil){
        NSUInteger oauthExpiredFieldValue = [oauthExpiredField intValue];
        HGWarning(@"got OAuth-Expired:%d", oauthExpiredFieldValue);
        if ([(id)self.delegate respondsToSelector:@selector(personlizedOccasionGiftCollectionLoader:didRequestPersonlizedOccasionAccessTokenFailed:)]) {
            [self.delegate personlizedOccasionGiftCollectionLoader:self didRequestPersonlizedOccasionAccessTokenFailed:oauthExpiredFieldValue];
        }
    }
}

- (void)connection:(NSURLConnection *)conn didFailWithError:(NSError *)error {
    [super connection:conn didFailWithError:error];
	running = NO;
    if (requestType == kRequestTypeRequestAllPersionalizedOcassion) {
        if ([(id)self.delegate respondsToSelector:@selector(personlizedOccasionGiftCollectionLoader:didRequestPersonlizedOccasionGiftCollectionsFail:)]) {
            [self.delegate personlizedOccasionGiftCollectionLoader:self didRequestPersonlizedOccasionGiftCollectionsFail:nil];
        }
    } else if (requestType == kRequestTypeRequestGiftsForOccasion) {
        if ([(id)self.delegate respondsToSelector:@selector(personlizedOccasionGiftCollectionLoader:didRequestGiftsForOccasionFail:)]) {
            [self.delegate personlizedOccasionGiftCollectionLoader:self didRequestGiftsForOccasionFail:[error description]];
        }
    } else if (requestType == kRequestTypeRequestGIFGiftsForOccasion) {
        if ([(id)self.delegate respondsToSelector:@selector(personlizedOccasionGiftCollectionLoader:didRequestGIFGiftsForOccasionFail:)]) {
            [self.delegate personlizedOccasionGiftCollectionLoader:self didRequestGIFGiftsForOccasionFail:[error description]];
        }
    }
}

#pragma persistent response data

-(NSArray*)loadOccasionGiftCollectionsCache {
    return [HGLoaderCache loadDataFromLoaderCache:kCacheKeyPersonalizedOccasionGiftCollections];
}

-(NSString*)getLastModifiedTimeOfOccasionGiftCollections {
    return [HGLoaderCache lastModifiedTimeForKey:kCacheKeyLastModifiedTimeOfPersonalizedOccasionGiftCollections];
}

-(NSArray*) personalizedOccasionGiftCollectionsLoaderCache {
    NSString* lastModifiedTimeOfPersonalizedOccasionGiftCollections = [self getLastModifiedTimeOfOccasionGiftCollections];
    if (lastModifiedTimeOfPersonalizedOccasionGiftCollections && ![@"" isEqualToString:lastModifiedTimeOfPersonalizedOccasionGiftCollections]) {
        return [self loadOccasionGiftCollectionsCache];
    } else {
        return nil;
    }
}

-(void)saveOccasionGiftCollections:(NSArray*)occasionGiftCollections andLastModifiedTime:(NSString*)lastModifiedTimeOfOccasionGiftCollections {
    [HGLoaderCache saveDataToLoaderCache:occasionGiftCollections forKey:kCacheKeyPersonalizedOccasionGiftCollections];
    [HGLoaderCache saveLastModifiedTime:lastModifiedTimeOfOccasionGiftCollections forKey:kCacheKeyLastModifiedTimeOfPersonalizedOccasionGiftCollections];
}


@end
