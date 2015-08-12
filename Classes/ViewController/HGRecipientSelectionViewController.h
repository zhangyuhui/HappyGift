//
//  HGRecipientSelectionViewController.h
//  HappyGift
//
//  Created by Zhang Yuhui on 2/11/11.
//  Copyright 2011 Ztelic Inc Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HGRecipient.h"
#import "HGRecipientService.h"
@class HGProgressView;
@protocol HGRecipientSelectionViewControllerDelegate;

#define kRecipientSelectionTypeNormal 0
#define kRecipientSelectionTypeInviteUser 1
#define kRecipientSelectionTypeSNSUsers 2

@interface HGRecipientSelectionViewController : UIViewController <HGRecipientServiceDelegate> {
    IBOutlet UINavigationBar*  navigationBar;
    IBOutlet UITextField* searchTextField;
    IBOutlet UITableView* tableView;
    IBOutlet UIView* tableHeaderView;
    IBOutlet UILabel* tableHeaderLabel;
    
    int recipientSelectionType;
    
    CGFloat dragOffsetY;

    UIBarButtonItem* leftBarButtonItem;
    HGProgressView*  progressView;
    
    NSArray *recipientDataItems;
    id<HGRecipientSelectionViewControllerDelegate> delegate;
    
    NSTimer* searchTimer;
}
- (id)initWithRecipientSelectionType:(int)type;
@property(nonatomic,retain) NSArray *recipientDataItems;
@property(nonatomic, assign) id<HGRecipientSelectionViewControllerDelegate> delegate;

- (void)didSearchKeywordChanged;
-(IBAction)backgroundTap:(id)sender;

@end

@protocol HGRecipientSelectionViewControllerDelegate <NSObject>

- (void)didRecipientSelected: (HGRecipient*)recipient;

@end