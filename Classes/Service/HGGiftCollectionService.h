//
//  HGGiftCollectionService.h
//  HappyGift
//
//  Created by Zhang Yuhui on 02/09/12.
//  Copyright 2011 Ztelic Inc Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
@class HGFeaturedGiftCollectionLoader;
@class HGGlobalOccasionGiftCollectionLoader;
@class HGPersonlizedOccasionGiftCollectionLoader;
@class HGGiftOccasion;
@protocol HGGiftCollectionServiceDelegate;

@interface HGGiftCollectionService : NSObject {
    HGFeaturedGiftCollectionLoader* featuredGiftCollectionLoader;
    HGGlobalOccasionGiftCollectionLoader* globalOccasionGiftCollectionLoader;
    HGPersonlizedOccasionGiftCollectionLoader* personlizedOccasionGiftCollectionLoader;
    HGPersonlizedOccasionGiftCollectionLoader* personalizedOccasionGIFGiftForFriendLoader;
    NSDictionary* occasionCategories;
    NSDictionary* occasionTags;
    NSArray* personalizedOccasionGiftCollectionsArray;
    NSArray* featuredGiftCollectionsArray;
    NSArray* globalOccasiondGiftCollectionsArray;
    id<HGGiftCollectionServiceDelegate> delegate;
}
@property (nonatomic, assign) id<HGGiftCollectionServiceDelegate> delegate;
@property (nonatomic, readonly) NSDictionary* occasionCategories;
@property (nonatomic, readonly) NSDictionary* occasionTags;
@property (nonatomic, readonly) NSArray* personalizedOccasionGiftCollectionsArray;
@property (nonatomic, readonly) NSArray* featuredGiftCollectionsArray;
@property (nonatomic, readonly) NSArray* globalOccasiondGiftCollectionsArray;

+ (HGGiftCollectionService*)sharedService;

- (void)requestFeaturedGiftCollections;
- (void)requestGlobalOccasionGiftCollections;
- (void)requestPersonlizedOccasionGiftCollections;
- (void)requestGiftsForOccasion:(NSString*)occasion andNetworkId:(int)networkId andProfileId:(NSString*)profileId withOffset:(int)offset andTagId:(NSString*)tagId;
- (void)requestGIFGiftsForOccasion:(NSString*)occasion andNetworkId:(int)networkId andProfileId:(NSString*)profileId withOffset:(int)offset andTagId:(NSString*)tagId;
- (void)clearPersonalizedOccasionCache;

@end


@protocol HGGiftCollectionServiceDelegate <NSObject>
@optional
- (void)giftCollectionService:(HGGiftCollectionService *)giftCollectionService didRequestFeaturedGiftCollectionsSucceed:(NSArray*)giftCollections;
- (void)giftCollectionService:(HGGiftCollectionService *)giftCollectionService didRequestFeaturedGiftCollectionsFail:(NSString*)error;

- (void)giftCollectionService:(HGGiftCollectionService *)giftCollectionService didRequestGlobalOccasionGiftCollectionsSucceed:(NSArray*)giftCollections;
- (void)giftCollectionService:(HGGiftCollectionService *)giftCollectionService didRequestGlobalOccasiondGiftCollectionsFail:(NSString*)error;

- (void)giftCollectionService:(HGGiftCollectionService *)giftCollectionService didRequestPersonlizedOccasionGiftCollectionsSucceed:(NSArray*)giftCollectionsArray;
- (void)giftCollectionService:(HGGiftCollectionService *)giftCollectionService didRequestPersonlizedOccasiondGiftCollectionsFail:(NSString*)error;

- (void)giftCollectionService:(HGGiftCollectionService *)giftCollectionService didRequestGiftsForOccasionSucceed:(NSArray*)giftsForOccasion;
- (void)giftCollectionService:(HGGiftCollectionService *)giftCollectionService didRequestGiftsForOccasionFail:(NSString*)error;

- (void)giftCollectionService:(HGGiftCollectionService *)giftCollectionService didRequestGIFGiftsForOccasionSucceed:(NSArray*)giftsForOccasion;
- (void)giftCollectionService:(HGGiftCollectionService *)giftCollectionService didRequestGIFGiftsForOccasionFail:(NSString*)error;
@end

