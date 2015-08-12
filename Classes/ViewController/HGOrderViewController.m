//
//  HGOrderViewController.m
//  HappyGift
//
//  Created by Zhang Yuhui on 2/11/11.
//  Copyright 2011 Ztelic Inc Inc. All rights reserved.
//

#import "HGOrderViewController.h"
#import "HappyGiftAppDelegate.h"
#import "HGConstants.h"
#import "HGProgressView.h"
#import "HGImageService.h"
#import "HGGiftOrderService.h"
#import "HGGiftOrder.h"
#import "HGRecipient.h"
#import "UIBarButtonItem+Addition.h"
#import "UIImage+Addition.h"
#import "HGSentGiftDetailViewController.h"
#import "HGTrackingService.h"
#import <QuartzCore/QuartzCore.h>
#import <MessageUI/MessageUI.h>
#import "HGRecipient.h"
#import "HGRecipientService.h"
#import "HGUserImageView.h"
#import "HGCreditService.h"
#import "HGGift.h"
#import "HGUtility.h"

@interface HGOrderViewController()<UIScrollViewDelegate, HGGiftOrderServiceDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate>
  
@end

@implementation HGOrderViewController
- (id)initWithGiftOrder:(HGGiftOrder*)theGiftOrder{
    self = [super initWithNibName:@"HGOrderViewController" bundle:nil];
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
    
    rightBarButtonItem = [[UIBarButtonItem alloc ] initNavigationRightTextBarButtonItem:@"发送" target:self action:@selector(handleDoneAction:)];
    navigationBar.topItem.rightBarButtonItem = rightBarButtonItem;
    
    
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
	titleLabel.text = @"发送清单";
    [titleView addSubview:titleLabel];
    [titleLabel release];
    
	navigationBar.topItem.titleView = titleView;
    [titleView release];
    
    senderLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeTiny]];
    senderLabel.textColor = [UIColor grayColor];
    senderLabel.text = @"发送至";
    
    senderNameLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:[HappyGiftAppDelegate fontSizeNormal]];
    senderNameLabel.textColor = UIColorFromRGB(0xd53d3b);;
    senderNameLabel.text = giftOrder.giftRecipient.recipientDisplayName;
    
    nameLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:[HappyGiftAppDelegate fontSizeLarge]];
    nameLabel.numberOfLines = 0;
    nameLabel.textColor = [UIColor blackColor];
    nameLabel.text = giftOrder.gift.name;
    
    summaryShippingCostTitleLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeNormal]];
    summaryTotalPriceTitleLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeNormal]];
    
    addressTitleLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeNormal]];
    phoneTitleLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeNormal]];
    addressLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeNormal]];
    phoneLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeNormal]];
    
    descriptionLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeSmall]];
    descriptionLabel.textColor = [UIColor grayColor];
    if (giftOrder.gift.sexyName != nil && [giftOrder.gift.sexyName isEqualToString:@""] == NO){
        descriptionLabel.text = giftOrder.gift.sexyName;
    }else{
        descriptionLabel.text = giftOrder.gift.manufacturer;
    }
    
    priceLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeNormal]];
    priceLabel.textColor = UIColorFromRGB(0xd53d3b);;
    if (fabs(giftOrder.gift.price) < 0.005){
        priceLabel.text = @"免费";
    }else{
        priceLabel.text = [NSString stringWithFormat:@"¥%.2f", giftOrder.gift.price];
    }
    CGSize nameLabelSize = [nameLabel.text sizeWithFont:nameLabel.font constrainedToSize:CGSizeMake(nameLabel.frame.size.width, 50.0)];
    CGRect nameLabelFrame = nameLabel.frame;
    nameLabelFrame.size.height = nameLabelSize.height;
    nameLabel.frame = nameLabelFrame;
    
    CGSize descriptionLabelSize = [descriptionLabel.text sizeWithFont:descriptionLabel.font constrainedToSize:CGSizeMake(descriptionLabel.frame.size.width, 40.0)];
    CGRect descriptionLabelFrame = descriptionLabel.frame;
    descriptionLabelFrame.size.height = descriptionLabelSize.height;
    descriptionLabelFrame.origin.y = nameLabelFrame.origin.y + nameLabelFrame.size.height;
    descriptionLabel.frame = descriptionLabelFrame;
    
    CGSize priceLabelSize = [priceLabel.text sizeWithFont:priceLabel.font];
    
    CGRect priceLabelFrame = priceLabel.frame;
    priceLabelFrame.size.width = priceLabelSize.width;
    if (nameLabelSize.height >= 50.0){
        priceLabelFrame.origin.y = descriptionLabelFrame.origin.y + descriptionLabelFrame.size.height + 5.0;
    }else{
        priceLabelFrame.origin.y = descriptionLabelFrame.origin.y + descriptionLabelFrame.size.height + 10.0;
    }
    if (priceLabelFrame.origin.y > 85.0){
        priceLabelFrame.origin.y = 85.0;
    }
    priceLabel.frame = priceLabelFrame;
    
    creditLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeTiny]];
    creditLabel.minimumFontSize = 10.0;
    creditLabel.adjustsFontSizeToFitWidth = YES;
    creditLabel.textColor = UIColorFromRGB(0xd53d3b);
    if ((fabs(giftOrder.gift.price) >= 0.005) && giftOrder.gift.creditLimit == YES){
        if (giftOrder.gift.creditConsume > 0 && giftOrder.gift.creditMoney > 0){
            creditLabel.text = [NSString stringWithFormat:@"(%d积分抵¥%.2f)", giftOrder.gift.creditConsume, (float)giftOrder.gift.creditMoney];
            
            CGRect creditLabelFrame = creditLabel.frame;
            creditLabelFrame.origin.x = priceLabelFrame.origin.x + priceLabelFrame.size.width + 3.0;
            creditLabelFrame.origin.y = priceLabelFrame.origin.y + 1.0;
            creditLabelFrame.size.width = 310.0 - creditLabelFrame.origin.x;
            creditLabel.frame = creditLabelFrame;
            
            creditLabel.hidden = NO;
        }else{
            creditLabel.hidden = YES;
        }
    }else{
        creditLabel.hidden = YES;
    }
    
    [sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [sendButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    sendButton.titleLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:[HappyGiftAppDelegate fontSizeLarge]];
    [sendButton setTitle:[NSString stringWithFormat:@"发送给%@", giftOrder.giftRecipient.recipientDisplayName] forState:UIControlStateNormal];
    UIImage* sendButtonBackgroundImage = [[UIImage imageNamed:@"gift_selection_button"] stretchableImageWithLeftCapWidth:5 topCapHeight:10];
    [sendButton setBackgroundImage:sendButtonBackgroundImage forState:UIControlStateNormal];
    
    [sendButton addTarget:self action:@selector(handleDoneAction:) forControlEvents:UIControlEventTouchUpInside];
    
    NSString* shippingCostText;
    if (giftOrder.gift.type == GIFT_TYPE_COUPON){
        shippingCostText = @"该礼品会通过短信或邮件发送给收礼人";
    }else{
        if ([giftOrder.gift isFreeShippingCost]) {
            shippingCostText = @"该礼品特别优惠活动中，免运费";
        } else if ([giftOrder.gift isFixedShippingCost]) {
            shippingCostText = [NSString stringWithFormat:@"统一运费：¥%.0f", giftOrder.gift.shippingCostMax];
        } else {
            shippingCostText = [NSString stringWithFormat:@"运费：¥%.0f~¥%.0f，取决于收礼人所在地区", giftOrder.gift.shippingCostMin, giftOrder.gift.shippingCostMax];
        }
    }
    
    paymentHintLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeSmall]];
    paymentHintLabel.textColor = [UIColor grayColor];
    
    if (fabs(giftOrder.gift.price) > 0.005){
        paymentHintLabel.text = [NSString stringWithFormat:@"乐送会在获得收礼人地址信息后通知您付款\n（%@）", shippingCostText];
    }else{
        paymentHintLabel.text = [NSString stringWithFormat:@"该礼品免费，您无需付款\n（%@）", shippingCostText];
    }
    
    summaryGiftPriceLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:[HappyGiftAppDelegate fontSizeNormal]];
    summaryGiftPriceLabel.textColor = [UIColor blackColor];
    
    summaryShippingCostLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:[HappyGiftAppDelegate fontSizeNormal]];
    summaryShippingCostLabel.textColor = [UIColor blackColor];
    
    summaryTotalPriceLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:[HappyGiftAppDelegate fontSizeNormal]];
    summaryTotalPriceLabel.textColor = UIColorFromRGB(0xd53d3b);
    
    [senderImageView updateUserImageViewWithRecipient:giftOrder.giftRecipient];
    
    HGImageService *imageService = [HGImageService sharedService];
    if (giftOrder.giftCard != nil) {
        cardTitleLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:[HappyGiftAppDelegate fontSizeSmall]];
        cardTitleLabel.textColor = [UIColor blackColor];
        cardTitleLabel.text = [NSString stringWithFormat:@"%@ %@", giftOrder.giftCard.title, giftOrder.giftRecipient.recipientDisplayName];
        cardTitleLabel.hidden = YES;
        
        CGSize cardTitleLabelSize = [cardTitleLabel.text sizeWithFont:cardTitleLabel.font constrainedToSize:CGSizeMake(cardTitleLabel.frame.size.width, cardTitleLabel.frame.size.height)];
        CGRect cardTitleLabelFrame = cardTitleLabel.frame;
        cardTitleLabelFrame.size.height = cardTitleLabelSize.height;
        cardTitleLabel.frame = cardTitleLabelFrame;
        
        cardContentLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:[HappyGiftAppDelegate fontSizeNormal]];
        cardContentLabel.textColor = [UIColor blackColor];
        cardContentLabel.text = giftOrder.giftCard.content;
        
        CGSize cardContentLabelSize = [cardContentLabel.text sizeWithFont:cardContentLabel.font constrainedToSize:CGSizeMake(cardContentLabel.frame.size.width, cardContentLabel.frame.size.height)];
        CGRect cardContentLabelFrame = cardContentLabel.frame;
        cardContentLabelFrame.origin.y = cardTitleLabelFrame.origin.y;
        cardContentLabelFrame.size.height = cardContentLabelSize.height;
        cardContentLabel.frame = cardContentLabelFrame;
        
        cardEnclosureLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:[HappyGiftAppDelegate fontSizeSmall]];
        cardEnclosureLabel.textColor = [UIColor blackColor];
        cardEnclosureLabel.textAlignment = UITextAlignmentRight;
        cardEnclosureLabel.text = [NSString stringWithFormat:@"%@ %@", giftOrder.giftCard.enclosure, giftOrder.giftCard.sender];
        cardEnclosureLabel.hidden = YES;
        
        CGSize cardEnclosureLabelSize = [cardEnclosureLabel.text sizeWithFont:cardEnclosureLabel.font constrainedToSize:CGSizeMake(cardEnclosureLabel.frame.size.width, cardEnclosureLabel.frame.size.height)];
        CGRect cardEnclosureLabelFrame = cardEnclosureLabel.frame;
        cardEnclosureLabelFrame.origin.y = cardContentLabelFrame.origin.y + cardContentLabelFrame.size.height + 5.0;
        cardEnclosureLabelFrame.size.height = cardEnclosureLabelSize.height;
        cardEnclosureLabel.frame = cardEnclosureLabelFrame;
        
        if (giftOrder.giftCard.cover  != nil){
            UIImage *cardImage = [imageService requestImage:giftOrder.giftCard.cover target:self selector:@selector(didImageLoaded:)];
            if (cardImage != nil){
                cardImageView.image = [cardImage imageWithFrame:cardImageView.frame.size color:[HappyGiftAppDelegate imageFrameColor]];
                
                CATransition *animation = [CATransition animation];
                [animation setDelegate:self];
                [animation setType:kCATransitionFade];
                [animation setDuration:0.2];
                [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
                [cardImageView.layer addAnimation:animation forKey:@"updateCardAnimation"];
            }else{
                CGSize defaultImageSize = cardImageView.frame.size;
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
                cardImageView.image = defaultImage;
            }
        }else{
            CGSize defaultImageSize = cardImageView.frame.size;
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
            cardImageView.image = defaultImage;
        }
    } else {
        cardSectionView.hidden = YES;
    }
    
    if (giftOrder.gift.thumb != nil){
        UIImage *coverImage = [imageService requestImage:giftOrder.gift.thumb target:self selector:@selector(didImageLoaded:)];
        if (coverImage != nil){
            coverImageView.image = coverImage;
            
            CATransition *animation = [CATransition animation];
            [animation setDelegate:self];
            [animation setType:kCATransitionFade];
            [animation setDuration:0.2];
            [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
            [coverImageView.layer addAnimation:animation forKey:@"updateCoverAnimation"];
        }else{
            CGSize defaultImageSize = coverImageView.frame.size;
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
    }else{
        CGSize defaultImageSize = coverImageView.frame.size;
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
    
    progressView = [[HGProgressView progressView:self.view.frame] retain];
    [self.view addSubview:progressView];
    progressView.hidden = YES;
    
    giftOrderViewNeeded = NO;
    giftOrderMessageNeeded = NO;
    
    if (giftOrder.orderType == kOrderTypeQuickOrder) {
        if (![giftOrder canUseCredit]) {
            paymentHintLabel.hidden = NO;
            paymentHintLabel.text = [NSString stringWithFormat:@"发送订单后将转到付款页面"];
            CGSize size = [paymentHintLabel.text sizeWithFont:paymentHintLabel.font constrainedToSize:CGSizeMake(paymentHintLabel.frame.size.width, 40)];
            CGRect frame = paymentHintLabel.frame;
            frame.size.height = size.height;
            paymentHintLabel.frame = frame;
        } else {
            paymentHintLabel.hidden = YES;
        }
        summarySectionView.hidden = NO;
        
        summaryGiftPriceLabel.text = [NSString stringWithFormat:@"¥%.02lf", giftOrder.gift.price];
        if (giftOrder.shippingCost >= 0) {
            summaryShippingCostLabel.text = [NSString stringWithFormat:@"¥%.02lf", giftOrder.shippingCost];
            summaryTotalPriceLabel.text = [NSString stringWithFormat:@"¥%.02lf", giftOrder.gift.price + giftOrder.shippingCost];
        } else {
            summaryShippingCostLabel.text = [NSString stringWithFormat:@"¥%.02lf~¥%.02lf", giftOrder.gift.shippingCostMin, giftOrder.gift.shippingCostMax];
            summaryTotalPriceLabel.text = [NSString stringWithFormat:@"¥%.02lf~¥%.02lf",  giftOrder.gift.price + giftOrder.gift.shippingCostMin,  giftOrder.gift.price + giftOrder.gift.shippingCostMax];
        }
        
        if (giftOrder.shippingCost < 0) {
            [progressView startAnimation];
            [HGGiftOrderService sharedService].delegate = self;
            [[HGGiftOrderService sharedService] requestShippingCost:giftOrder];
        }
        HGRecipient* recipient = giftOrder.giftRecipient;
        
        if (giftOrder.gift.type == GIFT_TYPE_COUPON){
            addressTitleLabel.text = @"邮件：";
            addressLabel.text = giftOrder.giftDelivery.emailNotify?recipient.recipientEmail:@"";
            phoneLabel.text = giftOrder.giftDelivery.phoneNotify?recipient.recipientPhone:@"";
        }else{
            addressTitleLabel.text = @"地址：";
            NSString* provinceCity = [HGUtility displayTextForProvince:recipient.recipientProvince andCity:recipient.recipientCity];
            addressLabel.text = [NSString stringWithFormat:@"%@ %@ 邮编：%@", provinceCity, recipient.recipientStreetAddress, recipient.recipientPostCode];
            phoneLabel.text = recipient.recipientPhone;
        }
        
        CGRect tmpFrame = CGRectZero;
        if (addressLabel.text.length > 0){
            CGSize addressLabelSize = [addressLabel.text sizeWithFont:addressLabel.font constrainedToSize:CGSizeMake(addressLabel.frame.size.width, 160.0)];
            tmpFrame = addressLabel.frame;
            tmpFrame.size = addressLabelSize;
            addressLabel.frame = tmpFrame;
            
            addressLabel.hidden = NO;
            addressTitleLabel.hidden = NO;
            
            tmpFrame = phoneTitleLabel.frame;
            tmpFrame.origin.y = addressLabel.frame.origin.y + addressLabel.frame.size.height + 5;
            phoneTitleLabel.frame = tmpFrame;
            
            tmpFrame = phoneLabel.frame;
            tmpFrame.origin.y = addressLabel.frame.origin.y + addressLabel.frame.size.height + 5;
            phoneLabel.frame = tmpFrame;
        }else{
            addressLabel.hidden = YES;
            addressTitleLabel.hidden = YES;
            
            tmpFrame = phoneTitleLabel.frame;
            tmpFrame.origin.y = addressLabel.frame.origin.y + 12.0;
            phoneTitleLabel.frame = tmpFrame;
            
            tmpFrame = phoneLabel.frame;
            tmpFrame.origin.y = addressLabel.frame.origin.y + 12.0;
            phoneLabel.frame = tmpFrame;
        }
        
        if (phoneLabel.text.length > 0){
            phoneLabel.hidden = NO;
            phoneTitleLabel.hidden = NO;
        }else{
            phoneLabel.hidden = YES;
            phoneTitleLabel.hidden = YES;
            
            tmpFrame = addressTitleLabel.frame;
            tmpFrame.origin.y = addressTitleLabel.frame.origin.y + 12.0;
            addressTitleLabel.frame = tmpFrame;
            
            tmpFrame = addressLabel.frame;
            tmpFrame.origin.y = addressLabel.frame.origin.y + 12.0;
            addressLabel.frame = tmpFrame;
        }
        
        addressSectionView.hidden = NO;
        tmpFrame = addressSectionView.frame;
        tmpFrame.origin.y = giftSectionView.frame.origin.y;
        if (phoneLabel.hidden == NO){
            tmpFrame.size.height = phoneLabel.frame.origin.y + phoneLabel.frame.size.height + 5.0;
        }else if (addressLabel.hidden == NO){
            tmpFrame.size.height = addressLabel.frame.origin.y + addressLabel.frame.size.height + 5.0;
        }
        if (tmpFrame.size.height < 56.0){
            tmpFrame.size.height = 56.0;
        }
        addressSectionView.frame = tmpFrame;
        
        tmpFrame = giftSectionView.frame;
        tmpFrame.origin.y = addressSectionView.frame.origin.y + addressSectionView.frame.size.height + 5.0;
        giftSectionView.frame = tmpFrame;
        
        summarySectionView.hidden = NO;
        
        CGRect summarySectionViewFrame = summarySectionView.frame;
        summarySectionViewFrame.origin.y =  giftSectionView.frame.origin.y + giftSectionView.frame.size.height + 5.0;
        summarySectionView.frame = summarySectionViewFrame;
        
        CGRect sendOrderSectionViewFrame = sendOrderSectionView.frame;
        sendOrderSectionViewFrame.origin.y = summarySectionView.frame.origin.y + summarySectionView.frame.size.height + 2;
        sendOrderSectionView.frame = sendOrderSectionViewFrame;
        
        CGSize contentSize = orderDetailScrollView.contentSize;
        contentSize.height = sendOrderSectionViewFrame.origin.y + sendOrderSectionViewFrame.size.height + 5;
        if (paymentHintLabel.hidden == NO) {
            contentSize.height += 15;
        }
        orderDetailScrollView.contentSize = contentSize;
    } else {
        paymentHintLabel.hidden = NO;
        summarySectionView.hidden = YES;
        addressSectionView.hidden = YES;
        
        CGSize contentSize = orderDetailScrollView.contentSize;
        contentSize.height = 460.0;
        orderDetailScrollView.contentSize = contentSize;
    }
}

- (void)viewDidUnload{
    [super viewDidUnload];
    [progressView removeFromSuperview];
    [progressView release];
    progressView = nil;
    [leftBarButtonItem release];
    leftBarButtonItem = nil;
    [rightBarButtonItem release];
    rightBarButtonItem = nil;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    if (giftOrderMessageNeeded == YES){
        giftOrderMessageNeeded = NO;
        [self performMessageNotification];
    }else if (giftOrderViewNeeded == YES){
        [HGTrackingService logEvent:kTrackingEventEnterSentGiftDetail withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"HGOrderViewController", @"from", nil]];
        
        giftOrderViewNeeded = NO;
        
        HGSentGiftDetailViewController* viewController = [[HGSentGiftDetailViewController alloc] initWithGiftOrder:giftOrder andShouldRefetchData:NO];
        [self.navigationController pushViewController:viewController animated:YES];
        [viewController release];
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
    [progressView release];
    [leftBarButtonItem release];
    [orderDetailScrollView release];
    [senderLabel release];
    [senderNameLabel release];
    [cardImageView release];
    [cardTitleLabel release];
    [giftOrder release];
    [senderImageView release];
    [coverImageView release];
    [cardEnclosureLabel release];
    [nameLabel release];
    [priceLabel release];
    [creditLabel release];
    [descriptionLabel release];
    [cardContentLabel release];
    [sendButton release];
    [mailViewController release];
    [messageViewController release];
    
    HGGiftOrderService* giftOrderService = [HGGiftOrderService sharedService];
    if (giftOrderService.delegate == self) {
        giftOrderService.delegate = nil;
    }
	[super dealloc];
}


- (void)handleCancelAction:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)handleDoneAction:(id)sender{
    if ([progressView animating] == NO){
        [progressView startAnimation];
        HGGiftOrderService* giftOrderService = [HGGiftOrderService sharedService];
        giftOrderService.delegate = self;
        [giftOrderService requestPlaceOrder:giftOrder];
    }
}

- (void)performMailNotification{
    if ([MFMailComposeViewController canSendMail]) {
		mailViewController = [[MFMailComposeViewController alloc] init];
        mailViewController.mailComposeDelegate = self;
        mailViewController.navigationBar.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"navigation_background"]];
        mailViewController.modalPresentationStyle = UIModalPresentationFormSheet;
        NSString* acceptUrl = giftOrder.acceptUrl;
        if (!acceptUrl || [@"" isEqualToString:acceptUrl]) {
            acceptUrl = [NSString stringWithFormat:@"http://lesongapp.cn/web/gift/%@", giftOrder.trackCode];
        }
        NSString *message = [NSString stringWithFormat:@"我通过乐送给你送了一份礼物：%@ \n---------------------------------------------- \n关于乐送\n乐送是一款即时创意礼品赠送手机应用。乐送帮助用户随时随地发现亲朋好友的重要时刻，并运用其专利所有的智能推荐技术，根据赠送对象的行为数据即时奉上精心挑选的礼品。\n还等什么快去看看你的礼物吧\n ----------------------------------------------", acceptUrl];
        [mailViewController setMessageBody:message isHTML:NO];
        [mailViewController setSubject:@"乐送礼物"];
        [mailViewController setToRecipients:[NSArray arrayWithObject:giftOrder.giftDelivery.email]];
        [self presentModalViewController:mailViewController animated:YES]; 
        [HGTrackingService logPageView];
	} else {
        HappyGiftAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
        [appDelegate sendNotification:@"您的设备不支持发送邮件"];
	}
}

- (void)performMessageNotification{
    if ([MFMessageComposeViewController canSendText]) {   
        messageViewController = [[MFMessageComposeViewController alloc] init];   
        messageViewController.messageComposeDelegate = self; 
        messageViewController.navigationBar.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"navigation_background"]];
        [messageViewController setRecipients:[NSArray arrayWithObject:giftOrder.giftDelivery.phone]];
        NSString* acceptUrl = giftOrder.acceptUrl;
        if (!acceptUrl || [@"" isEqualToString:acceptUrl]) {
            acceptUrl = [NSString stringWithFormat:@"http://lesongapp.cn/web/gift/%@", giftOrder.trackCode];
        }
        [messageViewController setBody:[NSString stringWithFormat:@"我通过乐送给你送了礼物,快打开看看吧：%@", acceptUrl]]; 
        [self presentModalViewController:messageViewController animated:YES]; 
        [HGTrackingService logPageView];
    }else {   
        HappyGiftAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
        [appDelegate sendNotification:@"您的设备不支持发送短信"];  
    }  
}

#pragma mark  HGImagesService selector
- (void)didImageLoaded:(HGImageData*)image{
    if ([image.url isEqualToString:giftOrder.gift.thumb]){
        coverImageView.image = image.image;
        
        CATransition *animation = [CATransition animation];
        [animation setDelegate:self];
        [animation setType:kCATransitionFade];
        [animation setDuration:0.2];
        [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        [coverImageView.layer addAnimation:animation forKey:@"updateCoverAnimation"];
    }else if ([image.url isEqualToString:giftOrder.giftCard.cover]){
        cardImageView.image = image.image;
        
        CATransition *animation = [CATransition animation];
        [animation setDelegate:self];
        [animation setType:kCATransitionFade];
        [animation setDuration:0.2];
        [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        [coverImageView.layer addAnimation:animation forKey:@"updateCardAnimation"];
    }
}

#pragma mark HGGiftOrderServiceDelegate
- (void)giftOrderService:(HGGiftOrderService *)theGiftOrderService didRequestPlaceGiftOrderSucceed:(HGGiftOrder*)theGiftOrder{
    [progressView stopAnimation];
    [HGRecipientService sharedService].selectedRecipient = nil;
    
    if (giftOrder != theGiftOrder){
        [giftOrder release];
        giftOrder = [theGiftOrder retain];
    }
    
    if (giftOrder.giftRecipient.recipientNetworkId == NETWORK_SNS_WEIBO ||
        giftOrder.giftRecipient.recipientNetworkId == NETWORK_SNS_RENREN){
        [HGTrackingService logEvent:kTrackingEventSendGiftOrder withParameters:[NSDictionary dictionaryWithObjectsAndKeys:theGiftOrder.identifier, @"order", giftOrder.gift.identifier, @"gift", giftOrder.giftRecipient.recipientProfileId, @"recipient", nil]];
    }else{
        [HGTrackingService logEvent:kTrackingEventSendGiftOrder withParameters:[NSDictionary dictionaryWithObjectsAndKeys:theGiftOrder.identifier, @"order", giftOrder.gift.identifier, @"gift", nil]];
    }
    
    if (giftOrder.orderType == kOrderTypeQuickOrder) {
        if (giftOrder.paymentUrl && ![@"" isEqualToString:giftOrder.paymentUrl] &&
            ![giftOrder canUseCredit]) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:giftOrder.paymentUrl]];
            [HGTrackingService logEvent:kTrackingEventPayGiftOrder withParameters:[NSDictionary dictionaryWithObjectsAndKeys:giftOrder.identifier, @"order", @"NO", @"useCredit", nil]];
        }
        
        [HGTrackingService logEvent:kTrackingEventEnterSentGiftDetail withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"HGOrderViewController", @"from", nil]];
        
        HGSentGiftDetailViewController* viewController = [[HGSentGiftDetailViewController alloc] initWithGiftOrder:giftOrder andShouldRefetchData:NO];
        [self.navigationController pushViewController:viewController animated:YES];
        [viewController release];
    } else {
        if (giftOrder.orderNotifyDate == nil){
            if (giftOrder.giftDelivery.emailNotify && [MFMailComposeViewController canSendMail]){
                [self performMailNotification];
            }else if (giftOrder.giftDelivery.phoneNotify && [MFMessageComposeViewController canSendText]){
                [self performMessageNotification];
            }else{
                [HGTrackingService logEvent:kTrackingEventEnterSentGiftDetail withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"HGOrderViewController", @"from", nil]];
                
                HGSentGiftDetailViewController* viewController = [[HGSentGiftDetailViewController alloc] initWithGiftOrder:giftOrder andShouldRefetchData:NO];
                [self.navigationController pushViewController:viewController animated:YES];
                [viewController release];
            }
        }else{
            [HGTrackingService logEvent:kTrackingEventEnterSentGiftDetail withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"HGOrderViewController", @"from", nil]];
            
            HGSentGiftDetailViewController* viewController = [[HGSentGiftDetailViewController alloc] initWithGiftOrder:giftOrder andShouldRefetchData:NO];
            [self.navigationController pushViewController:viewController animated:YES];
            [viewController release];
        }
    }
}

- (void)giftOrderService:(HGGiftOrderService *)theGiftOrderService didRequestPlaceGiftOrderFail:(NSString*)error{
    [progressView stopAnimation];
    
    HappyGiftAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    [appDelegate sendNotification:@"发送礼物清单失败，请检查网络设置"];
}

- (void)giftOrderService:(HGGiftOrderService *)giftOrderService didRequestShippingCostSucceed:(float)shippingCost {
    [progressView stopAnimation];
    giftOrder.shippingCost = shippingCost;
    
    summaryGiftPriceLabel.text = [NSString stringWithFormat:@"¥%.02lf", giftOrder.gift.price];
    if (giftOrder.shippingCost >= 0) {
        summaryShippingCostLabel.text = [NSString stringWithFormat:@"¥%.02lf", giftOrder.shippingCost];
        summaryTotalPriceLabel.text = [NSString stringWithFormat:@"¥%.02lf", giftOrder.gift.price + giftOrder.shippingCost];
    } else {
        summaryShippingCostLabel.text = [NSString stringWithFormat:@"¥%.02lf~¥%.02lf", giftOrder.gift.shippingCostMin, giftOrder.gift.shippingCostMax];
        summaryTotalPriceLabel.text = [NSString stringWithFormat:@"¥%.02lf~¥%.02lf",  giftOrder.gift.price + giftOrder.gift.shippingCostMin,  giftOrder.gift.price + giftOrder.gift.shippingCostMax];
    }
}

- (void)giftOrderService:(HGGiftOrderService *)giftOrderService didRequestShippingCostFail:(NSString*) error {
    [progressView stopAnimation];
    HappyGiftAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    [appDelegate sendNotification:@"获取运费信息失败，请检查网络设置"];
}

#pragma mark - MFMailComposeViewControllerDelegate
- (void) mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    if (result == MFMailComposeResultSent) {
        giftOrder.orderNotifiedFromClient = YES;
        giftOrder.status = GIFT_ORDER_STATUS_NOTIFIED;
        HappyGiftAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
        [appDelegate sendNotification:[NSString stringWithFormat:@"成功发送通知邮件给%@", giftOrder.giftRecipient.recipientDisplayName]];
    }
    [mailViewController dismissModalViewControllerAnimated:YES];
    [mailViewController release];
    mailViewController = nil;
    if (giftOrder.giftDelivery.phoneNotify && [MFMessageComposeViewController canSendText]){
        giftOrderMessageNeeded = YES;
    }else{
        giftOrderViewNeeded = YES;
    }
} 

#pragma mark - MFMessageComposeViewControllerDelegate
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {  
    if (result == MFMailComposeResultSent) {
        giftOrder.orderNotifiedFromClient = YES;
        giftOrder.status = GIFT_ORDER_STATUS_NOTIFIED;
        HappyGiftAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
        [appDelegate sendNotification:[NSString stringWithFormat:@"成功发送通知短信给%@", giftOrder.giftRecipient.recipientDisplayName]];
    }
    [messageViewController dismissModalViewControllerAnimated:YES];
    [messageViewController release];
    messageViewController = nil;
    giftOrderViewNeeded = YES;
}
@end

