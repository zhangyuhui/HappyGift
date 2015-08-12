//
//  HGGiftCollectionService.m
//  HappyGift
//
//  Created by Zhang Yuhui on 02/09/12.
//  Copyright 2011 Ztelic Inc. All rights reserved.
//

#import "HGGiftCollectionService.h"
#import "HGFeaturedGiftCollectionLoader.h"
#import "HGGlobalOccasionGiftCollectionLoader.h"
#import "HGPersonlizedOccasionGiftCollectionLoader.h"
#import "HappyGiftAppDelegate.h"
#import "HGGiftOccasion.h"
#import "HGOccasionCategory.h"
#import "HGRecipient.h"
#import "HGConstants.h"
#import "HGLogging.h"
#import "WBEngine.h"
#import "HGOccasionTag.h"
#import "HGLoaderCache.h"
#import "HGAppConfigurationService.h"

static HGGiftCollectionService* giftCollectionService;

@interface HGGiftCollectionService () <HGFeaturedGiftCollectionLoaderDelegate, HGGlobalOccasionGiftCollectionLoaderDelegate, HGPersonlizedOccasionGiftCollectionLoaderDelegate>

@end

@implementation HGGiftCollectionService
@synthesize delegate;
@synthesize personalizedOccasionGiftCollectionsArray;
@synthesize featuredGiftCollectionsArray;
@synthesize globalOccasiondGiftCollectionsArray;

+ (HGGiftCollectionService*)sharedService{
    if (giftCollectionService == nil){
        giftCollectionService = [[HGGiftCollectionService alloc] init];
    }
    return giftCollectionService;
}

- (id)init {
    self = [super init];
    if (self) {
        personlizedOccasionGiftCollectionLoader = [[HGPersonlizedOccasionGiftCollectionLoader alloc] init];
        personlizedOccasionGiftCollectionLoader.delegate = self;
        personalizedOccasionGiftCollectionsArray = [[personlizedOccasionGiftCollectionLoader personalizedOccasionGiftCollectionsLoaderCache] retain];
        
        featuredGiftCollectionLoader = [[HGFeaturedGiftCollectionLoader alloc] init];
        featuredGiftCollectionLoader.delegate = self;
        HGFeaturedGiftCollection* featuredGiftCollectionLoaderCache = [featuredGiftCollectionLoader featuredGiftCollectionLoaderCache];
        if (featuredGiftCollectionLoaderCache) {
            featuredGiftCollectionsArray = [[NSArray arrayWithObject:featuredGiftCollectionLoaderCache] retain];
        }
        
        globalOccasionGiftCollectionLoader = [[HGGlobalOccasionGiftCollectionLoader alloc] init];
        globalOccasionGiftCollectionLoader.delegate = self;
        globalOccasiondGiftCollectionsArray = [[globalOccasionGiftCollectionLoader globalOccasionGiftCollectionsLoaderCache] retain];
    }
    return self;
}

- (void) clearPersonalizedOccasionCache {
    personalizedOccasionGiftCollectionsArray = nil;
    [HGLoaderCache clearPersonalizedCacheData];
}

- (NSDictionary*)occasionCategories {
    if (occasionCategories == nil) {
        occasionCategories = [[[HGAppConfigurationService sharedService] occasionCategories] retain];
    }
    return occasionCategories;
}

- (NSDictionary*)occasionTags {
    if (occasionTags == nil) {
        NSMutableDictionary* theOccasionTags = [[NSMutableDictionary alloc] init];
        NSString *theOccassionCategoriesConfigFile = [[NSBundle mainBundle] pathForResource:@"OccasionTagConfig" ofType:@"plist"];
        NSDictionary *theOccasionTagConfigDictionary = [NSDictionary dictionaryWithContentsOfFile:theOccassionCategoriesConfigFile];
        NSArray *theOccassionTagConfigArray = [theOccasionTagConfigDictionary objectForKey:@"kOcassionTags"];
        
        for (NSDictionary* theOccasionTagDictionary in theOccassionTagConfigArray) {
            HGOccasionTag* theOccasionTag = [[HGOccasionTag alloc] init];
            
            theOccasionTag.identifier = [theOccasionTagDictionary objectForKey:@"kOcassionTagId"];
            theOccasionTag.name = [theOccasionTagDictionary objectForKey:@"kOcassionTagName"];
            theOccasionTag.icon = [theOccasionTagDictionary objectForKey:@"kOcassionTagIcon"];
            theOccasionTag.cornerIcon = [theOccasionTagDictionary objectForKey:@"kOcassionTagCornerIcon"];
            
            [theOccasionTags setObject:theOccasionTag forKey:theOccasionTag.identifier];
            [theOccasionTag release];
        }
        
        occasionTags = theOccasionTags;
    }
    return occasionTags;
}

- (void)dealloc{
    [featuredGiftCollectionLoader release];
    [globalOccasionGiftCollectionLoader release];
    [personlizedOccasionGiftCollectionLoader release];
    [personalizedOccasionGiftCollectionsArray release];
    [featuredGiftCollectionsArray release];
    [globalOccasiondGiftCollectionsArray release];
    [super dealloc];
}

- (void)requestFeaturedGiftCollections{
    if (featuredGiftCollectionLoader != nil){
        [featuredGiftCollectionLoader cancel];
    }else{
        featuredGiftCollectionLoader = [[HGFeaturedGiftCollectionLoader alloc] init];
        featuredGiftCollectionLoader.delegate = self;
    }
    [featuredGiftCollectionLoader requestGiftCollection];
}

- (void)requestPersonlizedOccasionGiftCollections{
    if (personlizedOccasionGiftCollectionLoader != nil){
        [personlizedOccasionGiftCollectionLoader cancel];
    }else{
        personlizedOccasionGiftCollectionLoader = [[HGPersonlizedOccasionGiftCollectionLoader alloc] init];
        personlizedOccasionGiftCollectionLoader.delegate = self;
    }
    [personlizedOccasionGiftCollectionLoader requestGiftCollection];
}

- (void)requestGlobalOccasionGiftCollections{
    if (globalOccasionGiftCollectionLoader != nil){
        [globalOccasionGiftCollectionLoader cancel];
    }else{
        globalOccasionGiftCollectionLoader = [[HGGlobalOccasionGiftCollectionLoader alloc] init];
        globalOccasionGiftCollectionLoader.delegate = self;
    }
    [globalOccasionGiftCollectionLoader requestGiftCollection];
}

- (void) requestGiftsForOccasion:(NSString*)occasion andNetworkId:(int)networkId andProfileId:(NSString*)profileId withOffset:(int)offset andTagId:(NSString*)tagId {
    if (personlizedOccasionGiftCollectionLoader != nil){
        [personlizedOccasionGiftCollectionLoader cancel];
    }else{
        personlizedOccasionGiftCollectionLoader = [[HGPersonlizedOccasionGiftCollectionLoader alloc] init];
        personlizedOccasionGiftCollectionLoader.delegate = self;
    }
    [personlizedOccasionGiftCollectionLoader requestGiftsForOccasion:occasion andNetworkId:networkId andProfileId:profileId withOffset:offset andTagId:tagId];
}


- (void)requestGIFGiftsForOccasion:(NSString*)occasion andNetworkId:(int)networkId andProfileId:(NSString*)profileId withOffset:(int)offset andTagId:(NSString*)tagId {
    if (personalizedOccasionGIFGiftForFriendLoader != nil) {
        [personalizedOccasionGIFGiftForFriendLoader cancel];
    } else {
        personalizedOccasionGIFGiftForFriendLoader = [[HGPersonlizedOccasionGiftCollectionLoader alloc] init];
        personalizedOccasionGIFGiftForFriendLoader.delegate = self;
    }
    [personalizedOccasionGIFGiftForFriendLoader requestGIFGiftsForOccasion:occasion andNetworkId:networkId andProfileId:profileId withOffset:offset andTagId:tagId];
}
 
#pragma mark　- HGFeaturedGiftCollectionLoaderDelegate 
- (void)featuredGiftCollectionLoader:(HGFeaturedGiftCollectionLoader *)theFeaturedGiftCollectionLoader didRequestFeaturedGiftCollectionSucceed:(HGFeaturedGiftCollection*)theFeaturedGiftCollection{
    NSArray* theFeaturedGiftCollectionArray = [NSArray arrayWithObject:theFeaturedGiftCollection];
    
    if (featuredGiftCollectionsArray) {
        [featuredGiftCollectionsArray release];
        featuredGiftCollectionsArray = nil;
    }
    featuredGiftCollectionsArray = [theFeaturedGiftCollectionArray retain];
    
    if ([delegate respondsToSelector:@selector(giftCollectionService:didRequestFeaturedGiftCollectionsSucceed:)]){
        [delegate giftCollectionService:self didRequestFeaturedGiftCollectionsSucceed:theFeaturedGiftCollectionArray];
    }
}
 
- (void)featuredGiftCollectionLoader:(HGFeaturedGiftCollectionLoader *)theFeaturedGiftCollectionLoader didRequestFeaturedGiftCollectionsFail:(NSString*)error{
   
    HGFeaturedGiftCollection* theFeaturedGiftCollection = [theFeaturedGiftCollectionLoader featuredGiftCollectionLoaderCache];
    if (theFeaturedGiftCollection) {
        HGDebug(@"featuredGiftCollectionLoader request failed, use cached data");
        if (featuredGiftCollectionsArray != nil){
            [featuredGiftCollectionsArray release];
            featuredGiftCollectionsArray = nil;
        }
        
        NSArray* theFeaturedGiftCollectionsArray = [NSArray arrayWithObject:theFeaturedGiftCollection];
        featuredGiftCollectionsArray = [theFeaturedGiftCollectionsArray retain];
    }
    
    if ([delegate respondsToSelector:@selector(giftCollectionService:didRequestFeaturedGiftCollectionsFail:)]){
        [delegate giftCollectionService:self didRequestFeaturedGiftCollectionsFail:error];
    }
}

#pragma mark　- HGGlobalOccasionGiftCollectionLoaderDelegate
- (void)globalOccasionGiftCollectionLoader:(HGGlobalOccasionGiftCollectionLoader *)theGlobalOccasionGiftCollectionLoader didRequestGlobalOccasionGiftCollectionsSucceed:(NSArray*)theGlobalOccasionGiftCollections{
    
    if (globalOccasiondGiftCollectionsArray) {
        [globalOccasiondGiftCollectionsArray release];
        globalOccasiondGiftCollectionsArray = nil;
    }
    globalOccasiondGiftCollectionsArray = [theGlobalOccasionGiftCollections retain];
    
    if ([delegate respondsToSelector:@selector(giftCollectionService:didRequestGlobalOccasionGiftCollectionsSucceed:)]){
        [delegate giftCollectionService:self didRequestGlobalOccasionGiftCollectionsSucceed:theGlobalOccasionGiftCollections];
    }
}

- (void)globalOccasionGiftCollectionLoader:(HGGlobalOccasionGiftCollectionLoader *)theGlobalOccasionGiftCollectionLoader didRequestGlobalOccasionGiftCollectionsFail:(NSString*)error{
    
    NSArray* theGlobalOccasiondGiftCollectionsArray = [theGlobalOccasionGiftCollectionLoader globalOccasionGiftCollectionsLoaderCache];
    if (theGlobalOccasiondGiftCollectionsArray) {
        HGDebug(@"globalOccasionGiftCollectionLoader request failed, use cached data");
        if (globalOccasiondGiftCollectionsArray != nil){
            [globalOccasiondGiftCollectionsArray release];
            globalOccasiondGiftCollectionsArray = nil;
        }
        globalOccasiondGiftCollectionsArray = [theGlobalOccasiondGiftCollectionsArray retain];
    }
    
    if ([delegate respondsToSelector:@selector(giftCollectionService:didRequestGlobalOccasiondGiftCollectionsFail:)]){
        [delegate giftCollectionService:self didRequestGlobalOccasiondGiftCollectionsFail:error];
    }
}

#pragma mark　- HGPersonlizedOccasionGiftCollectionLoaderDelegate
- (void)personlizedOccasionGiftCollectionLoader:(HGPersonlizedOccasionGiftCollectionLoader *)thePersonlizedOccasionGiftCollectionLoader didRequestPersonlizedOccasionGiftCollectionsSucceed:(NSArray*)thePersonlizedOccasionGiftCollectionsArray{
    
    if (personalizedOccasionGiftCollectionsArray) {
        [personalizedOccasionGiftCollectionsArray release];
        personalizedOccasionGiftCollectionsArray = nil;
    }
    personalizedOccasionGiftCollectionsArray = [thePersonlizedOccasionGiftCollectionsArray retain];
    
    if ([delegate respondsToSelector:@selector(giftCollectionService:didRequestPersonlizedOccasionGiftCollectionsSucceed:)]){
        [delegate giftCollectionService:self didRequestPersonlizedOccasionGiftCollectionsSucceed:thePersonlizedOccasionGiftCollectionsArray];
    }
}

- (void)personlizedOccasionGiftCollectionLoader:(HGPersonlizedOccasionGiftCollectionLoader *)thePersonlizedOccasionGiftCollectionLoader didRequestPersonlizedOccasionGiftCollectionsFail:(NSString*)error{
    
    NSArray* thePersonalizedOccasiondGiftCollectionsArray = [thePersonlizedOccasionGiftCollectionLoader personalizedOccasionGiftCollectionsLoaderCache];
    if (thePersonalizedOccasiondGiftCollectionsArray) {
        HGDebug(@"personlizedOccasionGiftCollectionLoader request failed, use cached data");
        if (personalizedOccasionGiftCollectionsArray != nil){
            [personalizedOccasionGiftCollectionsArray release];
            personalizedOccasionGiftCollectionsArray = nil;
        }
        personalizedOccasionGiftCollectionsArray = [thePersonalizedOccasiondGiftCollectionsArray retain];
    }
    
    if ([delegate respondsToSelector:@selector(giftCollectionService:didRequestPersonlizedOccasiondGiftCollectionsFail:)]){
        [delegate giftCollectionService:self didRequestPersonlizedOccasiondGiftCollectionsFail:error];
    }
}

- (void)personlizedOccasionGiftCollectionLoader:(HGPersonlizedOccasionGiftCollectionLoader *)personlizedOccasionGiftCollectionLoader didRequestGiftsForOccasionSucceed:(NSArray*)giftsForOccasion {
    if ([delegate respondsToSelector:@selector(giftCollectionService:didRequestGiftsForOccasionSucceed:)]){
        [delegate giftCollectionService:self didRequestGiftsForOccasionSucceed:giftsForOccasion];
    }
}

- (void)personlizedOccasionGiftCollectionLoader:(HGPersonlizedOccasionGiftCollectionLoader *)personlizedOccasionGiftCollectionLoader didRequestGiftsForOccasionFail:(NSString*)error {
    if ([delegate respondsToSelector:@selector(giftCollectionService:didRequestGiftsForOccasionFail:)]){
        [delegate giftCollectionService:self didRequestGiftsForOccasionFail:error];
    }
}

- (void)personlizedOccasionGiftCollectionLoader:(HGPersonlizedOccasionGiftCollectionLoader *)personlizedOccasionGiftCollectionLoader didRequestGIFGiftsForOccasionSucceed:(NSArray*)giftsForOccasion {
    if ([delegate respondsToSelector:@selector(giftCollectionService:didRequestGIFGiftsForOccasionSucceed:)]){
        [delegate giftCollectionService:self didRequestGIFGiftsForOccasionSucceed:giftsForOccasion];
    }
}

- (void)personlizedOccasionGiftCollectionLoader:(HGPersonlizedOccasionGiftCollectionLoader *)personlizedOccasionGiftCollectionLoader didRequestGIFGiftsForOccasionFail:(NSString*)error {
    if ([delegate respondsToSelector:@selector(giftCollectionService:didRequestGIFGiftsForOccasionFail:)]){
        [delegate giftCollectionService:self didRequestGIFGiftsForOccasionFail:error];
    }
}

- (void)personlizedOccasionGiftCollectionLoader:(HGPersonlizedOccasionGiftCollectionLoader *)thePersonlizedOccasionGiftCollectionLoader didRequestPersonlizedOccasionAccessTokenFailed:(int)theTokenNetwork{
    if (theTokenNetwork == NETWORK_SNS_WEIBO){
        if ([[WBEngine sharedWeibo] isLoggedIn] == YES) {
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            NSArray* preferneceKeySNSTokenExpiration = [defaults objectForKey:kHGPreferneceKeySNSTokenExpiration];
            if (preferneceKeySNSTokenExpiration == nil){
                [defaults setObject:[NSArray arrayWithObject:[NSNumber numberWithInt:NETWORK_SNS_WEIBO]] forKey:kHGPreferneceKeySNSTokenExpiration];
                [defaults synchronize];
            }else{
                if ([preferneceKeySNSTokenExpiration containsObject:[NSNumber numberWithInt:NETWORK_SNS_WEIBO]] == NO){
                    NSMutableArray* updatedPreferneceKeySNSTokenExpiration = [[NSMutableArray alloc] initWithArray:preferneceKeySNSTokenExpiration];
                    [updatedPreferneceKeySNSTokenExpiration addObject:[NSNumber numberWithInt:NETWORK_SNS_WEIBO]];
                    [defaults setObject:updatedPreferneceKeySNSTokenExpiration forKey:kHGPreferneceKeySNSTokenExpiration];
                    [defaults synchronize];
                    [updatedPreferneceKeySNSTokenExpiration release];
                }
            }
        }
    }else if (theTokenNetwork == NETWORK_SNS_RENREN){
        if ([[RenrenService sharedRenren] isSessionValid]){
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            NSArray* preferneceKeySNSTokenExpiration = [defaults objectForKey:kHGPreferneceKeySNSTokenExpiration];
            if (preferneceKeySNSTokenExpiration == nil){
                [defaults setObject:[NSArray arrayWithObject:[NSNumber numberWithInt:NETWORK_SNS_RENREN]] forKey:kHGPreferneceKeySNSTokenExpiration];
                [defaults synchronize];
            }else{
                if ([preferneceKeySNSTokenExpiration containsObject:[NSNumber numberWithInt:NETWORK_SNS_RENREN]] == NO){
                    NSMutableArray* updatedPreferneceKeySNSTokenExpiration = [[NSMutableArray alloc] initWithArray:preferneceKeySNSTokenExpiration];
                    [updatedPreferneceKeySNSTokenExpiration addObject:[NSNumber numberWithInt:NETWORK_SNS_RENREN]];
                    [defaults setObject:updatedPreferneceKeySNSTokenExpiration forKey:kHGPreferneceKeySNSTokenExpiration];
                    [defaults synchronize];
                    [updatedPreferneceKeySNSTokenExpiration release];
                }
            }
        } 
    }
}
@end
