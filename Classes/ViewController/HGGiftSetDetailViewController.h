//
//  HGGiftSetDetailViewController.h
//  HappyGift
//
//  Created by Zhang Yuhui on 2/11/11.
//  Copyright 2011 Ztelic Inc Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HGProgressView;
@class HGGiftSet;

@interface HGGiftSetDetailViewController : UIViewController{
    IBOutlet UIScrollView*  contentView;
    IBOutlet UINavigationBar*  navigationBar;
    IBOutlet UIButton* recipientButton;
    IBOutlet UILabel* recipientLabel;
    IBOutlet UIView*   headView;
    IBOutlet UILabel*  titleLabel;
    IBOutlet UILabel*  descriptionLabel;
    
    UIBarButtonItem* leftBarButtonItem;
    HGProgressView*  progressView;
    
    HGGiftSet* giftSet;
    NSMutableArray* contentSubViews;
}

- (id)initWithGiftSet:(HGGiftSet*)giftSet;
@end
