//
//  HGFavoriteLoader.m
//  HappyGift
//
//  Created by Zhang Yuhui on 12-6-20.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//

#import "HGFavoriteLoader.h"
#import "JSON.h"
#import "HGNetworkHost.h"
#import "HGConstants.h"
#import "HGLogging.h"
#import "HGGift.h"
#import "HappyGiftAppDelegate.h"
#import "NSString+Addition.h"
#import <sqlite3.h>
#import "HGGiftSet.h"
#import "HGDefines.h"
#import "HGLoaderCache.h"

static NSString *kFavoriteLikeRequestFormat = @"%@/gift/index.php?route=user/like&product_id=%@";
static NSString *kFavoriteUnLikeRequestFormat = @"%@/gift/index.php?route=user/unlike&product_id=%@";
static NSString *kFavoriteMyLikeProductsRequestFormat = @"%@/gift/index.php?route=user/like/products";
static NSString *kFavoriteMyLikeIdsRequestFormat = @"%@/gift/index.php?route=user/like";

#define kFavoriteRequestLike   0
#define kFavoriteRequestUnLike 1
#define kFavoriteRequestMyLikeProducts 2
#define kFavoriteRequestMyLikeIds 3

@interface HGFavoriteLoader()
@end

@implementation HGFavoriteLoader
@synthesize delegate;
@synthesize running;

- (void)dealloc {
    [requestGiftId release];
    [super dealloc];
}

- (void)cancel {	
    [super cancel];
    running = NO;
}

- (void)requestGiftLike:(NSString*)giftId{
    if (running) {
        return;
    }
    [self cancel];
    running = YES;
    if (requestGiftId != nil){
        [requestGiftId release];
        requestGiftId = nil;
    }
    requestType = kFavoriteRequestLike;
    requestGiftId = [giftId retain];
    NSString* requestString = [NSString stringWithFormat:kFavoriteLikeRequestFormat, [HappyGiftAppDelegate backendServiceHost], requestGiftId];
    HGDebug(@"%@", requestString);
    NSURL* requestURL = [NSURL URLWithString:[requestString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [super requestByGet:requestURL];
}

- (void)requestGiftUnLike:(NSString*)giftId{
    if (running) {
        return;
    }
    [self cancel];
    running = YES;
    if (requestGiftId != nil){
        [requestGiftId release];
        requestGiftId = nil;
    }
    requestType = kFavoriteRequestUnLike;
    requestGiftId = [giftId retain];
    NSString* requestString = [NSString stringWithFormat:kFavoriteUnLikeRequestFormat, [HappyGiftAppDelegate backendServiceHost], requestGiftId];
    HGDebug(@"%@", requestString);
    NSURL* requestURL = [NSURL URLWithString:[requestString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [super requestByGet:requestURL];    
}

- (void)requestMyLikeProducts {
    if (running) {
        return;
    }
    [self cancel];
    running = YES;
    requestType = kFavoriteRequestMyLikeProducts;
    NSString* requestString = [NSString stringWithFormat:kFavoriteMyLikeProductsRequestFormat, [HappyGiftAppDelegate backendServiceHost]];
    HGDebug(@"%@", requestString);
    NSURL *requestURL = [NSURL URLWithString:[requestString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    NSMutableDictionary* headers = nil;
    NSString* lastModifiedTime = [self getLastModifiedTimeOfMyLikeProducts];
    
    if (lastModifiedTime) {
        headers = [NSMutableDictionary dictionaryWithObject:lastModifiedTime forKey:kHttpHeaderIfModifiedSince];
    }
    
    [super requestByGet:requestURL withHeaders:headers];
}

- (void)requestMyLikeIds {
    if (running) {
        return;
    }
    [self cancel];
    running = YES;
    requestType = kFavoriteRequestMyLikeIds;
    NSString* requestString = [NSString stringWithFormat:kFavoriteMyLikeIdsRequestFormat, [HappyGiftAppDelegate backendServiceHost]];
    HGDebug(@"%@", requestString);
    NSURL *requestURL = [NSURL URLWithString:[requestString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSMutableDictionary* headers = nil;
    NSString* lastModifiedTime = [self getLastModifiedTimeOfMyLikeIds];
    
    if (lastModifiedTime) {
        headers = [NSMutableDictionary dictionaryWithObject:lastModifiedTime forKey:kHttpHeaderIfModifiedSince];
    }
    
    [super requestByGet:requestURL withHeaders:headers];
}

#pragma mark parser

- (void)handleParseMyLikesIdResponse:(NSData *)myLikesIdResponseData {
    NSAutoreleasePool * autoReleasePool = [[NSAutoreleasePool alloc] init];
    NSString* jsonString = [NSString stringWithData:myLikesIdResponseData];
    HGDebug(@"%@", jsonString);
    
    NSSet* myLikes = nil;
    NSString* error = nil;
    
    if (kHttpStatusCodeNotModified == [self.response statusCode]) {
        HGDebug(@"myLike Ids - got 304 not modifed");
        myLikes = [self loadMyLikeIdsCache];
    } else {
        if (jsonString != nil && [jsonString isEqualToString:@""] == NO) {
            @try {
                NSDictionary *jsonDictionary = [jsonString JSONValue];
                if (jsonDictionary != nil) {
                    error = [jsonDictionary objectForKey:@"error"];
                    myLikes = [self parseMyLikesId:jsonDictionary];
                }
                
                if (error && ![@"" isEqualToString:error]) {
                    HGWarning(@"error: ", error);
                }
            } @catch (NSException *e) {
                HGWarning(@"error on handleParseMyLikesIdResponse: %@, %@", e, jsonString);
            }
        }
        
        if (myLikes) {
            if ([myLikes count] > 0) {
                NSString* lastModifiedField = [self getLastModifiedHeader];
                HGDebug(@"new myLike Ids data - lastModified: %@, storing data", lastModifiedField);
                [self saveMyLikeIds:myLikes andLastModifiedTime:lastModifiedField];
            }
        } else {
            HGDebug(@"handle response error, use cached data");
            myLikes = [self loadMyLikeIdsCache];
        }
    }
    
    if (error == nil || [@"" isEqualToString:error]) {
        [self performSelectorOnMainThread:@selector(handleNotifyRequestMyLikesIdResponse:) withObject:[NSDictionary dictionaryWithObjectsAndKeys:myLikes, @"myLikes", nil] waitUntilDone:YES];
    }else{
        [self performSelectorOnMainThread:@selector(handleNotifyRequestMyLikesIdResponse:) withObject:nil waitUntilDone:YES];
    }
    
    [autoReleasePool release];
}

-(NSSet*) parseMyLikesId:(NSDictionary*)jsonDictionary {
    NSSet* myLikesId = nil;
    @try {
        id myLikesObj = [jsonDictionary objectForKey:@"likes"];
        NSArray* myLikesIdArray;
        if ([myLikesObj isKindOfClass:NSDictionary.class]) { 
            NSDictionary* myLikesDictionary = myLikesObj;
            myLikesIdArray = [myLikesDictionary allKeys];
        } else {
            myLikesIdArray = myLikesObj;
        }
        myLikesId = [[NSSet alloc] initWithArray:myLikesIdArray];
    }@catch (NSException* e) {
        HGDebug(@"Exception happened inside parseMyLikesId: %@ %@", e, jsonDictionary);
    }@finally {
        
    }
    return myLikesId;
}

- (void)handleNotifyRequestMyLikesIdResponse:(NSDictionary*) myLikesData {
    running = NO;
    NSSet* myLikesId = [myLikesData objectForKey:@"myLikes"];
    
    if (myLikesId) {
        if ([(id)self.delegate respondsToSelector:@selector(favoriteLoader:didRequestMyLikeIdsSucceed:)]) {
            [self.delegate favoriteLoader:self didRequestMyLikeIdsSucceed:myLikesId];
        }
    } else {
        if ([(id)self.delegate respondsToSelector:@selector(favoriteLoader:didRequestMyLikeIdsFail:)]) {
            [self.delegate favoriteLoader:self didRequestMyLikeIdsFail:nil];
        }
    }
    
    [self end];
} 

- (void)handleParseMyLikesResponse:(NSData *)myLikesResponseData {
    NSAutoreleasePool * autoReleasePool = [[NSAutoreleasePool alloc] init];
    NSString* jsonString = [NSString stringWithData:myLikesResponseData];
    HGDebug(@"%@", jsonString);
    
    NSArray* myLikes = nil;
    NSString* error = nil;
    
    if (kHttpStatusCodeNotModified == [self.response statusCode]) {
        HGDebug(@"myLikes - got 304 not modifed");
        myLikes = [self loadMyLikeProductsCache];
    } else {
        if (jsonString != nil && [jsonString isEqualToString:@""] == NO) {
            @try {
                NSDictionary *jsonDictionary = [jsonString JSONValue];
                if (jsonDictionary != nil) {
                    error = [jsonDictionary objectForKey:@"error"];
                    myLikes = [self parseMyLikesGiftCollection:jsonDictionary];
                }
                
                if (error && ![@"" isEqualToString:error]) {
                    HGWarning(@"error: %@", error);
                }
            } @catch (NSException *e) {
                HGWarning(@"error on handleParseMyLikesResponse: %@, %@", e, jsonString);
            }
        }
        
        if (myLikes) {
            if ([myLikes count] > 0) {
                NSString* lastModifiedField = [self getLastModifiedHeader];
                HGDebug(@"new myLikes data - lastModified: %@, storing data", lastModifiedField);
                [self saveMyLikeProducts:myLikes andLastModifiedTime:lastModifiedField];
            }
        } else {
            HGDebug(@"handle response error, use cached data");
            myLikes = [self loadMyLikeProductsCache];
        }

    }
    
    if (error == nil || [@"" isEqualToString:error]) {
        [self performSelectorOnMainThread:@selector(handleNotifyRequestMyLikesResponse:) withObject:[NSDictionary dictionaryWithObjectsAndKeys:myLikes, @"myLikes", nil] waitUntilDone:YES];
    }else{
        [self performSelectorOnMainThread:@selector(handleNotifyRequestMyLikesResponse:) withObject:nil waitUntilDone:YES];
    }
    
    [autoReleasePool release];
}


-(NSArray*) parseMyLikesGiftCollection:(NSDictionary*)jsonDictionary {
    NSMutableArray* giftSets = [[[NSMutableArray alloc] init] autorelease];
    @try {
        NSArray* productsJsonArray = [jsonDictionary objectForKey:@"products"];
        //NSString* error = [jsonDictionary objectForKey:@"error"];
        for (NSDictionary* productJsonDictionary in productsJsonArray) {
            HGGiftSet* giftSet = [self parseGiftSet:productJsonDictionary];
            if (giftSet != nil) {
                [giftSets addObject:giftSet];
            }
        }
        
    }@catch (NSException* e) {
        HGDebug(@"Exception happened inside parseMyLikesGiftCollection: %@ %@", e, jsonDictionary);
    }@finally {
        
    }
    return giftSets;
}

-(HGGiftSet*) parseGiftSet: (NSDictionary*)productJsonDictionary{
    HGGiftSet* giftSet = [[HGGiftSet alloc] init];
    HGGift* gift = [[HGGift alloc] initWithProductJsonDictionary:productJsonDictionary];
    giftSet.name = gift.name;
    giftSet.cover = gift.cover;
    giftSet.thumb = gift.thumb;
    giftSet.description = gift.description;
    giftSet.manufacturer = gift.manufacturer;
    giftSet.gifts = [NSArray arrayWithObject:gift];
    [gift release];
    return [giftSet autorelease];
}

- (void)handleNotifyRequestMyLikesResponse:(NSDictionary*) myLikesData {
    running = NO;
    NSArray* myLikes = [myLikesData objectForKey:@"myLikes"];
    
    if (myLikes) {
        if ([(id)self.delegate respondsToSelector:@selector(favoriteLoader:didRequestMyLikeProductsSucceed:)]) {
            [self.delegate favoriteLoader:self didRequestMyLikeProductsSucceed:myLikes];
        }
    } else {
        if ([(id)self.delegate respondsToSelector:@selector(favoriteLoader:didRequestMyLikeProductsFail:)]) {
            [self.delegate favoriteLoader:self didRequestMyLikeProductsFail:nil];
        }
    }
    
    [self end];
} 

- (void)handleParseRequestFavoriteResponse:(NSData *)favoriteResponseData {
    NSAutoreleasePool * autoReleasePool = [[NSAutoreleasePool alloc] init];
    NSString* jsonString = [NSString stringWithData:favoriteResponseData];
    HGDebug(@"%@", jsonString);
    NSString* error = nil;
    if (jsonString != nil && [jsonString isEqualToString:@""] == NO) {
        @try {
            NSDictionary *jsonDictionary = [jsonString JSONValue];
            if (jsonDictionary != nil) {
                error = [jsonDictionary objectForKey:@"error"];
            }
        } @catch (NSException *e) {
            HGDebug(@"error on handleParseRequestFavoriteResponse: %@", jsonString);
        }
    }
    if (error != nil && [error isEqualToString:@""] == YES) {
        [self performSelectorOnMainThread:@selector(handleNotifyRequestFavoriteResponse:) withObject:[NSDictionary dictionaryWithObjectsAndKeys:error, @"error", nil] waitUntilDone:YES];
    }else{
        [self performSelectorOnMainThread:@selector(handleNotifyRequestFavoriteResponse:) withObject:nil waitUntilDone:YES];
    }
    [autoReleasePool release];
}

- (void)handleNotifyRequestFavoriteResponse:(NSDictionary*)appConfigurationData {
    running = NO;
    NSString* error = [appConfigurationData objectForKey:@"error"];
    if (error != nil && [error isEqualToString:@""] == YES) {
        if (requestType == kFavoriteRequestLike){
            if ([(id)self.delegate respondsToSelector:@selector(favoriteLoader:didRequestGiftLikeSucceed:)]) {
                [self.delegate favoriteLoader:self didRequestGiftLikeSucceed:requestGiftId];
            }
            [requestGiftId release];
            requestGiftId = nil;
        }else if (requestType == kFavoriteRequestUnLike){
            if ([(id)self.delegate respondsToSelector:@selector(favoriteLoader:didRequestGiftUnLikeSucceed:)]) {
                [self.delegate favoriteLoader:self didRequestGiftUnLikeSucceed:requestGiftId];
            }
            [requestGiftId release];
            requestGiftId = nil;
        }
    } else {
        if (requestType == kFavoriteRequestLike){
            if ([(id)self.delegate respondsToSelector:@selector(favoriteLoader:didRequestGiftLikeFail:forGiftId:)]) {
                [self.delegate favoriteLoader:self didRequestGiftLikeFail:error forGiftId:requestGiftId];
            }
            [requestGiftId release];
            requestGiftId = nil;
        }else if (requestType == kFavoriteRequestUnLike){
            if ([(id)self.delegate respondsToSelector:@selector(favoriteLoader:didRequestGiftUnLikeFail:forGiftId:)]) {
                [self.delegate favoriteLoader:self didRequestGiftUnLikeFail:error forGiftId:requestGiftId];
            }
            [requestGiftId release];
            requestGiftId = nil;
        }
    }
    [self end];
}

#pragma mark overrides
- (void)connectionDidFinishLoading:(NSURLConnection *)conn {
    [super connectionDidFinishLoading:conn];
    if (requestType == kFavoriteRequestMyLikeProducts) {
        [self performSelectorInBackground:@selector(handleParseMyLikesResponse:) withObject:self.data];
    } else if (requestType == kFavoriteRequestMyLikeIds) {
        [self performSelectorInBackground:@selector(handleParseMyLikesIdResponse:) withObject:self.data];
    } else {
        [self performSelectorInBackground:@selector(handleParseRequestFavoriteResponse:) withObject:self.data];
    }
}

- (void)connection:(NSURLConnection *)conn didFailWithError:(NSError *)error {
    [super connection:conn didFailWithError:error];
	running = NO;
    if (requestType == kFavoriteRequestLike){
        if ([(id)self.delegate respondsToSelector:@selector(favoriteLoader:didRequestGiftLikeFail:forGiftId:)]) {
            [self.delegate favoriteLoader:self didRequestGiftLikeFail:[error description] forGiftId:requestGiftId];
        }
        [requestGiftId release];
        requestGiftId = nil;
    }else if (requestType == kFavoriteRequestUnLike){
        if ([(id)self.delegate respondsToSelector:@selector(favoriteLoader:didRequestGiftUnLikeFail:forGiftId:)]) {
            [self.delegate favoriteLoader:self didRequestGiftUnLikeFail:[error description] forGiftId:requestGiftId];
        }
        [requestGiftId release];
        requestGiftId = nil;
    } else if (requestType == kFavoriteRequestMyLikeProducts) {
        if ([(id)self.delegate  respondsToSelector:@selector(favoriteLoader:didRequestMyLikeProductsFail:)]) {
            [self.delegate favoriteLoader:self didRequestMyLikeProductsFail:[error description]];
        }
    } else if (requestType == kFavoriteRequestMyLikeIds) {
        if ([(id)self.delegate  respondsToSelector:@selector(favoriteLoader:didRequestMyLikeIdsFail:)]) {
            [self.delegate favoriteLoader:self didRequestMyLikeIdsFail:[error description]];
        }
    }
}

#pragma mark cache
- (NSString*)getLastModifiedTimeOfMyLikeProducts {
    return [HGLoaderCache lastModifiedTimeForKey:kCacheKeyLastModifiedTimeOfMyLikeProducts];
}

- (NSArray*)loadMyLikeProductsCache {
    return [HGLoaderCache loadDataFromLoaderCache:@"myLikeProducts"];
}

- (void)saveMyLikeProducts:(NSArray*)myLikeProducts andLastModifiedTime:(NSString*)lastModifiedTimeOfMyLikeProducts {
    [HGLoaderCache saveDataToLoaderCache:myLikeProducts forKey:@"myLikeProducts"];
    [HGLoaderCache saveLastModifiedTime:lastModifiedTimeOfMyLikeProducts forKey:kCacheKeyLastModifiedTimeOfMyLikeProducts];
}

- (NSArray*)myLikeProductsLoaderCache {
    NSString* lastModifiedTime = [self getLastModifiedTimeOfMyLikeProducts];
    if (lastModifiedTime && ![@"" isEqualToString:lastModifiedTime]) {
        return [self loadMyLikeProductsCache];
    } else {
        return nil;
    }
}

- (NSString*)getLastModifiedTimeOfMyLikeIds {
    return [HGLoaderCache lastModifiedTimeForKey:kCacheKeyLastModifiedTimeOfMyLikeIds];
}

- (NSSet*)loadMyLikeIdsCache {
    return [HGLoaderCache loadDataFromLoaderCache:@"myLikeIds"];
}

- (void)saveMyLikeIds:(NSSet*)myLikeIds andLastModifiedTime:(NSString*)lastModifiedTimeOfMyLikeIds {
    [HGLoaderCache saveDataToLoaderCache:myLikeIds forKey:@"myLikeIds"];
    [HGLoaderCache saveLastModifiedTime:lastModifiedTimeOfMyLikeIds forKey:kCacheKeyLastModifiedTimeOfMyLikeIds];
}

- (NSSet*)myLikeIdsLoaderCache {
    NSString* lastModifiedTime = [self getLastModifiedTimeOfMyLikeIds];
    if (lastModifiedTime && ![@"" isEqualToString:lastModifiedTime]) {
        return [self loadMyLikeIdsCache];
    } else {
        return nil;
    }
}
@end
