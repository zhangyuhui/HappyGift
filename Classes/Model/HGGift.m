//
//  HGGift.m
//  HappyGift
//
//  Created by Yuhui Zhang on 7/22/11.
//  Copyright 2011 Ztelic Inc. All rights reserved.
//

#import "HGGift.h"
#import "HGDefines.h"
#import "NSString+Addition.h"

static NSMutableDictionary* sharedInstancesDictionary;

NSString* const kGiftIdentifier = @"gift_identifier";
NSString* const kGiftSetIdentifierOfTheGift = @"gift_set_identifier";
NSString* const kGiftName = @"gift_name";
NSString* const kGiftDescription = @"gift_description";
NSString* const kGiftManufacturer = @"gift_manufacturer";
NSString* const kGiftPrice = @"gift_price";
NSString* const kGiftBasePrice = @"gift_base_price";
NSString* const kGiftShippingCostMin = @"gift_shpping_cost_min";
NSString* const kGiftShippingCostMax = @"gift_shpping_cost_max";
NSString* const kGiftCover = @"gift_cover";
NSString* const kGiftThumb = @"gift_thumb";
NSString* const kGiftImages = @"gift_images";
NSString* const kGiftIntroduction = @"gift_introduction";
NSString* const kGiftReview = @"gift_review";
NSString* const kGiftRecommend = @"gift_recommend";
NSString* const kGiftSexyName = @"gift_sexy_name";
NSString* const kGiftLikeCount = @"gift_like_count";
NSString* const kGiftMyLike = @"gift_my_like";
NSString* const kGiftProductUrl = @"gift_product_url";
NSString* const kGiftCreditMoney = @"gift_credit_money";
NSString* const kGiftCreditConsume = @"gift_credit_consume";
NSString* const kGiftCreditLimit = @"gift_credit_limit";
NSString* const kGiftType = @"gift_type";

@implementation HGGift
@synthesize identifier;
@synthesize giftSetIdentifier;
@synthesize name;
@synthesize description;
@synthesize manufacturer;
@synthesize price;
@synthesize basePrice;
@synthesize shippingCostMin;
@synthesize shippingCostMax;
@synthesize cover;
@synthesize thumb;
@synthesize likeCount;
@synthesize myLike;
@synthesize images;
@synthesize introduction;
@synthesize review;
@synthesize recommend;
@synthesize sexyName;
@synthesize productUrl;
@synthesize creditMoney;
@synthesize creditConsume;
@synthesize creditLimit;
@synthesize type;

+ (void)initialize{
    sharedInstancesDictionary = [[NSMutableDictionary alloc] init];
}

-(id)init{
    NSAssert(false, @"HGGift can not be constructed by init");
    return nil;
}

-(void)dealloc{
    [identifier release];
    [giftSetIdentifier release];
    [name release];
    [description release];
    [manufacturer release];
    [cover release];
    [thumb release];
    [images release];
    [introduction release];
    [review release];
    [recommend release];
    [sexyName release];
    [productUrl release];
	[super dealloc];
}

-(BOOL)isFreeShippingCost {
    return [self isFixedShippingCost] && fabs(shippingCostMax) < 0.005;
}

-(BOOL)isFixedShippingCost {
    return fabs(shippingCostMax - shippingCostMin) < 0.005;
}

-(id)initWithProductJsonDictionary:(NSDictionary*)productJsonDictionary {
    self = [super init];
    if (self) {
        NSString* theIdentifier = [productJsonDictionary objectForKey:@"product_id"];
        NSString* theName = [productJsonDictionary objectForKey:@"p_name"];
        theName = [theName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSString* theDescription = [productJsonDictionary objectForKey:@"prod_desc"];
        NSString* theManufacturer = [productJsonDictionary objectForKey:@"m_name"];
        float thePrice = [[productJsonDictionary objectForKey:@"price"] floatValue];
        float theBasePrice = [[productJsonDictionary objectForKey:@"base_price"] floatValue];
        float theShippingCostMin = [[productJsonDictionary objectForKey:@"min_shipping_cost"] floatValue];
        float theShippingCostMax = [[productJsonDictionary objectForKey:@"max_shipping_cost"] floatValue];
        NSString* theCover = [productJsonDictionary objectForKey:@"image"];
        NSString* theCoverMid = [productJsonDictionary objectForKey:@"mid_image"];
        NSString* theCoverSmall = [productJsonDictionary objectForKey:@"small_image"];
        NSArray* theImages = [productJsonDictionary objectForKey:@"images"];
        NSString* theReview = [productJsonDictionary objectForKey:@"prod_review"];
        NSString* theRecommend = [productJsonDictionary objectForKey:@"prod_recommend_reason"];
        NSString* theIntroduction = [NSString NSNullToNil:[productJsonDictionary objectForKey:@"manufacturer_desc"]];
        NSString* theSexyName = [productJsonDictionary objectForKey:@"sexy_name"];
        NSNumber* theLikeCount = [productJsonDictionary objectForKey:@"like"];
        NSNumber* theMyLike = [productJsonDictionary objectForKey:@"mylike"];
        NSString* theProductUrl = [productJsonDictionary objectForKey:@"product_url"];
        NSNumber* theCreditMoneyObject = [productJsonDictionary objectForKey:@"credit_money"];
        NSNumber* theCreditConsumeObject = [productJsonDictionary objectForKey:@"credit_consume"];
        NSNumber* theCreditLimitObject = [productJsonDictionary objectForKey:@"credit_limit"];
        NSString* theProductType = [productJsonDictionary objectForKey:@"product_type"];
        
        float theCreditMoney = (theCreditMoneyObject == nil)?0:[theCreditMoneyObject floatValue];
        int theCreditConsume = (theCreditConsumeObject == nil)?0:[theCreditConsumeObject intValue];
        BOOL theCreditLimit = [theCreditLimitObject boolValue];

        int theType = (theProductType != nil && [theProductType isEqualToString:@"coupons"])?GIFT_TYPE_COUPON:GIFT_TYPE_SHIPPING;
        
        HGGift* sharedInstance = [sharedInstancesDictionary objectForKey:theIdentifier];
        if (sharedInstance != nil){
            if (theName && ![@"" isEqualToString:theName]) {
                sharedInstance.name = theName;
            }
            if (theDescription && ![@"" isEqualToString:theDescription]) {
                sharedInstance.description = theDescription;
            }
            if (theManufacturer && ![@"" isEqualToString:theManufacturer]) {
                sharedInstance.manufacturer = theManufacturer;
            }
            
            sharedInstance.price = thePrice;
            sharedInstance.basePrice = theBasePrice;
            sharedInstance.shippingCostMin = theShippingCostMin;
            sharedInstance.shippingCostMax = theShippingCostMax;
            
            sharedInstance.creditMoney = theCreditMoney;
            sharedInstance.creditConsume = theCreditConsume;
            sharedInstance.creditLimit = theCreditLimit;
            sharedInstance.type = theType;
            
            if (theCover && ![@"" isEqualToString:theCover]) {
                sharedInstance.cover = theCover;
            }
            
            sharedInstance.thumb = isRetina ? theCoverMid : theCoverSmall;
            
            if (theImages && [theImages count] > 0) {
                sharedInstance.images = theImages;
            }
            
            if (theReview && ![@"" isEqualToString:theReview]) {
                sharedInstance.review = theReview;
            }
            if (theRecommend && ![@"" isEqualToString:theRecommend]) {
                sharedInstance.recommend = theRecommend;
            }
            if (theIntroduction && ![@"" isEqualToString:theIntroduction]) {
                sharedInstance.introduction = theIntroduction;
            }
            if (theSexyName && ![@"" isEqualToString:theSexyName]) {
                sharedInstance.sexyName = theSexyName;
            }
            
            sharedInstance.likeCount = [theLikeCount intValue];
            sharedInstance.myLike = [theMyLike boolValue];
            
            if (theProductUrl && ![@"" isEqualToString:theProductUrl]) {
                sharedInstance.productUrl = theProductUrl;
            }
            
            [self autorelease];
            [sharedInstance retain];
            return sharedInstance;
        }else{
            self.identifier = theIdentifier;
            self.name = theName;
            self.description = theDescription;
            self.manufacturer = theManufacturer;
            self.price = thePrice;
            self.basePrice = theBasePrice;
            self.shippingCostMin = theShippingCostMin;
            self.shippingCostMax = theShippingCostMax;
            self.cover = theCover;
            self.thumb = isRetina ? theCoverMid : theCoverSmall;
            self.images = theImages;
            self.review = theReview;
            self.recommend = theRecommend;
            self.introduction = theIntroduction;
            self.sexyName = theSexyName;
            self.likeCount = [theLikeCount intValue];
            self.myLike = [theMyLike boolValue];
            self.productUrl = theProductUrl;
            self.creditMoney = theCreditMoney;
            self.creditConsume = theCreditConsume;
            self.creditLimit = theCreditLimit;
            self.type = theType;
            [sharedInstancesDictionary setObject:self forKey:identifier];
        }
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        identifier = [[coder decodeObjectForKey:kGiftIdentifier] retain]; 
        
        HGGift* sharedInstance = [sharedInstancesDictionary objectForKey:identifier];
        if (sharedInstance != nil){
            [self autorelease];
            [sharedInstance retain];
            return sharedInstance;
        }else{
            giftSetIdentifier = [[coder decodeObjectForKey:kGiftSetIdentifierOfTheGift] retain];
            name = [[coder decodeObjectForKey:kGiftName] retain]; 
            description = [[coder decodeObjectForKey:kGiftDescription] retain];
            manufacturer = [[coder decodeObjectForKey:kGiftManufacturer] retain];
            price = [coder decodeFloatForKey:kGiftPrice];
            basePrice = [coder decodeFloatForKey:kGiftBasePrice];
            shippingCostMin = [coder decodeFloatForKey:kGiftShippingCostMin];
            shippingCostMax = [coder decodeFloatForKey:kGiftShippingCostMax];
            cover = [[coder decodeObjectForKey:kGiftCover] retain];
            thumb = [[coder decodeObjectForKey:kGiftThumb] retain];
            images = [[coder decodeObjectForKey:kGiftImages] retain];   
            introduction = [[coder decodeObjectForKey:kGiftIntroduction] retain];
            review = [[coder decodeObjectForKey:kGiftReview] retain];
            recommend = [[coder decodeObjectForKey:kGiftRecommend] retain];
            sexyName = [[coder decodeObjectForKey:kGiftSexyName] retain];
            likeCount = [coder decodeIntForKey:kGiftLikeCount];
            myLike = [coder decodeBoolForKey:kGiftMyLike];
            productUrl = [[coder decodeObjectForKey:kGiftProductUrl] retain];
            creditMoney = [coder decodeFloatForKey:kGiftCreditMoney];
            creditConsume = [coder decodeIntForKey:kGiftCreditConsume];
            creditLimit = [coder decodeBoolForKey:kGiftCreditLimit];
            type = [coder decodeIntForKey:kGiftType];
            [sharedInstancesDictionary setObject:self forKey:identifier];
        }
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder*)encoder {
    [encoder encodeObject:identifier forKey:kGiftIdentifier]; 
    [encoder encodeObject:giftSetIdentifier forKey:kGiftSetIdentifierOfTheGift];
    [encoder encodeObject:name forKey:kGiftName];
    [encoder encodeObject:description forKey:kGiftDescription]; 
    [encoder encodeObject:manufacturer forKey:kGiftManufacturer]; 
    [encoder encodeFloat:price forKey:kGiftPrice];
    [encoder encodeFloat:basePrice forKey:kGiftBasePrice];
    [encoder encodeFloat:shippingCostMin forKey:kGiftShippingCostMin];
    [encoder encodeFloat:shippingCostMax forKey:kGiftShippingCostMax];
    [encoder encodeObject:cover forKey:kGiftCover]; 
    [encoder encodeObject:thumb forKey:kGiftThumb];
    [encoder encodeObject:images forKey:kGiftImages];
    [encoder encodeObject:introduction forKey:kGiftIntroduction];
    [encoder encodeObject:review forKey:kGiftReview]; 
    [encoder encodeObject:recommend forKey:kGiftRecommend];
    [encoder encodeObject:sexyName forKey:kGiftSexyName];
    [encoder encodeInt:likeCount forKey:kGiftLikeCount];
    [encoder encodeBool:myLike forKey:kGiftMyLike];
    [encoder encodeObject:productUrl forKey:kGiftProductUrl];
    [encoder encodeFloat:creditMoney forKey:kGiftCreditMoney];
    [encoder encodeInt:creditConsume forKey:kGiftCreditConsume];
    [encoder encodeBool:creditLimit forKey:kGiftCreditLimit];
    [encoder encodeInt:type forKey:kGiftType];
}

- (oneway void)release {
    if ([self retainCount] == 2){
        [sharedInstancesDictionary removeObjectForKey:self.identifier];
    }
    [super release];    
}


@end
