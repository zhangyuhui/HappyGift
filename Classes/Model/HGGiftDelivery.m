//
//  HGGiftDelivery.m
//  HappyGift
//
//  Created by Yuhui Zhang on 7/22/11.
//  Copyright 2011 Ztelic Inc. All rights reserved.
//

#import "HGGiftDelivery.h"

NSString* const kGiftDeliveryCountry = @"gift_delivery_country";
NSString* const kGiftDeliveryProvince = @"gift_delivery_province";
NSString* const kGiftDeliveryCity = @"gift_delivery_city";
NSString* const kGiftDeliveryStreet = @"gift_delivery_street";
NSString* const kGiftDeliveryPostcode = @"gift_delivery_postcode";
NSString* const kGiftDeliveryPhone = @"gift_delivery_phone";
NSString* const kGiftDeliveryEmail = @"gift_delivery_email";

@implementation HGGiftDelivery
@synthesize country;
@synthesize province;
@synthesize city;
@synthesize street;
@synthesize postcode;
@synthesize phone;
@synthesize email;
@synthesize emailNotify;
@synthesize phoneNotify;

-(void)dealloc{
    [country release];
    [province release];
    [city release];
    [street release];
    [postcode release];
    [phone release];
    [email release];
	[super dealloc];
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {           
        country = [[coder decodeObjectForKey:kGiftDeliveryCountry] retain]; 
        province = [[coder decodeObjectForKey:kGiftDeliveryProvince] retain]; 
        city = [[coder decodeObjectForKey:kGiftDeliveryCity] retain];
        street = [[coder decodeObjectForKey:kGiftDeliveryStreet] retain];
        postcode = [[coder decodeObjectForKey:kGiftDeliveryPostcode] retain];
        phone = [[coder decodeObjectForKey:kGiftDeliveryPhone] retain];
        email = [[coder decodeObjectForKey:kGiftDeliveryEmail] retain];
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder*)encoder {
    [encoder encodeObject:country forKey:kGiftDeliveryCountry]; 
    [encoder encodeObject:province forKey:kGiftDeliveryProvince];
    [encoder encodeObject:city forKey:kGiftDeliveryCity]; 
    [encoder encodeObject:street forKey:kGiftDeliveryStreet]; 
    [encoder encodeObject:postcode forKey:kGiftDeliveryPostcode]; 
    [encoder encodeObject:phone forKey:kGiftDeliveryPhone]; 
    [encoder encodeObject:email forKey:kGiftDeliveryEmail]; 
    
}
@end
