//
//  HGShareViewController.m
//  HappyGift
//
//  Created by Yujian Weng on 12-5-25.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//

#import "HGShareViewController.h"
#import "HappyGiftAppDelegate.h"
#import "HGCreditService.h"
#import "HGProgressView.h"
#import "UIBarButtonItem+Addition.h"
#import "NSString+Addition.h"
#import "HGUtility.h"
#import "HGDefines.h"
#import "HGGiftOrder.h"
#import "HGRecipient.h"
#import "HGGift.h"
#import "WBEngine.h"
#import "HGImageService.h"
#import <QuartzCore/QuartzCore.h>
#import "HGTrackingService.h"
#import "HGRecipient.h"
#import "HGGIFGift.h"
#import "UIImage+Addition.h"
#import "HGVirtualGiftService.h"
#import "HGTweet.h"
#import "HGTweetComment.h"
#import "ROStatusAddCommentRequestParam.h"
#import "ROShareRequestParam.h"
#import "ROForwardStatusRequestParam.h"
#import "ROBlogAddCommentRequestParam.h"
#import "ROPhotoAddCommentRequestParam.h"
#import "HGAstroTrend.h"
#import "HGAccountService.h"
#import "HGTweetCommentService.h"

@interface HGShareViewController()<UIScrollViewDelegate, UIGestureRecognizerDelegate, WBEngineDelegate, RenrenDelegate, UITextViewDelegate>
  
@end

NSString* const kSNSShareTemplateShareOrderToRenren = @"我刚刚通过 @乐送App(601437626) 送出了一件精美的礼品＃%@＃";
NSString* const kSNSShareTemplateShareOrderToWeibo = @"我刚刚通过 @乐送App 送出了一件精美的礼品＃%@＃";

NSString* const kSNSShareTemplateShareOrderToRenrenWithUrl = @"我刚刚通过 @乐送App(601437626) 送出了一件精美的礼品＃%@＃，快来看看吧：%@";
NSString* const kSNSShareTemplateShareOrderToWeiboWithUrl = @"我刚刚通过 @乐送App 送出了一件精美的礼品＃%@＃，快来看看吧：%@";

NSString* const kSNSShareTemplateShareGiftToRenren = @"我在 @乐送App(601437626) 发现了一件精美的礼品＃%@＃";
NSString* const kSNSShareTemplateShareGiftToWeibo = @"我在 @乐送App 发现了一件精美的礼品＃%@＃";

NSString* const kSNSShareTemplateShareGiftToRenrenWithUrl = @"我在 @乐送App(601437626) 发现了一件精美的礼品＃%@＃，快来看看吧：%@";
NSString* const kSNSShareTemplateShareGiftToWeiboWithUrl = @"我在 @乐送App 发现了一件精美的礼品＃%@＃，快来看看吧：%@";

NSString* const kSNSShareTemplateShareAppToRenrenWithUrl = @"我向你推荐 @乐送App(601437626) ，这里有精美的礼品和最热的好友，快去下载使用吧！%@";
NSString* const kSNSShareTemplateShareAppToWeiboWithUrl = @"我向你推荐 @乐送App ，这里有精美的礼品和最热的好友，快去下载使用吧！%@";

NSString* const kSNSShareTemplateShareVirtualGiftToRenrenWithUrl = @"%@";
NSString* const kSNSShareTemplateShareVirtualGiftToWeiboWithUrl = @"%@";

NSString* const kSNSShareTemplateShareDIYGiftToRenrenWithUrl = @"@%@(%@) 我亲手为你制作了一张精美的贺卡，一睹为快吧！！ (来自@乐送App http://lesongapp.cn)";
NSString* const kSNSShareTemplateShareDIYGiftToWeiboWithUrl = @"@%@ 我亲手为你制作了一张精美的贺卡，一睹为快吧！！ (来自@乐送App)";

NSString* const kSNSShareTemplateShareGIFGiftToRenren = @"@%@(%@) %@%@ (来自@乐送App)";
NSString* const kSNSShareTemplateShareGIFGiftToWeibo = @"@%@ %@%@ (来自@乐送App)";

NSString* const kSNSShareTemplateShareAstroTrendToRenren = @"@%@(%@) 你今天的%@：\"%@\" (来自@乐送App http://lesongapp.cn)";
NSString* const kSNSShareTemplateShareAstroTrendToWeibo = @"@%@ 你今天的%@：\"%@\" (来自@乐送App)";

#define kRenrenMaximalCharacterCount 140
#define kWeiboMaximalCharacterCount 140


@implementation HGShareViewController

- (id)initWithGiftOrder:(HGGiftOrder *)theGiftOrder network:(int)theNetwork{
    self = [super initWithNibName:@"HGShareViewController" bundle:nil];
    if (self) {
        giftOrder = [theGiftOrder retain];
        network = theNetwork;
    }
    return self;
}

- (id)initWithGift:(HGGift *)theGift network:(int)theNetwork{
    self = [super initWithNibName:@"HGShareViewController" bundle:nil];
    if (self) {
        gift = [theGift retain];
        network = theNetwork;
    }
    return self;
}

- (id)initWithInvition:(NSString *)theInvitation network:(int)theNetwork{
    self = [super initWithNibName:@"HGShareViewController" bundle:nil];
    if (self) {
        invitation = [theInvitation retain];
        network = theNetwork;
    }
    return self;    
}

- (id)initWithVirtualGift:(NSString *)theVirtualGift network:(int)theNetwork;{
    self = [super initWithNibName:@"HGShareViewController" bundle:nil];
    if (self) {
        virtualGift = [theVirtualGift retain];
        network = theNetwork;
    }
    return self; 
}

- (id)initWithDIYGift:(UIImage*)theDIYImage recipient:(HGRecipient*)theRecipient{
    self = [super initWithNibName:@"HGShareViewController" bundle:nil];
    if (self) {
        DIYImage = [theDIYImage retain];
        recipient = [theRecipient retain];
        network = theRecipient.recipientNetworkId;
    }
    return self; 
}

- (id)initWithGIFGift:(HGGIFGift*)theGifGift recipient:(HGRecipient*)theRecipient andGiftReason:theGiftReason {
    self = [super initWithNibName:@"HGShareViewController" bundle:nil];
    if (self) {
        gifGift = [theGifGift retain];
        recipient = [theRecipient retain];
        network = theRecipient.recipientNetworkId;
        giftReason = [theGiftReason retain];
    }
    return self; 
}

- (id)initWithTweetForComment:(HGTweet*)theTweet {
    self = [super initWithNibName:@"HGShareViewController" bundle:nil];
    if (self) {
        tweetForComment = [theTweet retain];
        network = tweetForComment.tweetNetwork;
    }
    return self; 
}

- (id)initWithTweetForForward:(HGTweet*)theTweet {
    self = [super initWithNibName:@"HGShareViewController" bundle:nil];
    if (self) {
        tweetForForward = [theTweet retain];
        network = tweetForForward.tweetNetwork;
    }
    return self; 
}

- (id)initWithAstroTrend:(HGAstroTrend*)theAstroTrend {
    self = [super initWithNibName:@"HGShareViewController" bundle:nil];
    if (self) {
        astroTrend = [theAstroTrend retain];
        network = astroTrend.recipient.recipientNetworkId;
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    self.view.backgroundColor = [HappyGiftAppDelegate genericBackgroundColor];
    
    leftBarButtonItem = [[UIBarButtonItem alloc ] initNavigationLeftTextBarButtonItem:@"取消" target:self action:@selector(handleCancelAction:)];
    navigationBar.topItem.leftBarButtonItem = leftBarButtonItem;
    
    rightBarButtonItem = [[UIBarButtonItem alloc ] initNavigationRightTextBarButtonItem:@"发送" target:self action:@selector(handleSendAction:)];
    navigationBar.topItem.rightBarButtonItem = rightBarButtonItem;
    
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
    
    if (tweetForComment != nil) {
        if (network == NETWORK_SNS_WEIBO){
            titleLabel.text = @"评论微博";
        }else if (network == NETWORK_SNS_RENREN){
            titleLabel.text = @"评论人人网状态";
        }
    } else if (tweetForForward != nil)  {
        if (network == NETWORK_SNS_WEIBO){
            titleLabel.text = @"转发微博";
        }else if (network == NETWORK_SNS_RENREN){
            titleLabel.text = @"分享人人网状态";
        }
    } else {
        if (network == NETWORK_SNS_WEIBO){
            titleLabel.text = @"分享到新浪微博";
        }else if (network == NETWORK_SNS_RENREN){
            titleLabel.text = @"分享到人人网";
        }
    }
	
    [titleView addSubview:titleLabel];
    [titleLabel release];
    
	navigationBar.topItem.titleView = titleView;
    [titleView release];
    
    shareContentTextView.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeNormal]];
    shareContentTextView.textColor = [UIColor darkGrayColor];
   
    shareTitleLabel.font = [UIFont fontWithName:[HappyGiftAppDelegate fontName] size:[HappyGiftAppDelegate fontSizeNormal]];
    shareTitleLabel.textColor = [UIColor darkGrayColor];
   
    progressView = [[HGProgressView progressView:self.view.frame] retain];
    [self.view addSubview:progressView];
    progressView.hidden = YES;
    
    [shareContentTextView becomeFirstResponder];
    
    NSNotificationCenter *notification = [NSNotificationCenter defaultCenter];
    [notification addObserver:self selector:@selector(keyboardWillShow:) name: UIKeyboardWillShowNotification object:nil];
    [notification addObserver:self selector:@selector(keyboardDidShow:) name: UIKeyboardDidShowNotification object:nil];
    [notification addObserver:self selector:@selector(keyboardWillHide:) name: UIKeyboardWillHideNotification object:nil];
    [notification addObserver:self selector:@selector(keyboardDidHide:) name: UIKeyboardDidHideNotification object:nil];
            
    int countForInput = kWeiboMaximalCharacterCount;
    
    if (giftOrder != nil) {
        if (network == NETWORK_SNS_WEIBO) {
            if (giftOrder.gift.productUrl && ![@"" isEqualToString:giftOrder.gift.productUrl]) {
                shareContentTextView.text = [NSString stringWithFormat:kSNSShareTemplateShareOrderToWeiboWithUrl, giftOrder.gift.name, giftOrder.gift.productUrl];
            }else{
                shareContentTextView.text = [NSString stringWithFormat:kSNSShareTemplateShareOrderToWeibo, giftOrder.gift.name];
            }
            countForInput = kWeiboMaximalCharacterCount - [shareContentTextView.text length];
        } else if (network == NETWORK_SNS_RENREN){
            if (giftOrder.gift.productUrl && ![@"" isEqualToString:giftOrder.gift.productUrl]) {
                shareContentTextView.text = [NSString stringWithFormat:kSNSShareTemplateShareOrderToRenrenWithUrl, giftOrder.gift.name, giftOrder.gift.productUrl];
            }else{
                shareContentTextView.text = [NSString stringWithFormat:kSNSShareTemplateShareOrderToRenren, giftOrder.gift.name];
            }
            countForInput = kRenrenMaximalCharacterCount - [shareContentTextView.text length];
        }
        if (giftOrder.gift.thumb  != nil){
            HGImageService *imageService = [HGImageService sharedService];
            coverImage = [[imageService requestImage:giftOrder.gift.thumb target:self selector:@selector(didImageLoaded:)] retain];
        }
    } else if (gift != nil) {
        if (network == NETWORK_SNS_WEIBO) {
            if (gift.productUrl && ![@"" isEqualToString:gift.productUrl]) {
                shareContentTextView.text = [NSString stringWithFormat:kSNSShareTemplateShareGiftToWeiboWithUrl, gift.name, gift.productUrl];
            } else {
                shareContentTextView.text = [NSString stringWithFormat:kSNSShareTemplateShareGiftToWeibo, gift.name];
            }
            countForInput = kWeiboMaximalCharacterCount - [shareContentTextView.text length];
        } else if (network == NETWORK_SNS_RENREN) {
            if (gift.productUrl && ![@"" isEqualToString:gift.productUrl]) {
                shareContentTextView.text = [NSString stringWithFormat:kSNSShareTemplateShareGiftToRenrenWithUrl, gift.name, gift.productUrl];
            } else {
                shareContentTextView.text = [NSString stringWithFormat:kSNSShareTemplateShareGiftToRenren, gift.name];
            }
            countForInput = kRenrenMaximalCharacterCount - [shareContentTextView.text length];
        }
        if (gift.thumb  != nil){
            HGImageService *imageService = [HGImageService sharedService];
            coverImage = [[imageService requestImage:gift.thumb target:self selector:@selector(didImageLoaded:)] retain];
        }
    } else if (invitation != nil) {
        if (network == NETWORK_SNS_WEIBO) {
            shareContentTextView.text = [NSString stringWithFormat:kSNSShareTemplateShareAppToWeiboWithUrl, @"http://itunes.apple.com/cn/app/le-song/id537116971?ls=1&mt=8"];
            countForInput = kWeiboMaximalCharacterCount - [shareContentTextView.text length];
        } else if (network == NETWORK_SNS_RENREN){
            shareContentTextView.text = [NSString stringWithFormat:kSNSShareTemplateShareAppToRenrenWithUrl, @"http://itunes.apple.com/cn/app/le-song/id537116971?ls=1&mt=8"];
            countForInput = kRenrenMaximalCharacterCount - [shareContentTextView.text length];
        }
        [shareContentTextView setEditable:NO];
        shareTitleLabel.hidden = YES;
    } else if (virtualGift != nil) {
        if (network == NETWORK_SNS_WEIBO) {
            shareContentTextView.text = [NSString stringWithFormat:kSNSShareTemplateShareVirtualGiftToWeiboWithUrl, virtualGift];
            countForInput = kWeiboMaximalCharacterCount - [shareContentTextView.text length];
        } else if (network == NETWORK_SNS_RENREN){
            shareContentTextView.text = [NSString stringWithFormat:kSNSShareTemplateShareVirtualGiftToRenrenWithUrl, virtualGift];
            countForInput = kRenrenMaximalCharacterCount - [shareContentTextView.text length];
        }
    } else if (DIYImage != nil) {
        if (network == NETWORK_SNS_WEIBO) {
            shareContentTextView.text = [NSString stringWithFormat:kSNSShareTemplateShareDIYGiftToWeiboWithUrl, recipient.recipientName];
            countForInput = kWeiboMaximalCharacterCount - [shareContentTextView.text length];
        } else if (network == NETWORK_SNS_RENREN){
            shareContentTextView.text = [NSString stringWithFormat:kSNSShareTemplateShareDIYGiftToRenrenWithUrl, recipient.recipientName, recipient.recipientProfileId];
            countForInput = kRenrenMaximalCharacterCount - [shareContentTextView.text length];
        }
    } else if (gifGift != nil) {
        if (network == NETWORK_SNS_WEIBO) {
            shareContentTextView.text = [NSString stringWithFormat:kSNSShareTemplateShareGIFGiftToWeibo, recipient.recipientName, giftReason, gifGift.wishes];
            countForInput = kWeiboMaximalCharacterCount - [shareContentTextView.text length];
        } else if (network == NETWORK_SNS_RENREN){
            shareContentTextView.text = [NSString stringWithFormat:kSNSShareTemplateShareGIFGiftToRenren, recipient.recipientName, recipient.recipientProfileId, giftReason, gifGift.wishes];
            countForInput = kRenrenMaximalCharacterCount - [shareContentTextView.text length];
        }
        
        if (gifGift.gif != nil) {
            HGImageService *imageService = [HGImageService sharedService];
            HGImageData* imageData = [[imageService requestImageForRawData:gifGift.gif target:self selector:@selector(didImageLoaded:)] retain];
            gifImageData = [imageData retain];
            [imageData release];
        }
    } else if (tweetForForward != nil) {
        if (network == NETWORK_SNS_WEIBO) {
            NSString* status = @"";
            if (tweetForForward.originTweet != nil) {
                status = [NSString stringWithFormat:@"//@%@：%@", tweetForForward.senderName, tweetForForward.text];
                
                if ([status length] > kWeiboMaximalCharacterCount) {
                    status = [status substringToIndex:kWeiboMaximalCharacterCount];
                }
            }
            shareContentTextView.text = status;
            NSRange range;
            range.location = 0;
            range.length  = 0;
            shareContentTextView.selectedRange = range;
            
            countForInput = kWeiboMaximalCharacterCount - [shareContentTextView.text length];
        } else if (network == NETWORK_SNS_RENREN) {
            shareContentTextView.text = @"";
            countForInput = kRenrenMaximalCharacterCount - [shareContentTextView.text length];
        }
    } else if (astroTrend != nil) {
        if (network == NETWORK_SNS_WEIBO) {
            shareContentTextView.text = [NSString stringWithFormat:kSNSShareTemplateShareAstroTrendToWeibo, astroTrend.recipient.recipientName, astroTrend.trendName, astroTrend.trendDetail];
            countForInput = kWeiboMaximalCharacterCount - [shareContentTextView.text length];
        } else if (network == NETWORK_SNS_RENREN) {
            shareContentTextView.text = [NSString stringWithFormat:kSNSShareTemplateShareAstroTrendToRenren, astroTrend.recipient.recipientName, astroTrend.recipient.recipientProfileId, astroTrend.trendName,  astroTrend.trendDetail];
            countForInput = kRenrenMaximalCharacterCount - [shareContentTextView.text length];
        }
    }
    
    shareTitleLabel.text = [NSString stringWithFormat:@"您还能输入%d字", countForInput];
    
    if (coverImage != nil) {
        shareImageView.image = [coverImage imageWithFrame:CGSizeMake(shareImageView.frame.size.width, shareImageView.frame.size.height) color:[HappyGiftAppDelegate imageFrameColor]];
    }else if (DIYImage != nil) {
        shareImageView.image = [DIYImage imageWithFrame:CGSizeMake(shareImageView.frame.size.width, shareImageView.frame.size.height) color:[HappyGiftAppDelegate imageFrameColor]];
    } else if (gifImageData != nil) {
        shareImageView.image = [gifImageData.image imageWithFrame:CGSizeMake(shareImageView.frame.size.width, shareImageView.frame.size.height) color:[HappyGiftAppDelegate imageFrameColor]];
    } else {
        shareImageView.hidden = YES;
    }
    shareImageView.transform = CGAffineTransformMakeRotation(15.0*M_PI/180.0);
}

- (void)viewDidUnload{
    [super viewDidUnload];
    [progressView removeFromSuperview];
    [progressView release];
    
    [leftBarButtonItem release];
    leftBarButtonItem = nil;
    
    [rightBarButtonItem release];
    rightBarButtonItem = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
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

- (void)dealloc{
    [giftOrder release];
    [gift release];
    [progressView release];
    [leftBarButtonItem release];
    [shareTitleLabel release];
    [shareContentTextView release];
    [shareContentView release];
    [coverImage release];
    [invitation release];
    [virtualGift release];
    [DIYImage release];
    [recipient release];
    [gifGift release];
    [gifImageData release];
    [tweetForComment release];
    [tweetForForward release];
    [giftReason release];
    [astroTrend release];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
    
    WBEngine* engine = [WBEngine sharedWeibo];
    if (engine.delegate == self) {
        engine.delegate = nil;
    }
    
    RenrenService* renren = [RenrenService sharedRenren];
    if (renren.renrenDelegate == self) {
        renren.renrenDelegate = nil;
    }
    
	[super dealloc];
}


- (void)handleCancelAction:(id)sender {
    WBEngine* engine = [WBEngine sharedWeibo];
    if (engine.delegate == self) {
        engine.delegate = nil;
    }
    
    [self dismissModalViewControllerAnimated:YES];
}

- (void)handleSendAction:(id)sender {
    shareContentTextView.text = [shareContentTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString* textToShare = shareContentTextView.text;
    if (textToShare == nil || [textToShare isEqualToString:@""] == YES){
        [self performBounceViewAnimation:shareContentView];
        HappyGiftAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
        [appDelegate sendNotification:@"请将分享信息填写完整"];
    }else{
        [progressView startAnimation];
        shareContentTextView.userInteractionEnabled = NO;
        [self checkKeyboardVisiblity];
        
        if (network == NETWORK_SNS_WEIBO){
            WBEngine* engine = [WBEngine sharedWeibo];
            engine.delegate = self;
            if (coverImage != nil){
                [engine sendWeiBoWithText:textToShare image:coverImage];
            }else if (DIYImage != nil){
                [engine sendWeiBoWithText:textToShare image:DIYImage];
            } else if (gifImageData != nil) {
                [engine sendWeiBoWithText:textToShare imageData:gifImageData.data];
            } else if (tweetForComment != nil) {
                [engine commentTweet:tweetForComment.tweetId withComment:textToShare];
            } else if (tweetForForward != nil) {
                NSString* tweetId;
                if (tweetForForward.originTweet) {
                    tweetId = tweetForForward.originTweet.tweetId;
                } else {
                    tweetId = tweetForForward.tweetId;
                }
                [engine repostTweet:tweetId withStatus:textToShare];
            } else {
                [engine sendWeiBoWithText:textToShare image:nil];
            }
            
            if (gift != nil) {
                [HGTrackingService logEvent:kTrackingEventShareProduct withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"weibo", @"network", nil]];
            } else if (giftOrder != nil) {
                [HGTrackingService logEvent:kTrackingEventShareOrder withParameters:[NSDictionary dictionaryWithObjectsAndKeys: @"weibo", @"network", nil]];
            } else if (invitation != nil) {
                [HGTrackingService logEvent:kTrackingEventShareApp withParameters:[NSDictionary dictionaryWithObjectsAndKeys: @"weibo", @"network", nil]];
            } else if (virtualGift != nil) {
                [HGTrackingService logEvent:kTrackingEventShareVirtualGift withParameters:[NSDictionary dictionaryWithObjectsAndKeys: @"weibo", @"network", nil]];
            } else if (DIYImage != nil) {
                [HGTrackingService logEvent:kTrackingEventShareDIYGift withParameters:[NSDictionary dictionaryWithObjectsAndKeys: @"weibo", @"network", nil]];
            } else if (gifGift != nil) {
                [HGTrackingService logEvent:kTrackingEventShareGIFGift withParameters:[NSDictionary dictionaryWithObjectsAndKeys: @"weibo", @"network", nil]];
            } else if (tweetForComment != nil) {
                [HGTrackingService logEvent:kTrackingEventCommentTweet withParameters:[NSDictionary dictionaryWithObjectsAndKeys: @"weibo", @"network", nil]];
            } else if (tweetForForward != nil) {
                [HGTrackingService logEvent:kTrackingEventForwardTweet withParameters:[NSDictionary dictionaryWithObjectsAndKeys: @"weibo", @"network", nil]];
            } else if (astroTrend != nil) {
                [HGTrackingService logEvent:kTrackingEventShareAstroTrend withParameters:[NSDictionary dictionaryWithObjectsAndKeys: @"weibo", @"network", nil]];
            }
        }else if (network == NETWORK_SNS_RENREN){
            if (coverImage != nil){
                ROPublishPhotoRequestParam *param = [[ROPublishPhotoRequestParam alloc] init];
                param.caption = textToShare;
                param.imageFile = coverImage;
                [[RenrenService sharedRenren] publishPhoto:param andDelegate:self];
                [param release];
            } else if (DIYImage != nil){
                ROPublishPhotoRequestParam *param = [[ROPublishPhotoRequestParam alloc] init];
                param.caption = textToShare;
                param.imageFile = DIYImage;
                [[RenrenService sharedRenren] publishPhoto:param andDelegate:self];
                [param release];
            } else if (gifImageData != nil) {
                ROPublishPhotoRequestParam *param = [[ROPublishPhotoRequestParam alloc] init];
                param.caption = textToShare;
                param.imageData = gifImageData.data;
                [[RenrenService sharedRenren] publishPhoto:param andDelegate:self];
                [param release];
            } else if (tweetForComment != nil) {
                if (tweetForComment.tweetType == TWEET_TYPE_STATUS) {
                    ROStatusAddCommentRequestParam *param = [[ROStatusAddCommentRequestParam alloc] init];
                    param.content = textToShare;
                    param.owner_id = tweetForComment.senderId;
                    param.status_id = tweetForComment.tweetId;
                    [[RenrenService sharedRenren] addCommentToStatus:param andDelegate:self];
                    [param release];
                } else if (tweetForComment.tweetType == TWEET_TYPE_PHOTO) {
                    ROPhotoAddCommentRequestParam *param = [[ROPhotoAddCommentRequestParam alloc] init];
                    param.content = textToShare;
                    param.uid = tweetForComment.senderId;
                    param.pid = tweetForComment.tweetId;
                    [[RenrenService sharedRenren] addCommentToPhoto:param andDelegate:self];
                    [param release];
                } else if (tweetForComment.tweetType == TWEET_TYPE_BLOG) {
                    ROBlogAddCommentRequestParam *param = [[ROBlogAddCommentRequestParam alloc] init];
                    param.content = textToShare;
                    param.uid = tweetForComment.senderId;
                    param.blogId = tweetForComment.tweetId;
                    [[RenrenService sharedRenren] addCommentToBlog:param andDelegate:self];
                    [param release];
                }
            } else if (tweetForForward != nil) {
                if (tweetForForward.tweetType == TWEET_TYPE_STATUS) {
                    ROForwardStatusRequestParam *param = [[ROForwardStatusRequestParam alloc] init];
                    param.status = textToShare;
                    param.forwardOwner = tweetForForward.senderId;
                    param.forwardId = tweetForForward.tweetId;
                    [[RenrenService sharedRenren] forwardStatus:param andDelegate:self];
                    [param release];
                } else if (tweetForForward.tweetType == TWEET_TYPE_PHOTO) {
                    ROShareRequestParam *param = [[ROShareRequestParam alloc] init];
                    param.comment = textToShare;
                    param.type = @"2";
                    param.ugcId = tweetForForward.tweetId;
                    param.ownerId = tweetForForward.senderId;
                    [[RenrenService sharedRenren] share:param andDelegate:self];
                    [param release];
                } else if (tweetForForward.tweetType == TWEET_TYPE_BLOG) {
                    ROShareRequestParam *param = [[ROShareRequestParam alloc] init];
                    param.comment = textToShare;
                    param.type = @"1";
                    param.ugcId = tweetForForward.tweetId;
                    param.ownerId = tweetForForward.senderId;
                    [[RenrenService sharedRenren] share:param andDelegate:self];
                    [param release];
                }
            } else{
                NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:10];
                [params setObject:@"status.set" forKey:@"method"];
                [params setObject:textToShare forKey:@"status"];
                [[RenrenService sharedRenren] requestWithParams:params andDelegate:self];
            }
            if (gift != nil) {
                [HGTrackingService logEvent:kTrackingEventShareProduct withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"renren", @"network", nil]];
            } else if (giftOrder != nil) {
                [HGTrackingService logEvent:kTrackingEventShareOrder withParameters:[NSDictionary dictionaryWithObjectsAndKeys: @"renren", @"network", nil]];
            } else if (invitation != nil) {
                [HGTrackingService logEvent:kTrackingEventShareApp withParameters:[NSDictionary dictionaryWithObjectsAndKeys: @"renren", @"network", nil]];
            } else if (virtualGift != nil) {
                [HGTrackingService logEvent:kTrackingEventShareVirtualGift withParameters:[NSDictionary dictionaryWithObjectsAndKeys: @"renren", @"network", nil]];
            } else if (DIYImage != nil) {
                [HGTrackingService logEvent:kTrackingEventShareDIYGift withParameters:[NSDictionary dictionaryWithObjectsAndKeys: @"renren", @"network", nil]];
            } else if (gifGift != nil) {
                [HGTrackingService logEvent:kTrackingEventShareGIFGift withParameters:[NSDictionary dictionaryWithObjectsAndKeys: @"renren", @"network", nil]];
            }else if (tweetForComment != nil) {
                [HGTrackingService logEvent:kTrackingEventCommentTweet withParameters:[NSDictionary dictionaryWithObjectsAndKeys: @"renren", @"network", nil]];
            } else if (tweetForForward != nil) {
                [HGTrackingService logEvent:kTrackingEventForwardTweet withParameters:[NSDictionary dictionaryWithObjectsAndKeys: @"renren", @"network", nil]];
            } else if (astroTrend != nil) {
                [HGTrackingService logEvent:kTrackingEventShareAstroTrend withParameters:[NSDictionary dictionaryWithObjectsAndKeys: @"renren", @"network", nil]];
            }
        }
    }
}

- (void)checkKeyboardVisiblity{
    if ([shareContentTextView isFirstResponder]){
        [shareContentTextView resignFirstResponder];
    }
}

- (void)checkTextInputVisiblity{

}

- (void)performBounceViewAnimation:(UIView*)bounceView{
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position.x"];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    animation.duration = 0.5;
    NSMutableArray *values = [[NSMutableArray alloc] init];
    CGFloat minValue = bounceView.layer.position.x - 5.0;
    CGFloat maxValue = bounceView.layer.position.x + 5.0;
    CGFloat currentValue = bounceView.layer.position.x;
    CGFloat stepValue = 2.0;
    BOOL increase = YES;
    int bounces = 0;
    while (bounces < 3) {
        if (increase == YES){
            currentValue += stepValue;
        }else{
            currentValue -= stepValue;
        }
        [values addObject:[NSNumber numberWithFloat:currentValue]];
        if (increase == YES){
            if (currentValue > maxValue){
                increase = NO;
            }
        }else{
            if (currentValue < minValue){
                increase = YES;
                bounces += 1;
            }
        }
    }
    animation.values = values;
    [values release];
    
    animation.removedOnCompletion = YES;
    animation.fillMode = kCAFillModeForwards;
    animation.delegate = self;
    [bounceView.layer addAnimation:animation forKey:nil];
}

#pragma mark - Actions
- (void)keyboardWillShow:(NSNotification *)notfication {
    CGRect viewFrame = [shareContentView frame];
    NSDictionary* info = [notfication userInfo];
    
    NSValue* aValue = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGSize keyboardSize = [aValue CGRectValue].size;
    
    viewFrame.size.height = 150 - (keyboardSize.height - 216);
    shareContentView.frame = viewFrame;
}

- (void)keyboardDidShow:(NSNotification *)notfication {
}

- (void)keyboardWillHide:(NSNotification *)notfication {
    
}

- (void)keyboardDidHide:(NSNotification *)notfication {
}


#pragma mark WBEngineDelegate
- (void)engine:(WBEngine *)engine requestDidFailWithError:(NSError *)error{
    HappyGiftAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    if (tweetForComment != nil)  {
        [appDelegate sendNotification:@"提交评论失败，请检查网络连接稍后再试"];
    } else if (tweetForForward != nil) {
        [appDelegate sendNotification:@"转发微博失败，请检查网络连接稍后再试"];
    } else {
        [appDelegate sendNotification:@"提交分享信息错误，请稍后再试"];
    }
    shareContentTextView.userInteractionEnabled = YES;
    [progressView stopAnimation];
}

- (void)engine:(WBEngine *)engine requestDidSucceedWithResult:(id)result{
    shareContentTextView.userInteractionEnabled = YES;
    [progressView stopAnimation];
    
    if (giftOrder != nil) {
        [[HGCreditService sharedService] requestCreditByShareOrder:giftOrder.identifier];
    } else if (DIYImage != nil || gifGift != nil) {
        NSString* tweetId = [result objectForKey:@"idstr"];
        NSString* tweetPic = [result objectForKey:@"original_pic"];
        NSString* tweetText = [result objectForKey:@"text"];
        if (DIYImage != nil) {
            [[HGVirtualGiftService sharedService] requestSendVirtualGift:recipient.recipientNetworkId andProfileId:recipient.recipientProfileId giftType:@"diy" giftId:nil tweetId:tweetId tweetText:tweetText tweetPic:tweetPic];
        } else if (gifGift != nil) {
            [[HGVirtualGiftService sharedService] requestSendVirtualGift:recipient.recipientNetworkId andProfileId:recipient.recipientProfileId giftType:@"image" giftId:gifGift.identifier tweetId:tweetId tweetText:tweetText tweetPic:nil];
        }
    } else if (tweetForComment != nil) {
        HGTweetComment* comment = [[HGTweetComment alloc] init];
        comment.originTweetId = tweetForComment.tweetId;
        comment.originTweetNetwork = tweetForComment.tweetNetwork;
        comment.originTweetType = tweetForComment.tweetType;
        
        HGAccountService* accountService = [HGAccountService sharedService];
        comment.senderId = accountService.currentAccount.weiBoUserId;
        comment.senderName = accountService.currentAccount.weiBoUserName;
        comment.senderImageUrl = accountService.currentAccount.weiBoUserIconLarge;
        
        comment.text = shareContentTextView.text;
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
		NSString *formattedDateString = [dateFormatter stringFromDate:[NSDate date]];
		[dateFormatter release];
        
        comment.createTime = formattedDateString;
        
        [[HGTweetCommentService sharedService] addComment:comment toTweet:tweetForComment];
        
        [comment release];
    }
    
    [self performSelector:@selector(handleCancelAction:) withObject:nil afterDelay:0.01];
}

#pragma mark RenrenDelegate
- (void)renren:(RenrenService *)renren requestDidReturnResponse:(ROResponse*)response{
    shareContentTextView.userInteractionEnabled = YES;
    [progressView stopAnimation];
    
    
    
    if (giftOrder != nil) {
        [[HGCreditService sharedService] requestCreditByShareOrder:giftOrder.identifier];
    } else if (DIYImage != nil || gifGift != nil) {
        if ([response.rootObject isKindOfClass:ROPublishPhotoResponseItem.class]) {
            ROPublishPhotoResponseItem* photoResponse = (ROPublishPhotoResponseItem*)response.rootObject;
            NSString* tweetId = photoResponse.photoId;
            NSString* tweetText = photoResponse.caption;
            NSString* tweetPic = photoResponse.srcBigUrl;
            if (DIYImage != nil) {
                [[HGVirtualGiftService sharedService] requestSendVirtualGift:recipient.recipientNetworkId andProfileId:recipient.recipientProfileId giftType:@"diy" giftId:nil tweetId:tweetId tweetText:tweetText tweetPic:tweetPic];
            } else if (gifGift != nil) {
                [[HGVirtualGiftService sharedService] requestSendVirtualGift:recipient.recipientNetworkId andProfileId:recipient.recipientProfileId giftType:@"image" giftId:gifGift.identifier tweetId:tweetId tweetText:tweetText tweetPic:nil];
            }
        }
    } else if (tweetForComment != nil) {
        HGTweetComment* comment = [[HGTweetComment alloc] init];
        comment.originTweetId = tweetForComment.tweetId;
        comment.originTweetNetwork = tweetForComment.tweetNetwork;
        comment.originTweetType = tweetForComment.tweetType;
        
        HGAccountService* accountService = [HGAccountService sharedService];
        
        comment.senderId = accountService.currentAccount.renrenUserId;
        comment.senderName = accountService.currentAccount.renrenUserName;
        comment.senderImageUrl = accountService.currentAccount.renrenUserIconLarge;
        
        comment.text = shareContentTextView.text;
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
		NSString *formattedDateString = [dateFormatter stringFromDate:[NSDate date]];
		[dateFormatter release];
        
        comment.createTime = formattedDateString;
        
        [[HGTweetCommentService sharedService] addComment:comment toTweet:tweetForComment];
        [comment release];

    }
    
    [self performSelector:@selector(handleCancelAction:) withObject:nil afterDelay:0.01];
}

- (void)renren:(RenrenService *)renren requestFailWithError:(ROError*)error{
    HappyGiftAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    if (tweetForComment != nil) {
        int errorCode = [[error.userInfo objectForKey:@"error_code"] intValue];
        if (errorCode == 202) {
            [appDelegate sendNotification:@"您尚未授予乐送发布评论到人人网的权限，请重新登录后授权"];
        } else {
            [appDelegate sendNotification:@"提交评论信息出错，请检查网络连接稍后再试"];
        }
    } else if (tweetForForward != nil) {
        int errorCode = [[error.userInfo objectForKey:@"error_code"] intValue];
        if (errorCode == 202) {
            [appDelegate sendNotification:@"您尚未授予乐送转发状态到人人网的权限，请重新登录后授权"];
        } else {
            [appDelegate sendNotification:@"提交转发信息出错，请检查网络连接稍后再试"];
        }
    } else {
        [appDelegate sendNotification:@"提交分享信息错误"];
    }
    shareContentTextView.userInteractionEnabled = YES;
    [progressView stopAnimation];
}

#pragma mark UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if (network == NETWORK_SNS_WEIBO){
        NSString* lastText = textView.text;
        NSString* nextText = [lastText stringByReplacingCharactersInRange:range withString:text];
        if ([nextText length] > 140.0){
            return NO;
        }
    }else if (network == NETWORK_SNS_RENREN){
        NSString* lastText = textView.text;
        NSString* nextText = [lastText stringByReplacingCharactersInRange:range withString:text];
        if ([nextText length] > 140.0){
            return NO;
        }
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView{
    if (network == NETWORK_SNS_WEIBO){
        int countForInput = kWeiboMaximalCharacterCount - [textView.text length];
        shareTitleLabel.text = [NSString stringWithFormat:@"您还能输入%d字", countForInput];
    }else if (network == NETWORK_SNS_RENREN){
        int countForInput = kRenrenMaximalCharacterCount - [textView.text length];
        shareTitleLabel.text = [NSString stringWithFormat:@"您还能输入%d字", countForInput];
    }
}

#pragma mark didImageLoaded
-(void)didImageLoaded:(HGImageData*)image {
    if (gifGift && [image.url isEqualToString:gifGift.gif]) {
        gifImageData = [image retain];
    } else {
        coverImage = [image.image retain];
    }
    shareImageView.hidden = NO;
}

@end

