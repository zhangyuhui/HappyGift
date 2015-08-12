//
//  HGGiftSetsService.h
//  HappyGift
//
//  Created by Zhang Yuhui on 02/09/12.
//  Copyright 2011 Ztelic Inc Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol HGGiftSetsServiceDelegate;
@class HGGiftSetsLoader;
@class HGGift;
@class HGFavoriteLoader;

@interface HGGiftSetsService : NSObject {
    HGGiftSetsLoader* giftSetsLoader;
    HGGiftSetsLoader* giftDetailLoader;
    HGFavoriteLoader* favoriteLoader;
    HGFavoriteLoader* likeLoader;
    HGFavoriteLoader* unLikeLoader;
    NSDictionary* giftSets;
    NSArray*      myLikeProducts;
    NSMutableSet* myLikeIds;
    id<HGGiftSetsServiceDelegate> delegate;
}
@property (nonatomic, readonly) NSDictionary* giftSets;
@property (nonatomic, retain) NSArray*      myLikeProducts;
@property (nonatomic, retain) NSMutableSet*   myLikeIds;
@property (nonatomic, assign) id<HGGiftSetsServiceDelegate> delegate;

+ (HGGiftSetsService*)sharedService;

- (void)requestGiftSets;
- (void)requestGiftDetail:(NSString*) giftId;
- (void)requestGiftLike:(NSString*) giftId;
- (void)requestGiftUnLike:(NSString*) giftId;
- (void)requestMyLikeProducts;
- (void)requestMyLikeIds;
- (BOOL)isMyLike:(HGGift*)gift;
- (void)clearMyLikesCache;

@end


@protocol HGGiftSetsServiceDelegate <NSObject>
@optional
- (void)giftSetsService:(HGGiftSetsService *)giftSetsService didRequestGiftSetsSucceed:(NSDictionary*)giftSets;
- (void)giftSetsService:(HGGiftSetsService *)giftSetsService didRequestGiftSetsFail:(NSString*)error;

- (void)giftSetsService:(HGGiftSetsService *)giftSetsService didRequestGiftDetailSucceed:(HGGift*)gift;
- (void)giftSetsService:(HGGiftSetsService *)giftSetsService didRequestGiftDetailFail:(NSString*)error;

- (void)giftSetsService:(HGGiftSetsService *)giftSetsService didRequestGiftLikeSucceed:(NSString*)giftId;
- (void)giftSetsService:(HGGiftSetsService *)giftSetsService didRequestGiftLikeFail:(NSString*)error;

- (void)giftSetsService:(HGGiftSetsService *)giftSetsService didRequestGiftUnLikeSucceed:(NSString*)giftId;
- (void)giftSetsService:(HGGiftSetsService *)giftSetsService didRequestGiftUnLikeFail:(NSString*)error;

- (void)giftSetsService:(HGGiftSetsService *)giftSetsService didRequestMyLikeProductsSucceed:(NSArray*)myLikes;
- (void)giftSetsService:(HGGiftSetsService *)giftSetsService didRequestMyLikeProductsFail:(NSString*)error;
@end

