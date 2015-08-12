//
//  HGSplashLoader.h
//  HappyGift
//
//  Created by Zhang Yuhui on 3/22/11.
//  Copyright 2011 Ztelic Inc Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HGNetworkConnection.h"
@class HGSplash;
@protocol HGSplashLoaderDelegate;

@interface HGSplashLoader : HGNetworkConnection {
	BOOL running;
    id<HGSplashLoaderDelegate> delegate;
}
@property (nonatomic, assign, readonly) BOOL running;
@property (nonatomic, assign) id<HGSplashLoaderDelegate> delegate;

- (void)requestSplash;

@end

@protocol HGSplashLoaderDelegate <NSObject>
- (void)splashLoader:(HGSplashLoader *)splashLoader didRequestSucceed:(HGSplash*)splash;
- (void)splashLoader:(HGSplashLoader *)splashLoader didRequestFail:(NSString*)error;
@end
