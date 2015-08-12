//
//  HGOrderTypeConfirmViewController.m
//  HappyGift
//
//  Created by Yujian Weng on 12-6-27.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//

#import "HGOrderTypeConfirmViewController.h"
#import "HappyGiftAppDelegate.h"
#import "HGConstants.h"
#import "HGProgressView.h"
#import "HGOrderViewController.h"
#import "UIBarButtonItem+Addition.h"
#import <QuartzCore/QuartzCore.h>
#import "HGGiftOrder.h"
#import "HGTrackingService.h"
#import "HGAccountService.h"
#import "HGRecipientService.h"
#import "HGUtility.h"
#import "HGCardSelectionViewController.h"
#import "HGRecipientAddressViewController.h"
#import "HGRecipientService.h"
#import "HGUserImageView.h"

@interface HGOrderTypeConfirmViewController()<UIScrollViewDelegate, UITextFieldDelegate>
  
@end

@implementation HGOrderTypeConfirmViewController
- (id)initWithGiftOrder:(HGGiftOrder*)theGiftOrder{
    self = [super initWithNibName:@"HGOrderTypeConfirmViewController" bundle:nil];
    if (self){
        giftOrder = [theGiftOrder retain];
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    self.view.backgroundColor = [HappyGiftAppDelegate genericBackgroundColor];
    
    leftBarButtonItem = [[UIBarButtonItem alloc ] initNavigationBackImageBarButtonItem:@"navigation_back" target:self action:@selector(handleCancelAction:)];
    navigationBar.topItem.leftBarButtonItem = leftBarButtonItem;
    
    CGRect titleViewFrame = CGRectMake(20, 0, 180, 44);
    UIView* titleView = [[UIView alloc] initWithFrame:titleViewFrame];
    
    CGRect titleLabelFrame = CGRectMake(0, 0, 180, 40);
	UILabel *titleLabel = [[UILabel alloc] initWithFrame:titleLabelFrame];
	titleLabel.backgroundColor = [UIColor clearColor];
	titleLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:[HappyGiftAppDelegate naviagtionTitleFontSize]];;
    titleLabel.minimumFontSize = 20.0;
    titleLabel.adjustsFontSizeToFitWidth = YES;
	titleLabel.textAlignment = UITextAlignmentCenter;
	titleLabel.textColor = [UIColor whiteColor];
	titleLabel.text = @"送礼方式";
    [titleView addSubview:titleLabel];
    [titleLabel release];
    
	navigationBar.topItem.titleView = titleView;
    [titleView release];
    
    [recipientImageView updateUserImageViewWithRecipient:giftOrder.giftRecipient];
    [recipientImageView removeTagImage];
    
    sendToLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeSmall]];
    sendToLabel.textColor = [UIColor darkGrayColor];
    
    recipientNameLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:[HappyGiftAppDelegate fontSizeNormal]];
    recipientNameLabel.textColor = [UIColor blackColor];
    recipientNameLabel.text = giftOrder.giftRecipient.recipientDisplayName;
    
    orderTypeSelectionTitleLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:[HappyGiftAppDelegate fontSizeLarge]];
    orderTypeSelectionTitleLabel.textColor = [UIColor blackColor];
    
    quickOrderDescriptionLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeSmall]];
    quickOrderDescriptionLabel.textColor = [UIColor lightGrayColor];
    
    customizedOrderDescriptionLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeSmall]];
    customizedOrderDescriptionLabel.textColor = [UIColor lightGrayColor];
    
    quickOrderButton.titleLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:[HappyGiftAppDelegate fontSizeXLarge]];
    [quickOrderButton addTarget:self action:@selector(handleQuickOrderAction:) forControlEvents:UIControlEventTouchUpInside];
    UIImage* buttonBackgroundImage = [[UIImage imageNamed:@"gift_selection_button"] stretchableImageWithLeftCapWidth:5 topCapHeight:10];
    [quickOrderButton setBackgroundImage:buttonBackgroundImage forState:UIControlStateNormal];
    
    customizedOrderButton.titleLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:[HappyGiftAppDelegate fontSizeXLarge]];
    [customizedOrderButton addTarget:self action:@selector(handleCustomizedOrderAction:) forControlEvents:UIControlEventTouchUpInside];
    [customizedOrderButton setBackgroundImage:buttonBackgroundImage forState:UIControlStateNormal];

    progressView = [[HGProgressView progressView:self.view.frame] retain];
    [self.view addSubview:progressView];
    progressView.hidden = YES;
    
    CGSize contentSize = orderTypeConfirmScrollView.contentSize;
    contentSize.height = orderTypeConfirmScrollView.frame.size.height + 1.0;
    orderTypeConfirmScrollView.contentSize = contentSize;
}

- (void)viewDidUnload{
    [super viewDidUnload];
    [progressView removeFromSuperview];
    [progressView release];
    progressView = nil;
    
    [leftBarButtonItem release];
    leftBarButtonItem = nil;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void)dealloc{
    [progressView release];
    [leftBarButtonItem release];
    [orderTypeConfirmScrollView release];
    [giftOrder release];
    
    [recipientImageView release];
    
    [sendToLabel release];
    [recipientNameLabel release];
    [orderTypeSelectionTitleLabel release];
    [quickOrderDescriptionLabel release];
    [customizedOrderDescriptionLabel release];
    
    [quickOrderButton release];
    [customizedOrderButton release];
    
	[super dealloc];
}


- (void)handleCancelAction:(id)sender{
    [self dismissModalViewControllerAnimated:YES];
}

- (void)handleQuickOrderAction:(id)sender {
    giftOrder.orderType = kOrderTypeQuickOrder;
    giftOrder.orderNotifyDate = nil;
    giftOrder.giftCard = nil;
    giftOrder.giftDelivery = nil;
    
    HGRecipientAddressViewController* viewController = [[HGRecipientAddressViewController alloc] initWithGiftOrder:giftOrder];
    [self.navigationController pushViewController:viewController animated:YES];
    [viewController release];
    
    [HGTrackingService logEvent:kTrackingEventEnterRecipientAddressView withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"HGOrderTypeConfirmViewController", @"from", nil]];   
}

- (void)handleCustomizedOrderAction:(id)sender {
    giftOrder.orderType = kOrderTypeNormalOrder;
    giftOrder.orderNotifyDate = nil;
    giftOrder.giftCard = nil;
    giftOrder.giftDelivery = nil;
    
    HGCardSelectionViewController* viewController = [[HGCardSelectionViewController alloc] initWithGiftOrder:giftOrder];
    [self.navigationController pushViewController:viewController animated:YES];
    [viewController release];
    
    [HGTrackingService logEvent:kTrackingEventEnterGiftCard withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"HGOrderTypeConfirmViewController", @"from", nil]];
}

@end

