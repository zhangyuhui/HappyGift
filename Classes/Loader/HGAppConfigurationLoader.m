//
//  HGAppConfigurationLoader.m
//  HappyGift
//
//  Created by Yujian Weng on 12-6-6.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//

#import "HGAppConfigurationLoader.h"
#import "JSON.h"
#import "HGNetworkHost.h"
#import "HGConstants.h"
#import "HGLogging.h"
#import "HappyGiftAppDelegate.h"
#import "NSString+Addition.h"
#import <sqlite3.h>
#import "HGLoaderCache.h"

#define kRequestTypeRequestAppConfiguration 0

static NSString *kAppConfigurationRequestFormat = @"http://api.lesongapp.cn/gift/index.php?route=app_config&version=%@&build=%@&device_id=%@";

@interface HGAppConfigurationLoader()
@end

@implementation HGAppConfigurationLoader
@synthesize delegate;
@synthesize running;

- (void)dealloc {
    [super dealloc];
}

- (void)cancel {	
    [super cancel];
    running = NO;
}

- (void)requestAppConfigurationForVersion:(NSString*)appVersion andBuild:(NSString*)appBuild andDeviceId:(NSString*)deviceId{
    if (running) {
        return;
    }
    [self cancel];
    requestType = kRequestTypeRequestAppConfiguration;
    running = YES;
    
    NSString* requestString = [NSString stringWithFormat:kAppConfigurationRequestFormat, appVersion, appBuild, deviceId];
    
    HGDebug(@"%@", requestString);
    NSURL* requestURL = [NSURL URLWithString:[requestString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    NSMutableDictionary* headers = nil;
    NSString* lastModifiedTime = [self getLastModifiedTimeOfAppConfiguration];
    
    if (lastModifiedTime) {
        headers = [NSMutableDictionary dictionaryWithObject:lastModifiedTime forKey:kHttpHeaderIfModifiedSince];
    }
    
    [super requestByGet:requestURL withHeaders:headers];
}

#pragma mark parse app configuration

- (void)handleAppConfigurationResponse:(NSData *)appConfigurationResponseData {
    NSAutoreleasePool * autoReleasePool = [[NSAutoreleasePool alloc] init];
    NSString* jsonString = [NSString stringWithData:self.data];
    
    HGDebug(@"%@", jsonString);
    NSDictionary* appConfiguration = nil;
    
    if (kHttpStatusCodeNotModified == [self.response statusCode]) {
        HGDebug(@"app config - got 304 not modifed");
    } else {
        if (jsonString != nil && [jsonString isEqualToString:@""] == NO) {
            @try {
                NSDictionary *jsonDictionary = [jsonString JSONValue];
                if (jsonDictionary != nil) {
                    appConfiguration = [jsonDictionary objectForKey:@"app_config"];
                }
            } @catch (NSException *e) {
                HGDebug(@"error on handleAppConfigurationResponse: %@", jsonString);
            }
            
            if (appConfiguration) {
                NSString* lastModifiedField = [self getLastModifiedHeader];
                HGDebug(@"new app config data - lastModified: %@", lastModifiedField);
                [self saveLastModifiedTimeOfAppConfiguration:lastModifiedField];
            }
        }
    }
    
    if (appConfiguration != nil) {
        [self performSelectorOnMainThread:@selector(notifyAppConfigurationData:) withObject:[NSDictionary dictionaryWithObjectsAndKeys:appConfiguration, @"appConfiguration", nil] waitUntilDone:YES];
    }else{
        [self performSelectorOnMainThread:@selector(notifyAppConfigurationData:) withObject:nil waitUntilDone:YES];
    }
    [autoReleasePool release];
}

- (void)notifyAppConfigurationData:(NSDictionary*)appConfigurationData {
    running = NO;
    NSDictionary* appConfiguration = [appConfigurationData objectForKey:@"appConfiguration"];
    if (appConfiguration != nil) {
        if ([(id)self.delegate respondsToSelector:@selector(appConfigurationLoader:didRequestAppConfigurationSucceed:)]) {
            [self.delegate appConfigurationLoader:self didRequestAppConfigurationSucceed:appConfiguration];
        }
    } else {
        if ([(id)self.delegate respondsToSelector:@selector(appConfigurationLoader:didRequestAppConfigurationFail:)]) {
            [self.delegate appConfigurationLoader:self didRequestAppConfigurationFail:nil];
        }
    }
    [self end];
}

#pragma mark overrides
- (void)connectionDidFinishLoading:(NSURLConnection *)conn {
    [super connectionDidFinishLoading:conn];
    if (requestType == kRequestTypeRequestAppConfiguration) {
        [self performSelectorInBackground:@selector(handleAppConfigurationResponse:) withObject:self.data];
    }
}

- (void)connection:(NSURLConnection *)conn didFailWithError:(NSError *)error {
    [super connection:conn didFailWithError:error];
	running = NO;
    
    if (requestType == kRequestTypeRequestAppConfiguration) {
        if ([(id)self.delegate respondsToSelector:@selector(appConfigurationLoader:didRequestAppConfigurationFail:)]) {
            [self.delegate appConfigurationLoader:self didRequestAppConfigurationFail:[error description]];
        }
    }
}


#pragma persistent response data

-(NSString*)getLastModifiedTimeOfAppConfiguration {
    return [HGLoaderCache lastModifiedTimeForKey:kCacheKeyLastModifiedTimeOfAppConfiguration];
}

-(void)saveLastModifiedTimeOfAppConfiguration:(NSString*)lastModifiedTimeOfAppConfiguration {
    [HGLoaderCache saveLastModifiedTime:lastModifiedTimeOfAppConfiguration forKey:kCacheKeyLastModifiedTimeOfAppConfiguration];
}
@end
