//
//  HGRecipient.h
//  HappyGift
//
//  Created by Yujian Weng on 12-5-17.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

extern const int NETWORK_ALL_SNS;
extern const int NETWORK_PHONE_CONTACT;
extern const int NETWORK_LOCAL_CONTACT;
extern const int NETWORK_SNS_WEIBO;
extern const int NETWORK_SNS_RENREN;

@interface HGRecipient: NSObject <NSCoding>  {
    int  recipientId;
    NSString*  recipientName;
    NSString*  recipientPhone;
    NSString*  recipientEmail;
    NSString*  recipientImageUrl;
    NSString*  recipientProfileId;
    int        recipientNetworkId;
    NSString*  recipientBirthday;
    int recipientNextBirthdayCount;
    NSString*  recipientDisplayName;
    
    NSString* recipientProvince;
    NSString* recipientCity;
    NSString* recipientStreetAddress;
    NSString* recipientPostCode;
}

@property (nonatomic, assign) int  recipientId;
@property (nonatomic, retain) NSString*  recipientName;
@property (nonatomic, retain) NSString*  recipientDisplayName;
@property (nonatomic, retain) NSString*  recipientPhone;
@property (nonatomic, retain) NSString*  recipientEmail;
@property (nonatomic, retain) NSString*  recipientImageUrl;
@property (nonatomic, retain) NSString*  recipientProfileId;
@property (nonatomic, assign) int        recipientNetworkId;
@property (nonatomic, retain) NSString*  recipientBirthday;
@property (nonatomic, assign) int recipientNextBirthdayCount;
@property (nonatomic, retain) NSString*  recipientProvince;
@property (nonatomic, retain) NSString*  recipientCity;
@property (nonatomic, retain) NSString*  recipientStreetAddress;
@property (nonatomic, retain) NSString*  recipientPostCode;

@end
