//
//  HGPushNotificationService.m
//  HappyGift
//
//  Created by Zhang Yuhui on 02/09/12.
//  Copyright 2011 Ztelic Inc. All rights reserved.
//

#import "HGPushNotificationService.h"
#import "HGPushNotificationLoader.h"
#import "HappyGiftAppDelegate.h"


static HGPushNotificationService* pushNotificationService = nil;

@interface HGPushNotificationService () <HGPushNotificationLoaderDelegate>

@end

@implementation HGPushNotificationService
@synthesize delegate;

+ (HGPushNotificationService*)sharedService{
    if (pushNotificationService == nil){
        pushNotificationService = [[HGPushNotificationService alloc] init];
    }
    return pushNotificationService;
}

- (id)init{
    self = [super init];
    if (self){
    }
    return self;
}

- (void)dealloc{
    [resetNotificationBadgeLoader release];
    [pushNotificationLoader release];
    [super dealloc];
}

- (void)requestRegisterDeviceToken:(NSData*)deviceToken{
    if (pushNotificationLoader == nil){
        pushNotificationLoader = [[HGPushNotificationLoader alloc] init];
        pushNotificationLoader.delegate = self;
    }else{
        [pushNotificationLoader cancel];
    }
    [pushNotificationLoader requestRegisterDeviceToken:deviceToken];
}

- (void)requestResetNotificationBadge {
    if (resetNotificationBadgeLoader == nil) {
        resetNotificationBadgeLoader = [[HGPushNotificationLoader alloc] init];
        resetNotificationBadgeLoader.delegate = self;
    } else {
        [resetNotificationBadgeLoader cancel];
    }
    
    [resetNotificationBadgeLoader requestResetNotificationBadge];
}

- (void)checkAndSetAllNotificationsAsRead {
    UIApplication *application = [UIApplication sharedApplication];
    if (application.applicationIconBadgeNumber > 0) {
        application.applicationIconBadgeNumber = 0;
        [[HGPushNotificationService sharedService] requestResetNotificationBadge];
    }
}

+ (HGPushNotificationEventType) getNotificationEventType:(NSDictionary*) userInfo {
    int event = [[userInfo objectForKey:@"event"] intValue];
    HGPushNotificationEventType type = PUSH_NOTIFICATION_EVENT_TYPE_UNKNOWN;
    switch (event) {
        case 1:
            type = PUSH_NOTIFICATION_EVENT_TYPE_GIFT_ACCEPTED;
            break;
        case 2:
            type = PUSH_NOTIFICATION_EVENT_TYPE_NEED_PAYMENT;
            break;
        case 3:
            type = PUSH_NOTIFICATION_EVENT_TYPE_DELIVERED;
        default:
            break;
    }
    return type;
}

+ (NSString*) getNotificationOrderId:(NSDictionary*)userInfo {
    return [NSString stringWithFormat:@"%@", [userInfo objectForKey:@"order_id"]];
}

+ (NSString*) getNotificationEventDescription:(NSDictionary*) userInfo {
    NSDictionary* messageDictionary = [userInfo objectForKey:@"aps"];
    return [messageDictionary objectForKey:@"alert"];
}

#pragma mark　- HGPushNotificationLoaderDelegate 
- (void)pushNotificationLoader:(HGPushNotificationLoader *)thePushNotificationLoader didRegisterDeviceTokenSucceed:(NSString*)theUserId{
    
}

- (void)pushNotificationLoader:(HGPushNotificationLoader *)thePushNotificationLoader didRegisterDeviceTokenFail:(NSString*)error{
    
}

- (void)pushNotificationLoader:(HGPushNotificationLoader *)pushNotificationLoader didResetNotificationBadgeSucceed:(NSString*)result {

}

- (void)pushNotificationLoader:(HGPushNotificationLoader *)pushNotificationLoader didResetNotificationBadgeFail:(NSString*)error {
}

@end
