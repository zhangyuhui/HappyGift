//
//  HappyGiftAppDelegate.m
//  HappyGift
//
//  Created by Zhang Yuhui on 2/11/11.
//  Copyright 2011 Ztelic Inc Inc. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "HappyGiftAppDelegate.h"
#import "HGConstants.h"
#import "HGDefines.h"
#import "HGSplashViewController.h"
#import "HGImageService.h"
#import "HGMainViewController.h"
#import "HGAccountService.h"
#import "HGPushNotificationService.h"
#import "HGTrackingService.h"
#import "HGNetworkHost.h"
#import "RegexKitLite.h"
#import "HGLogging.h"
#import <netinet/in.h>
#import <arpa/inet.h>
#import "HGGiftOrderService.h"
#import "HGAppConfigurationService.h"
#import "HGTutorialViewController.h"
#import "HGCreditViewController.h"
#import "HGGiftsSelectionViewController.h"

#define kAppDelegateAlertViewNewVersionUpgrade 200
#define kNewVersionDialogMaxDisplayCount 3
#define kNewVersionDialogMinDisplayInterval 86400

#define PREFERENCE_TIMESTAMP_DATA_FORMAT @"yyyy-MM-dd HH:mm:ss.SSSS"

// oauth 1.0 keys
//#define kOAuthConsumerKey				@"1945481696"
//#define kOAuthConsumerSecret			@"015f74bbb77994f913718fe1e0ec7595"

//#define kOAuthConsumerKey				@"2966727340"
//#define kOAuthConsumerSecret			@"13b282baf78ca94f544d0286bec7430e"

//#define kOAuthConsumerKey				@"1339240082"
//#define kOAuthConsumerSecret			@"8c618392f722a4e4dcc55a317ab5d64b"

static UIColor *kGenericBackgroundColor;
static UIColor *kImageFrameColor;

static NSString *kBackendServiceHost;

//static BOOL locationServiceDisabled = NO;

@interface HappyGiftAppDelegate() <CLLocationManagerDelegate, AVAudioPlayerDelegate>
@property (nonatomic, retain) Reachability *internetReach;
@property (nonatomic, assign, readwrite) BOOL networkReachable;
@property (nonatomic, assign, readwrite) BOOL wifiReachable;
@end


@implementation HappyGiftAppDelegate
@synthesize remoteNotification;
@synthesize networkReachable;
@synthesize wifiReachable;
@synthesize window;
@synthesize navigationController;
@synthesize internetReach;
@synthesize account;
@synthesize deviceToken;

#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    [HGTrackingService startSession];
    
    application.applicationSupportsShakeToEdit = YES;
    
    NSDictionary *userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    
    if (userInfo) {  
        remoteNotification = [userInfo retain];
        HGDebug(@"launch from push notification %@", userInfo);
    }
    
    window.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Default.jpg"]];
    
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];
    [HGTrackingService logAllPageViews:self.navigationController];
    
    // Check if first time launch
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString* preferneceTimestamp = [defaults stringForKey:kHGPreferneceKeyTimestamp];
	if (preferneceTimestamp == nil){
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateFormat:PREFERENCE_TIMESTAMP_DATA_FORMAT];
		NSString *formattedDateString = [dateFormatter stringFromDate:[NSDate date]];
		[dateFormatter release];
		
		[defaults setObject:formattedDateString forKey:kHGPreferneceKeyTimestamp];
		[defaults synchronize];
        
        HGTutorialViewController* viewController = [[HGTutorialViewController alloc] initWithNibName:@"HGTutorialViewController" bundle:nil];
        [self.navigationController pushViewController:viewController animated:NO];
        [viewController release];
        
        UIImageView* splashImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Default.jpg"]];
        CGRect viewFrame = splashImageView.frame;
        viewFrame.origin.x = 0;
        viewFrame.origin.y = 20;
        viewFrame.size.width = 320;
        viewFrame.size.height = 460;
        splashImageView.frame = viewFrame;
        [window addSubview:splashImageView];
        [splashImageView release];
        
        viewFrame = self.navigationController.view.frame;
        viewFrame.origin.y = 460;
        self.navigationController.view.frame = viewFrame;
        [window addSubview:navigationController.view];
        
        [UIView animateWithDuration:0.3 
                              delay:0 
                            options:UIViewAnimationOptionCurveEaseInOut 
                         animations:^{
                             CGRect viewFrame = self.navigationController.view.frame;
                             viewFrame.origin.y = 0;
                             self.navigationController.view.frame = viewFrame;
                         } 
                         completion:^(BOOL finished) {
                             [splashImageView removeFromSuperview];
                         }];
        
    }else{
        HGSplashViewController* viewController = [[HGSplashViewController alloc] initWithNibName:@"HGSplashViewController" bundle:nil];
        [self.navigationController pushViewController:viewController animated:NO];
        [viewController release];
        [window addSubview:navigationController.view];
    }
    
    notificationView = [[HGNotificationView notificationView] retain];
    CGRect notificationViewFrame = notificationView.frame;
    notificationViewFrame.origin.x = 0.0;
    notificationViewFrame.origin.y = 445.0;
    notificationView.frame = notificationViewFrame;
    notificationView.hidden = YES;
    [window addSubview:notificationView];
    
    [window makeKeyAndVisible];
    
    // new version observer
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNewVersionAvailable:) name:kHGNotificationNewVersionAvailable object:nil];
	
	//Reachability
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(reachabilityDidChange:) name: kReachabilityChangedNotification object: nil];
    
    self.internetReach = [Reachability reachabilityForInternetConnection];
    [self.internetReach startNotifier];
    if (!self.networkReachable && [self.internetReach currentReachabilityStatus] != NotReachable) {
        self.networkReachable = YES;
    }
    if (!self.wifiReachable && [self.internetReach currentReachabilityStatus] == ReachableViaWiFi) {
        self.wifiReachable = YES;
    }
    
    kBackendServiceHost = [defaults objectForKey:kHGPreferneceKeyBackendServiceHost];
    if (kBackendServiceHost == nil || [kBackendServiceHost isEqualToString:@""] == YES){
        NSArray* backendServiceHosts = [[HGAppConfigurationService sharedService] serverList];
        kBackendServiceHost = [[NSString alloc] initWithString:[backendServiceHosts objectAtIndex:0]];
        NSString* lastBackendServiceHost = [defaults objectForKey:kHGPreferneceKeyBackendServiceHost];
        
        if (lastBackendServiceHost == nil || [@"" isEqualToString:lastBackendServiceHost]) {
            lastBackendServiceHost = @"http://42.120.48.230";
        }
        
        [defaults setObject:kBackendServiceHost forKey:kHGPreferneceKeyBackendServiceHost];
        [defaults synchronize];
        
        NSHTTPCookieStorage* cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        if (lastBackendServiceHost != nil && [lastBackendServiceHost isEqualToString:kBackendServiceHost] == NO){
            NSURL* lastServiceHostURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/gift/", lastBackendServiceHost]];
            NSArray* lastServiceHostTokenCookies = [cookieStorage cookiesForURL:lastServiceHostURL];
            if (lastServiceHostTokenCookies != nil){
                NSURL* serviceHostURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/gift/", kBackendServiceHost]];
                NSMutableArray* serviceHostTokenCookies = [[NSMutableArray alloc] init];
                for (NSHTTPCookie* cookie in lastServiceHostTokenCookies) {
                    NSMutableDictionary* cookieProperties =  [NSMutableDictionary dictionaryWithDictionary:cookie.properties];
                    [cookieProperties setObject:serviceHostURL.host forKey:NSHTTPCookieDomain];
                    NSHTTPCookie *newCookie = [NSHTTPCookie cookieWithProperties:cookieProperties];
                    [serviceHostTokenCookies addObject:newCookie];
                }
                [cookieStorage setCookies:serviceHostTokenCookies forURL:serviceHostURL mainDocumentURL:nil];
                [serviceHostTokenCookies release];
            }
        }
    }
    serviceHostsChecking = NO;
    if (self.networkReachable){
        [self performSelectorInBackground:@selector(handleServiceHostsChecking) withObject:nil];
    }

    [application registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
    [[NSNotificationCenter defaultCenter] postNotificationName:kHGNotificationApplicationWillResignActive object:nil];
    [[HGImageService sharedService] clearHistory];
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
//	if (locationManager) {
//		[locationManager stopUpdatingLocation];
//		locationManager.delegate = nil;
//		[locationManager release];
//		locationManager = nil;
//	}
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    [[HGPushNotificationService sharedService] checkAndSetAllNotificationsAsRead];
    [[NSNotificationCenter defaultCenter] postNotificationName:kHGNotificationApplicationDidBecomeActive object:self];
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)theDeviceToken{
    if ([deviceToken isEqualToData:theDeviceToken] == NO){
        if (deviceToken != nil){
            [deviceToken release];
            deviceToken = nil;
        }
        deviceToken = [theDeviceToken retain];
        HGAccountService* accountService = [HGAccountService sharedService];
        if (accountService.currentAccount != nil &&
            accountService.currentAccount.userId != nil &&
            [accountService.currentAccount.userId isEqualToString:@""] == NO){
            [[HGPushNotificationService sharedService] requestRegisterDeviceToken:deviceToken];
        }
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    HGDebug(@"didReceiveRemoteNotification: %@", userInfo);
    [self postNotification:[HGPushNotificationService getNotificationEventDescription:userInfo]];
    [[HGPushNotificationService sharedService] checkAndSetAllNotificationsAsRead];
    HGPushNotificationEventType type = [HGPushNotificationService getNotificationEventType:userInfo];
    if (type == PUSH_NOTIFICATION_EVENT_TYPE_GIFT_ACCEPTED || 
        type == PUSH_NOTIFICATION_EVENT_TYPE_NEED_PAYMENT ||
        type == PUSH_NOTIFICATION_EVENT_TYPE_DELIVERED) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kHGNotificationMyGiftsNeedUpdate object:nil];
    }
}

+ (UIColor*)genericBackgroundColor{
	if (kGenericBackgroundColor == nil) {
        kGenericBackgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"generic_background.jpg"]];
		[kGenericBackgroundColor retain];
    }
    return kGenericBackgroundColor;
}

+ (UIColor*)imageFrameColor{
    if (kImageFrameColor == nil) {
        kImageFrameColor = UIColorFromRGB(0xcecece);
        [kImageFrameColor retain];
    }
    return kImageFrameColor;
}

+ (CGFloat)naviagtionTitleFontSize{
    return 22.0;
}

+ (CGFloat)fontSizeMicro {
    return 10.0f;
}

+ (CGFloat)fontSizeTiny {
    return 12.0f;
}

+ (CGFloat)fontSizeSmall {
    return 14.0f;
}

+ (CGFloat)fontSizeNormal {
    return 16.0f;
}

+ (CGFloat)fontSizeLarge {
    return 18.0f;
}

+ (CGFloat)fontSizeXLarge {
    return 20.0f;
}

+ (CGFloat)fontSizeXXXXLarge {
    return 26.0f;
}

+ (NSString*)fontName {
  //  return @"Georgia";
  //  return @"TimesNewRomanPSMT";
 //  return @"HelveticaNeue";
  //  return @"ArialUnicodeMS";
  //  return @"CourierNewPSMT";
  //  return @"Courier";
   return @"Helvetica";
  //  return @"Verdana";
  //  return @"ArialMT";
  //  return @"STHeitiSC-Light";
}

+ (NSString*)boldFontName {
  //  return @"Georgia-Bold";
  //  return @"TimesNewRomanPS-BoldMT";
 //   return @"HelveticaNeue-Bold";
  //  return @"ArialUnicodeMS-Bold";
 //   return @"CourierNewPS-BoldMT";
 //   return @"Courier-Bold";
    return @"Helvetica-Bold";
 //   return @"Verdana-Bold";
  //  return @"Arial-BoldMT";
  //  return @"STHeitiSC-Medium";
}

+ (NSString*)backendServiceHost{
    //return kBackendServiceHost;
    return @"http://42.120.41.77";
}

- (void)handleServiceHostsChecking{
    serviceHostsChecking = YES;
    int serviceHostsIndex = 0;
    NSString* serviceHost = nil;
    NSArray* backendServiceHosts = [[NSArray alloc] initWithArray:[[HGAppConfigurationService sharedService] serverList]];
    while (YES) {
        serviceHost = [backendServiceHosts objectAtIndex:serviceHostsIndex];
        NSURL *serviceHostURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/gift/status.php", serviceHost]];
        NSURLRequest *serviceHostRequest = [[NSURLRequest alloc] initWithURL:serviceHostURL 
                                                      cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:20.0];
        NSHTTPURLResponse *serviceHostResponse = nil;
        [NSURLConnection sendSynchronousRequest:serviceHostRequest
                              returningResponse:&serviceHostResponse error:NULL];
        [serviceHostRequest release];
        if (serviceHostResponse == nil || serviceHostResponse.statusCode != 200){
            serviceHostsIndex += 1;
            if (serviceHostsIndex >= [backendServiceHosts count]){
                serviceHostsIndex = 0;
                break;
            }
        }else{
            break;
        }
    }
    [backendServiceHosts release];
    [self performSelectorOnMainThread:@selector(handleServiceHostsUpdating:) withObject:serviceHost waitUntilDone:YES];
    serviceHostsChecking = NO;
}

- (void)handleServiceHostsUpdating:(NSString*)serviceHost{
    if ([kBackendServiceHost isEqualToString:serviceHost] == NO){
        [kBackendServiceHost release];
        kBackendServiceHost = nil;
        kBackendServiceHost = [[NSString alloc] initWithString:serviceHost];
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        NSString* lastBackendServiceHost = [defaults objectForKey:kHGPreferneceKeyBackendServiceHost];
        [defaults setObject:kBackendServiceHost forKey:kHGPreferneceKeyBackendServiceHost];
        [defaults synchronize];
        
        NSHTTPCookieStorage* cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        if (lastBackendServiceHost != nil && [lastBackendServiceHost isEqualToString:kBackendServiceHost] == NO){
            NSURL* lastServiceHostURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/gift/", lastBackendServiceHost]];
            NSArray* lastServiceHostTokenCookies = [cookieStorage cookiesForURL:lastServiceHostURL];
            if (lastServiceHostTokenCookies != nil){
                NSURL* serviceHostURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/gift/", kBackendServiceHost]];
                NSMutableArray* serviceHostTokenCookies = [[NSMutableArray alloc] init];
                for (NSHTTPCookie* cookie in lastServiceHostTokenCookies) {
                    NSMutableDictionary* cookieProperties =  [NSMutableDictionary dictionaryWithDictionary:cookie.properties];
                    [cookieProperties setObject:serviceHostURL.host forKey:NSHTTPCookieDomain];
                    NSHTTPCookie *newCookie = [NSHTTPCookie cookieWithProperties:cookieProperties];
                    [serviceHostTokenCookies addObject:newCookie];
                }
                [cookieStorage setCookies:serviceHostTokenCookies forURL:serviceHostURL mainDocumentURL:nil];
                [serviceHostTokenCookies release];
            }
        }
    }
}

//#pragma mark - CLLocationManagerDelegate Delegate

//- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
//	locationServiceDisabled = NO;
//}
//
//- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
//	if ([error code]==kCLErrorDenied) {
//		locationServiceDisabled = YES;
//	}
//}

#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    [[HGImageService sharedService] applicationDidReceiveMemoryWarning:application];
}

#pragma mark Notification handlers

- (void)reachabilityDidChange:(NSNotification *)notification {
    Reachability* currReach = [notification object];
    if (self.internetReach == currReach){
        BOOL theNetworkReachable = YES;
        BOOL theWifiReachable = YES;
        if ([currReach currentReachabilityStatus] == NotReachable) {
            theNetworkReachable = NO;
            theWifiReachable = NO;
        }else if ([currReach currentReachabilityStatus] != ReachableViaWiFi) {
            theWifiReachable = NO;
        }
        self.networkReachable = theNetworkReachable;
        self.wifiReachable = theWifiReachable;
        if (self.networkReachable == YES && serviceHostsChecking == NO){
            [self performSelectorInBackground:@selector(handleServiceHostsChecking) withObject:nil];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:kHGNotificationApplicationReachablityUpdated object:nil];
        
    }
}

//
//#pragma mark Alipay
//- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
//    //[[HGAlipayService sharedService] parsePaymentResult:url application:application];
//	return YES;
//}

#pragma mark WeiBoAuthEngineDelegate
- (void)storeCachedOAuthData:(NSString *)data forUsername:(NSString *)username {
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:data forKey:@"authData"];
	[defaults synchronize];
}

- (NSString *)cachedOAuthDataForUsername:(NSString *)username {
    NSString* authData = [[NSUserDefaults standardUserDefaults] objectForKey:@"authData"];
    if (authData == nil || [authData isEqualToString:@""]){
        return @"";
    }else{
        return authData;
    }
}

- (void)removeCachedOAuthDataForUsername:(NSString *)username{
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	[defaults removeObjectForKey:@"authData"];
	[defaults synchronize];
}

- (void)dealloc {
    [navigationController release];
    [window release];
    
    [account release];
    [notificationView release];
    [notificationQueue release];
    
    [deviceToken release];
    [remoteNotification release];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kHGNotificationNewVersionAvailable object:nil];
    [super dealloc];
}

#pragma mark UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)theNavigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    NSArray *viewControllers = [navigationController viewControllers];
    UIViewController* rootViewController = [viewControllers objectAtIndex:0];
    if ([rootViewController isKindOfClass:[HGSplashViewController class]] &&
        [viewControllers count] > 1){
        if ([rootViewController respondsToSelector:@selector(removeFromParentViewController)]){
            [rootViewController removeFromParentViewController];
        }else{
            NSMutableArray *viewControllers = [[navigationController.viewControllers mutableCopy] autorelease];
            [viewControllers removeObjectAtIndex:0];
            navigationController.viewControllers = viewControllers;
        }
    }else if ([rootViewController isKindOfClass:[HGTutorialViewController class]] &&
         [viewControllers count] > 1){
        if ([rootViewController respondsToSelector:@selector(removeFromParentViewController)]){
            [rootViewController removeFromParentViewController];
        }else{
            NSMutableArray *viewControllers = [[navigationController.viewControllers mutableCopy] autorelease];
            [viewControllers removeObjectAtIndex:0];
            navigationController.viewControllers = viewControllers;
        }
    }else if ([viewController isKindOfClass:[HGGiftsSelectionViewController class]]){
        if ([viewControllers count] >= 2){
            int lastViewControllerIndex = [viewControllers count] - 2;
            UIViewController* lastViewController = [viewControllers objectAtIndex:lastViewControllerIndex];
            if ([lastViewController isKindOfClass:[HGCreditViewController class]]){
                if ([lastViewController respondsToSelector:@selector(removeFromParentViewController)]){
                    [lastViewController removeFromParentViewController];
                }else{
                    NSMutableArray *viewControllers = [[navigationController.viewControllers mutableCopy] autorelease];
                    [viewControllers removeObjectAtIndex:lastViewControllerIndex];
                    navigationController.viewControllers = viewControllers;
                }
            }
        }
    } 
}

- (void)postNotification:(NSString*)notification{
    if (notificationQueue == nil){
        notificationQueue = [[NSMutableArray alloc] init];
    }
    
    if ([notificationQueue count] > 0){
        NSString* lastNotification = [notificationQueue lastObject];
        if ([lastNotification isEqualToString:notification]){
            return;
        }
    }
    if (notificationView.hidden == NO && [notificationView.notification isEqualToString:notification]){
        return;
    }
    
    [notificationQueue addObject:notification];
    
    if (notificationTimer == nil){
        notificationTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(handleNotificationTimer:) userInfo:nil repeats:NO];
    }
}

- (void)sendNotification:(NSString*)notification{
    if (notificationQueue == nil){
        notificationQueue = [[NSMutableArray alloc] init];
    }
    
    if ([notificationQueue count] > 0){
        NSString* firstNotification = [notificationQueue objectAtIndex:0];
        if ([firstNotification isEqualToString:notification]){
            return;
        }
    }
    if (notificationView.hidden == NO && [notificationView.notification isEqualToString:notification]){
        return;
    }
    [notificationQueue insertObject:notification atIndex:0];
    
    if (notificationTimer == nil){
        notificationTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(handleNotificationTimer:) userInfo:nil repeats:NO];
    }    
}

- (void)handleNotificationTimer:(NSTimer*)timer{
    notificationTimer = nil;
    if ([notificationQueue count] > 0){
        NSString* notification = [notificationQueue objectAtIndex:0];
        notificationView.notification = notification;
        [notificationQueue removeObjectAtIndex:0];
        
        CGRect notificationViewFrame = notificationView.frame;
        notificationViewFrame.origin.y = 480.0 - notificationViewFrame.size.height;
        notificationView.frame = notificationViewFrame;
        
        BOOL refresh = YES;
        if (notificationView.hidden == YES){
            refresh = NO;
            notificationView.hidden = NO;
        }
        CATransition *animation = [CATransition animation];
        [animation setDelegate:self];
        [animation setType:@"cube"];
        [animation setDuration:refresh?0.5:0.3];
        [animation setSubtype:kCATransitionFromTop];
        [animation setValue:@"showNotification" forKey:@"animationName"];
        [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        [[notificationView layer] addAnimation:animation forKey:@"showNotification"];
        
        notificationTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(handleNotificationTimer:) userInfo:nil repeats:NO];
    }else{
        if (notificationView != nil && notificationView.hidden == NO){
            notificationView.notification = @"";
            notificationView.hidden = YES;
            CATransition *animation = [CATransition animation];
            [animation setDelegate:self];
            [animation setType:@"cube"];
            [animation setDuration:0.3];
            [animation setSubtype:kCATransitionFromTop];
            [animation setValue:@"hideNotification" forKey:@"animationName"];
            [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
            [notificationView.layer addAnimation:animation forKey:@"hideNotification"];
        }
    }
}

- (void)animationDidStart:(CAAnimation *)animation{
    NSString* animationName = [animation valueForKey:@"animationName"];
    if ([animationName isEqualToString:@"hideNotification"]){
         notificationView.notification = @"";
    }
}

- (void)animationDidStop:(CAAnimation *)animation finished:(BOOL)finished{
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == kAppDelegateAlertViewNewVersionUpgrade) {
        // upgrade button
        if (buttonIndex == 1) {
            NSString* newVersionDownloadUrl = [[HGAppConfigurationService sharedService].appConfiguration objectForKey:kAppConfigurationKeyNewVersionDownloadUrl];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:newVersionDownloadUrl]];
        }
    }
}

- (void)handleNewVersionAvailable:(NSNotification *)notification {
    NSDictionary* appConfiguration = [notification object];
    NSString* newVersion = [appConfiguration objectForKey:kAppConfigurationKeyNewVersion];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString* lastShownVersion = [defaults objectForKey:kHGPreferenceKeyNewVersionDialogLastShownVersion];
    
    BOOL shouldShowUpgradeDialog = NO;
    NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970];
    
    if (![lastShownVersion isEqualToString:newVersion]) {
        shouldShowUpgradeDialog = YES;
        
        [defaults setObject:newVersion forKey:kHGPreferenceKeyNewVersionDialogLastShownVersion];
        [defaults setInteger:1 forKey:kHGPreferenceKeyNewVersionDialogShownCount];
        [defaults setDouble:currentTime forKey:kHGPreferenceKeyNewVersionDialogLastShownTimestamp];
        [defaults synchronize];
    } else {
        int shownCount = [defaults integerForKey:kHGPreferenceKeyNewVersionDialogShownCount];
        if (shownCount < kNewVersionDialogMaxDisplayCount) {
            NSTimeInterval lastShownTimestamp = [defaults doubleForKey:kHGPreferenceKeyNewVersionDialogLastShownTimestamp];
            
            if (currentTime - lastShownTimestamp > kNewVersionDialogMinDisplayInterval) {
                shouldShowUpgradeDialog = YES;
                
                [defaults setInteger:shownCount + 1 forKey:kHGPreferenceKeyNewVersionDialogShownCount];
                [defaults setDouble:currentTime forKey:kHGPreferenceKeyNewVersionDialogLastShownTimestamp];
                [defaults synchronize];
            } else {
                HGDebug(@"last upgrade notice was shown in less than one day.");
            }
        } else {
            HGDebug(@"upgrade notice has been shown more than 3 times.");
        }
    }
    
    if (shouldShowUpgradeDialog) {
        NSString* newVersionDescription = [appConfiguration objectForKey:kAppConfigurationKeyNewVersionDescription];
        NSString* msg = newVersionDescription;
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:nil
                                                             message:msg
                                                            delegate:self 
                                                   cancelButtonTitle:@"以后再说"
                                                   otherButtonTitles:@"立即更新", nil];
        
        // set left alignment for the message text
        for (UIView *subview in alertView.subviews) {
            if ([[subview class] isSubclassOfClass:[UILabel class]]) {
                UILabel *label = (UILabel*)subview;
                if ([label.text isEqualToString:msg]) {
                    label.textAlignment = UITextAlignmentLeft;
                    break;
                }
            }
        }  
        
        [alertView setTag:kAppDelegateAlertViewNewVersionUpgrade];
        [alertView show];
        [alertView release];
    }
}
@end
