//
//  HGGiftOrderService.h
//  HappyGift
//
//  Created by Zhang Yuhui on 02/09/12.
//  Copyright 2011 Ztelic Inc Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
@class HGGiftOrderLoader;
@class HGGiftOrder;
@protocol HGGiftOrderServiceDelegate;

@interface HGGiftOrderService : NSObject {
    HGGiftOrderLoader* giftOrderLoader;
    HGGiftOrderLoader* sentGiftsLoader;
    HGGiftOrderLoader* specifiedGiftOrderLoader;
    HGGiftOrderLoader* shippingCostLoader;
    id<HGGiftOrderServiceDelegate> delegate;
    
    id<HGGiftOrderServiceDelegate> myGiftOrderDelegate;
    
    NSArray* sentGifts;
    
    NSArray* giftsNeedPaid;
    NSArray* giftsHistory;
}
@property (nonatomic, assign) id<HGGiftOrderServiceDelegate> delegate;
@property (nonatomic, assign) id<HGGiftOrderServiceDelegate> myGiftOrderDelegate;
@property (nonatomic, retain) NSArray* sentGifts;
@property (nonatomic, retain) NSArray* giftsNeedPaid;
@property (nonatomic, retain) NSArray* giftsHistory;

+ (HGGiftOrderService*)sharedService;
+ (NSString*) formatOrderStatusText:(HGGiftOrder *)order;

- (void)requestPlaceOrder:(HGGiftOrder*)giftOrder;
- (void)requestCancelOrder:(HGGiftOrder*)giftOrder;
- (void)requestMyGifts;
- (void)requestMyGiftOrder:(NSString*)orderId;
- (void)requestShippingCost:(HGGiftOrder*)giftOrder;
- (void)clearMyGiftsCache;

@end

@protocol HGGiftOrderServiceDelegate <NSObject>
@optional
- (void)giftOrderService:(HGGiftOrderService *)giftOrderService didRequestPlaceGiftOrderSucceed:(HGGiftOrder*)giftOrder;
- (void)giftOrderService:(HGGiftOrderService *)giftOrderService didRequestPlaceGiftOrderFail:(NSString*)error;

- (void)giftOrderService:(HGGiftOrderService *)giftOrderService didRequestCancelGiftOrderSucceed:(HGGiftOrder*)giftOrder;
- (void)giftOrderService:(HGGiftOrderService *)giftOrderService didRequestCancelGiftOrderFail:(NSString*)error;

- (void)giftOrderService:(HGGiftOrderService *)giftOrderService didRequestMyGiftsSucceed:(NSArray*)myGifts;
- (void)giftOrderService:(HGGiftOrderService *)giftOrderService didRequestMyGiftsFail:(NSString*)error;

- (void)giftOrderService:(HGGiftOrderService *)giftOrderService didRequestMyGiftOrderSucceed:(HGGiftOrder*)order;
- (void)giftOrderService:(HGGiftOrderService *)giftOrderService didRequestMyGiftOrderFail:(NSString*) error;

- (void)giftOrderService:(HGGiftOrderService *)giftOrderService didRequestShippingCostSucceed:(float)shippingCost;
- (void)giftOrderService:(HGGiftOrderService *)giftOrderService didRequestShippingCostFail:(NSString*) error;
@end

