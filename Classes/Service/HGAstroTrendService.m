//
//  HGAstroTrendService.h
//  HappyGift
//
//  Created by Yujian Weng on 12-7-4.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//

#import "HGAstroTrendService.h"
#import "HGAstroTrendLoader.h"
#import "HGConstants.h"
#import "HappyGiftAppDelegate.h"
#import "HGLogging.h"

static HGAstroTrendService* astroTrendService;
#define kRequestInitialData 0
#define kRequestMoreData 1

@interface HGAstroTrendService () <HGAstroTrendLoaderDelegate>

@end

@implementation HGAstroTrendService
@synthesize delegate;
@synthesize astroTrends;
@synthesize astroConfig;
@synthesize trendConfig;

+ (HGAstroTrendService*)sharedService {
    if (astroTrendService == nil) {
        astroTrendService = [[HGAstroTrendService alloc] init];
        [astroTrendService loadAstroTrendConfig];
    }
    return astroTrendService;
}

- (id)init {
    self = [super init];
    if (self) {
        astroTrendLoader = [[HGAstroTrendLoader alloc] init];
        astroTrendLoader.delegate = self;
        astroTrends = [[astroTrendLoader astroTrendsLoaderCache] retain];
    }
    return self;
}

- (void)dealloc {
    if (astroTrendLoader && astroTrendLoader.delegate == self) {
        astroTrendLoader.delegate = nil;
    }
    
    [astroTrendLoader release];
    
    if (astroTrendForFriendLoader && astroTrendForFriendLoader.delegate == self) {
        astroTrendForFriendLoader.delegate = nil;
    }
    [astroTrendForFriendLoader release];
    [astroConfig release];
    [trendConfig release];
    
    self.astroTrends = nil;

    [super dealloc];
}

- (void)requestAstroTrend {
    if (astroTrendLoader != nil) {
        [astroTrendLoader cancel];
    } else {
        astroTrendLoader = [[HGAstroTrendLoader alloc] init];
        astroTrendLoader.delegate = self;
    }
    requestType = kRequestInitialData;
    [astroTrendLoader requestAstroTrendWithOffset:0 andCount:6];
}

- (void)requestMoreAstroTrend:(int)count {
    if (astroTrendLoader != nil) {
        [astroTrendLoader cancel];
    } else {
        astroTrendLoader = [[HGAstroTrendLoader alloc] init];
        astroTrendLoader.delegate = self;
    }
    requestType = kRequestMoreData;
    int offset = [astroTrends count];
    
    [astroTrendLoader requestAstroTrendWithOffset:offset andCount:count];
}

- (void)requestMoreAstroTrendForFriend:(int)profileNetwork andProfileId:(NSString*)profileId withOffset:(int)offset andCount:(int)count {
    if (astroTrendForFriendLoader != nil) {
        [astroTrendForFriendLoader cancel];
    } else {
        astroTrendForFriendLoader = [[HGAstroTrendLoader alloc] init];
        astroTrendForFriendLoader.delegate = self;
    }

    [astroTrendForFriendLoader requestAstroTrendForFriend:profileNetwork andProfileId:profileId withOffset:offset andCount:count];
}
- (void)requestMoreAstroTrendGIFGiftsForFriend:(int)profileNetwork andProfileId:(NSString*)profileId withOffset:(int)offset andCount:(int)count {
    if (astroTrendForFriendLoader != nil) {
        [astroTrendForFriendLoader cancel];
    } else {
        astroTrendForFriendLoader = [[HGAstroTrendLoader alloc] init];
        astroTrendForFriendLoader.delegate = self;
    }
    
    [astroTrendForFriendLoader requestAstroTrendGIFGiftsForFriend:profileNetwork andProfileId:profileId withOffset:offset andCount:count];
}

- (void)loadAstroTrendConfig {
    NSString *theAstroTrendConfigFile = [[NSBundle mainBundle] pathForResource:@"AstroTrendConfig" ofType:@"plist"];
    NSDictionary *theAstroTrendConfigDictionary = [NSDictionary dictionaryWithContentsOfFile:theAstroTrendConfigFile];
    
    trendConfig = [[theAstroTrendConfigDictionary objectForKey:@"kTrend"] retain];
    astroConfig = [[theAstroTrendConfigDictionary objectForKey:@"kAstro"] retain];
}

- (void)clearAstroTrends {
    if (astroTrends) {
        [astroTrends release];
        astroTrends = nil;
    }
}

#pragma mark HGAstroTrendLoaderDelegate

- (void)astroTrendLoader:(HGAstroTrendLoader *)astroTrendLoader didRequestAstroTrendSucceed:(NSArray*)theAstroTrends {
    if (requestType == kRequestMoreData && astroTrends) {
        NSMutableArray* newAstroTrends = [[NSMutableArray alloc] initWithArray:astroTrends];
        [newAstroTrends addObjectsFromArray:theAstroTrends];
        self.astroTrends = newAstroTrends;
        [newAstroTrends release];
    } else {
        self.astroTrends = theAstroTrends;
    }
    
    if ([delegate respondsToSelector:@selector(astroTrendService:didRequestAstroTrendSucceed:)]){
        [delegate astroTrendService:self didRequestAstroTrendSucceed:theAstroTrends];
    }
}

- (void)astroTrendLoader:(HGAstroTrendLoader *)theAstroTrendLoader didRequestAstroTrendFail:(NSString*)error {
    HGWarning(@"astroTrendLoader request failed");
    if (requestType == kRequestInitialData) {
        NSArray* theAstroTrends = [theAstroTrendLoader astroTrendsLoaderCache];
        if (theAstroTrends) {
            HGWarning(@"astroTrendLoader - use cached data");
            self.astroTrends = theAstroTrends;
        }
    }
    
    if ([delegate respondsToSelector:@selector(astroTrendService:didRequestAstroTrendFail:)]){
        [delegate astroTrendService:self didRequestAstroTrendFail:error];
    }
}

- (void)astroTrendLoader:(HGAstroTrendLoader *)astroTrendLoader didRequestAstroTrendForFriendSucceed:(HGAstroTrend*)astroTrend {
    HGDebug(@"didRequestAstroTrendForFriendSucceed");
    
    if ([delegate respondsToSelector:@selector(astroTrendService:didRequestAstroTrendForFriendSucceed:)]){
        [delegate astroTrendService:self didRequestAstroTrendForFriendSucceed:astroTrend];
    }
}

- (void)astroTrendLoader:(HGAstroTrendLoader *)astroTrendLoader didRequestAstroTrendForFriendFail:(NSString*)error {
    HGWarning(@"didRequestAstroTrendForFriendFail");
    
    if ([delegate respondsToSelector:@selector(astroTrendService:didRequestAstroTrendForFriendFail:)]){
        [delegate astroTrendService:self didRequestAstroTrendForFriendFail:error];
    }
}

- (void)astroTrendLoader:(HGAstroTrendLoader *)astroTrendLoader didRequestAstroTrendGIFGiftsForFriendSucceed:(HGAstroTrend*)astroTrend {
    HGDebug(@"didRequestAstroTrendGIFGiftsForFriendSucceed");
    
    if ([delegate respondsToSelector:@selector(astroTrendService:didRequestAstroTrendGIFGiftsForFriendSucceed:)]){
        [delegate astroTrendService:self didRequestAstroTrendGIFGiftsForFriendSucceed:astroTrend];
    }
}

- (void)astroTrendLoader:(HGAstroTrendLoader *)astroTrendLoader didRequestAstroTrendGIFGiftsForFriendFail:(NSString*)error {
    HGWarning(@"didRequestAstroTrendGIFGiftsForFriendFail");
    
    if ([delegate respondsToSelector:@selector(astroTrendService:didRequestAstroTrendGIFGiftsForFriendFail:)]){
        [delegate astroTrendService:self didRequestAstroTrendGIFGiftsForFriendFail:error];
    }
}
@end
