//
//  HGGiftSetsLoader.m
//  HappyGift
//
//  Created by Zhang Yuhui on 02/09/12.
//  Copyright 2011 Ztelic Inc. All rights reserved.
//

#import "HGGiftSetsLoader.h"
#import "JSON.h"
#import "HGNetworkHost.h"
#import "HGConstants.h"
#import "HGGift.h"
#import "HGGiftSet.h"
#import "HappyGiftAppDelegate.h"
#import "NSString+Addition.h"
#import <sqlite3.h>
#import "HGLoaderCache.h"
#import "HGDefines.h"
#import "HGLogging.h"
#import "HGUtility.h"

static NSString *kGiftSetsRequestFormat = @"%@/gift/index.php?route=product/category&category_id=%@";
static NSString *kGiftDetailRequestFormat = @"%@/gift/index.php?route=product/one&product_id=%@";

#define kRequestTypeRequestGiftSets 0
#define kRequestTypeRequestGiftDetail 1

@interface HGGiftSetsLoader()
@end

@implementation HGGiftSetsLoader
@synthesize delegate;
@synthesize running;



- (void)dealloc {
    [super dealloc];
}

- (void)cancel {	
    [super cancel];
    running = NO;
}

- (void)requestGiftSets:(NSArray*)categories{
    if (running){
        return;
    }
    [self cancel];
    requestType = kRequestTypeRequestGiftSets;
    running = YES;
    
    NSString* requestString = [NSString stringWithFormat:kGiftSetsRequestFormat, [HappyGiftAppDelegate backendServiceHost], [categories componentsJoinedByString:@","]];
    
    if (![HGUtility wifiReachable]) {
        NSMutableString* newRequestString = [NSMutableString stringWithString:requestString];
        [newRequestString appendFormat:@"&with_detail=0"];
        requestString = newRequestString;
    }
    
    HGDebug(@"%@", requestString);
    NSURL* requestURL = [NSURL URLWithString:[requestString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    NSMutableDictionary* headers = nil;
    NSString* lastModifiedTime = [self getLastModifiedTimeOfGiftSets];
    
    if (lastModifiedTime) {
        headers = [NSMutableDictionary dictionaryWithObject:lastModifiedTime forKey:kHttpHeaderIfModifiedSince];
    }
    
    [super requestByGet:requestURL withHeaders:headers];
}

- (void)requestGiftDetail:(NSString*)giftId {
    if (running){
        return;
    }
    [self cancel];
    requestType = kRequestTypeRequestGiftDetail;
    running = YES;
    
    NSString* requestString = [NSString stringWithFormat:kGiftDetailRequestFormat, [HappyGiftAppDelegate backendServiceHost], giftId];
    HGDebug(@"%@", requestString);
    NSURL* requestURL = [NSURL URLWithString:[requestString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    [super requestByGet:requestURL];
}

#pragma mark parsers

- (void)handleParseGiftSets:(NSData*)giftSetsData{
    NSAutoreleasePool * autoReleasePool = [[NSAutoreleasePool alloc] init];
    NSString* jsonString = [NSString stringWithData:self.data];
    HGDebug(@"%@", jsonString);
    NSDictionary* giftSets = nil;
    
    if (kHttpStatusCodeNotModified == [self.response statusCode]) {
        HGDebug(@"Gift Sets - got 304 not modifed");
        giftSets = [self loadGiftSetsCache];
    } else {
        
        if (jsonString != nil && [jsonString isEqualToString:@""] == NO){
            NSDictionary *jsonDictionary = [jsonString JSONValue];
            if (jsonDictionary != nil){
                giftSets = [self parseGiftSets:jsonDictionary];
            }
        }
        
        if (giftSets) {
            NSString* lastModifiedField = [self getLastModifiedHeader];
            HGDebug(@"new Gift Sets data - lastModified: %@, storing data", lastModifiedField);
            [self saveGiftSets:giftSets andLastModifiedTime:lastModifiedField];
        } else {
            HGDebug(@"handle response error, use cached data");
            giftSets = [self loadGiftSetsCache];
        }
    }
    if (giftSets != nil){
        [self performSelectorOnMainThread:@selector(handleNotifyGiftSets:) withObject:[NSDictionary dictionaryWithObjectsAndKeys:giftSets, @"giftSets", nil] waitUntilDone:YES];
    }else{
        [self performSelectorOnMainThread:@selector(handleNotifyGiftSets:) withObject:nil waitUntilDone:YES];
    }
    [autoReleasePool release];
}

- (void)handleNotifyGiftSets:(NSDictionary*)giftSetsData{
    running = NO;
    NSDictionary* giftSets = [giftSetsData objectForKey:@"giftSets"];
    if (giftSets != nil){
        if ([(id)self.delegate respondsToSelector:@selector(giftSetsLoader:didRequestGiftSetsSucceed:)]) {
            [self.delegate giftSetsLoader:self didRequestGiftSetsSucceed:giftSets];
        }
    }else{
        if ([(id)self.delegate respondsToSelector:@selector(giftSetsLoader:didRequestGiftSetsFail:)]) {
            [self.delegate giftSetsLoader:self didRequestGiftSetsFail:nil];
        }
    }
    [self end];
}


-(NSDictionary*) parseGiftSets:(NSDictionary*)jsonDictionary{
    NSMutableDictionary* giftSets = nil;
    @try {
        //NSString* error = [jsonDictionary objectForKey:@"error"];
        NSDictionary* productsJsonDictionary = [jsonDictionary objectForKey:@"products"];
        NSEnumerator* productsJsonDictionaryEnumerator = [productsJsonDictionary keyEnumerator];
        NSString* productsCategoryIdentifier;
        while ((productsCategoryIdentifier = [productsJsonDictionaryEnumerator nextObject])) {
            NSMutableArray* categoryGiftSets = nil;
            NSArray* productsJsonArray = [productsJsonDictionary objectForKey:productsCategoryIdentifier];
            for (NSDictionary* productJsonDictionary in productsJsonArray){
                HGGiftSet* giftSet = [[HGGiftSet alloc] initWithProductJsonDictionary:productJsonDictionary];
                if (categoryGiftSets == nil){
                    categoryGiftSets = [[NSMutableArray alloc] init];
                }
                [categoryGiftSets addObject:giftSet];
                [giftSet release];
            }
            if (categoryGiftSets != nil){
                if (giftSets == nil){
                    giftSets = [[[NSMutableDictionary alloc] init] autorelease];
                }
                [giftSets setObject:categoryGiftSets forKey:productsCategoryIdentifier];
                [categoryGiftSets release];
            }
        }
    }@catch (NSException* e) {
        HGDebug(@"Exception happened inside parseFeaturedGiftCollection");
    }@finally {
        
    }
    return giftSets;
}

#pragma mark overrides
- (void)connectionDidFinishLoading:(NSURLConnection *)conn {
    [super connectionDidFinishLoading:conn];

    if (requestType == kRequestTypeRequestGiftSets) {
        [self performSelectorInBackground:@selector(handleParseGiftSets:) withObject:self.data];
    } else if (requestType == kRequestTypeRequestGiftDetail) {
        NSString* jsonString = [NSString stringWithData:self.data];
        HGDebug(@"%@", jsonString);
        NSDictionary* responseJson = [jsonString JSONValue];
        NSDictionary* giftJson = [responseJson objectForKey:@"product"];
        HGGift* gift = [[HGGift alloc] initWithProductJsonDictionary:giftJson];
        
        if ([(id)self.delegate respondsToSelector:@selector(giftSetsLoader:didRequestGiftDetailSucceed:)]) {
            [self.delegate giftSetsLoader:self didRequestGiftDetailSucceed:gift];
        }
        [gift release];
    }
}

- (void)connection:(NSURLConnection *)conn didFailWithError:(NSError *)error {
    [super connection:conn didFailWithError:error];
	running = NO;
    if (requestType == kRequestTypeRequestGiftSets) {
        if ([(id)self.delegate respondsToSelector:@selector(giftSetsLoader:didRequestGiftSetsFail:)]) {
            [self.delegate giftSetsLoader:self didRequestGiftSetsFail:[error description]];
        }
    } else if (requestType == kRequestTypeRequestGiftDetail) {
        if ([(id)self.delegate respondsToSelector:@selector(giftSetsLoader:didRequestGiftDetailFail:)]) {
            [self.delegate giftSetsLoader:self didRequestGiftDetailFail:[error description]];
        }
    }
}


#pragma persistent response data

-(NSDictionary*)loadGiftSetsCache {
    return [HGLoaderCache loadDataFromLoaderCache:@"giftSets"];
}

-(NSString*)getLastModifiedTimeOfGiftSets {
    return [HGLoaderCache lastModifiedTimeForKey:@"lastModifiedTimeOfGiftSets"];
}

-(NSDictionary*) giftSetsLoaderCache {
    NSString* lastModifiedTimeOfGiftSets = [self getLastModifiedTimeOfGiftSets];
    if (lastModifiedTimeOfGiftSets && ![@"" isEqualToString:lastModifiedTimeOfGiftSets]) {
        return [self loadGiftSetsCache];
    } else {
        return nil;
    }
}

-(void)saveGiftSets:(NSDictionary*)giftSets andLastModifiedTime:(NSString*)lastModifiedTimeOfGiftSets {
    [HGLoaderCache saveDataToLoaderCache:giftSets forKey:@"giftSets"];
    [HGLoaderCache saveLastModifiedTime:lastModifiedTimeOfGiftSets forKey:@"lastModifiedTimeOfGiftSets"];
}

@end
