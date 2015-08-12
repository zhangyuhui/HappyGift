//
//  HGGiftOrder.m
//  HappyGift
//
//  Created by Yuhui Zhang on 7/22/11.
//  Copyright 2011 Ztelic Inc. All rights reserved.
//

#import "HGGiftOrder.h"
#import "HGCreditService.h"
#import "HGAppConfigurationService.h"

NSString* const kGiftOrderIdentifier = @"gift_order_identifier";
NSString* const kGiftOrderTrackCode = @"gift_order_trackcode";
NSString* const kGiftOrderPayTrackCode = @"gift_order_paytrackcode";
NSString* const kGiftOrderGift = @"gift_order_gift";
NSString* const kGiftOrderGiftCard = @"gift_delivery_giftCard";
NSString* const kGiftOrderGiftDelivery = @"gift_delivery_giftdelivery";
NSString* const kGiftOrderGiftRecipient = @"gift_order_gift_recipient";
NSString* const kGiftOrderOrderCreatedDate = @"gift_order_order_created_date";
NSString* const kGiftOrderOrderNotifyDate = @"gift_order_order_notify_date";
NSString* const kGiftOrderStatus = @"gift_order_status";
NSString* const kGiftOrderIsPaid = @"gift_order_is_paid";
NSString* const kGiftOrderThanksNote = @"gift_order_thanks_note";
NSString* const kGiftOrderPaymentUrl = @"gift_order_payment_url";
NSString* const kGiftOrderAcceptUrl = @"gift_order_accept_url";
NSString* const kGiftOrderOrderNotifiedFromClient = @"gift_order_order_notified_from_client";
NSString* const kGiftOrderShippingCost = @"gift_order_shipping_cost";
NSString* const kGiftOrderOrderType = @"gift_order_order_type";
NSString* const kGiftOrderUseCredit = @"gift_order_use_credit";
NSString* const kGiftOrderCreditMoney = @"gift_order_credit_value";
NSString* const kGiftOrderCreditConsume = @"gift_order_credit_consume";

const int kOrderTypeQuickOrder = 1;
const int kOrderTypeNormalOrder = 2;

@implementation HGGiftOrder
@synthesize identifier;
@synthesize trackCode;
@synthesize payTrackCode;
@synthesize gift;
@synthesize giftCard;
@synthesize giftDelivery;
@synthesize giftRecipient;
@synthesize orderCreatedDate;
@synthesize orderNotifyDate;
@synthesize status;
@synthesize isPaid;
@synthesize thanksNote;
@synthesize acceptUrl;
@synthesize paymentUrl;
@synthesize orderNotifiedFromClient;
@synthesize shippingCost;
@synthesize orderType;
@synthesize useCredit;
@synthesize creditMoney;
@synthesize creditConsume;

-(void)dealloc{
    [identifier release];
    [payTrackCode release];
    [trackCode release];
    [gift release];
    [giftCard release];
    [giftDelivery release];
    [giftRecipient release];
    [orderCreatedDate release];
    [orderNotifyDate release];
    [thanksNote release];
    [paymentUrl release];
    [acceptUrl release];
	[super dealloc];
}

- (BOOL) isPaidOrCanceled {
    return isPaid || status == GIFT_ORDER_STATUS_CANCELED;
}

- (BOOL) canPaid {
    return !isPaid && (orderType == kOrderTypeQuickOrder || 
                       (status == GIFT_ORDER_STATUS_ACCEPTED || 
                       status == GIFT_ORDER_STATUS_DELIVERED || 
                       status == GIFT_ORDER_STATUS_SHIPPED)) && paymentUrl && ![paymentUrl isEqualToString:@""];
}

- (BOOL) isImmediatelyPay {
    return orderType != kOrderTypeQuickOrder && [self canPaid] && (status == GIFT_ORDER_STATUS_NEW || status == GIFT_ORDER_STATUS_NOTIFIED || status == GIFT_ORDER_STATUS_READ);
}

- (BOOL) canUseCredit {
    if (gift.creditLimit == YES){
        return (gift.creditConsume > 0 && gift.creditMoney > 0 && [HGCreditService sharedService].creditTotal >= gift.creditConsume);
    }else{
        NSNumber* creditExchangeObject = [[HGAppConfigurationService sharedService].appConfiguration objectForKey:kAppConfigurationKeyCreditExchange];
        float creditExchange = [creditExchangeObject floatValue];
        if ([HGCreditService sharedService].creditTotal*creditExchange >= 1.0){
            return YES;
        }else{
            return NO;
        }
    }
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        identifier = [[coder decodeObjectForKey:kGiftOrderIdentifier] retain];
        trackCode = [[coder decodeObjectForKey:kGiftOrderTrackCode] retain];
        payTrackCode = [[coder decodeObjectForKey:kGiftOrderPayTrackCode] retain];
        gift = [[coder decodeObjectForKey:kGiftOrderGift] retain];
        giftCard = [[coder decodeObjectForKey:kGiftOrderGiftCard] retain];
        giftDelivery = [[coder decodeObjectForKey:kGiftOrderGiftDelivery] retain];
        giftRecipient = [[coder decodeObjectForKey:kGiftOrderGiftRecipient] retain];
        orderCreatedDate = [[coder decodeObjectForKey:kGiftOrderOrderCreatedDate] retain];
        orderNotifyDate = [[coder decodeObjectForKey:kGiftOrderOrderNotifyDate] retain];
        thanksNote = [[coder decodeObjectForKey:kGiftOrderThanksNote] retain];
        orderNotifiedFromClient = [coder decodeBoolForKey:kGiftOrderOrderNotifiedFromClient];
        status = [coder decodeIntForKey:kGiftOrderStatus];
        isPaid = [coder decodeBoolForKey:kGiftOrderIsPaid];
        paymentUrl = [[coder decodeObjectForKey:kGiftOrderPaymentUrl] retain];
        acceptUrl = [[coder decodeObjectForKey:kGiftOrderAcceptUrl] retain];
        shippingCost = [coder decodeFloatForKey:kGiftOrderShippingCost];
        orderType = [coder decodeIntForKey:kGiftOrderOrderType];
        useCredit = [coder decodeBoolForKey:kGiftOrderUseCredit];
        creditConsume = [coder decodeIntForKey:kGiftOrderCreditConsume];
        creditMoney = [coder decodeFloatForKey:kGiftOrderCreditMoney];
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder*)encoder {
    [encoder encodeObject:identifier forKey:kGiftOrderIdentifier]; 
    [encoder encodeObject:trackCode forKey:kGiftOrderTrackCode]; 
    [encoder encodeObject:payTrackCode forKey:kGiftOrderPayTrackCode];
    [encoder encodeObject:gift forKey:kGiftOrderGift]; 
    [encoder encodeObject:giftCard forKey:kGiftOrderGiftCard];
    [encoder encodeObject:giftDelivery forKey:kGiftOrderGiftDelivery];
    [encoder encodeObject:giftRecipient forKey:kGiftOrderGiftRecipient]; 
    [encoder encodeObject:orderCreatedDate forKey:kGiftOrderOrderCreatedDate]; 
    [encoder encodeObject:orderNotifyDate forKey:kGiftOrderOrderNotifyDate]; 
    [encoder encodeInt:status forKey:kGiftOrderStatus]; 
    [encoder encodeBool:isPaid forKey:kGiftOrderIsPaid]; 
    [encoder encodeObject:thanksNote forKey:kGiftOrderThanksNote]; 
    [encoder encodeBool:orderNotifiedFromClient forKey:kGiftOrderOrderNotifiedFromClient]; 
    [encoder encodeObject:paymentUrl forKey:kGiftOrderPaymentUrl];
    [encoder encodeObject:acceptUrl forKey:kGiftOrderAcceptUrl];
    [encoder encodeFloat:shippingCost forKey:kGiftOrderShippingCost];
    [encoder encodeInt:orderType forKey:kGiftOrderOrderType];
    [encoder encodeBool:useCredit forKey:kGiftOrderUseCredit];
    [encoder encodeInt:creditConsume forKey:kGiftOrderCreditConsume];
    [encoder encodeFloat:creditMoney forKey:kGiftOrderCreditMoney];
}
@end
