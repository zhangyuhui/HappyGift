//
//  HGGiftDetailViewController.h
//  HappyGift
//
//  Created by Zhang Yuhui on 2/11/11.
//  Copyright 2011 Ztelic Inc Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HGProgressView;
@class HGGift;
@class HGPageControl;
@class HGGiftOrder;
@class HGEraseLineLabel;

@interface HGGiftDetailViewController : UIViewController{
    IBOutlet UIScrollView*  contentView;
    IBOutlet UINavigationBar*  navigationBar;
    IBOutlet UIButton* recipientButton;
    IBOutlet UILabel*  recipientLabel;
    IBOutlet UIView*      coverView;
    IBOutlet UIImageView* coverHeaderImageView;
    IBOutlet UIImageView* coverBackgroundImageView;
    IBOutlet UIScrollView* coverImagesScrollView;
    IBOutlet UILabel*     coverTitleLabel;
    IBOutlet UIImageView* coverPriceImageView;
    IBOutlet UILabel*     coverPriceLabel;
    IBOutlet HGEraseLineLabel*     coverBasePriceLabel;
    IBOutlet UILabel*     coverManufacturerLabel;
    IBOutlet HGPageControl* coverImagesPageControl;
    IBOutlet UIImageView* freeShippingCostImageView;
    IBOutlet UIView*      socialView;
    IBOutlet UILabel*     creditLabel;
    IBOutlet UIButton*    favoriteButton;
    IBOutlet UIButton*    shareButton;
    IBOutlet UIView*      detailView;
    IBOutlet UIButton*    addButton;
    IBOutlet UIView*      addButtonBackground;
    
    UIBarButtonItem* leftBarButtonItem;
    HGProgressView*  progressView;
    
    HGGiftOrder* giftOrder;
    NSMutableArray* contentSubViews;
    NSMutableDictionary* coverImagesLoadingPool;
    NSMutableDictionary* coverImagesPendingPool;
    BOOL giftStarted;
}

- (id)initWithGift:(HGGift*)gift;
@end
