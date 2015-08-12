//
//  HGRecipientSelectionViewCellView.m
//  HappyGift
//
//  Created by Yujian Weng on 12-5-22.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//

#import "HGSentGiftsViewController.h"
#import "HappyGiftAppDelegate.h"
#import "HGConstants.h"
#import "HGProgressView.h"
#import "UIBarButtonItem+Addition.h"
#import <QuartzCore/QuartzCore.h>
#import "HGGiftOrderService.h"
#import "HGSentGiftsViewCellView.h"
#import "NSString+Addition.h"
#import "HGDefines.h"
#import "HGGiftOrder.h"
#import "HGTrackingService.h"
#import "HGSentGiftDetailViewController.h"

@implementation HGSentGiftsViewController


- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.view.backgroundColor = [HappyGiftAppDelegate genericBackgroundColor];
    
    leftBarButtonItem = [[UIBarButtonItem alloc ] initNavigationBackImageBarButtonItem:@"navigation_back" target:self action:@selector(handleCancelAction:)];
    
    navigationBar.topItem.leftBarButtonItem = leftBarButtonItem; 
    navigationBar.topItem.rightBarButtonItem = nil;
 
    progressView = [[HGProgressView progressView:self.view.frame] retain];
    [self.view addSubview:progressView];
    progressView.hidden = YES;
    
    needPaidButton.selected = YES;
    
    CGRect titleViewFrame = CGRectMake(20, 0, 180, 44);
    UIView* titleView = [[UIView alloc] initWithFrame:titleViewFrame];
    
    CGRect titleLabelFrame = CGRectMake(0, 0, 180, 40);
	UILabel *titleLabel = [[UILabel alloc] initWithFrame:titleLabelFrame];
	titleLabel.backgroundColor = [UIColor clearColor];
	titleLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:[HappyGiftAppDelegate naviagtionTitleFontSize]];
    titleLabel.minimumFontSize = 20.0;
    titleLabel.adjustsFontSizeToFitWidth = YES;
	titleLabel.textAlignment = UITextAlignmentCenter;
	titleLabel.textColor = [UIColor whiteColor];
	titleLabel.text = @"已送出的礼物";
    [titleView addSubview:titleLabel];
    [titleLabel release];
    
	navigationBar.topItem.titleView = titleView;
    [titleView release];
    
    giftsNeedPaid = [[HGGiftOrderService sharedService] giftsNeedPaid];
    [giftsNeedPaid retain];
    
    giftsHistory = [[HGGiftOrderService sharedService] giftsHistory];
    [giftsHistory retain];
    
    if ([giftsNeedPaid count] == 0) {
        tableView.hidden = YES;
        emptyView.hidden = NO;
    }
    
    [giftHistoryButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [giftHistoryButton setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
    [giftHistoryButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    giftHistoryButton.titleLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:[HappyGiftAppDelegate fontSizeNormal]];
    
    [giftHistoryButton addTarget:self action:@selector(handleGiftHistoryButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    
    [needPaidButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [needPaidButton setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
    [needPaidButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    needPaidButton.titleLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:[HappyGiftAppDelegate fontSizeNormal]];
    [needPaidButton addTarget:self action:@selector(handleNeedPaidButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleMyGiftsUpdated:) name:kHGNotificationMyGiftsUpdated object:nil];
}

- (void)viewDidUnload{
    [super viewDidUnload];
    
    [progressView removeFromSuperview];
    [progressView release];
    progressView = nil;
    
    [leftBarButtonItem release];
    leftBarButtonItem = nil;
    
    if (giftsNeedPaid != nil){
        [giftsNeedPaid release];
        giftsNeedPaid = nil;
    }
    if (giftsHistory != nil){
        [giftsHistory release];
        giftsHistory = nil;
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kHGNotificationMyGiftsUpdated object:nil];
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
    if (progressView != nil){
        [progressView release];
        progressView = nil;
    }
    if (leftBarButtonItem != nil){
        [leftBarButtonItem release];
        leftBarButtonItem = nil;
    }
    if (giftsNeedPaid != nil){
        [giftsNeedPaid release];
        giftsNeedPaid = nil;
    }
    if (giftsHistory != nil){
        [giftsHistory release];
        giftsHistory = nil;
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kHGNotificationMyGiftsUpdated object:nil]; 
    
	[super dealloc];
}

- (void)handleCancelAction:(id)sender{
    HappyGiftAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    if (appDelegate.navigationController != self.navigationController){
        [self dismissModalViewControllerAnimated:YES];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)handleMyGiftsUpdated:(NSNotification *)notification{
    if (giftsNeedPaid != nil){
        [giftsNeedPaid release];
        giftsNeedPaid = nil;
    }
    giftsNeedPaid = [[HGGiftOrderService sharedService] giftsNeedPaid];
    [giftsNeedPaid retain];
    
    if (giftsHistory != nil){
        [giftsHistory release];
        giftsHistory = nil;
    }
    giftsHistory = [[HGGiftOrderService sharedService] giftsHistory];
    [giftsHistory retain];
    
    [tableView reloadData];
    if ((needPaidButton.selected && [giftsNeedPaid count] == 0) ||
        (giftHistoryButton.selected && [giftsHistory count] == 0)) {
        tableView.hidden = YES;
        emptyView.hidden = NO;
    } else {
        tableView.hidden = NO;
        emptyView.hidden = YES;
    }
}

-(void) handleNeedPaidButtonTouchUpInside:(id)sender {
    if (!needPaidButton.selected) {
        needPaidButton.selected = YES;
        giftHistoryButton.selected = NO;
        [self updateTableViewUI];
    }
}

-(void) handleGiftHistoryButtonTouchUpInside:(id)sender {
    if (!giftHistoryButton.selected) {
        giftHistoryButton.selected = YES;
        needPaidButton.selected = NO;
        [self updateTableViewUI];
    }
}

-(void) updateTableViewUI {
    [UIView animateWithDuration:0.3 
                          delay:0.0 
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         tableView.alpha = 0.0;
                         emptyView.alpha = 0.0;
                     } 
                     completion:^(BOOL finished) {
                         [tableView reloadData];
                         
                         if ((needPaidButton.selected && [giftsNeedPaid count] == 0) ||
                             (giftHistoryButton.selected && [giftsHistory count] == 0)) {
                             tableView.hidden = YES;
                             emptyView.hidden = NO;
                         } else {
                             tableView.hidden = NO;
                             emptyView.hidden = YES;
                         }
                         
                         [UIView animateWithDuration:0.3 
                                               delay:0.0 
                                             options:UIViewAnimationOptionCurveEaseInOut
                                          animations:^{
                                              tableView.alpha = 1.0;
                                              emptyView.alpha = 1.0;
                                          } 
                                          completion:^(BOOL finished) {
                                              
                                          }];
                     }];
}

#pragma mark Table view delegate

- (UIImage*) formatOrderStatusImage:(HGGiftOrder *)order {
    if (order.status == GIFT_ORDER_STATUS_NOTIFIED) {
        return [UIImage imageNamed:@"sent_gift_detail_notified_selected"];
    } else if (order.status == GIFT_ORDER_STATUS_READ) {
        return [UIImage imageNamed:@"sent_gift_detail_read_selected"];
    } else if (order.status == GIFT_ORDER_STATUS_ACCEPTED) {
        return [UIImage imageNamed:@"sent_gift_detail_accepted_selected"];
    } else if (order.status == GIFT_ORDER_STATUS_SHIPPED) {
        return [UIImage imageNamed:@"sent_gift_detail_shipped_selected"];
    } else if (order.status == GIFT_ORDER_STATUS_DELIVERED) {
        return [UIImage imageNamed:@"sent_gift_detail_delivered_selected"];
    } else if (order.status == GIFT_ORDER_STATUS_CANCELED) {
        return [UIImage imageNamed:@"sent_gift_detail_canceled_selected"];
    } else {
        return [UIImage imageNamed:@"sent_gift_detail_new_selected"];
    }
}

- (HGGiftOrder*) orderInSection: (NSUInteger)section andRow: (NSUInteger) row {
    HGGiftOrder* order;
    
    if (needPaidButton.selected) {
        order = (HGGiftOrder*)[giftsNeedPaid objectAtIndex:row];
    } else {
        order = (HGGiftOrder*)[giftsHistory objectAtIndex:row];
    }

    return order;
}

- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [theTableView deselectRowAtIndexPath: indexPath animated: YES];
    
    [HGTrackingService logEvent:kTrackingEventEnterSentGiftDetail withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"HGSentGiftsViewController", @"from", nil]];
    
    HGGiftOrder* order = [self orderInSection:indexPath.section andRow:indexPath.row];
    HGSentGiftDetailViewController* viewController = [[HGSentGiftDetailViewController alloc] initWithGiftOrder:order andShouldRefetchData:NO];
    [self.navigationController pushViewController:viewController animated:YES];
    [viewController release];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (needPaidButton.selected) {
        return [giftsNeedPaid count];
    } else {
        return [giftsHistory count];
    }
}

-(UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *viewIdentifier=@"HGSentGiftsViewCellView";
    HGSentGiftsViewCellView *cell=[theTableView dequeueReusableCellWithIdentifier:viewIdentifier];
    if (cell == nil) {
        cell = [HGSentGiftsViewCellView sentGiftCellView];
    }
    
    HGGiftOrder* order = [self orderInSection:indexPath.section andRow:indexPath.row];
    
    cell.recipientNameLabelView.text = order.giftRecipient.recipientDisplayName;
     
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date = [formatter dateFromString:order.orderCreatedDate];
    [formatter setDateFormat:@"创建于：yyyy年M月d日"];
    cell.orderCreatedDateLabelView.text = [formatter stringFromDate:date];    
    [formatter release];
    
    cell.statusLabelView.text = [HGGiftOrderService formatOrderStatusText:order];
    cell.statusImageView.image = [self formatOrderStatusImage:order];
    [cell updateUserImageViewWithRecipient: order.giftRecipient];
    
    return cell;
}

#pragma mark HGGiftOrderServiceDelegate

- (void) didUploadPhoneContactsSucceed {
    [progressView stopAnimation];
}

- (void) didUploadPhoneContactsFail:(NSString*)error {
    [progressView stopAnimation];
}

@end

