//
// HGFriendEmotionListViewController.m
//  HappyGift
//
//  Created by Yujian Weng on 12-7-10.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//

#import "HGFriendEmotionListViewController.h"
#import "HappyGiftAppDelegate.h"
#import "HGConstants.h"
#import "HGProgressView.h"
#import "HGAstroTrendListViewCellView.h"
#import "UIBarButtonItem+Addition.h"
#import <QuartzCore/QuartzCore.h>
#import "HGRecipientService.h"
#import "HGTrackingService.h"
#import "HGFriendEmotion.h"
#import "HGGift.h"
#import "HGDragToUpdateTableView.h"
#import "HGLogging.h"
#import "HGFriendEmotionService.h"
#import "HGDefines.h"
#import "HGFriendEmotionDetailViewController.h"
#import "HGUserImageView.h"

@interface HGFriendEmotionListViewController()<UIScrollViewDelegate, HGProgressViewDelegate,HGFriendEmotionServiceDelegate>
  
@end

#define kMoreFriendEmotionCount 6

@implementation HGFriendEmotionListViewController

- (id)initWithFriendEmotions:(NSArray*)theFriendEmotions {
    self = [super initWithNibName:@"HGFriendEmotionListViewController" bundle:nil];
    if (self){
        friendEmotions = [theFriendEmotions retain];
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
    
    astroTrendTitleLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:[HappyGiftAppDelegate fontSizeNormal]];
    astroTrendTitleLabel.textColor = UIColorFromRGB(0xd50247);
    astroTrendTitleLabel.text = @"正能量，负能量";

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
    
    [astroTrendHeadView release];
    [astroTrendTitleLabel release];
    [friendEmotions release];
    
    HGFriendEmotionService* service = [HGFriendEmotionService sharedService];
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
    return [friendEmotions count];
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"HGAstroTrendListViewCellView";
    UITableViewCell *cell = [theTableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [HGAstroTrendListViewCellView astroTrendListViewCellView];
    }
   HGAstroTrendListViewCellView* astroTrendListViewCellView = (HGAstroTrendListViewCellView*)cell;
   HGFriendEmotion* friendEmotion = [friendEmotions objectAtIndex:indexPath.row];
    
    [astroTrendListViewCellView.userImageView updateUserImageViewWithFriendEmotion:friendEmotion];
    
    astroTrendListViewCellView.nameLabel.text = friendEmotion.recipient.recipientName;
    astroTrendListViewCellView.descriptionLabel.text = friendEmotion.emotionType == kFriendEmotionTypePositive ? @"正能量" : @"负能量";
    
    return cell;
}

#pragma mark Table view delegate

- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [theTableView deselectRowAtIndexPath: indexPath animated: YES];
    
   HGFriendEmotion* friendEmotion = [friendEmotions objectAtIndex:indexPath.row];

    [HGRecipientService sharedService].selectedRecipient = friendEmotion.recipient;
    
   HGFriendEmotionDetailViewController* viewContoller = [[HGFriendEmotionDetailViewController alloc] initWithFriendEmotion:friendEmotion];
    [self.navigationController pushViewController:viewContoller animated:YES];
    [viewContoller release];
    
   [HGTrackingService logEvent:kTrackingEventEnterFriendEmotionDetail withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"HGFriendEmotionListViewController", @"from", nil]];
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
    HGFriendEmotionService* service = [HGFriendEmotionService sharedService];
    service.delegate = self;
    [service requestMoreFriendEmotion:kMoreFriendEmotionCount];
}

#pragma mark - HGFriendEmotionServiceDelegate
- (void)friendEmotionService:(HGFriendEmotionService *)friendEmotionService didRequestFriendEmotionSucceed:(NSArray*)theFriendEmotions {
    if (friendEmotions) {
        [friendEmotions release];
        friendEmotions = nil;
    }
    friendEmotions = [[HGFriendEmotionService sharedService].friendEmotions retain];
    
    [tableView reloadData];
    tableView.bottomDragToUpdateRunning = NO;
    if ([theFriendEmotions count] < kMoreFriendEmotionCount) {
        tableView.bottomDragToUpdateVisbile = NO;
    }
    
    friendEmotionService.delegate = nil;
}

- (void)friendEmotionService:(HGFriendEmotionService *)friendEmotionService didRequestFriendEmotionFail:(NSString*)error {
    tableView.bottomDragToUpdateRunning = NO;
    friendEmotionService.delegate = nil;
}
@end

