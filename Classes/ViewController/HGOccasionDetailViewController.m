//
//  HGOccasionDetailViewController.m
//  HappyGift
//
//  Created by Zhang Yuhui on 2/11/11.
//  Copyright 2011 Ztelic Inc Inc. All rights reserved.
//

#import "HGOccasionDetailViewController.h"
#import "HappyGiftAppDelegate.h"
#import "HGConstants.h"
#import "HGProgressView.h"
#import "HGImageService.h"
#import "HGGiftCollectionService.h"
#import "HGOccasionGiftCollection.h"
#import "HGOccasionDetailViewListItemView.h"
#import "HGGiftDetailViewController.h"
#import "HGGiftSet.h"
#import "HGGiftsSelectionViewController.h"
#import "HGGiftSetDetailViewController.h"
#import "HGTweet.h"
#import "HGGiftSetsService.h"
#import "UIBarButtonItem+Addition.h"
#import "UIImage+Addition.h"
#import <QuartzCore/QuartzCore.h>
#import "HGRecipient.h"
#import "HGTrackingService.h"
#import "HGRecipientService.h"
#import "HGOccasionCategory.h"
#import "HGUserImageView.h"
#import "HGUtility.h"
#import "HGOccasionsDetailViewListRowView.h"
#import "HGSentGiftsViewCellView.h"
#import "HGDragToUpdateTableView.h"
#import "HGDefines.h"
#import "HGLogging.h"
#import "HGGift.h"
#import "HGImageComposeViewController.h"
#import "HGOccasionTag.h"
#import "HGVirtualGiftsView.h"
#import "RenrenService.h"
#import "WBEngine.h"
#import "HGAccountViewController.h"
#import "HGShareViewController.h"
#import "HGGIFGiftListViewController.h"
#import "HGTweetView.h"
#import "HGTweetListView.h"
#import "HGTweetCommentService.h"

@interface HGOccasionDetailViewController()<UIScrollViewDelegate, UITableViewDelegate, HGProgressViewDelegate, HGGiftCollectionServiceDelegate, HGOccasionsDetailViewListRowViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, HGImageComposeViewControllerDelegate, UIActionSheetDelegate, HGTweetListViewDelegate, HGTweetViewDelegate>
  
@end

@implementation HGOccasionDetailViewController

- (id)initWithGiftCollection:(HGOccasionGiftCollection*)theGiftCollection{
    self = [super initWithNibName:@"HGOccasionDetailViewController" bundle:nil];
    if (self){
        giftCollection = [theGiftCollection retain];
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
    
    userNameLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:[HappyGiftAppDelegate fontSizeNormal]];
    userNameLabel.textColor = [UIColor blackColor];
    
    userDescriptionLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeNormal]];
    userDescriptionLabel.textColor = [UIColor darkGrayColor];
    
    userNameLabel.text = giftCollection.occasion.recipient.recipientName;
    
    giftRecommandationLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeNormal]];
    giftRecommandationLabel.textColor = UIColorFromRGB(0xd53d3b);
    giftRecommandationLabel.text = [NSString stringWithFormat:@"为%@推荐的礼物：", giftCollection.occasion.recipient.recipientName];
    
    if (giftCollection.occasion.occasionTag.icon) {
        occasionImageView.image = [UIImage imageNamed:giftCollection.occasion.occasionTag.icon];
    }
    
    NSMutableString* userDescription = [[NSMutableString alloc] init];
    if (giftCollection.occasion.userGender != nil && [giftCollection.occasion.userGender isEqualToString:@""] == NO){
        if ([userDescription length] != 0){
            [userDescription appendFormat:@" %@", giftCollection.occasion.userGender];
        }else{
            [userDescription appendFormat:@"%@", giftCollection.occasion.userGender];
        }
    }

    if (giftCollection.occasion.userCity != nil && [giftCollection.occasion.userCity isEqualToString:@""] == NO){
        if ([userDescription length] != 0){
            [userDescription appendFormat:@" %@", giftCollection.occasion.userCity];
        }else{
            [userDescription appendFormat:@"%@", giftCollection.occasion.userCity];
        }
    }
    userDescriptionLabel.text = userDescription;
    [userDescription release];
    
    progressView = [[HGProgressView progressView:self.view.frame] retain];
    [self.view addSubview:progressView];
    progressView.hidden = YES;
    
    [userImageView updateUserImageViewWithOccasion:giftCollection.occasion];
    [userImageView removeTagImage];
    //[userImageView updateUserImageViewWithRecipient:giftCollection.occasion.recipient];
    
    occasionNameLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:[HappyGiftAppDelegate fontSizeNormal]];
    occasionNameLabel.textColor = [UIColor blackColor];
    
    occasionDescriptionLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeNormal]];
    occasionDescriptionLabel.textColor = [UIColor darkGrayColor];
    
    startButton.titleLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeNormal]];
    startButton.titleLabel.minimumFontSize = 14;
    startButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    [startButton setTitle:[NSString stringWithFormat:@"更多礼物", giftCollection.occasion.recipient.recipientName] forState:UIControlStateNormal];
    
    [startButton addTarget:self action:@selector(handleStartAction:) forControlEvents:UIControlEventTouchUpInside];
    
    occasionNameLabel.adjustsFontSizeToFitWidth = NO;
    occasionNameLabel.numberOfLines = 1;
    occasionNameLabel.text = giftCollection.occasion.occasionTag.name;
    
    CGRect occasionNameLabelFrame = occasionNameLabel.frame;
    CGSize occasionNameLabelSize = [occasionNameLabel.text sizeWithFont:occasionNameLabel.font constrainedToSize:CGSizeMake(occasionNameLabelFrame.size.width, 20.0)];
    occasionNameLabelFrame.size.height = occasionNameLabelSize.height;
    occasionNameLabel.frame = occasionNameLabelFrame;
    
    
    occasionNameLabel.hidden = YES;
    
    CGRect occasionDescriptionLabelFrame = occasionDescriptionLabel.frame;
    occasionDescriptionLabelFrame.origin.y = 25.0;
    occasionDescriptionLabel.frame = occasionDescriptionLabelFrame;
    
    showDetailButton.hidden = YES;
    tweetsOverlayView.hidden = YES;
    
    if ([@"birthday" isEqualToString: giftCollection.occasion.eventType]) {
                
        occasionDescriptionLabel.text = [HGUtility formatBirthdayText:giftCollection.occasion.eventDate forShortDescription:NO];
    } else {
        occasionDescriptionLabel.text = [HGUtility formatLongDate:giftCollection.occasion.eventDate];
    }
    
    if (giftCollection.occasion.eventDescription && ![@"" isEqualToString: giftCollection.occasion.eventDescription]) {
        CGFloat viewX = 10.0;
        CGFloat viewY = occasionSeperatorTop.frame.origin.y + 5.0;
        CGFloat viewWidth = 280.0;
        
        UILabel* occastionEventDescriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(viewX, viewY, viewWidth, 20.0)];
        occastionEventDescriptionLabel.numberOfLines = 0;
        occastionEventDescriptionLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:[HappyGiftAppDelegate fontSizeNormal]];
        occastionEventDescriptionLabel.textColor = [UIColor blackColor];
        occastionEventDescriptionLabel.text = giftCollection.occasion.eventDescription;
        
        CGRect occastionEventDescriptionLabelFrame = occastionEventDescriptionLabel.frame;
        CGSize occastionEventDescriptionLabelSize = [occastionEventDescriptionLabel.text sizeWithFont:occastionEventDescriptionLabel.font constrainedToSize:CGSizeMake(occasionNameLabelFrame.size.width, 80.0)];
        occastionEventDescriptionLabelFrame.size.height = occastionEventDescriptionLabelSize.height;
        occastionEventDescriptionLabel.frame = occastionEventDescriptionLabelFrame;
        
        [occasionView addSubview:occastionEventDescriptionLabel];
        [occastionEventDescriptionLabel release];
        viewY += occastionEventDescriptionLabel.frame.size.height;
        
        viewY += 2.0;
        
        CGRect occasionSeperatorBottomFrame = occasionSeperatorBottom.frame;
        occasionSeperatorBottomFrame.origin.y = viewY;
        occasionSeperatorBottom.frame = occasionSeperatorBottomFrame;
        
        viewY += 5.0;
        CGRect giftRecommandationFrame = giftRecommandationHeaderView.frame;
        giftRecommandationFrame.origin.y = viewY;
        giftRecommandationHeaderView.frame = giftRecommandationFrame;
        viewY += giftRecommandationFrame.size.height;
        viewY += 5.0;
        
        CGRect occasionViewFrame = occasionView.frame;
        occasionViewFrame.size.height = viewY;
        occasionView.frame = occasionViewFrame;
        
        occasionSeperatorBottom.hidden = NO;
    } else if (giftCollection.occasion.tweet != nil){
        occasionView.autoresizesSubviews = NO;
        CGFloat viewX = 0.0;
        CGFloat viewY = occasionSeperatorTop.frame.origin.y + 5.0;
        CGFloat viewWidth = 300.0;
        
        tweetView = [HGTweetView tweetView];
        tweetView.showComments = NO;
        if ([[giftCollection.occasion.tweet comments] count] > 0 ) {
            tweetView.showCommentButton = NO;
        } else {
            tweetView.delegate = self;
        }
        CGRect tmpFrame = tweetView.frame;
        tmpFrame.size.width = viewWidth;
        tmpFrame.origin.y = viewY;
        tmpFrame.origin.x = viewX;
        tweetView.frame = tmpFrame;
        
        tweetView.tweet = giftCollection.occasion.tweet;
        [occasionView addSubview:tweetView];
        
        viewY += tweetView.frame.size.height;
        
        tweetsOverlayView.frame = tweetView.frame;
        tmpFrame = tweetsOverlayView.frame;
        tmpFrame.size.width -= 4;
        tmpFrame.origin.x = 2;
        tweetsOverlayView.frame = tmpFrame;
        
        showDetailButton.titleLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:[HappyGiftAppDelegate fontSizeSmall]];
        
        [showDetailButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [showDetailButton setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
        [showDetailButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
        
        if ([[giftCollection.occasion.tweet comments] count] > 0) {
            tweetsOverlayView.hidden = NO;
            [occasionView bringSubviewToFront:tweetsOverlayView];
            
            [tweetsOverlayView addTarget:self action:@selector(tweetsViewTouchDown:) forControlEvents:UIControlEventTouchDown];
            [tweetsOverlayView addTarget:self action:@selector(tweetsViewTouchUpOutside:) forControlEvents:UIControlEventTouchUpOutside];
            [tweetsOverlayView addTarget:self action:@selector(tweetsViewTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
            
            
            showDetailButton.hidden = NO;
            tmpFrame = showDetailButton.frame;
            tmpFrame.origin.y = viewY;
            viewY += showDetailButton.frame.size.height;
            showDetailButton.frame = tmpFrame;
            [showDetailButton addTarget:self action:@selector(handleShowDetailAction:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        viewY += 2.0;
        
        CGRect occasionSeperatorBottomFrame = occasionSeperatorBottom.frame;
        occasionSeperatorBottomFrame.origin.y = viewY;
        occasionSeperatorBottom.frame = occasionSeperatorBottomFrame;
        
        viewY += 8.0;
        
        CGRect giftRecommandationFrame = giftRecommandationHeaderView.frame;
        giftRecommandationFrame.origin.y = viewY;
        giftRecommandationHeaderView.frame = giftRecommandationFrame;
        viewY += giftRecommandationFrame.size.height;
        viewY += 5.0;
        
        CGRect occasionViewFrame = occasionView.frame;
        occasionViewFrame.size.height = viewY;
        occasionView.frame = occasionViewFrame;
        
        occasionSeperatorBottom.hidden = NO;
        
    }else{
        CGFloat viewY = occasionSeperatorTop.frame.origin.y + 8.0;
        
        
        CGRect giftRecommandationFrame = giftRecommandationHeaderView.frame;
        giftRecommandationFrame.origin.y = viewY;
        giftRecommandationHeaderView.frame = giftRecommandationFrame;
        viewY += giftRecommandationFrame.size.height;
        viewY += 5.0;
        
        CGRect occasionViewFrame = occasionView.frame;
        occasionViewFrame.size.height = viewY;
        occasionView.frame = occasionViewFrame;
        
        occasionSeperatorBottom.hidden = YES;
    }
    
    CGRect backgroundImageViewFrame = backgroundImageView.frame;
    backgroundImageViewFrame.size.height = occasionView.frame.size.height;
    backgroundImageView.frame = backgroundImageViewFrame;
    
    CGRect virtualGiftsViewFrame = virtualGiftsView.frame;
    virtualGiftsViewFrame.origin.y = occasionView.frame.origin.y + occasionView.frame.size.height + 10.0;
    virtualGiftsView.frame = virtualGiftsViewFrame;
    
    CGRect headerViewFrame = headerView.frame;
    headerViewFrame.size.height = occasionView.frame.size.height + virtualGiftsView.frame.size.height + 5.0;
    headerView.frame = headerViewFrame;
    
    HGVirtualGiftsView* gifGiftView = [HGVirtualGiftsView virtualGiftsView];
    CGRect gifGiftViewFrame = gifGiftView.frame;
    gifGiftViewFrame.origin.x = 0.0;
    gifGiftViewFrame.origin.y = 0.0;
    gifGiftView.frame = gifGiftViewFrame;
    gifGiftView.titleLabel.text = @"虚拟礼物";
    gifGiftView.coverImageView.image = [UIImage imageNamed:@"virtual_gift_gif_gift"];
    [gifGiftView addTarget:self action:@selector(handleGIFGiftViewAction:) forControlEvents:UIControlEventTouchUpInside];
    
    
    HGVirtualGiftsView* diyGiftView = [HGVirtualGiftsView virtualGiftsView];
    CGRect diyGiftViewFrame = diyGiftView.frame;
    diyGiftViewFrame.origin.x = gifGiftView.frame.origin.x + gifGiftView.frame.size.width + 10.0;
    diyGiftViewFrame.origin.y = 0.0;
    diyGiftView.frame = diyGiftViewFrame;
    diyGiftView.titleLabel.text = @"自制礼物";
    diyGiftView.coverImageView.image = [UIImage imageNamed:@"virtual_gift_diy_gift"];
    [diyGiftView addTarget:self action:@selector(handleDIYGiftViewAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [virtualGiftsView addSubview:gifGiftView];
    [virtualGiftsView addSubview:diyGiftView];
    
    tableView.tableHeaderView = headerView;
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
    if (imageForShare != nil){
        if ([self.presentedViewController isKindOfClass:[HGAccountViewController class]]){ 
            if (giftCollection.occasion.recipient.recipientNetworkId == NETWORK_SNS_WEIBO){
                if([[WBEngine sharedWeibo] isLoggedIn] == NO){
                    [imageForShare release];
                    imageForShare = nil;
                }
            }else if (giftCollection.occasion.recipient.recipientNetworkId == NETWORK_SNS_RENREN){
                if([[RenrenService sharedRenren] isSessionValid] == NO){
                    [imageForShare release];
                    imageForShare = nil;
                }
            }else{
                [imageForShare release];
                imageForShare = nil;
            }
        } 
    }
    if (tweetListView != nil && tweetListView.hidden == NO) {
        tweetListView.tweets = [NSArray arrayWithObject:giftCollection.occasion.tweet];
    } else if (showDetailButton.hidden == YES && [[giftCollection.occasion.tweet comments] count] > 0) {
        tweetView.showCommentButton = NO;
        tweetView.showForwardButton = NO;
        
        tweetsOverlayView.hidden = NO;
        CGRect tmpFrame = tweetsOverlayView.frame;
        tmpFrame.size.height -= (showDetailButton.frame.size.height + 5);
        tweetsOverlayView.frame = tmpFrame;
        
        [occasionView bringSubviewToFront:tweetsOverlayView];
        
        [tweetsOverlayView addTarget:self action:@selector(tweetsViewTouchDown:) forControlEvents:UIControlEventTouchDown];
        [tweetsOverlayView addTarget:self action:@selector(tweetsViewTouchUpOutside:) forControlEvents:UIControlEventTouchUpOutside];
        [tweetsOverlayView addTarget:self action:@selector(tweetsViewTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        
        showDetailButton.hidden = NO;
        tmpFrame = showDetailButton.frame;
        tmpFrame.origin.y = tweetView.frame.origin.y + tweetView.frame.size.height - showDetailButton.frame.size.height - 5.0;
        showDetailButton.frame = tmpFrame;
        [showDetailButton addTarget:self action:@selector(handleShowDetailAction:) forControlEvents:UIControlEventTouchUpInside];
        [occasionView bringSubviewToFront:showDetailButton];
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (imageForCompose != nil){
        [progressView startAnimation];
        [self performSelector:@selector(performImageComposeAction) withObject:nil afterDelay:0.0];
    }else if (imageForShare != nil){
        [progressView startAnimation];
        [self performSelector:@selector(performShareDIYGiftAction) withObject:nil afterDelay:0.0];

    }
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
    if (progressView != nil){
        [progressView release];
        progressView = nil;
    }
    if (leftBarButtonItem != nil){
        [leftBarButtonItem release];
        leftBarButtonItem = nil;
    }
    [tableView release];
    [userNameLabel release];
    [userDescriptionLabel release];
    [userImageView release];
   
    [occasionView release];
    [occasionImageView release];
    [occasionNameLabel release];
    [occasionDescriptionLabel release];
    [startButton release];
    
    [occasionSeperatorTop release];
    [occasionSeperatorBottom release];

    [giftCollection release];
    
    HGGiftCollectionService* giftCollectionService = [HGGiftCollectionService sharedService];
    
    if (giftCollectionService.delegate == self) {
        giftCollectionService.delegate = nil;
    }
    
    [super dealloc];
}

- (void)tweetsViewTouchDown:(id)sender {
    [tweetsOverlayView setBackgroundColor:[UIColor blackColor]];
    
}

- (void)tweetsViewTouchUpInside:(id)sender {
    [tweetsOverlayView setBackgroundColor:[UIColor clearColor]];
    [self handleShowDetailAction:sender];
}

- (void)tweetsViewTouchUpOutside:(id)sender {
    [tweetsOverlayView setBackgroundColor:[UIColor clearColor]];
}

- (void)handleShowDetailAction:(id)sender {
        HGDebug(@"handleTweetsViewTap");
        if (tweetListView != nil) {
            return;
        }
        
        tweetListView = [HGTweetListView tweetListView];
        tweetListView.delegate = self;
        
        CGRect frame = CGRectMake(10, 460, 300, 460 - 104);
        tweetListView.frame = frame;
    
        tweetListView.showCommentOption = TWEET_LIST_SHOW_COMMENT_OPTION_ONLY_FIRST;
        tweetListView.tweets = [NSArray arrayWithObject:giftCollection.occasion.tweet];
        
        [self.view addSubview:tweetListView];
        
        
        [UIView animateWithDuration:0.3 
                              delay:0.0 
                            options:UIViewAnimationOptionTransitionFlipFromLeft 
                         animations:^{
                             CGRect frame = CGRectMake(10, 104, 300, 460 - 104);
                             tweetListView.frame = frame;
                             tweetListView.alpha = 1.0;
                         }
                         completion:^(BOOL finished) {
                             tableView.hidden = YES;
                             
                         }];
}

- (void)handleBackAction:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)handleStartAction:(id)sender {
    [HGRecipientService sharedService].selectedRecipient = giftCollection.occasion.recipient;
    [HGTrackingService logEvent:kTrackingEventEnterGiftSelection withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"HGOccasionDetailViewController", @"from", giftCollection.occasion.occasionCategory.name, @"occasion", nil]];
    NSDictionary* giftSets = [HGGiftSetsService sharedService].giftSets;
    HGGiftsSelectionViewController* viewContoller = [[HGGiftsSelectionViewController alloc] initWithGiftSets:giftSets currentGiftCategory:nil];
    [self.navigationController pushViewController:viewContoller animated:YES];
    [viewContoller release];
}

- (void)handleGIFGiftViewAction:(id)sender {
    HGDebug(@"handleGIFGiftViewAction");
    [HGRecipientService sharedService].selectedRecipient = giftCollection.occasion.recipient;
    
    HGGIFGiftListViewController* viewController = [[HGGIFGiftListViewController alloc] initWithOccasionGiftCollection:giftCollection];
    [self.navigationController pushViewController:viewController animated:YES];
    [viewController release];
    
    [HGTrackingService logEvent:kTrackingEventEnterGIFGifts withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"HGOccasionDetailViewController", @"from", nil]];
}

- (void)handleDIYGiftViewAction:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] 
                                  initWithTitle:nil
                                  delegate:self 
                                  cancelButtonTitle:@"取消" 
                                  destructiveButtonTitle:nil 
                                  otherButtonTitles:@"从相册选择图片", @"拍摄一张新照片", nil];
    
    [actionSheet showInView:self.view];
    [actionSheet release];
}

- (void) performImagePickAction:(NSNumber*)action{
    if ([action intValue] == 0){
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum] == YES){
            UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
            imagePickerController.navigationBar.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"navigation_background"]];
            imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
            imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            imagePickerController.mediaTypes =  [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
            
            imagePickerController.allowsEditing = NO;
            imagePickerController.delegate = self;
            
            [self presentModalViewController:imagePickerController animated:YES];
            [HGTrackingService logPageView];
        }
    }else{
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == YES){
            UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
            imagePickerController.navigationBar.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"navigation_background"]];
            imagePickerController.modalPresentationStyle = UIModalPresentationFormSheet;
            imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
            imagePickerController.mediaTypes =  [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
            
            imagePickerController.allowsEditing = NO;
            imagePickerController.delegate = self;
            
            [self presentModalViewController:imagePickerController animated:YES];
            [HGTrackingService logPageView];
        }
    }
    [progressView stopAnimation];
}

- (void) performImageComposeAction{
    HGImageComposeViewController* viewContoller = [[HGImageComposeViewController alloc] initWithCanvasImage:imageForCompose];
    viewContoller.delegate = self;
    [self presentModalViewController:viewContoller animated:YES];
    [viewContoller release];
    [HGTrackingService logPageView];
    
    [imageForCompose release];
    imageForCompose = nil;
    [progressView stopAnimation];
}

    
- (void)performShareDIYGiftAction{
    if (giftCollection.occasion.recipient.recipientNetworkId == NETWORK_SNS_WEIBO){
        if([[WBEngine sharedWeibo] isLoggedIn] == NO){
            HGAccountViewController* viewController = [[HGAccountViewController alloc] initWithNibName:@"HGAccountViewController" bundle:nil];
            [self presentModalViewController:viewController animated:YES];
            [viewController release];
            [HGTrackingService logPageView];
            [progressView stopAnimation];
            return;
        }
    }else if (giftCollection.occasion.recipient.recipientNetworkId == NETWORK_SNS_RENREN){
        if([[RenrenService sharedRenren] isSessionValid] == NO){
            HGAccountViewController* viewController = [[HGAccountViewController alloc] initWithNibName:@"HGAccountViewController" bundle:nil];
            [self presentModalViewController:viewController animated:YES];
            [viewController release];
            [HGTrackingService logPageView];
            [progressView stopAnimation];
            return;
        }
    }else{
        [progressView stopAnimation];
        return;
    }
    
    [HGTrackingService logEvent:kTrackingEventEnterShare withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"HGOccasionDetailViewController", @"from", @"shareDIYGift", @"type", giftCollection.occasion.recipient.recipientNetworkId == NETWORK_SNS_WEIBO ? @"weibo" : @"renren", @"network", nil]];
    
    HGShareViewController* viewController = [[HGShareViewController alloc] initWithDIYGift:imageForShare recipient:giftCollection.occasion.recipient];
    [self presentModalViewController:viewController animated:YES];
    [viewController release];
    [HGTrackingService logPageView];
    
    [imageForShare release];
    imageForShare = nil;
    
    [progressView stopAnimation];
}

#pragma mark Table view delegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return ([giftCollection.giftSets count] + 1) / 2;
}

-(UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *viewIdentifier=@"HGOccasionsDetailViewListRowView";
    
    HGOccasionsDetailViewListRowView *cell = [theTableView dequeueReusableCellWithIdentifier:viewIdentifier];
    if (cell == nil) {
        cell = [[[HGOccasionsDetailViewListRowView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:viewIdentifier] autorelease];
        cell.delegate = self;
    }
    
    NSUInteger row = indexPath.row;
    
    NSMutableArray* giftSets = [NSMutableArray arrayWithObject:[giftCollection.giftSets objectAtIndex: 2 * row]];
    if (2 * row + 1 < [giftCollection.giftSets count]) {
        [giftSets addObject:[giftCollection.giftSets objectAtIndex: 2 * row + 1]];
    }
    
    cell.giftSets = giftSets;

    return cell;

}

- (void)dragToUpdateTableView:(HGDragToUpdateTableView *)dragToUpdateTableView didRequestTopUpdate:(HGDragToUpdateView *)topDragToUpdateView {
    HGDebug(@"didRequestTopUpdate");
}

- (void)dragToUpdateTableView:(HGDragToUpdateTableView *)dragToUpdateTableView didRequestBottomUpdate:(HGDragToUpdateView *)bottomDragToUpdateView {
     HGDebug(@"bottomDragToUpdateView");
    [HGGiftCollectionService sharedService].delegate = self;
    
    int offset = [giftCollection.giftSets count];
    int networkId = giftCollection.occasion.recipient.recipientNetworkId;
    NSString* profileId = giftCollection.occasion.recipient.recipientProfileId;
    NSString* occasionType = giftCollection.occasion.occasionCategory.identifier;
    NSString* tagId = giftCollection.occasion.occasionTag.identifier;
    
    [[HGGiftCollectionService sharedService] requestGiftsForOccasion:occasionType
                                                        andNetworkId:networkId
                                                        andProfileId:profileId 
                                                          withOffset:offset
                                                        andTagId:tagId];
    
    [HGTrackingService logEvent:kTrackingEventOccasionDetailLoadMoreGifts withParameters:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:offset], @"offset", nil]];
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

#pragma mark - HGGiftCollectionServiceDelegate
- (void)giftCollectionService:(HGGiftCollectionService *)giftCollectionService didRequestGiftsForOccasionSucceed:(NSArray*)giftsForOccasion {
    NSMutableArray* newGiftSets = [[NSMutableArray alloc] initWithArray:giftCollection.giftSets];
    [newGiftSets addObjectsFromArray:giftsForOccasion];
    giftCollection.giftSets = newGiftSets;
    [newGiftSets release];
    [tableView reloadData];
    tableView.bottomDragToUpdateRunning = NO;
    if ([giftsForOccasion count] < 6) {
        tableView.bottomDragToUpdateVisbile = NO;
    }
}

- (void)giftCollectionService:(HGGiftCollectionService *)giftCollectionService didRequestGiftsForOccasionFail:(NSString*)error {
    HGDebug(@"didRequestGiftsForOccasionFail");
    tableView.bottomDragToUpdateRunning = NO;
}

#pragma mark - HGOccasionsDetailViewListRowViewDelegate
- (void)handleOccasionsDetailViewListRowViewGiftSelected:(HGGiftSet*)giftSet {
    [HGRecipientService sharedService].selectedRecipient = giftCollection.occasion.recipient;
    
    if ([giftSet.gifts count] == 1) {
        HGGift* theGift = [giftSet.gifts objectAtIndex:0];
        [HGTrackingService logEvent:kTrackingEventEnterGiftDetail withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"HGMainViewController", @"from", theGift.identifier, @"productId", giftCollection.occasion.occasionCategory.name, @"occasion", nil]];
        
        HGGiftDetailViewController* viewContoller = [[HGGiftDetailViewController alloc] initWithGift:theGift];
        [self.navigationController pushViewController:viewContoller animated:YES];
        [viewContoller release];
    }else{
        [HGTrackingService logEvent:kTrackingEventEnterGiftGroupDetail withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"HGMainViewController", @"from", giftCollection.occasion.occasionCategory.name, @"occasion", nil]];
        
        HGGiftSetDetailViewController* viewContoller = [[HGGiftSetDetailViewController alloc] initWithGiftSet:giftSet];
        [self.navigationController pushViewController:viewContoller animated:YES];
        [viewContoller release];
    }
}

#pragma mark - UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)theNavigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex != 2){
        [progressView startAnimation];
        if (imageForCompose != nil){
            [imageForCompose release];
            imageForCompose = nil;
        }
        [self performSelector:@selector(performImagePickAction:) withObject:[NSNumber numberWithInt:buttonIndex] afterDelay:0.0];
    }
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    [picker dismissModalViewControllerAnimated:YES];
	imageForCompose = [[info objectForKey:@"UIImagePickerControllerOriginalImage"] retain];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissModalViewControllerAnimated:YES];
}

#pragma mark - HGImageComposeViewControllerDelegate 
- (void)imageComposeViewController:(HGImageComposeViewController *)imageComposeViewController didFinishComposeImage:(UIImage*)image{
    imageForShare = [image retain];
}

- (void)imageComposeViewControllerDidCancel:(HGImageComposeViewController *)imageComposeViewController{
    
}


- (void)tweetListView:(HGTweetListView *)theTweetListView didCloseTweetListView:(NSString*)result {
    tableView.hidden = NO;
    if (tweetListView != nil) {
        [UIView animateWithDuration:0.3 
                              delay:0.0 
                            options:UIViewAnimationOptionTransitionFlipFromLeft 
                         animations:^{
                             CGRect tmp = tweetListView.frame;
                             tmp.origin.y = 460;
                             tweetListView.frame = tmp;
                         }
                         completion:^(BOOL finished) {
                             [tweetListView removeFromSuperview];
                             tweetListView = nil;
                         }];
    }
}

- (void)commentTweet:(HGTweet *)tweet {
    [HGTrackingService logEvent:kTrackingEventEnterShare withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"HGOccasionDetailViewController", @"from", @"commentFriendEmotion", @"type", giftCollection.occasion.recipient.recipientNetworkId == NETWORK_SNS_WEIBO ? @"weibo" : @"renren", @"network", nil]];
    
    HGShareViewController* viewController = [[HGShareViewController alloc] initWithTweetForComment:tweet];
    [self presentModalViewController:viewController animated:YES];
    [viewController release];
    [HGTrackingService logPageView];
}

- (void)forwardTweet:(HGTweet *)tweet {
    [HGTrackingService logEvent:kTrackingEventEnterShare withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"HGOccasionDetailViewController", @"from", @"forwardFriendEmotion", @"type", giftCollection.occasion.recipient.recipientNetworkId == NETWORK_SNS_WEIBO ? @"weibo" : @"renren", @"network", nil]];
    
    HGShareViewController* viewController = [[HGShareViewController alloc] initWithTweetForForward:tweet];
    [self presentModalViewController:viewController animated:YES];
    [viewController release];
    [HGTrackingService logPageView];
}

- (void)tweetListView:(HGTweetListView *)tweetListView didCommentTweetAction:(HGTweet *)tweet {
    [self commentTweet:tweet];
}


-(void)tweetView:(HGTweetView*)tweetView didCommentTweetAction:(HGTweet*)tweet {
    [self commentTweet:tweet];
}

-(void)tweetView:(HGTweetView*)tweetView didForwardTweetAction:(HGTweet*)tweet {
    [self forwardTweet:tweet];
}

- (void)tweetListView:(HGTweetListView *)tweetListView didForwardTweetAction:(HGTweet *)tweet {
    [self forwardTweet:tweet];
}

@end

