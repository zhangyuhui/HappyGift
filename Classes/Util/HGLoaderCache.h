//
//  HGContactInfoViewController.m
//  HappyGift
//
//  Created by Yujian Weng on 12-5-30.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//


#import <Foundation/Foundation.h>

extern NSString * const kCacheKeyPersonalizedOccasionGiftCollections;
extern NSString * const kCacheKeyLastModifiedTimeOfPersonalizedOccasionGiftCollections;
extern NSString * const kCacheKeyLastModifiedTimeOfSentGifts;
extern NSString * const kCacheKeyAppConfiguration;
extern NSString * const kCacheKeyLastModifiedTimeOfAppConfiguration;
extern NSString * const kCacheKeyLastModifiedTimeOfRecipients;
extern NSString * const kCacheKeyLastModifiedTimeOfMyLikeProducts;
extern NSString * const kCacheKeyLastModifiedTimeOfMyLikeIds;
extern NSString * const kCacheKeyLastModifiedTimeOfCreditHistories;
extern NSString * const kCacheKeyLastModifiedTimeOfAstroTrends;
extern NSString * const kCacheKeyLastModifiedTimeOfFriendEmotions;

@interface HGLoaderCache : NSObject {

}

+(id) loadDataFromLoaderCache:(NSString*) key;
+(void) saveDataToLoaderCache:(id)data forKey: (NSString*)key;
+(void) saveLastModifiedTime:(NSString*)lastModifiedTime forKey:(NSString*)key;
+(NSString*) lastModifiedTimeForKey:(NSString*)key;
+(void) clearPersonalizedCacheData;
+(void) clearAllCacheData;
+(NSString*) appConfigurationCacheKey;

@end