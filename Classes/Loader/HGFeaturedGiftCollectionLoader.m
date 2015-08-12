//
//  HGGiftCollectionLoader.m
//  HappyGift
//
//  Created by Zhang Yuhui on 02/09/12.
//  Copyright 2011 Ztelic Inc. All rights reserved.
//

#import "HGFeaturedGiftCollectionLoader.h"
#import "JSON.h"
#import "HGNetworkHost.h"
#import "HGConstants.h"
#import "HGGift.h"
#import "HGGiftSet.h"
#import "HGFeaturedGiftCollection.h"
#import "HappyGiftAppDelegate.h"
#import "HGLogging.h"
#import "NSString+Addition.h"
#import <sqlite3.h>
#import "HGLoaderCache.h"
#import "HGDefines.h"
#import "HGUtility.h"

static NSString *kFeaturedGiftCollectionRequestFormat = @"%@/gift/index.php?route=product/featured";

@interface HGFeaturedGiftCollectionLoader()
@end

@implementation HGFeaturedGiftCollectionLoader
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
    
    NSString* requestString = [NSString stringWithFormat:kFeaturedGiftCollectionRequestFormat, [HappyGiftAppDelegate backendServiceHost]];
    
    if (![HGUtility wifiReachable]) {
        NSMutableString* newRequestString = [NSMutableString stringWithString:requestString];
        [newRequestString appendFormat:@"&with_detail=0"];
        requestString = newRequestString;
    }
    
    HGDebug(@"%@", requestString);
    NSURL* requestURL = [NSURL URLWithString:[requestString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    NSMutableDictionary* headers = nil;
    NSString* lastModifiedTime = [self getLastModifiedTimeOfFeaturedGiftCollection];
    
    if (lastModifiedTime) {
        headers = [NSMutableDictionary dictionaryWithObject:lastModifiedTime forKey:kHttpHeaderIfModifiedSince];
    }
    
    [super requestByGet:requestURL withHeaders:headers];
}

#pragma mark parsers

- (void)handleParseFeaturedGiftCollection:(NSData*)giftCollectionsData{
    NSAutoreleasePool * autoReleasePool = [[NSAutoreleasePool alloc] init];
    NSString* jsonString = [NSString stringWithData:self.data];
    HGDebug(@"%@", jsonString);
    HGFeaturedGiftCollection* featuredGiftCollection = nil;
    
    if (kHttpStatusCodeNotModified == [self.response statusCode]) {
        HGDebug(@"featured gifts - got 304 not modifed");
        featuredGiftCollection = [self loadFeaturedGiftCollectionCache];
    } else {
        if (jsonString != nil && [jsonString isEqualToString:@""] == NO){
            NSDictionary *jsonDictionary = [jsonString JSONValue];
            if (jsonDictionary != nil){
                featuredGiftCollection = [self parseFeaturedGiftCollection:jsonDictionary];
            }
        }
        
        if (featuredGiftCollection) {
            if ([featuredGiftCollection.giftSets count] > 0) {
                NSString* lastModifiedField = [self getLastModifiedHeader];
                HGDebug(@"new featured gifts data - lastModified: %@, storing data", lastModifiedField);
                [self saveFeaturedGiftCollection:featuredGiftCollection andLastModifiedTime:lastModifiedField];
            }
        } else {
            HGDebug(@"handle response error, use cached data");
            featuredGiftCollection = [self loadFeaturedGiftCollectionCache];
        }
    }
    
    if (featuredGiftCollection != nil){
        [self performSelectorOnMainThread:@selector(handleNotifyFeaturedGiftCollection:) withObject:[NSDictionary dictionaryWithObjectsAndKeys:featuredGiftCollection, @"featuredGiftCollection", nil] waitUntilDone:YES];
    }else{
        [self performSelectorOnMainThread:@selector(handleNotifyFeaturedGiftCollection:) withObject:nil waitUntilDone:YES];
    }
    [autoReleasePool release];
}

- (void)handleNotifyFeaturedGiftCollection:(NSDictionary*)featuredGiftCollectionsData{
    running = NO;
    HGFeaturedGiftCollection* featuredGiftCollection = [featuredGiftCollectionsData objectForKey:@"featuredGiftCollection"];
    if (featuredGiftCollection != nil){
        if ([(id)self.delegate respondsToSelector:@selector(featuredGiftCollectionLoader:didRequestFeaturedGiftCollectionSucceed:)]) {
            [self.delegate featuredGiftCollectionLoader:self didRequestFeaturedGiftCollectionSucceed:featuredGiftCollection];
        }
    }else{
        if ([(id)self.delegate respondsToSelector:@selector(featuredGiftCollectionLoader:didRequestFeaturedGiftCollectionsFail:)]) {
            [self.delegate featuredGiftCollectionLoader:self didRequestFeaturedGiftCollectionsFail:nil];
        }
    }
    [self end];
}


-(HGFeaturedGiftCollection*) parseFeaturedGiftCollection:(NSDictionary*)jsonDictionary{
    HGFeaturedGiftCollection* featuredGiftCollection = nil;
    @try {
        NSMutableArray* giftSets = nil;
        NSArray* productsJsonArray = [jsonDictionary objectForKey:@"products"];
        //NSString* error = [jsonDictionary objectForKey:@"error"];
        for (NSDictionary* productJsonDictionary in productsJsonArray){
            HGGiftSet* giftSet = [[HGGiftSet alloc] initWithProductJsonDictionary:productJsonDictionary];
            if (giftSets == nil){
                giftSets = [[NSMutableArray alloc] init];
            }
            [giftSets addObject:giftSet];
            [giftSet release];
        }
        if (giftSets != nil && [giftSets count] > 0){
            featuredGiftCollection = [[[HGFeaturedGiftCollection alloc] init] autorelease];
            featuredGiftCollection.giftSets = giftSets;
            featuredGiftCollection.description = @"";
            [giftSets release];
        }
    }@catch (NSException* e) {
        HGDebug(@"Exception happened inside parseFeaturedGiftCollection");
    }@finally {
        
    }
    return featuredGiftCollection;
}

#pragma mark overrides
- (void)connectionDidFinishLoading:(NSURLConnection *)conn {
    [super connectionDidFinishLoading:conn];
    [self performSelectorInBackground:@selector(handleParseFeaturedGiftCollection:) withObject:self.data];
}

- (void)connection:(NSURLConnection *)conn didFailWithError:(NSError *)error {
    [super connection:conn didFailWithError:error];
	running = NO;
    if ([(id)self.delegate respondsToSelector:@selector(featuredGiftCollectionLoader:didRequestFeaturedGiftCollectionsFail:)]) {
        [self.delegate featuredGiftCollectionLoader:self didRequestFeaturedGiftCollectionsFail:[error description]];
    }
}

#pragma persistent response data

-(HGFeaturedGiftCollection*)loadFeaturedGiftCollectionCache {
    return [HGLoaderCache loadDataFromLoaderCache:@"featuredGiftCollection"];
}

-(NSString*)getLastModifiedTimeOfFeaturedGiftCollection {
    return [HGLoaderCache lastModifiedTimeForKey:@"lastModifiedTimeOfFeaturedGiftCollection"];
}

-(HGFeaturedGiftCollection*) featuredGiftCollectionLoaderCache {
    NSString* lastModifiedTimeOfFeaturedGiftCollection = [self getLastModifiedTimeOfFeaturedGiftCollection];
    if (lastModifiedTimeOfFeaturedGiftCollection && ![@"" isEqualToString:lastModifiedTimeOfFeaturedGiftCollection]) {
        return [self loadFeaturedGiftCollectionCache];
    } else {
        return nil;
    }
}

-(void)saveFeaturedGiftCollection:(HGFeaturedGiftCollection*)featuredGiftCollection andLastModifiedTime:(NSString*)lastModifiedFeaturedGiftCollection {
    [HGLoaderCache saveDataToLoaderCache:featuredGiftCollection forKey:@"featuredGiftCollection"];
    [HGLoaderCache saveLastModifiedTime:lastModifiedFeaturedGiftCollection forKey:@"lastModifiedTimeOfFeaturedGiftCollection"];
}



@end
