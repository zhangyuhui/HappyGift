//
//  HGVirtualGiftService.h
//  HappyGift
//
//  Created by Yujian Weng on 12-7-31.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//

#import "HGVirtualGiftService.h"
#import "HGVirtualGiftLoader.h"
#import "HGConstants.h"
#import "HappyGiftAppDelegate.h"
#import "HGLogging.h"

static HGVirtualGiftService* virtualGiftService;

@interface HGVirtualGiftService () <HGVirtualGiftLoaderDelegate>

@end

@implementation HGVirtualGiftService
@synthesize delegate;
@synthesize gifGiftsByCategory;

+ (HGVirtualGiftService*)sharedService {
    if (virtualGiftService == nil) {
        virtualGiftService = [[HGVirtualGiftService alloc] init];
    }
    return virtualGiftService;
}

- (void)dealloc {
    [sendVirtualGiftLoader release];
    [getGIFGiftsLoader release];
    [gifGiftsByCategory release];

    [super dealloc];
}

- (void)requestGIFGifts {
    if (getGIFGiftsLoader != nil) {
        [getGIFGiftsLoader cancel];
    } else {
        getGIFGiftsLoader = [[HGVirtualGiftLoader alloc] init];
        getGIFGiftsLoader.delegate = self;
    }
    [getGIFGiftsLoader requestGIFGifts];
}

- (void)requestGIFGiftsForCategory:(NSString*)category withOffset:(int)offset andCount:(int)count {
    if (getGIFGiftsLoader != nil) {
        [getGIFGiftsLoader cancel];
    } else {
        getGIFGiftsLoader = [[HGVirtualGiftLoader alloc] init];
        getGIFGiftsLoader.delegate = self;
    }
    [getGIFGiftsLoader requestGIFGiftsForCategory:category withOffset:offset andCount:count];
}

- (void)requestSendVirtualGift:(int)profileNetwork andProfileId:(NSString*)profileId 
                      giftType:(NSString*)giftType giftId:(NSString*)giftId 
                       tweetId:(NSString*)tweetId tweetText:(NSString*)tweetText tweetPic:(NSString*)tweetPic {
    if (sendVirtualGiftLoader != nil) {
        [sendVirtualGiftLoader cancel];
    } else {
        sendVirtualGiftLoader = [[HGVirtualGiftLoader alloc] init];
        sendVirtualGiftLoader.delegate = self;
    }
    
    [sendVirtualGiftLoader requestSendVirtualGift:profileNetwork andProfileId:profileId giftType:giftType giftId:giftId tweetId:tweetId tweetText:tweetText tweetPic:tweetPic];
}

#pragma mark HGVirtualGiftLoaderDelegate

- (void)virtualGiftLoader:(HGVirtualGiftLoader *)virtualGiftLoader didRequestSendVirtualGiftSucceed:(NSString*)orderId {
    HGDebug(@"didRequestSendVirtualGiftSucceed");
    
    if ([delegate respondsToSelector:@selector(virtualGiftService:didRequestSendVirtualGiftSucceed:)]){
        [delegate virtualGiftService:self didRequestSendVirtualGiftSucceed:orderId];
    }
}


- (void)virtualGiftLoader:(HGVirtualGiftLoader *)virtualGiftLoader didRequestSendVirtualGiftFail:(NSString*)error {
    HGWarning(@"didRequestSendVirtualGiftFail request failed");
    
    if ([delegate respondsToSelector:@selector(virtualGiftService:didRequestSendVirtualGiftFail:)]){
        [delegate virtualGiftService:self didRequestSendVirtualGiftFail:error];
    }
}

- (void)virtualGiftLoader:(HGVirtualGiftLoader *)virtualGiftLoader didRequestGIFGiftsSucceed:(NSMutableDictionary*)gifGifts {
    HGDebug(@"didRequestGIFGiftsSucceed");
    
    if (gifGiftsByCategory) {
        [gifGiftsByCategory release];
        gifGiftsByCategory = nil;
    }
    
    gifGiftsByCategory = [gifGifts retain];
    
    if ([delegate respondsToSelector:@selector(virtualGiftService:didRequestGIFGiftsSucceed:)]){
        [delegate virtualGiftService:self didRequestGIFGiftsSucceed:gifGifts];
    }
}

- (void)virtualGiftLoader:(HGVirtualGiftLoader *)virtualGiftLoader didRequestGIFGiftsFail:(NSString*)error {
    HGWarning(@"didRequestGIFGiftsFail request failed:%@", error);
    
    if ([delegate respondsToSelector:@selector(virtualGiftService:didRequestGIFGiftsFail:)]){
        [delegate virtualGiftService:self didRequestGIFGiftsFail:error];
    }
}

- (void)virtualGiftLoader:(HGVirtualGiftLoader *)virtualGiftLoader didRequestGIFGiftsForCategorySucceed:(NSDictionary*)gifGifts {
    
    HGDebug(@"didRequestGIFGiftsForCategorySucceed");
    
    if ([delegate respondsToSelector:@selector(virtualGiftService:didRequestGIFGiftsForCategorySucceed:)]){
        [delegate virtualGiftService:self didRequestGIFGiftsForCategorySucceed:gifGifts];
    }
}

- (void)virtualGiftLoader:(HGVirtualGiftLoader *)virtualGiftLoader didRequestGIFGiftsForCategoryFail:(NSString*)error {
    HGWarning(@"didRequestGIFGiftsForCategoryFail request failed:%@", error);
    
    if ([delegate respondsToSelector:@selector(virtualGiftService:didRequestGIFGiftsForCategoryFail:)]){
        [delegate virtualGiftService:self didRequestGIFGiftsForCategoryFail:error];
    }
}
@end
