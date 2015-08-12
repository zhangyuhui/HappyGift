//
//  HGAboutViewController.m
//  HappyGift
//
//  Created by Yuhui Zhang on 8/21/11.
//  Copyright 2011 Ztelic Inc. All rights reserved.
//

#import "HGAboutViewController.h"
#import "HappyGiftAppDelegate.h"
#import "HGProgressView.h"
#import "UIBarButtonItem+Addition.h"
#import "HGUtility.h"
#import "HGAppConfigurationService.h"
#import "HGLogging.h"
#import "HGDefines.h"
#import "WBEngine.h"
#import "HGAccountViewController.h"
#import "HGTrackingService.h"

@interface HGAboutViewController () <WBEngineDelegate>

@end

@implementation HGAboutViewController

#pragma mark - View lifecycle
- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"about_background.jpg"]];
    
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
	titleLabel.text = @"关于我们";
    [titleView addSubview:titleLabel];
    [titleLabel release];
    
	navigationBar.topItem.titleView = titleView;
    [titleView release];
    
    progressView = [[HGProgressView progressView:self.view.frame] retain];
    [self.view addSubview:progressView];
    progressView.hidden = YES;
    
    CGFloat viewX = 15.0;
    CGFloat viewY = 5.0;
    CGFloat viewWidth = contentScrollView.frame.size.width - viewX*2.0;;
    
    UILabel* aboutTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(viewX, viewY, viewWidth, 20.0)];
    aboutTitleLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:[HappyGiftAppDelegate fontSizeLarge]];
    aboutTitleLabel.textColor = [UIColor blackColor];
    aboutTitleLabel.backgroundColor = [UIColor clearColor];
    aboutTitleLabel.text = @"乐送简介";
    [contentScrollView addSubview:aboutTitleLabel];
    [aboutTitleLabel release];
    
    viewY += 22.0;
    
    HGAppConfigurationService* appConfigurationService = [HGAppConfigurationService sharedService];
    
    UILabel* aboutContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(viewX, viewY, viewWidth, 10.0)];
    aboutContentLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeNormal]];
    aboutContentLabel.textColor = [UIColor darkGrayColor];
    aboutContentLabel.numberOfLines = 0;
    aboutContentLabel.backgroundColor = [UIColor clearColor];
    aboutContentLabel.text = [appConfigurationService aboutUsContent];
    
    CGRect aboutContentLabelFrame = aboutContentLabel.frame;
    CGSize aboutContentLabelSize = [aboutContentLabel.text sizeWithFont:aboutContentLabel.font constrainedToSize:CGSizeMake(aboutContentLabelFrame.size.width, MAXFLOAT) lineBreakMode:UILineBreakModeCharacterWrap];
    aboutContentLabelFrame.size.height = aboutContentLabelSize.height;
    aboutContentLabel.frame = aboutContentLabelFrame;
    [contentScrollView addSubview:aboutContentLabel];
    [aboutContentLabel release];
    
    viewY += 125.0;
    
    UILabel* aboutContactTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(viewX, viewY, viewWidth, 20.0)];
    aboutContactTitleLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:[HappyGiftAppDelegate fontSizeLarge]];
    aboutContactTitleLabel.textColor = [UIColor blackColor];
    aboutContactTitleLabel.backgroundColor = [UIColor clearColor];
    aboutContactTitleLabel.text = @"联系我们";

    [contentScrollView addSubview:aboutContactTitleLabel];
    [aboutContactTitleLabel release];
    viewY += 22.0;
    
    UILabel* aboutContactSiteLabel = [[UILabel alloc] initWithFrame:CGRectMake(viewX, viewY, 100.0, 20.0)];
    aboutContactSiteLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeNormal]];
    aboutContactSiteLabel.textColor = [UIColor darkGrayColor];
    aboutContactSiteLabel.backgroundColor = [UIColor clearColor];
    aboutContactSiteLabel.text = @"网站：";
    
    CGSize aboutContactSiteLabelSize = [aboutContactSiteLabel.text sizeWithFont:aboutContactSiteLabel.font];
    CGFloat aboutContactSiteValueButtonX = aboutContactSiteLabel.frame.origin.x + aboutContactSiteLabelSize.width;
    
    [contentScrollView addSubview:aboutContactSiteLabel];
    [aboutContactSiteLabel release];
    
    UIButton* aboutContactSiteValueButton = [[UIButton alloc] initWithFrame:CGRectMake(aboutContactSiteValueButtonX, viewY, viewWidth - aboutContactSiteValueButtonX, 20.0)];
    [aboutContactSiteValueButton addTarget:self action:@selector(handleContactSiteValueButtonTouchUp:) forControlEvents:UIControlEventTouchUpInside];
    [aboutContactSiteValueButton addTarget:self action:@selector(handleContactSiteValueButtonTouchDown:) forControlEvents:UIControlEventTouchDown];
    [aboutContactSiteValueButton addTarget:self action:@selector(handleContactSiteValueButtonTouchUpOutSide:) forControlEvents:UIControlEventTouchUpOutside];
    
    [contentScrollView addSubview:aboutContactSiteValueButton];
    [aboutContactSiteValueButton release];    
    
    UILabel* aboutContactSiteValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(aboutContactSiteValueButtonX, viewY, viewWidth - aboutContactSiteValueButtonX, 20.0)];
    aboutContactSiteValueLabel.textColor = UIColorFromRGB(0x0036a0);
    aboutContactSiteValueLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeNormal]];
    aboutContactSiteValueLabel.text = [appConfigurationService aboutUsWebSite];
    aboutContactSiteValueLabel.backgroundColor = [UIColor clearColor];
    
    [contentScrollView addSubview:aboutContactSiteValueLabel];
    [aboutContactSiteValueLabel release];
    
    viewY += 20.0;
    
    UILabel* aboutContactEmailLabel = [[UILabel alloc] initWithFrame:CGRectMake(viewX, viewY, 100.0, 20.0)];
    aboutContactEmailLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeNormal]];
    aboutContactEmailLabel.textColor = [UIColor darkGrayColor];
    aboutContactEmailLabel.backgroundColor = [UIColor clearColor];
    aboutContactEmailLabel.text = [NSString stringWithFormat:@"邮箱："];
    
    CGSize aboutContactEmailLabelSize = [aboutContactEmailLabel.text sizeWithFont:aboutContactEmailLabel.font];
    CGFloat aboutContactEmailValueButtonX = aboutContactEmailLabel.frame.origin.x + aboutContactEmailLabelSize.width;
    
    [contentScrollView addSubview:aboutContactEmailLabel];
    [aboutContactEmailLabel release];
    
    UIButton* aboutContactEmailButton = [[UIButton alloc] initWithFrame:CGRectMake(aboutContactEmailValueButtonX, viewY, viewWidth - aboutContactEmailValueButtonX, 20.0)];
    [aboutContactEmailButton addTarget:self action:@selector(handleContactEmailButtonTouchUp:) forControlEvents:UIControlEventTouchUpInside];
    [aboutContactEmailButton addTarget:self action:@selector(handleContactEmailButtonTouchDown:) forControlEvents:UIControlEventTouchDown];
    [aboutContactEmailButton addTarget:self action:@selector(handleContactEmailButtonTouchUpOutSide:) forControlEvents:UIControlEventTouchUpOutside];
    
    [contentScrollView addSubview:aboutContactEmailButton];
    [aboutContactEmailButton release];    
    
    UILabel* aboutContactEmailValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(aboutContactEmailValueButtonX, viewY, viewWidth - aboutContactEmailValueButtonX, 20.0)];
    aboutContactEmailValueLabel.textColor = UIColorFromRGB(0x0036a0);
    aboutContactEmailValueLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeNormal]];
    aboutContactEmailValueLabel.text = [appConfigurationService aboutUsEmail];
    aboutContactEmailValueLabel.backgroundColor = [UIColor clearColor];
    
    [contentScrollView addSubview:aboutContactEmailValueLabel];
    [aboutContactEmailValueLabel release];

    viewY += 20.0;
    
    UILabel* aboutContactPhoneLabel = [[UILabel alloc] initWithFrame:CGRectMake(viewX, viewY, viewWidth, 20.0)];
    aboutContactPhoneLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeNormal]];
    aboutContactPhoneLabel.textColor = [UIColor darkGrayColor];
    aboutContactPhoneLabel.backgroundColor = [UIColor clearColor];
    aboutContactPhoneLabel.text = [NSString stringWithFormat:@"电话：%@", [appConfigurationService aboutUsPhone]];
    aboutContactPhoneLabel.hidden = YES;
    [contentScrollView addSubview:aboutContactPhoneLabel];
    [aboutContactPhoneLabel release];
    
    viewY += 35.0;
    
    UILabel* termsTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(viewX, viewY, viewWidth, 20.0)];
    termsTitleLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:[HappyGiftAppDelegate fontSizeLarge]];
    termsTitleLabel.textColor = [UIColor blackColor];
    termsTitleLabel.backgroundColor = [UIColor clearColor];
    termsTitleLabel.text = @"特别说明";
    [contentScrollView addSubview:termsTitleLabel];
    [termsTitleLabel release];
    
    viewY += 22.0;
    
    UILabel* termsContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(viewX, viewY, viewWidth, 10.0)];
    termsContentLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeNormal]];
    termsContentLabel.textColor = [UIColor darkGrayColor];
    termsContentLabel.numberOfLines = 0;
    termsContentLabel.backgroundColor = [UIColor clearColor];
    termsContentLabel.text = @"礼品的配送、售后等服务由礼品供应商负责。";
    
    CGRect termsContentLabelFrame = termsContentLabel.frame;
    CGSize termsContentLabelSize = [termsContentLabel.text sizeWithFont:termsContentLabel.font constrainedToSize:CGSizeMake(termsContentLabelFrame.size.width, MAXFLOAT) lineBreakMode:UILineBreakModeCharacterWrap];
    termsContentLabelFrame.size.height = termsContentLabelSize.height;
    termsContentLabel.frame = termsContentLabelFrame;
    [contentScrollView addSubview:termsContentLabel];
    [termsContentLabel release];
    
    viewY += termsContentLabelSize.height;
    
    CGSize contentSize = contentScrollView.contentSize;
    contentSize.height = viewY;
    contentScrollView.contentSize = contentSize;
    
    [followUsButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [followUsButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    followUsButton.titleLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:[HappyGiftAppDelegate fontSizeSmall]];
    [followUsButton addTarget:self action:@selector(handleFollowUsButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel* buildLabel = [[UILabel alloc] initWithFrame:CGRectMake(40.0, 428.0, self.view.frame.size.width - 80.0, 20.0)];
    buildLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeMicro]];
    buildLabel.textColor = [UIColor darkGrayColor];
    buildLabel.backgroundColor = [UIColor clearColor];
    buildLabel.textAlignment = UITextAlignmentRight;
    buildLabel.text = [NSString stringWithFormat:@"version %@  build %@", [HGUtility appVersion], [HGUtility appBuild]];
    
    [self.view addSubview:buildLabel];
    [buildLabel release];
}


- (void)dealloc{
    [navigationBar release];
    [progressView release];
    [leftBarButtonItem release];
    [contentScrollView release];
    
    WBEngine* engine = [WBEngine sharedWeibo];
    if (engine.delegate == self) {
        engine.delegate = nil;
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

-(void) handleFollowUsButtonTouchUpInside:(id)sender {
    if ([[WBEngine sharedWeibo] isLoggedIn]) {
        [WBEngine sharedWeibo].delegate = self;
        [[WBEngine sharedWeibo] followUser:@"2496475640" andUserName:@"乐送App"];
    } else {
        HGAccountViewController* viewController = [[HGAccountViewController alloc] initWithNibName:@"HGAccountViewController" bundle:nil];
        [self presentModalViewController:viewController animated:YES];
        [viewController release];
        [HGTrackingService logPageView];
    }
}

-(void) handleContactSiteValueButtonTouchUpOutSide:(id)sender {
     ((UIButton*)sender).backgroundColor = [UIColor clearColor];
}

- (void)handleCancelAction:(id)sender{
    [self dismissModalViewControllerAnimated:YES];
}

- (void)handleContactSiteValueButtonTouchUp:(id)sender {
    ((UIButton*)sender).backgroundColor = [UIColor clearColor];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[[HGAppConfigurationService sharedService] aboutUsWebSite]]];
}

- (void)handleContactSiteValueButtonTouchDown:(id)sender {
    ((UIButton*)sender).backgroundColor = [UIColor lightGrayColor];
}

-(void) handleContactEmailButtonTouchUpOutSide:(id)sender {
    ((UIButton*)sender).backgroundColor = [UIColor clearColor];
}

- (void)handleContactEmailButtonTouchUp:(id)sender {
    HGDebug(@"handleContactEmailButtonTouchUp");
    ((UIButton*)sender).backgroundColor = [UIColor clearColor];
    NSString* mailToUrl = [[NSString stringWithFormat:@"mailto:%@", [[HGAppConfigurationService sharedService] aboutUsEmail]] stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
    HGDebug(@"%@", mailToUrl);
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:mailToUrl]];
}

- (void)handleContactEmailButtonTouchDown:(id)sender {
    ((UIButton*)sender).backgroundColor = [UIColor lightGrayColor];
}

#pragma mark WBEngineDelegate
- (void)engine:(WBEngine *)engine requestDidFailWithError:(NSError *)error{
    if (error && [[error.userInfo objectForKey:@"error_code"] intValue] == 20506) {
        HappyGiftAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
        [appDelegate sendNotification:@"您已关注乐送App"];
    }
    followUsButton.userInteractionEnabled = YES;
}

- (void)engine:(WBEngine *)engine requestDidSucceedWithResult:(id)result{
    followUsButton.userInteractionEnabled = YES;
    HappyGiftAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    [appDelegate sendNotification:@"成功关注乐送App"];
}

@end
