//
//  HGTrackingLoader.h
//  HappyGift
//
//  Created by Zhang Yuhui on 02/09/12.
//  Copyright 2011 Ztelic Inc Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HGNetworkConnection.h"

@protocol HGTrackingLoaderDelegate;

@interface HGTrackingLoader : HGNetworkConnection {
    BOOL running;
}
@property (nonatomic, assign)   id<HGTrackingLoaderDelegate> delegate;
@property (nonatomic, readonly) BOOL  running;

- (void)requestTrackingUpload:(NSData*)trackingData;
@end


@protocol HGTrackingLoaderDelegate <NSObject>
- (void)trackingLoader:(HGTrackingLoader *)trackingLoader didRequestTrackingUploadSucceed:(NSString*)nothing;
- (void)trackingLoader:(HGTrackingLoader *)trackingLoader didRequestTrackingUploadFail:(NSString*)error;
@end
