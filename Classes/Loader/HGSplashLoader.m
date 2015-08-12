//
//  HGSplashLoader.m
//  HappyGift
//
//  Created by Zhang Yuhui on 3/22/11.
//  Copyright 2011 Ztelic Inc Inc. All rights reserved.
//

#import "HGSplashLoader.h"
#import "JSON.h"
#import "NSString+Addition.h"
#import "HGNetworkHost.h"
#import "HGSplash.h"
#import "HappyGiftAppDelegate.h"

static NSString *kTopicSplashFormat = @"%@/topic/get_splash";

@interface HGSplashLoader () 

@end


@implementation HGSplashLoader
@synthesize delegate;
@synthesize running;

- (id)init {
    if ((self = [super init])) {
		running = NO;
    }
    
    return self;
}

- (void)dealloc {
    [super dealloc];
}

- (void)cancel {
	running = NO;
}

- (void)requestSplash{
    if (running){
        return;
    }
    [self cancel];
    running = YES;
    
    NSString* requestString = [NSString stringWithFormat:kTopicSplashFormat, [HappyGiftAppDelegate backendServiceHost]];
    //HGDebug(@"%@", requestString);
    NSURL* requestURL = [NSURL URLWithString:[requestString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [super requestByGet:requestURL];
}


#pragma mark overrides
- (void)connectionDidFinishLoading:(NSURLConnection *)conn {
	[super connectionDidFinishLoading:conn];
    running = NO;
    
    NSString* jsonString = [NSString stringWithData:self.data];
    NSDictionary *jsonDictionary = [jsonString JSONValue];
    NSString* splashTitle = [jsonDictionary objectForKey:@"title"];
    NSDictionary* splashImageDictionary = [jsonDictionary objectForKey:@"image"]; 
    NSString* splashImageUrl = [splashImageDictionary objectForKey:@"url"];
    NSString* splashPubDate = [splashImageDictionary objectForKey:@"update_ts"];
    
    HGSplash* splash = [[HGSplash alloc] init];
    splash.url = splashImageUrl;
    splash.title = splashTitle;
    splash.pubDate = splashPubDate;
    
    if ([self.delegate respondsToSelector:@selector(splashLoader:didRequestSucceed:)]) {
        [self.delegate splashLoader:self didRequestSucceed:splash];
    }
    
    [splash release];
    
    [self end];
}


- (void)connection:(NSURLConnection *)conn didFailWithError:(NSError *)error {
    [super connection:conn didFailWithError:error];
	running = NO;
    if ([self.delegate respondsToSelector:@selector(splashLoader:didRequestFail:)]) {
        [self.delegate splashLoader:self didRequestFail:nil];
    }
    [self end];
}
@end
