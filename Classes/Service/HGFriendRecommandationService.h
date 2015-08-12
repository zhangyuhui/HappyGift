//
//  HGFriendRecommandationService.h
//  HappyGift
//
//  Created by Yujian Weng on 12-6-11.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HGFriendRecommandationLoader;
@protocol HGFriendRecommandationServiceDelegate;

@interface HGFriendRecommandationService : NSObject {
    HGFriendRecommandationLoader* friendRecommandationLoader;
    id<HGFriendRecommandationServiceDelegate> delegate;
    
    NSArray* friendRecommandations;
    NSTimer* dataInitializationRequestTimer;
    int dataInitializationRequestCount;
}

@property (nonatomic, assign) id<HGFriendRecommandationServiceDelegate> delegate;
@property (nonatomic, retain) NSArray* friendRecommandations;
@property (nonatomic, assign) int dataInitializationRequestCount;

+ (HGFriendRecommandationService*)sharedService;
- (void)requestFriendRecommandation;
- (void)requestMoreFriendRecommandation:(int)count;

@end

@protocol HGFriendRecommandationServiceDelegate <NSObject>
- (void)friendRecommandationService:(HGFriendRecommandationService *)friendRecommandationService didRequestFriendRecommandationSucceed:(NSArray*)theRecommandations;

- (void)friendRecommandationService:(HGFriendRecommandationService *)friendRecommandationService didRequestFriendRecommandationFail:(NSString*)error;
@end

