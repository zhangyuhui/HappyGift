//
//  HGFriendRecommandationLoader.h
//  HappyGift
//
//  Created by Yujian Weng on 12-6-11.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HGNetworkConnection.h"

@protocol HGFriendRecommandationLoaderDelegate;

@interface HGFriendRecommandationLoader : HGNetworkConnection {
    BOOL running;
    int  requestType;
}

@property (nonatomic, assign)   id<HGFriendRecommandationLoaderDelegate> delegate;
@property (nonatomic, readonly) BOOL  running;

- (void)requestFriendRecommandationWithOffset:(int)offset andCount:(int)count;

@end

@protocol HGFriendRecommandationLoaderDelegate

- (void)friendRecommandationLoader:(HGFriendRecommandationLoader *)friendRecommandationLoader didRequestFriendRecommandationSucceed:(NSArray*)Recommandation;

- (void)friendRecommandationLoader:(HGFriendRecommandationLoader *)friendRecommandationLoader didRequestFriendRecommandationFail:(NSString*)error;

@end
