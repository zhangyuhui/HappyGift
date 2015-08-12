//
//  HGGiftCategoryLoader.h
//  HappyGift
//
//  Created by Zhang Yuhui on 02/09/12.
//  Copyright 2011 Ztelic Inc Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HGNetworkConnection.h"
#import "HGFeaturedGiftCollection.h"

@protocol HGGiftCategoryLoaderDelegate;

@interface HGGiftCategoryLoader : HGNetworkConnection {
    BOOL running;
}
@property (nonatomic, assign)   id<HGGiftCategoryLoaderDelegate> delegate;
@property (nonatomic, readonly) BOOL  running;

- (void)requestGiftCategories;

@end


@protocol HGGiftCategoryLoaderDelegate
- (void)giftCategoryLoader:(HGGiftCategoryLoader *)giftCategoryLoader didRequestGiftCategoriesSucceed:(NSArray*)giftCategories;
- (void)giftCategoryLoader:(HGGiftCategoryLoader *)giftCategoryLoader didRequestRequestGiftCategoriesFail:(NSString*)error;
@end
