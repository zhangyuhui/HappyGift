//
//  HGFavoriteLoader.h
//  HappyGift
//
//  Created by Zhang Yuhui on 12-6-20.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HGNetworkConnection.h"

@protocol HGFavoriteLoaderDelegate;

@interface HGFavoriteLoader : HGNetworkConnection {
    BOOL running;
    int  requestType;
    NSString* requestGiftId;
}

@property (nonatomic, assign)   id<HGFavoriteLoaderDelegate> delegate;
@property (nonatomic, readonly) BOOL running;

- (void)requestGiftLike:(NSString*)giftId;
- (void)requestGiftUnLike:(NSString*)giftId;
- (void)requestMyLikeProducts;
- (void)requestMyLikeIds;
- (NSArray*)myLikeProductsLoaderCache;
- (NSSet*)myLikeIdsLoaderCache;

@end

@protocol HGFavoriteLoaderDelegate
- (void)favoriteLoader:(HGFavoriteLoader *)favoriteLoader didRequestGiftLikeSucceed:(NSString*)giftId;
- (void)favoriteLoader:(HGFavoriteLoader *)favoriteLoader didRequestGiftLikeFail:(NSString*)error forGiftId:(NSString*)giftId;
- (void)favoriteLoader:(HGFavoriteLoader *)favoriteLoader didRequestGiftUnLikeSucceed:(NSString*)giftId;
- (void)favoriteLoader:(HGFavoriteLoader *)favoriteLoader didRequestGiftUnLikeFail:(NSString*)error forGiftId:(NSString*)giftId;
- (void)favoriteLoader:(HGFavoriteLoader *)favoriteLoader didRequestMyLikeProductsSucceed:(NSArray*)myLikes;
- (void)favoriteLoader:(HGFavoriteLoader *)favoriteLoader didRequestMyLikeProductsFail:(NSString *)error;
- (void)favoriteLoader:(HGFavoriteLoader *)favoriteLoader didRequestMyLikeIdsSucceed:(NSSet*)myLikesId;
- (void)favoriteLoader:(HGFavoriteLoader *)favoriteLoader didRequestMyLikeIdsFail:(NSString *)error;
@end

