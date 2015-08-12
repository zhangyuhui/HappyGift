//
//  HGContactInfoViewController.m
//  HappyGift
//
//  Created by Yujian Weng on 12-5-30.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//


#import "HGLoaderCache.h"
#import "HGUtility.h"
#import "HGLogging.h"

NSString * const kCacheKeyPersonalizedOccasionGiftCollections = @"personalizedOccasionGiftCollections";
NSString * const kCacheKeyLastModifiedTimeOfPersonalizedOccasionGiftCollections = @"lastModifiedTimeOfPersonalizedOccasionGiftCollections";
NSString * const kCacheKeyAppConfiguration = @"appConfiguration";
NSString * const kCacheKeyLastModifiedTimeOfAppConfiguration = @"lastModifiedTimeOfAppConfiguration";
NSString * const kCacheKeyLastModifiedTimeOfSentGifts = @"lastModifiedTimeOfSentGifts";
NSString * const kCacheKeyLastModifiedTimeOfRecipients = @"lastModifiedTimeOfRecipients";
NSString * const kCacheKeyLastModifiedTimeOfMyLikeProducts = @"lastModifiedTimeOfMyLikeProducts";
NSString * const kCacheKeyLastModifiedTimeOfMyLikeIds = @"lastModifiedTimeOfMyLikeIds";
NSString * const kCacheKeyLastModifiedTimeOfCreditHistories = @"lastModifiedTimeOfCreditHistories";
NSString * const kCacheKeyLastModifiedTimeOfAstroTrends = @"lastModifiedTimeOfAstroTrends";
NSString * const kCacheKeyLastModifiedTimeOfFriendEmotions = @"lastModifiedTimeOfFriendEmotions";


static NSString * loaderCacheDataPath = nil;

@interface HGLoaderCache(Private)

+(NSString*) lastModifiedTimeWithVersionKey:(NSString*) key;

@end

@implementation HGLoaderCache

+ (void)initialize {
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    loaderCacheDataPath = [[[paths objectAtIndex:0] stringByAppendingPathComponent:@"LoaderCacheDataPath"] retain];
    [[NSFileManager defaultManager] createDirectoryAtPath:loaderCacheDataPath withIntermediateDirectories:YES attributes:nil error:nil];
}

+ (void)finalize {
    [loaderCacheDataPath release];
}

+(id) loadDataFromLoaderCache:(NSString*) key {
    if (key == nil || [@"" isEqualToString:key]) {
        return nil;
    }
    id result = nil;
    NSString *cacheDataPath = [loaderCacheDataPath stringByAppendingPathComponent:key];
    if ([[NSFileManager defaultManager] fileExistsAtPath:cacheDataPath]) {
        NSData* cacheData = [NSData dataWithContentsOfFile:cacheDataPath];
        result = [[[NSKeyedUnarchiver unarchiveObjectWithData:cacheData] retain] autorelease];
    }
    
    return result;
}

+(void) saveDataToLoaderCache:(id)data forKey: (NSString*)key {
    if (key == nil || [@"" isEqualToString:key] || data == nil || data == [NSNull null]) {
        return;
    }
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:loaderCacheDataPath] == NO) {
        [[NSFileManager defaultManager] createDirectoryAtPath:loaderCacheDataPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSString *cacheDataPath = [loaderCacheDataPath stringByAppendingPathComponent:key];
    NSData* cacheData = [NSKeyedArchiver archivedDataWithRootObject:data];
    [cacheData writeToFile:cacheDataPath atomically:YES];
}

+(void) saveLastModifiedTime:(NSString*)lastModifiedTime forKey:(NSString*)key {
    NSString* lastModifiedTimeWithVersionKey = [HGLoaderCache lastModifiedTimeWithVersionKey:key];
    [HGLoaderCache saveDataToLoaderCache:lastModifiedTime forKey:lastModifiedTimeWithVersionKey];
}

+(NSString*) lastModifiedTimeForKey:(NSString*)key {
    NSString* lastModifiedTimeWithVersionKey = [HGLoaderCache lastModifiedTimeWithVersionKey:key];
    NSString* lastModifiedTime = [HGLoaderCache loadDataFromLoaderCache:lastModifiedTimeWithVersionKey];
    HGDebug(@"lastModifiedTimeWithVersionKey:%@: %@", lastModifiedTimeWithVersionKey, lastModifiedTime);
    return lastModifiedTime;
}

+(NSString*) cacheKeyWithVersion:(NSString*) key {
    NSString* version = [HGUtility appBuild];
    return [NSString stringWithFormat:@"%@_Ver_%@", key, version];
}

+(NSString*) lastModifiedTimeWithVersionKey:(NSString*) key {
    return [HGLoaderCache cacheKeyWithVersion:key];
}

+(NSString*) appConfigurationCacheKey {
    return [HGLoaderCache cacheKeyWithVersion: kCacheKeyAppConfiguration];
}

+(void) clearPersonalizedCacheData {
    NSArray* lastModifiedTimeKeys = [[NSArray alloc] initWithObjects:kCacheKeyLastModifiedTimeOfPersonalizedOccasionGiftCollections, kCacheKeyLastModifiedTimeOfSentGifts, kCacheKeyLastModifiedTimeOfRecipients, kCacheKeyLastModifiedTimeOfMyLikeIds, kCacheKeyLastModifiedTimeOfMyLikeProducts, kCacheKeyLastModifiedTimeOfCreditHistories, kCacheKeyLastModifiedTimeOfAstroTrends, kCacheKeyLastModifiedTimeOfFriendEmotions, nil];
    
    for (NSString* lastModifiedTimeKey in lastModifiedTimeKeys) {
        NSString* lastModifiedTimeWithVersionKey = [HGLoaderCache lastModifiedTimeWithVersionKey:lastModifiedTimeKey];
        
        NSString *cacheDataPath = [loaderCacheDataPath stringByAppendingPathComponent:lastModifiedTimeWithVersionKey];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:cacheDataPath]) {
            [[NSFileManager defaultManager] removeItemAtPath:cacheDataPath error:nil];
        }
    }
    [lastModifiedTimeKeys release];
}

+(void) clearAllCacheData {
    if ([[NSFileManager defaultManager] fileExistsAtPath:loaderCacheDataPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:loaderCacheDataPath error:nil];
    }
}

@end;