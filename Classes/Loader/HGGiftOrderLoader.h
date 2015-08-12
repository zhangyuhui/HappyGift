//
//  HGGiftOrderLoader.h
//  HappyGift
//
//  Created by Zhang Yuhui on 02/09/12.
//  Copyright 2011 Ztelic Inc Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HGNetworkConnection.h"
#import "HGGiftOrder.h"
#import "HGFeaturedGiftCollection.h"

@protocol HGGiftOrderLoaderDelegate;

@interface HGGiftOrderLoader : HGNetworkConnection {
    BOOL running;
    HGGiftOrder* giftOrder;
    int requestType;
}
@property (nonatomic, assign)   id<HGGiftOrderLoaderDelegate> delegate;
@property (nonatomic, readonly) BOOL  running;

- (void)requestPlaceOrder:(HGGiftOrder*)giftOrder;
- (void)requestCancelOrder:(HGGiftOrder*)giftOrder;
- (void)requestMyGifts;
- (void)requestMyGiftOrder:(NSString*)orderId;
- (void)requestShippingCost:(HGGiftOrder*)theGiftOrder;
-(NSArray*) sentGiftsLoaderCache;

@end

@protocol HGGiftOrderLoaderDelegate
- (void)giftOrderLoader:(HGGiftOrderLoader *)giftOrderLoader didRequestPlaceOrderSucceed:(HGGiftOrder*)giftOrder;
- (void)giftOrderLoader:(HGGiftOrderLoader *)giftOrderLoader didRequestPlaceOrderFail:(NSString*)error;

- (void)giftOrderLoader:(HGGiftOrderLoader *)giftOrderLoader didRequestCancelOrderSucceed:(HGGiftOrder*)giftOrder;
- (void)giftOrderLoader:(HGGiftOrderLoader *)giftOrderLoader didRequestCancelOrderFail:(NSString*)error;

- (void)giftOrderLoader:(HGGiftOrderLoader *)giftOrderLoader didRequestMyGiftsSucceed:(NSArray*)orders;
- (void)giftOrderLoader:(HGGiftOrderLoader *)giftOrderLoader didRequestMyGiftsFail:(NSString*)error;

- (void)giftOrderLoader:(HGGiftOrderLoader *)giftOrderLoader didRequestMyGiftOrderSucceed:(HGGiftOrder*)order;
- (void)giftOrderLoader:(HGGiftOrderLoader *)giftOrderLoader didRequestMyGiftOrderFail:(NSString*)error;

- (void)giftOrderLoader:(HGGiftOrderLoader *)giftOrderLoader didRequestShippingCostSucceed:(float)shippingCost;
- (void)giftOrderLoader:(HGGiftOrderLoader *)giftOrderLoader didRequestShippingCostFail:(NSString*)error;
@end
