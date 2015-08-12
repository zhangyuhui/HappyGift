//
//  HGLoginViewController.m
//  HappyGift
//
//  Created by Yujian Weng on 12-7-31.
//  Copyright 2011 Ztelic Inc Inc. All rights reserved.
//

#import "HGLoginViewController.h"
#import "HappyGiftAppDelegate.h"
#import "UIBarButtonItem+Addition.h"
#import "HGImageService.h"
#import "RenrenService.h"
#import "HGConstants.h"
#import "HGAccountService.h"
#import "UIImage+Addition.h"
#import "HGRenrenAuthViewController.h"
#import "HGMainViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "HGRecipientService.h"
#import "HGWeiBoAuth2ViewController.h"
#import "WBEngine.h"
#import "HGTrackingService.h"
#import "HGPushNotificationService.h"
#import "HGLogging.h"
#import <MessageUI/MessageUI.h>

#define kBindRenrenUser 2
#define kBindWeiboUser  1
#define kBindNothing    0

@interface HGLoginViewController () <HGWeiBoAuth2ViewControllerDelegate, HGRenrenAuthViewControllerDelegate, HGAccountServiceDelegate, HGRecipientServiceDelegate, UIGestureRecognizerDelegate>
@end

@implementation HGLoginViewController

#pragma mark - View lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [HappyGiftAppDelegate genericBackgroundColor];
    
    weiboUserIconImageView.image = [[[UIImage imageNamed:@"user_default.png"] imageWithScale:weiboUserIconImageView.frame.size] imageWithOutline:[HappyGiftAppDelegate imageFrameColor]];
    
    [weiboLoginButton addTarget:self action:@selector(handleWeiboLoginAction:) forControlEvents:UIControlEventTouchUpInside];
    
    renrenUserIconImageView.image = [[[UIImage imageNamed:@"user_default.png"] imageWithScale:renrenUserIconImageView.frame.size] imageWithOutline:[HappyGiftAppDelegate imageFrameColor]];
    
    [renrenLoginButton addTarget:self action:@selector(handleRenrenLoginAction:) forControlEvents:UIControlEventTouchUpInside];
    
    
    loginTitleLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:[HappyGiftAppDelegate fontSizeXXXXLarge]];
    
    loginDescriptionLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:[HappyGiftAppDelegate fontSizeSmall]];
    
    [startLesongButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [startLesongButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    startLesongButton.titleLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:[HappyGiftAppDelegate fontSizeXLarge]];
    [startLesongButton setTitle:[NSString stringWithFormat:@"开始乐送"] forState:UIControlStateNormal];
    
    UIImage* startLesongButtonBackgroundImage = [[UIImage imageNamed:@"gift_selection_button"] stretchableImageWithLeftCapWidth:5 topCapHeight:10];
    [startLesongButton setBackgroundImage:startLesongButtonBackgroundImage forState:UIControlStateNormal];
    
    [startLesongButton addTarget:self action:@selector(handleStartLesongAction:) forControlEvents:UIControlEventTouchUpInside];
    
    progressView = [[HGProgressView progressView:self.view.frame] retain];
    CGRect tmpFrame = progressView.overlayView.frame;
    tmpFrame.origin.y = 65;
    progressView.overlayView.frame = tmpFrame;
    tmpFrame = progressView.indicatorView.frame;
    tmpFrame.origin.y = 88;
    progressView.indicatorView.frame = tmpFrame;
    [self.view addSubview:progressView];
    progressView.hidden = YES;
    
    [self updateViewDisplay:NO];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}


- (void)dealloc{
    [contentScrollView release];
    [weiboAccountInfoView release];
    [weiboUserIconImageView release];
    [weiboUserNameLabel release];
    [progressView release];
    [loginAccount release];
    [renrenAccountInfoView release];
    [renrenUserIconImageView release];
    [renrenUserNameLabel release];
    [weiboLoginButton release];
    [renrenLoginButton release];
    
    HGAccountService* accountService = [HGAccountService sharedService];
    if (accountService.delegate == self) {
        accountService.delegate = nil;
    }
    
    HGRecipientService* recipientService = [HGRecipientService sharedService];
    if (recipientService.delegate == self) {
        recipientService.delegate = nil;
    }
    
    [super dealloc];
}

- (void)viewDidUnload{
    [super viewDidUnload];
    [progressView removeFromSuperview];
    [progressView release];
    progressView = nil;
}

- (void)handleStartLesongAction:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (void)handleWeiboLoginAction:(id)sender{
    if ([[WBEngine sharedWeibo] isLoggedIn] == NO){
        HGWeiBoAuth2ViewController *viewController = [[HGWeiBoAuth2ViewController alloc] initWithDelegate:self];
        [self presentModalViewController:viewController animated:YES];
        [viewController release];
        [HGTrackingService logPageView];
    }
}

- (void)handleRenrenLoginAction:(id)sender{
    if([[RenrenService sharedRenren] isSessionValid] == NO){
        HGRenrenAuthViewController *viewController = [[HGRenrenAuthViewController alloc] initWithDelegate:self];
        [self presentModalViewController:viewController animated:YES];
        [viewController release];
        [HGTrackingService logPageView];
    }
}

- (void)updateWeiboAccountDisplay {
    if ([[WBEngine sharedWeibo] isLoggedIn]) {
        HGAccount* currentAccount = [HGAccountService sharedService].currentAccount;
        weiboUserNameLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeLarge]];
        weiboUserNameLabel.text = currentAccount.weiBoUserName;
        weiboUserNameLabel.textColor = [UIColor whiteColor];
        
        CATransition *animation = [CATransition animation];
        [animation setType:kCATransitionFade];
        [animation setDuration:0.3];
        [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];   
        
        UIImage *imageData = nil;
        if (currentAccount.weiBoUserIconLarge && ![@"" isEqualToString:currentAccount.weiBoUserIconLarge]) {
            imageData = [[HGImageService sharedService] requestImage:currentAccount.weiBoUserIconLarge target:self selector:@selector(didImagesLoaded:)];
        }
        if (imageData != nil){
            weiboUserIconImageView.image = [imageData imageWithFrame:weiboUserIconImageView.frame.size color:[HappyGiftAppDelegate imageFrameColor]];
            
            CATransition *animation = [CATransition animation];
            [animation setType:kCATransitionFade];
            [animation setDuration:0.2];
            [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
            [weiboUserIconImageView.layer addAnimation:animation forKey:@"showWeiboUserImage"];
        }
        
        weiboAccountInfoView.hidden = NO;
        weiboLoginButton.hidden = YES;
        
    }else{
        weiboAccountInfoView.hidden = YES;
        weiboLoginButton.hidden = NO;
    }
}

- (void)updateRenrenAccountDisplay{
    HGAccount* currentAccount = [HGAccountService sharedService].currentAccount;
    if ([[RenrenService sharedRenren] isSessionValid]){
        renrenUserNameLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeLarge]];
        renrenUserNameLabel.text = currentAccount.renrenUserName;
        renrenUserNameLabel.textColor = [UIColor whiteColor];
        
        UIImage *imageData = nil;
        if (currentAccount.renrenUserIconLarge && ![@"" isEqualToString:currentAccount.renrenUserIconLarge]) {
            imageData = [[HGImageService sharedService] requestImage:currentAccount.renrenUserIconLarge target:self selector:@selector(didImagesLoaded:)];
        }
        
        if (imageData != nil){
            renrenUserIconImageView.image = [imageData imageWithFrame:renrenUserIconImageView.frame.size color:[HappyGiftAppDelegate imageFrameColor]];;
            
            CATransition *animation = [CATransition animation];
            [animation setType:kCATransitionFade];
            [animation setDuration:0.2];
            [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
            [renrenUserIconImageView.layer addAnimation:animation forKey:@"showRerenUserImage"];
        }
        
        renrenAccountInfoView.hidden = NO;
        renrenLoginButton.hidden = YES;
        
    }else{
        
        renrenAccountInfoView.hidden = YES;
        renrenLoginButton.hidden = NO;
    }
}

- (void)updateViewDisplay:(BOOL)animated{
    [self updateWeiboAccountDisplay];
    [self updateRenrenAccountDisplay];
    
    CGFloat viewY = 0;
    if (weiboAccountInfoView.hidden == YES){
        viewY = weiboLoginButton.frame.origin.y + weiboLoginButton.frame.size.height;
    }else{
        viewY = weiboAccountInfoView.frame.origin.y + weiboAccountInfoView.frame.size.height;
    }
    
    viewY += 14.0;
    
    if (renrenAccountInfoView.hidden == YES){
        CGRect renrenAccountLoginViewFrame = renrenLoginButton.frame;
        renrenAccountLoginViewFrame.origin.y = viewY;
        renrenLoginButton.frame = renrenAccountLoginViewFrame;
    }else{
        CGRect renrenAccountInfoViewFrame = renrenAccountInfoView.frame;
        renrenAccountInfoViewFrame.origin.y = viewY;
        renrenAccountInfoView.frame = renrenAccountInfoViewFrame;
    }
    
    if (animated == YES){
        CATransition *animation = [CATransition animation];
        [animation setType:kCATransitionFade];
        [animation setDuration:0.5];
        [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        [contentScrollView.layer addAnimation:animation forKey:@"updateViewDisplayAnimation"];
    }
    
    if ([[HGAccountService sharedService] hasSNSAccountLoggedIn]) {
        startLesongButton.hidden = NO;
    } else {
        startLesongButton.hidden = YES;
    }
}

#pragma mark  HGImagesService selector
- (void)didImagesLoaded:(HGImageData*)image{
    HGAccount* currentAccount = [HGAccountService sharedService].currentAccount;
    if ([image.url isEqualToString:currentAccount.renrenUserIconLarge]){
        renrenUserIconImageView.image = [image.image imageWithFrame:renrenUserIconImageView.frame.size color:[UIColor grayColor]];
        
        CATransition *animation = [CATransition animation];
        [animation setType:kCATransitionFade];
        [animation setDuration:0.2];
        [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        [renrenUserIconImageView.layer addAnimation:animation forKey:@"showRerenUserImage"];
    }else if ([image.url isEqualToString:currentAccount.weiBoUserIconLarge]){
        weiboUserIconImageView.image = [image.image imageWithFrame:weiboUserIconImageView.frame.size color:[UIColor grayColor]];
        
        CATransition *animation = [CATransition animation];
        [animation setType:kCATransitionFade];
        [animation setDuration:0.2];
        [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        [weiboUserIconImageView.layer addAnimation:animation forKey:@"showWeiboUserImage"];
    }
}

#pragma mark  HGWeiBoAuth2ViewControllerDelegate
- (void)weiBoAuth2ViewController:(HGWeiBoAuth2ViewController*)weiBoAuth2ViewController didWeiBoAuthSucceed:(HGAccount *)account{
    if (loginAccount != nil){
        [loginAccount release];
        loginAccount = nil;
    }
    loginAccount = [account retain];
    
    [progressView startAnimation];
    
    HGAccountService* accountService = [HGAccountService sharedService];
    accountService.delegate = self;
    loginAccount.userId = accountService.currentAccount.userId;
    loginAccount.userToken = accountService.currentAccount.userToken;
    loginAccount.userName = accountService.currentAccount.userName;
    loginAccount.userPhone = accountService.currentAccount.userPhone;
    loginAccount.userEmail = accountService.currentAccount.userEmail;
    
    loginAccount.renrenUserId = accountService.currentAccount.renrenUserId;
    loginAccount.renrenUserName = accountService.currentAccount.renrenUserName;
    loginAccount.renrenUserIcon = accountService.currentAccount.renrenUserIcon;
    loginAccount.renrenUserIconLarge = accountService.currentAccount.renrenUserIconLarge;
    loginAccount.renrenAuthToken = accountService.currentAccount.renrenAuthToken;
    loginAccount.renrenAuthSecret = accountService.currentAccount.renrenAuthSecret;
    
    bindUserRequestType = kBindWeiboUser;
    [accountService bindWeiboAccount:loginAccount andExpireTime:[WBEngine sharedWeibo].expireTime];
    
    
    [HGTrackingService logEvent:kTrackingEventLoginAccount withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"1", @"network", nil]];
}

- (void)weiBoAuth2ViewController:(HGWeiBoAuth2ViewController*)weiBoAuth2ViewController didWeiBoAuthFail:(NSString*)error{
    HappyGiftAppDelegate *appDelegate = (HappyGiftAppDelegate *)[[UIApplication sharedApplication] delegate];
    [[WBEngine sharedWeibo] logOut];
    [progressView stopAnimation];
    if (![error isEqualToString:@"cancel"]) {
        [appDelegate sendNotification:@"登录微博失败，请稍后再试"];
    }
}

#pragma mark  HGRenrenAuthViewControllerDelegate 
- (void)renrenAuthViewController:(HGRenrenAuthViewController*)renrenAuthViewController didRenrenAuthSucceed:(ROUserResponseItem*)renrenUser account:(HGAccount*)account{
    if (loginAccount != nil){
        [loginAccount release];
        loginAccount = nil;
    }
    loginAccount = [account retain];
    
    [progressView startAnimation];
    
    HGAccountService* accountService = [HGAccountService sharedService];
    accountService.delegate = self;
    
    loginAccount.userId = accountService.currentAccount.userId;
    loginAccount.userToken = accountService.currentAccount.userToken;
    loginAccount.userName = accountService.currentAccount.userName;
    loginAccount.userPhone = accountService.currentAccount.userPhone;
    loginAccount.userEmail = accountService.currentAccount.userEmail;
    
    loginAccount.weiBoUserId = accountService.currentAccount.weiBoUserId;
    loginAccount.weiBoUserName = accountService.currentAccount.weiBoUserName;
    loginAccount.weiBoUserDescription = accountService.currentAccount.weiBoUserDescription;
    loginAccount.weiBoUserSignature = accountService.currentAccount.weiBoUserSignature;
    loginAccount.weiBoUserIcon = accountService.currentAccount.weiBoUserIcon;
    loginAccount.weiBoUserIconLarge = accountService.currentAccount.weiBoUserIconLarge;
    loginAccount.weiBoAuthToken = accountService.currentAccount.weiBoAuthToken;
    loginAccount.weiBoAuthSecret = accountService.currentAccount.weiBoAuthSecret;
    loginAccount.weiBoAuthVerifier = accountService.currentAccount.weiBoAuthVerifier;
    loginAccount.weiboFavoriteCount = accountService.currentAccount.weiboFavoriteCount;
    loginAccount.weiboStatusCount = accountService.currentAccount.weiboStatusCount;
    loginAccount.weiboFollowersCount = accountService.currentAccount.weiboFollowersCount;
    loginAccount.weiboFriendsCount = accountService.currentAccount.weiboFriendsCount;
    
    bindUserRequestType = kBindRenrenUser;
    
    NSUInteger expireTime = [[[RenrenService sharedRenren] expirationDate]timeIntervalSince1970];
    [accountService bindRenrenAccount:loginAccount andExpireTime:expireTime];
    
    [HGTrackingService logEvent:kTrackingEventLoginAccount withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"2", @"network", nil]];
}

- (void)renrenAuthViewController:(HGRenrenAuthViewController*)renrenAuthViewController didRenrenAuthFail:(NSString*)error{
    [[RenrenService sharedRenren] logout:nil];
    [progressView stopAnimation];
    if (![@"cancel" isEqualToString:error]) {
        HappyGiftAppDelegate *appDelegate = (HappyGiftAppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate sendNotification:@"登录人人网失败，请稍后再试"];
    }
}

#pragma mark  HGAccountServiceDelegate
- (void)accountService:(HGAccountService *)accountService didAccountBindSucceed:(HGAccount*)account{
    if (![loginAccount.userId isEqualToString:account.userId]) {
        HGDebug(@"different userid: original: %@ new:%@", loginAccount.userId, account.userId);
        if (bindUserRequestType == kBindRenrenUser) {
            HGDebug(@"binding renren, should logout weibo");
            // logout weibo
            [[HGRecipientService sharedService] clearSNSRecipients:NETWORK_SNS_WEIBO];
            if ([[WBEngine sharedWeibo] isLoggedIn]){
                [[WBEngine sharedWeibo] logOut];
            }
        } else if (bindUserRequestType == kBindWeiboUser) {
            HGDebug(@"binding weibo, should logout renren");
            // logout renren
            [[HGRecipientService sharedService] clearSNSRecipients:NETWORK_SNS_RENREN];
            if ([[RenrenService sharedRenren] isSessionValid]){
                [[RenrenService sharedRenren] logout:nil];
            }
        }
        HGDebug(@"clear personalized cache");
        [accountService clearPersonalCache];
    }
    
    loginAccount.userId = account.userId;
    loginAccount.userToken = account.userToken;
    
    NSString* userName = accountService.currentAccount.userName;
    if (userName != nil && [userName isEqualToString:@""] == NO){
        account.userName = userName;
    }
    loginAccount.userName = account.userName;
    
    NSString* userEmail = accountService.currentAccount.userEmail;
    if (userEmail != nil && [userEmail isEqualToString:@""] == NO){
        account.userEmail = userEmail;
    }
    loginAccount.userEmail = account.userEmail;
    
    NSString* userPhone = accountService.currentAccount.userPhone;
    if (userPhone != nil && [userPhone isEqualToString:@""] == NO){
        account.userPhone = userPhone;
    }
    loginAccount.userPhone = account.userPhone;
    
    accountService.currentAccount = loginAccount;
    [accountService updateAccount:loginAccount];
    bindUserRequestType = kBindNothing;

    
    [self updateViewDisplay:YES];
    
    // request recipients data once after account bound;
    [HGRecipientService sharedService].delegate = self;
    [[HGRecipientService sharedService] requestRecipients];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kHGNotificationAccountUpdated object:nil];
    
    HappyGiftAppDelegate *appDelegate = (HappyGiftAppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appDelegate.deviceToken != nil){
        [[HGPushNotificationService sharedService] requestRegisterDeviceToken:appDelegate.deviceToken];
    }
    
    if ([[HGAccountService sharedService] isAllSNSAccountLoggedIn]) {
        [self dismissModalViewControllerAnimated:YES];
    } else {
        
        loginTitleLabel.text = @"多账号同时登陆，重要时刻再不遗漏！";
        loginTitleLabel.numberOfLines = 0;
        CGSize labelSize = [loginTitleLabel.text sizeWithFont:loginTitleLabel.font constrainedToSize:CGSizeMake(loginTitleLabel.frame.size.width, 100.0)];
        CGRect tmpFrame = loginTitleLabel.frame;
        tmpFrame.size.height = labelSize.height;
        loginTitleLabel.frame = tmpFrame;
    }
}

- (void)accountService:(HGAccountService *)accountService didAccountBindFail:(NSString*)error{
    HappyGiftAppDelegate *appDelegate = (HappyGiftAppDelegate *)[[UIApplication sharedApplication] delegate];
    if (bindUserRequestType == kBindRenrenUser){
        [[RenrenService sharedRenren] logout:nil];
        [appDelegate sendNotification:@"登录人人网失败，请稍后再试"];
    }else if (bindUserRequestType == kBindWeiboUser){
        [[WBEngine sharedWeibo] logOut];
        [appDelegate sendNotification:@"登录微博失败，请稍后再试"];
    }
    bindUserRequestType = kBindNothing;
    [progressView stopAnimation];
}

- (void) didRequestRecipientsSucceed:(NSArray*)recipients {
    [progressView stopAnimation];
}

- (void) didRequestRecipientsFail:(NSString*)error {
    [progressView stopAnimation];
}

- (void)accountService:(HGAccountService *)accountService didAccountCreateSucceed:(HGAccount*)account{
    [accountService addAccount:account];
    accountService.currentAccount = account;
    
    HappyGiftAppDelegate *appDelegate = (HappyGiftAppDelegate *)[[UIApplication sharedApplication] delegate];
    if ([[WBEngine sharedWeibo] isLoggedIn]){
        [[WBEngine sharedWeibo] logOut];
    }
    if ([[RenrenService sharedRenren] isSessionValid]){
        [[RenrenService sharedRenren] logout:nil];
    }    
    
    [self updateViewDisplay:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:kHGNotificationAccountUpdated object:nil];
    
    [progressView stopAnimation];
    
    if (appDelegate.deviceToken != nil){
        [[HGPushNotificationService sharedService] requestRegisterDeviceToken:appDelegate.deviceToken];
    }
}

- (void)accountService:(HGAccountService *)accountService didAccountCreateFail:(NSString*)error{
    [progressView stopAnimation];
}

@end
