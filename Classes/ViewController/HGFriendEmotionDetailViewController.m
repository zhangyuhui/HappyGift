//
//  HGFriendEmotionDetailViewController.m
//  HappyGift
//
//  Created by Yujian Weng on 12-7-10.
//  Copyright 2011 Ztelic Inc Inc. All rights reserved.
//

#import "HGFriendEmotionDetailViewController.h"
#import "HappyGiftAppDelegate.h"
#import "HGConstants.h"
#import "HGProgressView.h"
#import "HGImageService.h"
#import "HGGiftDetailViewController.h"
#import "HGGiftSet.h"
#import "HGGiftsSelectionViewController.h"
#import "HGGiftSetDetailViewController.h"
#import "HGGiftSetsService.h"
#import "UIBarButtonItem+Addition.h"
#import "UIImage+Addition.h"
#import <QuartzCore/QuartzCore.h>
#import "HGRecipient.h"
#import "HGTrackingService.h"
#import "HGRecipientService.h"
#import "HGUserImageView.h"
#import "HGUtility.h"
#import "HGOccasionsDetailViewListRowView.h"
#import "HGDragToUpdateTableView.h"
#import "HGDefines.h"
#import "HGLogging.h"
#import "HGGift.h"
#import "HGFriendEmotion.h"
#import "HGFriendEmotionService.h"
#import "HGTweet.h"
#import "HGTweetView.h"
#import "HGTweetListView.h"
#import "HGVirtualGiftsView.h"
#import "HGGIFGiftListViewController.h"
#import "HGImageComposeViewController.h"
#import "WBEngine.h"
#import "RenrenService.h"
#import "HGAccountViewController.h"
#import "HGShareViewController.h"
#import "HGTweetCommentService.h"

@interface HGFriendEmotionDetailViewController()<UIScrollViewDelegate, UITableViewDelegate, HGProgressViewDelegate, HGFriendEmotionServiceDelegate, HGOccasionsDetailViewListRowViewDelegate, UIGestureRecognizerDelegate, HGTweetListViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, HGImageComposeViewControllerDelegate, UIActionSheetDelegate>
  
@end

@implementation HGFriendEmotionDetailViewController

- (id)initWithFriendEmotion:(HGFriendEmotion*)theFriendEmotion {
    self = [super initWithNibName:@"HGFriendEmotionDetailViewController" bundle:nil];
    if (self){
        friendEmotion = [theFriendEmotion retain];
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
    
    progressView = [[HGProgressView progressView:self.view.frame] retain];
    [self.view addSubview:progressView];
    progressView.hidden = YES;
    
    showMoreTweetsButton.titleLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:[HappyGiftAppDelegate fontSizeSmall]];
    
    [showMoreTweetsButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [showMoreTweetsButton setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    [showMoreTweetsButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
    
    [showMoreTweetsButton addTarget:self action:@selector(handleShowMoreTweetsButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    
    userNameLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:[HappyGiftAppDelegate fontSizeNormal]];
    userNameLabel.textColor = [UIColor blackColor];
    userNameLabel.text = friendEmotion.recipient.recipientName;
    
    userDescriptionLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeNormal]];
    userDescriptionLabel.textColor = [UIColor darkGrayColor];
    
    giftRecommendationLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeNormal]];
    giftRecommendationLabel.textColor = UIColorFromRGB(0xd53d3b);
    giftRecommendationLabel.text = [NSString stringWithFormat:@"为%@推荐的礼物：", friendEmotion.recipient.recipientName];
    
    startButton.titleLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeNormal]];
    startButton.titleLabel.minimumFontSize = 14;
    startButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    [startButton setTitle:@"更多礼物" forState:UIControlStateNormal];
    [startButton addTarget:self action:@selector(handleStartAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [userImageView updateUserImageViewWithRecipient:friendEmotion.recipient];
    [userImageView removeTagImage];
   
    astroTrendSummaryLabel.text = friendEmotion.emotionType == kFriendEmotionTypePositive ? @"正能量" : @"负能量";
    astroTrendSummaryLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeNormal]];
    astroTrendSummaryLabel.textColor = [UIColor blackColor];
    
    NSArray* positiveTemplates = [NSArray arrayWithObjects:@"%@最近连续发了%d篇微博，正能量满格，快送TA礼物，跟TA一起传递正能量！", @"逆天了，%@最近连续发了%d篇微博，正能量爆增，快送TA礼物，跟TA一起传递正能量！", @"嫉妒啊，%@最近连续发了%d篇正能量微博，正能量开了外挂，随便送点啥吧，让TA一起分享正能量！", nil];
    NSArray* negativeTemplates = [NSArray arrayWithObjects:@"%@最近连续发了%d篇微博，负能量满格，快送TA礼物，帮TA摆脱负能量！", @"挺住啊，%@最近连续发了%d篇微博，负能量缠身，快送TA礼物，一起远离负能量！", @"住手啊，%@最近连续发了%d篇负能量微博，负能量已经占领全身，快送TA祝福，帮TA打跑负能量！", nil];
    
    NSString* positiveDescriptionTemplate;
    NSString* negativeDescriptionTemplate;
    if (friendEmotion.score == 10.0) {
        positiveDescriptionTemplate = [positiveTemplates objectAtIndex:0];
        negativeDescriptionTemplate = [negativeTemplates objectAtIndex:0];
    } else if (friendEmotion.score >= 6.0) {
        positiveDescriptionTemplate = [positiveTemplates objectAtIndex:1];
        negativeDescriptionTemplate = [negativeTemplates objectAtIndex:1];
    } else {
        positiveDescriptionTemplate = [positiveTemplates objectAtIndex:2];
        negativeDescriptionTemplate = [negativeTemplates objectAtIndex:2];
    }
    
    emotionDescriptionLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeNormal]];
    emotionDescriptionLabel.textColor = [UIColor darkGrayColor];
    emotionDescriptionLabel.numberOfLines = 0;
    
    if (friendEmotion.emotionType == kFriendEmotionTypePositive) {
        astroTrendImageView.image = [UIImage imageNamed:@"friend_emotion_positive_icon"];
        emotionDescriptionLabel.text = [NSString stringWithFormat:positiveDescriptionTemplate, friendEmotion.recipient.recipientName, [friendEmotion.tweets count]];
    } else {
        astroTrendImageView.image = [UIImage imageNamed:@"friend_emotion_negative_icon"];
        emotionDescriptionLabel.text = [NSString stringWithFormat:negativeDescriptionTemplate, friendEmotion.recipient.recipientName, [friendEmotion.tweets count]];
    }
    
    emotionScoreBarImageView.image = [[UIImage imageNamed:@"friend_emotion_score_bar_red"] stretchableImageWithLeftCapWidth:8.0 topCapHeight:4.0];
    CGRect tmpFrame = emotionScoreBarImageView.frame;
    tmpFrame.size.width = friendEmotion.score / 10.0 * 69;
    if (tmpFrame.size.width < 10) {
        tmpFrame.size.width = 10;
    }
    emotionScoreBarImageView.frame = tmpFrame;
    
    //69
    tmpFrame = emotionDescriptionLabel.frame;
    CGSize descriptionSize = [emotionDescriptionLabel.text sizeWithFont:emotionDescriptionLabel.font constrainedToSize:CGSizeMake(emotionDescriptionLabel.frame.size.width, 100.0)];
    tmpFrame.size.height = descriptionSize.height;
    emotionDescriptionLabel.frame = tmpFrame;
    
    tweetsOverlayView.frame = emotionDescriptionLabel.frame;
    [tweetsOverlayView addTarget:self action:@selector(tweetsViewTouchDown:) forControlEvents:UIControlEventTouchDown];
    [tweetsOverlayView addTarget:self action:@selector(tweetsViewTouchUpOutside:) forControlEvents:UIControlEventTouchUpOutside];
    [tweetsOverlayView addTarget:self action:@selector(tweetsViewTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
     
    
    CGFloat viewY = emotionDescriptionLabel.frame.origin.y + emotionDescriptionLabel.frame.size.height;

    tmpFrame = showMoreTweetsButton.frame;
    tmpFrame.origin.y = viewY;
    viewY += showMoreTweetsButton.frame.size.height;
    
    showMoreTweetsButton.frame = tmpFrame;
    
    CGRect tmpRect = bottomSeperator.frame;
    tmpRect.origin.y = viewY + 2;
    bottomSeperator.frame = tmpRect;
    
    viewY += 5.0;
    CGRect giftRecommendationFrame = giftRecommendationHeaderView.frame;
    giftRecommendationFrame.origin.y = viewY + 3.0;
    giftRecommendationHeaderView.frame = giftRecommendationFrame;
    viewY += giftRecommendationFrame.size.height;
    viewY += 5.0;
    
    CGRect astroTrendViewFrame = astroTrendView.frame;
    astroTrendViewFrame.size.height = viewY;
    astroTrendView.frame = astroTrendViewFrame;
       
    CGRect backgroundImageViewFrame = backgroundImageView.frame;
    backgroundImageViewFrame.size.height = astroTrendView.frame.size.height;
    backgroundImageView.frame = backgroundImageViewFrame;
    
    CGRect virtualGiftsViewFrame = virtualGiftsView.frame;
    virtualGiftsViewFrame.origin.y = astroTrendView.frame.origin.y + astroTrendView.frame.size.height + 10.0;
    virtualGiftsView.frame = virtualGiftsViewFrame;
    
    CGRect headerViewFrame = headerView.frame;
    headerViewFrame.size.height = astroTrendView.frame.size.height + virtualGiftsView.frame.size.height + 5.0;
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
            if (friendEmotion.recipient.recipientNetworkId == NETWORK_SNS_WEIBO){
                if([[WBEngine sharedWeibo] isLoggedIn] == NO){
                    [imageForShare release];
                    imageForShare = nil;
                }
            }else if (friendEmotion.recipient.recipientNetworkId == NETWORK_SNS_RENREN){
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
        tweetListView.tweets = friendEmotion.tweets;
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
   
    [astroTrendView release];
    [astroTrendImageView release];
    [astroTrendSummaryLabel release];
    [startButton release];
    
    [topSeperator release];
    [bottomSeperator release];

    [friendEmotion release];
    
    HGFriendEmotionService* astroTrendService = [HGFriendEmotionService sharedService];
    if (astroTrendService.delegate == self) {
        astroTrendService.delegate = nil;
    }
    
    [super dealloc];
}

- (void)handleBackAction:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)handleStartAction:(id)sender {
    [HGRecipientService sharedService].selectedRecipient = friendEmotion.recipient;
    NSDictionary* giftSets = [HGGiftSetsService sharedService].giftSets;
    HGGiftsSelectionViewController* viewContoller = [[HGGiftsSelectionViewController alloc] initWithGiftSets:giftSets currentGiftCategory:nil];
    [self.navigationController pushViewController:viewContoller animated:YES];
    [viewContoller release];
}

- (void)tweetsViewTouchDown:(id)sender {
    [tweetsOverlayView setBackgroundColor:[UIColor blackColor]];

}

- (void)tweetsViewTouchUpInside:(id)sender {
    [tweetsOverlayView setBackgroundColor:[UIColor clearColor]];
    [self handleTweetsViewTap:sender];
}

- (void)tweetsViewTouchUpOutside:(id)sender {
    [tweetsOverlayView setBackgroundColor:[UIColor clearColor]];
}

- (void)handleShowMoreTweetsButtonTouchUpInside:(id)sender {
    [self handleTweetsViewTap:sender];
}

- (void)handleTweetsViewTap:(id)sender {
    HGDebug(@"handleTweetsViewTap");
    if (tweetListView != nil) {
        return;
    }
    
    tweetListView = [HGTweetListView tweetListView];
    tweetListView.delegate = self;
    
    CGRect frame = CGRectMake(10, 460, 300, 460 - 104);
    tweetListView.frame = frame;
    tweetListView.showCommentOption = TWEET_LIST_SHOW_COMMENT_OPTION_ALL;
    tweetListView.tweets = friendEmotion.tweets;
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

#pragma mark - HGFriendEmotionServiceDelegate
- (void)friendEmotionService:(HGFriendEmotionService *)friendEmotionService didRequestFriendEmotionForFriendSucceed:(HGFriendEmotion*)theFriendEmotion {
    NSMutableArray* newGiftSets = [[NSMutableArray alloc] initWithArray:friendEmotion.giftSets];
    [newGiftSets addObjectsFromArray:theFriendEmotion.giftSets];
    friendEmotion.giftSets = newGiftSets;
    [newGiftSets release];
    
    [tableView reloadData];
    tableView.bottomDragToUpdateRunning = NO;
    
    if ([theFriendEmotion.giftSets count] < 6) {
        tableView.bottomDragToUpdateVisbile = NO;
    }
}

- (void)friendEmotionService:(HGFriendEmotionService *)friendEmotionService didRequestFriendEmotionForFriendFail:(NSString*)error {
    HGDebug(@"didRequestFriendEmotionForFriendFail");
    tableView.bottomDragToUpdateRunning = NO;
}

#pragma mark Table view delegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return ([friendEmotion.giftSets count] + 1) / 2;
}

-(UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *viewIdentifier=@"HGOccasionsDetailViewListRowView";
    
    HGOccasionsDetailViewListRowView *cell = [theTableView dequeueReusableCellWithIdentifier:viewIdentifier];
    if (cell == nil) {
        cell = [[[HGOccasionsDetailViewListRowView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:viewIdentifier] autorelease];
        cell.delegate = self;
    }
    
    NSUInteger row = indexPath.row;
    
    NSMutableArray* giftSets = [NSMutableArray arrayWithObject:[friendEmotion.giftSets objectAtIndex: 2 * row]];
    if (2 * row + 1 < [friendEmotion.giftSets count]) {
        [giftSets addObject:[friendEmotion.giftSets objectAtIndex: 2 * row + 1]];
    }
    
    cell.giftSets = giftSets;

    return cell;

}

- (void)dragToUpdateTableView:(HGDragToUpdateTableView *)dragToUpdateTableView didRequestTopUpdate:(HGDragToUpdateView *)topDragToUpdateView {
    HGDebug(@"didRequestTopUpdate");
}

- (void)dragToUpdateTableView:(HGDragToUpdateTableView *)dragToUpdateTableView didRequestBottomUpdate:(HGDragToUpdateView *)bottomDragToUpdateView {
     HGDebug(@"bottomDragToUpdateView");
    
    int networkId = friendEmotion.recipient.recipientNetworkId;
    NSString* profileId = friendEmotion.recipient.recipientProfileId;
    int offset = [friendEmotion.giftSets count];
    int count = 6;
    
    HGFriendEmotionService* friendEmotionService = [HGFriendEmotionService sharedService];
    friendEmotionService.delegate = self;
    [friendEmotionService requestMoreFriendEmotionForFriend:networkId andProfileId:profileId withOffset:offset andCount:count];
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

#pragma mark - HGOccasionsDetailViewListRowViewDelegate
- (void)handleOccasionsDetailViewListRowViewGiftSelected:(HGGiftSet*)giftSet {
    [HGRecipientService sharedService].selectedRecipient = friendEmotion.recipient;
    
    if ([giftSet.gifts count] == 1) {
        HGGift* theGift = [giftSet.gifts objectAtIndex:0];
        
        HGGiftDetailViewController* viewContoller = [[HGGiftDetailViewController alloc] initWithGift:theGift];
        [self.navigationController pushViewController:viewContoller animated:YES];
        [viewContoller release];
    } else {
        
        HGGiftSetDetailViewController* viewContoller = [[HGGiftSetDetailViewController alloc] initWithGiftSet:giftSet];
        [self.navigationController pushViewController:viewContoller animated:YES];
        [viewContoller release];
    }
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

- (void)tweetListView:(HGTweetListView *)tweetListView didCommentTweetAction:(HGTweet *)tweet {
    [HGTrackingService logEvent:kTrackingEventEnterShare withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"HGFriendEmotionDetailViewController", @"from", @"commentFriendEmotion", @"type", friendEmotion.recipient.recipientNetworkId == NETWORK_SNS_WEIBO ? @"weibo" : @"renren", @"network", nil]];
    
    HGShareViewController* viewController = [[HGShareViewController alloc] initWithTweetForComment:tweet];
    [self presentModalViewController:viewController animated:YES];
    [viewController release];
    [HGTrackingService logPageView];
}

- (void)tweetListView:(HGTweetListView *)tweetListView didForwardTweetAction:(HGTweet *)tweet {
    [HGTrackingService logEvent:kTrackingEventEnterShare withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"HGFriendEmotionDetailViewController", @"from", @"forwardFriendEmotion", @"type", friendEmotion.recipient.recipientNetworkId == NETWORK_SNS_WEIBO ? @"weibo" : @"renren", @"network", nil]];
    
    HGShareViewController* viewController = [[HGShareViewController alloc] initWithTweetForForward:tweet];
    [self presentModalViewController:viewController animated:YES];
    [viewController release];
    [HGTrackingService logPageView];
}

- (void)handleGIFGiftViewAction:(id)sender {
    HGDebug(@"handleGIFGiftViewAction");
    [HGRecipientService sharedService].selectedRecipient = friendEmotion.recipient;
    
    HGGIFGiftListViewController* viewController = [[HGGIFGiftListViewController alloc] initWithFriendEmotion:friendEmotion];
    [self.navigationController pushViewController:viewController animated:YES];
    [viewController release];
    
    [HGTrackingService logEvent:kTrackingEventEnterGIFGifts withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"HGFriendEmotionDetailViewController", @"from", nil]];
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
            imagePickerController.modalPresentationStyle = UIModalPresentationFormSheet;
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
    if (friendEmotion.recipient.recipientNetworkId == NETWORK_SNS_WEIBO){
        if([[WBEngine sharedWeibo] isLoggedIn] == NO){
            HGAccountViewController* viewController = [[HGAccountViewController alloc] initWithNibName:@"HGAccountViewController" bundle:nil];
            [self presentModalViewController:viewController animated:YES];
            [viewController release];
            [HGTrackingService logPageView];
            [progressView stopAnimation];
            return;
        }
    }else if (friendEmotion.recipient.recipientNetworkId == NETWORK_SNS_RENREN){
        if([[RenrenService sharedRenren] isSessionValid] == NO){
            HGAccountViewController* viewController = [[HGAccountViewController alloc] initWithNibName:@"HGAccountViewController" bundle:nil];
            [self presentModalViewController:viewController animated:YES];
            [viewController release];
            [HGTrackingService logPageView];
            [progressView stopAnimation];
            return;
        }
    }else{
        [imageForShare release];
        imageForShare = nil;
        [progressView stopAnimation];
        return;
    }
    
    [HGTrackingService logEvent:kTrackingEventEnterShare withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"HGFriendEmotionDetailViewController", @"from", @"shareDIYGift", @"type", friendEmotion.recipient.recipientNetworkId == NETWORK_SNS_WEIBO ? @"weibo" : @"renren", @"network", nil]];
    
    HGShareViewController* viewController = [[HGShareViewController alloc] initWithDIYGift:imageForShare recipient:friendEmotion.recipient];
    [self presentModalViewController:viewController animated:YES];
    [viewController release];
    [HGTrackingService logPageView];
    
    [imageForShare release];
    imageForShare = nil;
    
    [progressView stopAnimation];
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
@end

