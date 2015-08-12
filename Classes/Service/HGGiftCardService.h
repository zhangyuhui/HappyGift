//
//  HGGiftCardService.h
//  HappyGift
//
//  Created by Zhang Yuhui on 02/09/12.
//  Copyright 2011 Ztelic Inc Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
@class HGGiftCardLoader;
@protocol HGGiftCardServiceDelegate;

@interface HGGiftCardService : NSObject {
    HGGiftCardLoader* giftCardLoader;
    NSArray* giftCardCategories;
    id<HGGiftCardServiceDelegate> delegate;
}
@property (nonatomic, assign) id<HGGiftCardServiceDelegate> delegate;
@property (nonatomic, retain) NSArray* giftCardCategories;

+ (HGGiftCardService*)sharedService;

+ (NSArray*)titleWords;
+ (NSArray*)enclosureWords;

- (void)requestGiftCards;

@end


@protocol HGGiftCardServiceDelegate <NSObject>
- (void)giftCardService:(HGGiftCardService *)giftCardService didRequestGiftCardsSucceed:(NSArray*)giftCardCollections;
- (void)giftCardService:(HGGiftCardService *)giftCardService didRequestGiftCardsFail:(NSString*)error;
@end

