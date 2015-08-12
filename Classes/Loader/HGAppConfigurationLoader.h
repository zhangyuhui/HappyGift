//
//  HGAppConfigurationLoader.h
//  HappyGift
//
//  Created by Yujian Weng on 12-6-6.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HGNetworkConnection.h"

@protocol HGAppConfigurationLoaderDelegate;

@interface HGAppConfigurationLoader : HGNetworkConnection {
    BOOL running;
    int requestType;
}

@property (nonatomic, assign)   id<HGAppConfigurationLoaderDelegate> delegate;
@property (nonatomic, readonly) BOOL running;

- (void)requestAppConfigurationForVersion:(NSString*)appVersion andBuild:(NSString*)appBuild andDeviceId:(NSString*)deviceId;

@end

@protocol HGAppConfigurationLoaderDelegate
- (void)appConfigurationLoader:(HGAppConfigurationLoader *)appConfigurationLoader didRequestAppConfigurationSucceed:(NSDictionary*)appConfiguration;

- (void)appConfigurationLoader:(HGAppConfigurationLoader *)appConfigurationLoader didRequestAppConfigurationFail:(NSString*)error;
@end

