//
//  HGCreditHistory.h
//  HappyGift
//
//  Created by Yuhui Zhang on 7/22/11.
//  Copyright 2011 Ztelic Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HGRecipient.h"

typedef enum {
    HG_CREDIT_TYPE_GAIN_INVITE,
    HG_CREDIT_TYPE_GAIN_REDEEM,
    HG_CREDIT_TYPE_GAIN_SHARE_APP,
    HG_CREDIT_TYPE_GAIN_SHARE_ORDER,
    HG_CREDIT_TYPE_GAIN_PAY,
    HG_CREDIT_TYPE_CONSUME,
} HGCreditType;

@interface HGCreditHistory : NSObject <NSCoding>{
    NSString* identifier;
    HGCreditType type;
    NSDate* date;
    int value;
}
@property (nonatomic, retain) NSString* identifier;
@property (nonatomic, assign) HGCreditType type;
@property (nonatomic, retain) NSDate* date;
@property (nonatomic, assign) int value;

@end
