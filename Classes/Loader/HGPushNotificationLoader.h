//
//  HGPushNotificationLoader.h
//  HappyGift
//
//  Created by Zhang Yuhui on 02/09/12.
//  Copyright 2011 Ztelic Inc Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HGNetworkConnection.h"

@protocol HGPushNotificationLoaderDelegate;

@interface HGPushNotificationLoader : HGNetworkConnection {
    BOOL running;
    int requestType;
}
@property (nonatomic, assign)   id<HGPushNotificationLoaderDelegate> delegate;
@property (nonatomic, readonly) BOOL  running;

- (void)requestRegisterDeviceToken:(NSData*)deviceToken;
- (void)requestResetNotificationBadge;
@end


@protocol HGPushNotificationLoaderDelegate <NSObject>
- (void)pushNotificationLoader:(HGPushNotificationLoader *)pushNotificationLoader didRegisterDeviceTokenSucceed:(NSString*)userId;
- (void)pushNotificationLoader:(HGPushNotificationLoader *)pushNotificationLoader didRegisterDeviceTokenFail:(NSString*)error;

- (void)pushNotificationLoader:(HGPushNotificationLoader *)pushNotificationLoader didResetNotificationBadgeSucceed:(NSString*)result;
- (void)pushNotificationLoader:(HGPushNotificationLoader *)pushNotificationLoader didResetNotificationBadgeFail:(NSString*)error;
@end
