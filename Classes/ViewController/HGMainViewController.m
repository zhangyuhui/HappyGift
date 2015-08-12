//
//  HGMainViewController.m
//  HappyGift
//
//  Created by Zhang Yuhui on 2/11/11.
//  Copyright 2011 Ztelic Inc Inc. All rights reserved.
//

#import "HGMainViewController.h"
#import "HappyGiftAppDelegate.h"
#import "HGConstants.h"
#import "HGAccountViewController.h"
#import "HGAccountService.h"
#import "HGProgressView.h"
#import "HGFeaturedGiftCollection.h"
#import "HGGiftSet.h"
#import "HGGift.h"
#import "HGTutorialViewController.h"
#import "HGMainViewSentGiftsGridView.h"
#import "HGOccasionsListViewController.h"
#import "HGOccasionGiftCollection.h"
#import "HGMainViewFeaturedGiftCollectionGridView.h"
#import "HGMainViewGlobalOccasionGiftCollectionGridView.h"
#import "HGMainViewPersonlizedOccasionGiftCollectionGridView.h"
#import "HGGiftSetDetailViewController.h"
#import "HGGiftCollectionService.h"
#import "UIBarButtonItem+Addition.h"
#import "HGGiftsSelectionViewController.h"
#import "HGGiftDetailViewController.h"
#import "HGGiftCategoryService.h"
#import "HGSentGiftDetailViewController.h"
#import "HGOccasionDetailViewController.h"
#import "HGGiftSetsService.h"
#import "HGTrackingService.h"
#import "HGOccasionCategory.h"
#import <QuartzCore/QuartzCore.h>
#import "HGGiftOrderService.h"
#import "HGSentGiftsViewController.h"
#import "HGRecipientService.h"
#import "HGImageService.h"
#import "HGGiftCardService.h"
#import "WBEngine.h"
#import <AddressBook/AddressBook.h>
#import "HGLogging.h"
//#import "HGFriendRecommandationService.h"
#import "HGMainViewFriendRecommandationGridView.h"
#import "HGFriendRecommandation.h"
#import "HGFriendRecommandationListViewController.h"
#import "HGAppConfigurationService.h"
#import "HGCreditViewController.h"
#import "HGCreditService.h"
//#import "HGAstroTrendService.h"
#import "HGMainViewAstroTrendGridView.h"
#import "HGAstroTrend.h"
#import "HGAstroTrendDetailViewController.h"
#import "HGAstroTrendListViewController.h"
#import "HGMainViewVirtualGiftGridView.h"
#import "HGFriendEmotionService.h"
#import "HGMainViewFriendEmotionGridView.h"
#import "HGFriendEmotionDetailViewController.h"
#import "HGFriendEmotion.h"
#import "HGFriendEmotionListViewController.h"
#import "HGLoginViewController.h"
#import "HGGIFGiftListViewController.h"
#import "HGImageComposeViewController.h"
#import "HGShareViewController.h"
#import "HGTrackingService.h"
#import "HGVirtualGiftService.h"
#import "HGOccasionTag.h"

#define kMainViewGiftCollectionsExpirationIntervalForWIFI   (30*60)
#define kMainViewGiftCollectionsExpirationIntervalForOtherNetwork   (60*60*3)

#define kMainViewAlertViewContineuGift 100
#define kMainViewAlertViewAccountExpired 101

#define kMainViewGiftCollectionsTimestampDataFormat @"yyyy-MM-dd HH:mm:ss.SSSS"

@interface HGMainViewController()<UIScrollViewDelegate, HGGiftCollectionServiceDelegate, HGGiftOrderServiceDelegate, HGMainViewFeaturedGiftCollectionGridViewDelegate, HGMainViewGlobalOccasionGiftCollectionGridViewDelegate, HGMainViewPersonlizedOccasionGiftCollectionGridViewDelegate, HGMainViewSentGiftsGridViewDelegate, /*HGFriendRecommandationServiceDelegate,*/ HGMainViewRecommandationGridViewDelegate, HGAccountServiceDelegate, /*HGAstroTrendServiceDelegate,*/ HGMainViewAstroTrendGridViewDelegate, HGFriendEmotionServiceDelegate, HGMainViewFriendEmotionGridViewDelegate, HGAccountViewControllerDelegate, HGMainViewVirtualGiftGridViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, HGImageComposeViewControllerDelegate>
  
@end

@implementation HGMainViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    self.view.backgroundColor = [HappyGiftAppDelegate genericBackgroundColor];
    
    HappyGiftAppDelegate *appDelegate = (HappyGiftAppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.window.backgroundColor = [HappyGiftAppDelegate genericBackgroundColor];
    
    leftBarButtonItem = [[UIBarButtonItem alloc ] initNavigationLeftImageBarButtonItem:@"navigation_account" target:self action:@selector(handleSettingAction:)];
    navigationBar.topItem.leftBarButtonItem = leftBarButtonItem; 
    navigationBar.topItem.rightBarButtonItem = nil;
    
    CGRect titleViewFrame = CGRectMake(0, 0, 180, 44);
    UIView* titleView = [[UIView alloc] initWithFrame:titleViewFrame];
    CGRect logoImageViewFrame = CGRectMake((titleViewFrame.size.width - 44.0)/2.0, 5.0, 44.0, 35.0);
    UIImageView* logoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"navigation_logo"]];
    logoImageView.frame = logoImageViewFrame;
    [titleView addSubview:logoImageView];
    [logoImageView release];
    
	navigationBar.topItem.titleView = titleView;
    [titleView release];
    
    UIImage* giftStartBackgroundImage = [[UIImage imageNamed:@"gift_selection_start_button"] stretchableImageWithLeftCapWidth:20.0 topCapHeight:20.0];
    UIImage* giftContinueBackgroundImage = [[UIImage imageNamed:@"gift_selection_continue_button"] stretchableImageWithLeftCapWidth:20.0 topCapHeight:0.0];
    [giftStartButton setBackgroundImage:giftStartBackgroundImage forState:UIControlStateNormal];
    [giftContinueButton setBackgroundImage:giftContinueBackgroundImage forState:UIControlStateNormal];
    
    giftContinueUpLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeMicro]];
    giftContinueUpLabel.textColor = [UIColor darkGrayColor];
    giftContinueUpLabel.text = @"继续送礼物给";
    
    giftContinueBottomLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:[HappyGiftAppDelegate fontSizeNormal]];
    giftContinueBottomLabel.minimumFontSize = 12.0;
    giftContinueBottomLabel.adjustsFontSizeToFitWidth = YES;
    giftContinueBottomLabel.textColor = [UIColor blackColor];
    
    giftStartLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:[HappyGiftAppDelegate fontSizeXLarge]];
    giftStartLabel.minimumFontSize = 12.0;
    giftStartLabel.adjustsFontSizeToFitWidth = YES;
    giftStartLabel.textColor = [UIColor blackColor];
    giftStartLabel.text = @"挑选礼物";

    
    accountBindButton.titleLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:[HappyGiftAppDelegate fontSizeXLarge]];
    [accountBindButton setTitle:@"登录您的微博和社交平台" forState:UIControlStateNormal];
    [accountBindButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [accountBindButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [accountBindButton addTarget:self action:@selector(handleAccountBindAction:) forControlEvents:UIControlEventTouchUpInside];
    UIImage* accountBindButtonImage = [[UIImage imageNamed:@"gift_selection_button"] stretchableImageWithLeftCapWidth:5 topCapHeight:10];
    [accountBindButton setBackgroundImage:accountBindButtonImage forState:UIControlStateNormal];
    
    progressView = [[HGProgressView progressView:self.view.frame] retain];
    [self.view addSubview:progressView];
    progressView.hidden = YES;
    smallProgressView.hidden = YES;
    
    [creditButton addTarget:self action:@selector(handleCreditAction:) forControlEvents:UIControlEventTouchUpInside];
    
    reloadButton.hidden = YES;
    [reloadButton addTarget:self action:@selector(handleReloadButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleApplicationDidBecomeActiveAction:) name:kHGNotificationApplicationDidBecomeActive object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleApplicationWillResignActive:) name:kHGNotificationApplicationWillResignActive object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleApplicationReachablityUpdated:) name:kHGNotificationApplicationReachablityUpdated object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAccountUpdated:) name:kHGNotificationAccountUpdated object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleMyGiftsUpdated:) name:kHGNotificationMyGiftsUpdated object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleMyGiftsNeedUpdate:) name:kHGNotificationMyGiftsNeedUpdate object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleFriendRecommendationUpdated:) name:kHGNotificationFriendRecommendationUpdated object:nil];
    
    if (NO == [self checkSNSTokenExpires]) {
        if ([self hasSomethingToShow]) {
            [self updateGiftCollectionViews];
            [self performGiftCollectionsUpdate:NO];
        } else {
            [self performGiftCollectionsUpdate:YES];
        }
    }
}

- (void)viewDidUnload{
    [super viewDidUnload];
    
    [progressView removeFromSuperview];
    [progressView release];
    progressView = nil;
    
    [leftBarButtonItem release];
    leftBarButtonItem = nil;
    
    if (contentSubViews != nil) {
        for (UIView* subView in contentSubViews){
            [subView removeFromSuperview];
        }
        [contentSubViews removeAllObjects];
        [contentSubViews release];
        contentSubViews = nil;
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kHGNotificationApplicationDidBecomeActive object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kHGNotificationApplicationWillResignActive object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kHGNotificationApplicationReachablityUpdated object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kHGNotificationAccountUpdated object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kHGNotificationMyGiftsUpdated object:nil]; 
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kHGNotificationMyGiftsNeedUpdate object:nil]; 
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kHGNotificationFriendRecommendationUpdated object:nil];  
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (giftCollectionsRequest <= 0) {
        CGPoint p = [contentView contentOffset];
        [self updateGiftCollectionViews];
        [contentView setContentOffset:p];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (![[HGAccountService sharedService] hasSNSAccountLoggedIn]) {
        [self showLoginView];
    }else if (imageForCompose != nil){
        [progressView startAnimation];
        [self performSelector:@selector(performImageComposeAction) withObject:nil afterDelay:0.0];
    }else if (imageForShare != nil){
        [progressView startAnimation];
        [self performSelector:@selector(performShareDIYGiftAction) withObject:nil afterDelay:0.0];
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void)dealloc{
    NSArray* subviews = contentView.subviews;
    for (UIView* subview in subviews){
        [subview removeFromSuperview];
    }
    [contentView release];
    [creditButton release];
    [progressView release];
    [leftBarButtonItem release];
    [giftContinueButton release];
    [giftContinueView release];
    [giftContinueUpLabel release];
    [giftContinueBottomLabel release];
    [accountBindView release];
    [accountBindButton release];
    [giftStartLabel release];
    [giftStartIndicator release];
    [reloadButton release];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kHGNotificationApplicationDidBecomeActive object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kHGNotificationApplicationWillResignActive object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kHGNotificationApplicationReachablityUpdated object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kHGNotificationAccountUpdated object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kHGNotificationMyGiftsUpdated object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kHGNotificationMyGiftsNeedUpdate object:nil]; 
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kHGNotificationFriendRecommendationUpdated object:nil];
	[super dealloc]; 
}

- (void)showLoginView {
    [HGTrackingService logEvent:kTrackingEventEnterLoginView withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"HGMainViewController", @"from", nil]];
    
    HGLoginViewController* viewController = [[HGLoginViewController alloc] initWithNibName:@"HGLoginViewController" bundle:nil];
    [self presentModalViewController:viewController animated:YES];
    [viewController release];
    [HGTrackingService logPageView];
}

- (void)handleSettingAction:(id)sender {
    [HGTrackingService logEvent:kTrackingEventEnterSetting withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"HGMainViewController", @"from", nil]];
    
    HGAccountViewController* viewController = [[HGAccountViewController alloc] initWithNibName:@"HGAccountViewController" bundle:nil];
    viewController.delegate = self;
    [self presentModalViewController:viewController animated:YES];
    [viewController release];
    [HGTrackingService logPageView];
}

- (void)handleReloadButtonAction:(id)sender {
    [self performGiftCollectionsUpdate:NO];
}

- (void)handleCreditAction:(id)sender{
    HGCreditViewController* viewController = [[HGCreditViewController alloc] initWithNibName:@"HGCreditViewController" bundle:nil];
    [self.navigationController pushViewController:viewController animated:YES];
    [viewController release];
}

- (void)handleAccountBindAction:(id)sender{
    [HGTrackingService logEvent:kTrackingEventEnterSetting withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"HGMainViewController", @"from", nil]];
    if (weiboExpired == YES && renrenExpired == YES){
        HGAccountViewController* viewController = [[HGAccountViewController alloc] initWithNibName:@"HGAccountViewController" bundle:nil];
        [self presentModalViewController:viewController animated:YES];
        [viewController release];
    }else if (weiboExpired == YES){
        HGAccountViewController* viewController = [[HGAccountViewController alloc] initWithLoginNetwork:NETWORK_SNS_WEIBO];
        [self presentModalViewController:viewController animated:NO];
        [viewController release];
    }else if (renrenExpired == YES){
        HGAccountViewController* viewController = [[HGAccountViewController alloc] initWithLoginNetwork:NETWORK_SNS_RENREN];
        [self presentModalViewController:viewController animated:NO];
        [viewController release];
    }else{
        HGAccountViewController* viewController = [[HGAccountViewController alloc] initWithNibName:@"HGAccountViewController" bundle:nil];
        [self presentModalViewController:viewController animated:YES];
        [viewController release];
    }
    [HGTrackingService logPageView];
}

- (void) updateStartGiftLayout {
    if ([HGRecipientService sharedService].selectedRecipient) {
        HGRecipient *recipient = [HGRecipientService sharedService].selectedRecipient;
        
        giftStartView.frame = CGRectMake(5, giftStartView.frame.origin.y, 130, giftStartView.frame.size.height);
        giftContinueView.frame = CGRectMake(140, giftStartView.frame.origin.y, 175, giftStartView.frame.size.height);
        
        giftContinueBottomLabel.text = [NSString stringWithFormat:@"%@", recipient.recipientName];
        giftStartLabel.text = @"挑选新礼物";
        
        giftContinueView.hidden = NO;
        giftStartView.hidden = NO;
        giftStartIndicator.hidden = YES;
        
        UIImage *imageData = nil;
        if (recipient.recipientImageUrl && ![@"" isEqualToString:recipient.recipientImageUrl]) {
            imageData = [[HGImageService sharedService] requestImage:recipient.recipientImageUrl target:self selector:@selector(didImagesLoaded:)];
        }
        
        if (!imageData){
            imageData = [UIImage imageNamed:@"user_default"];
        }
        
        if (recipient.recipientNetworkId == NETWORK_PHONE_CONTACT) {
            if (recipient.recipientProfileId && ![recipient.recipientProfileId isEqualToString:@""]) {
                ABAddressBookRef addressBook = ABAddressBookCreate();
                ABRecordRef person = ABAddressBookGetPersonWithRecordID(addressBook, [recipient.recipientProfileId intValue]);
                if (person) {
                    NSData* data = (NSData*)ABPersonCopyImageData(person);
                    if (data) {
                        imageData = [UIImage imageWithData:data];
                        [data release];
                    }
                }
                CFRelease(addressBook);
            }
        }
            
        giftContinueImageView.image = imageData;
    } else {
        giftStartView.frame = CGRectMake(5, giftStartView.frame.origin.y, 310, giftStartView.frame.size.height);
        giftContinueView.hidden = YES;
        giftStartView.hidden = NO;
        giftStartLabel.text = @"挑选礼物";
        giftStartIndicator.hidden = NO;
    }
}

- (void)updateGiftCollectionViewsWithAnimation {
    if (contentSubViews != nil) {
        contentView.alpha = 1.0;
        accountBindView.alpha = 1.0;
        
        CGRect contentViewFrame= contentView.frame;
        contentViewFrame.origin.y = 44.0;
        contentView.frame = contentViewFrame;
        
        [UIView animateWithDuration:0.3 animations:^{
            contentView.alpha = 0.0;
            accountBindView.alpha = 0.0;
        } completion:^(BOOL finished) {
            [self updateGiftCollectionViews];
            
            [UIView animateWithDuration:0.3 animations:^{
                contentView.alpha = 1.0;
                accountBindView.alpha = 1.0;
            } completion:^(BOOL finished) {
                [self checkAndShowSNSExpiredDialog];
            }];
        }];
    } else {
        contentView.alpha = 1.0;
        accountBindView.alpha = 1.0;
        
        [self updateGiftCollectionViews];
        
        CGRect contentViewFrame= contentView.frame;
        contentViewFrame.origin.y = 460.0;
        contentView.frame = contentViewFrame;
        
        if (accountBindView.hidden == NO){
            CGRect accountBindViewFrame= accountBindView.frame;
            accountBindViewFrame.origin.y = contentViewFrame.origin.y + contentViewFrame.size.height;
            accountBindView.frame = accountBindViewFrame;
        }
        
        [UIView animateWithDuration:0.5 
                              delay:0.0 
                            options:UIViewAnimationOptionCurveEaseInOut 
                         animations:^{
                             CGRect contentViewFrame= contentView.frame;
                             contentViewFrame.origin.y = 44.0;
                             contentView.frame = contentViewFrame;
                             
                             if (accountBindView.hidden == NO){
                                 CGRect accountBindViewFrame= accountBindView.frame;
                                 accountBindViewFrame.origin.y = contentViewFrame.origin.y + contentViewFrame.size.height;
                                 accountBindView.frame = accountBindViewFrame;
                             }
                         } 
                         completion:^(BOOL finished) {
                             [self checkAndShowSNSExpiredDialog];
                         }];
    }
}

- (void) checkAndShowSNSExpiredDialog {
    
    if (shouldNotifiyExpiration) {
        shouldNotifiyExpiration = NO;
        if (weiboExpired || renrenExpired) {
            NSString* msg;
            
            if (weiboExpired) {
                msg = @"你的微博登录已超时，请重新登录";
            } else if (renrenExpired) {
                msg = @"你的人人网登录已超时，请重新登录";
            }
            
            if ([[HGAccountService sharedService] hasSNSAccountLoggedIn]) {
                UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"提示" 
                                                                     message:msg
                                                                    delegate:self 
                                                           cancelButtonTitle:@"登录"
                                                           otherButtonTitles:@"取消", nil];
                [alertView setTag:kMainViewAlertViewAccountExpired];
                [alertView show];
                [alertView release];
            } else {
                UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"提示" 
                                                                     message:msg
                                                                    delegate:self 
                                                           cancelButtonTitle:@"确认"
                                                           otherButtonTitles: nil];
                [alertView setTag:kMainViewAlertViewAccountExpired];
                [alertView show];
                [alertView release];
            }
        }
    }

}

- (BOOL)hasSomethingToShow {
    if ([[HGGiftCollectionService sharedService].personalizedOccasionGiftCollectionsArray count] > 0){
        return YES;
    }
    
    if ([[HGGiftCollectionService sharedService].globalOccasiondGiftCollectionsArray count] > 0) {
        return YES;
    }
    
    if ([[HGGiftCollectionService sharedService].featuredGiftCollectionsArray count] > 0) {
        return YES;
    }
    
    //if ([[HGAstroTrendService sharedService].astroTrends count] > 0) {
    //    return YES;
    //}
    
    if ([[HGFriendEmotionService sharedService].friendEmotions count] > 0) {
        return YES;
    }
    
    //if ([[HGFriendRecommandationService sharedService].friendRecommandations count] > 0) {
    //    return YES;
    //}
    
    if ([[HGGiftOrderService sharedService].sentGifts count] > 0) {
        return YES;
    }
    
    return NO;
}

- (CGFloat)layoutSection:(NSString*)sectionName atPosition:(CGFloat)viewY {
    CGFloat viewX = 1.0;
    if ([@"personalizedOccasion" isEqualToString:sectionName]) {
        NSArray* personalizedOccasionGiftCollectionsArray = [HGGiftCollectionService sharedService].personalizedOccasionGiftCollectionsArray;
        if (personalizedOccasionGiftCollectionsArray != nil && [personalizedOccasionGiftCollectionsArray count] > 0){
            for (NSArray* personalizedOccasionGiftCollections in personalizedOccasionGiftCollectionsArray){
                if (personalizedOccasionGiftCollections != nil && [personalizedOccasionGiftCollections count] > 0){
                    HGMainViewPersonlizedOccasionGiftCollectionGridView* mainViewPersonlizedOccasionGiftCollectionGridView = [HGMainViewPersonlizedOccasionGiftCollectionGridView mainViewPersonlizedOccasionGiftCollectionGridView];
                    
                    mainViewPersonlizedOccasionGiftCollectionGridView.giftCollections = personalizedOccasionGiftCollections;
                    
                    CGRect viewFrame = mainViewPersonlizedOccasionGiftCollectionGridView.frame;
                    viewFrame.origin.x = viewX;
                    viewFrame.origin.y = viewY;
                    mainViewPersonlizedOccasionGiftCollectionGridView.frame = viewFrame;
                    mainViewPersonlizedOccasionGiftCollectionGridView.delegate = self;
                    
                    [contentView addSubview:mainViewPersonlizedOccasionGiftCollectionGridView];
                    [contentSubViews addObject:mainViewPersonlizedOccasionGiftCollectionGridView];
                    
                    viewY += viewFrame.size.height;
                    viewY += 5.0;
                }
            }
        }
    } /*else if ([@"astroTrend" isEqualToString:sectionName]) {
        NSArray* astroTrends = [HGAstroTrendService sharedService].astroTrends;
        if (astroTrends && [astroTrends count] > 0) {
            HGMainViewAstroTrendGridView* view = [HGMainViewAstroTrendGridView mainViewAstroTrendGridView];
            view.astroTrends = astroTrends;
            
            CGRect viewFrame = view.frame;
            viewFrame.origin.x = viewX;
            viewFrame.origin.y = viewY;
            view.frame = viewFrame;
            view.delegate = self;
            
            [contentView addSubview:view];
            [contentSubViews addObject:view];
            
            viewY += viewFrame.size.height;
            viewY += 5.0;  
        }
    }*/ else if ([@"friendEmotion" isEqualToString:sectionName]) {
        NSArray* friendEmotions = [HGFriendEmotionService sharedService].friendEmotions;
        if (friendEmotions && [friendEmotions count] > 0) {
            HGMainViewFriendEmotionGridView* view = [HGMainViewFriendEmotionGridView mainViewFriendEmotionGridView];
            view.friendEmotions = friendEmotions;
            
            CGRect viewFrame = view.frame;
            viewFrame.origin.x = viewX;
            viewFrame.origin.y = viewY;
            view.frame = viewFrame;
            view.delegate = self;
            
            [contentView addSubview:view];
            [contentSubViews addObject:view];
            
            viewY += viewFrame.size.height;
            viewY += 5.0;  
        }
    } /*else if ([@"friendRecommendation" isEqualToString:sectionName]) {
        NSArray* recommendations = [HGFriendRecommandationService sharedService].friendRecommandations;
        if (recommendations && [recommendations count] > 0) {
            HGMainViewFriendRecommandationGridView* view = [HGMainViewFriendRecommandationGridView mainViewRecommandationGridView];
            view.recommandations = recommendations;
            
            CGRect viewFrame = view.frame;
            viewFrame.origin.x = viewX;
            viewFrame.origin.y = viewY;
            view.frame = viewFrame;
            view.delegate = self;
            
            [contentView addSubview:view];
            [contentSubViews addObject:view];
            
            viewY += viewFrame.size.height;
            viewY += 5.0;  
        }
    }*/ else if ([@"globalOccasion" isEqualToString:sectionName]) {
        NSArray* globalOccasionGiftCollections = [HGGiftCollectionService sharedService].globalOccasiondGiftCollectionsArray;
        for (HGOccasionGiftCollection* globalOccasionGiftCollection in globalOccasionGiftCollections){
            HGMainViewGlobalOccasionGiftCollectionGridView* mainViewGlobalOccasionGiftCollectionView = [HGMainViewGlobalOccasionGiftCollectionGridView mainViewGlobalOccasionGiftCollectionGridView];
            
            mainViewGlobalOccasionGiftCollectionView.giftCollection = globalOccasionGiftCollection;
            
            CGRect viewFrame = mainViewGlobalOccasionGiftCollectionView.frame;
            viewFrame.origin.x = viewX;
            viewFrame.origin.y = viewY;
            mainViewGlobalOccasionGiftCollectionView.frame = viewFrame;
            mainViewGlobalOccasionGiftCollectionView.delegate = self;
            
            [contentView addSubview:mainViewGlobalOccasionGiftCollectionView];
            [contentSubViews addObject:mainViewGlobalOccasionGiftCollectionView];
            
            viewY += viewFrame.size.height;
            viewY += 5.0;
        }
    } else if ([@"featuredGifts" isEqualToString:sectionName]) {
        NSArray* featuredGiftCollections = [HGGiftCollectionService sharedService].featuredGiftCollectionsArray;
        for (HGFeaturedGiftCollection* featuredGiftCollection in featuredGiftCollections){
            HGMainViewFeaturedGiftCollectionGridView* mainViewFeaturedGiftCollectionGridView = [HGMainViewFeaturedGiftCollectionGridView mainViewFeaturedGiftCollectionGridView];
            
            mainViewFeaturedGiftCollectionGridView.giftCollection = featuredGiftCollection;
            
            CGRect viewFrame = mainViewFeaturedGiftCollectionGridView.frame;
            viewFrame.origin.x = viewX;
            viewFrame.origin.y = viewY;
            mainViewFeaturedGiftCollectionGridView.frame = viewFrame;
            mainViewFeaturedGiftCollectionGridView.delegate = self;
            
            [contentView addSubview:mainViewFeaturedGiftCollectionGridView];
            [contentSubViews addObject:mainViewFeaturedGiftCollectionGridView];
            
            viewY += viewFrame.size.height;
            viewY += 5.0;
        }
    } else if ([@"sentGifts" isEqualToString:sectionName]) {
        NSArray* sentGifts = [HGGiftOrderService sharedService].sentGifts;
        if (sentGifts != nil && [sentGifts count] > 0) {
            HGMainViewSentGiftsGridView* mainViewSentGiftsGridView = [HGMainViewSentGiftsGridView mainViewSentGiftsGridView];
            mainViewSentGiftsGridView.giftOrders = sentGifts;
            
            CGRect viewFrame = mainViewSentGiftsGridView.frame;
            viewFrame.origin.x = viewX;
            viewFrame.origin.y = viewY;
            mainViewSentGiftsGridView.frame = viewFrame;
            mainViewSentGiftsGridView.delegate = self;
            
            [contentView addSubview:mainViewSentGiftsGridView];
            [contentSubViews addObject:mainViewSentGiftsGridView];
            
            viewY += viewFrame.size.height;
            viewY += 10.0;  
        }
    }else if ([@"virtualGifts" isEqualToString:sectionName]) {
//        HGMainViewVirtualGiftGridView* mainViewVirtualGiftGridView = [HGMainViewVirtualGiftGridView mainViewVirtualGiftGridView];
//        
//        CGRect mainViewVirtualGiftGridViewFrame = mainViewVirtualGiftGridView.frame;
//        mainViewVirtualGiftGridViewFrame.origin.x = viewX;
//        mainViewVirtualGiftGridViewFrame.origin.y = viewY;
//        mainViewVirtualGiftGridView.frame = mainViewVirtualGiftGridViewFrame;
//        mainViewVirtualGiftGridView.delegate = self;
//        
//        [contentView addSubview:mainViewVirtualGiftGridView];
//        [contentSubViews addObject:mainViewVirtualGiftGridView];
//        
//        viewY += mainViewVirtualGiftGridViewFrame.size.height;
//        viewY += 5.0;
    }
    return viewY;
}

- (void)updateGiftCollectionViews {
    if (contentSubViews == nil){
        contentSubViews = [[NSMutableArray alloc] init];
    }else{
        for (UIView* subView in contentSubViews){
            [subView removeFromSuperview];
        }
        [contentSubViews removeAllObjects];
    }
    
    giftContinueView.hidden = YES;
    giftStartView.hidden = YES;
    
    if (accountBindView.hidden == NO) {
        CGRect contentViewFrame = contentView.frame;
        contentViewFrame.size.height +=  accountBindView.frame.size.height;
        contentView.frame = contentViewFrame;
        accountBindView.hidden = YES;
    }
    //reloadButton.hidden = NO;
    
    CGSize contentSize = contentView.contentSize;
    contentSize.width = contentView.frame.size.width;
    contentSize.height = contentView.frame.size.height + 1.0;
    [contentView setContentSize:contentSize];

    CGFloat viewY = 10.0;
    
    [self updateStartGiftLayout];
    
    [giftStartButton addTarget:self action:@selector(handleStartButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [giftContinueButton addTarget:self action:@selector(handleStartButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    viewY += giftStartView.frame.size.height + 5.0;
    
    for (NSString* sectionName in [HGAppConfigurationService sharedService].mainPageSections) {
        viewY = [self layoutSection:sectionName atPosition:viewY];
    }

    contentSize = contentView.contentSize;
    contentSize.width = contentView.frame.size.width;
    contentSize.height = viewY;
    [contentView setContentSize:contentSize];
    
    if ([self isAccountNotifyNeeded] == NO){
        if (accountBindView.hidden == NO){
            CGRect contentViewFrame = contentView.frame;
            contentViewFrame.size.height +=  accountBindView.frame.size.height;
            contentView.frame = contentViewFrame;
            accountBindView.hidden = YES;
        }
    }else{
        if (accountBindView.hidden == YES){
            CGRect contentViewFrame = contentView.frame;
            contentViewFrame.size.height -=  accountBindView.frame.size.height;
            contentView.frame = contentViewFrame;
            accountBindView.hidden = NO;
        }
    }
}

- (BOOL)isAccountNotifyNeeded {
//  only show account notify button when sns expired as sns login is always required
//    if ([[WBEngine sharedWeibo] isLoggedIn] == NO && [[RenrenService sharedRenren] isSessionValid] == NO) {
//        return YES;
//    }
    
    if (renrenExpired || weiboExpired) {
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)checkGiftCollectionsUpdate {
    HappyGiftAppDelegate *appDelegate = (HappyGiftAppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appDelegate.networkReachable == YES){
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString* giftCollectionsTimestamp = [defaults stringForKey:kHGPreferneceKeyGiftCollectionsTimestamp];
        if (giftCollectionsTimestamp == nil){
            return YES;
        }else{
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:kMainViewGiftCollectionsTimestampDataFormat];
            NSDate* giftCollectionsDate = [dateFormatter dateFromString:giftCollectionsTimestamp];
            [dateFormatter release];
            
            int expireTime = appDelegate.wifiReachable ? kMainViewGiftCollectionsExpirationIntervalForWIFI : kMainViewGiftCollectionsExpirationIntervalForOtherNetwork;
            
            // nagative for past time
            if (-[giftCollectionsDate timeIntervalSinceNow] > expireTime){
                return YES;
            }else{
                return NO;
            }
        }
    }else{
        return NO;
    }
}

- (void)clearGiftCollectionsUpdate {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:kHGPreferneceKeyGiftCollectionsTimestamp];
    [defaults synchronize];
}

- (void)reportGiftCollectionsUpdate{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:kMainViewGiftCollectionsTimestampDataFormat];
    NSString *formattedDateString = [dateFormatter stringFromDate:[NSDate date]];
    [dateFormatter release];
    
    [defaults setObject:formattedDateString forKey:kHGPreferneceKeyGiftCollectionsTimestamp];
    [defaults synchronize];
}

- (void)performGiftCollectionsUpdate:(BOOL)shouldBlockUser {
    if (giftCollectionsRequest != 0){
        [HGGiftCollectionService sharedService].delegate = nil;
        [HGGiftOrderService sharedService].delegate = nil;
        //[HGFriendRecommandationService sharedService].delegate = nil;
        giftCollectionsRequest = 0;
    }
    
    if (shouldBlockUser) {
        [progressView startAnimation];
    } else {
        [self startHeaderProgressView];
    }
    
    //reloadButton.hidden = YES;
    
    HGGiftCollectionService* giftCollectionService = [HGGiftCollectionService sharedService];
    giftCollectionService.delegate = self;
    giftCollectionsRequest = 3;
    
    if ([[HGAccountService sharedService] hasSNSAccountLoggedIn]) {
        giftCollectionsRequest += 2;
        [giftCollectionService requestPersonlizedOccasionGiftCollections];
        
        //[HGAstroTrendService sharedService].delegate = self;
        //[[HGAstroTrendService sharedService] requestAstroTrend];
        
        [HGFriendEmotionService sharedService].delegate = self;
        [[HGFriendEmotionService sharedService] requestFriendEmotions];

        //if ([[HGAppConfigurationService sharedService] isFriendRecommendationEnabled]) {
        //    giftCollectionsRequest++;
        //    [HGFriendRecommandationService sharedService].delegate = self;
        //    [[HGFriendRecommandationService sharedService] requestFriendRecommandation];
        //}
    }
    
    [giftCollectionService requestFeaturedGiftCollections];
    [giftCollectionService requestGlobalOccasionGiftCollections];
    HGGiftOrderService* giftOrderService = [HGGiftOrderService sharedService];
    giftOrderService.delegate = self;
    [giftOrderService requestMyGifts];
    
    [[HGGiftSetsService sharedService] requestGiftSets];
    [[HGGiftSetsService sharedService] requestMyLikeIds];
    [[HGGiftCardService sharedService] requestGiftCards];
    
    [[HGCreditService sharedService] requestCreditTotal];
}

- (void)startHeaderProgressView {
    smallProgressView.hidden = NO;
    [smallProgressView startAnimating];
}

- (void)stopHeaderProgressView {
    smallProgressView.hidden = YES;
    [smallProgressView stopAnimating];
}

- (void) performImagePickAction:(NSNumber*)action{
    if ([action intValue] == 0){
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum] == YES){
            UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
            imagePickerController.navigationBar.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"navigation_background"]];
            imagePickerController.modalPresentationStyle = UIModalPresentationFormSheet;
            imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            imagePickerController.mediaTypes =  [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
            
            imagePickerController.allowsEditing = NO;
            imagePickerController.delegate = self;
            
            [self presentModalViewController:imagePickerController animated:YES];
            [HGTrackingService logPageView];
        }
    }else{
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == YES){
            UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
            imagePickerController.navigationBar.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"navigation_background"]];
            imagePickerController.modalPresentationStyle = UIModalPresentationFormSheet;
            imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
            imagePickerController.mediaTypes =  [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
            
            imagePickerController.allowsEditing = NO;
            imagePickerController.delegate = self;
            
            [self presentModalViewController:imagePickerController animated:YES];
            [HGTrackingService logPageView];
        }
    }
    [progressView stopAnimation];
}

- (void) performImageComposeAction{
    HGImageComposeViewController* viewContoller = [[HGImageComposeViewController alloc] initWithCanvasImage:imageForCompose];
    viewContoller.delegate = self;
    [self presentModalViewController:viewContoller animated:YES];
    [viewContoller release];
    [HGTrackingService logPageView];
    
    [imageForCompose release];
    imageForCompose = nil;
    [progressView stopAnimation];
}

- (void)performShareDIYGiftAction{
    HGRecipient *recipient = [HGRecipientService sharedService].selectedRecipient;
    if (recipient.recipientNetworkId == NETWORK_SNS_WEIBO){
        if([[WBEngine sharedWeibo] isLoggedIn] == NO){
            HGAccountViewController* viewController = [[HGAccountViewController alloc] initWithNibName:@"HGAccountViewController" bundle:nil];
            [self presentModalViewController:viewController animated:YES];
            [viewController release];
            [HGTrackingService logPageView];
            [progressView stopAnimation];
            return;
        }
    }else if (recipient.recipientNetworkId == NETWORK_SNS_RENREN){
        if([[RenrenService sharedRenren] isSessionValid] == NO){
            HGAccountViewController* viewController = [[HGAccountViewController alloc] initWithNibName:@"HGAccountViewController" bundle:nil];
            [self presentModalViewController:viewController animated:YES];
            [viewController release];
            [HGTrackingService logPageView];
            [progressView stopAnimation];
            return;
        }
    }else{
        [imageForShare release];
        imageForShare = nil;
        [progressView stopAnimation];
        return;
    }
    
    [HGTrackingService logEvent:kTrackingEventEnterShare withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"HGMainViewController", @"from", @"shareDIYGift", @"type", recipient.recipientNetworkId == NETWORK_SNS_WEIBO ? @"weibo" : @"renren", @"network", nil]];
    
    HGShareViewController* viewController = [[HGShareViewController alloc] initWithDIYGift:imageForShare recipient:recipient];
    [self presentModalViewController:viewController animated:YES];
    [viewController release];
    [HGTrackingService logPageView];
    
    [imageForShare release];
    imageForShare = nil;
    
    [HGRecipientService sharedService].selectedRecipient = nil;
    
    [progressView stopAnimation];
}

#pragma mark  HGImagesService selector
- (void)didImagesLoaded:(HGImageData*)image{
    giftContinueImageView.image = image.image;
}

#pragma mark Notifications
- (void)handleApplicationDidBecomeActiveAction:(NSNotification *)notification {  
    if (giftCollectionsRequest > 0) {
        HGInfo(@"request ongoing, do nothing.");
        return;
    }
    
    if (NO == [self checkSNSTokenExpires]) {
        if ([self checkGiftCollectionsUpdate] == YES) {
            [self performGiftCollectionsUpdate:NO];
        }else{
            if (giftCollectionsRequest <= 0) {
                HGGiftOrderService* giftOrderService = [HGGiftOrderService sharedService];
                // don't callback us, will be notified by the mygiftupdated notification;
                if (giftOrderService.delegate == self) {
                    giftOrderService.delegate = nil;
                }
                [giftOrderService requestMyGifts];
            }
        }
    }
}

- (void)handleApplicationWillResignActive:(NSNotification *)notification{
    if (giftCollectionsRequest > 0) {
        if ([HGGiftCollectionService sharedService].delegate == self) {
            [HGGiftCollectionService sharedService].delegate = nil;
        }
        if ([HGGiftOrderService sharedService].delegate == self) {
            [HGGiftOrderService sharedService].delegate = nil;
        }
        //if ([HGFriendRecommandationService sharedService].delegate == self) {
        //    [HGFriendRecommandationService sharedService].delegate = nil;
        //}
        
        [progressView stopAnimation];
        [self stopHeaderProgressView];
        giftCollectionsRequest = 0;
        [self clearGiftCollectionsUpdate];
    }
}

- (void)handleApplicationReachablityUpdated:(NSNotification *)notification{
    HappyGiftAppDelegate *appDelegate = (HappyGiftAppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appDelegate.networkReachable == YES){
        HGDebug(@"handleApplicationReachablityUpdated");
        if (giftCollectionsRequest <= 0){
            CGPoint p = [contentView contentOffset];
            [self updateGiftCollectionViews];
            [contentView setContentOffset:p];
        }
    }
}

- (void)handleAccountUpdated:(NSNotification *)notification{
    HGDebug(@"handleAccountUpdated");
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray* preferneceKeySNSTokenExpiration = [defaults objectForKey:kHGPreferneceKeySNSTokenExpiration];
    if (preferneceKeySNSTokenExpiration != nil && [preferneceKeySNSTokenExpiration count] > 0){
        if ([[WBEngine sharedWeibo] isLoggedIn] == YES){
            if ([preferneceKeySNSTokenExpiration containsObject:[NSNumber numberWithInt:NETWORK_SNS_WEIBO]]){
                NSMutableArray* updatedPreferneceKeySNSTokenExpiration = [[NSMutableArray alloc] initWithArray:preferneceKeySNSTokenExpiration];
                [updatedPreferneceKeySNSTokenExpiration removeObject:[NSNumber numberWithInt:NETWORK_SNS_WEIBO]];
                preferneceKeySNSTokenExpiration = [NSArray arrayWithArray:updatedPreferneceKeySNSTokenExpiration];
                
                [defaults setObject:updatedPreferneceKeySNSTokenExpiration forKey:kHGPreferneceKeySNSTokenExpiration];
                [defaults synchronize];
                [updatedPreferneceKeySNSTokenExpiration release];
            }
            weiboExpired = NO;
        }
        if ([[RenrenService sharedRenren] isSessionValid] == YES){
            if ([preferneceKeySNSTokenExpiration containsObject:[NSNumber numberWithInt:NETWORK_SNS_RENREN]]){
                NSMutableArray* updatedPreferneceKeySNSTokenExpiration = [[NSMutableArray alloc] initWithArray:preferneceKeySNSTokenExpiration];
                [updatedPreferneceKeySNSTokenExpiration removeObject:[NSNumber numberWithInt:NETWORK_SNS_RENREN]];
                
                [defaults setObject:updatedPreferneceKeySNSTokenExpiration forKey:kHGPreferneceKeySNSTokenExpiration];
                [defaults synchronize];
                [updatedPreferneceKeySNSTokenExpiration release];
            }
            renrenExpired = NO;
        }
    }
    [self performGiftCollectionsUpdate:YES];
    
    HGCreditService* creditService = [HGCreditService sharedService];
    [creditService requestCreditTotal];
}

- (void)handleFriendRecommendationUpdated:(NSNotification *)notification {
    if (giftCollectionsRequest <= 0) {
        CGPoint p = [contentView contentOffset];
        [self updateGiftCollectionViews];
        [contentView setContentOffset:p];
    }
}


- (void)handleMyGiftsNeedUpdate:(NSNotification *)notification {
    if (giftCollectionsRequest <= 0) {
        HGGiftOrderService* giftOrderService = [HGGiftOrderService sharedService];
        // don't callback us, will be notified by the mygiftupdated notification;
        if (giftOrderService.delegate == self) {
            giftOrderService.delegate = nil;
        }
        [giftOrderService requestMyGifts];
    }
}

- (void)handleMyGiftsUpdated:(NSNotification *)notification{
    HGDebug(@"handleMyGiftsUpdated");
    if (giftCollectionsRequest <= 0) {
        CGPoint p = [contentView contentOffset];
        [self updateGiftCollectionViews];
        [contentView setContentOffset:p];
    }
}

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
        //reloadButton.hidden = YES;
        HGAccountService* accountService = [HGAccountService sharedService];
        accountService.delegate = self;
        [accountService unbindSNSAccount:networkId andProfileId:profileId];
    }
}

- (void)accountService:(HGAccountService *)accountService didAccountUnbindSucceed:(int)networkId withUpdatedAccount:(HGAccount *)updatedAccount {
    [progressView stopAnimation];
}

- (void)accountService:(HGAccountService *)accountService didAccountUnbindFail:(int)networkId withError:(NSString*)error {
    HGWarning(@"got unbind failure:%@", error);
    [accountService localLogout:networkId];
    [progressView stopAnimation];
}

- (BOOL)checkSNSTokenExpires {
    BOOL unbinding = NO;
    weiboExpired = NO;
    renrenExpired = NO;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray* preferneceKeySNSTokenExpiration = [defaults objectForKey:kHGPreferneceKeySNSTokenExpiration];
    if (preferneceKeySNSTokenExpiration != nil && [preferneceKeySNSTokenExpiration count] > 0) {
        if ([preferneceKeySNSTokenExpiration containsObject:[NSNumber numberWithInt:NETWORK_SNS_WEIBO]]){
            [accountBindButton setTitle:@"微博登录已超时，请重新登录" forState:UIControlStateNormal];
            if ([[WBEngine sharedWeibo] isLoggedIn]) {
                [self unbindSNSAccount:NETWORK_SNS_WEIBO];
                unbinding = YES;
            }
            weiboExpired = YES;
        } else if ([preferneceKeySNSTokenExpiration containsObject:[NSNumber numberWithInt:NETWORK_SNS_RENREN]]){
            [accountBindButton setTitle:@"人人网登录已超时，请重新登录" forState:UIControlStateNormal];
            
            if ([[RenrenService sharedRenren] isSessionValid]) {
                [self unbindSNSAccount:NETWORK_SNS_RENREN];
                unbinding = YES;
            }
            renrenExpired = YES;
        }
    }
    
    if (unbinding) {
        shouldNotifiyExpiration = YES;
        // clear UI
        if (contentSubViews) {
            for (UIView* subView in contentSubViews){
                [subView removeFromSuperview];
            }
            [contentSubViews removeAllObjects];
            [contentSubViews release];
            contentSubViews = nil;
        }
    
        giftContinueView.hidden = YES;
        giftStartView.hidden = YES;
        if (accountBindView.hidden == NO){
            CGRect contentViewFrame = contentView.frame;
            contentViewFrame.size.height +=  accountBindView.frame.size.height;
            contentView.frame = contentViewFrame;
            accountBindView.hidden = YES;
        }
    }
    
    return unbinding;
}

- (void)handleStartButtonAction:(id)sender{
    if (![sender isEqual:giftContinueButton]) {
        if ([HGRecipientService sharedService].selectedRecipient) {
            NSString* msg = [NSString stringWithFormat:@"开始新的礼物将放弃%@的礼物", [HGRecipientService sharedService].selectedRecipient.recipientName];
            UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"提示" 
                                                                 message:msg
                                                                delegate:self 
                                                       cancelButtonTitle:@"确定"
                                                       otherButtonTitles:@"取消", nil];
            [alertView setTag:kMainViewAlertViewContineuGift];
            [alertView show];
            [alertView release];
            return;
        }
    }
    
    [HGTrackingService logEvent:kTrackingEventEnterGiftSelection withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"HGMainViewController", @"from", nil]];
    
    NSDictionary* giftSets = [HGGiftSetsService sharedService].giftSets;
    HGGiftsSelectionViewController* viewContoller = [[HGGiftsSelectionViewController alloc] initWithGiftSets:giftSets currentGiftCategory:nil];
    [self.navigationController pushViewController:viewContoller animated:YES];
    [viewContoller release];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
   if (alertView.tag == kMainViewAlertViewContineuGift) {
       if (buttonIndex == alertView.cancelButtonIndex) {
           [HGRecipientService sharedService].selectedRecipient = nil;
           
           [HGTrackingService logEvent:kTrackingEventEnterGiftSelection withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"HGMainViewController", @"from", nil]];
           
           NSDictionary* giftSets = [HGGiftSetsService sharedService].giftSets;
           HGGiftsSelectionViewController* viewContoller = [[HGGiftsSelectionViewController alloc] initWithGiftSets:giftSets currentGiftCategory:nil];
           [self.navigationController pushViewController:viewContoller animated:YES];
           [viewContoller release];
       }
   } else if (alertView.tag == kMainViewAlertViewAccountExpired) {
       if (buttonIndex == alertView.cancelButtonIndex) {
           [HGTrackingService logEvent:kTrackingEventEnterSetting withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"HGMainViewController", @"from", nil]];
           if (weiboExpired == YES && renrenExpired == YES){
               HGAccountViewController* viewController = [[HGAccountViewController alloc] initWithNibName:@"HGAccountViewController" bundle:nil];
               [self presentModalViewController:viewController animated:YES];
               [viewController release];
           }else if (weiboExpired == YES){
               HGAccountViewController* viewController = [[HGAccountViewController alloc] initWithLoginNetwork:NETWORK_SNS_WEIBO];
               [self presentModalViewController:viewController animated:NO];
               [viewController release];
           }else if (renrenExpired == YES){
               HGAccountViewController* viewController = [[HGAccountViewController alloc] initWithLoginNetwork:NETWORK_SNS_RENREN];
               [self presentModalViewController:viewController animated:NO];
               [viewController release];
           }
           [HGTrackingService logPageView];
       }
   }
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex != 2){
        [progressView startAnimation];
        if (imageForCompose != nil){
            [imageForCompose release];
            imageForCompose = nil;
        }
        [self performSelector:@selector(performImagePickAction:) withObject:[NSNumber numberWithInt:buttonIndex] afterDelay:0.0];
    }
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    [picker dismissModalViewControllerAnimated:YES];
	imageForCompose = [[info objectForKey:@"UIImagePickerControllerOriginalImage"] retain];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissModalViewControllerAnimated:YES];
}

#pragma mark - HGImageComposeViewControllerDelegate 
- (void)imageComposeViewController:(HGImageComposeViewController *)imageComposeViewController didFinishComposeImage:(UIImage*)image{
    imageForShare = [image retain];
}

- (void)imageComposeViewControllerDidCancel:(HGImageComposeViewController *)imageComposeViewController{
    
}

#pragma mark - UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)theNavigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
}
 
/*#pragma mark - HGFriendRecommandationServiceDelegate
- (void)friendRecommandationService:(HGFriendRecommandationService *)friendRecommandationService didRequestFriendRecommandationSucceed:(NSArray*)theRecommandations {
    giftCollectionsRequest -= 1;
    if (giftCollectionsRequest <= 0){
        [self updateGiftCollectionViewsWithAnimation];
        [progressView stopAnimation];
        [self stopHeaderProgressView];
    }
    friendRecommandationService.delegate = nil;
    [self reportGiftCollectionsUpdate];
}

- (void)friendRecommandationService:(HGFriendRecommandationService *)friendRecommandationService didRequestFriendRecommandationFail:(NSString*)error {
    giftCollectionsRequest -= 1;
    if (giftCollectionsRequest <= 0){
        [self updateGiftCollectionViewsWithAnimation];
        [progressView stopAnimation];
        [self stopHeaderProgressView];
    }
    friendRecommandationService.delegate = nil;
}*/

/*#pragma mark - HGAstroTrendServiceDelegate
- (void)astroTrendService:(HGAstroTrendService *)astroTrendService didRequestAstroTrendSucceed:(NSArray *)theAstroTrends {
    giftCollectionsRequest -= 1;
    if (giftCollectionsRequest <= 0){
        [self updateGiftCollectionViewsWithAnimation];
        [progressView stopAnimation];
        [self stopHeaderProgressView];
    }
    astroTrendService.delegate = nil;
    [self reportGiftCollectionsUpdate];
}

- (void)astroTrendService:(HGAstroTrendService *)astroTrendService didRequestAstroTrendFail:(NSString*)error {
    giftCollectionsRequest -= 1;
    if (giftCollectionsRequest <= 0){
        [self updateGiftCollectionViewsWithAnimation];
        [progressView stopAnimation];
        [self stopHeaderProgressView];
    }
    astroTrendService.delegate = nil;
}*/

#pragma mark - HGFriendEmotionServiceDelegate
- (void)friendEmotionService:(HGFriendEmotionService *)friendEmotionService didRequestFriendEmotionSucceed:(NSArray*)theFriendEmotions {
    giftCollectionsRequest -= 1;
    if (giftCollectionsRequest <= 0){
        [self updateGiftCollectionViewsWithAnimation];
        [progressView stopAnimation];
        [self stopHeaderProgressView];
    }
    friendEmotionService.delegate = nil;
    [self reportGiftCollectionsUpdate];
}

- (void)friendEmotionService:(HGFriendEmotionService *)friendEmotionService didRequestFriendEmotionFail:(NSString*)error {
    giftCollectionsRequest -= 1;
    if (giftCollectionsRequest <= 0){
        [self updateGiftCollectionViewsWithAnimation];
        [progressView stopAnimation];
        [self stopHeaderProgressView];
    }
    friendEmotionService.delegate = nil;
}


#pragma mark - HGGiftCollectionServiceDelegate
- (void)giftCollectionService:(HGGiftCollectionService *)theGiftCollectionService didRequestFeaturedGiftCollectionsSucceed:(NSArray*)theFeaturedGiftCollections{
    giftCollectionsRequest -= 1;
    if (giftCollectionsRequest <= 0){
        [self updateGiftCollectionViewsWithAnimation];
        [progressView stopAnimation];
        [self stopHeaderProgressView];
    }
    
    [self reportGiftCollectionsUpdate];
}

- (void)giftCollectionService:(HGGiftCollectionService *)theGiftCollectionService didRequestFeaturedGiftCollectionsFail:(NSString*)error {
    giftCollectionsRequest -= 1;
    if (giftCollectionsRequest <= 0){
        [self updateGiftCollectionViewsWithAnimation];
        [progressView stopAnimation];
        [self stopHeaderProgressView];
    }
}

- (void)giftCollectionService:(HGGiftCollectionService *)giftCollectionService didRequestGlobalOccasionGiftCollectionsSucceed:(NSArray*)theGlobalOccasionGiftCollections{
    giftCollectionsRequest -= 1;
    if (giftCollectionsRequest <= 0){
        [self updateGiftCollectionViewsWithAnimation];
        [progressView stopAnimation];
        [self stopHeaderProgressView];
    }
    [self reportGiftCollectionsUpdate];
}

- (void)giftCollectionService:(HGGiftCollectionService *)giftCollectionService didRequestGlobalOccasiondGiftCollectionsFail:(NSString*)error{
    giftCollectionsRequest -= 1;
    if (giftCollectionsRequest <= 0){
        [self updateGiftCollectionViewsWithAnimation];
        [progressView stopAnimation];
        [self stopHeaderProgressView];
    }
}

- (void)giftCollectionService:(HGGiftCollectionService *)giftCollectionService didRequestPersonlizedOccasionGiftCollectionsSucceed:(NSArray*)thePersonlizedOccasionGiftCollectionsArray{
    giftCollectionsRequest -= 1;
    if (giftCollectionsRequest <= 0){
        [self updateGiftCollectionViewsWithAnimation];
        [progressView stopAnimation];
        [self stopHeaderProgressView];
    }
    [self reportGiftCollectionsUpdate];
}

- (void)giftCollectionService:(HGGiftCollectionService *)giftCollectionService didRequestPersonlizedOccasiondGiftCollectionsFail:(NSString*)error{
    giftCollectionsRequest -= 1;
    if (giftCollectionsRequest <= 0){
        [self updateGiftCollectionViewsWithAnimation];
        [progressView stopAnimation];
        [self stopHeaderProgressView];
    }
}

#pragma mark - HGGiftOrderServiceDelegate
- (void)giftOrderService:(HGGiftOrderService *)theGiftOrderService didRequestMyGiftsSucceed:(NSArray*)theMyGifts{
    giftCollectionsRequest -= 1;
    if (giftCollectionsRequest <= 0){
        [self updateGiftCollectionViewsWithAnimation];
        [progressView stopAnimation];
        [self stopHeaderProgressView];
    }
    [self reportGiftCollectionsUpdate];
    theGiftOrderService.delegate = nil;
}

- (void)giftOrderService:(HGGiftOrderService *)theGiftOrderService didRequestMyGiftsFail:(NSString*)error{
    giftCollectionsRequest -= 1;
    if (giftCollectionsRequest <= 0){
        [self updateGiftCollectionViewsWithAnimation];
        [progressView stopAnimation];
        [self stopHeaderProgressView];
    }
    theGiftOrderService.delegate = nil;
}

#pragma mark - HGMainViewFeaturedGiftCollectionGridViewDelegate
- (void)mainViewFeaturedGiftCollectionGridView:(HGMainViewFeaturedGiftCollectionGridView *)theMainViewFeaturedGiftCollectionGridView didSelectFeaturedGiftCollection:(HGFeaturedGiftCollection*)theFeaturedGiftCollection{
    
    [HGTrackingService logEvent:kTrackingEventEnterGiftSelection withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"HGMainViewController", @"from", nil]];
    
    NSDictionary* giftSets = [HGGiftSetsService sharedService].giftSets;
    HGGiftsSelectionViewController* viewContoller = [[HGGiftsSelectionViewController alloc] initWithGiftSets:giftSets currentGiftCategory:nil];
    [self.navigationController pushViewController:viewContoller animated:YES];
    [viewContoller release];
}

- (void)mainViewFeaturedGiftCollectionGridView:(HGMainViewFeaturedGiftCollectionGridView *)theMainViewFeaturedGiftCollectionGridView didSelectFeaturedGiftSet:(HGGiftSet*)theGiftSet{
    
    if ([theGiftSet.gifts count] == 1){
        HGGift* theGift = [theGiftSet.gifts objectAtIndex:0];
        
        [HGTrackingService logEvent:kTrackingEventEnterGiftDetail withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"HGMainViewController", @"from", theGift.identifier, @"productId", nil]];
        
        HGGiftDetailViewController* viewContoller = [[HGGiftDetailViewController alloc] initWithGift:theGift];
        [self.navigationController pushViewController:viewContoller animated:YES];
        [viewContoller release];
    }else{
        [HGTrackingService logEvent:kTrackingEventEnterGiftGroupDetail withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"HGMainViewController", @"from", nil]];
        HGGiftSetDetailViewController* viewContoller = [[HGGiftSetDetailViewController alloc] initWithGiftSet:theGiftSet];
        [self.navigationController pushViewController:viewContoller animated:YES];
        [viewContoller release];
    }
}

- (void)mainViewFeaturedGiftCollectionGridViewDidSelectGIFGifts:(HGMainViewVirtualGiftGridView*)mainViewVirtualGiftGridView {
    NSMutableDictionary* gifts = [HGVirtualGiftService sharedService].gifGiftsByCategory;
    HGGIFGiftListViewController* viewController = [[HGGIFGiftListViewController alloc] initWithGIFGiftsByCategory:gifts];
    [self.navigationController pushViewController:viewController animated:YES];
    [viewController release];
    [HGTrackingService logEvent:kTrackingEventEnterGIFGifts withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"HGMainViewController", @"from", nil]];
}

- (void)mainViewFeaturedGiftCollectionGridViewDidSelectDIYGifts:(HGMainViewVirtualGiftGridView*)mainViewVirtualGiftGridView{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] 
                                  initWithTitle:nil
                                  delegate:self 
                                  cancelButtonTitle:@"取消" 
                                  destructiveButtonTitle:nil 
                                  otherButtonTitles:@"从相册选择图片", @"拍摄一张新照片", nil];
    [actionSheet showInView:self.view];
    [actionSheet release];
}

#pragma mark - HGMainViewGlobalOccasionGiftCollectionGridViewDelegate
- (void)mainViewGlobalOccasionGiftCollectionGridView:(HGMainViewGlobalOccasionGiftCollectionGridView *)theMainViewGlobalOccasionGiftCollectionGridView didSelectGlobalOccasionGiftCollection:(HGOccasionGiftCollection*)theOccasionGiftCollection{
    
    [HGTrackingService logEvent:kTrackingEventEnterGiftSelection withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"HGMainViewController", @"from", theOccasionGiftCollection.occasion.occasionCategory.name, @"occasion", nil]];
    
    
    NSDictionary* giftSets = [HGGiftSetsService sharedService].giftSets;
    HGGiftsSelectionViewController* viewContoller = [[HGGiftsSelectionViewController alloc] initWithGiftSets:giftSets occasionGiftCollection:theOccasionGiftCollection];
    [self.navigationController pushViewController:viewContoller animated:YES];
    [viewContoller release];
}

- (void)mainViewGlobalOccasionGiftCollectionGridView:(HGMainViewGlobalOccasionGiftCollectionGridView *)theMainViewGlobalOccasionGiftCollectionGridView didSelectGlobalOccasionGiftSet:(HGGiftSet*)theGiftSet{
    if ([theGiftSet.gifts count] == 1){
        HGGift* theGift = [theGiftSet.gifts objectAtIndex:0];
        
        [HGTrackingService logEvent:kTrackingEventEnterGiftDetail withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"HGMainViewController", @"from", theGift.identifier, @"productId",theMainViewGlobalOccasionGiftCollectionGridView.giftCollection.occasion.occasionCategory.name, @"occasion", nil]];
        
        HGGiftDetailViewController* viewContoller = [[HGGiftDetailViewController alloc] initWithGift:theGift];
        [self.navigationController pushViewController:viewContoller animated:YES];
        [viewContoller release];
    }else{
        [HGTrackingService logEvent:kTrackingEventEnterGiftGroupDetail withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"HGMainViewController", @"from", nil]];
        HGGiftSetDetailViewController* viewContoller = [[HGGiftSetDetailViewController alloc] initWithGiftSet:theGiftSet];
        [self.navigationController pushViewController:viewContoller animated:YES];
        [viewContoller release];
    }
}

#pragma mark - HGMainViewPersonlizedOccasionGiftCollectionGridViewDelegate
- (void)mainViewPersonlizedOccasionGiftCollectionGridView:(HGMainViewPersonlizedOccasionGiftCollectionGridView *)themainViewPersonlizedOccasionGiftCollectionGridView didSelectGiftOccasions:(NSArray*)theGiftCollections{
    HGOccasionsListViewController* viewContoller = [[HGOccasionsListViewController alloc] initWithGiftCollections:theGiftCollections];
    [self.navigationController pushViewController:viewContoller animated:YES];
    [viewContoller release];
    
    HGOccasionGiftCollection* occasionGiftCollection = [theGiftCollections objectAtIndex:0];
    [HGTrackingService logEvent:kTrackingEventEnterOccasionList withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"HGMainViewController", @"from", occasionGiftCollection.occasion.occasionCategory.name, @"occasion", nil]];
}

- (void)mainViewPersonlizedOccasionGiftCollectionGridView:(HGMainViewPersonlizedOccasionGiftCollectionGridView *)themainViewPersonlizedOccasionGiftCollectionGridView didSelectPersonlizedOccasionGiftCollection:(HGOccasionGiftCollection*)theOccasionGiftCollection{
    HGOccasionDetailViewController* viewController = [[HGOccasionDetailViewController alloc] initWithGiftCollection:theOccasionGiftCollection];
    [self.navigationController pushViewController:viewController animated:YES];
    [viewController release];
    
    [HGTrackingService logEvent:kTrackingEventEnterOccasionDetail withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"HGMainViewController", @"from", theOccasionGiftCollection.occasion.occasionCategory.name, @"occasion", theOccasionGiftCollection.occasion.occasionTag.name, @"tag", nil]];
}

#pragma mark - HGMainViewSentGiftsGridViewDelegate
- (void)mainViewSentGiftsGridView:(HGMainViewSentGiftsGridView *)theMainViewSentGiftsGridView didSelectSentGiftOrders:(NSArray*)theGiftOrders{
    [HGTrackingService logEvent:kTrackingEventEnterSentGiftList withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"HGMainViewController", @"from", nil]];
    
    HGSentGiftsViewController* viewController = [[HGSentGiftsViewController alloc] initWithNibName:@"HGSentGiftsViewController" bundle:nil];
    [self.navigationController pushViewController:viewController animated:YES];
    [viewController release];
}

- (void)mainViewSentGiftsGridView:(HGMainViewSentGiftsGridView *)theMainViewSentGiftsGridView didSelectSentGiftOrder:(HGGiftOrder*)theGiftOrder{
    [HGTrackingService logEvent:kTrackingEventEnterSentGiftDetail withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"HGMainViewController", @"from", nil]];
    HGSentGiftDetailViewController* viewController = [[HGSentGiftDetailViewController alloc] initWithGiftOrder:theGiftOrder andShouldRefetchData:NO];
    [self.navigationController pushViewController:viewController animated:YES];
    [viewController release];
}

#pragma mark - HGMainViewRecommandationGridViewDelegate

- (void)mainViewRecommandationGridView:(HGMainViewFriendRecommandationGridView *)mainViewRecommandationGridView didSelectRecommandations:(NSArray*)recommandations {
    HGDebug(@"didSelectRecommandations");

   [HGTrackingService logEvent:kTrackingEventEnterFriendRecommendationList withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"HGMainViewController", @"from", nil]];
    
    HGFriendRecommandationListViewController* viewController = [[HGFriendRecommandationListViewController alloc] initWithFriendRecommandations:recommandations];
    [self.navigationController pushViewController:viewController animated:YES];
    [viewController release];
}

- (void)mainViewRecommandationGridView:(HGMainViewFriendRecommandationGridView *)mainViewRecommandationGridView didSelectRecommandation:(HGFriendRecommandation*)recommandation {
    HGDebug(@"didSelectRecommandation");
    
    HGGift* theGift = recommandation.gift;
    [HGRecipientService sharedService].selectedRecipient = recommandation.recipient;
    
    [HGTrackingService logEvent:kTrackingEventEnterGiftDetail withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"HGMainViewController", @"from", theGift.identifier, @"productId", nil]];
    
    HGGiftDetailViewController* viewContoller = [[HGGiftDetailViewController alloc] initWithGift:theGift];
    [self.navigationController pushViewController:viewContoller animated:YES];
    [viewContoller release];
}

#pragma mark - HGMainViewAstroTrendGridViewDelegate

- (void)mainViewAstroTrendGridView:(HGMainViewAstroTrendGridView *)mainViewAstroTrendGridView didSelectAstroTrends:(NSArray*)astroTrends {
    [HGTrackingService logEvent:kTrackingEventEnterAstroTrendList withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"HGMainViewController", @"from", nil]];
    
    HGAstroTrendListViewController* viewController = [[HGAstroTrendListViewController alloc] initWithAstroTrends:astroTrends];
    [self.navigationController pushViewController:viewController animated:YES];
    [viewController release];
}

- (void)mainViewAstroTrendGridView:(HGMainViewAstroTrendGridView *)mainViewAstroTrendGridView didSelectAstroTrend:(HGAstroTrend*)astroTrend {
    [HGTrackingService logEvent:kTrackingEventEnterAstroTrendDetail withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"HGMainViewController", @"from", nil]];
    
    HGAstroTrendDetailViewController* viewContoller = [[HGAstroTrendDetailViewController alloc] initWithAstroTrend:astroTrend];
    [self.navigationController pushViewController:viewContoller animated:YES];
    [viewContoller release];
}

#pragma mark - HGMainViewFriendEmotionGridViewDelegate
- (void)mainViewFriendEmotionGridView:(HGMainViewFriendEmotionGridView *)mainViewFriendEmotionGridView didSelectFriendEmotions:(NSArray*)friendEmotions {
    HGDebug(@"didSelectFriendEmotions");
    
    HGFriendEmotionListViewController* viewController = [[HGFriendEmotionListViewController alloc] initWithFriendEmotions:friendEmotions];
    [self.navigationController pushViewController:viewController animated:YES];
    [viewController release];
    
    [HGTrackingService logEvent:kTrackingEventEnterFriendEmotionList withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"HGMainViewController", @"from", nil]];
}

- (void)mainViewFriendEmotionGridView:(HGMainViewFriendEmotionGridView *)mainViewFriendEmotionGridView didSelectFriendEmotion:(HGFriendEmotion*)friendEmotion {
    HGDebug(@"didSelectFriendEmotion");
    
    HGFriendEmotionDetailViewController* viewContoller = [[HGFriendEmotionDetailViewController alloc] initWithFriendEmotion:friendEmotion];
    [self.navigationController pushViewController:viewContoller animated:YES];
    [viewContoller release];
    
    [HGTrackingService logEvent:kTrackingEventEnterFriendEmotionDetail withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"HGFriendEmotionListViewController", @"from", nil]];
}

#pragma mark - HGMainViewVirtualGiftGridViewDelegate
- (void)mainViewVirtualGiftGridViewDidSelectMoreGifts:(HGMainViewVirtualGiftGridView*)mainViewVirtualGiftGridView{
    
}

- (void)mainViewVirtualGiftGridViewDidSelectGIFGifts:(HGMainViewVirtualGiftGridView*)mainViewVirtualGiftGridView {
    NSMutableDictionary* gifts = [HGVirtualGiftService sharedService].gifGiftsByCategory;
    HGGIFGiftListViewController* viewController = [[HGGIFGiftListViewController alloc] initWithGIFGiftsByCategory:gifts];
    [self.navigationController pushViewController:viewController animated:YES];
    [viewController release];
    [HGTrackingService logEvent:kTrackingEventEnterGIFGifts withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"HGMainViewController", @"from", nil]];
}

- (void)mainViewVirtualGiftGridViewDidSelectDIYGifts:(HGMainViewVirtualGiftGridView*)mainViewVirtualGiftGridView{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] 
                                  initWithTitle:nil
                                  delegate:self 
                                  cancelButtonTitle:@"取消" 
                                  destructiveButtonTitle:nil 
                                  otherButtonTitles:@"从相册选择图片", @"拍摄一张新照片", nil];
    [actionSheet showInView:self.view];
    [actionSheet release];
}

- (void)didGlobalLogout {
    HGDebug(@"didGlobalLogout");
    weiboExpired = NO;
    renrenExpired = NO;
    
    // remove sns expire flag when do global logout
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:kHGPreferneceKeySNSTokenExpiration];
    [defaults synchronize];
}
@end

