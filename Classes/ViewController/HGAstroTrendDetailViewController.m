//
//  HGAstroTrendDetailViewController.m
//  HappyGift
//
//  Created by Yujian Weng on 12-7-5.
//  Copyright 2011 Ztelic Inc Inc. All rights reserved.
//

#import "HGAstroTrendDetailViewController.h"
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
#import "HGAstroTrend.h"
#import "HGAstroTrendService.h"
#import "WBEngine.h"
#import "HGSong.h"
#import "HGWish.h"
#import "HGRecipient.h"
#import "HGShareViewController.h"
#import "HGAccountViewController.h"
#import "HGVirtualGiftsView.h"
#import "HGGIFGiftListViewController.h"
#import "HGImageComposeViewController.h"

@interface HGAstroTrendDetailViewController()<UIScrollViewDelegate, UITableViewDelegate, HGProgressViewDelegate, HGAstroTrendServiceDelegate, HGOccasionsDetailViewListRowViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, HGImageComposeViewControllerDelegate, UIActionSheetDelegate>
  
@end

@implementation HGAstroTrendDetailViewController

- (id)initWithAstroTrend:(HGAstroTrend*)theAstroTrend {
    self = [super initWithNibName:@"HGAstroTrendDetailViewController" bundle:nil];
    if (self){
        astroTrend = [theAstroTrend retain];
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
    
    userNameLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:[HappyGiftAppDelegate fontSizeNormal]];
    userNameLabel.textColor = [UIColor blackColor];
    userNameLabel.text = astroTrend.recipient.recipientName;
    
    userDescriptionLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeNormal]];
    userDescriptionLabel.textColor = [UIColor darkGrayColor];
    
    giftRecommendationLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeNormal]];
    giftRecommendationLabel.textColor = UIColorFromRGB(0xd53d3b);
    giftRecommendationLabel.text = [NSString stringWithFormat:@"为%@推荐的礼物：", astroTrend.recipient.recipientName];
    
    startButton.titleLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeNormal]];
    startButton.titleLabel.minimumFontSize = 14;
    startButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    [startButton setTitle:[NSString stringWithFormat:@"更多礼物", astroTrend.recipient.recipientName] forState:UIControlStateNormal];
    [startButton addTarget:self action:@selector(handleStartAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [userImageView updateUserImageViewWithRecipient:astroTrend.recipient];
    [userImageView removeTagImage];
   
    NSDictionary* astroConfig = [[[HGAstroTrendService sharedService] astroConfig] objectForKey:astroTrend.astroId];
    NSDictionary* trendConfig = [[[HGAstroTrendService sharedService] trendConfig] objectForKey:astroTrend.trendId];
    
    NSString* astroImage = [astroConfig objectForKey:@"kAstroIcon"];
    astroImageView.image = [UIImage imageNamed:astroImage];
    
    astroNameLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeNormal]];
    astroNameLabel.textColor = [UIColor darkGrayColor];
    astroNameLabel.text = [astroConfig objectForKey:@"kAstroName"];
    
    trendNameLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:[HappyGiftAppDelegate fontSizeLarge]];
    trendNameLabel.textColor = [UIColor blackColor];
    trendNameLabel.text = [trendConfig objectForKey:@"kTrendName"];
    
    NSString* goodOrBadTrendImage;
    if (astroTrend.trendScore >= 3) {
        goodOrBadTrendImage = [trendConfig objectForKey:@"kGoodTrendIcon"];
    } else {
        goodOrBadTrendImage = [trendConfig objectForKey:@"kBadTrendIcon"];
    }
    astroTrendImageView.image = [UIImage imageNamed:goodOrBadTrendImage];
    
    astroTrendSummaryLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeNormal]];
    astroTrendSummaryLabel.textColor = [UIColor darkGrayColor];
    astroTrendSummaryLabel.adjustsFontSizeToFitWidth = NO;
    astroTrendSummaryLabel.numberOfLines = 0;
    astroTrendSummaryLabel.text = astroTrend.trendSummary;
    
    CGRect astroTrendSummaryLabelFrame = astroTrendSummaryLabel.frame;
    CGSize astroTrendSummaryLabelSize = [astroTrendSummaryLabel.text sizeWithFont:astroTrendSummaryLabel.font constrainedToSize:CGSizeMake(astroTrendSummaryLabelFrame.size.width, 60.0)];
    astroTrendSummaryLabelFrame.size.height = astroTrendSummaryLabelSize.height;
    astroTrendSummaryLabelFrame.origin.y = 5 + (60 - astroTrendSummaryLabelFrame.size.height) / 2;
    
    astroTrendSummaryLabel.frame = astroTrendSummaryLabelFrame;
    
    CGRect tmpRect = trendNameLabel.frame;
    tmpRect.origin.y = topSeperator.frame.origin.y + 5.0;
    trendNameLabel.frame = tmpRect;
    
    CGFloat viewX = 10.0;
    CGFloat viewY = trendNameLabel.frame.origin.y + trendNameLabel.frame.size.height + 5.0;
    CGFloat viewWidth = 280.0;
    
    astroTrendDetailLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeNormal]];
    astroTrendDetailLabel.numberOfLines = 0;
    astroTrendDetailLabel.textColor = [UIColor darkGrayColor];   
    astroTrendDetailLabel.frame = CGRectMake(viewX, viewY, viewWidth, 20.0);
    astroTrendDetailLabel.text = astroTrend.trendDetail;
    
    CGRect astroTrendDetailLabelFrame = astroTrendDetailLabel.frame;
    CGSize astroTrendDetailLabelFrameSize = [astroTrendDetailLabel.text sizeWithFont:astroTrendDetailLabel.font constrainedToSize:CGSizeMake(viewWidth, 160.0)];
    astroTrendDetailLabelFrame.size.height = astroTrendDetailLabelFrameSize.height;
    astroTrendDetailLabel.frame = astroTrendDetailLabelFrame;
    
    viewY += astroTrendDetailLabel.frame.size.height;
    viewY += 5.0;
    
    [shareAstroTrendButton addTarget:self action:@selector(handleForwardButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [shareAstroTrendButton.titleLabel setFont:[UIFont fontWithName:[HappyGiftAppDelegate boldFontName] size:[HappyGiftAppDelegate fontSizeSmall]]];
    CGRect tmpFrame = shareAstroTrendButton.frame;
    tmpFrame.origin.y = viewY;
    shareAstroTrendButton.frame = tmpFrame;
    viewY += shareAstroTrendButton.frame.size.height + 5.0;
    
    
    tmpRect = bottomSeperator.frame;
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
       
    CGRect virtualGiftsViewFrame = virtualGiftsView.frame;
    virtualGiftsViewFrame.origin.y = astroTrendView.frame.origin.y + astroTrendView.frame.size.height + 10.0;
    virtualGiftsView.frame = virtualGiftsViewFrame;
    
    CGRect headerViewFrame = headerView.frame;
    headerViewFrame.size.height = astroTrendView.frame.size.height + virtualGiftsView.frame.size.height + 5.0;
    headerView.frame = headerViewFrame;
    
    CGRect backgroundImageViewFrame = backgroundImageView.frame;
    backgroundImageViewFrame.size.height = astroTrendView.frame.size.height;
    backgroundImageView.frame = backgroundImageViewFrame;
    
    
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
    
    giftTableView.tableHeaderView = headerView;
    giftTableView.dragToUpdateDelegate = self;
    giftTableView.bottomDragToUpdateVisbile = YES;
    giftTableView.topDragToUpdateVisbile = NO;
    giftTableView.topDragToUpdateRunning = NO;
    giftTableView.bottomDragToUpdateRunning = NO;
    giftTableView.topDragToUpdateDate = nil;
    giftTableView.bottomDragToUpdateDate = nil;
    [giftTableView setShowBottomUpdateDateLabel:NO];
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
            if (astroTrend.recipient.recipientNetworkId == NETWORK_SNS_WEIBO){
                if([[WBEngine sharedWeibo] isLoggedIn] == NO){
                    [imageForShare release];
                    imageForShare = nil;
                }
            }else if (astroTrend.recipient.recipientNetworkId == NETWORK_SNS_RENREN){
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
    [giftTableView release];
    [userNameLabel release];
    [userDescriptionLabel release];
    [userImageView release];
   
    [astroTrendView release];
    [astroTrendImageView release];
    [astroTrendSummaryLabel release];
    [astroTrendDetailLabel release];
    [startButton release];
    
    [topSeperator release];
    [bottomSeperator release];

    [astroTrend release];
    
    HGAstroTrendService* astroTrendService = [HGAstroTrendService sharedService];
    if (astroTrendService.delegate == self) {
        astroTrendService.delegate = nil;
    }
    
    [super dealloc];
}

- (void)handleForwardButtonAction:(id)sender {
    HGDebug(@"handleForwardButtonAction");
    
    [HGTrackingService logEvent:kTrackingEventEnterShare withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"HGAstroTrendDetailViewController", @"from", @"shareAstroTrend", @"type", astroTrend.recipient.recipientNetworkId == NETWORK_SNS_WEIBO ? @"weibo" : @"renren", @"network", nil]];
    
    HGShareViewController* viewController = [[HGShareViewController alloc] initWithAstroTrend:astroTrend];
    [self presentModalViewController:viewController animated:YES];
    [viewController release];
    [HGTrackingService logPageView];
}

- (void)handleBackAction:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)handleStartAction:(id)sender {
    [HGRecipientService sharedService].selectedRecipient = astroTrend.recipient;
    NSDictionary* giftSets = [HGGiftSetsService sharedService].giftSets;
    HGGiftsSelectionViewController* viewContoller = [[HGGiftsSelectionViewController alloc] initWithGiftSets:giftSets currentGiftCategory:nil];
    [self.navigationController pushViewController:viewContoller animated:YES];
    [viewContoller release];
}

#pragma mark Table view delegate

-(NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section {
    return ([astroTrend.giftSets count] + 1) / 2;
}

-(UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *viewIdentifier=@"HGOccasionsDetailViewListRowView";
    
    HGOccasionsDetailViewListRowView *cell = [theTableView dequeueReusableCellWithIdentifier:viewIdentifier];
    if (cell == nil) {
        cell = [[[HGOccasionsDetailViewListRowView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:viewIdentifier] autorelease];
        cell.delegate = self;
    }
    
    NSUInteger row = indexPath.row;
    
    NSMutableArray* giftSets = [NSMutableArray arrayWithObject:[astroTrend.giftSets objectAtIndex: 2 * row]];
    if (2 * row + 1 < [astroTrend.giftSets count]) {
        [giftSets addObject:[astroTrend.giftSets objectAtIndex: 2 * row + 1]];
    }
    
    cell.giftSets = giftSets;
    
    return cell;
}


- (void)dragToUpdateTableView:(HGDragToUpdateTableView *)dragToUpdateTableView didRequestTopUpdate:(HGDragToUpdateView *)topDragToUpdateView {
    HGDebug(@"didRequestTopUpdate");
}

- (void)dragToUpdateTableView:(HGDragToUpdateTableView *)dragToUpdateTableView didRequestBottomUpdate:(HGDragToUpdateView *)bottomDragToUpdateView {
     HGDebug(@"bottomDragToUpdateView");
    
    int networkId = astroTrend.recipient.recipientNetworkId;
    NSString* profileId = astroTrend.recipient.recipientProfileId;
    int offset = [astroTrend.giftSets count];
    int count = 6;
    
    HGAstroTrendService* astroTrendService = [HGAstroTrendService sharedService];
    astroTrendService.delegate = self;
    [astroTrendService requestMoreAstroTrendForFriend:networkId andProfileId:profileId withOffset:offset andCount:count];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView == giftTableView){
        [giftTableView handleScrollViewDidScroll:scrollView];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if (scrollView == giftTableView){
        [giftTableView handleScrollViewWillBeginDragging:scrollView];
    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView{
    if (scrollView == giftTableView){
        [giftTableView handleScrollViewWillBeginDecelerating:scrollView];
    }
}

#pragma mark - HGAstroTrendServiceDelegate
- (void)astroTrendService:(HGAstroTrendService *)astroTrendService didRequestAstroTrendForFriendSucceed:(HGAstroTrend*)theAstroTrend {
    NSMutableArray* newGiftSets = [[NSMutableArray alloc] initWithArray:astroTrend.giftSets];
    [newGiftSets addObjectsFromArray:theAstroTrend.giftSets];
    astroTrend.giftSets = newGiftSets;
    [newGiftSets release];
    
    [giftTableView reloadData];
    giftTableView.bottomDragToUpdateRunning = NO;
    
    if ([theAstroTrend.giftSets count] < 6) {
        giftTableView.bottomDragToUpdateVisbile = NO;
    }
}

- (void)astroTrendService:(HGAstroTrendService *)astroTrendService didRequestAstroTrendForFriendFail:(NSString*)error {
    HGDebug(@"didRequestGiftsForOccasionFail");
    giftTableView.bottomDragToUpdateRunning = NO;
}

#pragma mark - HGOccasionsDetailViewListRowViewDelegate
- (void)handleOccasionsDetailViewListRowViewGiftSelected:(HGGiftSet*)giftSet {
    [HGRecipientService sharedService].selectedRecipient = astroTrend.recipient;
    
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

- (void)handleGIFGiftViewAction:(id)sender {
    [HGRecipientService sharedService].selectedRecipient = astroTrend.recipient;
    
    HGGIFGiftListViewController* viewController = [[HGGIFGiftListViewController alloc] initWithAstroTrend:astroTrend];
    [self.navigationController pushViewController:viewController animated:YES];
    [viewController release];
    
    [HGTrackingService logEvent:kTrackingEventEnterGIFGifts withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"HGAstroTrendDetailViewController", @"from", nil]];
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
    if (astroTrend.recipient.recipientNetworkId == NETWORK_SNS_WEIBO){
        if([[WBEngine sharedWeibo] isLoggedIn] == NO){
            HGAccountViewController* viewController = [[HGAccountViewController alloc] initWithNibName:@"HGAccountViewController" bundle:nil];
            [self presentModalViewController:viewController animated:YES];
            [viewController release];
            [HGTrackingService logPageView];
            [progressView stopAnimation];
            return;
        }
    }else if (astroTrend.recipient.recipientNetworkId == NETWORK_SNS_RENREN){
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
    
    [HGTrackingService logEvent:kTrackingEventEnterShare withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"HGAstroTrendDetailViewController", @"from", @"shareDIYGift", @"type", astroTrend.recipient.recipientNetworkId == NETWORK_SNS_WEIBO ? @"weibo" : @"renren", @"network", nil]];
    
    HGShareViewController* viewController = [[HGShareViewController alloc] initWithDIYGift:imageForShare recipient:astroTrend.recipient];
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

