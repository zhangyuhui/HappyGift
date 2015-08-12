//
//  HGOrderViewController.h
//  HappyGift
//
//  Created by Zhang Yuhui on 2/11/11.
//  Copyright 2011 Ztelic Inc Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HGProgressView;
@class HGGiftOrder;
@class MFMailComposeViewController;
@class MFMessageComposeViewController;
@class HGUserImageView;

@interface HGOrderViewController : UIViewController{
    IBOutlet UINavigationBar*  navigationBar;
    IBOutlet UIScrollView*     orderDetailScrollView;
    IBOutlet UILabel*          senderLabel;
    IBOutlet HGUserImageView*  senderImageView;
    IBOutlet UILabel*          senderNameLabel; 
    IBOutlet UIImageView*      coverImageView;
    IBOutlet UIImageView*      cardImageView;
    IBOutlet UILabel*          nameLabel;
    IBOutlet UILabel*          descriptionLabel;
    IBOutlet UILabel*          priceLabel;
    IBOutlet UILabel*          creditLabel;
    IBOutlet UILabel*          cardTitleLabel;
    IBOutlet UILabel*          cardContentLabel;
    IBOutlet UILabel*          cardEnclosureLabel;
    IBOutlet UIButton*         sendButton;
    IBOutlet UILabel*          paymentHintLabel;
    
    IBOutlet UILabel*          summaryGiftPriceLabel;
    IBOutlet UILabel*          summaryShippingCostLabel;
    IBOutlet UILabel*          summaryTotalPriceLabel;
    
    IBOutlet UILabel*          summaryShippingCostTitleLabel;
    IBOutlet UILabel*          summaryTotalPriceTitleLabel;
    
    IBOutlet UIView*           giftSectionView;
    IBOutlet UIView*           cardSectionView;
    IBOutlet UIView*           sendOrderSectionView;
    IBOutlet UIView*           summarySectionView;
    
    IBOutlet UIView*           addressSectionView;
    IBOutlet UILabel*          addressTitleLabel;
    IBOutlet UILabel*          phoneTitleLabel;
    IBOutlet UILabel*          addressLabel;
    IBOutlet UILabel*          phoneLabel;
    
    UIBarButtonItem* leftBarButtonItem;
    UIBarButtonItem* rightBarButtonItem;
    HGProgressView*  progressView;
    HGGiftOrder* giftOrder;
    
    BOOL giftOrderMessageNeeded;
    BOOL giftOrderViewNeeded;
    
    MFMailComposeViewController *mailViewController; 
    MFMessageComposeViewController *messageViewController;
}
- (id)initWithGiftOrder:(HGGiftOrder*)giftOrder;
@end