//
//  HGGift.h
//  HappyGift
//
//  Created by Yuhui Zhang on 7/22/11.
//  Copyright 2011 Ztelic Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum _HGGiftType {
    GIFT_TYPE_SHIPPING,
    GIFT_TYPE_COUPON
} HGGiftType;

@interface HGGift : NSObject <NSCoding>{
    NSString* identifier;
    NSString* giftSetIdentifier;
    NSString* name;
    NSString* description;
    NSString* manufacturer;
    NSString* introduction;
    NSString* review;
    NSString* recommend;
    float     price;
    float     basePrice;
    float     shippingCostMin;
    float     shippingCostMax;
    NSString* cover;
    NSString* thumb;
    NSArray*  images;
    NSString* sexyName;
    int       likeCount;
    BOOL      myLike;
    NSString* productUrl;
    float     creditMoney;
    int       creditConsume;
    BOOL      creditLimit;
    HGGiftType       type;
}

-(BOOL)isFreeShippingCost;
-(BOOL)isFixedShippingCost;
-(id)initWithProductJsonDictionary:(NSDictionary*)productJsonDictionary;

@property (nonatomic, retain) NSString* identifier;
@property (nonatomic, retain) NSString* giftSetIdentifier;
@property (nonatomic, retain) NSString* name;
@property (nonatomic, retain) NSString* description;
@property (nonatomic, retain) NSString* manufacturer;
@property (nonatomic, retain) NSString* introduction; 
@property (nonatomic, retain) NSString* review;
@property (nonatomic, retain) NSString* recommend;
@property (nonatomic, assign) float     price;
@property (nonatomic, assign) float     basePrice;
@property (nonatomic, assign) float     shippingCostMin;
@property (nonatomic, assign) float     shippingCostMax;
@property (nonatomic, retain) NSString* cover;
@property (nonatomic, retain) NSString* thumb;
@property (nonatomic, retain) NSArray*  images;
@property (nonatomic, retain) NSString* sexyName;
@property (nonatomic, assign) int       likeCount;
@property (nonatomic, assign) BOOL      myLike;
@property (nonatomic, retain) NSString* productUrl;
@property (nonatomic, assign) float     creditMoney;
@property (nonatomic, assign) int       creditConsume;
@property (nonatomic, assign) BOOL      creditLimit;
@property (nonatomic, assign) HGGiftType       type;
@end
