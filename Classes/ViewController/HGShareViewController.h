//
//  HGShareViewController.m
//  HappyGift
//
//  Created by Yujian Weng on 12-5-25.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HGProgressView;
@class HGGiftOrder;
@class HGGift;
@class HGSong;
@class HGWish;
@class HGRecipient;
@class HGGIFGift;
@class HGImageData;
@class HGTweet;
@class HGAstroTrend;

@interface HGShareViewController : UIViewController {
    IBOutlet UINavigationBar*  navigationBar;
    IBOutlet UILabel*          shareTitleLabel;
    IBOutlet UIView*           shareContentView;
    IBOutlet UITextView*       shareContentTextView;
    IBOutlet UIImageView*      shareImageView;
    
    UIBarButtonItem* leftBarButtonItem;
    UIBarButtonItem* rightBarButtonItem;
    HGProgressView*  progressView;
    
    HGGiftOrder* giftOrder;
    HGGift* gift;
    NSString* invitation;
    NSString* virtualGift;
    UIImage* DIYImage;
    HGGIFGift* gifGift;
    
    UIImage* coverImage;
    HGImageData* gifImageData;
    int network;
    HGRecipient* recipient;
    NSString* giftReason;
    
    HGTweet* tweetForComment;
    HGTweet* tweetForForward;
    
    HGAstroTrend* astroTrend;
}

- (id)initWithGiftOrder:(HGGiftOrder *)giftOrder network:(int)network;
- (id)initWithGift:(HGGift *)gift network:(int)network;
- (id)initWithInvition:(NSString *)invitation network:(int)network;
- (id)initWithVirtualGift:(NSString *)virtualGift network:(int)network;
- (id)initWithDIYGift:(UIImage*)DIYImage recipient:(HGRecipient*)recipient;
- (id)initWithGIFGift:(HGGIFGift*)theGIFGift recipient:(HGRecipient*)theRecipient andGiftReason:(NSString*)giftReason;
- (id)initWithTweetForComment:(HGTweet*)theTweet;
- (id)initWithTweetForForward:(HGTweet*)theTweet;
- (id)initWithAstroTrend:(HGAstroTrend*)theAstroTrend;
@end