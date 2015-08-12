//
//  HGGiftCardLoader.h
//  HappyGift
//
//  Created by Zhang Yuhui on 02/09/12.
//  Copyright 2011 Ztelic Inc Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HGNetworkConnection.h"
#import "HGFeaturedGiftCollection.h"

@protocol HGGiftCardLoaderDelegate;

@interface HGGiftCardLoader : HGNetworkConnection {
    BOOL running;
}
@property (nonatomic, assign)   id<HGGiftCardLoaderDelegate> delegate;
@property (nonatomic, readonly) BOOL  running;

- (void)requestGiftCards;
- (NSArray*)giftCardCategoriesLoaderCache;
@end


@protocol HGGiftCardLoaderDelegate
- (void)giftCardLoader:(HGGiftCardLoader *)giftCardLoader didRequestGiftCardsSucceed:(NSArray*)giftCardCategories;
- (void)giftCardLoader:(HGGiftCardLoader *)giftCardLoader didRequestRequestGiftCardsFail:(NSString*)error;
@end
