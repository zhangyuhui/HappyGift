//
//  HGFriendRecommandationListViewController.m
//  HappyGift
//
//  Created by Yujian Weng on 12-6-11.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//

#import "HGFriendRecommandationListViewController.h"
#import "HappyGiftAppDelegate.h"
#import "HGConstants.h"
#import "HGProgressView.h"
#import "HGOccasionGiftCollection.h"
#import "HGFriendRecommandationListViewCellView.h"
#import "HGGiftCollectionService.h"
#import "UIBarButtonItem+Addition.h"
#import <QuartzCore/QuartzCore.h>
#import "HGGiftDetailViewController.h"
#import "HGRecipientService.h"
#import "HGTrackingService.h"
#import "HGGiftDetailViewController.h"
#import "HGFriendRecommandation.h"
#import "HGGift.h"
#import "HGDragToUpdateTableView.h"
#import "HGLogging.h"
#import "HGFriendRecommandationService.h"
#import "HGDefines.h"

@interface HGFriendRecommandationListViewController()<UIScrollViewDelegate, HGProgressViewDelegate, HGFriendRecommandationServiceDelegate>
  
@end

#define kMoreFriendRecommandationCount 12

@implementation HGFriendRecommandationListViewController

- (id)initWithFriendRecommandations:(NSArray *)theFriendRecommandations {
    self = [super initWithNibName:@"HGFriendRecommandationListViewController" bundle:nil];
    if (self){
        friendRecommandations = [theFriendRecommandations retain];
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    self.view.backgroundColor = [HappyGiftAppDelegate genericBackgroundColor];
    
    leftBarButtonItem = [[UIBarButtonItem alloc ] initNavigationBackImageBarButtonItem:@"navigation_back" target:self action:@selector(handleBackAction:)];
    navigationBar.topItem.leftBarButtonItem = leftBarButtonItem; 
    navigationBar.topItem.rightBarButtonItem = nil;
    
    CGRect titleViewFrame = CGRectMake(0, 0, 180, 44);
    UIView* titleView = [[UIView alloc] initWithFrame:titleViewFrame];
    CGRect logoImageViewFrame = CGRectMake((titleViewFrame.size.width - 44.0)/2.0, 5.0, 44.0, 35.0);
    UIImageView* logoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"navigation_logo"]];
    logoImageView.frame = logoImageViewFrame;
    [titleView addSubview:logoImageView];
    [logoImageView release];
    
	navigationBar.topItem.titleView = titleView;
    [titleView release];
    
    occasionNameLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeNormal]];
    occasionNameLabel.textColor = UIColorFromRGB(0xde5a1b);
    occasionNameLabel.text = @"猜TA喜欢";

    progressView = [[HGProgressView progressView:self.view.frame] retain];
    [self.view addSubview:progressView];
    progressView.hidden = YES;
    
    tableView.dragToUpdateDelegate = self;
    tableView.bottomDragToUpdateVisbile = YES;
    tableView.topDragToUpdateVisbile = NO;
    tableView.topDragToUpdateRunning = NO;
    tableView.bottomDragToUpdateRunning = NO;
    tableView.topDragToUpdateDate = nil;
    tableView.bottomDragToUpdateDate = nil;
    [tableView setShowBottomUpdateDateLabel:NO];
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

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void)dealloc {	
    [tableView release];
    [progressView release];
    [leftBarButtonItem release];
    [occasionNameLabel release];
    [occasionButton release];
    [friendRecommandations release];
    
    HGFriendRecommandationService* service = [HGFriendRecommandationService sharedService];
    if (service.delegate == self) {
        service.delegate = nil;
    }
    
    [super dealloc];
}

- (void)handleBackAction:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark Table view data source

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [friendRecommandations count];
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"HGFriendRecommandationListViewCellView";
    UITableViewCell *cell = [theTableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [HGFriendRecommandationListViewCellView friendRecommandationListViewCellView];
    }
    HGFriendRecommandationListViewCellView* friendRecommandationListViewCellView = (HGFriendRecommandationListViewCellView*)cell;
    HGFriendRecommandation* friendRecommandation = [friendRecommandations objectAtIndex:indexPath.row];
    friendRecommandationListViewCellView.friendRecommandation = friendRecommandation;
    return cell;
}

#pragma mark Table view delegate

- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [theTableView deselectRowAtIndexPath: indexPath animated: YES];
    
    HGFriendRecommandation* friendRecommandation = [friendRecommandations objectAtIndex:indexPath.row];
    
    HGGift* theGift = friendRecommandation.gift;
    [HGRecipientService sharedService].selectedRecipient = friendRecommandation.recipient;
    
    [HGTrackingService logEvent:kTrackingEventEnterGiftDetail withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"HGFriendRecommandationListViewController", @"from", theGift.identifier, @"productId", nil]];
    
    HGGiftDetailViewController* viewContoller = [[HGGiftDetailViewController alloc] initWithGift:theGift];
    [self.navigationController pushViewController:viewContoller animated:YES];
    [viewContoller release];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [tableView handleScrollViewDidScroll:scrollView];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [tableView handleScrollViewWillBeginDragging:scrollView];
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView{
    [tableView handleScrollViewWillBeginDecelerating:scrollView];
}

- (void)dragToUpdateTableView:(HGDragToUpdateTableView *)dragToUpdateTableView didRequestTopUpdate:(HGDragToUpdateView *)topDragToUpdateView {
    HGDebug(@"didRequestTopUpdate");
}

- (void)dragToUpdateTableView:(HGDragToUpdateTableView *)dragToUpdateTableView didRequestBottomUpdate:(HGDragToUpdateView *)bottomDragToUpdateView {
    HGDebug(@"bottomDragToUpdateView");
    HGFriendRecommandationService* service = [HGFriendRecommandationService sharedService];
    service.delegate = self;
    [service requestMoreFriendRecommandation:kMoreFriendRecommandationCount];
}

#pragma mark - HGFriendRecommandationServiceDelegate
- (void)friendRecommandationService:(HGFriendRecommandationService *)friendRecommandationService didRequestFriendRecommandationSucceed:(NSArray*)theRecommandations {
    
    [tableView reloadData];
    tableView.bottomDragToUpdateRunning = NO;
    if ([theRecommandations count] < kMoreFriendRecommandationCount) {
        tableView.bottomDragToUpdateVisbile = NO;
    }
    
    friendRecommandationService.delegate = nil;
}

- (void)friendRecommandationService:(HGFriendRecommandationService *)friendRecommandationService didRequestFriendRecommandationFail:(NSString*)error {

    friendRecommandationService.delegate = nil;
}

@end

