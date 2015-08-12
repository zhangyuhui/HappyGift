//
//  HGTrackingLoader.m
//  HappyGift
//
//  Created by Zhang Yuhui on 02/09/12.
//  Copyright 2011 Ztelic Inc. All rights reserved.
//

#import "HGTrackingLoader.h"
#import "JSON.h"
#import "HGNetworkHost.h"
#import "HGConstants.h"
#import "HappyGiftAppDelegate.h"
#import "NSString+Addition.h"
#import "HGLogging.h"

@interface HGTrackingLoader()
@end

@implementation HGTrackingLoader
@synthesize delegate;
@synthesize running;

static NSString *kRegisterDeviceTokenFormat = @"%@/gift/index.php?route=account/apns_token&device_token=%@";

- (void)dealloc {
    [super dealloc];
}

- (void)cancel {	
    [super cancel];
    running = NO;
}

- (void)requestTrackingUpload:(NSData*)trackingData{
    if (running){
        return;
    }
    [self cancel];
    running = YES;
    
    NSString* requestString = [NSString stringWithFormat:kRegisterDeviceTokenFormat, 
                           [HappyGiftAppDelegate backendServiceHost], trackingData];
    HGDebug(@"HGTrackingLoader %@", requestString);
    NSURL* requestURL = [NSURL URLWithString:[requestString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [super requestByGet:requestURL];
}

#pragma mark overrides
- (void)connectionDidFinishLoading:(NSURLConnection *)conn {
    [super connectionDidFinishLoading:conn];
    running = NO;
    NSString* jsonString = [NSString stringWithData:self.data];
    HGDebug(@"HGTrackingLoader %@", jsonString);
    if ([delegate respondsToSelector:@selector(trackingLoader:didRequestTrackingUploadSucceed:)]){
        [delegate trackingLoader:self didRequestTrackingUploadSucceed:nil];
    }
}

- (void)connection:(NSURLConnection *)conn didFailWithError:(NSError *)error {
    [super connection:conn didFailWithError:error];
	running = NO;
    if ([delegate respondsToSelector:@selector(trackingLoader:didRequestTrackingUploadFail:)]){
        [delegate trackingLoader:self didRequestTrackingUploadFail:[error description]];
    }
}
@end
