//
//  HGMyLikesViewController.m
//  HappyGift
//
//  Created by Yujian Weng on 12-6-25.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//

#import "HGMyLikesViewController.h"
#import "HappyGiftAppDelegate.h"
#import "HGProgressView.h"
#import "UIBarButtonItem+Addition.h"
#import <QuartzCore/QuartzCore.h>
#import "NSString+Addition.h"
#import "HGTrackingService.h"
#import "HGUtility.h"
#import "HGGift.h"
#import "HGGiftSet.h"
#import "HGGiftsSelectionViewGiftsListItemView.h"
#import "HGGiftSetsService.h"
#import "HGGiftDetailViewController.h"
#import "HGGiftSetDetailViewController.h"

@interface HGMyLikesViewController() <HGGiftSetsServiceDelegate>
  
@end

@implementation HGMyLikesViewController


- (void)viewDidLoad{
    [super viewDidLoad];
    self.view.backgroundColor = [HappyGiftAppDelegate genericBackgroundColor];
    
    UIBarButtonItem* leftBarButtonItem = [[UIBarButtonItem alloc ] initNavigationBackImageBarButtonItem:@"navigation_back" target:self action:@selector(handleCancelAction:)];
    navigationBar.topItem.leftBarButtonItem = leftBarButtonItem; 
    [leftBarButtonItem release];
    
    CGRect titleViewFrame = CGRectMake(20, 0, 180, 44);
    UIView* titleView = [[UIView alloc] initWithFrame:titleViewFrame];
    
    CGRect titleLabelFrame = CGRectMake(0, 0, 180, 40);
	UILabel *titleLabel = [[UILabel alloc] initWithFrame:titleLabelFrame];
	titleLabel.backgroundColor = [UIColor clearColor];
	titleLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:[HappyGiftAppDelegate naviagtionTitleFontSize]];;
    titleLabel.minimumFontSize = 20.0;
    titleLabel.adjustsFontSizeToFitWidth = YES;
	titleLabel.textAlignment = UITextAlignmentCenter;
	titleLabel.textColor = [UIColor whiteColor];
	titleLabel.text = @"我的喜欢";
    [titleView addSubview:titleLabel];
    [titleLabel release];
    
	navigationBar.topItem.titleView = titleView;
    [titleView release];
    
    progressView = [[HGProgressView progressView:self.view.frame] retain];
    [self.view addSubview:progressView];
    progressView.hidden = YES;
    
    [progressView startAnimation];
    [HGGiftSetsService sharedService].delegate = self;
    [[HGGiftSetsService sharedService] requestMyLikeProducts];
}

- (void)viewDidUnload {
    [progressView removeFromSuperview];
    [progressView release];
    
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (![progressView animating]) {
        CGPoint p = [giftSetsScrollView contentOffset];
        [self updateGiftSetsDisplay];
        [giftSetsScrollView setContentOffset:p];
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void)dealloc{
    [progressView release];
    [contentSubViews release];
    
    HGGiftSetsService* giftSetsService = [HGGiftSetsService sharedService];
    if (giftSetsService.delegate == self) {
        giftSetsService.delegate = nil;
    }
	[super dealloc];
}

- (void)updateGiftSetsDisplayWithAnimation {
    giftSetsScrollView.alpha = 0.0;
    [self updateGiftSetsDisplay];

    [UIView animateWithDuration:0.8 
                       delay:0.0 
                     options:UIViewAnimationOptionCurveEaseInOut
                  animations:^{
                      giftSetsScrollView.alpha = 1.0;
                  } 
                  completion:^(BOOL finished) {
                  }];
}

- (void)updateGiftSetsDisplay {
    if (contentSubViews == nil) {
        contentSubViews = [[NSMutableArray alloc] init];
    }else{
        for (UIView* subView in contentSubViews) {
            [subView removeFromSuperview];
        }
        [contentSubViews removeAllObjects];
    }
    
    NSArray* myLikeGiftSets = [HGGiftSetsService sharedService].myLikeProducts;
    
    BOOL showEmptyView = YES;
    
    if (myLikeGiftSets != nil && [myLikeGiftSets count] > 0) {
        CGFloat viewX = 3.0;
        CGFloat viewY = 3.0;
        
        for (HGGiftSet* giftSet in myLikeGiftSets) {
            if ([giftSet.gifts count] == 1){
                HGGift* theGift = [giftSet.gifts objectAtIndex:0];
                if (![[HGGiftSetsService sharedService] isMyLike:theGift]) {
                    continue;
                }
            }
        
            
            showEmptyView = NO;
            
            HGGiftsSelectionViewGiftsListItemView* giftsSelectionViewGiftsListItemView = [HGGiftsSelectionViewGiftsListItemView giftsSelectionViewGiftsListItemView];
            CGRect viewFrame = giftsSelectionViewGiftsListItemView.frame;
            viewFrame.origin.x = viewX;
            viewFrame.origin.y = viewY;
            giftsSelectionViewGiftsListItemView.frame = viewFrame;
            
            [giftsSelectionViewGiftsListItemView addTarget:self action:@selector(handleGiftsListItemViewAction:) forControlEvents:UIControlEventTouchUpInside];
            
            [giftSetsScrollView addSubview:giftsSelectionViewGiftsListItemView];
            [contentSubViews addObject:giftsSelectionViewGiftsListItemView];
            
            giftsSelectionViewGiftsListItemView.giftSet = giftSet;
            
            viewY += viewFrame.size.height;
            if (giftSet != [myLikeGiftSets lastObject]) {
                viewY += 10.0;
            }else{
                viewY += 10.0;
            }
        }
        
        CGSize contentSize = giftSetsScrollView.contentSize;
        contentSize.width = giftSetsScrollView.frame.size.width;
        contentSize.height = viewY;
        [giftSetsScrollView setContentSize:contentSize];
        
        [giftSetsScrollView setContentOffset:CGPointMake(0.0, 0.0) animated:NO];
    }
    emptyView.hidden = !showEmptyView;
}

- (void)handleGiftsListItemViewAction:(id)sender {
    HGGiftsSelectionViewGiftsListItemView* giftsSelectionViewGiftsListItemView = (HGGiftsSelectionViewGiftsListItemView*)sender;
    HGGiftSet* theGiftSet = giftsSelectionViewGiftsListItemView.giftSet;
    if ([theGiftSet.gifts count] == 1){
        HGGift* theGift = [theGiftSet.gifts objectAtIndex:0];
        
        [HGTrackingService logEvent:kTrackingEventEnterGiftDetail withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"HGMyLikesViewController", @"from", theGift.identifier, @"productId", nil]];
        HGGiftDetailViewController* viewController = [[HGGiftDetailViewController alloc] initWithGift:theGift];
        [self.navigationController pushViewController:viewController animated:YES];
        [viewController release];
    }else{
        [HGTrackingService logEvent:kTrackingEventEnterGiftGroupDetail withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"HGMyLikesViewController", @"from", nil]];
        HGGiftSetDetailViewController* viewController = [[HGGiftSetDetailViewController alloc] initWithGiftSet:theGiftSet];
        [self.navigationController pushViewController:viewController animated:YES];
        [viewController release];
    }
}

- (void)handleCancelAction:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (void)giftSetsService:(HGGiftSetsService *)giftSetsService didRequestMyLikeProductsSucceed:(NSArray*)myLikes {
    [progressView stopAnimation];
    [self updateGiftSetsDisplayWithAnimation];
    giftSetsService.delegate = nil;
}

- (void)giftSetsService:(HGGiftSetsService *)giftSetsService didRequestMyLikeProductsFail:(NSString*)error {
    [progressView stopAnimation];
    [self updateGiftSetsDisplayWithAnimation];
    giftSetsService.delegate = nil;
}
@end

