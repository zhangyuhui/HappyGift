//
//  HGAlipayManager.h
//  HappyGift
//
//  Created by Yujian Weng on 12-5-15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HGGift.h"

@interface HGAlipayService : NSObject {
    NSString	*_sellerID;
    NSString	*_partnerID;
    NSString    *_rsaPrivateKey;
    NSString    *_rsaPublicKey;
    NSString    *_notifyURL;
}

@property (nonatomic, readwrite, retain) NSString *sellerID;
@property (nonatomic, readwrite, retain) NSString *partnerID;
@property (nonatomic, readwrite, retain) NSString *rsaPrivateKey;
@property (nonatomic, readwrite, retain) NSString *rsaPublicKey;
@property (nonatomic, readwrite, retain) NSString *notifyURL;

- (void)payForGift:(HGGift*)gift withTradeNO:(NSString*)tradeNO;

- (void)parsePaymentResult:(NSURL *)url application:(UIApplication *)application;

+ (HGAlipayService*) sharedService;

@end
