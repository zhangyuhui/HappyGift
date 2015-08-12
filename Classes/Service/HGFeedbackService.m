//
//  HGFeedbackService.m
//  HappyGift
//
//  Created by Yujian Weng on 12-6-6.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//

#import "HGFeedbackService.h"
#import "HGFeedbackLoader.h"
#import "HGConstants.h"
#import "HGAccountService.h"
#import "HappyGiftAppDelegate.h"

static HGFeedbackService* feedbackService;

@interface HGFeedbackService () <HGFeedbackLoaderDelegate>

@end

@implementation HGFeedbackService
@synthesize delegate;

+ (HGFeedbackService*)sharedService {
    if (feedbackService == nil) {
        feedbackService = [[HGFeedbackService alloc] init];
    }
    return feedbackService;
}

+ (void)killService{
    if (feedbackService != nil) {
        [feedbackService release];
        feedbackService = nil;
    }    
}

- (void)dealloc {
    [feedbackLoader release];
    [super dealloc];
}

- (void)requestUploadFeedback:(NSString*)feedback{
    if (feedbackLoader != nil) {
        [feedbackLoader cancel];
    } else {
        feedbackLoader = [[HGFeedbackLoader alloc] init];
        feedbackLoader.delegate = self;
    }
    HGAccount* currentAccount = [HGAccountService sharedService].currentAccount;
    [feedbackLoader requestUploadFeedback:feedback userName:currentAccount.userName userPhone:currentAccount.userPhone userEmail:currentAccount.userEmail];
}

#pragma mark HGFeedbackLoaderDelegate
- (void)feedbackLoader:(HGFeedbackLoader *)feedbackLoader didRequestUploadFeedbackSucceed:(NSString*)nothing{
    if ([delegate respondsToSelector:@selector(feedbackService:didRequestUploadFeedbackSucceed:)]){
        [delegate feedbackService:self didRequestUploadFeedbackSucceed:nothing];
    }
}

- (void)feedbackLoader:(HGFeedbackLoader *)feedbackLoader didRequestUploadFeedbackFail:(NSString*)error {
    if ([delegate respondsToSelector:@selector(feedbackService:didRequestUploadFeedbackFail:)]){
        [delegate feedbackService:self didRequestUploadFeedbackFail:error];
    }
}

@end
