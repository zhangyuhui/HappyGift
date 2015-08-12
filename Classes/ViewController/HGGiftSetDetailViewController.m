//
//  HGGiftSetDetailViewController.m
//  HappyGift
//
//  Created by Zhang Yuhui on 2/11/11.
//  Copyright 2011 Ztelic Inc Inc. All rights reserved.
//

#import "HGGiftSetDetailViewController.h"
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
#import "HGGift.h"

@interface HGGiftSetDetailViewController()<UIScrollViewDelegate, HGRecipientSelectionViewControllerDelegate>
  
@end

@implementation HGGiftSetDetailViewController

- (id)initWithGiftSet:(HGGiftSet*)theGiftSet{
    self = [super initWithNibName:@"HGGiftSetDetailViewController" bundle:nil];
    if (self){
        giftSet = [theGiftSet retain];
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
    
    descriptionLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeTiny]];
    descriptionLabel.textColor = [UIColor darkGrayColor];
    
    titleLabel.text = giftSet.name;
    
    HGGift *theGift = [giftSet.gifts objectAtIndex:0];
    if (theGift.sexyName && ![@"" isEqualToString: theGift.sexyName]) {
        descriptionLabel.text = theGift.sexyName;
    } else {
        descriptionLabel.text = giftSet.manufacturer;
    }
    
    if ([giftSet.gifts count] > 1 && giftSet.canLetThemChoose){
        titleLabel.text = [NSString stringWithFormat:@"%@ (%@)", giftSet.name, @"收礼人可以在礼物组合中进行挑选"];
        titleLabel.numberOfLines = 0;
        titleLabel.lineBreakMode = UILineBreakModeCharacterWrap;
        
        CGSize titleLabelSize = [titleLabel.text sizeWithFont:titleLabel.font constrainedToSize:CGSizeMake(titleLabel.frame.size.width, 100.0f) lineBreakMode:UILineBreakModeCharacterWrap];
        CGRect titleLabelFrame = titleLabel.frame;
        titleLabelFrame.size.height = titleLabelSize.height;
        titleLabel.frame = titleLabelFrame;
        
        CGRect descriptionLabelFrame = descriptionLabel.frame;
        descriptionLabelFrame.origin.y = titleLabelFrame.origin.y + titleLabelFrame.size.height;
        descriptionLabel.frame = descriptionLabelFrame;
        
        CGRect headViewFrame = headView.frame;
        headViewFrame.size.height = descriptionLabelFrame.size.height + descriptionLabelFrame.origin.y + 2.0;
        if (headViewFrame.size.height < 46.0){
            headViewFrame.size.height = 46.0;
        }
        headView.frame = headViewFrame;
        
        CGRect contentViewFrame = contentView.frame;
        contentViewFrame.origin.y = headViewFrame.size.height + headViewFrame.origin.y;
        contentViewFrame.size.height = self.view.frame.size.height - contentViewFrame.origin.y;
        contentView.frame = contentViewFrame;
    }
    
    
    
    recipientLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:[HappyGiftAppDelegate fontSizeLarge]];
    recipientLabel.textColor = [UIColor whiteColor];
    recipientLabel.backgroundColor = [UIColor clearColor];
    recipientLabel.textAlignment = UITextAlignmentLeft;
    
    [[HGRecipientService sharedService] updateRecipientLabel:recipientLabel];
    
    progressView = [[HGProgressView progressView:self.view.frame] retain];
    [self.view addSubview:progressView];
    progressView.hidden = YES;
    
    [self setupGiftGroupViews];
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

#pragma mark HGRecipientSelectionViewControllerDelegate
- (void)didRecipientSelected: (HGRecipient*) recipient {
    [[HGRecipientService sharedService] updateRecipientLabel:recipientLabel];
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

- (void)dealloc{
    [contentView release];
    [contentSubViews release];
    [progressView release];
    [leftBarButtonItem release];
    [giftSet release];
    [recipientButton release];
    [recipientLabel release];
    [titleLabel release];
    [descriptionLabel release];
	[super dealloc];
}

- (void)handleBackAction:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)handleRecipientButtonAction:(id)sender{
    [HGTrackingService logEvent:kTrackingEventEnterRecipientSelection withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"HGGiftSetDetailViewController", @"from", nil]];
    
    HGRecipientSelectionViewController* viewController = [[HGRecipientSelectionViewController alloc] initWithNibName:@"HGRecipientSelectionViewController" bundle:nil];
    viewController.delegate = self;
    [self presentModalViewController:viewController animated:YES];
    [viewController release];
    [HGTrackingService logPageView];
}

- (void)setupGiftGroupViews{
    
    if (contentSubViews == nil){
        contentSubViews = [[NSMutableArray alloc] init];
    }else{
        for (UIView* subView in contentSubViews){
            [subView removeFromSuperview];
        }
        [contentSubViews removeAllObjects];
    }
    
    CGFloat viewX = 5.0;
    CGFloat viewY = 5.0;
    for (HGGift* gift in giftSet.gifts){
        HGGiftSetDetailViewListItemView* giftSetDetailViewListItemView = [HGGiftSetDetailViewListItemView giftSetDetailViewListItemView];
        CGRect viewFrame = giftSetDetailViewListItemView.frame;
        viewFrame.origin.x = viewX;
        viewFrame.origin.y = viewY;
        giftSetDetailViewListItemView.frame = viewFrame;
        
        [giftSetDetailViewListItemView addTarget:self action:@selector(handleGiftsListItemViewAction:) forControlEvents:UIControlEventTouchUpInside];
        
        [contentView addSubview:giftSetDetailViewListItemView];
        [contentSubViews addObject:giftSetDetailViewListItemView];
        
        giftSetDetailViewListItemView.gift = gift;
        
        if (viewX == 5.0){
            viewX += 5.0 + giftSetDetailViewListItemView.frame.size.width;
            if (gift == [giftSet.gifts lastObject]){
                viewY += viewFrame.size.height;
                viewY += 5.0;
            }
        }else{
            viewX = 5.0;
            viewY += viewFrame.size.height;
            if (gift != [giftSet.gifts lastObject]){
                viewY += 5.0;
            }
        }
    }
    
    viewY += 5.0;
    
    CGSize contentSize = contentView.contentSize;
    contentSize.width = contentView.frame.size.width;
    contentSize.height = viewY;
    [contentView setContentSize:contentSize];
}



- (void)handleGiftsListItemViewAction:(id)sender{
     HGGiftSetDetailViewListItemView* giftsGroupSelectionViewGiftsListItemView = (HGGiftSetDetailViewListItemView*)sender;
    
    [HGTrackingService logEvent:kTrackingEventEnterGiftDetail withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"HGGiftSetDetailViewController", @"from", giftsGroupSelectionViewGiftsListItemView.gift.identifier, @"productId", nil]];
    
    HGGiftDetailViewController* viewController = [[HGGiftDetailViewController alloc] initWithGift:giftsGroupSelectionViewGiftsListItemView.gift];
    [self.navigationController pushViewController:viewController animated:YES];
    [viewController release];
}


@end

