//
//  HGGiftOrderService.m
//  HappyGift
//
//  Created by Zhang Yuhui on 02/09/12.
//  Copyright 2011 Ztelic Inc. All rights reserved.
//

#import "HGGiftOrderService.h"
#import "HGGiftOrderLoader.h"
#import "HGConstants.h"
#import "HappyGiftAppDelegate.h"
#import "HGGiftOrder.h"
#import "HGLogging.h"

static HGGiftOrderService* giftOrderService;


@interface HGGiftOrderService () <HGGiftOrderLoaderDelegate>

@end

@implementation HGGiftOrderService
@synthesize delegate;
@synthesize myGiftOrderDelegate;
@synthesize sentGifts;
@synthesize giftsNeedPaid;
@synthesize giftsHistory;

+ (HGGiftOrderService*)sharedService{
    if (giftOrderService == nil){
        giftOrderService = [[HGGiftOrderService alloc] init];
    }
    return giftOrderService;
}

- (id) init {
    self = [super init];
    if (self) {
        sentGiftsLoader = [[HGGiftOrderLoader alloc] init];
        sentGiftsLoader.delegate = self;
        sentGifts = [[sentGiftsLoader sentGiftsLoaderCache] retain];
        [self buildNeedPaidAndHistoryArray];
    }
    return self;
}

- (void)dealloc{
    [giftOrderLoader release];
    [sentGiftsLoader release];
    [specifiedGiftOrderLoader release];
    [shippingCostLoader release];
    
    self.giftsHistory = nil;
    self.giftsNeedPaid = nil;
    [sentGifts release];
    
    [super dealloc];
}

- (void)requestPlaceOrder:(HGGiftOrder*)giftOrder{
    if (giftOrderLoader != nil){
        [giftOrderLoader cancel];
    }else{
        giftOrderLoader = [[HGGiftOrderLoader alloc] init];
        giftOrderLoader.delegate = self;
    }
    [giftOrderLoader requestPlaceOrder:giftOrder];
}

- (void)requestCancelOrder:(HGGiftOrder*)giftOrder{
    if (giftOrderLoader != nil){
        [giftOrderLoader cancel];
    }else{
        giftOrderLoader = [[HGGiftOrderLoader alloc] init];
        giftOrderLoader.delegate = self;
    }
    [giftOrderLoader requestCancelOrder:giftOrder];
}

- (void)requestMyGifts {
    if (sentGiftsLoader != nil) {
        [sentGiftsLoader cancel];
    } else {
        sentGiftsLoader = [[HGGiftOrderLoader alloc] init];
        sentGiftsLoader.delegate = self;
    }
    [sentGiftsLoader requestMyGifts];
}

- (void)requestMyGiftOrder:(NSString*)orderId {
    if (specifiedGiftOrderLoader != nil) {
        [specifiedGiftOrderLoader cancel];
    } else {
        specifiedGiftOrderLoader = [[HGGiftOrderLoader alloc] init];
        specifiedGiftOrderLoader.delegate = self;
    }
    
    [specifiedGiftOrderLoader requestMyGiftOrder:orderId];
}

- (void)requestShippingCost:(HGGiftOrder*)giftOrder {
    if (shippingCostLoader != nil) {
        [shippingCostLoader cancel];
    } else {
        shippingCostLoader = [[HGGiftOrderLoader alloc] init];
        shippingCostLoader.delegate = self;
    }
    [shippingCostLoader requestShippingCost:giftOrder];
}

-(void) clearMyGiftsCache {
    self.sentGifts = nil;
    self.giftsNeedPaid = nil;
    self.giftsHistory = nil;
}
 
#pragma mark　- HGGiftOrderLoaderDelegate 
- (void)giftOrderLoader:(HGGiftOrderLoader *)theGiftOrderLoader didRequestPlaceOrderSucceed:(HGGiftOrder*)theGiftOrder{
    if (theGiftOrder.gift.type == GIFT_TYPE_COUPON){
         theGiftOrder.status = GIFT_ORDER_STATUS_SHIPPED;
         theGiftOrder.isPaid = YES;
    }else{
         theGiftOrder.status = GIFT_ORDER_STATUS_NEW;
    }
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    theGiftOrder.orderCreatedDate = [formatter stringFromDate:[NSDate date]];
    [formatter release];
    
    NSMutableArray* theSentGifts = [[NSMutableArray alloc] initWithObjects:theGiftOrder, nil];
    [theSentGifts addObjectsFromArray:self.sentGifts];
    self.sentGifts = theSentGifts;
    [theSentGifts release];
    
    if (theGiftOrder.gift.type != GIFT_TYPE_COUPON){
        NSMutableArray* theGiftsNeedPaid = [[NSMutableArray alloc] initWithObjects:theGiftOrder, nil];
        [theGiftsNeedPaid addObjectsFromArray:self.giftsNeedPaid];
        self.giftsNeedPaid = theGiftsNeedPaid;
        [theGiftsNeedPaid release];
    }
    
    if ([delegate respondsToSelector:@selector(giftOrderService:didRequestPlaceGiftOrderSucceed:)]){
        [delegate giftOrderService:self didRequestPlaceGiftOrderSucceed:theGiftOrder];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kHGNotificationMyGiftsUpdated object:self];
}

- (void)giftOrderLoader:(HGGiftOrderLoader *)theGiftOrderLoader didRequestPlaceOrderFail:(NSString*)theError{
    if ([delegate respondsToSelector:@selector(giftOrderService:didRequestPlaceGiftOrderFail:)]){
        [delegate giftOrderService:self didRequestPlaceGiftOrderFail:theError];
    }
}

- (void)giftOrderLoader:(HGGiftOrderLoader *)theGiftOrderLoader didRequestCancelOrderSucceed:(HGGiftOrder*)theGiftOrder{
    theGiftOrder.status = GIFT_ORDER_STATUS_CANCELED;
    for (HGGiftOrder* theGiftOrderNeedPaid in self.giftsNeedPaid){
        if ([theGiftOrderNeedPaid.identifier isEqualToString:theGiftOrder.identifier]){
            NSMutableArray* theGiftsHistory = [[NSMutableArray alloc] initWithObjects:theGiftOrder, nil];
            [theGiftsHistory addObjectsFromArray:giftsHistory];
            self.giftsHistory = theGiftsHistory;
            [theGiftsHistory release];
            
            NSMutableArray* theGiftsNeedPaid = [[NSMutableArray alloc] initWithArray:self.giftsNeedPaid];
            [theGiftsNeedPaid removeObject:theGiftOrder];
            self.giftsNeedPaid = theGiftsNeedPaid;
            [theGiftsNeedPaid release];
            break;
        }
    }
    if ([delegate respondsToSelector:@selector(giftOrderService:didRequestCancelGiftOrderSucceed:)]){
        [delegate giftOrderService:self didRequestCancelGiftOrderSucceed:theGiftOrder];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kHGNotificationMyGiftsUpdated object:self];
}

- (void)giftOrderLoader:(HGGiftOrderLoader *)theGiftOrderLoader didRequestCancelOrderFail:(NSString*)theError{
    if ([delegate respondsToSelector:@selector(giftOrderService:didRequestCancelGiftOrderFail:)]){
        [delegate giftOrderService:self didRequestCancelGiftOrderFail:theError];
    }
}

-(void) buildNeedPaidAndHistoryArray {
    NSMutableArray* tmpNeedPaid = [[NSMutableArray alloc] init];    
    NSMutableArray* tmpHistory = [[NSMutableArray alloc] init];
    
    for (HGGiftOrder* order in sentGifts) {
        if (![order isPaidOrCanceled]) {
            [tmpNeedPaid addObject: order];
        } else {
            [tmpHistory addObject:order];
        }
    }
    self.giftsNeedPaid = tmpNeedPaid;
    self.giftsHistory = tmpHistory;
    
    [tmpNeedPaid release];
    [tmpHistory release];
}

- (void)giftOrderLoader:(HGGiftOrderLoader *)giftOrderLoader didRequestMyGiftsSucceed:(NSArray*)orders {
    BOOL changed = NO;
    
    if (self.sentGifts == nil || [self.sentGifts count] != [orders count]) {
        changed = YES;
    } else {
        int count = [orders count];
        for (int i = 0; i < count; ++i) {
            HGGiftOrder* order1 = [self.sentGifts objectAtIndex:i];
            HGGiftOrder* order2 = [orders objectAtIndex:i];
            
            if (![order1.identifier isEqualToString:order2.identifier] ||
                order1.status != order2.status || order1.isPaid != order2.isPaid) {
                changed = YES;
                break;
            }
        }
    }
    HGDebug(@"changed: %@", changed ? @"YES" : @"NO");
    
    self.sentGifts = orders;
    [self buildNeedPaidAndHistoryArray];
    
    if ([delegate respondsToSelector:@selector(giftOrderService:didRequestMyGiftsSucceed:)]){
        [delegate giftOrderService:self didRequestMyGiftsSucceed:orders];
    }
    
    if (changed) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kHGNotificationMyGiftsUpdated object:self];
    }
} 

- (void)giftOrderLoader:(HGGiftOrderLoader *)theGiftOrderLoader didRequestMyGiftsFail:(NSString*)error {
    NSArray* theSentGifts = [theGiftOrderLoader sentGiftsLoaderCache];
    if (theSentGifts) {
        HGDebug(@"giftOrderLoader request failed, use cached data");
        self.sentGifts = theSentGifts;
        [self buildNeedPaidAndHistoryArray];
    }
    
    if ([delegate respondsToSelector:@selector(giftOrderService:didRequestMyGiftsFail:)]){
        [delegate giftOrderService:self didRequestMyGiftsFail:error];
    }
}

- (void)giftOrderLoader:(HGGiftOrderLoader *)giftOrderLoader didRequestMyGiftOrderSucceed:(HGGiftOrder*)order {
    if ([myGiftOrderDelegate respondsToSelector:@selector(giftOrderService:didRequestMyGiftOrderSucceed:)]) {
        [myGiftOrderDelegate giftOrderService:self didRequestMyGiftOrderSucceed:order];
    }
}

- (void)giftOrderLoader:(HGGiftOrderLoader *)giftOrderLoader didRequestMyGiftOrderFail:(NSString*)error {
    if ([myGiftOrderDelegate respondsToSelector:@selector(giftOrderService:didRequestMyGiftOrderFail:)]) {
        [myGiftOrderDelegate giftOrderService:self didRequestMyGiftOrderFail:error];
    }
}

- (void)giftOrderLoader:(HGGiftOrderLoader *)giftOrderLoader didRequestShippingCostSucceed:(float)shippingCost {
    if ([delegate respondsToSelector:@selector(giftOrderService:didRequestShippingCostSucceed:)]) {
        [delegate giftOrderService:self didRequestShippingCostSucceed:shippingCost];
    }
}

- (void)giftOrderLoader:(HGGiftOrderLoader *)giftOrderLoader didRequestShippingCostFail:(NSString*)error {
    if ([delegate respondsToSelector:@selector(giftOrderService:didRequestShippingCostFail:)]) {
        [delegate giftOrderService:self didRequestShippingCostFail:error];
    }
}

+ (NSString*) formatOrderStatusText:(HGGiftOrder *)order {
    if (order.status == GIFT_ORDER_STATUS_NOTIFIED) {
        return @"已通知";
    } else if (order.status == GIFT_ORDER_STATUS_READ) {
        return @"贺卡已读";
    } else if (order.status == GIFT_ORDER_STATUS_ACCEPTED) {
        return @"已接受";
    } else if (order.status == GIFT_ORDER_STATUS_SHIPPED) {
        return @"已投递";
    } else if (order.status == GIFT_ORDER_STATUS_DELIVERED) {
        return @"已送达";
    } else if (order.status == GIFT_ORDER_STATUS_CANCELED) {
        return @"已取消";
    } else if (order.status == GIFT_ORDER_STATUS_NEW) {
        return @"新订单";
    } else {
        return @"";
    }
}

@end
