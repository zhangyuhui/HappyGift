//
//  HGAstroTrendListViewController.m
//  HappyGift
//
//  Created by Yujian Weng on 12-6-11.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//

#import "HGAstroTrendListViewController.h"
#import "HappyGiftAppDelegate.h"
#import "HGConstants.h"
#import "HGProgressView.h"
#import "HGAstroTrendListViewCellView.h"
#import "UIBarButtonItem+Addition.h"
#import <QuartzCore/QuartzCore.h>
#import "HGRecipientService.h"
#import "HGTrackingService.h"
#import "HGAstroTrend.h"
#import "HGGift.h"
#import "HGDragToUpdateTableView.h"
#import "HGLogging.h"
#import "HGAstroTrendService.h"
#import "HGDefines.h"
#import "HGAstroTrendDetailViewController.h"

@interface HGAstroTrendListViewController()<UIScrollViewDelegate, HGProgressViewDelegate, HGAstroTrendServiceDelegate>
  
@end

#define kMoreAstroTrendCount 6

@implementation HGAstroTrendListViewController

- (id)initWithAstroTrends:(NSArray*)theAstroTrends {
    self = [super initWithNibName:@"HGAstroTrendListViewController" bundle:nil];
    if (self){
        astroTrends = [theAstroTrends retain];
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
    astroTrendTitleLabel.textColor = UIColorFromRGB(0xde5a1b);
    astroTrendTitleLabel.text = @"星座运势";

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
    [astroTrends release];
    
    HGAstroTrendService* service = [HGAstroTrendService sharedService];
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
    return [astroTrends count];
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"HGAstroTrendListViewCellView";
    UITableViewCell *cell = [theTableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [HGAstroTrendListViewCellView astroTrendListViewCellView];
    }
    HGAstroTrendListViewCellView* astroTrendListViewCellView = (HGAstroTrendListViewCellView*)cell;
    HGAstroTrend* astroTrend = [astroTrends objectAtIndex:indexPath.row];
    astroTrendListViewCellView.astroTrend = astroTrend;
    return cell;
}

#pragma mark Table view delegate

- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [theTableView deselectRowAtIndexPath: indexPath animated: YES];
    
    [HGTrackingService logEvent:kTrackingEventEnterAstroTrendDetail withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"HGAstroTrendListViewController", @"from", nil]];
    
    HGAstroTrend* astroTrend = [astroTrends objectAtIndex:indexPath.row];

    [HGRecipientService sharedService].selectedRecipient = astroTrend.recipient;
    
    HGAstroTrendDetailViewController* viewContoller = [[HGAstroTrendDetailViewController alloc] initWithAstroTrend:astroTrend];
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
    HGAstroTrendService* service = [HGAstroTrendService sharedService];
    service.delegate = self;
    [service requestMoreAstroTrend:kMoreAstroTrendCount];
}

#pragma mark - HGAstroTrendServiceDelegate
- (void)astroTrendService:(HGAstroTrendService *)astroTrendService didRequestAstroTrendSucceed:(NSArray*)theAstroTrends {
    if (astroTrends) {
        [astroTrends release];
        astroTrends = nil;
    }
    astroTrends = [[HGAstroTrendService sharedService].astroTrends retain];
    
    [tableView reloadData];
    tableView.bottomDragToUpdateRunning = NO;
    if ([theAstroTrends count] < kMoreAstroTrendCount) {
        tableView.bottomDragToUpdateVisbile = NO;
    }
    
    astroTrendService.delegate = nil;
}

- (void)astroTrendService:(HGAstroTrendService *)astroTrendService didRequestAstroTrendFail:(NSString*)error {
    tableView.bottomDragToUpdateRunning = NO;
    astroTrendService.delegate = nil;
}

@end

