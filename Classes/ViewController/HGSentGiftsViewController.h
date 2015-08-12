//
//  HGRecipientSelectionViewCellView.m
//  HappyGift
//
//  Created by Yujian Weng on 12-5-22.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HGRecipient.h"
#import "HGGiftOrderService.h"
@class HGProgressView;

@interface HGSentGiftsViewController : UIViewController {
    IBOutlet UINavigationBar*  navigationBar;
    IBOutlet UITableView* tableView;
    IBOutlet UILabel* emptyView;
    
    UIBarButtonItem* leftBarButtonItem;
    HGProgressView*  progressView;
    
    NSArray* giftsNeedPaid;
    NSArray* giftsHistory;
    
    IBOutlet UIButton* needPaidButton;
    IBOutlet UIButton* giftHistoryButton;
}

@end;