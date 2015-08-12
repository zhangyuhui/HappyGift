//
//  HGAstroTrendLoader.m
//  HappyGift
//
//  Created by Yujian Weng on 12-7-4.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//

#import "HGAstroTrendLoader.h"
#import "JSON.h"
#import "HGNetworkHost.h"
#import "HGConstants.h"
#import "HappyGiftAppDelegate.h"
#import "HGLogging.h"
#import "NSString+Addition.h"
#import <sqlite3.h>
#import "HGAstroTrend.h"
#import "HGLoaderCache.h"
#import "HGLogging.h"
#import "HGUtility.h"
#import "HGRecipientService.h"
#import "HGGiftSet.h"
#import "HGSong.h"
#import "HGWish.h"
#import "HGGIFGift.h"

#define kRequestTypeAstroTrend 0
#define kRequestTypeAstroTrendForFriend 1
#define kRequestTypeAstroTrendGIFGiftsForFriend 2

static NSString *kAstroTrendRequestFormat = @"%@/gift/index.php?route=product/astro&fri_offset=%d&fri_count=%d&fetch_wishes=0&fetch_music=0&fetch_image=1&fetch_image_offset=0&fetch_image_count=9";
static NSString *kAstroTrendForFriendRequestFormat = @"%@/gift/index.php?route=product/astro/one_friend&profile_network=%d&profile_id=%@&product_offset=%d&product_count=%d";
static NSString *kAstroTrendGIFGiftsForFriendRequestFormat = @"%@/gift/index.php?route=product/astro/one_friend&profile_network=%d&profile_id=%@&fetch_image_offset=%d&fetch_image_count=%d&fetch_real_gift=0&fetch_wishes=0&fetch_music=0&fetch_image=1";

@implementation HGAstroTrendLoader
@synthesize delegate;
@synthesize running;

- (void)dealloc {
    [super dealloc];
}

- (void)cancel {	
    [super cancel];
    running = NO;
}

- (void)requestAstroTrendWithOffset:(int)offset andCount:(int)count {
    if (running) {
        return;
    }
    [self cancel];
    requestType = kRequestTypeAstroTrend;
    requestAstroTrendsOffset = offset;
    
    NSString* requestString = [NSString stringWithFormat:kAstroTrendRequestFormat, [HappyGiftAppDelegate backendServiceHost], offset, count];
    
    if (![HGUtility wifiReachable]) {
        NSMutableString* newRequestString = [NSMutableString stringWithString:requestString];
        [newRequestString appendFormat:@"&with_detail=0"];
        requestString = newRequestString;
    }
    
    HGDebug(@"%@", requestString);
    NSURL* requestURL = [NSURL URLWithString:[requestString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    NSMutableDictionary* headers = nil;
    if (offset == 0) {
        NSString* lastModifiedTime = [self getLastModifiedTimeOfAstroTrends];
        
        if (lastModifiedTime) {
            headers = [NSMutableDictionary dictionaryWithObject:lastModifiedTime forKey:kHttpHeaderIfModifiedSince];
        }
    }
    
    [super requestByGet:requestURL withHeaders:headers];
}

- (void)requestAstroTrendForFriend:(int)profileNetwork andProfileId:(NSString*)profileId withOffset:(int)offset andCount:(int)count {
    if (running) {
        return;
    }
    [self cancel];
    requestType = kRequestTypeAstroTrendForFriend;
    
    NSString* requestString = [NSString stringWithFormat:kAstroTrendForFriendRequestFormat, [HappyGiftAppDelegate backendServiceHost], profileNetwork, profileId, offset, count];
    
    if (![HGUtility wifiReachable]) {
        NSMutableString* newRequestString = [NSMutableString stringWithString:requestString];
        [newRequestString appendFormat:@"&with_detail=0"];
        requestString = newRequestString;
    }
    
    HGDebug(@"%@", requestString);
    NSURL* requestURL = [NSURL URLWithString:[requestString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    [super requestByGet:requestURL];
}

- (void)requestAstroTrendGIFGiftsForFriend:(int)profileNetwork andProfileId:(NSString*)profileId withOffset:(int)offset andCount:(int)count {
    if (running) {
        return;
    }
    [self cancel];
    requestType = kRequestTypeAstroTrendGIFGiftsForFriend;
    
    NSString* requestString = [NSString stringWithFormat:kAstroTrendGIFGiftsForFriendRequestFormat, [HappyGiftAppDelegate backendServiceHost], profileNetwork, profileId, offset, count];
    
    HGDebug(@"%@", requestString);
    NSURL* requestURL = [NSURL URLWithString:[requestString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    [super requestByGet:requestURL];
}

#pragma mark parsers

- (void)handleAstroTrendForFriendResponse:(NSData*)astroTrendsData {
    NSAutoreleasePool * autoReleasePool = [[NSAutoreleasePool alloc] init];
    HGAstroTrend* astroTrend = nil;
    
    NSString* jsonString = [NSString stringWithData:self.data];
    HGDebug(@"%@", jsonString);
    
    if (jsonString != nil && [jsonString isEqualToString:@""] == NO) {
        @try {
            NSDictionary *jsonDictionary = [jsonString JSONValue];
            if (jsonDictionary != nil){
                astroTrend = [self parseAstroTrend:jsonDictionary];
            }
        } @catch (NSException* e) {
            HGWarning(@"exception: %@, for %@", e, jsonString);
        } 
    }
    
    if (astroTrend != nil){
        [self performSelectorOnMainThread:@selector(handleNotifyAstroTrendForFriendData:) withObject:[NSDictionary dictionaryWithObjectsAndKeys:astroTrend, @"astroTrend", nil] waitUntilDone:YES];
    }else{
        [self performSelectorOnMainThread:@selector(handleNotifyAstroTrendForFriendData:) withObject:nil waitUntilDone:YES];
    }
    [autoReleasePool release];
}

- (void)handleAstroTrendGIFGiftsForFriendResponse:(NSData*)astroTrendsData {
    NSAutoreleasePool * autoReleasePool = [[NSAutoreleasePool alloc] init];
    HGAstroTrend* astroTrend = nil;
    
    NSString* jsonString = [NSString stringWithData:self.data];
    HGDebug(@"%@", jsonString);
    
    if (jsonString != nil && [jsonString isEqualToString:@""] == NO) {
        @try {
            NSDictionary *jsonDictionary = [jsonString JSONValue];
            if (jsonDictionary != nil){
                astroTrend = [self parseAstroTrend:jsonDictionary];
            }
        } @catch (NSException* e) {
            HGWarning(@"exception: %@, for %@", e, jsonString);
        } 
    }
    
    if (astroTrend != nil){
        [self performSelectorOnMainThread:@selector(handleNotifyAstroTrendGIFGiftsForFriendData:) withObject:[NSDictionary dictionaryWithObjectsAndKeys:astroTrend, @"astroTrend", nil] waitUntilDone:YES];
    }else{
        [self performSelectorOnMainThread:@selector(handleNotifyAstroTrendGIFGiftsForFriendData:) withObject:nil waitUntilDone:YES];
    }
    [autoReleasePool release];
}

- (void)handleNotifyAstroTrendForFriendData:(NSDictionary*)result {
    running = NO;
    
    HGAstroTrend* astroTrend  = [result objectForKey:@"astroTrend"];
    
    if (astroTrend != nil) {
        if ([(id)self.delegate respondsToSelector:@selector(astroTrendLoader:didRequestAstroTrendForFriendSucceed:)]) {
            [self.delegate astroTrendLoader:self didRequestAstroTrendForFriendSucceed:astroTrend];
        }
    } else {
        if ([(id)self.delegate respondsToSelector:@selector(astroTrendLoader:didRequestAstroTrendForFriendFail:)]) {
            [self.delegate astroTrendLoader:self didRequestAstroTrendForFriendFail:nil];
        }
    }
    
    [self end];
}

- (void)handleNotifyAstroTrendGIFGiftsForFriendData:(NSDictionary*)result {
    running = NO;
    
    HGAstroTrend* astroTrend  = [result objectForKey:@"astroTrend"];
    
    if (astroTrend != nil) {
        if ([(id)self.delegate respondsToSelector:@selector(astroTrendLoader:didRequestAstroTrendGIFGiftsForFriendSucceed:)]) {
            [self.delegate astroTrendLoader:self didRequestAstroTrendGIFGiftsForFriendSucceed:astroTrend];
        }
    } else {
        if ([(id)self.delegate respondsToSelector:@selector(astroTrendLoader:didRequestAstroTrendGIFGiftsForFriendFail:)]) {
            [self.delegate astroTrendLoader:self didRequestAstroTrendGIFGiftsForFriendFail:nil];
        }
    }
    
    [self end];
}


- (void)handleAstroTrendResponse:(NSData*)astroTrendsData {
    NSAutoreleasePool * autoReleasePool = [[NSAutoreleasePool alloc] init];
    NSArray* astroTrendArray = nil;

    NSString* jsonString = [NSString stringWithData:self.data];
    HGDebug(@"%@", jsonString);
    
    if (kHttpStatusCodeNotModified == [self.response statusCode]) {
        HGDebug(@"AstroTrends - got 304 not modifed");
        if (requestAstroTrendsOffset == 0) {
            astroTrendArray = [self loadAstroTrendsCache];
        }
    } else {
        if (jsonString != nil && [jsonString isEqualToString:@""] == NO) {
            @try {
                NSDictionary *jsonDictionary = [jsonString JSONValue];
                if (jsonDictionary != nil){
                    astroTrendArray = [self parseAstroTrends:jsonDictionary];
                }
            } @catch (NSException* e) {
                HGWarning(@"exception: %@, for %@", e, jsonString);
            } 
        }
        
        if (requestAstroTrendsOffset == 0 && astroTrendArray && [astroTrendArray count] > 0) {
            NSString* lastModifiedField = [self getLastModifiedHeader];
            HGDebug(@"new astroTrendArray data - lastModified: %@, storing data", lastModifiedField);
            [self saveAstroTrends:astroTrendArray andLastModifiedTime:lastModifiedField];
        }
    }
    
    if (astroTrendArray != nil){
        [self performSelectorOnMainThread:@selector(handleNotifyAstroTrendData:) withObject:[NSDictionary dictionaryWithObjectsAndKeys:astroTrendArray, @"astroTrends", nil] waitUntilDone:YES];
    }else{
        [self performSelectorOnMainThread:@selector(handleNotifyAstroTrendData:) withObject:nil waitUntilDone:YES];
    }
    [autoReleasePool release];
}

-(HGAstroTrend*) parseAstroTrend:(NSDictionary*)astroTrendDictionary {
    HGAstroTrend* astroTrend = [[HGAstroTrend alloc] init];
    
    NSDictionary* astroJson = [astroTrendDictionary objectForKey:@"astro"];
    
    astroTrend.astroId = [astroJson objectForKey:@"astro_id"];
    astroTrend.trendId = [astroJson objectForKey:@"trend_id"];
    astroTrend.trendName = [astroJson objectForKey:@"trend_name"];
    astroTrend.trendScore = [[astroJson objectForKey:@"trend_score"] intValue];
    astroTrend.trendSummary = [astroJson objectForKey:@"trend_total"];
    astroTrend.trendDetail = [astroJson objectForKey:@"trend_desc"];
    
    NSMutableArray* giftWishes = [[NSMutableArray alloc] init];
    NSArray* astroWishesJson = [astroTrendDictionary objectForKey:@"wishes"];
    for (NSDictionary* astroWishJson in astroWishesJson){
        HGWish* wish = [[HGWish alloc] init];
        wish.content = [astroWishJson objectForKey:@"content"];
        [giftWishes addObject:wish];
        [wish release];
    }
    astroTrend.giftWishes = giftWishes;
    [giftWishes release];
    
    NSMutableArray* giftSongs = [[NSMutableArray alloc] init];
    NSArray* astroSongsJson = [astroTrendDictionary objectForKey:@"songs"];
    for (NSDictionary* astroSongJson in astroSongsJson){
        NSString* songName = [astroSongJson objectForKey:@"title"];
        NSString* songArtist = [astroSongJson objectForKey:@"artist"];
        NSString* songLink = [astroSongJson objectForKey:@"play_link"];
        HGSong* song = [[HGSong alloc] init];
        song.name = songName;
        song.artist = songArtist;
        song.link = songLink;
        [giftSongs addObject:song];
        [song release];
    }
    astroTrend.giftSongs = giftSongs;
    [giftSongs release];
    
    NSArray* gifGiftsJsonDictionary = [astroTrendDictionary objectForKey:@"gift_images"];
    NSMutableArray* gifGifts = [[NSMutableArray alloc] init];
    for (NSDictionary* gifGiftJsonDictionary in gifGiftsJsonDictionary) {
        HGGIFGift* gifGift = [[HGGIFGift alloc] initWithGIFGiftJsonDictionary:gifGiftJsonDictionary];
        [gifGifts addObject:gifGift];
        [gifGift release];
    }
    astroTrend.gifGifts = gifGifts;
    [gifGifts release];
    
    HGRecipient* recipient = [[HGRecipient alloc] init];
    
    recipient.recipientProfileId = [astroJson objectForKey:@"id"];
    recipient.recipientNetworkId = [[astroJson objectForKey:@"network"] intValue];
    recipient.recipientName = [astroJson objectForKey:@"name"];
    recipient.recipientImageUrl = [astroJson objectForKey:@"profile_image"];
    
    HGRecipientService *recipientService = [HGRecipientService sharedService];
    
    [recipientService updateSNSRecipientWithDBData:recipient];
    
    if (nil == [recipientService getRecipientWithNetworkId:recipient.recipientNetworkId andProfileId:recipient.recipientProfileId]) {
        [recipientService addRecipient:recipient];
    }
    
    astroTrend.recipient = recipient;
    [recipient release];
    
    NSMutableArray* giftSets = nil;
    NSArray* productsJsonArray = [astroTrendDictionary objectForKey:@"products"];
    for (NSDictionary* productJsonDictionary in productsJsonArray){
        HGGiftSet* giftSet = [[HGGiftSet alloc] initWithProductJsonDictionary:productJsonDictionary];
        if (giftSets == nil){
            giftSets = [[NSMutableArray alloc] init];
        }
        [giftSets addObject:giftSet];
        [giftSet release];
    }
    astroTrend.giftSets = giftSets;
    [giftSets release];
    
    return [astroTrend autorelease];
}

-(NSArray*) parseAstroTrends:(NSDictionary*)jsonDictionary {
    NSMutableArray* astroTrends = [[[NSMutableArray alloc] init] autorelease];
    
    for (NSDictionary* astroTrendDictionary in jsonDictionary){
        HGAstroTrend* astroTrend = [self parseAstroTrend:astroTrendDictionary];
        [astroTrends addObject:astroTrend];
    }
        
    return astroTrends;
}

- (void)handleNotifyAstroTrendData:(NSDictionary*)result {
    running = NO;
    
    NSArray* astroTrends  = [result objectForKey:@"astroTrends"];
    
    if (astroTrends != nil) {
        if ([(id)self.delegate respondsToSelector:@selector(astroTrendLoader:didRequestAstroTrendSucceed:)]) {
            [self.delegate astroTrendLoader:self didRequestAstroTrendSucceed:astroTrends];
        }
    } else {
        if ([(id)self.delegate respondsToSelector:@selector(astroTrendLoader:didRequestAstroTrendFail:)]) {
            [self.delegate astroTrendLoader:self didRequestAstroTrendFail:nil];
        }
    }
    
    [self end];
}

#pragma mark overrides
- (void)connectionDidFinishLoading:(NSURLConnection *)conn {
    [super connectionDidFinishLoading:conn];
    if (requestType == kRequestTypeAstroTrend) {
        [self performSelectorInBackground:@selector(handleAstroTrendResponse:) withObject:self.data];
    } else if (requestType == kRequestTypeAstroTrendForFriend) {
        [self performSelectorInBackground:@selector(handleAstroTrendForFriendResponse:) withObject:self.data];
    } else if (requestType == kRequestTypeAstroTrendGIFGiftsForFriend) {
        [self performSelectorInBackground:@selector(handleAstroTrendGIFGiftsForFriendResponse:) withObject:self.data];
    }
}

- (void)connection:(NSURLConnection *)conn didFailWithError:(NSError *)error {
    [super connection:conn didFailWithError:error];
	running = NO;
    if (requestType == kRequestTypeAstroTrend) {
        if ([(id)self.delegate respondsToSelector:@selector(astroTrendLoader:didRequestAstroTrendFail:)]) {
            [self.delegate astroTrendLoader:self didRequestAstroTrendFail:[error description]];
        }
    } else if (requestType == kRequestTypeAstroTrendForFriend) {
        if ([(id)self.delegate respondsToSelector:@selector(astroTrendLoader:didRequestAstroTrendForFriendFail:)]) {
            [self.delegate astroTrendLoader:self didRequestAstroTrendForFriendFail:[error description]];
        }
    } else if (requestType == kRequestTypeAstroTrendGIFGiftsForFriend) {
        if ([(id)self.delegate respondsToSelector:@selector(astroTrendLoader:didRequestAstroTrendGIFGiftsForFriendFail:)]) {
            [self.delegate astroTrendLoader:self didRequestAstroTrendGIFGiftsForFriendFail:[error description]];
        }
    }
}


#pragma persistent response data

-(NSArray*)loadAstroTrendsCache {
    return [HGLoaderCache loadDataFromLoaderCache:@"astroTrends"];
}

-(NSString*)getLastModifiedTimeOfAstroTrends {
    return [HGLoaderCache lastModifiedTimeForKey:kCacheKeyLastModifiedTimeOfAstroTrends];
}

-(NSArray*) astroTrendsLoaderCache {
    NSString* lastModifiedTimeOfAstroTrends = [self getLastModifiedTimeOfAstroTrends];
    if (lastModifiedTimeOfAstroTrends && ![@"" isEqualToString:lastModifiedTimeOfAstroTrends]) {
        return [self loadAstroTrendsCache];
    } else {
        return nil;
    }
}

-(void)saveAstroTrends:(NSArray*)astroTrends andLastModifiedTime:(NSString*)lastModifiedTimeOfAstroTrends {
    [HGLoaderCache saveDataToLoaderCache:astroTrends forKey:@"astroTrends"];
    [HGLoaderCache saveLastModifiedTime:lastModifiedTimeOfAstroTrends forKey:kCacheKeyLastModifiedTimeOfAstroTrends];
}

@end
