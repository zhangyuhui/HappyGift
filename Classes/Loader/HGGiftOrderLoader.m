//
//  HGGiftOrderLoader.m
//  HappyGift
//
//  Created by Zhang Yuhui on 02/09/12.
//  Copyright 2011 Ztelic Inc. All rights reserved.
//

#import "HGGiftOrderLoader.h"
#import "JSON.h"
#import "HGNetworkHost.h"
#import "HGConstants.h"
#import "HGGiftOrder.h"
#import "HappyGiftAppDelegate.h"
#import "HGLogging.h"
#import "NSString+Addition.h"
#import <sqlite3.h>
#import "HGAccountService.h"
#import "HGLoaderCache.h"
#import "HGLogging.h"
#import "HGRecipientService.h"

#define kRequestTypeGiftOrderPlace 0
#define kRequestTypeGiftOrderCancel 1
#define kRequestTypeMyGifts 2
#define kRequestTypeMyGiftOrder 3
#define kRequestTypeShippingCost 4

static NSString *kGiftOrderPlaceRequestFormat = @"%@/gift/index.php?route=order/place_order";
static NSString *kGiftCouponOrderPlaceRequestFormat = @"%@/gift/index.php?route=order/place_order/place_coupon_order";
static NSString *kGiftOrderCancelRequestFormat = @"%@/gift/index.php?route=order/cancel_order&order_id=%@";
static NSString *kMyGiftsRequestFormat = @"%@/gift/index.php?route=user/mygifts";
static NSString *kMyGiftOrderRequestFormat = @"%@/gift/index.php?route=user/mygifts/order&order_id=%@";
static NSString *kMyGiftOrderShippingCostRequestFormat = @"%@/gift/index.php?route=order/shipping_cost&product_id=%@&province=%@&city=%@&postcode=%@";

@interface HGGiftOrderLoader()
@end

@implementation HGGiftOrderLoader
@synthesize delegate;
@synthesize running;

- (void)dealloc {
    [super dealloc];
}

- (void)cancel {	
    [super cancel];
    running = NO;
}

- (void)requestMyGifts {
    if (running) {
        return;
    }
    [self cancel];
    requestType = kRequestTypeMyGifts;
    
    NSString* requestString = [NSString stringWithFormat:kMyGiftsRequestFormat, [HappyGiftAppDelegate backendServiceHost]];
    HGDebug(@"%@", requestString);
    NSURL* requestURL = [NSURL URLWithString:[requestString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    NSMutableDictionary* headers = nil;
    NSString* lastModifiedTime = [self getLastModifiedTimeOfSentGifts];
    
    if (lastModifiedTime) {
        headers = [NSMutableDictionary dictionaryWithObject:lastModifiedTime forKey:kHttpHeaderIfModifiedSince];
    }
    
    [super requestByGet:requestURL withHeaders:headers];
}

- (void)requestMyGiftOrder:(NSString*)orderId {
    if (running) {
        return;
    }
    [self cancel];
    requestType = kRequestTypeMyGiftOrder;
    
    NSString* requestString = [NSString stringWithFormat:kMyGiftOrderRequestFormat, [HappyGiftAppDelegate backendServiceHost], orderId];
    
    HGDebug(@"%@", requestString);
    
    NSURL* requestURL = [NSURL URLWithString:[requestString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];

    [super requestByGet:requestURL];
}

- (void)requestShippingCost:(HGGiftOrder*)theGiftOrder {
    if (running) {
        return;
    }
    [self cancel];
    requestType = kRequestTypeShippingCost;
    
    HGRecipient* recipient = theGiftOrder.giftRecipient;
    
    NSString* provinceCode = [[HGRecipientService sharedService].provinceCode objectForKey:recipient.recipientProvince];
    
    NSString* requestString = [NSString stringWithFormat:kMyGiftOrderShippingCostRequestFormat, [HappyGiftAppDelegate backendServiceHost], theGiftOrder.gift.identifier, provinceCode, recipient.recipientCity, recipient.recipientPostCode];
    
    HGDebug(@"%@", requestString);
    
    NSURL* requestURL = [NSURL URLWithString:[requestString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    [super requestByGet:requestURL];
}

- (void)requestPlaceOrder:(HGGiftOrder*)theGiftOrder{
    if (running){
        return;
    }
    [self cancel];
    requestType = kRequestTypeGiftOrderPlace;
    running = YES;
    giftOrder = [theGiftOrder retain];
    
    NSMutableString* requestString = [[NSMutableString alloc] init];
    
    if (theGiftOrder.gift.type == GIFT_TYPE_COUPON){
        [requestString appendFormat:kGiftCouponOrderPlaceRequestFormat, [HappyGiftAppDelegate backendServiceHost]];
    }else{
        [requestString appendFormat:kGiftOrderPlaceRequestFormat, [HappyGiftAppDelegate backendServiceHost]];
    }
    
    [requestString appendFormat:@"&product_id=%@", giftOrder.gift.identifier];
    [requestString appendFormat:@"&recipient_name=%@", giftOrder.giftRecipient.recipientDisplayName];
    
    HGAccount* currentAccount = [HGAccountService sharedService].currentAccount;
    
    if (currentAccount.userEmail && ![currentAccount.userEmail isEqualToString:@""]) {
        [requestString appendFormat:@"&sender_email=%@", currentAccount.userEmail];
    }
    
    if (currentAccount.userPhone && ![currentAccount.userPhone isEqualToString:@""]) {
        [requestString appendFormat:@"&sender_phone=%@", currentAccount.userPhone];
    }
    
    if (giftOrder.giftDelivery.phoneNotify == YES && giftOrder.giftDelivery.phone != nil && [giftOrder.giftDelivery.phone isEqualToString:@""] == NO){
        [requestString appendFormat:@"&addr_phone=%@", giftOrder.giftDelivery.phone];
    }
    if (giftOrder.giftDelivery.emailNotify == YES && giftOrder.giftDelivery.email != nil && [giftOrder.giftDelivery.email isEqualToString:@""] == NO){
        [requestString appendFormat:@"&addr_email=%@", giftOrder.giftDelivery.email];
    }
    
    if (giftOrder.orderType == kOrderTypeQuickOrder) {
        [requestString appendFormat:@"&order_type=quick"];
        
        if (giftOrder.orderNotifyDate == nil) {
            [requestString appendFormat:@"&notify_date=%ld", (long)[[NSDate date] timeIntervalSince1970]];
        } else {
            [requestString appendFormat:@"&notify_date=%ld", (long)[giftOrder.orderNotifyDate timeIntervalSince1970]];
        }
        NSString* provinceCode = [[HGRecipientService sharedService].provinceCode objectForKey:giftOrder.giftRecipient.recipientProvince];
        [requestString appendFormat:@"&province_code=%@", provinceCode];
        [requestString appendFormat:@"&addr_province=%@", giftOrder.giftRecipient.recipientProvince];
        [requestString appendFormat:@"&addr_city=%@", giftOrder.giftRecipient.recipientCity];
        [requestString appendFormat:@"&addr_street=%@", giftOrder.giftRecipient.recipientStreetAddress];
        [requestString appendFormat:@"&addr_postcode=%@", giftOrder.giftRecipient.recipientPostCode];
    } else {
        if (giftOrder.orderNotifyDate == nil) {
            [requestString appendFormat:@"&notify_date=0"];
        } else {
            [requestString appendFormat:@"&notify_date=%ld", (long)[giftOrder.orderNotifyDate timeIntervalSince1970]];
        }
    }
    
    if (giftOrder.giftCard) {
        [requestString appendFormat:@"&sender_name=%@", giftOrder.giftCard.sender];
        [requestString appendFormat:@"&card_id=%@", giftOrder.giftCard.identifier];
        [requestString appendFormat:@"&card_recipient_name=%@", giftOrder.giftRecipient.recipientDisplayName];
        [requestString appendFormat:@"&card_body=%@", giftOrder.giftCard.content];
        [requestString appendFormat:@"&card_salutation=%@", giftOrder.giftCard.title];
        [requestString appendFormat:@"&card_closing=%@", giftOrder.giftCard.enclosure];
    } else {
        [requestString appendFormat:@"&sender_name=%@", currentAccount.userName];
    }
    
    if (giftOrder.gift.giftSetIdentifier) {
        [requestString appendFormat:@"&product_group_id=%@", giftOrder.gift.giftSetIdentifier];
    }
    
    if (giftOrder.giftRecipient.recipientNetworkId > 0) {
        [requestString appendFormat:@"&recipient_profile_id=%@", giftOrder.giftRecipient.recipientProfileId];
        [requestString appendFormat:@"&recipient_profile_network=%d", giftOrder.giftRecipient.recipientNetworkId];
    } else if (giftOrder.giftRecipient.recipientNetworkId == NETWORK_PHONE_CONTACT) {
        [requestString appendFormat:@"&recipient_phone_contact_id=%@", giftOrder.giftRecipient.recipientProfileId];
    }
    
    HGDebug(@"%@", requestString);
    
    NSURL* requestURL = [NSURL URLWithString:[requestString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [super requestByGet:requestURL];
    
    [requestString release];
}

- (void)requestCancelOrder:(HGGiftOrder*)theGiftOrder{
    if (running){
        return;
    }
    [self cancel];
    requestType = kRequestTypeGiftOrderCancel;
    running = YES;
    giftOrder = [theGiftOrder retain];
    
    NSMutableString* requestString = [[NSMutableString alloc] init];
    [requestString appendFormat:kGiftOrderCancelRequestFormat, [HappyGiftAppDelegate backendServiceHost], giftOrder.identifier];
    
    HGDebug(@"%@", requestString);
    
    NSURL* requestURL = [NSURL URLWithString:[requestString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [super requestByGet:requestURL];
    
    [requestString release];
}

#pragma mark parsers

- (void)handleMyGiftsResponseData:(NSData*)myGiftsData {
    NSAutoreleasePool * autoReleasePool = [[NSAutoreleasePool alloc] init];
    NSArray* orders = nil;
    
    if (kHttpStatusCodeNotModified == [self.response statusCode]) {
        HGDebug(@"mygifts - got 304 not modifed");
        orders = [self loadSentGiftsCache];
    } else {
        NSString* jsonString = [NSString stringWithData:self.data];
        HGDebug(@"%@", jsonString);
        
        if (jsonString != nil && [jsonString isEqualToString:@""] == NO) {
            NSDictionary *jsonDictionary = [jsonString JSONValue];
            if (jsonDictionary != nil){
                orders = [self parseOrders:jsonDictionary];
            }
        }
        
        if (orders) {
            if ([orders count] > 0) {
                NSString* lastModifiedField = [self getLastModifiedHeader];
                HGDebug(@"new my gifts data - lastModified: %@, storing data", lastModifiedField);
                [self saveSentGifts:orders andLastModifiedTime:lastModifiedField];
            }
        } else {
            HGDebug(@"handle response error, use cached data");
            orders = [self loadSentGiftsCache];
        }
    }
    
    if (orders != nil){
        [self performSelectorOnMainThread:@selector(handleNotifyMyGiftsData:) withObject:[NSDictionary dictionaryWithObjectsAndKeys:orders, @"orders", nil] waitUntilDone:YES];
    }else{
        [self performSelectorOnMainThread:@selector(handleNotifyMyGiftsData:) withObject:nil waitUntilDone:YES];
    }
    
    [autoReleasePool release];
}

-(NSArray*) parseOrders:(NSDictionary*)jsonDictionary{
    NSMutableArray* orders = [[[NSMutableArray alloc] init] autorelease];
    @try {
        NSArray* ordersJsonArray = [jsonDictionary objectForKey:@"orders"];
        for (NSDictionary* orderJsonDictionary in ordersJsonArray){
            HGGiftOrder* order = [self parseOrder:orderJsonDictionary];
            if (order) {
                [orders addObject:order];
            }
        }
        
    }@catch (NSException* e) {
        HGDebug(@"Exception happened inside parseOrders");
    }@finally {
        
    }
    return orders;
}

-(HGGiftOrder*)parseOrder:(NSDictionary*)orderJsonDictionary{
    @try {
        HGGiftOrder* order = [[HGGiftOrder alloc] init];
        
        order.identifier = [orderJsonDictionary objectForKey:@"order_id"];
        order.trackCode = [orderJsonDictionary objectForKey:@"short_track_code"];
        order.payTrackCode = [orderJsonDictionary objectForKey:@"pay_track_code"];
        order.orderCreatedDate = [orderJsonDictionary objectForKey:@"date_added"];
        
        NSString* orderType = [orderJsonDictionary objectForKey:@"order_type"];
        if ([@"quick" isEqualToString:orderType]) {
            order.orderType = kOrderTypeQuickOrder;
        } else {
            order.orderType = kOrderTypeNormalOrder;
        }
        
        //order.thanksNote = [orderJsonDictionary objectForKey:@"thanks_note"];
        NSObject* thanksNoteObject = [orderJsonDictionary objectForKey:@"thanks_note"];
        if ([thanksNoteObject isKindOfClass:[NSString class]]){
            order.thanksNote = (NSString*)thanksNoteObject;
        }
        
        order.shippingCost = [[orderJsonDictionary objectForKey:@"shipping_cost"] floatValue];
        
        NSString* status = [orderJsonDictionary objectForKey:@"status"];
        
        if ([status isEqualToString:@"notified"]) {
            order.status = GIFT_ORDER_STATUS_NOTIFIED;
        } else if ([status isEqualToString:@"card read"]) {
            order.status = GIFT_ORDER_STATUS_READ;
        } else if ([status isEqualToString:@"accepted"]) {
            order.status = GIFT_ORDER_STATUS_ACCEPTED;
        } else if ([status isEqualToString:@"shipped"]) {
            order.status = GIFT_ORDER_STATUS_SHIPPED;
        } else if ([status isEqualToString:@"delivered"]) {
            order.status = GIFT_ORDER_STATUS_DELIVERED;
        } else if ([status isEqualToString:@"canceled"]) {
            order.status = GIFT_ORDER_STATUS_CANCELED;
        } else {
            order.status = GIFT_ORDER_STATUS_NEW;
        }
        
        order.isPaid = [[orderJsonDictionary objectForKey:@"paid"] intValue] ? YES : NO;
        
        order.paymentUrl = [orderJsonDictionary objectForKey:@"payment_url"];
        
        HGGift* gift = [[HGGift alloc] initWithProductJsonDictionary:[orderJsonDictionary objectForKey:@"product"]];
        order.gift = gift;
        [gift release];
        
        if (gift.type == GIFT_TYPE_COUPON){
            order.isPaid = YES;
        }
        
        NSNumber* creditMoneyObject = [orderJsonDictionary objectForKey:@"credit_money"];
        NSNumber* creditConsumeObject = [orderJsonDictionary objectForKey:@"credit_value"];
        order.creditMoney = creditMoneyObject == nil?0:[creditMoneyObject floatValue];
        order.creditConsume = creditConsumeObject == nil?0:[creditConsumeObject intValue];
        if (creditConsumeObject != nil && [creditConsumeObject intValue] > 0){
            order.useCredit = YES;
        }else{
            order.useCredit = NO;
        }
        
        HGRecipient* recipient = [[HGRecipient alloc]init];
        recipient.recipientName = [orderJsonDictionary objectForKey:@"recipient_name"];
        recipient.recipientImageUrl = [orderJsonDictionary objectForKey:@"recipient_image"];
        
        NSString* profileId = [orderJsonDictionary objectForKey:@"recipient_profile_id"];
        if (profileId && ![profileId isEqual:[NSNull null]]) {
            recipient.recipientProfileId = profileId;
        }
        
        NSString * networkId  = [orderJsonDictionary objectForKey:@"recipient_profile_network"];
        if (networkId && ![networkId isEqual:[NSNull null]]) {
            recipient.recipientNetworkId = [networkId intValue];
        }
        
        if (profileId == nil || [profileId isEqualToString:@""]) {
            NSString * phoneContactId  = [orderJsonDictionary objectForKey:@"recipient_phone_contact_id"];
            if (phoneContactId && ![phoneContactId isEqualToString:@""]) {
                recipient.recipientNetworkId = NETWORK_PHONE_CONTACT;
                recipient.recipientProfileId = phoneContactId;
            }
        }
        
        order.giftRecipient = recipient;
        [recipient release];
        
        HGGiftCard* giftCard = [[HGGiftCard alloc] init];
        
        giftCard.identifier = [orderJsonDictionary objectForKey:@"card_id"];
        giftCard.cover = [orderJsonDictionary objectForKey:@"card_image"];
        giftCard.name = [orderJsonDictionary objectForKey:@"card_name"];
        giftCard.content = [orderJsonDictionary objectForKey:@"card_body"];
        giftCard.enclosure = [orderJsonDictionary objectForKey:@"card_closing"];
        giftCard.title = [orderJsonDictionary objectForKey:@"card_salutation"];
        
        order.giftCard = giftCard;
        [giftCard release];
        
        return [order autorelease];
    }  @catch (NSException* e) {
        HGDebug(@"Exception happened inside parseOrder");
        return nil;
    } @finally {
    }
}

- (void)handleNotifyMyGiftsData:(NSDictionary*)result {
    running = NO;
    
    NSArray* orders  = [result objectForKey:@"orders"];
    if (orders != nil) {
        if ([(id)self.delegate respondsToSelector:@selector(giftOrderLoader:didRequestMyGiftsSucceed:)]) {
            [self.delegate giftOrderLoader:self didRequestMyGiftsSucceed:orders];
        }
    } else {
        if ([(id)self.delegate respondsToSelector:@selector(giftOrderLoader:didRequestMyGiftsFail:)]) {
            [self.delegate giftOrderLoader:self didRequestMyGiftsFail:nil];
        }
    }
    [self end];
}

- (void) handleMyGiftOrderResponseData {
    NSString* jsonString = [NSString stringWithData:self.data];
    HGDebug(@"%@", jsonString);
    
    NSDictionary* responseJson = [jsonString JSONValue];
    NSDictionary* orderJson = [responseJson objectForKey:@"order"];
    HGGiftOrder* order = [self parseOrder:orderJson];
    
    if (order) {
        if ([(id)self.delegate respondsToSelector:@selector(giftOrderLoader:didRequestMyGiftOrderSucceed:)]) {
            [self.delegate giftOrderLoader:self didRequestMyGiftOrderSucceed:order];
        }
    } else {
        if ([(id)self.delegate respondsToSelector:@selector(giftOrderLoader:didRequestMyGiftOrderFail:)]) {
            [self.delegate giftOrderLoader:self didRequestMyGiftOrderFail:nil];
        }
    }
}

- (void) handleShippingCostResponseData {
    NSString* jsonString = [NSString stringWithData:self.data];
    HGDebug(@"%@", jsonString);
    
    float shippingCost = -1.0;
    
    @try {
        NSDictionary* responseJson = [jsonString JSONValue];
        NSNumber *shippingCostNumber = [responseJson objectForKey:@"shipping_cost"];
        if (shippingCostNumber) {
            shippingCost = [shippingCostNumber floatValue];
        }
    } @catch (NSException* e) {
        HGWarning(@"error: %@ for %@", e, jsonString);
    } @finally {
    }
    
    if (shippingCost >= 0.0) {
        if ([(id)self.delegate respondsToSelector:@selector(giftOrderLoader:didRequestShippingCostSucceed:)]) {
            [self.delegate giftOrderLoader:self didRequestShippingCostSucceed:shippingCost];
        }
    } else {
        if ([(id)self.delegate respondsToSelector:@selector(giftOrderLoader:didRequestShippingCostFail:)]) {
            [self.delegate giftOrderLoader:self didRequestShippingCostFail:nil];
        }
    }
}

- (void)handleParsePlaceGiftOrderData:(NSData*)giftOrderData{
    NSAutoreleasePool * autoReleasePool = [[NSAutoreleasePool alloc] init];
    NSString* jsonString = [NSString stringWithData:self.data];
    HGDebug(@"%@", jsonString);
    NSString* orderId = nil; 
    NSString* trackCode = nil;
    NSString* paymentUrl = nil;
    NSString* acceptUrl = nil;
    NSString* payTrackCode = nil;
    if (jsonString != nil && [jsonString isEqualToString:@""] == NO){
        NSDictionary *jsonDictionary = [jsonString JSONValue];
        if (jsonDictionary != nil && [jsonDictionary objectForKey:@"order_id"] != nil){
            NSObject* orderIdObject = [jsonDictionary objectForKey:@"order_id"];
            if ([orderIdObject isKindOfClass:[NSNumber class]]){
                orderId = [(NSNumber*)orderIdObject stringValue];
            }else{
                orderId = (NSString*)orderIdObject;
            }
            trackCode = [jsonDictionary objectForKey:@"short_track_code"];
            paymentUrl = [jsonDictionary objectForKey:@"payment_url"];
            acceptUrl = [jsonDictionary objectForKey:@"accept_url"];
            payTrackCode = [jsonDictionary objectForKey:@"pay_track_code"];
        }
    }
    if (orderId != nil){
        [self performSelectorOnMainThread:@selector(handleNotifyPlaceGiftOrderData:) withObject:[NSDictionary dictionaryWithObjectsAndKeys:orderId, @"orderId", trackCode, @"trackCode", paymentUrl, @"paymentUrl", acceptUrl, @"acceptUrl", payTrackCode, @"payTrackCode", nil] waitUntilDone:YES];
    }else{
        [self performSelectorOnMainThread:@selector(handleNotifyPlaceGiftOrderData:) withObject:nil waitUntilDone:YES];
    }
    [autoReleasePool release];
}

- (void)handleNotifyPlaceGiftOrderData:(NSDictionary*)giftOrderData{
    running = NO;
    if (giftOrderData != nil){
        NSString* orderId = [giftOrderData objectForKey:@"orderId"];
        NSString* trackCode = [giftOrderData objectForKey:@"trackCode"];
        NSString* paymentUrl = [giftOrderData objectForKey:@"paymentUrl"];
        NSString* acceptUrl = [giftOrderData objectForKey:@"acceptUrl"];
        NSString* payTrackCode = [giftOrderData objectForKey:@"payTrackCode"];
        if (orderId != nil){
            giftOrder.identifier = orderId;
            giftOrder.trackCode = trackCode;
            giftOrder.paymentUrl = paymentUrl;
            giftOrder.acceptUrl = acceptUrl;
            giftOrder.payTrackCode = payTrackCode;
            if ([(id)self.delegate respondsToSelector:@selector(giftOrderLoader:didRequestPlaceOrderSucceed:)]) {
                [self.delegate giftOrderLoader:self didRequestPlaceOrderSucceed:giftOrder];
            }
        }else{
            if ([(id)self.delegate respondsToSelector:@selector(giftOrderLoader:didRequestPlaceOrderFail:)]) {
                [self.delegate giftOrderLoader:self didRequestPlaceOrderFail:nil];
            }
        }
    }else{
        if ([(id)self.delegate respondsToSelector:@selector(giftOrderLoader:didRequestPlaceOrderFail:)]) {
            [self.delegate giftOrderLoader:self didRequestPlaceOrderFail:nil];
        }
    }
    [giftOrder release];
    giftOrder = nil;
    [self end];
}

- (void)handleParseCancelGiftOrderData:(NSData*)giftOrderData{
    NSAutoreleasePool * autoReleasePool = [[NSAutoreleasePool alloc] init];
    NSString* jsonString = [NSString stringWithData:self.data];
    HGDebug(@"%@", jsonString);
    NSString* canceled = nil; 
    if (jsonString != nil && [jsonString isEqualToString:@""] == NO){
        NSDictionary *jsonDictionary = [jsonString JSONValue];
        if (jsonDictionary != nil){
            canceled = [jsonDictionary objectForKey:@"canceled"];
        }
    }
    if (canceled != nil){
        [self performSelectorOnMainThread:@selector(handleNotifyCancelGiftOrderData:) withObject:[NSDictionary dictionaryWithObjectsAndKeys:canceled, @"canceled", nil] waitUntilDone:YES];
    }else{
        [self performSelectorOnMainThread:@selector(handleNotifyCancelGiftOrderData:) withObject:nil waitUntilDone:YES];
    }
    [autoReleasePool release];
}

- (void)handleNotifyCancelGiftOrderData:(NSDictionary*)giftOrderData{
    running = NO;
    NSString* canceled = [giftOrderData objectForKey:@"canceled"];
    if (canceled != nil && [canceled isEqualToString:@"1"]){
        if ([(id)self.delegate respondsToSelector:@selector(giftOrderLoader:didRequestCancelOrderSucceed:)]) {
            [self.delegate giftOrderLoader:self didRequestCancelOrderSucceed:giftOrder];
        }
    }else{
        if ([(id)self.delegate respondsToSelector:@selector(giftOrderLoader:didRequestCancelOrderFail:)]) {
            [self.delegate giftOrderLoader:self didRequestCancelOrderFail:nil];
        }
    }
    [giftOrder release];
    giftOrder = nil;
    [self end];
}

#pragma mark overrides
- (void)connectionDidFinishLoading:(NSURLConnection *)conn {
    [super connectionDidFinishLoading:conn];
    if (requestType == kRequestTypeGiftOrderPlace) {
        [self performSelectorInBackground:@selector(handleParsePlaceGiftOrderData:) withObject:self.data];
    }else if (requestType == kRequestTypeGiftOrderCancel) {
        [self performSelectorInBackground:@selector(handleParseCancelGiftOrderData:) withObject:self.data];
    }else if (requestType == kRequestTypeMyGifts) {
        [self performSelectorInBackground:@selector(handleMyGiftsResponseData:) withObject:self.data];
    } else if (requestType == kRequestTypeMyGiftOrder) {
        [self handleMyGiftOrderResponseData];
    } else if (requestType == kRequestTypeShippingCost) {
        [self handleShippingCostResponseData];
    }
}

- (void)connection:(NSURLConnection *)conn didFailWithError:(NSError *)error {
    [super connection:conn didFailWithError:error];
	running = NO;
    if (requestType == kRequestTypeGiftOrderPlace) {
        if ([(id)self.delegate respondsToSelector:@selector(giftOrderLoader:didRequestPlaceOrderFail:)]) {
            [self.delegate giftOrderLoader:self didRequestPlaceOrderFail:[error description]];
        }
        [giftOrder release];
        giftOrder = nil;
    }else if (requestType == kRequestTypeGiftOrderCancel) {
        if ([(id)self.delegate respondsToSelector:@selector(giftOrderLoader:didRequestCancelOrderFail:)]) {
            [self.delegate giftOrderLoader:self didRequestCancelOrderFail:[error description]];
        }
        [giftOrder release];
        giftOrder = nil;
    }else if (requestType == kRequestTypeMyGifts) {
        if ([(id)self.delegate respondsToSelector:@selector(giftOrderLoader:didRequestMyGiftsFail:)]) {
            [self.delegate giftOrderLoader:self didRequestMyGiftsFail:nil];
        }
    } else if (requestType == kRequestTypeMyGiftOrder) {
        if ([(id)self.delegate respondsToSelector:@selector(giftOrderLoader:didRequestMyGiftOrderFail:)]) {
            [self.delegate giftOrderLoader:self didRequestMyGiftOrderFail:nil];
        }
    } else if (requestType == kRequestTypeShippingCost) {
        if ([(id)self.delegate respondsToSelector:@selector(giftOrderLoader:didRequestShippingCostFail:)]) {
            [self.delegate giftOrderLoader:self didRequestShippingCostFail:nil];
        }
    }
}

#pragma persistent response data

-(NSArray*)loadSentGiftsCache {
    return [HGLoaderCache loadDataFromLoaderCache:@"sentGifts"];
}

-(NSString*)getLastModifiedTimeOfSentGifts {
    return [HGLoaderCache lastModifiedTimeForKey:kCacheKeyLastModifiedTimeOfSentGifts];
}

-(NSArray*) sentGiftsLoaderCache {
    NSString* lastModifiedTimeOfSentGifts = [self getLastModifiedTimeOfSentGifts];
    if (lastModifiedTimeOfSentGifts && ![@"" isEqualToString:lastModifiedTimeOfSentGifts]) {
        return [self loadSentGiftsCache];
    } else {
        return nil;
    }
}

-(void)saveSentGifts:(NSArray*)sentGifts andLastModifiedTime:(NSString*)lastModifiedTimeOfSentGifts {
    [HGLoaderCache saveDataToLoaderCache:sentGifts forKey:@"sentGifts"];
    [HGLoaderCache saveLastModifiedTime:lastModifiedTimeOfSentGifts forKey:kCacheKeyLastModifiedTimeOfSentGifts];
}


@end
