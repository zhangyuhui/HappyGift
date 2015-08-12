//
//  HGFeedbackLoader.m
//  HappyGift
//
//  Created by Yujian Weng on 12-6-6.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//

#import "HGFeedbackLoader.h"
#import "JSON.h"
#import "HGNetworkHost.h"
#import "HGConstants.h"
#import "HGLogging.h"
#import "HappyGiftAppDelegate.h"
#import "NSString+Addition.h"
#import <sqlite3.h>

static NSString *kFeedbackRequestFormat = @"%@/gift/index.php?route=user/feedback&content=%@";


@interface HGFeedbackLoader()
@end

@implementation HGFeedbackLoader
@synthesize delegate;
@synthesize running;

- (void)dealloc {
    [super dealloc];
}

- (void)cancel {	
    [super cancel];
    running = NO;
}

- (void)requestUploadFeedback:(NSString*)feedback userName:(NSString*)userName userPhone:(NSString*)userPhone userEmail:(NSString*)userEmail{
    if (running) {
        return;
    }
    [self cancel];
    running = YES;
    
    NSMutableString* requestString = [[NSMutableString alloc] init];
    [requestString appendFormat:kFeedbackRequestFormat, [HappyGiftAppDelegate backendServiceHost], feedback];
    if (userName != nil && [userName isEqualToString:@""] == NO){
        [requestString appendFormat:@"&name=%@", userName];
    }
    if (userPhone != nil && [userPhone isEqualToString:@""] == NO){
        [requestString appendFormat:@"&phone=%@", userPhone];
    }
    if (userEmail != nil && [userEmail isEqualToString:@""] == NO){
        [requestString appendFormat:@"&email=%@", userEmail];
    }
    HGDebug(@"%@", requestString);
    NSURL* requestURL = [NSURL URLWithString:[requestString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [requestString release];
    [super requestByGet:requestURL];
}

#pragma mark parse app configuration

- (void)handleParseUploadFeedbackResponse:(NSData *)uploadFeedbackResponseData {
    NSAutoreleasePool * autoReleasePool = [[NSAutoreleasePool alloc] init];
    NSString* jsonString = [NSString stringWithData:uploadFeedbackResponseData];
    HGDebug(@"%@", jsonString);
    NSString* error = nil;
    if (jsonString != nil && [jsonString isEqualToString:@""] == NO) {
        @try {
            NSDictionary *jsonDictionary = [jsonString JSONValue];
            if (jsonDictionary != nil) {
                error = [jsonDictionary objectForKey:@"error"];
            }
        } @catch (NSException *e) {
            HGDebug(@"error on handleParseUploadFeedbackResponse: %@", jsonString);
        }
    }
    
    if (error != nil && [error isEqualToString:@""] == YES) {
        [self performSelectorOnMainThread:@selector(handleNotifyUploadFeedbackResponse:) withObject:[NSDictionary dictionaryWithObjectsAndKeys:error, @"error", nil] waitUntilDone:YES];
    }else{
        [self performSelectorOnMainThread:@selector(handleNotifyUploadFeedbackResponse:) withObject:nil waitUntilDone:YES];
    }
    [autoReleasePool release];
}

- (void)handleNotifyUploadFeedbackResponse:(NSDictionary*)appConfigurationData {
    running = NO;
    NSString* error = [appConfigurationData objectForKey:@"error"];
    if (error != nil && [error isEqualToString:@""] == YES) {
        if ([(id)self.delegate respondsToSelector:@selector(feedbackLoader:didRequestUploadFeedbackSucceed:)]) {
            [self.delegate feedbackLoader:self didRequestUploadFeedbackSucceed:nil];
        }
    } else {
        if ([(id)self.delegate respondsToSelector:@selector(feedbackLoader:didRequestUploadFeedbackFail:)]) {
            [self.delegate feedbackLoader:self didRequestUploadFeedbackFail:nil];
        }
    }
    [self end];
}

#pragma mark overrides
- (void)connectionDidFinishLoading:(NSURLConnection *)conn {
    [super connectionDidFinishLoading:conn];
    [self performSelectorInBackground:@selector(handleParseUploadFeedbackResponse:) withObject:self.data];
}

- (void)connection:(NSURLConnection *)conn didFailWithError:(NSError *)error {
    [super connection:conn didFailWithError:error];
	running = NO;
    
    if ([(id)self.delegate respondsToSelector:@selector(feedbackLoader:didRequestUploadFeedbackFail:)]) {
        [self.delegate feedbackLoader:self didRequestUploadFeedbackFail:[error description]];
    }
}

@end
