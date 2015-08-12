//
//  HGSplashService.h
//  HappyGift
//
//  Created by Zhang Yuhui on 02/09/12.
//  Copyright 2011 Ztelic Inc Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
@class HGSplash;
@class HGSplashLoader;
@protocol HGSplashServiceDelegate;

@interface HGSplashService : NSObject {
    HGSplash*  splash;
    HGSplashLoader* splashLoader;
    id<HGSplashServiceDelegate> delegate;
    NSDate*   splashTimestamp;
}
@property (nonatomic, retain) HGSplash* splash;
@property (nonatomic, retain) NSDate*   splashTimestamp;
@property (nonatomic, assign) id<HGSplashServiceDelegate> delegate;

+ (HGSplashService*)sharedService;

- (void)checkUpdate;
@end

@protocol HGSplashServiceDelegate<NSObject>
- (void)splashService:(HGSplashService *)splashService didSplashSucceed:(HGSplash*)splash;
- (void)splashService:(HGSplashService *)splashService didSplashFail:(NSString*)error;
@end
