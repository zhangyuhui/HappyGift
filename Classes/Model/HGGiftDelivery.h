//
//  HGGiftDelivery.h
//  HappyGift
//
//  Created by Yuhui Zhang on 7/22/11.
//  Copyright 2011 Ztelic Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HGGiftDelivery : NSObject <NSCoding>{
    NSString* country;
    NSString* province;
    NSString* city;
    NSString* street;
    NSString* postcode;
    NSString* phone;
    NSString* email;
    BOOL      emailNotify;
    BOOL      phoneNotify;
}
@property (nonatomic, retain) NSString* country;
@property (nonatomic, retain) NSString* province;
@property (nonatomic, retain) NSString* city;
@property (nonatomic, retain) NSString* postcode;
@property (nonatomic, retain) NSString* street;
@property (nonatomic, retain) NSString* phone;
@property (nonatomic, retain) NSString* email;
@property (nonatomic, assign) BOOL      emailNotify;
@property (nonatomic, assign) BOOL      phoneNotify;

@end
