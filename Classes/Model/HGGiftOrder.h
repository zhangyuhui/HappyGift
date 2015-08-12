//
//  HGGiftOrder.h
//  HappyGift
//
//  Created by Yuhui Zhang on 7/22/11.
//  Copyright 2011 Ztelic Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HGGift.h"
#import "HGGiftCard.h"
#import "HGGiftDelivery.h"
#import "HGRecipient.h"
#import "HGDefines.h"

typedef enum _HGGiftOrderStatus {
    GIFT_ORDER_STATUS_NEW,
    GIFT_ORDER_STATUS_CANCELED,
    GIFT_ORDER_STATUS_NOTIFIED,
    GIFT_ORDER_STATUS_READ,
    GIFT_ORDER_STATUS_ACCEPTED,
    GIFT_ORDER_STATUS_PAID,
    GIFT_ORDER_STATUS_SHIPPED,
    GIFT_ORDER_STATUS_DELIVERED,
} HGGiftOrderStatus;

extern const int kOrderTypeQuickOrder;
extern const int kOrderTypeNormalOrder;

@interface HGGiftOrder : NSObject <NSCoding> {
    NSString* identifier;
    NSString* trackCode;
    NSString* payTrackCode;
    HGGift* gift;
    HGGiftCard* giftCard;
    HGGiftDelivery* giftDelivery;
    HGRecipient* giftRecipient;
    
    NSString* orderCreatedDate;
    HGGiftOrderStatus status;
    NSDate* orderNotifyDate;
    BOOL orderNotifiedFromClient;
    
    NSString* thanksNote;
    
    BOOL isPaid;
    NSString* paymentUrl;
    NSString* acceptUrl;
    
    BOOL useCredit;
    float  creditMoney;
    int  creditConsume;
    
    float shippingCost;
    int orderType;
}
- (BOOL) isPaidOrCanceled;
- (BOOL) canPaid;
- (BOOL) isImmediatelyPay;
- (BOOL) canUseCredit;

@property (nonatomic, retain) NSString* identifier;
@property (nonatomic, retain) NSString* trackCode;
@property (nonatomic, retain) NSString* payTrackCode;
@property (nonatomic, retain) HGRecipient* giftRecipient;
@property (nonatomic, retain) HGGift* gift;
@property (nonatomic, retain) HGGiftCard* giftCard;
@property (nonatomic, retain) HGGiftDelivery* giftDelivery;

@property (nonatomic, retain) NSString* orderCreatedDate;
@property (nonatomic, retain) NSDate* orderNotifyDate;
@property (nonatomic, assign) HGGiftOrderStatus status;
@property (nonatomic, retain) NSString* thanksNote;
@property (nonatomic, assign) BOOL isPaid;
@property (nonatomic, assign) BOOL orderNotifiedFromClient;
@property (nonatomic, retain) NSString* paymentUrl;
@property (nonatomic, retain) NSString* acceptUrl;
@property (nonatomic, assign) float shippingCost;
@property (nonatomic, assign) int orderType;
@property (nonatomic, assign) BOOL useCredit;
@property (nonatomic, assign) float  creditMoney;
@property (nonatomic, assign) int  creditConsume;
@end
