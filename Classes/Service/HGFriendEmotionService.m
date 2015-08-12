//
//  HGFriendEmotionService.h
//  HappyGift
//
//  Created by Yujian Weng on 12-7-9.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//

#import "HGFriendEmotionService.h"
#import "HGFriendEmotionLoader.h"
#import "HGConstants.h"
#import "HappyGiftAppDelegate.h"
#import "HGLogging.h"

static HGFriendEmotionService* friendEmotionService;

#define kRequestInitialData 0
#define kRequestMoreData 1

@interface HGFriendEmotionService () <HGFriendEmotionLoaderDelegate>

@end

@implementation HGFriendEmotionService
@synthesize delegate;
@synthesize friendEmotions;

+ (HGFriendEmotionService*)sharedService {
    if (friendEmotionService == nil) {
        friendEmotionService = [[HGFriendEmotionService alloc] init];
    }
    return friendEmotionService;
}

- (id) init {
    self = [super init];
    if (self) {
        friendEmotionLoader = [[HGFriendEmotionLoader alloc] init];
        friendEmotionLoader.delegate = self;
        friendEmotions = [[friendEmotionLoader friendEmotionsLoaderCache] retain];
    }
    return self;
}

- (void)dealloc {
    if (friendEmotionLoader && friendEmotionLoader.delegate == self) {
        friendEmotionLoader.delegate = nil;
    }
    
    [friendEmotionLoader release];
    
    self.friendEmotions = nil;

    [super dealloc];
}

- (void)requestFriendEmotions {
    if (friendEmotionLoader != nil) {
        [friendEmotionLoader cancel];
    } else {
        friendEmotionLoader = [[HGFriendEmotionLoader alloc] init];
        friendEmotionLoader.delegate = self;
    }
    
    requestType = kRequestInitialData;
    [friendEmotionLoader requestFriendEmotionWithOffset:0 andCount:6];
}

- (void)requestMoreFriendEmotion:(int)count {
    if (friendEmotionLoader != nil) {
        [friendEmotionLoader cancel];
    } else {
        friendEmotionLoader = [[HGFriendEmotionLoader alloc] init];
        friendEmotionLoader.delegate = self;
    }
    
    requestType = kRequestMoreData;
    int offset = [friendEmotions count];
    
    [friendEmotionLoader requestFriendEmotionWithOffset:offset andCount:count];
}

- (void)requestMoreFriendEmotionForFriend:(int)profileNetwork andProfileId:(NSString*)profileId withOffset:(int)offset andCount:(int)count {
    if (friendEmotionForFriendLoader != nil) {
        [friendEmotionForFriendLoader cancel];
    } else {
        friendEmotionForFriendLoader = [[HGFriendEmotionLoader alloc] init];
        friendEmotionForFriendLoader.delegate = self;
    }

    [friendEmotionForFriendLoader requestFriendEmotionForFriend:profileNetwork andProfileId:profileId withOffset:offset andCount:count];
}

- (void)requestMoreFriendEmotionGIFGiftsForFriend:(int)profileNetwork andProfileId:(NSString*)profileId withOffset:(int)offset andCount:(int)count {
    if (friendEmotionForFriendLoader != nil) {
        [friendEmotionForFriendLoader cancel];
    } else {
        friendEmotionForFriendLoader = [[HGFriendEmotionLoader alloc] init];
        friendEmotionForFriendLoader.delegate = self;
    }
    
    [friendEmotionForFriendLoader requestFriendEmotionGIFGiftsForFriend:profileNetwork andProfileId:profileId withOffset:offset andCount:count];
}

- (void)clearFriendEmotions {
    if (friendEmotions) {
        [friendEmotions release];
        friendEmotions = nil;
    }
}

#pragma mark HGFriendEmotionLoaderDelegate

- (void)friendEmotionLoader:(HGFriendEmotionLoader *)friendEmotionLoader didRequestFriendEmotionSucceed:(NSArray*)theFriendEmotions {

    if (requestType == kRequestMoreData && friendEmotions) {
        NSMutableArray* newFriendEmotions = [[NSMutableArray alloc] initWithArray:friendEmotions];
        [newFriendEmotions addObjectsFromArray:theFriendEmotions];
        self.friendEmotions = newFriendEmotions;
        [newFriendEmotions release];
    } else {
         self.friendEmotions = theFriendEmotions;
    }
    
    if ([delegate respondsToSelector:@selector(friendEmotionService:didRequestFriendEmotionSucceed:)]){
        [delegate friendEmotionService:self didRequestFriendEmotionSucceed:theFriendEmotions];
    }
}

- (void)friendEmotionLoader:(HGFriendEmotionLoader *)theFriendEmotionLoader didRequestFriendEmotionFail:(NSString*)error {
    HGWarning(@"friendEmotionLoader request failed");
    
    if (requestType == kRequestInitialData) {
        NSArray* theFriendEmotions = [theFriendEmotionLoader friendEmotionsLoaderCache];
        if (theFriendEmotions) {
            HGWarning(@"friendEmotionLoader - use cached data");
            self.friendEmotions = theFriendEmotions;
        }
    }
    
    if ([delegate respondsToSelector:@selector(friendEmotionService:didRequestFriendEmotionFail:)]){
        [delegate friendEmotionService:self didRequestFriendEmotionFail:error];
    }
}


- (void)friendEmotionLoader:(HGFriendEmotionLoader *)friendEmotionLoader didRequestFriendEmotionForFriendSucceed:(HGFriendEmotion*)friendEmotion {
    HGDebug(@"didRequestFriendEmotionForFriendSucceed");
    
    if ([delegate respondsToSelector:@selector(friendEmotionService:didRequestFriendEmotionForFriendSucceed:)]){
        [delegate friendEmotionService:self didRequestFriendEmotionForFriendSucceed:friendEmotion];
    }
}

- (void)friendEmotionLoader:(HGFriendEmotionLoader *)friendEmotionLoader didRequestFriendEmotionForFriendFail:(NSString*)error {
    HGWarning(@"didRequestFriendEmotionForFriendFail");
    
    if ([delegate respondsToSelector:@selector(friendEmotionService:didRequestFriendEmotionForFriendFail:)]){
        [delegate friendEmotionService:self didRequestFriendEmotionForFriendFail:error];
    }
}

- (void)friendEmotionLoader:(HGFriendEmotionLoader *)friendEmotionLoader didRequestFriendEmotionGIFGiftsForFriendSucceed:(HGFriendEmotion*)friendEmotion {
    HGDebug(@"didRequestFriendEmotionGIFGiftsForFriendSucceed");
    
    if ([delegate respondsToSelector:@selector(friendEmotionService:didRequestFriendEmotionGIFGiftsForFriendSucceed:)]){
        [delegate friendEmotionService:self didRequestFriendEmotionGIFGiftsForFriendSucceed:friendEmotion];
    }
}

- (void)friendEmotionLoader:(HGFriendEmotionLoader *)friendEmotionLoader didRequestFriendEmotionGIFGiftsForFriendFail:(NSString*)error {
    HGWarning(@"didRequestFriendEmotionGIFGiftsForFriendFail");
    
    if ([delegate respondsToSelector:@selector(friendEmotionService:didRequestFriendEmotionGIFGiftsForFriendFail:)]){
        [delegate friendEmotionService:self didRequestFriendEmotionGIFGiftsForFriendFail:error];
    }
}

@end
