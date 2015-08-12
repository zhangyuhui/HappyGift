//
//  HGGiftDetailViewController.m
//  HappyGift
//
//  Created by Zhang Yuhui on 2/11/11.
//  Copyright 2011 Ztelic Inc Inc. All rights reserved.
//

#import "HGGiftDetailViewController.h"
#import "HappyGiftAppDelegate.h"
#import "HGConstants.h"
#import "HGProgressView.h"
#import "HGGift.h"
#import "HGGiftOrder.h"
#import "HGImageService.h"
#import "HGRecipientSelectionViewController.h"
#import "HGPageControl.h"
#import "HGCardSelectionViewController.h"
#import "HGImageViewController.h"
#import "HGSentGiftDetailViewController.h"
#import "HGTrackingService.h"
#import "UIBarButtonItem+Addition.h"
#import "UIImage+Addition.h"
#import "HGUtility.h"
#import <QuartzCore/QuartzCore.h>
#import "HGGiftSetsService.h"
#import "HGLogging.h"
#import "HGAccountViewController.h"
#import "HGShareViewController.h"
#import "WBEngine.h"
#import "HGEraseLineLabel.h"
#import "HGOrderTypeConfirmViewController.h"
#import "HGRecipientContactViewController.h"

@interface HGGiftDetailViewController()<UIScrollViewDelegate, UINavigationControllerDelegate, HGRecipientSelectionViewControllerDelegate, HGGiftSetsServiceDelegate, UIActionSheetDelegate>
  
@end

@implementation HGGiftDetailViewController

- (id)initWithGift:(HGGift*)theGift{
    self = [super initWithNibName:@"HGGiftDetailViewController" bundle:nil];
    if (self){
        giftOrder = [[HGGiftOrder alloc] init];
        giftOrder.gift = theGift;
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    giftStarted = NO;
    self.view.backgroundColor = [HappyGiftAppDelegate genericBackgroundColor];
    
    leftBarButtonItem = [[UIBarButtonItem alloc ] initNavigationBackImageBarButtonItem:@"navigation_back" target:self action:@selector(handleBackAction:)];
    navigationBar.topItem.leftBarButtonItem = leftBarButtonItem; 
    navigationBar.topItem.rightBarButtonItem = nil;
    
    [recipientButton addTarget:self action:@selector(handleRecipientButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [addButton addTarget:self action:@selector(handleAddButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UIImage* addButtonBackgroundImage = [[UIImage imageNamed:@"gift_selection_button"] stretchableImageWithLeftCapWidth:5 topCapHeight:10];
    [addButton setBackgroundImage:addButtonBackgroundImage forState:UIControlStateNormal];
    
    recipientLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:[HappyGiftAppDelegate fontSizeLarge]];
    recipientLabel.textColor = [UIColor whiteColor];
    recipientLabel.backgroundColor = [UIColor clearColor];
    recipientLabel.textAlignment = UITextAlignmentLeft;
    
    [[HGRecipientService sharedService] updateRecipientLabel:recipientLabel];
    
    addButton.titleLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:[HappyGiftAppDelegate fontSizeXLarge]];
    [addButton setTitle:@"选择这件礼物" forState:UIControlStateNormal];
    [addButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [addButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    
    creditLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeSmall]];
    creditLabel.textColor = UIColorFromRGB(0xd53d3b);
    creditLabel.backgroundColor = [UIColor clearColor];
    creditLabel.textAlignment = UITextAlignmentLeft;
    creditLabel.numberOfLines = 0;
    creditLabel.adjustsFontSizeToFitWidth = NO;
    creditLabel.hidden = YES;
    
    favoriteButton.titleLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeSmall]];
    favoriteButton.titleLabel.minimumFontSize = 10.0;
    favoriteButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    [favoriteButton setTitle:[NSString stringWithFormat:@"%d", giftOrder.gift.likeCount] forState:UIControlStateNormal];
    [favoriteButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [favoriteButton setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    [favoriteButton addTarget:self action:@selector(handleFavoriteButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [favoriteButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, -5)];
    
    shareButton.titleLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeTiny]];
    shareButton.titleLabel.minimumFontSize = 10.0;
    shareButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    [shareButton setTitle:@"" forState:UIControlStateNormal];
    [shareButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [shareButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [shareButton addTarget:self action:@selector(handleShareButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    favoriteButton.selected = [[HGGiftSetsService sharedService] isMyLike:giftOrder.gift];
    
    contentView.hidden = YES;
    addButton.hidden = YES;
    addButtonBackground.hidden = YES;
    
    progressView = [[HGProgressView progressView:self.view.frame] retain];
    [self.view addSubview:progressView];
    progressView.hidden = YES;
    
    [progressView startAnimation];
    
    if ((!giftOrder.gift.description || [@"" isEqualToString:giftOrder.gift.description]) && (!giftOrder.gift.introduction || [@"" isEqualToString:giftOrder.gift.introduction]) && (!giftOrder.gift.review || [@"" isEqualToString:giftOrder.gift.review]) && (!giftOrder.gift.recommend || [@"" isEqualToString:giftOrder.gift.recommend])) {
        HGGiftSetsService* service = [HGGiftSetsService sharedService];
        service.delegate = self;
        [service requestGiftDetail:giftOrder.gift.identifier];
    } else {
        [self performSelector:@selector(updateGiftDetailDisplay) withObject:nil afterDelay:0.01];
    }
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

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (giftStarted) {
        giftStarted = NO;
        if ([HGRecipientService sharedService].selectedRecipient) {
            [self navigateToGiftCardSelector];
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

#pragma mark HGRecipientSelectionViewControllerDelegate
- (void)didRecipientSelected: (HGRecipient*) recipient {
    [[HGRecipientService sharedService] updateRecipientLabel:recipientLabel];
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
	[contentView release];
    [detailView release];
    [coverView release];
    [addButton release];
    [coverPriceLabel release];
    [coverBasePriceLabel release];
    [coverPriceImageView release];
    [recipientButton release];
    [recipientLabel release];
    [coverHeaderImageView release];
    [coverBackgroundImageView release];
    [coverImagesScrollView release];
    [coverTitleLabel release];
    [coverManufacturerLabel release];
    [coverImagesPageControl release];
    [socialView release];
    [favoriteButton release];
    [shareButton release];
    [creditLabel release];
    if (progressView != nil){
        [progressView release];
        progressView = nil;
    }
    if (leftBarButtonItem != nil){
        [leftBarButtonItem release];
        leftBarButtonItem = nil;
    }
    [contentSubViews release];
    [giftOrder release];
    if (coverImagesLoadingPool != nil){
        [coverImagesLoadingPool release];
        coverImagesLoadingPool = nil;
    }
    if (coverImagesPendingPool != nil){
        [coverImagesPendingPool release];
        coverImagesPendingPool = nil;
    }
    
    HGGiftSetsService* service = [HGGiftSetsService sharedService];
    if (service.delegate == self) {
        service.delegate = nil;
    }
    
    [super dealloc];
}

- (void)handleBackAction:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)showRecipientSelector {
    [HGTrackingService logEvent:kTrackingEventEnterRecipientSelection withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"HGGiftDetailViewController", @"from", nil]];
    
    HGRecipientSelectionViewController* viewController = [[HGRecipientSelectionViewController alloc] initWithNibName:@"HGRecipientSelectionViewController" bundle:nil];
    viewController.delegate = self;
    [self presentModalViewController:viewController animated:YES];
    [viewController release];
    [HGTrackingService logPageView];
}

- (void)navigateToGiftCardSelector {
    
    if (giftOrder.giftCard != nil){
        giftOrder.giftCard = nil;
    }
    
    if (giftOrder.giftDelivery != nil){
        giftOrder.giftDelivery = nil;
    }
    
    giftOrder.giftRecipient = [HGRecipientService sharedService].selectedRecipient;
    
    if (giftOrder.gift.type == GIFT_TYPE_COUPON){
        giftOrder.orderType = kOrderTypeQuickOrder;
        giftOrder.orderNotifyDate = nil;
        giftOrder.giftCard = nil;
        if (giftOrder.giftDelivery == nil) {
            HGGiftDelivery* theGiftDelivery = [[HGGiftDelivery alloc] init];
            theGiftDelivery.email = giftOrder.giftRecipient.recipientEmail;
            theGiftDelivery.phone = giftOrder.giftRecipient.recipientPhone;
            giftOrder.giftDelivery = theGiftDelivery;
            [theGiftDelivery release];
        }
        
        HGRecipientContactViewController* viewController = [[HGRecipientContactViewController alloc] initWithGiftOrder:giftOrder];
        
        UINavigationController* navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
        navigationController.delegate = self;
        [navigationController setNavigationBarHidden:YES];
        [HGTrackingService logAllPageViews:navigationController];
        [self presentModalViewController:navigationController animated:YES];
        [viewController release];
        
        [HGTrackingService logEvent:kTrackingEventEnterRecipientContactView withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"HGGiftDetailViewController", @"from", nil]];
    }else{
        HGOrderTypeConfirmViewController* viewController = [[HGOrderTypeConfirmViewController alloc] initWithGiftOrder:giftOrder];
        UINavigationController* navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
        navigationController.delegate = self;
        [navigationController setNavigationBarHidden:YES];
        [HGTrackingService logAllPageViews:navigationController];
        [self presentModalViewController:navigationController animated:YES];
        [viewController release];
        [navigationController release];
    }
}

- (void)handleRecipientButtonAction:(id)sender{
    [self showRecipientSelector];
}

- (void)handleAddButtonAction:(id)sender {
    if ([HGRecipientService sharedService].selectedRecipient == nil) {
        giftStarted = YES;
        [self showRecipientSelector];
    } else {
        [self navigateToGiftCardSelector];
    }    
}

- (void)handleFavoriteButtonAction:(id)sender {    
    HGGiftSetsService* service = [HGGiftSetsService sharedService];
    service.delegate = self;
    if (favoriteButton.selected == NO){
        [service requestGiftLike:giftOrder.gift.identifier];
        giftOrder.gift.likeCount += 1;
        giftOrder.gift.myLike = YES;
        favoriteButton.selected = giftOrder.gift.myLike;
        [favoriteButton setTitle:[NSString stringWithFormat:@"%d", giftOrder.gift.likeCount] forState:UIControlStateNormal];
        
        [HGTrackingService logEvent:kTrackingEventLikeProduct withParameters:[NSDictionary dictionaryWithObjectsAndKeys:giftOrder.gift.identifier, @"productId", nil]];
    }else{
        [service requestGiftUnLike:giftOrder.gift.identifier];
        giftOrder.gift.likeCount -= 1;
        giftOrder.gift.myLike = NO;
        favoriteButton.selected = giftOrder.gift.myLike;
        [favoriteButton setTitle:[NSString stringWithFormat:@"%d", giftOrder.gift.likeCount] forState:UIControlStateNormal];
    }
}

- (void)handleShareButtonAction:(id)sender {
    if([[RenrenService sharedRenren] isSessionValid] == NO && [[WBEngine sharedWeibo] isLoggedIn] == NO){
        HGAccountViewController* viewController = [[HGAccountViewController alloc] initWithNibName:@"HGAccountViewController" bundle:nil];
        [self presentModalViewController:viewController animated:YES];
        [viewController release];
        [HGTrackingService logPageView];
    }else if([[RenrenService sharedRenren] isSessionValid] == YES && [[WBEngine sharedWeibo] isLoggedIn] == YES){
        UIActionSheet *actionSheet = [[UIActionSheet alloc] 
                                      initWithTitle:nil
                                      delegate:self 
                                      cancelButtonTitle:@"取消" 
                                      destructiveButtonTitle:nil 
                                      otherButtonTitles:@"分享到新浪微博", @"分享到人人网", nil];
        
        [actionSheet showInView:self.view];
        [actionSheet release];
    }else{
        int network = NETWORK_SNS_WEIBO;
        if([[RenrenService sharedRenren] isSessionValid] == YES){
            network = NETWORK_SNS_RENREN;
        }else if([[WBEngine sharedWeibo] isLoggedIn] == YES){
            network = NETWORK_SNS_WEIBO;
        }
        
        [HGTrackingService logEvent:kTrackingEventEnterShare withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"HGGiftDetailViewController", @"from", @"shareProduct", @"type", network == NETWORK_SNS_WEIBO ? @"weibo" : @"renren", @"network", nil]];
        
        HGShareViewController* viewController = [[HGShareViewController alloc] initWithGift:giftOrder.gift network:network];
        [self presentModalViewController:viewController animated:YES];
        [viewController release];
        [HGTrackingService logPageView];
    }
}

#pragma mark  UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    int network = NETWORK_SNS_WEIBO;
    if (buttonIndex == 0){
        network = NETWORK_SNS_WEIBO;
    }else if (buttonIndex == 1){
        network = NETWORK_SNS_RENREN;
    }else{
        return;
    }
    
    [HGTrackingService logEvent:kTrackingEventEnterShare withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"HGGiftDetailViewController", @"from", @"shareProduct", @"type", network == NETWORK_SNS_WEIBO ? @"weibo" : @"renren", @"network", nil]];
    
    HGShareViewController* viewController = [[HGShareViewController alloc] initWithGift:giftOrder.gift network:network];
    [self presentModalViewController:viewController animated:YES];
    [viewController release];
    [HGTrackingService logPageView];
}


- (void)updateGiftDetailDisplay{    
    contentView.hidden = NO;
    addButton.hidden = NO;
    addButtonBackground.hidden = NO;
    if (contentSubViews == nil){
        contentSubViews = [[NSMutableArray alloc] init];
    }else{
        for (UIView* subView in contentSubViews){
            [subView removeFromSuperview];
        }
        [contentSubViews removeAllObjects];
    }
    
    if (coverImagesLoadingPool != nil){
        [coverImagesLoadingPool removeAllObjects];
    }else{
        coverImagesLoadingPool = [[NSMutableDictionary alloc] init];
    }
    
    if (coverImagesPendingPool != nil){
        [coverImagesPendingPool removeAllObjects];
        [coverImagesPendingPool release];
        coverImagesPendingPool = nil;
    }
    
    HGGift* theGift = giftOrder.gift;
    if (theGift != nil){
        coverPriceLabel.numberOfLines = 1;
        coverPriceLabel.textColor = [UIColor whiteColor];
        coverPriceLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:[HappyGiftAppDelegate fontSizeXLarge]];
        if (fabs(theGift.price) < 0.005){
           coverPriceLabel.text = @"免费";
        }else{
            coverPriceLabel.text = [NSString stringWithFormat:@"¥%.2f", theGift.price];
        }
        CGSize coverPriceLabelSize = [coverPriceLabel.text sizeWithFont:coverPriceLabel.font];
        CGRect coverPriceLabelFrame = coverPriceLabel.frame;
        coverPriceLabelFrame.size.width = coverPriceLabelSize.width;
        coverPriceLabelFrame.origin.x = coverView.frame.size.width - coverPriceLabelSize.width - 5.0;
        coverPriceLabel.frame = coverPriceLabelFrame;
        
        coverManufacturerLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeTiny]];
        coverManufacturerLabel.textColor = [UIColor grayColor];
        coverManufacturerLabel.lineBreakMode = UILineBreakModeTailTruncation;
        if (theGift.sexyName && [@"" isEqualToString: theGift.sexyName] == NO) {
            coverManufacturerLabel.text = theGift.sexyName;
        }else{
            coverManufacturerLabel.text = theGift.manufacturer;
        }
        CGRect coverManufacturerLabelFrame = coverManufacturerLabel.frame;
        coverManufacturerLabelFrame.size.width = coverPriceLabelFrame.origin.x - coverManufacturerLabelFrame.origin.x - 10.0;
        coverManufacturerLabel.frame = coverManufacturerLabelFrame;
        if (coverManufacturerLabel.text != nil && [coverManufacturerLabel.text isEqualToString:@""] == NO){
            coverManufacturerLabel.hidden = NO;
        }else{
            coverManufacturerLabel.hidden = YES;
        }
        
        coverTitleLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:[HappyGiftAppDelegate fontSizeNormal]];
        coverTitleLabel.text = theGift.name;
        coverTitleLabel.textColor = [UIColor blackColor];
        coverTitleLabel.lineBreakMode = UILineBreakModeClip;
        coverTitleLabel.numberOfLines = 0;
        CGRect coverTitleLabelFrame = coverTitleLabel.frame;
        coverTitleLabelFrame.size.width = coverPriceLabelFrame.origin.x - coverTitleLabelFrame.origin.x - 10.0;
        CGSize coverTitleLabelSize = [coverTitleLabel.text sizeWithFont:coverTitleLabel.font constrainedToSize:CGSizeMake(coverTitleLabelFrame.size.width, 80.0) lineBreakMode:UILineBreakModeClip];
        coverTitleLabelFrame.size.height = coverTitleLabelSize.height;
        coverTitleLabel.frame = coverTitleLabelFrame;
        CGFloat coverHeaderHeight = coverTitleLabelFrame.origin.y + coverTitleLabelFrame.size.height;
        if (coverManufacturerLabel.hidden == NO){
            CGRect coverManufacturerLabelFrame = coverManufacturerLabel.frame;
            coverManufacturerLabelFrame.origin.y = coverTitleLabelFrame.origin.y + coverTitleLabelFrame.size.height;
            coverManufacturerLabel.frame = coverManufacturerLabelFrame;
            coverHeaderHeight += coverManufacturerLabelFrame.size.height;
        }
        coverHeaderHeight += 5.0;
        if (coverHeaderHeight < 48.0){
            coverHeaderHeight = 48.0;
        }
        
        if (theGift.basePrice > theGift.price){
            coverBasePriceLabel.textColor = [UIColor whiteColor];
            coverBasePriceLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeSmall]];
            coverBasePriceLabel.textColor = UIColorFromRGB(0xd53d3b);
            coverBasePriceLabel.text = [NSString stringWithFormat:@"¥%.2f", theGift.basePrice];
            
            coverPriceLabelFrame.origin.y = (coverHeaderHeight - coverPriceLabelFrame.size.height)/2.0 - 15.0;
            if (coverPriceLabelFrame.origin.y < 5.0){
                coverPriceLabelFrame.origin.y = 5.0;
            }
            coverPriceLabel.frame = coverPriceLabelFrame;
            
            CGSize coverBasePriceLabelSize = [coverBasePriceLabel.text sizeWithFont:coverBasePriceLabel.font];
            
            CGRect coverBasePriceLabelFrame = coverBasePriceLabel.frame;
            coverBasePriceLabelFrame.origin.x = coverView.frame.size.width - coverBasePriceLabelSize.width - 6.0;
            coverBasePriceLabelFrame.size.width = coverBasePriceLabelSize.width;
            coverBasePriceLabelFrame.origin.y = coverPriceLabelFrame.origin.y + coverPriceLabelFrame.size.height;
            coverBasePriceLabel.frame = coverBasePriceLabelFrame;
            
            coverBasePriceLabel.hidden = NO;
        }else{
            coverBasePriceLabel.hidden = YES;
            coverPriceLabelFrame.origin.y = (coverHeaderHeight - coverPriceLabelFrame.size.height)/2.0;
            coverPriceLabel.frame = coverPriceLabelFrame;
        }
        
        CGRect coverPriceImageViewFrame = coverPriceImageView.frame;
        coverPriceImageViewFrame.size.width = coverPriceLabelFrame.size.width + 15.0;
        if (coverPriceImageViewFrame.size.width < 50.0){
            coverPriceImageViewFrame.size.width = 50.0;
        }
        coverPriceImageViewFrame.origin.x = coverView.frame.size.width - coverPriceImageViewFrame.size.width;
        coverPriceImageViewFrame.origin.y = coverPriceLabelFrame.origin.y - 2.0;
        coverPriceImageViewFrame.size.height = coverPriceLabelFrame.size.height + 4.0;
        coverPriceImageView.frame = coverPriceImageViewFrame;

        CGRect coverHeaderImageViewFrame = coverHeaderImageView.frame;
        coverHeaderImageViewFrame.size.height = coverHeaderHeight;
        coverHeaderImageView.frame = coverHeaderImageViewFrame;
        
        CGRect coverBackgroundImageViewFrame = coverBackgroundImageView.frame;
        coverBackgroundImageViewFrame.origin.y = coverHeaderImageViewFrame.origin.y + coverHeaderImageViewFrame.size.height;
        coverBackgroundImageView.frame = coverBackgroundImageViewFrame;
        
        CGRect coverImagesScrollViewFrame = coverImagesScrollView.frame;
        coverImagesScrollViewFrame.origin.y = coverHeaderImageViewFrame.origin.y + coverHeaderImageViewFrame.size.height + 5.0;
        coverImagesScrollView.frame = coverImagesScrollViewFrame;
        
        CGFloat itemViewX = 2.0;
        CGFloat itemViewY = 0;
        UIImage* defaultImage = nil;
        
        HappyGiftAppDelegate *appDelegate = (HappyGiftAppDelegate *)[[UIApplication sharedApplication] delegate];
        int itemIndex = 0;
        for (NSString* giftImage in theGift.images){
            UIImageView* coverImageView = [[UIImageView alloc] initWithFrame:CGRectMake(itemViewX, itemViewY, coverImagesScrollView.frame.size.width - 4.0, coverImagesScrollView.frame.size.height)];
            coverImageView.contentMode = UIViewContentModeScaleAspectFit;
            [coverImageView.layer setBorderColor:[[HappyGiftAppDelegate imageFrameColor] CGColor]];
            [coverImageView.layer setBorderWidth:1.0];
            
            [contentSubViews addObject:coverImageView];
            [coverImagesScrollView addSubview:coverImageView];
            
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
            tapGesture.numberOfTapsRequired = 1;
            [coverImageView addGestureRecognizer:tapGesture];
            coverImageView.userInteractionEnabled = YES;
            [tapGesture release];
            
            if (appDelegate.wifiReachable == YES || giftImage == [theGift.images objectAtIndex:0]){
                [coverImagesLoadingPool setObject:coverImageView forKey:giftImage];
                HGImageService *imageService = [HGImageService sharedService];
                UIImage *coverImage = [imageService requestImage:giftImage target:self selector:@selector(didImageLoaded:)];
                if (coverImage != nil){
                    coverImageView.image = coverImage;
                    CATransition *animation = [CATransition animation];
                    [animation setDelegate:self];
                    [animation setType:kCATransitionFade];
                    [animation setDuration:0.3];
                    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
                    [coverImageView.layer addAnimation:animation forKey:@"updateCoverAnimation"];
                }else{
                    if (defaultImage == nil){
                        CGSize defaultImageSize = coverImageView.frame.size;
                        defaultImage = [[HGUtility defaultImage:defaultImageSize] retain];
                    }
                    coverImageView.image = defaultImage;
                }
            }else{
                if (coverImagesPendingPool == nil){
                    coverImagesPendingPool = [[NSMutableDictionary alloc] init];
                }
                if (defaultImage == nil){
                    CGSize defaultImageSize = coverImageView.frame.size;
                    defaultImage = [[HGUtility defaultImage:defaultImageSize] retain];
                }
                coverImageView.image = defaultImage;
                [coverImagesPendingPool setObject:coverImageView forKey:[NSNumber numberWithInt:itemIndex]];
            }
            itemIndex += 1;
            itemViewX += coverImagesScrollView.frame.size.width;
            [coverImageView release];
        }
        [defaultImage release];
        
        CGSize contentSize = coverImagesScrollView.contentSize;
        contentSize.width = itemViewX;
        [coverImagesScrollView setContentSize:contentSize];
        
        coverImagesPageControl.numberOfPages = [theGift.images count];
        coverImagesPageControl.currentPage = 0;
        
        if ([theGift.images count] <= 1){
            coverImagesPageControl.hidden = YES;
            
            CGRect socialViewFrame = socialView.frame;
            socialViewFrame.origin.y = coverImagesScrollViewFrame.origin.y + coverImagesScrollViewFrame.size.height + 8.0;
            socialView.frame = socialViewFrame;
            
            CGRect coverViewFrame = coverView.frame;
            coverViewFrame.size.height = socialViewFrame.origin.y + socialViewFrame.size.height + 8.0;
            coverView.frame = coverViewFrame;
            
            coverBackgroundImageViewFrame.size.height = coverViewFrame.size.height - coverBackgroundImageViewFrame.origin.y;
            coverBackgroundImageView.frame = coverBackgroundImageViewFrame;
            
            CGRect detailViewFrame = detailView.frame;
            detailViewFrame.origin.y = coverViewFrame.origin.y + coverViewFrame.size.height + 3.0;
            detailView.frame = detailViewFrame;
        }else{
            CGRect coverImagesPageControlFrame = coverImagesPageControl.frame;
            coverImagesPageControlFrame.origin.y = coverImagesScrollViewFrame.origin.y + coverImagesScrollViewFrame.size.height - 2.0;
            coverImagesPageControl.frame = coverImagesPageControlFrame;
            
            CGRect socialViewFrame = socialView.frame;
            socialViewFrame.origin.y = coverImagesScrollViewFrame.origin.y + coverImagesScrollViewFrame.size.height + 8.0;
            socialView.frame = socialViewFrame;
            
            CGRect coverViewFrame = coverView.frame;
            coverViewFrame.size.height = socialViewFrame.origin.y + socialViewFrame.size.height + 8.0;
            coverView.frame = coverViewFrame;
            
            coverBackgroundImageViewFrame.size.height = coverViewFrame.size.height - coverBackgroundImageViewFrame.origin.y;
            coverBackgroundImageView.frame = coverBackgroundImageViewFrame;
            
            CGRect detailViewFrame = detailView.frame;
            detailViewFrame.origin.y = coverViewFrame.origin.y + coverViewFrame.size.height + 3.0;
            detailView.frame = detailViewFrame;
            
            coverImagesPageControl.hidden = NO;
        }
        
        if ([theGift isFreeShippingCost]) {
            freeShippingCostImageView.hidden = NO;
            CGRect freeShippingCostImageViewFrame = freeShippingCostImageView.frame;
            freeShippingCostImageViewFrame.origin.y = coverImagesScrollView.frame.origin.y + coverImagesScrollView.frame.size.height - freeShippingCostImageViewFrame.size.height;
            freeShippingCostImageView.frame = freeShippingCostImageViewFrame;
        } else {
            freeShippingCostImageView.hidden = YES;
        }
        
        CGFloat detailViewY = 2.0;
        
        UILabel* detailReviewTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, detailViewY, detailView.frame.size.width - 20.0, 30.0)];
        detailReviewTitleLabel.backgroundColor = [UIColor clearColor];
        detailReviewTitleLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:[HappyGiftAppDelegate fontSizeNormal]];
        detailReviewTitleLabel.textColor = [UIColor blackColor];
        detailReviewTitleLabel.text = @"产品介绍：";
        
        [contentSubViews addObject:detailReviewTitleLabel];
        [detailView addSubview:detailReviewTitleLabel];
        [detailReviewTitleLabel release];
        
        detailViewY += 30.0;
        
        UIImageView* detailReviewImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10.0, detailViewY, detailView.frame.size.width - 20.0, 1.0)];
        detailReviewImageView.backgroundColor = [UIColor clearColor];
        detailReviewImageView.image = [UIImage imageNamed:@"gift_delivery_input_line"];
        [contentSubViews addObject:detailReviewImageView];
        [detailView addSubview:detailReviewImageView];
        [detailReviewImageView release];
        
        detailViewY += 5.0;
        
        UILabel* detailReviewLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, detailViewY, detailView.frame.size.width - 20.0, 10.0)];
        detailReviewLabel.numberOfLines = 0;
        detailReviewLabel.backgroundColor = [UIColor clearColor];
        detailReviewLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeSmall]];
        detailReviewLabel.textColor = [UIColor darkGrayColor];
        detailReviewLabel.text = theGift.review;
        
        CGSize detailReviewLabelSize = [detailReviewLabel.text sizeWithFont:detailReviewLabel.font constrainedToSize:CGSizeMake(detailReviewLabel.frame.size.width, 1000.0)];
        
        CGRect detailReviewLabelFrame = detailReviewLabel.frame;
        detailReviewLabelFrame.size.height = detailReviewLabelSize.height;
        detailReviewLabel.frame = detailReviewLabelFrame;
        
        [contentSubViews addObject:detailReviewLabel];
        [detailView addSubview:detailReviewLabel];
        [detailReviewLabel release];
        
        detailViewY += detailReviewLabelFrame.size.height + 15.0;
        
        UILabel* detailRecommendTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, detailViewY, detailView.frame.size.width - 20.0, 30.0)];
        detailRecommendTitleLabel.backgroundColor = [UIColor clearColor];
        detailRecommendTitleLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:[HappyGiftAppDelegate fontSizeNormal]];
        detailRecommendTitleLabel.textColor = [UIColor blackColor];
        detailRecommendTitleLabel.text = @"推荐理由：";
        [contentSubViews addObject:detailRecommendTitleLabel];
        [detailView addSubview:detailRecommendTitleLabel];
        [detailRecommendTitleLabel release];
        
        detailViewY += 30.0;
        
        UIImageView* detailRecommendImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10.0, detailViewY, detailView.frame.size.width - 20.0, 1.0)];
        detailRecommendImageView.backgroundColor = [UIColor clearColor];
        detailRecommendImageView.image = [UIImage imageNamed:@"gift_delivery_input_line"];
        [contentSubViews addObject:detailRecommendImageView];
        [detailView addSubview:detailRecommendImageView];
        [detailRecommendImageView release];
        
        detailViewY += 5.0;
        
        UILabel* detailRecommendLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, detailViewY, detailView.frame.size.width - 20.0, 10.0)];
        detailRecommendLabel.numberOfLines = 0;
        detailRecommendLabel.backgroundColor = [UIColor clearColor];
        detailRecommendLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeSmall]];
        detailRecommendLabel.textColor = [UIColor darkGrayColor];
        detailRecommendLabel.text = theGift.recommend;
        
        CGSize detailRecommendLabelSize = [detailRecommendLabel.text sizeWithFont:detailRecommendLabel.font constrainedToSize:CGSizeMake(detailRecommendLabel.frame.size.width, 1000.0)];
        
        CGRect detailRecommendLabelFrame = detailRecommendLabel.frame;
        detailRecommendLabelFrame.size.height = detailRecommendLabelSize.height;
        detailRecommendLabel.frame = detailRecommendLabelFrame;
        
        [contentSubViews addObject:detailRecommendLabel];
        [detailView addSubview:detailRecommendLabel];
        [detailRecommendLabel release];
        
        detailViewY += detailRecommendLabelFrame.size.height + 15.0;
        
        if (theGift.introduction != nil && [theGift.introduction isEqualToString:@""] == NO){
            UILabel* detailIntroductionTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, detailViewY, detailView.frame.size.width - 20.0, 30.0)];
            detailIntroductionTitleLabel.backgroundColor = [UIColor clearColor];
            detailIntroductionTitleLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:[HappyGiftAppDelegate fontSizeNormal]];
            detailIntroductionTitleLabel.textColor = [UIColor blackColor];
            detailIntroductionTitleLabel.text = @"品牌故事：";
            [contentSubViews addObject:detailIntroductionTitleLabel];
            [detailView addSubview:detailIntroductionTitleLabel];
            [detailIntroductionTitleLabel release];
            
            detailViewY += 30.0;
            
            UIImageView* seperatorImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10.0, detailViewY, detailView.frame.size.width - 20.0, 1.0)];
            seperatorImageView.backgroundColor = [UIColor clearColor];
            seperatorImageView.image = [UIImage imageNamed:@"gift_delivery_input_line"];
            [contentSubViews addObject:seperatorImageView];
            [detailView addSubview:seperatorImageView];
            [seperatorImageView release];
            
            detailViewY += 5.0;
            
            UILabel* detailIntroductionLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, detailViewY, detailView.frame.size.width - 20.0, 10.0)];
            detailIntroductionLabel.numberOfLines = 0;
            detailIntroductionLabel.backgroundColor = [UIColor clearColor];
            detailIntroductionLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeSmall]];
            detailIntroductionLabel.textColor = [UIColor darkGrayColor];
            detailIntroductionLabel.text = theGift.introduction;
            
            CGSize detailIntroductionLabelSize = [detailIntroductionLabel.text sizeWithFont:detailIntroductionLabel.font constrainedToSize:CGSizeMake(detailIntroductionLabel.frame.size.width, 1000.0)];
            
            CGRect detailIntroductionLabelFrame = detailIntroductionLabel.frame;
            detailIntroductionLabelFrame.size.height = detailIntroductionLabelSize.height;
            detailIntroductionLabel.frame = detailIntroductionLabelFrame;
            
            [contentSubViews addObject:detailIntroductionLabel];
            [detailView addSubview:detailIntroductionLabel];
            [detailIntroductionLabel release];
            
            detailViewY += detailIntroductionLabelFrame.size.height + 15.0;
        }
        
        if (theGift.description != nil && [theGift.description isEqualToString:@""] == NO){
            UILabel* detailDescriptionTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, detailViewY, detailView.frame.size.width - 20.0, 30.0)];
            detailDescriptionTitleLabel.backgroundColor = [UIColor clearColor];
            detailDescriptionTitleLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:[HappyGiftAppDelegate fontSizeNormal]];
            detailDescriptionTitleLabel.textColor = [UIColor blackColor];
            detailDescriptionTitleLabel.text = @"产品规格：";
            
            [contentSubViews addObject:detailDescriptionTitleLabel];
            [detailView addSubview:detailDescriptionTitleLabel];
            [detailDescriptionTitleLabel release];
            
            detailViewY += 30.0;
            
            UIImageView* detailDescriptionImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10.0, detailViewY, detailView.frame.size.width - 20.0, 1.0)];
            detailDescriptionImageView.backgroundColor = [UIColor clearColor];
            detailDescriptionImageView.image = [UIImage imageNamed:@"gift_delivery_input_line"];
            [contentSubViews addObject:detailDescriptionImageView];
            [detailView addSubview:detailDescriptionImageView];
            [detailDescriptionImageView release];
            
            detailViewY += 5.0;
            
            UILabel* detailDescriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, detailViewY, detailView.frame.size.width - 20.0, 10.0)];
            detailDescriptionLabel.numberOfLines = 0;
            detailDescriptionLabel.backgroundColor = [UIColor clearColor];
            detailDescriptionLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeSmall]];
            detailDescriptionLabel.textColor = [UIColor darkGrayColor];
            detailDescriptionLabel.text = theGift.description;
            
            CGSize detailDescriptionLabelSize = [detailDescriptionLabel.text sizeWithFont:detailDescriptionLabel.font constrainedToSize:CGSizeMake(detailDescriptionLabel.frame.size.width, 1000.0)];
            
            CGRect detailDescriptionLabelFrame = detailDescriptionLabel.frame;
            detailDescriptionLabelFrame.size.height = detailDescriptionLabelSize.height;
            detailDescriptionLabel.frame = detailDescriptionLabelFrame;
            
            [contentSubViews addObject:detailDescriptionLabel];
            [detailView addSubview:detailDescriptionLabel];
            [detailDescriptionLabel release];
            
            detailViewY += detailDescriptionLabelFrame.size.height + 15.0;
        }
        
        
        if (detailViewY < 72.0){
            detailViewY = 72.0;
        }
        
        CGRect detailViewFrame = detailView.frame;
        detailViewFrame.size.height = detailViewY;
        detailView.frame = detailViewFrame;
    }
    
    CGSize contentSize = contentView.contentSize;
    contentSize.height = detailView.frame.origin.y + detailView.frame.size.height + 3.0;
    [contentView setContentSize:contentSize];
    
    [progressView stopAnimation];
}

#pragma mark Gesture
- (void)handleTapGesture:(UITapGestureRecognizer*)sender{
    UIImageView* coverImageView = (UIImageView*)sender.view;
    
    CGRect coverImageViewFrame = [coverImageView convertRect:coverImageView.frame toView:contentView];
    coverImageViewFrame.origin.x -= coverImagesScrollView.contentOffset.x + 2.0;
    
    UIImageView* snapShotImageView = [[UIImageView alloc] initWithFrame:coverImageViewFrame];
    snapShotImageView.hidden = YES;
    [contentView addSubview:snapShotImageView];
    
    UIGraphicsBeginImageContext(coverImageViewFrame.size);
    CGContextScaleCTM( UIGraphicsGetCurrentContext(), 1.0f, 1.0f );
    [coverImageView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage* viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [snapShotImageView setImage:viewImage];
    snapShotImageView.hidden = NO;
    
    [UIView animateWithDuration:0.2
                          delay:0.0 
                        options:UIViewAnimationOptionCurveLinear 
                     animations:^{
                         snapShotImageView.layer.transform = CATransform3DScale(CATransform3DIdentity, 2.0 , 2.0, 2.0);
                         snapShotImageView.alpha = 0.0;
                     } 
                     completion:^(BOOL finished) {
                         snapShotImageView.hidden = YES;
                         [snapShotImageView removeFromSuperview];
                         [snapShotImageView release];
                         
                         HGImageViewController *viewController = [[HGImageViewController alloc] initWithImages:giftOrder.gift.images page:0];
                         [self presentModalViewController:viewController animated:YES];
                         [viewController release];
                         [HGTrackingService logPageView];
                     }];
}

#pragma mark  HGImagesService selector
- (void)didImageLoaded:(HGImageData*)image{
    UIImageView* imageView = [coverImagesLoadingPool objectForKey:image.url];
    if (imageView != nil){
        UIImage *coverImage = image.image;
        imageView.image = coverImage;
        
        CATransition *animation = [CATransition animation];
        [animation setDelegate:self];
        [animation setType:kCATransitionFade];
        [animation setDuration:0.3];
        [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        [imageView.layer addAnimation:animation forKey:@"updateCoverAnimation"];
        
        [coverImagesLoadingPool removeObjectForKey:image.url];
    }
}


#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView{
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView == coverImagesScrollView){
        int currentPage = floor((scrollView.contentOffset.x - scrollView.frame.size.width/2.0) / coverImagesScrollView.frame.size.width) + 1;
        if (coverImagesPageControl.currentPage != currentPage){
            coverImagesPageControl.currentPage = currentPage;
            if (coverImagesPendingPool != nil){
                UIImageView* coverImageView = [coverImagesPendingPool objectForKey:[NSNumber numberWithInt:currentPage]];
                if (coverImageView != nil){
                    NSString* giftImage =  [giftOrder.gift.images objectAtIndex:currentPage];
                    [coverImagesLoadingPool setObject:coverImageView forKey:giftImage];
                    HGImageService *imageService = [HGImageService sharedService];
                    UIImage *coverImage = [imageService requestImage:giftImage target:self selector:@selector(didImageLoaded:)];
                    if (coverImage != nil){
                        coverImageView.image = coverImage;
                        CATransition *animation = [CATransition animation];
                        [animation setDelegate:self];
                        [animation setType:kCATransitionFade];
                        [animation setDuration:0.3];
                        [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
                        [coverImageView.layer addAnimation:animation forKey:@"updateCoverAnimation"];
                    }else{
                        
                        CGSize defaultImageSize = coverImagesScrollView.frame.size;
                        UIGraphicsBeginImageContext(defaultImageSize);
                        
                        CGContextRef context = UIGraphicsGetCurrentContext();
                        
                        CGContextSetAllowsAntialiasing(context, YES);
                        CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
                        CGContextAddRect(context, CGRectMake(0, 0, defaultImageSize.width, defaultImageSize.height));
                        CGContextClosePath(context);
                        CGContextFillPath(context);
                        
                        CGContextSetLineWidth(context, 1.0);
                        CGContextSetStrokeColorWithColor(context, [HappyGiftAppDelegate imageFrameColor].CGColor);
                        CGContextAddRect(context, CGRectMake(0.0, 0.0, defaultImageSize.width, defaultImageSize.height));
                        CGContextClosePath(context);
                        CGContextStrokePath(context);
                        
                        UIImage *defaultImage = UIGraphicsGetImageFromCurrentImageContext();
                        UIGraphicsEndImageContext();
                        
                        coverImageView.image = defaultImage;
                    }
                    [coverImagesPendingPool removeObjectForKey:[NSNumber numberWithInt:currentPage]];
                    if ([coverImagesPendingPool count] == 0){
                        [coverImagesPendingPool release];
                        coverImagesPendingPool = nil;
                    }
                }
            }
        }
    }
}

#pragma mark UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)theNavigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    if ([viewController isKindOfClass:[HGSentGiftDetailViewController class]]){
        [theNavigationController setViewControllers:[NSArray arrayWithObject:viewController] animated:NO];
        [self.navigationController popToRootViewControllerAnimated:NO];
    }
}

#pragma mark HGGiftSetsServiceDelegate
- (void)giftSetsService:(HGGiftSetsService *)giftSetsService didRequestGiftDetailSucceed:(HGGift*)gift {
    HGDebug(@"didRequestGiftDetailSucceed");
    giftSetsService.delegate = nil;

    giftOrder.gift.images = gift.images;
    giftOrder.gift.description = gift.description;
    giftOrder.gift.introduction = gift.introduction;
    giftOrder.gift.review = gift.review;
    giftOrder.gift.recommend = gift.recommend;

    [self performSelector:@selector(updateGiftDetailDisplay) withObject:nil afterDelay:0.01];
}

- (void)giftSetsService:(HGGiftSetsService *)giftSetsService didRequestGiftDetailFail:(NSString*)error {
    giftSetsService.delegate = nil;
    HGDebug(@"didRequestGiftDetailFail");
    HappyGiftAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    [appDelegate sendNotification:@"请求产品详情失败，请检查网络设置"];
    
    [progressView stopAnimation];
}

- (void)giftSetsService:(HGGiftSetsService *)giftSetsService didRequestGiftLikeSucceed:(NSString*)giftId{
    
}

- (void)giftSetsService:(HGGiftSetsService *)giftSetsService didRequestGiftLikeFail:(NSString*)error{
    giftOrder.gift.likeCount -= 1;
    giftOrder.gift.myLike = NO;
    favoriteButton.selected = giftOrder.gift.myLike;
    [favoriteButton setTitle:[NSString stringWithFormat:@"%d", giftOrder.gift.likeCount] forState:UIControlStateNormal];
    giftSetsService.delegate = nil;
}

- (void)giftSetsService:(HGGiftSetsService *)giftSetsService didRequestGiftUnLikeSucceed:(NSString*)giftId{
   
}

- (void)giftSetsService:(HGGiftSetsService *)giftSetsService didRequestGiftUnLikeFail:(NSString*)error{
    giftOrder.gift.likeCount += 1;
    giftOrder.gift.myLike = YES;
    favoriteButton.selected = giftOrder.gift.myLike;
    [favoriteButton setTitle:[NSString stringWithFormat:@"%d", giftOrder.gift.likeCount] forState:UIControlStateNormal];
    giftSetsService.delegate = nil;
}
@end

