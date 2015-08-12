//
//  HGFriendEmotionLoader.h
//  HappyGift
//
//  Created by Yujian Weng on 12-7-9.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HGNetworkConnection.h"

@class HGFriendEmotion;
@protocol HGFriendEmotionLoaderDelegate;

@interface HGFriendEmotionLoader : HGNetworkConnection {
    BOOL running;
    int  requestType;
    int  requestFriendEmotionsOffset;
}

@property (nonatomic, assign)   id<HGFriendEmotionLoaderDelegate> delegate;
@property (nonatomic, readonly) BOOL  running;

- (void)requestFriendEmotionWithOffset:(int)offset andCount:(int)count; 
- (void)requestFriendEmotionForFriend:(int)profileNetwork andProfileId:(NSString*)profileId withOffset:(int)offset andCount:(int)count;
- (void)requestFriendEmotionGIFGiftsForFriend:(int)profileNetwork andProfileId:(NSString*)profileId withOffset:(int)offset andCount:(int)count;
- (NSArray*) friendEmotionsLoaderCache;

@end

@protocol HGFriendEmotionLoaderDelegate

- (void)friendEmotionLoader:(HGFriendEmotionLoader *)friendEmotionLoader didRequestFriendEmotionSucceed:(NSArray*)friendEmotionArray;
- (void)friendEmotionLoader:(HGFriendEmotionLoader *)friendEmotionLoader didRequestFriendEmotionFail:(NSString*)error;


- (void)friendEmotionLoader:(HGFriendEmotionLoader *)friendEmotionLoader didRequestFriendEmotionForFriendSucceed:(HGFriendEmotion*)friendEmotion;
- (void)friendEmotionLoader:(HGFriendEmotionLoader *)friendEmotionLoader didRequestFriendEmotionForFriendFail:(NSString*)error;

- (void)friendEmotionLoader:(HGFriendEmotionLoader *)friendEmotionLoader didRequestFriendEmotionGIFGiftsForFriendSucceed:(HGFriendEmotion*)friendEmotion;
- (void)friendEmotionLoader:(HGFriendEmotionLoader *)friendEmotionLoader didRequestFriendEmotionGIFGiftsForFriendFail:(NSString*)error;
@end
