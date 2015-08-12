//
//  HGGiftCategoryLoader.m
//  HappyGift
//
//  Created by Zhang Yuhui on 02/09/12.
//  Copyright 2011 Ztelic Inc. All rights reserved.
//

#import "HGGiftCategoryLoader.h"
#import "JSON.h"
#import "HGNetworkHost.h"
#import "HGConstants.h"
#import "HGGiftCategory.h"
#import "HappyGiftAppDelegate.h"
#import "HGLogging.h"
#import "NSString+Addition.h"
#import <sqlite3.h>

static NSString *kGiftCategoriesRequestFormat = @"%@/gift/index.php?route=product/show_category";

@interface HGGiftCategoryLoader()
@end

@implementation HGGiftCategoryLoader
@synthesize delegate;
@synthesize running;

- (void)dealloc {
    [super dealloc];
}

- (void)cancel {	
    [super cancel];
    running = NO;
}

- (void)requestGiftCategories{
    if (running){
        return;
    }
    [self cancel];
    running = YES;
    
    NSString* requestString = [NSString stringWithFormat:kGiftCategoriesRequestFormat, [HappyGiftAppDelegate backendServiceHost]];
    HGDebug(@"%@", requestString);
    NSURL* requestURL = [NSURL URLWithString:[requestString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [super requestByGet:requestURL];
}

#pragma mark parsers

- (void)handleParseGiftCategoriesData:(NSData*)giftCategoriesData{
    NSAutoreleasePool * autoReleasePool = [[NSAutoreleasePool alloc] init];
    NSString* jsonString = [NSString stringWithData:self.data];
    HGDebug(@"%@", jsonString);
    NSArray* giftCategories = nil;
    if (jsonString != nil && [jsonString isEqualToString:@""] == NO){
        NSDictionary *jsonDictionary = [jsonString JSONValue];
        if (jsonDictionary != nil){
            giftCategories = [self parseGiftCategories:jsonDictionary];
        }
    }
    if (giftCategories != nil){
        [self performSelectorOnMainThread:@selector(handleNotifyGiftCategoriesDataData:) withObject:[NSDictionary dictionaryWithObjectsAndKeys:giftCategories, @"giftCategories", nil] waitUntilDone:YES];
    }else{
        [self performSelectorOnMainThread:@selector(handleNotifyGiftCategoriesDataData:) withObject:nil waitUntilDone:YES];
    }
    [autoReleasePool release];
}

- (void)handleNotifyGiftCategoriesDataData:(NSDictionary*)giftCategoriesData{
    running = NO;
    NSArray* giftCategories = [giftCategoriesData objectForKey:@"giftCategories"];
    if (giftCategories != nil){
        if ([(id)self.delegate respondsToSelector:@selector(giftCategoryLoader:didRequestGiftCategoriesSucceed:)]) {
            [self.delegate giftCategoryLoader:self didRequestGiftCategoriesSucceed:giftCategories];
        }
    }else{
        if ([(id)self.delegate respondsToSelector:@selector(giftCategoryLoader:didRequestRequestGiftCategoriesFail:)]) {
            [self.delegate giftCategoryLoader:self didRequestRequestGiftCategoriesFail:nil];
        }
    }
    [self end];
}


-(NSArray*) parseGiftCategories:(NSDictionary*)jsonDictionary{
    NSMutableArray* giftCategories = [[[NSMutableArray alloc] init] autorelease];
    @try {
        NSArray* categoriesJsonArray = [jsonDictionary objectForKey:@"category_list"];
        //NSString* error = [jsonDictionary objectForKey:@"error"];
        for (NSDictionary* categoryJsonDictionary in categoriesJsonArray){
            HGGiftCategory* giftCategory = [self parseGiftCategory:categoryJsonDictionary];
            [giftCategories addObject:giftCategory];
        }
        
    }@catch (NSException* e) {
        HGDebug(@"Exception happened inside parseGiftCategories");
    }@finally {
        
    }
    return giftCategories;
}

-(HGGiftCategory*)parseGiftCategory:(NSDictionary*)categoryJsonDictionary{
    HGGiftCategory* giftCategory = [[HGGiftCategory alloc] init];
    
    NSString* theIdentifier = [categoryJsonDictionary objectForKey:@"category_id"];
    NSString* theName = [categoryJsonDictionary objectForKey:@"name"];
    NSString* theDescription = [categoryJsonDictionary objectForKey:@"description"];
    NSString* theCover = [categoryJsonDictionary objectForKey:@"image"];
    
    giftCategory.identifier = theIdentifier;
    giftCategory.name = theName;
    giftCategory.description = theDescription;
    giftCategory.cover = theCover;
    giftCategory.cover = theCover;
    
    return [giftCategory autorelease];
}

#pragma mark overrides
- (void)connectionDidFinishLoading:(NSURLConnection *)conn {
    [super connectionDidFinishLoading:conn];
    [self performSelectorInBackground:@selector(handleParseGiftCategoriesData:) withObject:self.data];
}

- (void)connection:(NSURLConnection *)conn didFailWithError:(NSError *)error {
    [super connection:conn didFailWithError:error];
	running = NO;
    if ([(id)self.delegate respondsToSelector:@selector(giftCategoryLoader:didRequestRequestGiftCategoriesFail:)]) {
        [self.delegate giftCategoryLoader:self didRequestRequestGiftCategoriesFail:[error description]];
    }
}




@end
