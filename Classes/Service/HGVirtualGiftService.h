//
//  HGVirtualGiftService.h
//  HappyGift
//
//  Created by Yujian Weng on 12-7-31.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HGVirtualGiftLoader;
@protocol HGVirtualGiftServiceDelegate;

@interface HGVirtualGiftService : NSObject {
    HGVirtualGiftLoader* sendVirtualGiftLoader;
    HGVirtualGiftLoader* getGIFGiftsLoader;
    id<HGVirtualGiftServiceDelegate> delegate;
    
    NSMutableDictionary* gifGiftsByCategory;
}

@property (nonatomic, assign) id<HGVirtualGiftServiceDelegate> delegate;
@property (nonatomic, retain) NSMutableDictionary* gifGiftsByCategory;

+ (HGVirtualGiftService*)sharedService;
- (void)requestGIFGifts;
- (void)requestGIFGiftsForCategory:(NSString*)category withOffset:(int)offset andCount:(int)count;
- (void)requestSendVirtualGift:(int)profileNetwork andProfileId:(NSString*)profileId 
                      giftType:(NSString*)giftType giftId:(NSString*)giftId 
                       tweetId:(NSString*)tweetId tweetText:(NSString*)tweetText tweetPic:(NSString*)tweetPic;

@end

@protocol HGVirtualGiftServiceDelegate <NSObject>
@optional
- (void)virtualGiftService:(HGVirtualGiftService *)virtualGiftService didRequestSendVirtualGiftSucceed:(NSString*)orderId;
- (void)virtualGiftService:(HGVirtualGiftService *)virtualGiftService didRequestSendVirtualGiftFail:(NSString*)error;

- (void)virtualGiftService:(HGVirtualGiftService *)virtualGiftService didRequestGIFGiftsSucceed:(NSMutableDictionary*)gifGifts;
- (void)virtualGiftService:(HGVirtualGiftService *)virtualGiftService didRequestGIFGiftsFail:(NSString*)error;

- (void)virtualGiftService:(HGVirtualGiftService *)virtualGiftService didRequestGIFGiftsForCategorySucceed:(NSDictionary*)gifGifts;
- (void)virtualGiftService:(HGVirtualGiftService *)virtualGiftService didRequestGIFGiftsForCategoryFail:(NSString*)error;
@end

