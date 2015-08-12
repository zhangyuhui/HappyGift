//
//  HGGIFGiftListViewController.m
//  HappyGift
//
//  Created by Yujian Weng on 12-7-27.
//  Copyright 2011 Ztelic Inc Inc. All rights reserved.
//

#import "HGGIFGiftListViewController.h"
#import "HappyGiftAppDelegate.h"
#import "HGConstants.h"
#import "HGProgressView.h"
#import "HGGiftSet.h"
#import "HGRecipientSelectionViewController.h"
#import "HGGiftSetDetailViewListItemView.h"
#import "HGGiftDetailViewController.h"
#import "HGTrackingService.h"
#import "UIBarButtonItem+Addition.h"
#import <QuartzCore/QuartzCore.h>
#import "HGGIFGiftListViewRowView.h"
#import "HGLogging.h"
#import "HGDragToUpdateTableView.h"
#import "HGGiftCollectionService.h"
#import "HGOccasionGiftCollection.h"
#import "HGOccasionCategory.h"
#import "HGOccasionTag.h"
#import "HGShareViewController.h"
#import "HGImageService.h"
#import "HGGIFGift.h"
#import "HGFriendEmotion.h"
#import "HGFriendEmotionService.h"
#import "HGAstroTrend.h"
#import "HGAstroTrendService.h"
#import "HGVirtualGiftService.h"
#import "HGDefines.h"

#define kGIFGiftListViewColumnCount 3

@interface HGGIFGiftListViewController()<UIScrollViewDelegate, HGRecipientSelectionViewControllerDelegate, HGGIFGiftListViewRowViewDelegate, HGProgressViewDelegate, HGGiftCollectionServiceDelegate, HGFriendEmotionServiceDelegate, HGAstroTrendServiceDelegate, HGVirtualGiftServiceDelegate>

-(void) setupGiftCategoryUI;
@end

@implementation HGGIFGiftListViewController

- (id)initWithOccasionGiftCollection:(HGOccasionGiftCollection*)theGiftCollection {
    self = [super initWithNibName:@"HGGIFGiftListViewController" bundle:nil];
    if (self){
        occasionGiftCollection = [theGiftCollection retain];
        gifGifts = [occasionGiftCollection.gifGifts retain];
    }
    return self;
}

- (id)initWithFriendEmotion:(HGFriendEmotion*)theFriendEmotion {
    self = [super initWithNibName:@"HGGIFGiftListViewController" bundle:nil];
    if (self){
        friendEmotion = [theFriendEmotion retain];
        gifGifts = [friendEmotion.gifGifts retain];
    }
    return self;
}

- (id)initWithAstroTrend:(HGAstroTrend*)theAstroTrend {
    self = [super initWithNibName:@"HGGIFGiftListViewController" bundle:nil];
    if (self){
        astroTrend = [theAstroTrend retain];
        gifGifts = [astroTrend.gifGifts retain];
    }
    return self;
}

- (id)initWithGIFGiftsByCategory:(NSMutableDictionary*)theGIFGifts {
    self = [super initWithNibName:@"HGGIFGiftListViewController" bundle:nil];
    if (self){
        gifGiftsByCategory = [theGIFGifts retain];
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    self.view.backgroundColor = [HappyGiftAppDelegate genericBackgroundColor];
    
    leftBarButtonItem = [[UIBarButtonItem alloc ] initNavigationBackImageBarButtonItem:@"navigation_back" target:self action:@selector(handleBackAction:)];
    navigationBar.topItem.leftBarButtonItem = leftBarButtonItem; 
    navigationBar.topItem.rightBarButtonItem = nil;
    
    [recipientButton addTarget:self action:@selector(handleRecipientButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    titleLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:[HappyGiftAppDelegate fontSizeNormal]];
    titleLabel.textColor = [UIColor blackColor];
    
    recipientLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:[HappyGiftAppDelegate fontSizeLarge]];
    recipientLabel.textColor = [UIColor whiteColor];
    recipientLabel.backgroundColor = [UIColor clearColor];
    recipientLabel.textAlignment = UITextAlignmentLeft;
    
    [[HGRecipientService sharedService] updateRecipientLabel:recipientLabel];
    
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
    
    if (gifGiftsByCategory) {
        [self setupGiftCategoryUI];
        if (headView.hidden == NO){
            CGRect headViewFrame = headView.frame;
            headViewFrame.origin.y = -2.0; 
            headView.frame = headViewFrame;
            
            CGRect tableViewFrame = tableView.frame;
            tableViewFrame.origin.y = 46.0; 
            tableViewFrame.size.height = 370.0;
            tableView.frame = tableViewFrame;
            
            CGRect categoryScrollViewFrame = categoryScrollView.frame;
            categoryScrollViewFrame.origin.x = headView.frame.size.width;
            categoryScrollView.frame = categoryScrollViewFrame;
        }
    }else{
        CGRect headViewFrame = headView.frame;
        headViewFrame.origin.y = -2.0; 
        headView.frame = headViewFrame;
        
        CGRect tableViewFrame = tableView.frame;
        tableViewFrame.origin.y = 46.0; 
        tableViewFrame.size.height = 409.0;
        tableView.frame = tableViewFrame;
    }
    
    if ([gifGifts count] == 0) {
        headView.hidden = YES;
        [progressView startAnimation];
        [HGVirtualGiftService sharedService].delegate = self;
        [[HGVirtualGiftService sharedService] requestGIFGifts];
    } 
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

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if ([HGRecipientService sharedService].selectedRecipient == nil) {
        [selectedGIFGift release];
        selectedGIFGift = nil;
    }
    
    if (selectedGIFGift) {
        [self handleGIGGiftSelected:selectedGIFGift];
    }
    
    if (headView.hidden == NO && headView.frame.origin.y == -2.0){
        [UIView animateWithDuration:0.3 
                              delay:0.0 
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             CGRect tableViewFrame = tableView.frame;
                             tableViewFrame.origin.y = 85.0;
                             tableView.frame = tableViewFrame;
                             CGRect headViewFrame = headView.frame;
                             headViewFrame.origin.y = 46.0; 
                             headView.frame = headViewFrame;
                         } 
                         completion:^(BOOL finished) {
                             [UIView animateWithDuration:0.3 
                                                   delay:0.0 
                                                 options:UIViewAnimationOptionCurveEaseInOut 
                                              animations:^{
                                                  CGRect categoryScrollViewFrame = categoryScrollView.frame;
                                                  categoryScrollViewFrame.origin.x = -50.0;
                                                  categoryScrollView.frame = categoryScrollViewFrame;
                                              } 
                                              completion:^(BOOL finished) {
                                                  [UIView animateWithDuration:0.2 
                                                                        delay:0.0 
                                                                      options:UIViewAnimationOptionCurveEaseInOut 
                                                                   animations:^{
                                                                       CGRect categoryScrollViewFrame = categoryScrollView.frame;
                                                                       categoryScrollViewFrame.origin.x = 30.0;
                                                                       categoryScrollView.frame = categoryScrollViewFrame;
                                                                   } 
                                                                   completion:^(BOOL finished) {
                                                                       [UIView animateWithDuration:0.2 
                                                                                             delay:0.0 
                                                                                           options:UIViewAnimationOptionCurveEaseInOut 
                                                                                        animations:^{
                                                                                            CGRect categoryScrollViewFrame = categoryScrollView.frame;
                                                                                            categoryScrollViewFrame.origin.x = 0.0;
                                                                                            categoryScrollView.frame = categoryScrollViewFrame;
                                                                                        } 
                                                                                        completion:^(BOOL finished) {
                                                                                            
                                                                                        }];
                                                                   }];
                                              }];
                         }];
        
    }
    
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

#pragma mark HGRecipientSelectionViewControllerDelegate
- (void)didRecipientSelected: (HGRecipient*) recipient {
    [[HGRecipientService sharedService] updateRecipientLabel:recipientLabel];
}

- (void)didReceiveMemoryWarning{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    [tableView release];
    [contentSubViews release];
    [progressView release];
    [leftBarButtonItem release];
    [gifGifts release];
    [recipientButton release];
    [recipientLabel release];
    [titleLabel release];
    [occasionGiftCollection release];
    [friendEmotion release];
    [astroTrend release];
    [gifGiftsByCategory release];
    [selectedCategoryButton release];
    [selectedGIFGift release];
    
    if ([HGGiftCollectionService sharedService].delegate == self) {
        [HGGiftCollectionService sharedService].delegate = nil;
    }
    if ([HGFriendEmotionService sharedService].delegate == self) {
        [HGFriendEmotionService sharedService].delegate = nil;
    }
    if ([HGAstroTrendService sharedService].delegate == self) {
        [HGAstroTrendService sharedService].delegate = nil;
    }
    if ([HGVirtualGiftService sharedService].delegate == self) {
        [HGVirtualGiftService sharedService].delegate = nil;
    }
	[super dealloc];
}

- (void)handleBackAction:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)handleRecipientButtonAction:(id)sender{
    [HGTrackingService logEvent:kTrackingEventEnterRecipientSelection withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"HGGIFGiftListViewController", @"from", nil]];
    
    HGRecipientSelectionViewController* viewController = [[HGRecipientSelectionViewController alloc] initWithRecipientSelectionType:kRecipientSelectionTypeSNSUsers];
    viewController.delegate = self;
    [self presentModalViewController:viewController animated:YES];
    [viewController release];
    [HGTrackingService logPageView];
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return ([gifGifts count] + kGIFGiftListViewColumnCount - 1) / kGIFGiftListViewColumnCount;
}

-(UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *viewIdentifier = @"HGGIFGiftListViewRowView";
    
    HGGIFGiftListViewRowView *cell = [theTableView dequeueReusableCellWithIdentifier:viewIdentifier];
    if (cell == nil) {
        cell = [[[HGGIFGiftListViewRowView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:viewIdentifier] autorelease];
        cell.delegate = self;
    }
    
    NSUInteger row = indexPath.row;
    
    NSMutableArray* theGifGifts = [NSMutableArray arrayWithObject:[gifGifts objectAtIndex: kGIFGiftListViewColumnCount * row]];
    for (int i = 1; i < kGIFGiftListViewColumnCount; ++i) {
        if (kGIFGiftListViewColumnCount * row + i < [gifGifts count]) {
            [theGifGifts addObject:[gifGifts objectAtIndex: kGIFGiftListViewColumnCount * row + i]];
        }
    }
    
    cell.gifGifts = theGifGifts;
    
    return cell;
}


- (void)dragToUpdateTableView:(HGDragToUpdateTableView *)dragToUpdateTableView didRequestTopUpdate:(HGDragToUpdateView *)topDragToUpdateView {
    HGDebug(@"didRequestTopUpdate");
}

- (void)dragToUpdateTableView:(HGDragToUpdateTableView *)dragToUpdateTableView didRequestBottomUpdate:(HGDragToUpdateView *)bottomDragToUpdateView {
    HGDebug(@"bottomDragToUpdateView");
    
    [self requireMoreGIFGifts];
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

- (void)requireMoreGIFGifts {
    HGDebug(@"requireMoreGIFGifts");
    HGRecipient* recipient = [HGRecipientService sharedService].selectedRecipient;
    
    int networkId = recipient.recipientNetworkId;
    NSString* profileId = recipient.recipientProfileId;
    int offset = [gifGifts count];
    
    if (occasionGiftCollection) {
        [HGGiftCollectionService sharedService].delegate = self;
        
        NSString* occasionType = occasionGiftCollection.occasion.occasionCategory.identifier;
        NSString* tagId = occasionGiftCollection.occasion.occasionTag.identifier;
        
        [[HGGiftCollectionService sharedService] requestGIFGiftsForOccasion:occasionType
                                                               andNetworkId:networkId
                                                               andProfileId:profileId 
                                                                 withOffset:offset
                                                                   andTagId:tagId];
    } else if (friendEmotion) {
        [HGFriendEmotionService sharedService].delegate = self;
        
        [[HGFriendEmotionService sharedService] requestMoreFriendEmotionGIFGiftsForFriend:networkId andProfileId:profileId withOffset:offset andCount:9];
    } else if (astroTrend) {
        [HGAstroTrendService sharedService].delegate = self;
        [[HGAstroTrendService sharedService] requestMoreAstroTrendGIFGiftsForFriend:networkId andProfileId:profileId withOffset:offset andCount:9];
    } else if (gifGiftsByCategory) {
        [HGVirtualGiftService sharedService].delegate = self;
        [[HGVirtualGiftService sharedService] requestGIFGiftsForCategory:selectedCategoryButton.titleLabel.text withOffset:[gifGifts count] andCount:6];
    }
}

- (void)giftCollectionService:(HGGiftCollectionService *)giftCollectionService didRequestGIFGiftsForOccasionSucceed:(NSArray*)giftsForOccasion {
    HGDebug(@"didRequestGIFGiftsForOccasionSucceed");
    
    NSMutableArray* newGifGifts = [[NSMutableArray alloc] initWithArray:gifGifts];
    [newGifGifts addObjectsFromArray:giftsForOccasion];
    gifGifts = [newGifGifts retain];
    [newGifGifts release];
    
    if (occasionGiftCollection) {
        occasionGiftCollection.gifGifts = gifGifts;
    }
    
    [tableView reloadData];
    tableView.bottomDragToUpdateRunning = NO;
    if ([giftsForOccasion count] < 9) {
        tableView.bottomDragToUpdateVisbile = NO;
    }

}

- (void)giftCollectionService:(HGGiftCollectionService *)giftCollectionService didRequestGIFGiftsForOccasionFail:(NSString*)error {
    HGWarning(@"didRequestGIFGiftsForOccasionFail");
    tableView.bottomDragToUpdateRunning = NO;
}

- (void)friendEmotionService:(HGFriendEmotionService *)friendEmotionService didRequestFriendEmotionGIFGiftsForFriendSucceed:(HGFriendEmotion*)theFriendEmotion {
    HGDebug(@"didRequestFriendEmotionGIFGiftsForFriendSucceed");
    
    NSMutableArray* newGifGifts = [[NSMutableArray alloc] initWithArray:gifGifts];
    [newGifGifts addObjectsFromArray:theFriendEmotion.gifGifts];
    gifGifts = [newGifGifts retain];
    [newGifGifts release];
    
    if (friendEmotion) {
        friendEmotion.gifGifts = gifGifts;
    }
    
    [tableView reloadData];
    tableView.bottomDragToUpdateRunning = NO;
    if ([theFriendEmotion.gifGifts count] < 9) {
        tableView.bottomDragToUpdateVisbile = NO;
    }
}

- (void)friendEmotionService:(HGFriendEmotionService *)friendEmotionService didRequestFriendEmotionGIFGiftsForFriendFail:(NSString*)error {
    HGWarning(@"didRequestFriendEmotionGIFGiftsForFriendFail");
    tableView.bottomDragToUpdateRunning = NO;
}

- (void)astroTrendService:(HGAstroTrendService *)astroTrendService didRequestAstroTrendGIFGiftsForFriendSucceed:(HGAstroTrend*)theAstroTrend {
    HGDebug(@"didRequestAstroTrendGIFGiftsForFriendSucceed");
    
    NSMutableArray* newGifGifts = [[NSMutableArray alloc] initWithArray:gifGifts];
    [newGifGifts addObjectsFromArray:theAstroTrend.gifGifts];
    gifGifts = [newGifGifts retain];
    [newGifGifts release];
    
    if (astroTrend) {
        astroTrend.gifGifts = gifGifts;
    }
    
    [tableView reloadData];
    tableView.bottomDragToUpdateRunning = NO;
    if ([theAstroTrend.gifGifts count] < 9) {
        tableView.bottomDragToUpdateVisbile = NO;
    }
}

- (void)astroTrendService:(HGAstroTrendService *)astroTrendService didRequestAstroTrendGIFGiftsForFriendFail:(NSString*)error {
    
    HGWarning(@"didRequestAstroTrendGIFGiftsForFriendFail");
    tableView.bottomDragToUpdateRunning = NO;
}


#pragma mark - HGGIFGiftListViewRowViewDelegate
- (void)handleGIGGiftSelected:(HGGIFGift*)gifGift {
    if (selectedGIFGift != gifGift) {
        [selectedGIFGift release];
        selectedGIFGift = [gifGift retain];
    }
    
    HGRecipient* recipient = [HGRecipientService sharedService].selectedRecipient;
    
    if (recipient == nil) {
        [HGTrackingService logEvent:kTrackingEventEnterRecipientSelection withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"HGGIFGiftListViewController", @"from", nil]];
        
        HGRecipientSelectionViewController* viewController = [[HGRecipientSelectionViewController alloc] initWithRecipientSelectionType:kRecipientSelectionTypeSNSUsers];
        viewController.delegate = self;
        [self presentModalViewController:viewController animated:YES];
        [viewController release];
        [HGTrackingService logPageView];
        
        return;
    } else {
        [selectedGIFGift release];
        selectedGIFGift = nil;
    }
    
    NSString* giftReason = @"";
    if (astroTrend) {
        if (astroTrend.trendScore >= 3) {
            giftReason = [NSString stringWithFormat:@"我发现你今天的%@极佳，", astroTrend.trendName];
        } else {
            giftReason = [NSString stringWithFormat:@"我发现你今天的%@不佳，", astroTrend.trendName];
        }
    } else if (friendEmotion) {
        if (friendEmotion.emotionType == kFriendEmotionTypePositive) {
            giftReason = [NSString stringWithFormat:@"我发现你最近发表了%d篇正能量微博，", [friendEmotion.tweets count]];
        } else {
            giftReason = [NSString stringWithFormat:@"我发现你最近发表了%d篇负能量微博，", [friendEmotion.tweets count]];
        }
    }
     
    HGShareViewController* viewController = [[HGShareViewController alloc] initWithGIFGift:gifGift recipient:recipient andGiftReason:giftReason];
    [self presentModalViewController:viewController animated:YES];
    [viewController release];
    [HGTrackingService logPageView];
    
    [HGTrackingService logEvent:kTrackingEventEnterShare withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"HGGIFGiftListViewController", @"from", @"shareGIFGift", @"type", recipient.recipientNetworkId == NETWORK_SNS_WEIBO ? @"weibo" : @"renren", @"network", nil]];
}

- (void) setupGiftCategoryUI {
    for (UIView* view in [categoryScrollView subviews]) {
        [view removeFromSuperview];
    }
    
    int index = 0;
    int viewX = 10;
    int viewHeight = 21;
    NSArray* keys = [gifGiftsByCategory allKeys];
    for (NSString* key in keys) {
        UIButton* categoryButton = [[UIButton alloc] initWithFrame:CGRectMake(viewX, 13, 100, viewHeight)];
        [categoryButton setShowsTouchWhenHighlighted:YES];
        categoryButton.titleLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:[HappyGiftAppDelegate fontSizeNormal]];
        [categoryButton setTitle:key forState:UIControlStateNormal];
        [categoryButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [categoryButton setTitleColor:UIColorFromRGB(0xd53d3b) forState:UIControlStateSelected];
        [categoryButton addTarget:self action:@selector(handleGiftCategorySelected:) forControlEvents:UIControlEventTouchUpInside];
        
        CGSize size = [categoryButton.titleLabel.text sizeWithFont:categoryButton.titleLabel.font constrainedToSize:CGSizeMake(100, categoryButton.frame.size.height)];
        
        if (size.width < 41){
            size.width = 41;
        }
        
        CGRect tmpFrame = categoryButton.frame;
        tmpFrame.size.width = size.width;
        categoryButton.frame = tmpFrame;
        
        viewX += categoryButton.frame.size.width + 10.0;

        if (index == 0) {
            if (selectedCategoryButton) {
                [selectedCategoryButton release];
                selectedCategoryButton = nil;
            }
            selectedCategoryButton = [categoryButton retain];
            
            [categoryButton setSelected:YES];
        }
        
        [categoryScrollView addSubview:categoryButton];
        [categoryButton release];
        
        if (![key isEqual:[keys lastObject]]) {
            UIImageView* giftCategorySeperatorView = [[UIImageView alloc] initWithFrame:CGRectMake(viewX, 5, 1.0, 36)];
            giftCategorySeperatorView.image = [UIImage imageNamed:@"gift_selection_panel_seperator"];
            
            [categoryScrollView addSubview:giftCategorySeperatorView];
            [giftCategorySeperatorView release];
            
            viewX += 11;
        }
        
        index++;
    }
    
    if (viewX > categoryScrollView.frame.size.width) {
        [categoryScrollView setContentSize:CGSizeMake(viewX, categoryScrollView.frame.size.height)];
    } else {
        [categoryScrollView setContentSize:CGSizeMake(categoryScrollView.frame.size.width + 1, categoryScrollView.frame.size.height)];
    }
    
    categoryScrollView.hidden = NO;
    headView.hidden = NO;
    titleLabel.hidden = YES;
    
    if (gifGifts) {
        [gifGifts release];
        gifGifts = nil;
    }
    gifGifts = [[gifGiftsByCategory objectForKey:selectedCategoryButton.titleLabel.text] retain];
    
    [tableView reloadData];
}

- (void)virtualGiftService:(HGVirtualGiftService *)virtualGiftService didRequestGIFGiftsSucceed:(NSMutableDictionary*)theGifGifts {
    [progressView stopAnimation];
    
    BOOL wasCategoryHidden = headView.hidden;
    
    if (gifGiftsByCategory) {
        [gifGiftsByCategory release];
        gifGiftsByCategory = nil;
    }
    gifGiftsByCategory = [theGifGifts retain];
    [self setupGiftCategoryUI];
    
    if (wasCategoryHidden == YES && headView.hidden == NO){
        
        CGRect tableViewFrame = tableView.frame;
        tableViewFrame.size.height = 370.0;
        tableView.frame = tableViewFrame;
            
        CGRect categoryScrollViewFrame = categoryScrollView.frame;
        categoryScrollViewFrame.origin.x = headView.frame.size.width;
        categoryScrollView.frame = categoryScrollViewFrame;
        
        [UIView animateWithDuration:0.3 
                              delay:0.0 
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             CGRect tableViewFrame = tableView.frame;
                             tableViewFrame.origin.y = 85.0;
                             tableView.frame = tableViewFrame;
                             CGRect headViewFrame = headView.frame;
                             headViewFrame.origin.y = 46.0; 
                             headView.frame = headViewFrame;
                         } 
                         completion:^(BOOL finished) {
                             [UIView animateWithDuration:0.3 
                                                   delay:0.0 
                                                 options:UIViewAnimationOptionCurveEaseInOut 
                                              animations:^{
                                                  CGRect categoryScrollViewFrame = categoryScrollView.frame;
                                                  categoryScrollViewFrame.origin.x = -50.0;
                                                  categoryScrollView.frame = categoryScrollViewFrame;
                                              } 
                                              completion:^(BOOL finished) {
                                                  [UIView animateWithDuration:0.2 
                                                                        delay:0.0 
                                                                      options:UIViewAnimationOptionCurveEaseInOut 
                                                                   animations:^{
                                                                       CGRect categoryScrollViewFrame = categoryScrollView.frame;
                                                                       categoryScrollViewFrame.origin.x = 30.0;
                                                                       categoryScrollView.frame = categoryScrollViewFrame;
                                                                   } 
                                                                   completion:^(BOOL finished) {
                                                                       [UIView animateWithDuration:0.2 
                                                                                             delay:0.0 
                                                                                           options:UIViewAnimationOptionCurveEaseInOut 
                                                                                        animations:^{
                                                                                            CGRect categoryScrollViewFrame = categoryScrollView.frame;
                                                                                            categoryScrollViewFrame.origin.x = 0.0;
                                                                                            categoryScrollView.frame = categoryScrollViewFrame;
                                                                                        } 
                                                                                        completion:^(BOOL finished) {
                                                                                            
                                                                                        }];
                                                                   }];
                                              }];
                         }];
    }
}

- (void)virtualGiftService:(HGVirtualGiftService *)virtualGiftService didRequestGIFGiftsFail:(NSString*)error {
    [progressView stopAnimation];
}

- (void)virtualGiftService:(HGVirtualGiftService *)virtualGiftService didRequestGIFGiftsForCategorySucceed:(NSDictionary*)theGifGiftsByCategory {
    HGDebug(@"didRequestGIFGiftsForCategorySucceed");
    
    int newResultCount = 0;
    
    for (NSString* key in [theGifGiftsByCategory allKeys]) {
        NSArray* theGifts = [theGifGiftsByCategory objectForKey:key];
        newResultCount += [theGifts count];
        
        NSArray* gifts = [gifGiftsByCategory objectForKey:key];
        
        if (gifts == nil) {
            [gifGiftsByCategory setValue:theGifts forKey:key];
        } else {
            NSMutableArray* newGifts = [[NSMutableArray alloc] initWithArray:gifts];
            [newGifts addObjectsFromArray:theGifts];
            [gifGiftsByCategory setValue:newGifts forKey:key];
            [newGifts release];
        }
    }
    
    if (gifGifts) {
        [gifGifts release];
        gifGifts = nil;
    }
    gifGifts = [[gifGiftsByCategory objectForKey:selectedCategoryButton.titleLabel.text] retain];
    
    [tableView reloadData];
    tableView.bottomDragToUpdateRunning = NO;
    if (newResultCount < 9) {
        tableView.bottomDragToUpdateVisbile = NO;
    }
}

- (void)virtualGiftService:(HGVirtualGiftService *)virtualGiftService didRequestGIFGiftsForCategoryFail:(NSString*)error {
    
    HGWarning(@"didRequestGIFGiftsForCategoryFail:%@", error);
    tableView.bottomDragToUpdateRunning = NO;
}

- (void) handleGiftCategorySelected:(id)sender {
    [UIView animateWithDuration:0.3 
                          delay:0.0 
                        options:UIViewAnimationOptionCurveEaseInOut 
                     animations:^{
                         tableView.alpha = 0.0;
                     }
                     completion:^(BOOL finished) {
                         UIButton* button = (UIButton*)sender;
                         button.selected = YES;
                         
                         selectedCategoryButton.selected = NO;
                         
                         if (selectedCategoryButton) {
                             [selectedCategoryButton release];
                             selectedCategoryButton = nil;
                         }
                         selectedCategoryButton = [button retain]; 
                         
                         if (gifGifts) {
                             [gifGifts release];
                             gifGifts = nil;
                         }
                         gifGifts = [[gifGiftsByCategory objectForKey:selectedCategoryButton.titleLabel.text] retain];
                         
                         tableView.bottomDragToUpdateVisbile = YES;
                         [tableView reloadData];
                         
                         [UIView animateWithDuration:0.3 
                                               delay:0.0 
                                             options:UIViewAnimationOptionCurveEaseInOut 
                                          animations:^{
                                              tableView.alpha = 1.0;
                                          }
                                          completion:^(BOOL finished) {
                                              
                                          }];    
                     }];
    
    
}

@end

