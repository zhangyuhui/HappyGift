//
//  HGSentGiftDetailViewController.h
//  HappyGift
//
//  Created by Zhang Yuhui on 2/11/11.
//  Copyright 2011 Ztelic Inc Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HGProgressView;
@class HGGiftOrder;
@class HGUserImageView;

@interface HGSentGiftDetailViewController : UIViewController{
    IBOutlet UINavigationBar*  navigationBar;
    IBOutlet UIScrollView*     contentScrollView;
    IBOutlet UIView*           userInfoView;
    IBOutlet UILabel*          userNameLabel;
    IBOutlet UILabel*          userTitleLabel;
    IBOutlet HGUserImageView*      userImageView;
    IBOutlet UIButton*         shareButton;
    
    IBOutlet UIView*           statusView;
    IBOutlet UILabel*          statusTitleLabel;
    IBOutlet UIImageView*      statusNotifiedView;
    IBOutlet UIImageView*      statusReadView;
    IBOutlet UIImageView*      statusAcceptedView;
    IBOutlet UIImageView*      statusShippedView;
    IBOutlet UIImageView*      statusDeliveredView;
    IBOutlet UILabel*          statusNotifiedLabel;
    IBOutlet UILabel*          statusReadLabel;
    IBOutlet UILabel*          statusAcceptedLabel;
    IBOutlet UILabel*          statusShippedLabel;
    IBOutlet UILabel*          statusDeliveredLabel;
    
    IBOutlet UILabel*          statusPaidLabel;
    IBOutlet UIImageView*      statusPaidView;
    
    IBOutlet UILabel*          orderTrackCodeTitleLabel;
    
    IBOutlet UIView*           giftView;
    IBOutlet UILabel*          giftTitleLabel;
    IBOutlet UIImageView*      giftImageView;
    IBOutlet UILabel*          giftNameLabel;
    IBOutlet UILabel*          giftManufactureLabel;
    IBOutlet UIImageView*      giftPriceImageView;
    IBOutlet UILabel*          giftPriceLabel;
    
    IBOutlet UIView*           cardView;
    IBOutlet UILabel*          cardTitleLabel;
    IBOutlet UIImageView*      cardImageView;
    IBOutlet UILabel*          cardContentLabel;
    
    IBOutlet UIView*           thankView;
    IBOutlet UILabel*          thankTitleLabel;
    IBOutlet HGUserImageView*  thankImageView;
    IBOutlet UILabel*          thankContentLabel;
    
    IBOutlet UIView*           summaryPriceView;
    
    IBOutlet UIView*           summaryView;
    IBOutlet UILabel*          summaryTitleLabel;
    IBOutlet UILabel*          summaryValueLabel;
    IBOutlet UIView*           summaryCreditView;
    IBOutlet UIImageView*      summaryCreditImageView;
    IBOutlet UIButton*         summaryCreditButton;
    IBOutlet UILabel*          summaryCreditLabel;
    IBOutlet UILabel*          summaryPriceTitleLabel;
    IBOutlet UILabel*          summaryDeliveryTitleLabel;
    IBOutlet UILabel*          summaryPriceValueLabel;
    IBOutlet UILabel*          summaryDeliveryValueLabel;
    IBOutlet UIButton*         payButton;
    IBOutlet UILabel*          paidLabel;
    IBOutlet UILabel*          immediatelyPayExplainationLabel;
    IBOutlet UILabel*          laterPayHint;
    IBOutlet UIButton*         cancelButton;
    IBOutlet UIImageView*      cancelButtonTopSeparator;

    
    UILabel* titleLabel;
    
    HGProgressView*  progressView;
    
    HGGiftOrder* giftOrder;
    BOOL shouldRefetchData;
}

- (id)initWithGiftOrder:(HGGiftOrder*)theGiftOrder andShouldRefetchData:(BOOL)shouldRefetchData;
@end
