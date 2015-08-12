//
//  HGVirtualGiftLoader.h
//  HappyGift
//
//  Created by Yujian Weng on 12-7-31.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HGNetworkConnection.h"

@protocol HGVirtualGiftLoaderDelegate;

@interface HGVirtualGiftLoader : HGNetworkConnection {
    BOOL running;
    int  requestType;
}

@property (nonatomic, assign)   id<HGVirtualGiftLoaderDelegate> delegate;
@property (nonatomic, readonly) BOOL  running;

- (void)requestSendVirtualGift:(int)profileNetwork andProfileId:(NSString*)profileId 
                      giftType:(NSString*)giftType giftId:(NSString*)giftId 
                       tweetId:(NSString*)tweetId tweetText:(NSString*)tweetText tweetPic:(NSString*)tweetPic;

- (void)requestGIFGifts;
- (void)requestGIFGiftsForCategory:(NSString*)category withOffset:(int)offset andCount:(int)count;
@end

@protocol HGVirtualGiftLoaderDelegate

- (void)virtualGiftLoader:(HGVirtualGiftLoader *)virtualGiftLoader didRequestSendVirtualGiftSucceed:(NSString*)orderId;
- (void)virtualGiftLoader:(HGVirtualGiftLoader *)virtualGiftLoader didRequestSendVirtualGiftFail:(NSString*)error;

- (void)virtualGiftLoader:(HGVirtualGiftLoader *)virtualGiftLoader didRequestGIFGiftsSucceed:(NSMutableDictionary*)gifGifts;
- (void)virtualGiftLoader:(HGVirtualGiftLoader *)virtualGiftLoader didRequestGIFGiftsFail:(NSString*)error;

- (void)virtualGiftLoader:(HGVirtualGiftLoader *)virtualGiftLoader didRequestGIFGiftsForCategorySucceed:(NSDictionary*)gifGifts;
- (void)virtualGiftLoader:(HGVirtualGiftLoader *)virtualGiftLoader didRequestGIFGiftsForCategoryFail:(NSString*)error;
@end
