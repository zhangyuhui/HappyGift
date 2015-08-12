//
//  HGAstroTrendLoader.h
//  HappyGift
//
//  Created by Yujian Weng on 12-7-4.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HGNetworkConnection.h"

@class HGAstroTrend;
@protocol HGAstroTrendLoaderDelegate;

@interface HGAstroTrendLoader : HGNetworkConnection {
    BOOL running;
    int  requestType;
    int  requestAstroTrendsOffset;
}

@property (nonatomic, assign)   id<HGAstroTrendLoaderDelegate> delegate;
@property (nonatomic, readonly) BOOL  running;

- (void)requestAstroTrendWithOffset:(int)offset andCount:(int)count;
- (void)requestAstroTrendForFriend:(int)profileNetwork andProfileId:(NSString*)profileId withOffset:(int)offset andCount:(int)count;
- (void)requestAstroTrendGIFGiftsForFriend:(int)profileNetwork andProfileId:(NSString*)profileId withOffset:(int)offset andCount:(int)count;
- (NSArray*) astroTrendsLoaderCache;

@end

@protocol HGAstroTrendLoaderDelegate

- (void)astroTrendLoader:(HGAstroTrendLoader *)astroTrendLoader didRequestAstroTrendSucceed:(NSArray*)astroTrendArray;
- (void)astroTrendLoader:(HGAstroTrendLoader *)astroTrendLoader didRequestAstroTrendFail:(NSString*)error;

- (void)astroTrendLoader:(HGAstroTrendLoader *)astroTrendLoader didRequestAstroTrendForFriendSucceed:(HGAstroTrend*)astroTrend;
- (void)astroTrendLoader:(HGAstroTrendLoader *)astroTrendLoader didRequestAstroTrendForFriendFail:(NSString*)error;


- (void)astroTrendLoader:(HGAstroTrendLoader *)astroTrendLoader didRequestAstroTrendGIFGiftsForFriendSucceed:(HGAstroTrend*)astroTrend;
- (void)astroTrendLoader:(HGAstroTrendLoader *)astroTrendLoader didRequestAstroTrendGIFGiftsForFriendFail:(NSString*)error;
@end
