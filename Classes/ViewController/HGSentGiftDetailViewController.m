//
//  HGSentGiftDetailViewController.m
//  HappyGift
//
//  Created by Zhang Yuhui on 2/11/11.
//  Copyright 2011 Ztelic Inc Inc. All rights reserved.
//

#import "HGSentGiftDetailViewController.h"
#import "HappyGiftAppDelegate.h"
#import "HGGiftOrder.h"
#import "HGConstants.h"
#import "HGProgressView.h"
#import "HGImageService.h"
#import "HGGiftOrderService.h"
#import "HGOrderViewController.h"
#import "UIBarButtonItem+Addition.h"
#import "UIImage+Addition.h"
#import "HGTrackingService.h"
#import "RenrenService.h"
#import "WBEngine.h"
#import "HGShareViewController.h"
#import "HGAccountViewController.h"
#import "HGCreditService.h"
#import <QuartzCore/QuartzCore.h>
#import "HGUserImageView.h"
#import "HGUtility.h"
#import "HGAppConfigurationService.h"

@interface HGSentGiftDetailViewController()<UIScrollViewDelegate, HGGiftOrderServiceDelegate, UIActionSheetDelegate>
  
@end

@implementation HGSentGiftDetailViewController

- (id)initWithGiftOrder:(HGGiftOrder*)theGiftOrder andShouldRefetchData:(BOOL)theShouldRefetchData {
    self = [super initWithNibName:@"HGSentGiftDetailViewController" bundle:nil];
    if (self){
        giftOrder = [theGiftOrder retain];
        shouldRefetchData = theShouldRefetchData;
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    self.view.backgroundColor = [HappyGiftAppDelegate genericBackgroundColor];
    
    CGRect titleViewFrame = CGRectMake(20, 0, 180, 44);
    UIView* titleView = [[UIView alloc] initWithFrame:titleViewFrame];
    
    CGRect titleLabelFrame = CGRectMake(0, 0, 180, 40);
	titleLabel = [[UILabel alloc] initWithFrame:titleLabelFrame];
	titleLabel.backgroundColor = [UIColor clearColor];
	titleLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:[HappyGiftAppDelegate naviagtionTitleFontSize]];;
    titleLabel.minimumFontSize = 20.0;
    titleLabel.adjustsFontSizeToFitWidth = YES;
	titleLabel.textAlignment = UITextAlignmentCenter;
	titleLabel.textColor = [UIColor whiteColor];
    [titleView addSubview:titleLabel];
    [titleLabel release];
    
	navigationBar.topItem.titleView = titleView;
    [titleView release];
    
    NSArray* viewControllers = [self.navigationController viewControllers];
    if ([viewControllers count] > 1){
        UIViewController* prevViewController = [viewControllers objectAtIndex:[viewControllers count] - 2];
        if ([prevViewController isKindOfClass:[HGOrderViewController class]]){
            UIBarButtonItem* leftBarButtonItem = [[UIBarButtonItem alloc ] initNavigationLeftTextBarButtonItem:@"完成" target:self action:@selector(handleBackAction:)];
            navigationBar.topItem.leftBarButtonItem = leftBarButtonItem; 
            [leftBarButtonItem release];
        }else{
            UIBarButtonItem* leftBarButtonItem = [[UIBarButtonItem alloc ] initNavigationBackImageBarButtonItem:@"navigation_back" target:self action:@selector(handleBackAction:)];
            navigationBar.topItem.leftBarButtonItem = leftBarButtonItem; 
            [leftBarButtonItem release];
        }
    }else{
        UIBarButtonItem* leftBarButtonItem = [[UIBarButtonItem alloc ] initNavigationBackImageBarButtonItem:@"navigation_back" target:self action:@selector(handleBackAction:)];
        navigationBar.topItem.leftBarButtonItem = leftBarButtonItem; 
        [leftBarButtonItem release];
    }
    
    [shareButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [shareButton setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
    [shareButton setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    shareButton.titleLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeNormal]];
    [shareButton setTitle:@"分享" forState:UIControlStateNormal];
    [shareButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, -7)];
    
    [shareButton setImage:[UIImage imageNamed:@"gift_detail_share"] forState:UIControlStateNormal];
    [shareButton addTarget:self action:@selector(handleShareAction:) forControlEvents:UIControlEventTouchUpInside];
    shareButton.hidden = (giftOrder.isPaid == NO);
    
    
    orderTrackCodeTitleLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeSmall]];
    orderTrackCodeTitleLabel.textColor = [UIColor lightGrayColor];
    if (giftOrder.payTrackCode && ![giftOrder.payTrackCode isEqualToString:@""]) {
        orderTrackCodeTitleLabel.text = [NSString stringWithFormat:@"订单号：%@", giftOrder.payTrackCode];
    }
    
    userTitleLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeTiny]];
    userTitleLabel.textColor = [UIColor darkGrayColor];
    userTitleLabel.text = @"发送至：";
    
    userNameLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:[HappyGiftAppDelegate fontSizeNormal]];
    userNameLabel.textColor = [UIColor blackColor];
    
    progressView = [[HGProgressView progressView:self.view.frame] retain];
    [self.view addSubview:progressView];
    progressView.hidden = YES;
    
    statusTitleLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:[HappyGiftAppDelegate fontSizeNormal]];
    statusTitleLabel.textColor = [UIColor blackColor];
    statusTitleLabel.text = @"订单状态";
    
    statusPaidLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeSmall]];
    statusPaidLabel.highlightedTextColor = [UIColor darkGrayColor];
    statusPaidLabel.textColor = [UIColor lightGrayColor];
    statusPaidLabel.text = @"已付款";
    
    statusNotifiedLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeSmall]];
    statusNotifiedLabel.highlightedTextColor = [UIColor darkGrayColor];
    statusNotifiedLabel.textColor = [UIColor lightGrayColor];
    statusNotifiedLabel.text = @"已通知";
    
    statusReadLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeSmall]];
    statusReadLabel.highlightedTextColor = [UIColor darkGrayColor];
    statusReadLabel.textColor = [UIColor lightGrayColor];
    statusReadLabel.text = @"贺卡已读";
    
    statusAcceptedLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeSmall]];
    statusAcceptedLabel.highlightedTextColor = [UIColor darkGrayColor];
    statusAcceptedLabel.textColor = [UIColor lightGrayColor];
    statusAcceptedLabel.text = @"已接受";
    
    statusShippedLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeSmall]];
    statusShippedLabel.highlightedTextColor = [UIColor darkGrayColor];
    statusShippedLabel.textColor = [UIColor lightGrayColor];
    statusShippedLabel.text = @"已投递";
    
    statusDeliveredLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeSmall]];
    statusDeliveredLabel.highlightedTextColor = [UIColor darkGrayColor];
    statusDeliveredLabel.textColor = [UIColor lightGrayColor];
    statusDeliveredLabel.text = @"已送达";
    
    giftTitleLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:[HappyGiftAppDelegate fontSizeNormal]];
    giftTitleLabel.textColor = [UIColor blackColor];
    giftTitleLabel.text = @"礼物详情";
    
    cardTitleLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:[HappyGiftAppDelegate fontSizeNormal]];
    cardTitleLabel.textColor = [UIColor blackColor];
    cardTitleLabel.text = @"贺卡信息";
    
    cardContentLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeNormal]];
    cardContentLabel.numberOfLines = 0;
    cardContentLabel.textColor = UIColorFromRGB(0x484744);
    
    summaryTitleLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:[HappyGiftAppDelegate fontSizeNormal]];
    summaryTitleLabel.textColor = [UIColor blackColor];
    summaryTitleLabel.text = @"合计：";
    
    summaryPriceTitleLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:[HappyGiftAppDelegate fontSizeNormal]];
    summaryPriceTitleLabel.textColor = [UIColor blackColor];
    summaryPriceTitleLabel.text = @"礼物价格：";
    
    summaryDeliveryTitleLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:[HappyGiftAppDelegate fontSizeNormal]];
    summaryDeliveryTitleLabel.textColor = [UIColor blackColor];
    summaryDeliveryTitleLabel.text = @"运费：";
    
    summaryPriceValueLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:[HappyGiftAppDelegate fontSizeNormal]];
    summaryPriceValueLabel.textColor = [UIColor blackColor];
    
    summaryCreditLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeTiny]];
    summaryCreditLabel.minimumFontSize = 10.0;
    summaryCreditLabel.adjustsFontSizeToFitWidth = YES;
    summaryCreditLabel.textColor = UIColorFromRGB(0xd53d3b);
    summaryCreditLabel.highlightedTextColor = [UIColor lightGrayColor];
    
    summaryDeliveryValueLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:[HappyGiftAppDelegate fontSizeNormal]];
    summaryDeliveryValueLabel.textColor = [UIColor blackColor];
    
    summaryValueLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:[HappyGiftAppDelegate fontSizeNormal]];
    summaryValueLabel.textColor = UIColorFromRGB(0xd53d3b);
    
    [payButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [payButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    payButton.titleLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeLarge]];
    [payButton setTitle:@"付款" forState:UIControlStateNormal];
    UIImage* payButtonBackgroundImage = [[UIImage imageNamed:@"gift_selection_button"] stretchableImageWithLeftCapWidth:5 topCapHeight:10];
    [payButton setBackgroundImage:payButtonBackgroundImage forState:UIControlStateNormal];
    [payButton addTarget:self action:@selector(handlePayAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [cancelButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [cancelButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateSelected];
    [cancelButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    cancelButton.titleLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeNormal]];
    [cancelButton setTitle:@"取消礼物订单" forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(handleCancelAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [summaryCreditButton addTarget:self action:@selector(handleCreditButtonSelectAction:) forControlEvents:UIControlEventTouchUpInside];
    [summaryCreditButton addTarget:self action:@selector(handleCreditButtonDownAction:) forControlEvents:UIControlEventTouchDown];
    [summaryCreditButton addTarget:self action:@selector(handleCreditButtonUpAction:) forControlEvents:UIControlEventTouchUpInside|UIControlEventTouchUpOutside|UIControlEventTouchCancel];

    if (shouldRefetchData == NO) {
        [self setupUI];
    } else {
        contentScrollView.hidden = YES;
        userInfoView.hidden = YES;
        [progressView startAnimation];
        [HGGiftOrderService sharedService].myGiftOrderDelegate = self;
        [[HGGiftOrderService sharedService] requestMyGiftOrder:giftOrder.identifier];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleApplicationDidBecomeActiveAction:) name:kHGNotificationApplicationDidBecomeActive object:nil];
}

- (void)setupUIWithAnimation {
    contentScrollView.alpha = 0.0;
    userInfoView.alpha = 0.0;
    contentScrollView.hidden = NO;
    userInfoView.hidden = NO;
    
    [UIView animateWithDuration:0.8
                          delay:0.0 
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         contentScrollView.alpha = 1.0;
                         userInfoView.alpha = 1.0;
                     } 
                     completion:^(BOOL finished) {
                         [self setupUI];
                     }];

}

- (void) setupUI {
    UIBarButtonItem* rightBarButtonItem = [[UIBarButtonItem alloc ] initNavigationRightTextBarButtonItem:@"付款" target:self action:@selector(handlePayAction:)];
    navigationBar.topItem.rightBarButtonItem = rightBarButtonItem;
    [rightBarButtonItem release];
    
    if (giftOrder.status == GIFT_ORDER_STATUS_CANCELED) {
        titleLabel.text = @"订单已取消";
        statusView.hidden = YES;
        CGRect tmpFrame = giftView.frame;
        tmpFrame.origin.y = statusView.frame.origin.y;
        giftView.frame = tmpFrame;
        
        tmpFrame = cardView.frame;
        tmpFrame.origin.y = giftView.frame.origin.y + giftView.frame.size.height + 10.0;
        cardView.frame = tmpFrame;
        
        tmpFrame = thankView.frame;
        tmpFrame.origin.y = cardView.frame.origin.y + cardView.frame.size.height + 10.0;
        thankView.frame = tmpFrame;
        
        tmpFrame = summaryView.frame;
        tmpFrame.origin.y = thankView.frame.origin.y + thankView.frame.size.height + 10.0;
        summaryView.frame = tmpFrame;
    } else if (giftOrder.isPaid) {
        if (giftOrder.status == GIFT_ORDER_STATUS_SHIPPED){
            titleLabel.text = @"订单已投递";
        }else if (giftOrder.status == GIFT_ORDER_STATUS_DELIVERED){
            titleLabel.text = @"订单已送达";
        }else{
            titleLabel.text = @"订单已付款";
        }
    } else {
        titleLabel.text = @"订单已发送";
    }
    shareButton.hidden = (giftOrder.isPaid == NO);
   
    if (giftOrder.payTrackCode && ![giftOrder.payTrackCode isEqualToString:@""]) {
        orderTrackCodeTitleLabel.text = [NSString stringWithFormat:@"订单号：%@", giftOrder.payTrackCode];
    }
    
    HGImageService *imageService = [HGImageService sharedService];
    
    if (giftOrder.orderType == kOrderTypeQuickOrder) {
        cardView.hidden = YES;
        
        CGRect tmpFrame = thankView.frame;
        tmpFrame.origin.y = cardView.frame.origin.y;
        thankView.frame = tmpFrame;
        
        tmpFrame = summaryView.frame;
        tmpFrame.origin.y = thankView.frame.origin.y + thankView.frame.size.height + 10.0;
        summaryView.frame = tmpFrame;
    } else {
        if (giftOrder.giftCard.cover != nil && [giftOrder.giftCard.cover isEqualToString:@""] == NO){
            UIImage *cardImage = [imageService requestImage:giftOrder.giftCard.cover target:self selector:@selector(didImageLoaded:)];
            if (cardImage != nil){
                cardImageView.image = [cardImage imageWithFrame:cardImageView.frame.size color:[HappyGiftAppDelegate imageFrameColor]];
                
                CATransition *animation = [CATransition animation];
                [animation setDelegate:self];
                [animation setType:kCATransitionFade];
                [animation setDuration:0.2];
                [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
                [cardImageView.layer addAnimation:animation forKey:@"updateGiftImageAnimation"];
            }else{
                cardImageView.image = [HGUtility defaultImage:cardImageView.frame.size];
            }
        }else{
            cardImageView.image = [HGUtility defaultImage:cardImageView.frame.size];
        }
        cardContentLabel.text = giftOrder.giftCard.content;
    }

    userNameLabel.text = giftOrder.giftRecipient.recipientDisplayName;
    [userImageView updateUserImageViewWithRecipient:giftOrder.giftRecipient];
    UIImage *giftImage = [imageService requestImage:giftOrder.gift.thumb target:self selector:@selector(didImageLoaded:)];
    if (giftImage != nil){
        giftImageView.image = [giftImage imageWithFrame:giftImageView.frame.size color:[HappyGiftAppDelegate imageFrameColor]];
        
        CATransition *animation = [CATransition animation];
        [animation setDelegate:self];
        [animation setType:kCATransitionFade];
        [animation setDuration:0.2];
        [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        [giftImageView.layer addAnimation:animation forKey:@"updateGiftImageAnimation"];
    }else{
        CGSize defaultImageSize = giftImageView.frame.size;
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
        
        UIImage *theDefaultImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        giftImageView.image = theDefaultImage;
    }
        
    if (giftOrder.gift.sexyName && ![@"" isEqualToString: giftOrder.gift.sexyName]) {
        giftManufactureLabel.text = giftOrder.gift.sexyName;
    } else {
        giftManufactureLabel.text = giftOrder.gift.manufacturer;
    }
    
    if (fabs(giftOrder.gift.price) < 0.005){
        giftPriceLabel.text = @"免费";
    }else{
        giftPriceLabel.text = [NSString stringWithFormat:@"¥%.2f", giftOrder.gift.price];
    }
       
    // setup gift view
    giftPriceLabel.numberOfLines = 1;
    giftPriceLabel.textColor = [UIColor whiteColor];
    giftPriceLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:[HappyGiftAppDelegate fontSizeXLarge]];
    
    CGSize priceLabelSize = [giftPriceLabel.text sizeWithFont:giftPriceLabel.font];
    CGRect priceLabelFrame = giftPriceLabel.frame;
    priceLabelFrame.origin.x = giftView.frame.size.width - priceLabelSize.width - 5.0;
    priceLabelFrame.size.width = priceLabelSize.width;
    priceLabelFrame.origin.y = (48.0 - priceLabelSize.height)/2.0;
    giftPriceLabel.frame = priceLabelFrame;
    
    
    CGRect giftPriceImageViewFrame = giftPriceImageView.frame;
    giftPriceImageViewFrame.size.width = priceLabelFrame.size.width + 15.0;
    if (giftPriceImageViewFrame.size.width < 50.0){
        giftPriceImageViewFrame.size.width = 50.0;
    }
    giftPriceImageViewFrame.origin.x = giftView.frame.size.width - giftPriceImageViewFrame.size.width;
    giftPriceImageViewFrame.origin.y = priceLabelFrame.origin.y - 2.0;
    giftPriceImageViewFrame.size.height = priceLabelFrame.size.height + 4.0;
    giftPriceImageView.frame = giftPriceImageViewFrame;
    
    giftManufactureLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeTiny]];
    giftManufactureLabel.textColor = [UIColor grayColor];
    
    if (giftManufactureLabel.text != nil && [giftManufactureLabel.text isEqualToString:@""] == NO){
        CGRect descriptionLabelFrame = giftManufactureLabel.frame;
        descriptionLabelFrame.origin.y = 26.0;
        giftManufactureLabel.frame = descriptionLabelFrame;
        giftManufactureLabel.hidden = NO;
    }else{
        giftManufactureLabel.hidden = YES;
    }
    
    giftNameLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:[HappyGiftAppDelegate fontSizeSmall]];
    giftNameLabel.text = giftOrder.gift.name;
    giftNameLabel.textColor = [UIColor blackColor];
    
    CGFloat giftNameLabelWidth = giftView.frame.size.width - 20.0 - priceLabelSize.width;
    CGRect giftNameLabelFrame = giftNameLabel.frame;
    giftNameLabelFrame.origin.y = 8.0;
    giftNameLabelFrame.size.width = giftNameLabelWidth;
    
    if (giftManufactureLabel.hidden == YES){
        giftNameLabel.lineBreakMode = UILineBreakModeClip;
        giftNameLabel.numberOfLines = 0;
        CGSize giftNameLabelSize = [giftNameLabel.text sizeWithFont:giftNameLabel.font constrainedToSize:CGSizeMake(giftNameLabelWidth, 40.0) lineBreakMode:UILineBreakModeClip];
        giftNameLabelFrame.size.height = giftNameLabelSize.height;
    }else{
        giftNameLabel.lineBreakMode = UILineBreakModeTailTruncation;
        giftNameLabel.numberOfLines = 1;
        CGSize giftNameLabelSize = [@"A" sizeWithFont:giftNameLabel.font];
        giftNameLabelFrame.size.height = giftNameLabelSize.height;
    }
    giftNameLabel.frame = giftNameLabelFrame;
    
    cardContentLabel.text = giftOrder.giftCard.content;
    CGRect cardContentLabelFrame = cardContentLabel.frame;
    CGSize cardContentLabelSize = [cardContentLabel.text sizeWithFont:cardContentLabel.font constrainedToSize:CGSizeMake(cardContentLabelFrame.size.width, 80.0)];
    cardContentLabelFrame.size.height = cardContentLabelSize.height;
    cardContentLabel.frame = cardContentLabelFrame;
    
    if (giftOrder.thanksNote != nil && [giftOrder.thanksNote isEqualToString:@""] == NO){
        thankTitleLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:[HappyGiftAppDelegate fontSizeNormal]];
        thankTitleLabel.textColor = [UIColor blackColor];
        thankTitleLabel.text = @"接收人回执";
        
        thankContentLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:[HappyGiftAppDelegate fontSizeNormal]];
        thankContentLabel.textColor = [UIColor blackColor];
        thankContentLabel.text = giftOrder.thanksNote;
        thankContentLabel.numberOfLines = 0;
        
        CGRect thankContentLabelFrame = thankContentLabel.frame;
        CGSize thankContentLabelSize = [thankContentLabel.text sizeWithFont:thankContentLabel.font constrainedToSize:CGSizeMake(thankContentLabelFrame.size.width, 200.0)];
        thankContentLabelFrame.size.height = thankContentLabelSize.height;
        thankContentLabel.frame = thankContentLabelFrame;
        
        thankView.hidden = NO;
        [thankImageView updateUserImageViewWithRecipient:giftOrder.giftRecipient];
        if (thankView.frame.size.height < thankContentLabelFrame.origin.y + thankContentLabelFrame.size.height + 10.0) {
            thankView.frame = CGRectMake(thankView.frame.origin.x, thankView.frame.origin.y,
                                         thankView.frame.size.width, 
                                         thankContentLabelFrame.origin.y + thankContentLabelFrame.size.height + 10.0);
        }
        
        CGRect summaryViewFrame = summaryView.frame;
        summaryViewFrame.origin.y = thankView.frame.origin.y + thankView.frame.size.height + 10.0;
        summaryView.frame = summaryViewFrame;
    }else{
        thankView.hidden = YES;
        
        CGRect summaryViewFrame = summaryView.frame;
        if (cardView.hidden == NO) {
            summaryViewFrame.origin.y = cardView.frame.origin.y + cardView.frame.size.height + 10.0;
        } else {
            summaryViewFrame.origin.y = giftView.frame.origin.y + giftView.frame.size.height + 10.0;
        }
        summaryView.frame = summaryViewFrame;
    }
    
    if (fabs(giftOrder.gift.price) < 0.005){
        summaryPriceValueLabel.text = @"¥0.00";
    }else{
        summaryPriceValueLabel.text = [NSString stringWithFormat:@"¥%.2f", giftOrder.gift.price];
    }
    
    if (fabs(giftOrder.shippingCost) < 0.005){
        summaryDeliveryValueLabel.text = @"¥0.00";
    }else{
        summaryDeliveryValueLabel.text = [NSString stringWithFormat:@"¥%.2f", giftOrder.shippingCost];
    }
    
    if (giftOrder.gift.type == GIFT_TYPE_COUPON){
        summaryValueLabel.text = @"¥0.00";
        summaryCreditView.hidden = YES;
    }else{
        if ([giftOrder canPaid]){
            if ([giftOrder isPaid] == NO){
                if (giftOrder.creditConsume == 0){
                    NSNumber* creditExchangeObject = [[HGAppConfigurationService sharedService].appConfiguration objectForKey:kAppConfigurationKeyCreditExchange];
                    float creditExchange = [creditExchangeObject floatValue];
                    if (giftOrder.gift.creditLimit == YES && [HGCreditService sharedService].creditTotal >= giftOrder.gift.creditConsume){
                        summaryCreditLabel.text = [NSString stringWithFormat:@"使用%d积分抵¥%.2f", giftOrder.gift.creditConsume, (float)giftOrder.gift.creditMoney];
                        summaryCreditView.hidden = NO;
                        
                        [summaryCreditButton setEnabled:YES];
                        giftOrder.useCredit = YES;
                        summaryValueLabel.text = [NSString stringWithFormat:@"¥%.2f", giftOrder.gift.price + giftOrder.shippingCost - giftOrder.gift.creditMoney];
                        summaryCreditImageView.highlighted = NO;
                        summaryValueLabel.highlighted = NO;
                        
                    }else if (giftOrder.gift.creditLimit == NO && [HGCreditService sharedService].creditTotal*creditExchange >= 1.0){
                        if ([HGCreditService sharedService].creditTotal*creditExchange <=  giftOrder.gift.price){
                            float creditMoney = [HGCreditService sharedService].creditTotal*creditExchange;
                            summaryCreditLabel.text = [NSString stringWithFormat:@"使用%d积分抵¥%.2f", [HGCreditService sharedService].creditTotal, creditMoney];
                            summaryValueLabel.text = [NSString stringWithFormat:@"¥%.2f", giftOrder.gift.price + giftOrder.shippingCost - creditMoney];
                        }else{
                            int creditConsume = (int)(giftOrder.gift.price/creditExchange);
                            float creditMoney = giftOrder.gift.price;
                            summaryCreditLabel.text = [NSString stringWithFormat:@"使用%d积分抵¥%.2f", creditConsume, creditMoney];
                            summaryValueLabel.text = [NSString stringWithFormat:@"¥%.2f", giftOrder.gift.price + giftOrder.shippingCost - creditMoney];
                        }
                        summaryCreditView.hidden = NO;
                        
                        [summaryCreditButton setEnabled:YES];
                        giftOrder.useCredit = YES;
                        
                        summaryCreditImageView.highlighted = NO;
                        summaryValueLabel.highlighted = NO;
                        
                    }else{
                        giftOrder.useCredit = NO;
                        summaryValueLabel.text = [NSString stringWithFormat:@"¥%.2f", giftOrder.gift.price + giftOrder.shippingCost];
                        summaryCreditView.hidden = YES;
                    }
                }else{
                    summaryCreditLabel.text = [NSString stringWithFormat:@"已使用%d积分抵¥%.2f", giftOrder.creditConsume, giftOrder.creditMoney];
                    summaryCreditView.hidden = NO;
                    summaryCreditButton.hidden = YES;
                    summaryCreditImageView.hidden = YES;
                    
                    CGSize summaryTitleLabelSize = [summaryTitleLabel.text sizeWithFont:summaryTitleLabel.font];
                    CGRect summaryCreditLabelFrame = summaryCreditLabel.frame;
                    summaryCreditLabelFrame.origin.x = summaryTitleLabelSize.width - 5.0;
                    summaryCreditLabel.frame = summaryCreditLabelFrame;
                    
                    giftOrder.useCredit = YES;
                    summaryValueLabel.text = [NSString stringWithFormat:@"¥%.2f", giftOrder.gift.price + giftOrder.shippingCost - giftOrder.creditMoney];
                    summaryCreditImageView.highlighted = NO;
                    summaryValueLabel.highlighted = NO;
                }
            }else{
                if (giftOrder.creditConsume > 0){
                    summaryCreditLabel.text = [NSString stringWithFormat:@"使用%d积分抵¥%.2f", giftOrder.creditConsume, giftOrder.creditMoney];
                    summaryCreditView.hidden = NO;
                    
                    [summaryCreditButton setEnabled:NO];
                    
                    summaryValueLabel.text = [NSString stringWithFormat:@"¥%.2f", giftOrder.gift.price + giftOrder.shippingCost - giftOrder.creditMoney];
                    summaryCreditImageView.highlighted = NO;
                    summaryValueLabel.highlighted = NO;
                    
                }else{
                    summaryValueLabel.text = [NSString stringWithFormat:@"¥%.2f", giftOrder.gift.price + giftOrder.shippingCost];
                    summaryCreditView.hidden = YES;
                }
            }
            
        }else{
            summaryValueLabel.text = [NSString stringWithFormat:@"¥%.2f", giftOrder.gift.price + giftOrder.shippingCost];
            summaryCreditView.hidden = YES;
        }
    }
    
    
    CGSize contentSize = contentScrollView.contentSize;
    contentSize.height = summaryView.frame.origin.y + summaryView.frame.size.height + 20.0;
    
    paidLabel.hidden = YES;
    paidLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeLarge]];
    paidLabel.text = @"已成功付款";
    
    paidLabel.textColor = UIColorFromRGB(0xd53d3b);
    
    immediatelyPayExplainationLabel.hidden = YES;
    immediatelyPayExplainationLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeTiny]];
    immediatelyPayExplainationLabel.textColor = [UIColor grayColor];
    immediatelyPayExplainationLabel.text =[NSString stringWithFormat:@"您可以选择现在付款或者等待%@确认收礼信息后付款", giftOrder.giftRecipient.recipientDisplayName];
    
    laterPayHint.hidden = YES;
    laterPayHint.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeLarge]];
    laterPayHint.textColor = UIColorFromRGB(0xd53d3b);
    laterPayHint.text =[NSString stringWithFormat:@"请等待%@确认收礼信息后付款", giftOrder.giftRecipient.recipientDisplayName];
    
    summaryPriceView.hidden = NO;
    
    
    if (giftOrder.status == GIFT_ORDER_STATUS_CANCELED) {
        // hide pay & cancel
        cancelButtonTopSeparator.hidden = YES;
        cancelButton.hidden = YES;
        payButton.hidden = YES;
        navigationBar.topItem.rightBarButtonItem = nil;
        
        summaryPriceView.hidden = YES;
        
        contentSize.height = contentSize.height - 140.0 - summaryPriceView.frame.size.height;
    } else if (giftOrder.isPaid) {
        // show is paid label
        cancelButtonTopSeparator.hidden = YES;
        cancelButton.hidden = YES;
        payButton.hidden = YES;
        navigationBar.topItem.rightBarButtonItem = nil;
        if (fabs(giftOrder.gift.price) > 0.005){
            paidLabel.hidden = NO;
            contentSize.height -= 90.0;
        }else{
            paidLabel.hidden = YES;
            contentSize.height -= 130.0;
        }
    } else if (![giftOrder canPaid]) {
        // show cancel only
        payButton.hidden = YES;
        navigationBar.topItem.rightBarButtonItem = nil;
        
        summaryPriceView.hidden = YES;
        laterPayHint.hidden = NO;
        
        CGRect cancelButtonTopSeparatorFrame = cancelButtonTopSeparator.frame;
        cancelButtonTopSeparatorFrame.origin.y = laterPayHint.frame.origin.y + laterPayHint.frame.size.height + 15.0;
        cancelButtonTopSeparator.frame = cancelButtonTopSeparatorFrame;
        
        CGRect cancelButtonFrame = cancelButton.frame;
        cancelButtonFrame.origin.y = cancelButtonTopSeparatorFrame.origin.y + 5.0;
        cancelButton.frame = cancelButtonFrame;
        
        contentSize.height -= (70.0 + summaryPriceView.frame.size.height);
    } else if ([giftOrder isImmediatelyPay]) {
        payButton.hidden = NO;
        cancelButton.hidden = NO;
        immediatelyPayExplainationLabel.hidden = NO;
        navigationBar.topItem.rightBarButtonItem = nil;
    } else {
        // hide immediatelyPayExplainationLabel
        payButton.hidden = NO;
        cancelButton.hidden = NO;
        CGRect cancelButtonTopSeparatorFrame = cancelButtonTopSeparator.frame;
        cancelButtonTopSeparatorFrame.origin.y = payButton.frame.origin.y + payButton.frame.size.height + 15.0;
        cancelButtonTopSeparator.frame = cancelButtonTopSeparatorFrame;
        
        CGRect cancelButtonFrame = cancelButton.frame;
        cancelButtonFrame.origin.y = cancelButtonTopSeparatorFrame.origin.y + 5.0;
        cancelButton.frame = cancelButtonFrame;
        
        contentSize.height -= 45;
    }
    
    
    if (contentSize.height <= contentScrollView.frame.size.height){
        contentSize.height = contentScrollView.frame.size.height + 1.0;
    }
    
    [contentScrollView setContentSize:contentSize];
    
    if (giftOrder.status == GIFT_ORDER_STATUS_NOTIFIED) {
        statusNotifiedView.highlighted = YES;
        statusNotifiedLabel.highlighted = YES;
    } else if (giftOrder.status == GIFT_ORDER_STATUS_READ) {
        statusNotifiedView.highlighted = YES;
        statusNotifiedLabel.highlighted = YES;
        statusReadView.highlighted = YES;
        statusReadLabel.highlighted = YES;
    } else if (giftOrder.status == GIFT_ORDER_STATUS_ACCEPTED) {
        statusNotifiedView.highlighted = YES;
        statusNotifiedLabel.highlighted = YES;
        statusReadView.highlighted = YES;
        statusReadLabel.highlighted = YES;
        statusAcceptedView.highlighted = YES;
        statusAcceptedLabel.highlighted = YES;
    } else if (giftOrder.status == GIFT_ORDER_STATUS_SHIPPED) {
        statusNotifiedView.highlighted = YES;
        statusNotifiedLabel.highlighted = YES;
        statusReadView.highlighted = YES;
        statusReadLabel.highlighted = YES;
        statusAcceptedView.highlighted = YES;
        statusAcceptedLabel.highlighted = YES;
        statusShippedView.highlighted = YES;
        statusShippedLabel.highlighted = YES;
    } else if (giftOrder.status == GIFT_ORDER_STATUS_DELIVERED) {
        statusNotifiedView.highlighted = YES;
        statusNotifiedLabel.highlighted = YES;
        statusReadView.highlighted = YES;
        statusReadLabel.highlighted = YES;
        statusAcceptedView.highlighted = YES;
        statusAcceptedLabel.highlighted = YES;
        statusShippedView.highlighted = YES;
        statusShippedLabel.highlighted = YES;
        statusDeliveredView.highlighted = YES;
        statusDeliveredLabel.highlighted = YES;
    }
    
    if (giftOrder.orderType == kOrderTypeQuickOrder) {
        statusPaidView.hidden = NO;
        statusPaidLabel.hidden = NO;
        
        if (giftOrder.isPaid) {
            statusPaidView.highlighted = YES;
            statusPaidLabel.highlighted = YES;
        } else {
            statusPaidView.highlighted = NO;
            statusPaidLabel.highlighted = NO;
        }
        
        statusNotifiedView.hidden = YES;
        statusNotifiedLabel.hidden = YES;
        statusReadView.hidden = YES;
        statusReadLabel.hidden = YES;
        statusAcceptedView.hidden = YES;
        statusAcceptedLabel.hidden = YES;
        
        CGRect tmpFrame = statusPaidView.frame;
        tmpFrame.origin.x = 40.0;
        statusPaidView.frame = tmpFrame;
        tmpFrame = statusPaidLabel.frame;
        tmpFrame.origin.x = 29.0;
        statusPaidLabel.frame = tmpFrame;
        
        tmpFrame = statusShippedView.frame;
        tmpFrame.origin.x = 135.0;
        statusShippedView.frame = tmpFrame;
        tmpFrame = statusShippedLabel.frame;
        tmpFrame.origin.x = 124.0;
        statusShippedLabel.frame = tmpFrame;
        
        tmpFrame = statusDeliveredView.frame;
        tmpFrame.origin.x = 230.0;
        statusDeliveredView.frame = tmpFrame;
        tmpFrame = statusDeliveredLabel.frame;
        tmpFrame.origin.x = 219.0;
        statusDeliveredLabel.frame = tmpFrame;
    }
}

- (void)viewDidUnload{
    [super viewDidUnload];
    [progressView removeFromSuperview];
    [progressView release];
    progressView = nil;
    if (titleLabel != nil){
        [titleLabel removeFromSuperview];
        titleLabel = nil;
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kHGNotificationApplicationDidBecomeActive object:nil];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}


#pragma mark Notifications
- (void)handleApplicationDidBecomeActiveAction:(NSNotification *)notification {
    contentScrollView.hidden = YES;
    userInfoView.hidden = YES;
    [progressView startAnimation];
    [HGGiftOrderService sharedService].myGiftOrderDelegate = self;
    [[HGGiftOrderService sharedService] requestMyGiftOrder:giftOrder.identifier];
    [[HGCreditService sharedService] requestCreditTotal];
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
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kHGNotificationApplicationDidBecomeActive object:nil];
    
    [contentScrollView release];
    if (progressView != nil){
        [progressView release];
    }
    [userTitleLabel release];
    [userNameLabel release];
    [userImageView release];
    [shareButton release];
    
    [statusView release];
    [statusTitleLabel release];
    [statusNotifiedView release];
    [statusReadView release];
    [statusAcceptedView release];
    [statusShippedView release];
    [statusDeliveredView release];
    [statusNotifiedLabel release];
    [statusReadLabel release];
    [statusAcceptedLabel release];
    [statusShippedLabel release];
    [statusDeliveredLabel release];
    
    [giftView release];
    [giftTitleLabel release];
    [giftImageView release];
    [giftNameLabel release];
    [giftManufactureLabel release];
    
    [cardView release];
    [cardTitleLabel release];
    [cardImageView release];
    [cardContentLabel release];
    
    [thankView release];
    [thankTitleLabel release];
    [thankImageView release];
    [thankContentLabel release];
    
    [summaryView release];
    [summaryTitleLabel release];
    [summaryPriceTitleLabel release];
    [giftPriceImageView release];
    [summaryCreditImageView release];
    [summaryDeliveryTitleLabel release];
    [summaryPriceValueLabel release];
    [summaryDeliveryValueLabel release];
    [payButton release];
    [cancelButton release];
    [summaryCreditView release];
    [summaryCreditButton release];
    [summaryCreditLabel release];
    [giftOrder release];
    [titleLabel release];
    
    HGGiftOrderService* giftOrderService = [HGGiftOrderService sharedService];
    if (giftOrderService.delegate == self) {
        giftOrderService.delegate = nil;
    }
    if (giftOrderService.myGiftOrderDelegate == self) {
        giftOrderService.myGiftOrderDelegate = nil;
    }
	[super dealloc];
}

- (void)handleBackAction:(id)sender{
    if ([[self.navigationController viewControllers] count] == 1){
        [self dismissModalViewControllerAnimated:YES];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)handlePayAction:(id)sender {
    if (giftOrder.paymentUrl && ![@"" isEqualToString:giftOrder.paymentUrl]) {
        if (giftOrder.useCredit){
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@&use_credit=1", giftOrder.paymentUrl]]];
            [HGTrackingService logEvent:kTrackingEventPayGiftOrder withParameters:[NSDictionary dictionaryWithObjectsAndKeys:giftOrder.identifier, @"order", @"YES", @"useCredit", nil]];
        }else{
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:giftOrder.paymentUrl]];
            [HGTrackingService logEvent:kTrackingEventPayGiftOrder withParameters:[NSDictionary dictionaryWithObjectsAndKeys:giftOrder.identifier, @"order", @"NO", @"useCredit", nil]];
        }
    }
}

- (void)handleCancelAction:(id)sender{
    if ([progressView animating] == NO && giftOrder.status != GIFT_ORDER_STATUS_CANCELED){
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"提示" 
                                                             message:@"是否取消这个礼品订单？"
                                                            delegate:self 
                                                   cancelButtonTitle:@"确定"
                                                   otherButtonTitles:@"取消", nil];
        [alertView show];
        [alertView release];
    }
}

- (void)handleShareAction:(id)sender{
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
        
        [HGTrackingService logEvent:kTrackingEventEnterShare withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"HGGiftDetailViewController", @"from", @"shareOrder", @"type", network == NETWORK_SNS_WEIBO ? @"weibo" : @"renren", @"network", nil]];
        
        HGShareViewController* viewController = [[HGShareViewController alloc] initWithGiftOrder:giftOrder network:network];
        [self presentModalViewController:viewController animated:YES];
        [viewController release];
        [HGTrackingService logPageView];
    }
}

- (void)handleCreditButtonSelectAction:(id)sender{
    giftOrder.useCredit = !giftOrder.useCredit;
    if (giftOrder.useCredit){
        NSNumber* creditExchangeObject = [[HGAppConfigurationService sharedService].appConfiguration objectForKey:kAppConfigurationKeyCreditExchange];
        float creditExchange = [creditExchangeObject floatValue];
        if (giftOrder.gift.creditLimit == YES && [HGCreditService sharedService].creditTotal >= giftOrder.gift.creditConsume){
            summaryValueLabel.text = [NSString stringWithFormat:@"¥%.2f", giftOrder.gift.price + giftOrder.shippingCost - giftOrder.gift.creditMoney];
        }else if (giftOrder.gift.creditLimit == NO && [HGCreditService sharedService].creditTotal >= (int)(1.0/creditExchange)){
            if ([HGCreditService sharedService].creditTotal*creditExchange <=  giftOrder.gift.price){
                float creditMoney = [HGCreditService sharedService].creditTotal*creditExchange;
                summaryValueLabel.text = [NSString stringWithFormat:@"¥%.2f", giftOrder.gift.price + giftOrder.shippingCost - creditMoney];
            }else{
                float creditMoney = giftOrder.gift.price;
                summaryValueLabel.text = [NSString stringWithFormat:@"¥%.2f", giftOrder.gift.price + giftOrder.shippingCost - creditMoney];
            }
        } 
        summaryCreditImageView.highlighted = NO;
        summaryCreditLabel.highlighted = NO;
        
        CATransition *animation = [CATransition animation];
        [animation setDelegate:self];
        [animation setType:kCATransitionPush];
        [animation setSubtype:kCATransitionFromTop];
        [animation setDuration:0.3];
        [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        [summaryValueLabel.layer addAnimation:animation forKey:@"updateSummaryValueAnimation"];
    }else{
        summaryValueLabel.text = [NSString stringWithFormat:@"¥%.2f", giftOrder.gift.price + giftOrder.shippingCost];  
        summaryCreditImageView.highlighted = YES;
        summaryCreditLabel.highlighted = YES;
        
        CATransition *animation = [CATransition animation];
        [animation setDelegate:self];
        [animation setType:kCATransitionPush];
        [animation setSubtype:kCATransitionFromBottom];
        [animation setDuration:0.3];
        [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        [summaryValueLabel.layer addAnimation:animation forKey:@"updateSummaryValueAnimation"];
    }
    
    CATransition *animation = [CATransition animation];
    [animation setDelegate:self];
    [animation setType:kCATransitionFade];
    [animation setDuration:0.2];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [summaryCreditImageView.layer addAnimation:animation forKey:@"updateSummaryCreditImageAnimation"];
    [summaryCreditLabel.layer addAnimation:animation forKey:@"updateSummaryCreditLabelAnimation"];
}

- (void)handleCreditButtonDownAction:(id)sender{
    
}

- (void)handleCreditButtonUpAction:(id)sender{
    
}

#pragma mark  HGImagesService selector
- (void)didImageLoaded:(HGImageData*)image{
    if ([image.url isEqualToString:giftOrder.gift.thumb]){
        UIImage *coverImage = image.image;
        giftImageView.image = [coverImage imageWithFrame:giftImageView.frame.size color:[HappyGiftAppDelegate imageFrameColor]];
        
        CATransition *animation = [CATransition animation];
        [animation setDelegate:self];
        [animation setType:kCATransitionFade];
        [animation setDuration:0.2];
        [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        [giftImageView.layer addAnimation:animation forKey:@"updateCoverAnimation"];
    } else if ([image.url isEqualToString:giftOrder.giftCard.cover]) {
        cardImageView.image = [image.image imageWithFrame:cardImageView.frame.size color:[HappyGiftAppDelegate imageFrameColor]];
        
        CATransition *animation = [CATransition animation];
        [animation setDelegate:self];
        [animation setType:kCATransitionFade];
        [animation setDuration:0.2];
        [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        [cardImageView.layer addAnimation:animation forKey:@"updateGiftImageAnimation"];
    }
}

#pragma mark  HGGiftOrderServiceDelegate
- (void)giftOrderService:(HGGiftOrderService *)theGiftOrderService didRequestCancelGiftOrderSucceed:(HGGiftOrder*)theGiftOrder{
    [progressView stopAnimation];
    HappyGiftAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    [appDelegate sendNotification:[NSString stringWithFormat:@"成功取消订单"]];
    
    statusView.hidden = YES;
    
    [UIView animateWithDuration:0.3 
                          delay:0.0 
                        options:UIViewAnimationOptionCurveEaseInOut 
                     animations:^{
                         giftView.alpha = 0.0;
                         cardView.alpha = 0.0;
                         
                         if (giftOrder.thanksNote != nil && [giftOrder.thanksNote isEqualToString:@""] == NO) {
                             thankView.hidden = NO;
                             thankView.alpha = 0.0;
                         } else {
                             thankView.hidden = YES;
                         }
                         summaryView.alpha = 0.0;
                     } 
                     completion:^(BOOL finished) {
                         titleLabel.text = @"订单已取消";
                         cancelButton.hidden = YES;
                         cancelButtonTopSeparator.hidden = YES;
                         payButton.hidden = YES;
                         paidLabel.hidden = YES;
                         laterPayHint.hidden = YES;
                         immediatelyPayExplainationLabel.hidden = YES;
                         navigationBar.topItem.rightBarButtonItem = nil;
                         
                         summaryPriceView.hidden = YES;
                         
                         CGRect tmpFrame = giftView.frame;
                         tmpFrame.origin.y = statusView.frame.origin.y;
                         giftView.frame = tmpFrame;
                         
                         tmpFrame = cardView.frame;
                         tmpFrame.origin.y = giftView.frame.origin.y + giftView.frame.size.height + 10.0;
                         cardView.frame = tmpFrame;
                         
                         if (giftOrder.thanksNote != nil && [giftOrder.thanksNote isEqualToString:@""] == NO) {
                             thankView.hidden = NO;
                             tmpFrame = thankView.frame;
                             if (cardView.hidden == NO) {
                                 tmpFrame.origin.y = cardView.frame.origin.y + cardView.frame.size.height + 10.0;
                             } else {
                                 tmpFrame.origin.y = giftView.frame.origin.y + giftView.frame.size.height + 10.0;
                             }
                             thankView.frame = tmpFrame;
                             
                             tmpFrame = summaryView.frame;
                             tmpFrame.origin.y = thankView.frame.origin.y + thankView.frame.size.height + 10.0;
                             summaryView.frame = tmpFrame;
                         } else {
                             thankView.hidden = YES;
                             
                             tmpFrame = summaryView.frame;
                             if (cardView.hidden == NO) {
                                 tmpFrame.origin.y = cardView.frame.origin.y + cardView.frame.size.height + 10.0;
                             } else {
                                 tmpFrame.origin.y = giftView.frame.origin.y + giftView.frame.size.height + 10.0;
                             }
                             summaryView.frame = tmpFrame;
                         }
                         
                         CGSize contentSize = contentScrollView.contentSize;
                         contentSize.height = summaryView.frame.origin.y + summaryView.frame.size.height + 20.0 - 140.0 - summaryPriceView.frame.size.height;
                         if (contentSize.height <= contentScrollView.frame.size.height){
                             contentSize.height = contentScrollView.frame.size.height + 1.0;
                         }
                         [contentScrollView setContentSize:contentSize];
                         
                         [UIView animateWithDuration:0.6 
                                               delay:0.0 
                                             options:UIViewAnimationOptionCurveEaseInOut 
                                          animations:^{
                                              giftView.alpha = 1.0;
                                              cardView.alpha = 1.0;
                                              
                                              if (giftOrder.thanksNote != nil && [giftOrder.thanksNote isEqualToString:@""] == NO) {
                                                  thankView.hidden = NO;
                                              } else {
                                                  thankView.hidden = YES;
                                              }
                                              thankView.alpha = 1.0;
                                              summaryView.alpha = 1.0;
                                          } 
                                          completion:^(BOOL finished) {
                                              
                                          }];
                         
                     }];
    
    [HGTrackingService logEvent:kTrackingEventCancelGiftOrder withParameters:[NSDictionary dictionaryWithObjectsAndKeys:theGiftOrder.identifier, @"order", nil]];
}

- (void)giftOrderService:(HGGiftOrderService *)theGiftOrderService didRequestCancelGiftOrderFail:(NSString*)error{
    [progressView stopAnimation];
}

- (void)giftOrderService:(HGGiftOrderService *)giftOrderService didRequestMyGiftOrderSucceed:(HGGiftOrder*)order {
    [progressView stopAnimation];
    if (order) {
        if (giftOrder) {
            [giftOrder release];
            giftOrder = nil;
        }
        giftOrder = [order retain];
        [self setupUIWithAnimation];
    } else {
        if (shouldRefetchData) {
            HappyGiftAppDelegate *appDelegate = (HappyGiftAppDelegate *)[[UIApplication sharedApplication] delegate];
            [appDelegate sendNotification:@"获取订单信息失败，请稍后再试"];
        }
    }
    
    giftOrderService.myGiftOrderDelegate = nil;
}

- (void)giftOrderService:(HGGiftOrderService *)giftOrderService didRequestMyGiftOrderFail:(NSString*) error {
    [progressView stopAnimation];
    if (shouldRefetchData) {
        HappyGiftAppDelegate *appDelegate = (HappyGiftAppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate sendNotification:@"获取订单信息失败，请稍后再试"];
    }
    
    giftOrderService.myGiftOrderDelegate = nil;
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
    HGShareViewController* viewController = [[HGShareViewController alloc] initWithGiftOrder:giftOrder network:network];
    [self presentModalViewController:viewController animated:YES];
    [viewController release];
    [HGTrackingService logPageView];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0){
        [progressView startAnimation];
        HGGiftOrderService* giftOrderService = [HGGiftOrderService sharedService];
        giftOrderService.delegate = self;
        [giftOrderService requestCancelOrder:giftOrder];
    }
}

@end

