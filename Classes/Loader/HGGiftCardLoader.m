//
//  HGGiftCardLoader.m
//  HappyGift
//
//  Created by Zhang Yuhui on 02/09/12.
//  Copyright 2011 Ztelic Inc. All rights reserved.
//

#import "HGGiftCardLoader.h"
#import "JSON.h"
#import "HGNetworkHost.h"
#import "HGConstants.h"
#import "HGGiftCategory.h"
#import "HappyGiftAppDelegate.h"
#import "NSString+Addition.h"
#import "HGGiftCardTemplate.h"
#import "HGGiftCardCategory.h"
#import <sqlite3.h>
#import "HGDefines.h"
#import "HGLoaderCache.h"
#import "HGLogging.h"

static NSString *kGiftCardsRequestFormat = @"%@/gift/index.php?route=card/show";

@interface HGGiftCardLoader()
@end

@implementation HGGiftCardLoader
@synthesize delegate;
@synthesize running;

- (void)dealloc {
    [super dealloc];
}

- (void)cancel {	
    [super cancel];
    running = NO;
}

- (void)requestGiftCards {
    if (running){
        return;
    }
    [self cancel];
    running = YES;
    
    NSString* requestString = [NSString stringWithFormat:kGiftCardsRequestFormat, [HappyGiftAppDelegate backendServiceHost]];
    HGDebug(@"%@", requestString);
    NSURL* requestURL = [NSURL URLWithString:[requestString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    NSMutableDictionary* headers = nil;
    NSString* lastModifiedTime = [self getLastModifiedTimeOfGiftCardCategories];
    
    if (lastModifiedTime) {
        headers = [NSMutableDictionary dictionaryWithObject:lastModifiedTime forKey:kHttpHeaderIfModifiedSince];
    }
    
    [super requestByGet:requestURL withHeaders:headers];
}

#pragma mark parsers

- (void)handleParseGiftCardsData:(NSData*)giftCategoriesData {
    NSAutoreleasePool * autoReleasePool = [[NSAutoreleasePool alloc] init];
    NSArray* giftCardCategories = nil;
    if (kHttpStatusCodeNotModified == [self.response statusCode]) {
        HGDebug(@"GiftCards - got 304 not modifed");
        giftCardCategories = [self loadGiftCardCategoriesCache];
    } else {
        NSString* jsonString = [NSString stringWithData:self.data];
        HGDebug(@"%@", jsonString);
        
        if (jsonString != nil && [jsonString isEqualToString:@""] == NO){
            NSDictionary *jsonDictionary = [jsonString JSONValue];
            if (jsonDictionary != nil){
                giftCardCategories = [self parseGiftCardCategories:jsonDictionary];
            }
        }
        
        if (giftCardCategories) {
            if ([giftCardCategories count] > 0) {
                NSString* lastModifiedField = [self getLastModifiedHeader];
                HGDebug(@"new giftCardCategories data - lastModified: %@, storing data", lastModifiedField);
                [self saveGiftCardCategories:giftCardCategories andLastModifiedTime:lastModifiedField];
            }
        } else {
            HGDebug(@"handle response error, use cached data");
            giftCardCategories = [self loadGiftCardCategoriesCache];
        }
    }
    if (giftCardCategories != nil){
        [self performSelectorOnMainThread:@selector(handleNotifyGiftCardsDataData:) withObject:[NSDictionary dictionaryWithObjectsAndKeys:giftCardCategories, @"giftCardCategories", nil] waitUntilDone:YES];
    }else{
        [self performSelectorOnMainThread:@selector(handleNotifyGiftCardsDataData:) withObject:nil waitUntilDone:YES];
    }
    [autoReleasePool release];
}

- (void)handleNotifyGiftCardsDataData:(NSDictionary*)giftCardCategoriesData {
    running = NO;
    NSArray* giftCardCategories = [giftCardCategoriesData objectForKey:@"giftCardCategories"];
    if (giftCardCategories != nil){
        if ([(id)self.delegate respondsToSelector:@selector(giftCardLoader:didRequestGiftCardsSucceed:)]) {
            [self.delegate giftCardLoader:self didRequestGiftCardsSucceed:giftCardCategories];
        }
    }else{
        if ([(id)self.delegate respondsToSelector:@selector(giftCardLoader:didRequestRequestGiftCardsFail:)]) {
            [self.delegate giftCardLoader:self didRequestRequestGiftCardsFail:nil];
        }
    }
    [self end];
}

-(NSArray*) parseGiftCardCategories:(NSDictionary*)jsonDictionary {
    NSMutableArray* giftCardCategories = [[[NSMutableArray alloc] init] autorelease];
    @try {
        NSDictionary* categoriesJsonObject = [jsonDictionary objectForKey:@"cards"];
        
        NSArray *keys = [categoriesJsonObject allKeys];
        int count = [keys count];
        for (int i = 0; i < count; ++i) {
            id key = [keys objectAtIndex: i];
            id value = [categoriesJsonObject objectForKey: key];
            
            HGGiftCardCategory *category = [[HGGiftCardCategory alloc] init];
            
            NSDictionary* attr = [value objectForKey:@"attr"];
            category.identifier = [attr objectForKey:@"card_category_id"];
            category.name = [attr objectForKey:@"name"];
            category.descriptionText = [attr objectForKey:@"description"];
            
            NSArray* cardsObj = [value objectForKey:@"cards"];
            NSMutableArray* cardTemplates = [[NSMutableArray alloc] init];
            
            for (NSDictionary* cardObj in cardsObj) {
                HGGiftCardTemplate* card = [[HGGiftCardTemplate alloc] init];
                card.identifier = [cardObj objectForKey:@"card_id"];
                card.name = [cardObj objectForKey:@"name"];
                card.coverImageUrl = [cardObj objectForKey:@"image"];
                
                NSString *backgroundColor = [NSString stringWithFormat:@"0x%@", [cardObj objectForKey:@"bg_color"]];
                int color = 0xFFFFFF;
                sscanf([backgroundColor cStringUsingEncoding:NSASCIIStringEncoding], "%x", &color);
                
                card.backgroundColor = UIColorFromRGB(color);
                
                card.defaultContent = [cardObj objectForKey:@"default_body"];
                card.cardCategoryId = category.identifier;
                
                [cardTemplates addObject:card];
                [card release];
            }
            
            category.cardTemplates = cardTemplates;
            [giftCardCategories addObject:category];
            [cardTemplates release];
            [category release];
        }
        
    }@catch (NSException* e) {
        HGDebug(@"Exception happened inside parseGiftCardCategories");
    }@finally {
        
    }
    return giftCardCategories;
}

#pragma mark overrides
- (void)connectionDidFinishLoading:(NSURLConnection *)conn {
    [super connectionDidFinishLoading:conn];
    [self performSelectorInBackground:@selector(handleParseGiftCardsData:) withObject:self.data];
}

- (void)connection:(NSURLConnection *)conn didFailWithError:(NSError *)error {
    [super connection:conn didFailWithError:error];
	running = NO;
    if ([(id)self.delegate respondsToSelector:@selector(giftCardLoader:didRequestRequestGiftCardsFail:)]) {
        [self.delegate giftCardLoader:self didRequestRequestGiftCardsFail:[error description]];
    }
}


#pragma persistent response data

-(NSArray*)loadGiftCardCategoriesCache {
    return [HGLoaderCache loadDataFromLoaderCache:@"giftCardCategoriesCache"];
}

-(NSString*)getLastModifiedTimeOfGiftCardCategories {
    return [HGLoaderCache lastModifiedTimeForKey:@"lastModifiedTimeOfGiftCardCategories"];
}

- (NSArray*)giftCardCategoriesLoaderCache {
    NSString* lastModifiedTimeOfGiftCardCategories = [self getLastModifiedTimeOfGiftCardCategories];
    if (lastModifiedTimeOfGiftCardCategories && ![@"" isEqualToString:lastModifiedTimeOfGiftCardCategories]) {
        return [self loadGiftCardCategoriesCache];
    } else {
        return nil;
    }
}

-(void)saveGiftCardCategories:(NSArray*)giftCardCategories andLastModifiedTime:(NSString*)lastModifiedTimeOfOccasionGiftCollections {
    [HGLoaderCache saveDataToLoaderCache:giftCardCategories forKey:@"giftCardCategoriesCache"];
    [HGLoaderCache saveLastModifiedTime:lastModifiedTimeOfOccasionGiftCollections forKey:@"lastModifiedTimeOfGiftCardCategories"];
}

@end
