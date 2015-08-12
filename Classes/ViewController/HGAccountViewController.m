//
//  HGAccountViewController.m
//  HappyGift
//
//  Created by Yuhui Zhang on 8/21/11.
//  Copyright 2011 Ztelic Inc. All rights reserved.
//

#import "HGAccountViewController.h"
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
#import "HGAboutViewController.h"
#import "HGFeedbackViewController.h"
#import "HGContactInfoViewController.h"
#import "HGPushNotificationService.h"
#import "HGLogging.h"
#import "HGGiftCollectionService.h"
#import "HGFriendRecommandationService.h"
#import "HGGiftOrderService.h"
#import "HGLoaderCache.h"
#import "HGGiftSetsService.h"
#import "HGMyLikesViewController.h"
#import "HGShareViewController.h"
#import "HGCreditService.h"
#import "HGTutorialViewController.h"
#import "HGRecipientSelectionViewController.h"
#import "HGSentGiftsViewController.h"
#import <MessageUI/MessageUI.h>

#define kBindRenrenUser 2
#define kBindWeiboUser  1
#define kBindNothing    0

#define kRecommendActionWeibo   0
#define kRecommendActionRenren  1
#define kRecommendActionMessage 2
#define kRecommendActionEmail   3
#define kRecommendActionCancel  4

@interface HGAccountViewController () <HGWeiBoAuth2ViewControllerDelegate, HGRenrenAuthViewControllerDelegate, HGAccountServiceDelegate, HGRecipientServiceDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate, HGCreditServiceDelegate, HGRecipientSelectionViewControllerDelegate, UIGestureRecognizerDelegate>

@end

@implementation HGAccountViewController
@synthesize delegate;

- (id)initWithLoginNetwork:(int)network{
    self = [super initWithNibName:@"HGAccountViewController" bundle:nil];
    if (self){
        launchForLogin = YES;
        launchForLoginNetwork = network;
    }
    return self;
}

#pragma mark - View lifecycle
- (void)viewDidLoad{
    [super viewDidLoad];
    self.view.backgroundColor = [HappyGiftAppDelegate genericBackgroundColor];
    
    leftBarButtonItem = [[UIBarButtonItem alloc ] initNavigationBackImageBarButtonItem:@"navigation_back" target:self action:@selector(handleCancelAction:)];
    navigationBar.topItem.leftBarButtonItem = leftBarButtonItem; 
    navigationBar.topItem.rightBarButtonItem = nil;
    
    CGRect titleViewFrame = CGRectMake(20, 0, 180, 44);
    UIView* titleView = [[UIView alloc] initWithFrame:titleViewFrame];
    
    CGRect titleLabelFrame = CGRectMake(0, 0, 180, 40);
	UILabel *titleLabel = [[UILabel alloc] initWithFrame:titleLabelFrame];
	titleLabel.backgroundColor = [UIColor clearColor];
	titleLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:[HappyGiftAppDelegate naviagtionTitleFontSize]];
    titleLabel.minimumFontSize = 20.0;
    titleLabel.adjustsFontSizeToFitWidth = YES;
	titleLabel.textAlignment = UITextAlignmentCenter;
	titleLabel.textColor = [UIColor whiteColor];
	titleLabel.text = @"个人中心";
    [titleView addSubview:titleLabel];
    [titleLabel release];
    
	navigationBar.topItem.titleView = titleView;
    [titleView release];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString* accountTutorialShown = [defaults stringForKey:kHGPreferenceKeyAccountTutorialShown];

    if (accountTutorialShown == nil && ![[HGAccountService sharedService] isAllSNSAccountLoggedIn]) {
        CGRect frame = CGRectMake(0, 0, 320, 460);
        accountTutorialView = [[UIImageView alloc] initWithFrame:frame];
        UIImage* tutorialImage = [UIImage imageNamed:@"account_tutorial"];
        accountTutorialView.image = tutorialImage;
        [accountTutorialView setUserInteractionEnabled:YES];
        
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(handleAccountTutorialTap:)];
        tapGestureRecognizer.numberOfTapsRequired = 1;
        tapGestureRecognizer.numberOfTouchesRequired = 1;
        tapGestureRecognizer.delegate = self;
        [accountTutorialView addGestureRecognizer:tapGestureRecognizer];
        [tapGestureRecognizer release];
        
        [self.view addSubview:accountTutorialView];
        [defaults setObject:@"1" forKey:kHGPreferenceKeyAccountTutorialShown];
        [defaults synchronize];
    }
    
    weiboLogoutButton.hidden = YES;
    weiboLogoutButton.titleLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:[HappyGiftAppDelegate fontSizeXLarge]];
    [weiboLogoutButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [weiboLogoutButton setTitleColor:[UIColor grayColor] forState:UIControlStateSelected];
    [weiboLogoutButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [weiboLogoutButton addTarget:self action:@selector(handleWeiboLogoutAction:) forControlEvents:UIControlEventTouchUpInside];
    [weiboLogoutButton setTitle:@"退出" forState:UIControlStateNormal];
    [weiboLogoutButton setTitle:@"退出" forState:UIControlStateSelected];
    [weiboLogoutButton setTitle:@"退出" forState:UIControlStateHighlighted];
    
    weiboUserIconImageView.image = [[[UIImage imageNamed:@"user_default.png"] imageWithScale:weiboUserIconImageView.frame.size] imageWithOutline:[HappyGiftAppDelegate imageFrameColor]];
    
    weiboLoginLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:[HappyGiftAppDelegate fontSizeXLarge]];
    weiboLoginLabel.textColor = [UIColor blackColor];
    weiboLoginLabel.text = @"新浪微博登录";
    
    [weiboLoginButton addTarget:self action:@selector(handleWeiboLoginAction:) forControlEvents:UIControlEventTouchUpInside];
    
    renrenLogoutButton.hidden = YES;
    renrenLogoutButton.titleLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:[HappyGiftAppDelegate fontSizeXLarge]];
    [renrenLogoutButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [renrenLogoutButton setTitleColor:[UIColor grayColor] forState:UIControlStateSelected];
    [renrenLogoutButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [renrenLogoutButton addTarget:self action:@selector(handleRenrenLogoutAction:) forControlEvents:UIControlEventTouchUpInside];
    [renrenLogoutButton setTitle:@"退出" forState:UIControlStateNormal];
    [renrenLogoutButton setTitle:@"退出" forState:UIControlStateSelected];
    [renrenLogoutButton setTitle:@"退出" forState:UIControlStateHighlighted];
    
    renrenUserIconImageView.image = [[[UIImage imageNamed:@"user_default.png"] imageWithScale:renrenUserIconImageView.frame.size] imageWithOutline:[HappyGiftAppDelegate imageFrameColor]];
    
    renrenLoginLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:[HappyGiftAppDelegate fontSizeXLarge]];
    renrenLoginLabel.textColor = [UIColor blackColor];
    renrenLoginLabel.text = @"人人网登录";
    
    [renrenLoginButton addTarget:self action:@selector(handleRenrenLoginAction:) forControlEvents:UIControlEventTouchUpInside];
    
    clearCacheButton.titleLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:[HappyGiftAppDelegate fontSizeXLarge]];
    [clearCacheButton setTitle:[NSString stringWithFormat:@"清理缓存"] forState:UIControlStateNormal];
    [clearCacheButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 198)];
    
    [clearCacheButton setBackgroundImage:[UIImage imageNamed:@"setting_background"] forState:UIControlStateNormal];
    [clearCacheButton addTarget:self action:@selector(handleClearCacheAction:) forControlEvents:UIControlEventTouchUpInside];
    
    
    [globalLogoutButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [globalLogoutButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    globalLogoutButton.titleLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:[HappyGiftAppDelegate fontSizeXLarge]];
    [globalLogoutButton setTitle:[NSString stringWithFormat:@"退出帐号"] forState:UIControlStateNormal];
    
    UIImage* globalLogoutButtonBackgroundImage = [[UIImage imageNamed:@"gift_selection_button"] stretchableImageWithLeftCapWidth:5 topCapHeight:10];
    [globalLogoutButton setBackgroundImage:globalLogoutButtonBackgroundImage forState:UIControlStateNormal];
    
    [globalLogoutButton addTarget:self action:@selector(handleGlobalLogoutAction:) forControlEvents:UIControlEventTouchUpInside];
    
    
    contactLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:[HappyGiftAppDelegate fontSizeXLarge]];
    contactLabel.textColor = [UIColor blackColor];
    contactLabel.text = @"个人信息";
    
    [contactButton addTarget:self action:@selector(handleContactAction:) forControlEvents:UIControlEventTouchUpInside];
    
    myLikesLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:[HappyGiftAppDelegate fontSizeXLarge]];
    myLikesLabel.textColor = [UIColor blackColor];
    myLikesLabel.text = @"我的喜欢";
    
    [myLikesButton addTarget:self action:@selector(handleMyLikesAction:) forControlEvents:UIControlEventTouchUpInside];
    
    myGiftsLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:[HappyGiftAppDelegate fontSizeXLarge]];
    myGiftsLabel.textColor = [UIColor blackColor];
    myGiftsLabel.text = @"已送出的礼物";
    
    [myGiftsButton addTarget:self action:@selector(handleMyGiftsAction:) forControlEvents:UIControlEventTouchUpInside];
    
    aboutLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:[HappyGiftAppDelegate fontSizeXLarge]];
    aboutLabel.textColor = [UIColor blackColor];
    aboutLabel.text = @"关于我们";
    
    [aboutButton addTarget:self action:@selector(handleAboutAction:) forControlEvents:UIControlEventTouchUpInside];
    
    tutorialLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:[HappyGiftAppDelegate fontSizeXLarge]];
    tutorialLabel.textColor = [UIColor blackColor];
    tutorialLabel.text = @"如何乐送";
    
    [tutorialButton addTarget:self action:@selector(handleTutorialAction:) forControlEvents:UIControlEventTouchUpInside];
    
    feedbackLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:[HappyGiftAppDelegate fontSizeXLarge]];
    feedbackLabel.textColor = [UIColor blackColor];
    feedbackLabel.text = @"意见反馈";
    
    [feedbackButton addTarget:self action:@selector(handleFeedbackAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [recommendButton addTarget:self action:@selector(handleRecommendAction:) forControlEvents:UIControlEventTouchUpInside];
    
    recommendLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:[HappyGiftAppDelegate fontSizeXLarge]];
    recommendLabel.textColor = [UIColor blackColor];
    recommendLabel.text = @"推乐送赢积分";
    
    progressView = [[HGProgressView progressView:self.view.frame] retain];
    [self.view addSubview:progressView];
    progressView.hidden = YES;
    
    recommendRecipientSelected = NO;
    
    [self updateViewDisplay:NO];
    
    if (launchForLogin == YES){
        HappyGiftAppDelegate *appDelegate = (HappyGiftAppDelegate *)[[UIApplication sharedApplication] delegate];
        UIImageView* fakeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 460.0)];
        fakeImageView.contentMode = UIViewContentModeBottom;
        UIGraphicsBeginImageContext(CGSizeMake(320.0, 480.0));
        CGContextScaleCTM( UIGraphicsGetCurrentContext(), 1.0f, 1.0f );
        [appDelegate.window.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage* fakeImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        fakeImageView.userInteractionEnabled = YES;
        [fakeImageView setImage:fakeImage];
        [self.view addSubview:fakeImageView];
        [fakeImageView release];
        [self.view bringSubviewToFront:progressView];
        launchForLoginBindRequest = YES;
        launchForLoginBindCancel = NO;
    }
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (recommendRecipientSelected == YES){
        recommendRecipientSelected = NO;
        
        [progressView startAnimation];
        HGCreditService* creditService = [HGCreditService sharedService];
        creditService.delegate = self;
        if (recommendAction == kRecommendActionMessage){
            [creditService requestInvitation:recommendRecipient type:HGCreditInvitationTypeMessage];
        }else if (recommendAction == kRecommendActionEmail){
            [creditService requestInvitation:recommendRecipient type:HGCreditInvitationTypeEmail];
        }
    }
    if (launchForLogin){
        if (launchForLoginBindRequest == YES){
            launchForLoginBindRequest = NO;
            if (launchForLoginNetwork == NETWORK_SNS_WEIBO){
                [self handleWeiboLoginAction:nil];
            }else if (launchForLoginNetwork == NETWORK_SNS_RENREN){
                [self handleRenrenLoginAction:nil];
            }else{
                [self handleCancelAction:nil];
            }
        }else if (launchForLoginBindCancel == YES){
            launchForLoginBindCancel = NO;
            [self handleCancelAction:nil];
        }
    }
}


- (void)dealloc{
    [contentScrollView release];
    [weiboAccountInfoView release];
    [weiboLogoutButton release];
    [weiboUserIconImageView release];
    [weiboUserNameLabel release];
    [navigationBar release];
    [progressView release];
    [loginAccount release];
    [leftBarButtonItem release];
    [renrenAccountInfoView release];
    [renrenLogoutButton release];
    [renrenUserIconImageView release];
    [renrenUserNameLabel release];
    [weiboAccountLoginView release];
    [renrenAccountLoginView release];
    [weiboLoginButton release];
    [renrenLoginButton release];
    [renrenLoginLabel release];
    [weiboLoginLabel release];
    [rightBarButtonItem release];
    [aboutView release];
    [aboutButton release];
    [aboutLabel release];
    [feedbackView release];
    [feedbackButton release];
    [feedbackLabel release];
    [contactView release];
    [contactButton release];
    [contactLabel release];
    [recommendView release];
    [recommendButton release];
    [recommendLabel release];
    [mailViewController release];
    [messageViewController release];
    [recommendRecipient release];
    [tutorialView release];
    [tutorialButton release];
    [tutorialLabel release];
    
    if (accountTutorialView) {
        [accountTutorialView removeFromSuperview];
        [accountTutorialView release];
        accountTutorialView = nil;
    }
    
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
    [leftBarButtonItem release];
    leftBarButtonItem = nil;
}

- (void)handleAccountTutorialTap:(id)sender {
    if (accountTutorialView) {
        [accountTutorialView removeFromSuperview];
        [accountTutorialView release];
        accountTutorialView = nil;
    }
}

- (void)handleCancelAction:(id)sender {
    HappyGiftAppDelegate *appDelegate = (HappyGiftAppDelegate *)[[UIApplication sharedApplication] delegate];
    if (bindUserRequestType == kBindRenrenUser) {
        [[RenrenService sharedRenren] logout:nil];
        [appDelegate sendNotification:@"登录人人网已取消"];
    }else if (bindUserRequestType == kBindWeiboUser) {
        [[WBEngine sharedWeibo] logOut];
        [appDelegate sendNotification:@"登录微博已取消"];
    }
    
    HGCreditService* creditService = [HGCreditService sharedService];
    creditService.delegate = nil;
    
    if (launchForLogin){
        [self dismissModalViewControllerAnimated:NO];
    }else{
        [self dismissModalViewControllerAnimated:YES];
    }
}

- (void)handleSettingAction:(id)sender{
}

- (void)handleClearCacheAction:(id)sender {
    [progressView startAnimation];
    [self performSelectorInBackground:@selector(clearCacheData) withObject:nil];
}

- (void)clearCacheData {
    [HGLoaderCache clearAllCacheData];
    [[HGImageService sharedService] clearAllHistory];
    [self performSelectorOnMainThread:@selector(didClearCacheData) withObject:nil waitUntilDone:NO];
}

- (void)didClearCacheData {
    [progressView stopAnimation];
}

- (void)handleGlobalLogoutAction:(id)sender {
    [progressView startAnimation];
    HGAccountService* accountService = [HGAccountService sharedService];
    accountService.delegate = self;
    [accountService unbindSNSAccount:NETWORK_ALL_SNS andProfileId:nil];
    
    if ([delegate respondsToSelector:@selector(didGlobalLogout)]) {
        [delegate didGlobalLogout];
    }

    [HGTrackingService logEvent:kTrackingEventLogoutAccount withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"all", @"network", nil]];
}

- (void)handleWeiboLogoutAction:(id)sender{
    if ([[WBEngine sharedWeibo] isLoggedIn]){
        [self unbindSNSAccount:NETWORK_SNS_WEIBO];
        [HGTrackingService logEvent:kTrackingEventLogoutAccount withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"1", @"network", nil]];
    }
}

- (void)handleWeiboLoginAction:(id)sender{
    if ([[WBEngine sharedWeibo] isLoggedIn] == NO){
        HGWeiBoAuth2ViewController *viewController = [[HGWeiBoAuth2ViewController alloc] initWithDelegate:self];
        [self presentModalViewController:viewController animated:YES];
        [viewController release];
        [HGTrackingService logPageView];
    }
}

- (void)handleRenrenLogoutAction:(id)sender{
    if([[RenrenService sharedRenren] isSessionValid]){
        [self unbindSNSAccount:NETWORK_SNS_RENREN];
        [HGTrackingService logEvent:kTrackingEventLogoutAccount withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"2", @"network", nil]];
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

- (void)handleAboutAction:(id)sender{
    HGAboutViewController* viewController = [[HGAboutViewController alloc] initWithNibName:@"HGAboutViewController" bundle:nil];
    [self presentModalViewController:viewController animated:YES];
    [viewController release];
    [HGTrackingService logPageView];
}

- (void)handleFeedbackAction:(id)sender{
    HGFeedbackViewController* viewController = [[HGFeedbackViewController alloc] initWithNibName:@"HGFeedbackViewController" bundle:nil];
    [self presentModalViewController:viewController animated:YES];
    [viewController release];
    [HGTrackingService logPageView];
}

- (void)handleRecommendAction:(id)sender{
    if (![[HGAccountService sharedService] hasSNSAccountLoggedIn]) {
        HappyGiftAppDelegate *appDelegate = (HappyGiftAppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate sendNotification:@"请先登录微博或社交平台，向您的好友推荐使用乐送赢取相应积分。"];
    } else {    
        UIActionSheet *actionSheet = [[UIActionSheet alloc] 
                                      initWithTitle:nil
                                      delegate:self 
                                      cancelButtonTitle:@"取消" 
                                      destructiveButtonTitle:nil 
                                      otherButtonTitles:@"短信推荐好友", @"邮件推荐好友", nil];
        
        [actionSheet showInView:self.view];
        [actionSheet release];
    }
}

- (void)handleContactAction:(id)sender{
    if (![[HGAccountService sharedService] hasSNSAccountLoggedIn]) {
        HappyGiftAppDelegate *appDelegate = (HappyGiftAppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate sendNotification:@"请先登录微博或社交平台。"];
    } else {  
        HGContactInfoViewController* viewController = [[HGContactInfoViewController alloc] initWithGiftOrder:nil];
        [self presentModalViewController:viewController animated:YES];
        [viewController release];
        [HGTrackingService logPageView];
    }
}

- (void)handleMyLikesAction:(id)sender {
    if (![[HGAccountService sharedService] hasSNSAccountLoggedIn]) {
        HappyGiftAppDelegate *appDelegate = (HappyGiftAppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate sendNotification:@"请先登录微博或社交平台。"];
    } else {  
        [HGTrackingService logEvent:kTrackingEventEnterMyLikes withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"HGAccountViewController", @"from", nil]];
        
        HGMyLikesViewController* viewController = [[HGMyLikesViewController alloc] init];
        
        UINavigationController* navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
        [navigationController setNavigationBarHidden:YES];
        
        [viewController release];
        
        [HGTrackingService logAllPageViews:navigationController];
        [self presentModalViewController:navigationController animated:YES];
        [navigationController release];
    }
}

- (void)handleMyGiftsAction:(id)sender{
    if (![[HGAccountService sharedService] hasSNSAccountLoggedIn]) {
        HappyGiftAppDelegate *appDelegate = (HappyGiftAppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate sendNotification:@"请先登录微博或社交平台。"];
    } else {  
        HGSentGiftsViewController* viewController = [[HGSentGiftsViewController alloc] initWithNibName:@"HGSentGiftsViewController" bundle:nil];
 
        UINavigationController* navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
        [navigationController setNavigationBarHidden:YES];
        [viewController release];
        
        [HGTrackingService logAllPageViews:navigationController];
        [self presentModalViewController:navigationController animated:YES];
        [navigationController release];
    }
}

- (void)handleTutorialAction:(id)sender {
    HGTutorialViewController* viewController = [[HGTutorialViewController alloc] initWithNibName:@"HGTutorialViewController" bundle:nil];
    [self presentModalViewController:viewController animated:YES];
    [viewController release];
    [HGTrackingService logPageView];
}

- (void)updateWeiboAccountDisplay {
    if ([[WBEngine sharedWeibo] isLoggedIn]) {
        HGAccount* currentAccount = [HGAccountService sharedService].currentAccount;
        
        NSString* nameDisplay = currentAccount.weiBoUserName;
        CGFloat nameLabelFontSize = 22.0;
        UIFont* nameLabelFont = nil;
        CGSize userNameLabelSize = CGSizeZero;
        while (nameLabelFontSize >= 16.0) {
            nameLabelFont = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:nameLabelFontSize];
            userNameLabelSize = [nameDisplay sizeWithFont:nameLabelFont constrainedToSize:CGSizeMake(weiboUserNameLabel.frame.size.width, 60.0) lineBreakMode:UILineBreakModeClip];
            CGSize userNameLableLineSize = [@"A" sizeWithFont:nameLabelFont constrainedToSize:CGSizeMake(weiboUserNameLabel.frame.size.width, 60.0) lineBreakMode:UILineBreakModeClip];
            if (userNameLabelSize.height > userNameLableLineSize.height){
                nameLabelFontSize -= 1;
            }else{
                break;
            }
        }
        weiboUserNameLabel.font = nameLabelFont;
        weiboUserNameLabel.numberOfLines = 1;
        weiboUserNameLabel.text = nameDisplay;
        CGRect userNameLabelFrame = weiboUserNameLabel.frame;
        userNameLabelFrame.size.height = userNameLabelSize.height;
        weiboUserNameLabel.frame = userNameLabelFrame;
        
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
        weiboAccountLoginView.hidden = YES;
        
    }else{
        weiboAccountInfoView.hidden = YES;
        weiboAccountLoginView.hidden = NO;
    }
}

- (void)updateRenrenAccountDisplay{
    HGAccount* currentAccount = [HGAccountService sharedService].currentAccount;
    if ([[RenrenService sharedRenren] isSessionValid]){
        NSString* nameDisplay = currentAccount.renrenUserName;
        CGFloat nameLabelFontSize = 22.0;
        UIFont* nameLabelFont = nil;
        CGSize userNameLabelSize = CGSizeZero;
        while (nameLabelFontSize >= 16.0) {
            nameLabelFont = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:nameLabelFontSize];
            userNameLabelSize = [nameDisplay sizeWithFont:nameLabelFont constrainedToSize:CGSizeMake(weiboUserNameLabel.frame.size.width, 60.0) lineBreakMode:UILineBreakModeClip];
            CGSize userNameLableLineSize = [@"A" sizeWithFont:nameLabelFont constrainedToSize:CGSizeMake(weiboUserNameLabel.frame.size.width, 60.0) lineBreakMode:UILineBreakModeClip];
            if (userNameLabelSize.height > userNameLableLineSize.height){
                nameLabelFontSize -= 1;
            }else{
                break;
            }
        }
        renrenUserNameLabel.font = nameLabelFont;
        renrenUserNameLabel.numberOfLines = 1;
        renrenUserNameLabel.text = nameDisplay;
        CGRect renrenUserNameLabelFrame = renrenUserNameLabel.frame;
        renrenUserNameLabelFrame.size.height = userNameLabelSize.height;
        renrenUserNameLabel.frame = renrenUserNameLabelFrame;
        
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
        renrenAccountLoginView.hidden = YES;
        
    }else{
        
        renrenAccountInfoView.hidden = YES;
        renrenAccountLoginView.hidden = NO;
    }
}

- (void)updateViewDisplay:(BOOL)animated{
    [self updateWeiboAccountDisplay];
    [self updateRenrenAccountDisplay];
    
    CGFloat viewY = 0;
    if (weiboAccountInfoView.hidden == YES){
        viewY = weiboAccountLoginView.frame.origin.y + weiboAccountLoginView.frame.size.height + 2.0;
    }else{
        viewY = weiboAccountInfoView.frame.origin.y + weiboAccountInfoView.frame.size.height + 2.0;
    }
    
    if (renrenAccountInfoView.hidden == YES){
        CGRect renrenAccountLoginViewFrame = renrenAccountLoginView.frame;
        renrenAccountLoginViewFrame.origin.y = viewY;
        renrenAccountLoginView.frame = renrenAccountLoginViewFrame;
        viewY += renrenAccountLoginViewFrame.size.height + 2.0;
    }else{
        CGRect renrenAccountInfoViewFrame = renrenAccountInfoView.frame;
        renrenAccountInfoViewFrame.origin.y = viewY;
        renrenAccountInfoView.frame = renrenAccountInfoViewFrame;
        viewY += renrenAccountInfoViewFrame.size.height + 2.0;
    }
    
    viewY += 8.0;
    
    CGRect contactViewFrame = contactView.frame;
    contactViewFrame.origin.y = viewY;
    contactView.frame = contactViewFrame;
    viewY += contactViewFrame.size.height + 2.0;
    
    CGRect myLikesViewFrame = myLikesView.frame;
    myLikesViewFrame.origin.y = viewY;
    myLikesView.frame = myLikesViewFrame;
    viewY += myLikesViewFrame.size.height + 2.0;
    
    CGRect myGiftsViewFrame = myGiftsView.frame;
    myGiftsViewFrame.origin.y = viewY;
    myGiftsView.frame = myGiftsViewFrame;
    viewY += myGiftsViewFrame.size.height + 2.0;
    
    CGRect recommendViewFrame = recommendView.frame;
    recommendViewFrame.origin.y = viewY;
    recommendView.frame = recommendViewFrame;
    viewY += recommendViewFrame.size.height + 2.0;
    
    viewY += 8.0;
    
    CGRect aboutViewFrame = aboutView.frame;
    aboutViewFrame.origin.y = viewY;
    aboutView.frame = aboutViewFrame;
    viewY += aboutViewFrame.size.height + 2.0;   
    
    CGRect tutorialViewFrame = tutorialView.frame;
    tutorialViewFrame.origin.y = viewY;
    tutorialView.frame = tutorialViewFrame;
    viewY += tutorialViewFrame.size.height + 2.0; 
    
    CGRect feedbackViewFrame = feedbackView.frame;
    feedbackViewFrame.origin.y = viewY;
    feedbackView.frame = feedbackViewFrame;
    viewY += feedbackViewFrame.size.height + 2.0; 
    
    CGRect clearCacheButtonFrame = clearCacheButton.frame;
    clearCacheButtonFrame.origin.y = viewY;
    clearCacheButton.frame = clearCacheButtonFrame;
    viewY += clearCacheButtonFrame.size.height + 2.0;
    
    viewY += 8.0;
    
    if ([[HGAccountService sharedService] hasSNSAccountLoggedIn]) {
        globalLogoutButton.hidden = NO;
        CGRect globalLogoutButtonFrame = globalLogoutButton.frame;
        globalLogoutButtonFrame.origin.y = viewY;
        globalLogoutButton.frame = globalLogoutButtonFrame;
        
        viewY += globalLogoutButtonFrame.size.height + 10.0;
    } else {
        globalLogoutButton.hidden = YES;
    }
    
    CGSize contentSize = contentScrollView.contentSize;
    if (viewY <= contentScrollView.frame.size.height){
        viewY = contentScrollView.frame.size.height + 1.0;
    }
    contentSize.height = viewY;
    contentScrollView.contentSize = contentSize;
    
    if (animated == YES){
        CATransition *animation = [CATransition animation];
        [animation setType:kCATransitionFade];
        [animation setDuration:0.5];
        [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        [contentScrollView.layer addAnimation:animation forKey:@"updateViewDisplayAnimation"];
    }
}

//- (void)logoutAccount{
//    [progressView startAnimation];
//    HGAccountService* accountService = [HGAccountService sharedService];
//    accountService.delegate = self;
//    [accountService createAccount];
//}

- (void)unbindSNSAccount:(int)networkId {
    HGAccount* currentAccount = [HGAccountService sharedService].currentAccount;
    NSString* profileId = nil;
    if (networkId == NETWORK_SNS_WEIBO) {
        profileId = currentAccount.weiBoUserId;
    } else if (networkId == NETWORK_SNS_RENREN) {
        profileId = currentAccount.renrenUserId;
    }
    
    if (profileId && ![@"" isEqualToString:profileId]) {
        [progressView startAnimation];
        HGAccountService* accountService = [HGAccountService sharedService];
        accountService.delegate = self;
        [accountService unbindSNSAccount:networkId andProfileId:profileId];
    } else {
        [[HGAccountService sharedService] localLogout:networkId];
        [self updateViewDisplay:YES];
    }
}

- (void)recommedAppByMessage:(HGRecipient*)recipient invitation:(NSString*)invitation{
    if ([MFMessageComposeViewController canSendText]) {   
        messageViewController = [[MFMessageComposeViewController alloc] init];   
        messageViewController.messageComposeDelegate = self; 
        messageViewController.navigationBar.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"navigation_background"]];
        [messageViewController setBody:[NSString stringWithFormat:@"%@，我向你推荐乐送，这里有精美的礼品和最热的好友，现在下载并使用邀请码 %@ 可以领取积分呦！%@", recipient.recipientName, invitation, @"http://itunes.apple.com/cn/app/le-song/id537116971?ls=1&mt=8"]]; 
        if (recipient.recipientPhone != nil && [recipient.recipientPhone isEqualToString:@""] == NO){
            [messageViewController setRecipients:[NSArray arrayWithObject:recipient.recipientPhone]];
        }
        [self presentModalViewController:messageViewController animated:YES]; 
        [HGTrackingService logPageView];
    }else {   
        HappyGiftAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
        [appDelegate sendNotification:@"您的设备不支持发送短信"];  
    } 
}

- (void)recommedAppByEmail:(HGRecipient*)recipient invitation:(NSString*)invitation{
    if ([MFMailComposeViewController canSendMail]) {
		mailViewController = [[MFMailComposeViewController alloc] init];
        mailViewController.mailComposeDelegate = self;
        mailViewController.navigationBar.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"navigation_background"]];
        mailViewController.modalPresentationStyle = UIModalPresentationFormSheet;
        NSString *message = [NSString stringWithFormat:@"%@，我向你推荐乐送，这里有精美的礼品和最热的好友，现在下载并使用邀请码 %@ 可以领取积分呦！%@ \n---------------------------------------------- \n关于乐送\n乐送是一款即时创意礼品赠送手机应用。乐送帮助用户随时随地发现亲朋好友的重要时刻，并运用其专利所有的智能推荐技术，根据赠送对象的行为数据即时奉上精心挑选的礼品。\n还等什么快去看看你的礼物吧\n ----------------------------------------------", recipient.recipientName, invitation, @"http://itunes.apple.com/cn/app/le-song/id537116971?ls=1&mt=8"];
        [mailViewController setMessageBody:message isHTML:NO];
        [mailViewController setSubject:@"乐送"];
        if (recipient.recipientEmail != nil && [recipient.recipientEmail isEqualToString:@""] == NO){
            [mailViewController setToRecipients:[NSArray arrayWithObject:recipient.recipientEmail]];
        }
        [self presentModalViewController:mailViewController animated:YES]; 
        [HGTrackingService logPageView];
	} else {
        HappyGiftAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
        [appDelegate sendNotification:@"您的设备不支持发送邮件"];
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
    launchForLoginBindCancel = YES;
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
    launchForLoginBindCancel = YES;
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

    /*NSMutableDictionary *tokenCookie = [NSMutableDictionary dictionary];
    [tokenCookie setObject:[NSString stringWithFormat:@"user_id=%@;token=%@", accountService.currentAccount.userId, accountService.currentAccount.userToken] forKey:NSHTTPCookieValue];
    [tokenCookie setObject:[[NSDate date] dateByAddingTimeInterval:2629743] forKey:NSHTTPCookieExpires];
    NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:tokenCookie];
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];*/
    
    [self updateViewDisplay:YES];
    
    // request recipients data once after account bound;
    [HGRecipientService sharedService].delegate = self;
    [[HGRecipientService sharedService] requestRecipients];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kHGNotificationAccountUpdated object:nil];
    
    HappyGiftAppDelegate *appDelegate = (HappyGiftAppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appDelegate.deviceToken != nil){
        [[HGPushNotificationService sharedService] requestRegisterDeviceToken:appDelegate.deviceToken];
    }
    
    [self handleCancelAction:nil];
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
    
    if (launchForLogin == YES){
        [self handleCancelAction:nil];
    }
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
    
    /*NSMutableDictionary *tokenCookie = [NSMutableDictionary dictionary];
    [tokenCookie setObject:[NSString stringWithFormat:@"user_id=%@;token=%@", accountService.currentAccount.userId, accountService.currentAccount.userToken] forKey:NSHTTPCookieValue];
    [tokenCookie setObject:[[NSDate date] dateByAddingTimeInterval:2629743] forKey:NSHTTPCookieExpires];
    NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:tokenCookie];
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];*/
    
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

- (void)accountService:(HGAccountService *)accountService didAccountUnbindSucceed:(int)networkId withUpdatedAccount:(HGAccount *)updatedAccount {
    if (networkId == NETWORK_SNS_WEIBO || networkId == NETWORK_SNS_RENREN || networkId == NETWORK_ALL_SNS) {
        [self updateViewDisplay:YES];
    }   
    [progressView stopAnimation];
}

- (void)accountService:(HGAccountService *)accountService didAccountUnbindFail:(int)networkId withError:(NSString*)error {
    HGWarning(@"got unbind failure:%@", error);
    
//    [accountService localLogout:networkId];
//    if (networkId == NETWORK_SNS_WEIBO || networkId == NETWORK_SNS_RENREN || networkId == NETWORK_ALL_SNS) {
//        [self updateViewDisplay:YES];
//    }
    [progressView stopAnimation];
    
    HappyGiftAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    [appDelegate sendNotification:@"退出登陆失败，请检查您的网络连接稍后再试"];
}

#pragma mark  UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0){
        recommendAction = kRecommendActionMessage;
    }else if (buttonIndex == 1){
        recommendAction = kRecommendActionEmail;
    } else {
        recommendAction = kRecommendActionCancel;
    }
    
    if (recommendAction == kRecommendActionMessage || recommendAction == kRecommendActionEmail) {
        HGRecipientSelectionViewController* viewController = [[HGRecipientSelectionViewController alloc] initWithRecipientSelectionType:1];
        viewController.delegate = self;
        [self presentModalViewController:viewController animated:YES];
        [viewController release]; 
        [HGTrackingService logEvent:kTrackingEventEnterRecipientSelection withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"HGAccountViewController", @"from", nil]];
        [HGTrackingService logPageView];
    }
}

#pragma mark  HGCreditServiceDelegate
- (void)creditService:(HGCreditService *)creditService didRequestInvitationSucceed:(NSString*)invitation{
    [progressView stopAnimation];
    
    if (recommendAction == kRecommendActionMessage){
        [self recommedAppByMessage:recommendRecipient invitation:invitation];
    }else if (recommendAction == kRecommendActionEmail){
        [self recommedAppByEmail:recommendRecipient invitation:invitation];
    }
    
    [recommendRecipient release];
    recommendRecipient = nil;
}

- (void)creditService:(HGCreditService *)creditService didRequestInvitationFail:(NSString*)error{
    [progressView stopAnimation];
    HappyGiftAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    [appDelegate sendNotification:[NSString stringWithFormat:@"发送推荐邀请失败"]];
}

#pragma mark  HGRecipientSelectionViewControllerDelegate
- (void)didRecipientSelected: (HGRecipient*)recipient{
    recommendRecipient = [recipient retain];
    recommendRecipientSelected = YES;
}

#pragma mark - MFMailComposeViewControllerDelegate
- (void) mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    if (result == MFMailComposeResultSent) {
        HappyGiftAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
        [appDelegate sendNotification:[NSString stringWithFormat:@"成功发送推荐邮件"]];
    }else if (result == MFMailComposeResultFailed) {
        HappyGiftAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
        [appDelegate sendNotification:[NSString stringWithFormat:@"发送推荐邮件失败"]];
    }
    [mailViewController dismissModalViewControllerAnimated:YES];
    [mailViewController release];
    mailViewController = nil;
} 

#pragma mark - MFMessageComposeViewControllerDelegate
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {  
    if (result == MessageComposeResultSent) {
        HappyGiftAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
        [appDelegate sendNotification:[NSString stringWithFormat:@"成功发送推荐短信"]];
    }else if (result == MessageComposeResultFailed) {
        HappyGiftAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
        [appDelegate sendNotification:[NSString stringWithFormat:@"发送推荐短信失败"]];
    }
    [messageViewController dismissModalViewControllerAnimated:YES];
    [messageViewController release];
    messageViewController = nil;
}
@end
