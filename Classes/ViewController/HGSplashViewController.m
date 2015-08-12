//
//  HGSplashViewController.m
//  HappyGift
//
//  Created by Zhang Yuhui on 2/11/11.
//  Copyright 2011 Ztelic Inc Inc. All rights reserved.
//

#import "HGSplashViewController.h"
#import "HGSplashService.h"
#import "UIImage+Addition.h"
#import "HGConstants.h"
#import "HappyGiftAppDelegate.h"
#import "HGMainViewController.h"
#import "HGAccountService.h"
#import "HGSplash.h"
#import "HGProgressView.h"
#import "HGTrackingService.h"
#import "HGSentGiftDetailViewController.h"
#import "HGPushNotificationService.h"
#import "HappyGiftAppDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import "HGGiftOrder.h"
#import "HGLogging.h"
#import "HGAppConfigurationService.h"
#import "HGLoginViewController.h"

#define kSplashPlayInterval 10.0
#define kSplashChangeInterval 4.0

#define kSplashExitInterval 5.0

@interface HGSplashViewController() <HGAccountServiceDelegate>

@end

@implementation HGSplashViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Default.jpg"]];
    
    HGSplash* splash = [HGSplashService sharedService].splash;
    
    splashImageView.image = splash.image;
    splashImageView.alpha = 0.0;
    
    progressView = [[HGProgressView progressView:self.view.frame] retain];
    [self.view addSubview:progressView];
    progressView.hidden = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleApplicationDidBecomeActiveAction:) name:kHGNotificationApplicationDidBecomeActive object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleApplicationWillResignActive:) name:kHGNotificationApplicationWillResignActive object:nil];
    
    NSHTTPCookieStorage* cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSString* backendHost = [HappyGiftAppDelegate backendServiceHost];
    NSURL* backendHostURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/gift/", backendHost]];
    NSArray* tokenCookies = [cookieStorage cookiesForURL:backendHostURL];

    HGAccountService* accountService = [HGAccountService sharedService];
    if (tokenCookies == nil || [tokenCookies count] == 0 || accountService.currentAccount == nil ||
        accountService.currentAccount.userId == nil ||
        [accountService.currentAccount.userId isEqualToString:@""] == YES){
        accountReady = NO;
        accountService.delegate = self;
        [progressView startAnimation];
        [accountService createAccount];
    }else{
        accountReady = YES;
        [progressView stopAnimation];
        /*NSMutableDictionary *tokenCookie = [NSMutableDictionary dictionary];
         [tokenCookie setObject:[NSString stringWithFormat:@"user_id=%@;token=%@", accountService.currentAccount.userId, accountService.currentAccount.userToken] forKey:NSHTTPCookieValue];
         [tokenCookie setObject:[[NSDate date] dateByAddingTimeInterval:2629743] forKey:NSHTTPCookieExpires];
         NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:tokenCookie];
         [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];*/
        
        [[HGAppConfigurationService sharedService] requestAppConfiguration];
        
        HappyGiftAppDelegate *appDelegate = (HappyGiftAppDelegate *)[[UIApplication sharedApplication] delegate];
        if (appDelegate.deviceToken != nil){
            [[HGPushNotificationService sharedService] requestRegisterDeviceToken:appDelegate.deviceToken];
        }
    }
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    [progressView removeFromSuperview];
    [progressView release];
    progressView = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kHGNotificationApplicationDidBecomeActive object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kHGNotificationApplicationWillResignActive object:nil];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    /*if (splashPlayTimer  == nil){
        [UIView animateWithDuration:2.0 
                              delay:0.0 
                            options:UIViewAnimationOptionCurveEaseInOut 
                         animations:^{
                             splashImageView.alpha = 1.0;
                             splashTitleView.alpha = 1.0;
                         } 
                         completion:^(BOOL finished) {
                             UIImage* image = splashImageView.image;
                             if (image != nil){
                                 self.view.backgroundColor = [UIColor colorWithPatternImage:[image imageWithScale:splashImageView.frame.size]];
                             }
                             if (self.view.userInteractionEnabled == YES){
                                 splashPlayTimer = [NSTimer scheduledTimerWithTimeInterval:kSplashExitInterval target:self selector:@selector(handleSplashTimer:) userInfo:nil repeats:NO];
                             }
                         }];
    }*/
    if (splashPlayTimer == nil && accountReady == NO){
        splashPlayTimer = [NSTimer scheduledTimerWithTimeInterval:kSplashExitInterval target:self selector:@selector(handleSplashTimer:) userInfo:nil repeats:NO];
    }else{
        [self gotoNextPage];
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

- (void)handleApplicationDidBecomeActiveAction:(NSNotification *)notification{
    splashPlayTimer = [NSTimer scheduledTimerWithTimeInterval:kSplashPlayInterval target:self selector:@selector(handleSplashTimer:) userInfo:nil repeats:YES];
}

- (void)handleApplicationWillResignActive:(NSNotification *)notification{
    if (splashPlayTimer != nil){
        [splashPlayTimer invalidate];
        splashPlayTimer = nil;
    }   
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}


- (void)dealloc {
    [splashImageView release];
    if (progressView != nil){
        [progressView release];
        progressView = nil;
    }
    
    HGAccountService* accountService = [HGAccountService sharedService];
    if (accountService.delegate == self) {
        accountService.delegate = nil;
    }
        
	[super dealloc];
}

- (void)handleNextAction:(UITapGestureRecognizer*)sender{
    [self gotoNextPage];
}

- (void)handleCheckLoginAction{
    HGAccountService* accountService = [HGAccountService sharedService];
    if (accountService.currentAccount == nil ||
        accountService.currentAccount.userId == nil ||
        [accountService.currentAccount.userId isEqualToString:@""] == YES){
        accountReady = NO;
        accountService.delegate = self;
        [accountService createAccount];
    }else{
        accountReady = YES;
        /*NSMutableDictionary *tokenCookie = [NSMutableDictionary dictionary];
        [tokenCookie setObject:[NSString stringWithFormat:@"user_id=%@;token=%@", accountService.currentAccount.userId, accountService.currentAccount.userToken] forKey:NSHTTPCookieValue];
        [tokenCookie setObject:[[NSDate date] dateByAddingTimeInterval:2629743] forKey:NSHTTPCookieExpires];
        NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:tokenCookie];
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];*/
        
        [self gotoNextPage];
        
        [[HGAppConfigurationService sharedService] requestAppConfiguration];
        HappyGiftAppDelegate *appDelegate = (HappyGiftAppDelegate *)[[UIApplication sharedApplication] delegate];
        if (appDelegate.deviceToken != nil){
            [[HGPushNotificationService sharedService] requestRegisterDeviceToken:appDelegate.deviceToken];
        }
    }
}

- (void)handleSplashTimer:(NSTimer*)timer{
    /*if (splashIndex < splashCount - 1){
        splashIndex += 1;
    }else{
        splashIndex = 0;
    }
    HGSplashService* splashService = [HGSplashService sharedService];
    splashImageView.alpha = 0.0;
    splashImageView.image = [splashService splashImageForUser:nil index:splashIndex];;
    
    [UIView animateWithDuration:kSplashChangeInterval/2 
                          delay:0.0 
                        options:UIViewAnimationOptionCurveEaseInOut 
                     animations:^{
                         splashTitleView.alpha = 0.0;
                     } 
                     completion:^(BOOL finished) {
                         splashTitleContentLabel.text = [splashService splashTitleForUser:nil index:splashIndex];
                         [UIView animateWithDuration:kSplashChangeInterval/2 
                                               delay:0.0 
                                             options:UIViewAnimationOptionCurveEaseInOut 
                                          animations:^{
                                              splashTitleView.alpha = 1.0;
                                          } 
                                          completion:^(BOOL finished) {
                                             
                                          }];
                     }];
    
    
    [UIView animateWithDuration:kSplashChangeInterval 
                          delay:0.0 
                        options:UIViewAnimationOptionCurveEaseInOut 
                     animations:^{
                         splashImageView.alpha = 1.0;
                     } 
                     completion:^(BOOL finished) {
                         UIImage* image = splashImageView.image;
                         self.view.backgroundColor = [UIColor colorWithPatternImage:[image imageWithScale:splashImageView.frame.size]];
                     }];*/
    if (accountReady == YES){
        [self gotoNextPage];
    }else{
        splashPlayTimer = nil;
    }
}

- (void)gotoNextPage{
    self.view.userInteractionEnabled = NO;
    [self.view.layer removeAllAnimations];
    if (splashPlayTimer != nil){
        [splashPlayTimer invalidate];
        splashPlayTimer = nil;
    }
    CGSize viewSize = self.view.bounds.size;
    UIGraphicsBeginImageContext(viewSize);
    
    CGContextScaleCTM( UIGraphicsGetCurrentContext(), 1.0f, 1.0f );
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage* curtainImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIImageView* curtainView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 20.0, viewSize.width, viewSize.height)];
    [curtainView setImage:curtainImage];
    
    HappyGiftAppDelegate *appDelegate = (HappyGiftAppDelegate *)[[UIApplication sharedApplication] delegate];
    UIWindow* appWindow = appDelegate.window;
    [appWindow addSubview:curtainView];
    [curtainView release];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber* preferneceTutorialLogin = [defaults objectForKey:kHGPreferneceKeyTutorialLogin];
    if (preferneceTutorialLogin != nil){
        HGMainViewController* mainViewController = [[HGMainViewController alloc] initWithNibName:@"HGMainViewController" bundle:nil];
        [self.navigationController pushViewController:mainViewController animated:NO];
        if  ([preferneceTutorialLogin boolValue] == YES){
            HGLoginViewController* loginViewController = [[HGLoginViewController alloc] initWithNibName:@"HGLoginViewController" bundle:nil];
            [mainViewController presentModalViewController:loginViewController animated:NO];
            [loginViewController release];
            [HGTrackingService logPageView];
        }
        [mainViewController release];
        [defaults removeObjectForKey:kHGPreferneceKeyTutorialLogin];
        [defaults synchronize];
    }else{
        HGMainViewController* mainViewController = [[HGMainViewController alloc] initWithNibName:@"HGMainViewController" bundle:nil];
        [self.navigationController pushViewController:mainViewController animated:NO];
        [mainViewController release];
    }
    
    if (appDelegate.remoteNotification != nil) {
        HGDebug(@"splash view - got notification");
    
        [HGTrackingService logEvent:kTrackingEventEnterSentGiftList withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"HGSplashViewController", @"from", nil]];

        HGPushNotificationEventType type = [HGPushNotificationService getNotificationEventType:appDelegate.remoteNotification];
        
        if (type == PUSH_NOTIFICATION_EVENT_TYPE_GIFT_ACCEPTED || 
            type == PUSH_NOTIFICATION_EVENT_TYPE_NEED_PAYMENT ||
            type == PUSH_NOTIFICATION_EVENT_TYPE_DELIVERED) {
        
            NSString* orderId = [HGPushNotificationService getNotificationOrderId:appDelegate.remoteNotification];
            HGGiftOrder* giftOrder = [[HGGiftOrder alloc] init];
            giftOrder.identifier = orderId;
            
            HGSentGiftDetailViewController* sentGiftDetailViewController = [[HGSentGiftDetailViewController alloc] initWithGiftOrder:giftOrder andShouldRefetchData:YES];
            [self.navigationController pushViewController:sentGiftDetailViewController animated:NO];
            [sentGiftDetailViewController release];
            [giftOrder release];
        }
        [[HGPushNotificationService sharedService] checkAndSetAllNotificationsAsRead];
        appDelegate.remoteNotification = nil;
    }
    
    [UIView animateWithDuration:0.3 
                          delay:0.0 
                        options:UIViewAnimationOptionCurveEaseInOut 
                     animations:^{
                         CGRect viewFrame = curtainView.frame;
                         viewFrame.origin.y = viewSize.height + 20.0;
                         curtainView.frame = viewFrame;
                     } 
                     completion:^(BOOL finished) {
                         [curtainView removeFromSuperview];
                     }];
}


#pragma mark  HGAccountServiceDelegate
- (void)accountService:(HGAccountService *)accountService didAccountCreateSucceed:(HGAccount*)account{
    [accountService addAccount:account];
    accountService.currentAccount = account;
    accountReady = YES;
    /*NSMutableDictionary *tokenCookie = [NSMutableDictionary dictionary];
    [tokenCookie setObject:[NSString stringWithFormat:@"user_id=%@;token=%@", accountService.currentAccount.userId, accountService.currentAccount.userToken] forKey:NSHTTPCookieValue];
    [tokenCookie setObject:[[NSDate date] dateByAddingTimeInterval:2629743] forKey:NSHTTPCookieExpires];
    NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:tokenCookie];
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];*/
    
    [[HGAppConfigurationService sharedService] requestAppConfiguration];
    HappyGiftAppDelegate *appDelegate = (HappyGiftAppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appDelegate.deviceToken != nil){
        [[HGPushNotificationService sharedService] requestRegisterDeviceToken:appDelegate.deviceToken];
    }
    
    if (splashPlayTimer == nil){
        [self gotoNextPage];
    }
}


- (void)accountService:(HGAccountService *)accountService didAccountCreateFail:(NSString*)error{
    if (splashPlayTimer != nil){
        [splashPlayTimer invalidate];
        splashPlayTimer = nil;
    }
    [progressView stopAnimation];
    
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"提示" 
                                                         message:@"登录乐送失败，请检查网络设置，稍后再试"
                                                        delegate:self 
                                               cancelButtonTitle:@"确定"
                                               otherButtonTitles:nil];
    [alertView show];
    [alertView release];
}

#pragma mark  UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    [progressView startAnimation];
    [self performSelector:@selector(handleCheckLoginAction) withObject:nil afterDelay:2.5];
}
@end

