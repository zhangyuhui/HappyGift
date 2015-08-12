//
//  HGFriendRecommandationService.h
//  HappyGift
//
//  Created by Yujian Weng on 12-6-11.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//

#import "HGFriendRecommandationService.h"
#import "HGFriendRecommandationLoader.h"
#import "HGConstants.h"
#import "HappyGiftAppDelegate.h"

static HGFriendRecommandationService* recommandationService;

#define kRequestFriendRecommandationCount 9
#define kMinFriendRecommandationCount 6
#define kMaxRequestCountForDataInitialization 2
#define kRequestIntervalForDataInitialization 30.0

@interface HGFriendRecommandationService () <HGFriendRecommandationLoaderDelegate>

@end

@implementation HGFriendRecommandationService
@synthesize delegate;
@synthesize friendRecommandations;
@synthesize dataInitializationRequestCount;

+ (HGFriendRecommandationService*)sharedService {
    if (recommandationService == nil) {
        recommandationService = [[HGFriendRecommandationService alloc] init];
        recommandationService.dataInitializationRequestCount = 0;
    }
    return recommandationService;
}

- (void)dealloc {
    if (friendRecommandationLoader && friendRecommandationLoader.delegate == self) {
        friendRecommandationLoader.delegate = nil;
    }
    
    [friendRecommandationLoader release];
    
    self.friendRecommandations = nil;
    
    if (dataInitializationRequestTimer) {
        [dataInitializationRequestTimer invalidate];
        dataInitializationRequestTimer = nil;
    }

    [super dealloc];
}

- (void)requestFriendRecommandation {
    dataInitializationRequestCount = 1;
    [self doRequestMoreFriendRecommandation:kRequestFriendRecommandationCount];
}

- (void)requestMoreFriendRecommandation:(int)count {
    // cancel auto request when load more 
    if (dataInitializationRequestTimer) {
        [dataInitializationRequestTimer invalidate];
        dataInitializationRequestTimer = nil;
    }
    dataInitializationRequestCount = kMaxRequestCountForDataInitialization;
    [self doRequestMoreFriendRecommandation:count];
}

- (void)doRequestMoreFriendRecommandation:(int)count {
    if (friendRecommandationLoader != nil) {
        [friendRecommandationLoader cancel];
    } else {
        friendRecommandationLoader = [[HGFriendRecommandationLoader alloc] init];
        friendRecommandationLoader.delegate = self;
    }
    
    int offset = friendRecommandations ? [friendRecommandations count] : 0;
    [friendRecommandationLoader requestFriendRecommandationWithOffset:offset andCount:count];
}

-(void)handleDataInitializationRequestTimer:(NSTimer*)timer {
    dataInitializationRequestTimer = nil;
    dataInitializationRequestCount++;
    [self doRequestMoreFriendRecommandation:kRequestFriendRecommandationCount - [friendRecommandations count]];
}

#pragma mark HGFriendRecommandationLoaderDelegate

- (void)friendRecommandationLoader:(HGFriendRecommandationLoader *)friendRecommandationLoader didRequestFriendRecommandationSucceed:(NSArray*)theRecommandation {
    BOOL updated = NO;
    if (friendRecommandations) {
        if (theRecommandation && [theRecommandation count] > 0) {
            NSMutableArray* newFriendRecommandations = [[NSMutableArray alloc] initWithArray:friendRecommandations];
            [newFriendRecommandations addObjectsFromArray:theRecommandation];
            self.friendRecommandations = newFriendRecommandations;
            [newFriendRecommandations release];
            updated = YES;
        }
    } else {
        self.friendRecommandations = theRecommandation;
        updated = YES;
    }
    
    if (dataInitializationRequestCount < kMaxRequestCountForDataInitialization && 
        [friendRecommandations count] < kMinFriendRecommandationCount) {
        dataInitializationRequestTimer = [NSTimer scheduledTimerWithTimeInterval:kRequestIntervalForDataInitialization target:self selector:@selector(handleDataInitializationRequestTimer:) userInfo:nil repeats:NO];
    }
    
    if (updated) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kHGNotificationFriendRecommendationUpdated object:nil];
    }
    
    if ([delegate respondsToSelector:@selector(friendRecommandationService:didRequestFriendRecommandationSucceed:)]){
        [delegate friendRecommandationService:self didRequestFriendRecommandationSucceed:theRecommandation];
    }
}

- (void)friendRecommandationLoader:(HGFriendRecommandationLoader *)friendRecommandationLoader didRequestFriendRecommandationFail:(NSString*)error {
    
    if ([delegate respondsToSelector:@selector(friendRecommandationService:didRequestFriendRecommandationFail:)]){
        [delegate friendRecommandationService:self didRequestFriendRecommandationFail:error];
    }
}

@end
