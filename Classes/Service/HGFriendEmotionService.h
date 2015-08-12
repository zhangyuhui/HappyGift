//
//  HGFriendEmotionService.h
//  HappyGift
//
//  Created by Yujian Weng on 12-7-9.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HGFriendEmotionLoader;
@class HGFriendEmotion;
@protocol HGFriendEmotionServiceDelegate;

@interface HGFriendEmotionService : NSObject {
    HGFriendEmotionLoader* friendEmotionLoader;
    HGFriendEmotionLoader* friendEmotionForFriendLoader;
    
    id<HGFriendEmotionServiceDelegate> delegate;
    
    NSArray* friendEmotions;
    int requestType;
}

@property (nonatomic, assign) id<HGFriendEmotionServiceDelegate> delegate;
@property (nonatomic, retain) NSArray* friendEmotions;

+ (HGFriendEmotionService*)sharedService;
- (void)requestFriendEmotions;
- (void)requestMoreFriendEmotion:(int)count;
- (void)requestMoreFriendEmotionForFriend:(int)profileNetwork andProfileId:(NSString*)profileId withOffset:(int)offset andCount:(int)count;
- (void)requestMoreFriendEmotionGIFGiftsForFriend:(int)profileNetwork andProfileId:(NSString*)profileId withOffset:(int)offset andCount:(int)count;
- (void)clearFriendEmotions;

@end

@protocol HGFriendEmotionServiceDelegate <NSObject>
@optional
- (void)friendEmotionService:(HGFriendEmotionService *)friendEmotionService didRequestFriendEmotionSucceed:(NSArray*)theFriendEmotions;
- (void)friendEmotionService:(HGFriendEmotionService *)friendEmotionService didRequestFriendEmotionFail:(NSString*)error;

- (void)friendEmotionService:(HGFriendEmotionService *)friendEmotionService didRequestFriendEmotionForFriendSucceed:(HGFriendEmotion*)theFriendEmotion;
- (void)friendEmotionService:(HGFriendEmotionService *)friendEmotionService didRequestFriendEmotionForFriendFail:(NSString*)error;

- (void)friendEmotionService:(HGFriendEmotionService *)friendEmotionService didRequestFriendEmotionGIFGiftsForFriendSucceed:(HGFriendEmotion*)theFriendEmotion;
- (void)friendEmotionService:(HGFriendEmotionService *)friendEmotionService didRequestFriendEmotionGIFGiftsForFriendFail:(NSString*)error;
@end

