//
//  HGGlobalOccasionGiftCollectionLoader.m
//  HappyGift
//
//  Created by Zhang Yuhui on 02/09/12.
//  Copyright 2011 Ztelic Inc. All rights reserved.
//

#import "HGGlobalOccasionGiftCollectionLoader.h"
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
#import "HGGiftCollectionService.h"
#import "HGLoaderCache.h"
#import "HGRecipient.h"
#import "HGDefines.h"
#import "HGLogging.h"
#import "HGUtility.h"
#import "HGOccasionCategory.h"

static NSString *kGlobalOccasionGiftCollectionRequestFormat = @"%@/gift/index.php?route=product/global_occasion";

@interface HGGlobalOccasionGiftCollectionLoader()
@end

@implementation HGGlobalOccasionGiftCollectionLoader
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
    
    NSString* requestString = [NSString stringWithFormat:kGlobalOccasionGiftCollectionRequestFormat, [HappyGiftAppDelegate backendServiceHost]];
    
    if (![HGUtility wifiReachable]) {
        NSMutableString* newRequestString = [NSMutableString stringWithString:requestString];
        [newRequestString appendFormat:@"&with_detail=0"];
        requestString = newRequestString;
    }
    
    HGDebug(@"%@", requestString);
    NSURL* requestURL = [NSURL URLWithString:[requestString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    
    NSMutableDictionary* headers = nil;
    NSString* lastModifiedTime = [self getLastModifiedTimeOfGlobalOccasionGiftCollections];
    
    if (lastModifiedTime) {
        headers = [NSMutableDictionary dictionaryWithObject:lastModifiedTime forKey:kHttpHeaderIfModifiedSince];
    }
    
    [super requestByGet:requestURL withHeaders:headers];
}

#pragma mark parsers

- (void)handleParseOccasionGiftCollections:(NSData*)giftCollectionsData{
    NSAutoreleasePool * autoReleasePool = [[NSAutoreleasePool alloc] init];
    NSString* jsonString = [NSString stringWithData:self.data];
    HGDebug(@"%@", jsonString);
    NSArray* occasionGiftCollections = nil;
    
    if (kHttpStatusCodeNotModified == [self.response statusCode]) {
        HGDebug(@"global occasions - got 304 not modifed");
        occasionGiftCollections = [self loadGlobalOccasionGiftCollectionsCache];
    } else {
        if (jsonString != nil && [jsonString isEqualToString:@""] == NO){
            NSDictionary *jsonDictionary = [jsonString JSONValue];
            if (jsonDictionary != nil){
                occasionGiftCollections = [self parseOccasionGiftCollections:jsonDictionary];
            }
        }
        
        if (occasionGiftCollections) {
            if ([occasionGiftCollections count] > 0) {
                NSString* lastModifiedField = [self getLastModifiedHeader];
                HGDebug(@"new globalOccasionGiftCollections data - lastModified: %@, storing data", lastModifiedField);
                [self saveGlobalOccasionGiftCollections:occasionGiftCollections andLastModifiedTime:lastModifiedField];
            }
        } else {
            HGDebug(@"handle response error, use cached data");
            occasionGiftCollections = [self loadGlobalOccasionGiftCollectionsCache];
        }
    }
    
    if (occasionGiftCollections != nil){
        [self performSelectorOnMainThread:@selector(handleNotifyOccasionGiftCollections:) withObject:[NSDictionary dictionaryWithObjectsAndKeys:occasionGiftCollections, @"occasionGiftCollections", nil] waitUntilDone:YES];
    }else{
        [self performSelectorOnMainThread:@selector(handleNotifyOccasionGiftCollections:) withObject:nil waitUntilDone:YES];
    }
    [autoReleasePool release];
}

- (void)handleNotifyOccasionGiftCollections:(NSDictionary*)occasionGiftCollectionsData{
    running = NO;
    NSArray* occasionGiftCollections = [occasionGiftCollectionsData objectForKey:@"occasionGiftCollections"];
    if (occasionGiftCollections != nil){
        if ([(id)self.delegate respondsToSelector:@selector(globalOccasionGiftCollectionLoader:didRequestGlobalOccasionGiftCollectionsSucceed:)]) {
            [self.delegate globalOccasionGiftCollectionLoader:self didRequestGlobalOccasionGiftCollectionsSucceed:occasionGiftCollections];
        }
    }else{
        if ([(id)self.delegate respondsToSelector:@selector(globalOccasionGiftCollectionLoader:didRequestGlobalOccasionGiftCollectionsFail:)]) {
            [self.delegate globalOccasionGiftCollectionLoader:self didRequestGlobalOccasionGiftCollectionsFail:nil];
        }
    }
    [self end];
}


-(NSArray*) parseOccasionGiftCollections:(NSDictionary*)jsonDictionary{
    NSMutableArray* occasionGiftCollections = [[[NSMutableArray alloc] init] autorelease];
    @try {
        NSArray* occasionsJsonArray = [jsonDictionary objectForKey:@"occasions"];
        //NSString* error = [jsonDictionary objectForKey:@"error"];
        for (NSDictionary* occasionJsonDictionary in occasionsJsonArray){
            HGOccasionGiftCollection* occasionGiftCollection = [self parseOccasionGiftCollection:occasionJsonDictionary];
            if (occasionGiftCollection != nil){
                [occasionGiftCollections addObject:occasionGiftCollection];
            }
        }
        
    }@catch (NSException* e) {
        HGDebug(@"Exception happened inside parseOccasionGiftCollections");
    }@finally {
        
    }
    return occasionGiftCollections;
}

-(HGOccasionGiftCollection*) parseOccasionGiftCollection: (NSDictionary*)occasionGiftCollectionJsonDictionary{
    NSDictionary* occasionJsonDictionary = [occasionGiftCollectionJsonDictionary objectForKey:@"occasion"];
    NSArray* productsJsonDictionary = [occasionGiftCollectionJsonDictionary objectForKey:@"products"];
    NSMutableArray* giftSets = [[NSMutableArray alloc] init];
    for (NSDictionary* productJsonDictionary in productsJsonDictionary){
        HGGiftSet* giftSet = [[HGGiftSet alloc] initWithProductJsonDictionary:productJsonDictionary];
        [giftSets addObject:giftSet];
        [giftSet release];
    }
    HGOccasionGiftCollection* occasionGiftCollection = [HGOccasionGiftCollection alloc];
    occasionGiftCollection.giftSets = giftSets;
    [giftSets release];
    occasionGiftCollection.occasion = [self parseGiftOccasion:occasionJsonDictionary];
    return [occasionGiftCollection autorelease];
}

-(HGGiftOccasion*) parseGiftOccasion:(NSDictionary*)occasionJsonDictionary{
    HGGiftOccasion* giftOccasion = [[HGGiftOccasion alloc] init];
    
    NSString* theIdentifier = [occasionJsonDictionary objectForKey:@"occasion_id"];
    HGOccasionCategory* theOccasionCategory = [[[HGGiftCollectionService sharedService].occasionCategories objectForKey:theIdentifier] retain];
    
    if (theOccasionCategory == nil) {
        theOccasionCategory = [[HGOccasionCategory alloc] init];
        theOccasionCategory.name = [occasionJsonDictionary objectForKey:@"name"];
        theOccasionCategory.longName  = theOccasionCategory.name;
        theOccasionCategory.identifier = theIdentifier;
        theOccasionCategory.icon = @"occasion_holiday_icon_general";
        theOccasionCategory.headerIcon = @"occasion_holiday_header_icon_general";
        theOccasionCategory.headerBackground = @"occasion_holiday_header_background_general";
    }
    
    NSString* theEventType = [occasionJsonDictionary objectForKey:@"event_type"];
    NSString* theEventDate = [occasionJsonDictionary objectForKey:@"event_date"];
    
    giftOccasion.occasionCategory = theOccasionCategory;
    [theOccasionCategory release];

    giftOccasion.eventType = theEventType;
    giftOccasion.eventDate = theEventDate;
    
    return [giftOccasion autorelease];
}

#pragma mark overrides
- (void)connectionDidFinishLoading:(NSURLConnection *)conn {
    [super connectionDidFinishLoading:conn];
    [self performSelectorInBackground:@selector(handleParseOccasionGiftCollections:) withObject:self.data];
}

- (void)connection:(NSURLConnection *)conn didFailWithError:(NSError *)error {
    [super connection:conn didFailWithError:error];
	running = NO;
    if ([(id)self.delegate respondsToSelector:@selector(globalOccasionGiftCollectionLoader:didRequestGlobalOccasionGiftCollectionsFail:)]) {
        [self.delegate globalOccasionGiftCollectionLoader:self didRequestGlobalOccasionGiftCollectionsFail:nil];
    }
}

#pragma persistent response data

-(NSArray*)loadGlobalOccasionGiftCollectionsCache {
    return [HGLoaderCache loadDataFromLoaderCache:@"globalOccasionGiftCollections"];
}

-(NSString*)getLastModifiedTimeOfGlobalOccasionGiftCollections {
    return [HGLoaderCache lastModifiedTimeForKey:@"lastModifiedTimeOfGlobalOccasionGiftCollections"];
}

-(NSArray*) globalOccasionGiftCollectionsLoaderCache {
    NSString* lastModifiedTimeOfGlobalOccasionGiftCollections = [self getLastModifiedTimeOfGlobalOccasionGiftCollections];
    if (lastModifiedTimeOfGlobalOccasionGiftCollections && ![@"" isEqualToString:lastModifiedTimeOfGlobalOccasionGiftCollections]) {
        return [self loadGlobalOccasionGiftCollectionsCache];
    } else {
        return nil;
    }
}

-(void)saveGlobalOccasionGiftCollections:(NSArray*)globalOccasionGiftCollections andLastModifiedTime:(NSString*)lastModifiedTimeOfGlobalOccasionGiftCollections {
    [HGLoaderCache saveDataToLoaderCache:globalOccasionGiftCollections forKey:@"globalOccasionGiftCollections"];
    [HGLoaderCache saveLastModifiedTime:lastModifiedTimeOfGlobalOccasionGiftCollections forKey:@"lastModifiedTimeOfGlobalOccasionGiftCollections"];
}


@end
