//
//  HGGiftCategoryService.h
//  HappyGift
//
//  Created by Zhang Yuhui on 02/09/12.
//  Copyright 2011 Ztelic Inc Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
@class HGGiftCategoryLoader;
@protocol HGGiftCategoryServiceDelegate;

@interface HGGiftCategoryService : NSObject {
    HGGiftCategoryLoader* giftCategoryLoader;
    NSArray* giftCategories;
    id<HGGiftCategoryServiceDelegate> delegate;
}
@property (nonatomic, assign) id<HGGiftCategoryServiceDelegate> delegate;
@property (nonatomic, readonly) NSArray* giftCategories;

+ (HGGiftCategoryService*)sharedService;

- (void)requestGiftCategories;

@end


@protocol HGGiftCategoryServiceDelegate <NSObject>
- (void)giftCategoryService:(HGGiftCategoryService *)giftCategoryService didRequestGiftCategoriesSucceed:(NSArray*)giftCollections;
- (void)giftCategoryService:(HGGiftCategoryService *)giftCategoryService didRequestGiftCategoriesFail:(NSString*)error;
@end

