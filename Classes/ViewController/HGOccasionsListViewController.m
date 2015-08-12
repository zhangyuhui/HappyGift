//
//  HGOccasionsListViewController.m
//  HappyGift
//
//  Created by Zhang Yuhui on 2/11/11.
//  Copyright 2011 Ztelic Inc Inc. All rights reserved.
//

#import "HGOccasionsListViewController.h"
#import "HappyGiftAppDelegate.h"
#import "HGConstants.h"
#import "HGProgressView.h"
#import "HGOccasionGiftCollection.h"
#import "HGOccasionsListViewCellView.h"
#import "HGOccasionDetailViewController.h"
#import "HGGiftCollectionService.h"
#import "UIBarButtonItem+Addition.h"
#import <QuartzCore/QuartzCore.h>
#import "HGOccasionCategory.h"
#import "HGDefines.h"
#import "HGTrackingService.h"
#import "HGOccasionTag.h"

@interface HGOccasionsListViewController()<UIScrollViewDelegate>
  
@end

@implementation HGOccasionsListViewController

- (id)initWithGiftCollections:(NSArray*)theGiftCollections{
    self = [super initWithNibName:@"HGOccasionsListViewController" bundle:nil];
    if (self){
        giftCollections = [theGiftCollections retain];
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
    
    occasionNameLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:[HappyGiftAppDelegate fontSizeLarge]];
    occasionNameLabel.textColor = [UIColor blackColor];
    
    HGOccasionGiftCollection* giftCollection = [giftCollections objectAtIndex:0];
    
    if ([@"birthday" isEqualToString: giftCollection.occasion.occasionCategory.identifier]) {
        occasionNameLabel.textColor = UIColorFromRGB(0xe18106);
    } else {
        occasionNameLabel.textColor = UIColorFromRGB(0xe33a3c);
    }
    
    if (giftCollection.occasion.occasionCategory.longName && ![@"" isEqualToString:giftCollection.occasion.occasionCategory.longName]) {
        occasionNameLabel.text = giftCollection.occasion.occasionCategory.longName;
    } else {
        occasionNameLabel.text = giftCollection.occasion.occasionCategory.name;
    }
    
    if (giftCollection.occasion.occasionCategory.icon) {
        occasionImageView.image = [UIImage imageNamed:giftCollection.occasion.occasionCategory.icon];
    }

    progressView = [[HGProgressView progressView:self.view.frame] retain];
    [self.view addSubview:progressView];
    progressView.hidden = YES;
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

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void)dealloc {	
    [occasionTableView release];
    [progressView release];
    [leftBarButtonItem release];
    [giftCollections release];
    [occasionNameLabel release];
    [occasionImageView release];
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
    return [giftCollections count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"HGOccasionsListViewCellView";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [HGOccasionsListViewCellView occasionsListViewCellView];
    }
    HGOccasionsListViewCellView* occasionsListViewCellView = (HGOccasionsListViewCellView*)cell;
    HGOccasionGiftCollection* giftCollection = [giftCollections objectAtIndex:indexPath.row];
    occasionsListViewCellView.giftCollection = giftCollection;
    return cell;
}

#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath: indexPath animated: YES];
    HGOccasionGiftCollection* giftCollection = [giftCollections objectAtIndex:indexPath.row];
    HGOccasionDetailViewController* viewController = [[HGOccasionDetailViewController alloc] initWithGiftCollection:giftCollection];
    [self.navigationController pushViewController:viewController animated:YES];
    [viewController release];
    
    [HGTrackingService logEvent:kTrackingEventEnterOccasionDetail withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"HGOccasionsListViewController", @"from", giftCollection.occasion.occasionCategory.name, @"occasion", giftCollection.occasion.occasionTag.name, @"tag",  nil]];
}

@end

