//
//  HGPushNotificationLoader.m
//  HappyGift
//
//  Created by Zhang Yuhui on 02/09/12.
//  Copyright 2011 Ztelic Inc. All rights reserved.
//

#import "HGPushNotificationLoader.h"
#import "JSON.h"
#import "HGNetworkHost.h"
#import "HGConstants.h"
#import "HappyGiftAppDelegate.h"
#import "NSString+Addition.h"
#import <sqlite3.h>
#import "HGLogging.h"

#define kRequestTypeRegisterDeviceToken 0
#define kRequestResetNotificationBadge 1


@interface HGPushNotificationLoader()
@end

@implementation HGPushNotificationLoader
@synthesize delegate;
@synthesize running;

static NSString *kRegisterDeviceTokenFormat = @"%@/gift/index.php?route=account/apns_token&device_token=%@";
static NSString *kResetNotificationBadgeFormat = @"%@/gift/index.php?route=account/reset_badge";

- (void)dealloc {
    [super dealloc];
}

- (void)cancel {	
    [super cancel];
    running = NO;
}

- (void)requestRegisterDeviceToken:(NSData*)deviceToken{
    if (running){
        return;
    }
    [self cancel];
    running = YES;
    requestType = kRequestTypeRegisterDeviceToken;
    
    NSString* requestString = [NSString stringWithFormat:kRegisterDeviceTokenFormat, 
                           [HappyGiftAppDelegate backendServiceHost], deviceToken];
    HGDebug(@"%@", requestString);
    NSURL* requestURL = [NSURL URLWithString:[requestString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [super requestByGet:requestURL];
}

- (void)requestResetNotificationBadge {
    if (running) {
        return;
    }
    [self cancel];
    running = YES;
    requestType = kRequestResetNotificationBadge;
    
    NSString* requestString = [NSString stringWithFormat:kResetNotificationBadgeFormat, 
                               [HappyGiftAppDelegate backendServiceHost]];
    HGDebug(@"%@", requestString);
    NSURL* requestURL = [NSURL URLWithString:[requestString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [super requestByGet:requestURL];
}

#pragma mark overrides
- (void)connectionDidFinishLoading:(NSURLConnection *)conn {
    [super connectionDidFinishLoading:conn];
    running = NO;
    NSString* jsonString = [NSString stringWithData:self.data];
    HGDebug(@"%@", jsonString);

    if (requestType == kRequestTypeRegisterDeviceToken) {
        if ([delegate respondsToSelector:@selector(pushNotificationLoader:didRegisterDeviceTokenSucceed:)]){
            [delegate pushNotificationLoader:self didRegisterDeviceTokenSucceed:nil];
        }
    } else if (requestType == kRequestResetNotificationBadge) {
        if ([delegate respondsToSelector:@selector(pushNotificationLoader:didResetNotificationBadgeSucceed:)]){
            [delegate pushNotificationLoader:self didResetNotificationBadgeSucceed:nil];
        }
    }
}

- (void)connection:(NSURLConnection *)conn didFailWithError:(NSError *)error {
    [super connection:conn didFailWithError:error];
    HGDebug(@"didFailWithError: %@", error);
	running = NO;
    if (requestType == kRequestTypeRegisterDeviceToken) {
        if ([delegate respondsToSelector:@selector(pushNotificationLoader:didRegisterDeviceTokenFail:)]){
            [delegate pushNotificationLoader:self didRegisterDeviceTokenFail:[error description]];
        }
    } else if (requestType == kRequestResetNotificationBadge) {
        if ([delegate respondsToSelector:@selector(pushNotificationLoader:didResetNotificationBadgeFail:)]){
            [delegate pushNotificationLoader:self didResetNotificationBadgeFail:nil];
        }
    }
}
@end
