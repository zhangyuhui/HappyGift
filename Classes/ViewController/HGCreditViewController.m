//
//  HGCreditViewController.m
//  HappyGift
//
//  Created by Zhang Yuhui on 2/11/11.
//  Copyright 2011 Ztelic Inc Inc. All rights reserved.
//

#import "HGCreditViewController.h"
#import "HGProgressView.h"
#import "HappyGiftAppDelegate.h"
#import "HGConstants.h"
#import "HGProgressView.h"
#import "HGImageService.h"
#import "UIBarButtonItem+Addition.h"
#import "UIImage+Addition.h"
#import "HGDefines.h"
#import "HGCreditService.h"
#import "HGGiftSetsService.h"
#import "HGCreditHistory.h"
#import "HGGiftsSelectionViewController.h"
#import "WBEngine.h"
#import "HGRecipientSelectionViewController.h"
#import "HGShareViewController.h"
#import "HGAccountService.h"
#import "HGAccountViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <MessageUI/MessageUI.h>
#import "HGTrackingService.h"

#define kRecommendActionWeibo   0
#define kRecommendActionRenren  1
#define kRecommendActionMessage 2
#define kRecommendActionEmail   3
#define kRecommendActionCancel  4

#define CREDIT_TIMESTAMP_DATA_FORMAT @"yyyy年MM月dd日"

@interface HGCreditViewController()<UIScrollViewDelegate, HGCreditServiceDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate, HGRecipientSelectionViewControllerDelegate>
  
@end

@implementation HGCreditViewController


- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.view.backgroundColor = [HappyGiftAppDelegate genericBackgroundColor];
    
    leftBarButtonItem = [[UIBarButtonItem alloc ] initNavigationBackImageBarButtonItem:@"navigation_back" target:self action:@selector(handleBackAction:)];
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
    
    creditStartButton.titleLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeNormal]];
    creditStartButton.titleLabel.minimumFontSize = 14;
    creditStartButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    [creditStartButton addTarget:self action:@selector(handleCreditStartAction:) forControlEvents:UIControlEventTouchUpInside];
    
    creditTitleLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:[HappyGiftAppDelegate fontSizeNormal]];
    creditTitleLabel.textColor = [UIColor blackColor];
    creditTitleLabel.text = [NSString stringWithFormat:@"目前积分总计为"];
    
    CGSize creditTitleLabelSize = [creditTitleLabel.text sizeWithFont:creditTitleLabel.font];
    CGRect creditTitleLabelFrame = creditTitleLabel.frame;
    creditTitleLabelFrame.size.width = creditTitleLabelSize.width;
    creditTitleLabel.frame = creditTitleLabelFrame;
    
    creditValueLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:[HappyGiftAppDelegate fontSizeNormal]];
    creditValueLabel.textColor = UIColorFromRGB(0xd53d3b);
    creditValueLabel.text = [NSString stringWithFormat:@"%d", [HGCreditService sharedService].creditTotal];
    
    CGRect creditValueLabelFrame = creditValueLabel.frame;
    creditValueLabelFrame.origin.x = creditTitleLabelFrame.origin.x + creditTitleLabelFrame.size.width + 5.0;
    creditValueLabel.frame = creditValueLabelFrame;
    
    creditDescriptionLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeSmall]];
    creditDescriptionLabel.textColor = [UIColor darkGrayColor];
    creditDescriptionLabel.numberOfLines = 0;
    if ([HGCreditService sharedService].creditTotal > 100){
        [creditStartButton setTitle:@"选择礼物" forState:UIControlStateNormal];
        creditDescriptionLabel.text = [NSString stringWithFormat:@"您可以在购买礼物时使用积分抵消部分现金！"];
    }else{
        [creditStartButton setTitle:@"推荐乐送" forState:UIControlStateNormal];
        creditDescriptionLabel.text = [NSString stringWithFormat:@"您的积分有点少呦，推荐乐送或者分享礼单都是可以获取积分的！"];
    }
    creditStartButton.hidden = YES;
    
    CGRect creditDescriptionLabelFrame = creditDescriptionLabel.frame;
    //creditDescriptionLabelFrame.size.width = 320.0 - creditDescriptionLabelFrame.origin.x - creditStartButton.frame.size.width - 15.0;
    CGSize creditDescriptionLabelSize = [creditDescriptionLabel.text sizeWithFont:creditDescriptionLabel.font constrainedToSize:CGSizeMake(creditDescriptionLabelFrame.size.width, MAXFLOAT)];
    creditDescriptionLabelFrame.size.height = creditDescriptionLabelSize.height;
    creditDescriptionLabel.frame = creditDescriptionLabelFrame;
    
    CGRect creditHeaderViewFrame = creditHeaderView.frame;
    creditHeaderViewFrame.size.height = creditDescriptionLabelFrame.origin.y + creditDescriptionLabelFrame.size.height + 5.0;
    if (creditHeaderViewFrame.size.height < 60.0){
        creditHeaderViewFrame.size.height = 60.0;
    }
    creditHeaderView.frame = creditHeaderViewFrame;
    
    CGRect creditStartButtonFrame = creditStartButton.frame;
    creditStartButtonFrame.origin.y = (creditHeaderViewFrame.size.height - creditStartButtonFrame.size.height)/2.0;
    creditStartButton.frame = creditStartButtonFrame;
    
    CGRect creditHistoryViewFrame = creditHistoryView.frame;
    creditHistoryViewFrame.origin.y = creditHeaderViewFrame.origin.y + creditHeaderViewFrame.size.height;
    creditHistoryViewFrame.size.height = 460.0 - creditHistoryViewFrame.origin.y - 2.0;
    creditHistoryView.frame = creditHistoryViewFrame;
    
    CGRect creditRedeemViewFrame = creditRedeemView.frame;
    creditRedeemViewFrame = creditHeaderViewFrame;
    creditRedeemView.frame = creditHistoryViewFrame;
    
    creditHistoryTitleLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:[HappyGiftAppDelegate fontSizeNormal]];
    creditHistoryTitleLabel.textColor = [UIColor blackColor];
    
    CGFloat viewY = 5.0;
    CGFloat viewX = 5.0;
    
    NSArray* creditHistories = [HGCreditService sharedService].creditHistories;
    if (creditHistories != nil && [creditHistories count] > 0){
        creditHistoryTitleLabel.text = @"积分明细";
        int creditHistoryIndex = 1;
        for (HGCreditHistory* creditHistory in creditHistories){
            UILabel* creditHistoryDetailLabel = [[UILabel alloc] initWithFrame:CGRectMake(viewX, viewY, creditHistoryScrollView.frame.size.width - viewX*2.0, 20.0)];
            creditHistoryDetailLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeSmall]];
            creditHistoryDetailLabel.textColor = [UIColor darkGrayColor];
            creditHistoryDetailLabel.backgroundColor = [UIColor clearColor];
            creditHistoryDetailLabel.numberOfLines = 0;
            
            NSString* typeString;
            if (creditHistory.type == HG_CREDIT_TYPE_GAIN_INVITE){
                typeString = @"推荐好友";
            }else if (creditHistory.type == HG_CREDIT_TYPE_GAIN_SHARE_ORDER){
                typeString = @"分享礼单";
            }else if (creditHistory.type == HG_CREDIT_TYPE_GAIN_SHARE_APP){
                typeString = @"分享乐送";
            }else if (creditHistory.type == HG_CREDIT_TYPE_GAIN_PAY){
                typeString = @"发送礼物";
            }else if (creditHistory.type == HG_CREDIT_TYPE_CONSUME){
                typeString = @"购买礼物";
            }else if (creditHistory.type == HG_CREDIT_TYPE_GAIN_REDEEM){
                typeString = @"接受推荐";
            }else{
                continue;
            }
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:CREDIT_TIMESTAMP_DATA_FORMAT];
            NSString* dateString = [NSString stringWithFormat:@"%@", [dateFormatter stringFromDate:creditHistory.date]];
            [dateFormatter release];
            
            if (creditHistory.type == HG_CREDIT_TYPE_CONSUME){
                creditHistoryDetailLabel.text = [NSString stringWithFormat:@"%d. %@\"%@\"消费%d积分", creditHistoryIndex, dateString, typeString, creditHistory.value];
            }else{
                creditHistoryDetailLabel.text = [NSString stringWithFormat:@"%d. %@\"%@\"获取%d积分", creditHistoryIndex, dateString, typeString, creditHistory.value];
            }
            
            CGSize creditHistoryDetailLabelSize = [creditHistoryDetailLabel.text sizeWithFont:creditHistoryDetailLabel.font constrainedToSize:CGSizeMake(creditHistoryDetailLabel.frame.size.width, 2000.0) lineBreakMode:UILineBreakModeClip];
            CGRect creditHistoryDetailLabelFrame = creditHistoryDetailLabel.frame;
            creditHistoryDetailLabelFrame.size.height = creditHistoryDetailLabelSize.height;
            creditHistoryDetailLabel.frame = creditHistoryDetailLabelFrame;
            
            [creditHistoryScrollView addSubview:creditHistoryDetailLabel];
            [creditHistoryDetailLabel release];
            
            viewY += creditHistoryDetailLabelSize.height + 4.0;
            
            creditHistoryIndex += 1;
        }
    }else{
        creditHistoryTitleLabel.text = @"如何获取积分";
        {
            UILabel* creditHistoryDetailLabel = [[UILabel alloc] initWithFrame:CGRectMake(viewX, viewY, creditHistoryScrollView.frame.size.width - viewX*2.0, 20.0)];
            creditHistoryDetailLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeSmall]];
            creditHistoryDetailLabel.textColor = [UIColor darkGrayColor];
            creditHistoryDetailLabel.backgroundColor = [UIColor clearColor];
            creditHistoryDetailLabel.numberOfLines = 0;
            creditHistoryDetailLabel.text = @"1. 您可以通过推荐邀请好友使用乐送来赢取积分，当您的好友下载使用乐送并输入您发送给他的邀请码后，您和您的好友均可获取量值不菲的积分。";
            
            CGSize creditHistoryDetailLabelSize = [creditHistoryDetailLabel.text sizeWithFont:creditHistoryDetailLabel.font constrainedToSize:CGSizeMake(creditHistoryDetailLabel.frame.size.width, 2000.0) lineBreakMode:UILineBreakModeClip];
            CGRect creditHistoryDetailLabelFrame = creditHistoryDetailLabel.frame;
            creditHistoryDetailLabelFrame.size.height = creditHistoryDetailLabelSize.height;
            creditHistoryDetailLabel.frame = creditHistoryDetailLabelFrame;
            
            [creditHistoryScrollView addSubview:creditHistoryDetailLabel];
            [creditHistoryDetailLabel release];
            
            viewY += creditHistoryDetailLabelSize.height + 10.0;
        }
        {
            UILabel* creditHistoryDetailLabel = [[UILabel alloc] initWithFrame:CGRectMake(viewX, viewY, creditHistoryScrollView.frame.size.width - viewX*2.0, 20.0)];
            creditHistoryDetailLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeSmall]];
            creditHistoryDetailLabel.textColor = [UIColor darkGrayColor];
            creditHistoryDetailLabel.backgroundColor = [UIColor clearColor];
            creditHistoryDetailLabel.numberOfLines = 0;
            creditHistoryDetailLabel.text = @"2. 您可以把您的送礼过程分享出去，在微博或人人网上每成功分享一次送礼礼单，您就能获取一定量的鼓励积分。";
            
            CGSize creditHistoryDetailLabelSize = [creditHistoryDetailLabel.text sizeWithFont:creditHistoryDetailLabel.font constrainedToSize:CGSizeMake(creditHistoryDetailLabel.frame.size.width, 2000.0) lineBreakMode:UILineBreakModeClip];
            CGRect creditHistoryDetailLabelFrame = creditHistoryDetailLabel.frame;
            creditHistoryDetailLabelFrame.size.height = creditHistoryDetailLabelSize.height;
            creditHistoryDetailLabel.frame = creditHistoryDetailLabelFrame;
            
            [creditHistoryScrollView addSubview:creditHistoryDetailLabel];
            [creditHistoryDetailLabel release];
            
            viewY += creditHistoryDetailLabelSize.height + 10.0;
        }
        {
            UILabel* creditHistoryDetailLabel = [[UILabel alloc] initWithFrame:CGRectMake(viewX, viewY, creditHistoryScrollView.frame.size.width - viewX*2.0, 20.0)];
            creditHistoryDetailLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeSmall]];
            creditHistoryDetailLabel.textColor = [UIColor darkGrayColor];
            creditHistoryDetailLabel.backgroundColor = [UIColor clearColor];
            creditHistoryDetailLabel.numberOfLines = 0;
            creditHistoryDetailLabel.text = @"3. 您所获取的积分可以在礼物付款时兑换为现金使用，是否可以使用积分抵现以及可使用积分额度根据具体产品而定。";
            
            CGSize creditHistoryDetailLabelSize = [creditHistoryDetailLabel.text sizeWithFont:creditHistoryDetailLabel.font constrainedToSize:CGSizeMake(creditHistoryDetailLabel.frame.size.width, 2000.0) lineBreakMode:UILineBreakModeClip];
            CGRect creditHistoryDetailLabelFrame = creditHistoryDetailLabel.frame;
            creditHistoryDetailLabelFrame.size.height = creditHistoryDetailLabelSize.height;
            creditHistoryDetailLabel.frame = creditHistoryDetailLabelFrame;
            
            [creditHistoryScrollView addSubview:creditHistoryDetailLabel];
            [creditHistoryDetailLabel release];
            
            viewY += creditHistoryDetailLabelSize.height + 15.0;
        }
    }
    
    if ([HGCreditService sharedService].invited == NO){
        UIButton* creditRedeemButton = [[UIButton alloc] initWithFrame:CGRectMake(10.0, creditHistoryView.frame.size.height - 44.0, creditHistoryView.frame.size.width - (10.0)*2.0, 36.0)];
        creditRedeemButton.tag = 100;
        UIImage* creditRedeemButtonBackgroundImage = [[UIImage imageNamed:@"gift_selection_button"] stretchableImageWithLeftCapWidth:5.0 topCapHeight:1.0];
        [creditRedeemButton setBackgroundImage:creditRedeemButtonBackgroundImage forState:UIControlStateNormal];
        creditRedeemButton.titleLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:[HappyGiftAppDelegate fontSizeXLarge]];
        [creditRedeemButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];	
        [creditRedeemButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
        [creditRedeemButton setTitle:[NSString stringWithFormat:@"输入邀请码获取积分"] forState:UIControlStateNormal];
        
        [creditRedeemButton addTarget:self action:@selector(handleCreditRedeemAction:) forControlEvents:UIControlEventTouchUpInside];
        
        [creditHistoryView addSubview:creditRedeemButton];
        [creditRedeemButton release];
        
        viewY += 40.0;
    }
    
    CGSize creditHistoryScrollViewContentSize = creditHistoryScrollView.contentSize;
    creditHistoryScrollViewContentSize.height = viewY;
    if (creditHistoryScrollViewContentSize.height <= creditHistoryScrollView.frame.size.height ){
        creditHistoryScrollViewContentSize.height = creditHistoryScrollView.frame.size.height + 1.0;
    }
    [creditHistoryScrollView setContentSize:creditHistoryScrollViewContentSize];
        
    creditRedeemNameLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeNormal]];
    creditRedeemNameLabel.textColor = [UIColor darkGrayColor];
    creditRedeemNameLabel.text = @"邀请码";
    
    creditRedeemTextField.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeNormal]];
    creditRedeemTextField.textColor = [UIColor darkGrayColor];
    
    creditRedeemSubmitButton.titleLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeNormal]];
    creditRedeemSubmitButton.titleLabel.minimumFontSize = 14;
    creditRedeemSubmitButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    [creditRedeemSubmitButton setTitle:[NSString stringWithFormat:@"提交"] forState:UIControlStateNormal];
    
    [creditRedeemSubmitButton addTarget:self action:@selector(handleCreditRedeemSubmitAction:) forControlEvents:UIControlEventTouchUpInside];
    
    creditRedeemCancelButton.titleLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeNormal]];
    creditRedeemCancelButton.titleLabel.minimumFontSize = 14;
    creditRedeemCancelButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    [creditRedeemCancelButton setTitle:[NSString stringWithFormat:@"取消"] forState:UIControlStateNormal];
    
    [creditRedeemCancelButton addTarget:self action:@selector(handleCreditRedeemCancelAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UIImage* backgroundImage = [[UIImage imageNamed:@"setting_background"] stretchableImageWithLeftCapWidth:10 topCapHeight:10];
    [creditHistoryBackgroundView setImage:backgroundImage];
    
    creditRedeemView.hidden = YES;
    recommendRecipientSelected = NO;
    
    progressView = [[HGProgressView progressView:self.view.frame] retain];
    [self.view addSubview:progressView];
    progressView.hidden = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAccountUpdated:) name:kHGNotificationAccountUpdated object:nil];
    
    [[HGCreditService sharedService] requestCreditTotal];
}

- (void)viewDidUnload{
    [super viewDidUnload];
    [progressView removeFromSuperview];
    [progressView release];
    progressView = nil;
    [leftBarButtonItem release];
    leftBarButtonItem = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kHGNotificationAccountUpdated object:nil];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
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

- (void)dealloc {    
    if (progressView != nil){
        [progressView release];
        progressView = nil;
    }
    if (leftBarButtonItem != nil){
        [leftBarButtonItem release];
        leftBarButtonItem = nil;
    }
    [creditHeaderView release];
    [creditTitleLabel release];
    [creditValueLabel release];
    [creditStartButton release];
    [creditDescriptionLabel release];
    [creditHistoryView release];
    [creditHistoryTitleLabel release];
    [creditHistoryBackgroundView release];
    [creditRedeemView release];
    [creditRedeemNameLabel release];
    [creditRedeemSubmitButton release];
    [creditRedeemCancelButton release];
    [creditRedeemTextField release];
    [creditHistoryScrollView release];
    [creditRedeemInputView release];
    [recommendRecipient release];
    HGCreditService* creditService = [HGCreditService sharedService];
    creditService.delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kHGNotificationAccountUpdated object:nil];
    [super dealloc];
}

- (void)handleBackAction:(id)sender{
    HGCreditService* creditService = [HGCreditService sharedService];
    creditService.delegate = nil;
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)handleCreditStartAction:(id)sender {
    if ([HGCreditService sharedService].creditTotal > 100){
        NSDictionary* giftSets = [HGGiftSetsService sharedService].giftSets;
        HGGiftsSelectionViewController* viewContoller = [[HGGiftsSelectionViewController alloc] initWithGiftSets:giftSets currentGiftCategory:nil];
        [self.navigationController pushViewController:viewContoller animated:YES];
        [viewContoller release];
    }else{
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

- (void)handleCreditRedeemAction:(id)sender {
    if ([[HGAccountService sharedService] hasSNSAccountLoggedIn]) {
        if (creditRedeemView.hidden == YES){
            CGRect creditRedeemViewFrame = creditRedeemView.frame;
            creditRedeemViewFrame.origin.y = 480.0;
            creditRedeemView.frame = creditRedeemViewFrame;
            creditRedeemView.hidden = NO;
            creditRedeemTextField.text = @"";
            [UIView animateWithDuration:0.4 
                                  delay:0.0 
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 CGRect creditRedeemViewFrame = creditRedeemView.frame;
                                 creditRedeemViewFrame.origin.y = creditHistoryView.frame.origin.y;
                                 creditRedeemView.frame = creditRedeemViewFrame;
                             } 
                             completion:^(BOOL finished) {
                                 creditHistoryView.hidden = YES;
                                 [creditRedeemTextField becomeFirstResponder];
                             }];
        }
    }else{
        HGAccountViewController* viewController = [[HGAccountViewController alloc] initWithNibName:@"HGAccountViewController" bundle:nil];
        [self presentModalViewController:viewController animated:YES];
        [viewController release];
        [HGTrackingService logPageView];
    }
}

- (void)handleCreditRedeemSubmitAction:(id)sender {
    NSString* invitation = creditRedeemTextField.text;
    invitation = [invitation stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([invitation isEqualToString:@""] == YES){
        [self performBounceViewAnimation:creditRedeemInputView];
    }else{
        [creditRedeemTextField resignFirstResponder];
        [progressView startAnimation];
        HGCreditService* creditService = [HGCreditService sharedService];
        creditService.delegate = self;
        [creditService requestCreditByInvitation:invitation];
    }
}

- (void)handleCreditRedeemCancelAction:(id)sender {
    if (creditRedeemView.hidden == NO){
        creditHistoryView.hidden = NO;
        [creditRedeemTextField resignFirstResponder];
        [UIView animateWithDuration:0.4 
                              delay:0.0 
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             CGRect creditRedeemViewFrame = creditRedeemView.frame;
                             creditRedeemViewFrame.origin.y = 480.0;
                             creditRedeemView.frame = creditRedeemViewFrame;
                         } 
                         completion:^(BOOL finished) {
                             creditRedeemView.hidden = YES;
                         }];
    }
}

- (void)handleAccountUpdated:(NSNotification *)notification{
    [[HGCreditService sharedService] requestCreditTotal];
}

- (void)performBounceViewAnimation:(UIView*)bounceView{
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position.x"];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    animation.duration = 0.5;
    NSMutableArray *values = [[NSMutableArray alloc] init];
    CGFloat minValue = bounceView.layer.position.x - 5.0;
    CGFloat maxValue = bounceView.layer.position.x + 5.0;
    CGFloat currentValue = bounceView.layer.position.x;
    CGFloat stepValue = 2.0;
    BOOL increase = YES;
    int bounces = 0;
    while (bounces < 3) {
        if (increase == YES){
            currentValue += stepValue;
        }else{
            currentValue -= stepValue;
        }
        [values addObject:[NSNumber numberWithFloat:currentValue]];
        if (increase == YES){
            if (currentValue > maxValue){
                increase = NO;
            }
        }else{
            if (currentValue < minValue){
                increase = YES;
                bounces += 1;
            }
        }
    }
    animation.values = values;
    [values release];
    
    animation.removedOnCompletion = YES;
    animation.fillMode = kCAFillModeForwards;
    animation.delegate = self;
    [bounceView.layer addAnimation:animation forKey:nil];
}

- (void)recommedAppByWeibo{
    HGShareViewController* viewController = [[HGShareViewController alloc] initWithInvition:@"" network:NETWORK_SNS_WEIBO];
    [self presentModalViewController:viewController animated:YES];
    [viewController release];
    [HGTrackingService logPageView];
}

- (void)recommedAppByRenren{
    HGShareViewController* viewController = [[HGShareViewController alloc] initWithInvition:@"" network:NETWORK_SNS_RENREN];
    [self presentModalViewController:viewController animated:YES];
    [viewController release];
    [HGTrackingService logPageView];
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
    } else {   
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

#pragma mark HGCreditServiceDelegate
- (void)creditService:(HGCreditService *)creditService didRequestCreditByInvitationSucceed:(int)credit{
    [progressView stopAnimation];
    if (credit > 0){
        if (creditRedeemView.hidden == NO){
            creditHistoryView.hidden = NO;
            [creditRedeemTextField resignFirstResponder];
            UIButton* creditRedeemButton = (UIButton*)[creditHistoryScrollView viewWithTag:100];
            creditRedeemButton.hidden = YES;
            [UIView animateWithDuration:0.4 
                                  delay:0.0 
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 CGRect creditRedeemViewFrame = creditRedeemView.frame;
                                 creditRedeemViewFrame.origin.y = 480.0;
                                 creditRedeemView.frame = creditRedeemViewFrame;
                             } 
                             completion:^(BOOL finished) {
                                 creditRedeemView.hidden = YES;
                                 HappyGiftAppDelegate *appDelegate = (HappyGiftAppDelegate *)[[UIApplication sharedApplication] delegate];
                                 [appDelegate sendNotification:[NSString stringWithFormat:@"成功获得%d个积分", credit]];
                                 creditValueLabel.text = [NSString stringWithFormat:@"%d", [HGCreditService sharedService].creditTotal];
                             }];
        }
    }else{
        HappyGiftAppDelegate *appDelegate = (HappyGiftAppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate sendNotification:[NSString stringWithFormat:@"获取积分失败"]];
    }
}

- (void)creditService:(HGCreditService *)creditService didRequestCreditByInvitationFail:(NSString*)error{
    [progressView stopAnimation];
    HappyGiftAppDelegate *appDelegate = (HappyGiftAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate sendNotification:@"获取邀请积分失败"];
}

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

#pragma mark  UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0){
        recommendAction = kRecommendActionMessage;
    }else if (buttonIndex == 1){
        recommendAction = kRecommendActionEmail;
    } else {
        recommendAction = kRecommendActionCancel;
    }
    
    if (recommendAction == kRecommendActionMessage ||
        recommendAction == kRecommendActionEmail){
        HGRecipientSelectionViewController* viewController = [[HGRecipientSelectionViewController alloc] initWithRecipientSelectionType:1];
        viewController.delegate = self;
        [self presentModalViewController:viewController animated:YES];
        [viewController release];
        [HGTrackingService logPageView];
        [HGTrackingService logEvent:kTrackingEventEnterRecipientSelection withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"HGCreditViewController", @"from", nil]];
    }
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

