//
//  HappyGiftAppDelegate.h
//  HappyGift
//
//  Created by Zhang Yuhui on 2/11/11.
//  Copyright 2011 Ztelic Inc Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "Reachability.h"
#import "HGAccount.h"
#import "HGNotificationView.h"

@class MainViewController;
@interface HappyGiftAppDelegate : NSObject <UIApplicationDelegate> {
    IBOutlet UIWindow *window;
    IBOutlet UINavigationController *navigationController;
	HGAccount              *account;
    HGNotificationView     *notificationView; 
    NSMutableArray         *notificationQueue;
    NSTimer                *notificationTimer;
    NSDictionary           *remoteNotification;
    BOOL                   serviceHostsChecking;
}
@property (nonatomic, assign, readonly) BOOL networkReachable;
@property (nonatomic, assign, readonly) BOOL wifiReachable;

@property (nonatomic, retain) UIWindow	*window;
@property (nonatomic, retain) UINavigationController	*navigationController;

@property (nonatomic, retain) HGAccount 	*account;
@property (nonatomic, retain) NSData 	*deviceToken;
@property (nonatomic, retain) NSDictionary 	*remoteNotification;

+ (UIColor*)genericBackgroundColor;
+ (UIColor*)imageFrameColor;

+ (CGFloat)naviagtionTitleFontSize;
+ (CGFloat)fontSizeMicro;
+ (CGFloat)fontSizeTiny;
+ (CGFloat)fontSizeSmall;
+ (CGFloat)fontSizeNormal;
+ (CGFloat)fontSizeLarge;
+ (CGFloat)fontSizeXLarge;
+ (CGFloat)fontSizeXXXXLarge;
+ (NSString*)fontName;
+ (NSString*)boldFontName;

- (void)postNotification:(NSString*)notification;
- (void)sendNotification:(NSString*)notification;

+ (NSString*)backendServiceHost;

@end

