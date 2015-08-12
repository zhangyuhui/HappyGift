//
//  HGAstroTrendService.h
//  HappyGift
//
//  Created by Yujian Weng on 12-7-4.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HGAstroTrendLoader;
@class HGAstroTrend;
@protocol HGAstroTrendServiceDelegate;

@interface HGAstroTrendService : NSObject {
    HGAstroTrendLoader* astroTrendLoader;
    HGAstroTrendLoader* astroTrendForFriendLoader;
    id<HGAstroTrendServiceDelegate> delegate;
    
    NSArray* astroTrends;
    
    NSDictionary* astroConfig;
    NSDictionary* trendConfig;
    int requestType;
}

@property (nonatomic, assign) id<HGAstroTrendServiceDelegate> delegate;
@property (nonatomic, retain) NSArray* astroTrends;
@property (nonatomic, retain) NSDictionary* astroConfig;
@property (nonatomic, retain) NSDictionary* trendConfig;

+ (HGAstroTrendService*)sharedService;
- (void)requestAstroTrend;
- (void)requestMoreAstroTrend:(int)count;
- (void)requestMoreAstroTrendForFriend:(int)profileNetwork andProfileId:(NSString*)profileId withOffset:(int)offset andCount:(int)count;
- (void)requestMoreAstroTrendGIFGiftsForFriend:(int)profileNetwork andProfileId:(NSString*)profileId withOffset:(int)offset andCount:(int)count;
- (void)clearAstroTrends;

@end

@protocol HGAstroTrendServiceDelegate <NSObject>
@optional
- (void)astroTrendService:(HGAstroTrendService *)astroTrendService didRequestAstroTrendSucceed:(NSArray*)theAstroTrends;
- (void)astroTrendService:(HGAstroTrendService *)astroTrendService didRequestAstroTrendFail:(NSString*)error;

- (void)astroTrendService:(HGAstroTrendService *)astroTrendService didRequestAstroTrendForFriendSucceed:(HGAstroTrend*)theAstroTrend;
- (void)astroTrendService:(HGAstroTrendService *)astroTrendService didRequestAstroTrendForFriendFail:(NSString*)error;

- (void)astroTrendService:(HGAstroTrendService *)astroTrendService didRequestAstroTrendGIFGiftsForFriendSucceed:(HGAstroTrend*)theAstroTrend;
- (void)astroTrendService:(HGAstroTrendService *)astroTrendService didRequestAstroTrendGIFGiftsForFriendFail:(NSString*)error;

@end

