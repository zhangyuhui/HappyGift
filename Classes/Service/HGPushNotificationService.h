//
//  HGPushNotificationService.h
//  HappyGift
//
//  Created by Zhang Yuhui on 02/09/12.
//  Copyright 2011 Ztelic Inc Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
@class HGPushNotificationLoader;
@protocol HGPushNotificationServiceDelegate;

typedef enum _HGPushNotificationEventType {
    PUSH_NOTIFICATION_EVENT_TYPE_UNKNOWN,
    PUSH_NOTIFICATION_EVENT_TYPE_GIFT_ACCEPTED,
    PUSH_NOTIFICATION_EVENT_TYPE_NEED_PAYMENT,
    PUSH_NOTIFICATION_EVENT_TYPE_DELIVERED,
} HGPushNotificationEventType;

@interface HGPushNotificationService : NSObject {
    HGPushNotificationLoader* pushNotificationLoader;
    HGPushNotificationLoader* resetNotificationBadgeLoader;
    id<HGPushNotificationServiceDelegate> delegate;
}
@property (nonatomic, assign) id<HGPushNotificationServiceDelegate> delegate;

+ (HGPushNotificationService*)sharedService;

- (void)requestRegisterDeviceToken:(NSData*)deviceToken;
- (void)requestResetNotificationBadge;
- (void)checkAndSetAllNotificationsAsRead;

+ (HGPushNotificationEventType) getNotificationEventType:(NSDictionary*) userInfo;
+ (NSString*) getNotificationOrderId:(NSDictionary*)userInfo;
+ (NSString*) getNotificationEventDescription:(NSDictionary*) userInfo;
@end

@protocol HGPushNotificationServiceDelegate<NSObject>

@end
