//
//  HGVirtualGiftLoader.m
//  HappyGift
//
//  Created by Yujian Weng on 12-7-31.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//

#import "HGVirtualGiftLoader.h"
#import "JSON.h"
#import "HGNetworkHost.h"
#import "HGConstants.h"
#import "HappyGiftAppDelegate.h"
#import "HGLogging.h"
#import "NSString+Addition.h"
#import <sqlite3.h>
#import "HGLogging.h"
#import "HGUtility.h"
#import "HGGIFGift.h"

#define kRequestTypeSendVirtualGift 0
#define kRequestTypeRequestGIFGifts 1
#define kRequestTypeRequestGIFGiftsForCategory 2

static NSString *kSendVirtualGiftRequestFormat = @"%@/gift/index.php?route=user/notify/send_vgift&profile_network=%d&profile_id=%@&vgift_type=%@&vgift_tweet_id=%@&vgift_tweet_text=%@";

static NSString *kGetGIFGiftsRequestFormat = @"%@/gift/index.php?route=product/vgift/image&offset=0&count=9";
static NSString *kGetGIFGiftsForCategoryRequestFormat = @"%@/gift/index.php?route=product/vgift/image&cat=%@&offset=%d&count=%d";

@implementation HGVirtualGiftLoader
@synthesize delegate;
@synthesize running;

- (void)dealloc {
    [super dealloc];
}

- (void)cancel {	
    [super cancel];
    running = NO;
}

- (void)requestGIFGifts {
    if (running) {
        return;
    }
    [self cancel];
    requestType = kRequestTypeRequestGIFGifts;
    
    NSMutableString* requestString = [NSMutableString stringWithFormat:kGetGIFGiftsRequestFormat, [HappyGiftAppDelegate backendServiceHost]];
    
    HGDebug(@"%@", requestString);
    NSURL* requestURL = [NSURL URLWithString:[requestString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    [super requestByGet:requestURL];
}

- (void)requestGIFGiftsForCategory:(NSString*)category withOffset:(int)offset andCount:(int)count {
    if (running) {
        return;
    }
    [self cancel];
    requestType = kRequestTypeRequestGIFGiftsForCategory;
    
    NSMutableString* requestString = [NSMutableString stringWithFormat:kGetGIFGiftsForCategoryRequestFormat, [HappyGiftAppDelegate backendServiceHost], category, offset, count];
    
    HGDebug(@"%@", requestString);
    NSURL* requestURL = [NSURL URLWithString:[requestString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    [super requestByGet:requestURL];
}

- (void)requestSendVirtualGift:(int)profileNetwork andProfileId:(NSString*)profileId 
                      giftType:(NSString*)giftType giftId:(NSString*)giftId 
                       tweetId:(NSString*)tweetId tweetText:(NSString*)tweetText tweetPic:(NSString*)tweetPic {
    if (running) {
        return;
    }
    [self cancel];
    requestType = kRequestTypeSendVirtualGift;
    
    NSMutableString* requestString = [NSMutableString stringWithFormat:kSendVirtualGiftRequestFormat, [HappyGiftAppDelegate backendServiceHost], profileNetwork, profileId, giftType, tweetId, tweetText];
    if ([giftType isEqualToString:@"diy"]) {
        [requestString appendFormat:@"&vgift_tweet_pic=%@", tweetPic];
    } else {
        [requestString appendFormat:@"&vgift_id=%@", giftId];
    }
    
    HGDebug(@"%@", requestString);
    NSURL* requestURL = [NSURL URLWithString:[requestString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    [super requestByGet:requestURL];
}

#pragma mark parsers
- (void)handleGetGIFGiftsForCategoryResponse:(id)responseData {
    NSAutoreleasePool * autoReleasePool = [[NSAutoreleasePool alloc] init];
    NSDictionary* gifGifts = nil;
    
    NSString* jsonString = [NSString stringWithData:self.data];
    HGDebug(@"%@", jsonString);
    
    if (jsonString != nil && [jsonString isEqualToString:@""] == NO) {
        @try {
            NSDictionary *jsonDictionary = [jsonString JSONValue];
            if (jsonDictionary != nil){
                gifGifts = [self parseGIFGifts:jsonDictionary];
            }
        } @catch (NSException* e) {
            HGWarning(@"exception: %@, for %@", e, jsonString);
        } 
    }
    
    if (gifGifts != nil){
        [self performSelectorOnMainThread:@selector(handleNotifyGIFGiftsForCategoryData:) withObject:[NSDictionary dictionaryWithObjectsAndKeys:gifGifts, @"gifGifts", nil] waitUntilDone:YES];
    }else{
        [self performSelectorOnMainThread:@selector(handleNotifyGIFGiftsForCategoryData:) withObject:nil waitUntilDone:YES];
    }
    [autoReleasePool release];
}

- (void) handleNotifyGIFGiftsForCategoryData:(NSDictionary*) result {
    running = NO;
    
    NSDictionary* gifGifts  = [result objectForKey:@"gifGifts"];
    
    if (gifGifts != nil) {
        if ([(id)self.delegate respondsToSelector:@selector(virtualGiftLoader:didRequestGIFGiftsForCategorySucceed:)]) {
            [self.delegate virtualGiftLoader:self didRequestGIFGiftsForCategorySucceed:gifGifts];
        }
    } else {
        if ([(id)self.delegate respondsToSelector:@selector(virtualGiftLoader:didRequestGIFGiftsForCategorySucceed:)]) {
            [self.delegate virtualGiftLoader:self didRequestGIFGiftsForCategorySucceed:nil];
        }
    }
    
    [self end];
}

- (void)handleGetGIFGiftsResponse:(id)responseData {
    NSAutoreleasePool * autoReleasePool = [[NSAutoreleasePool alloc] init];
    NSMutableDictionary* gifGifts = nil;
    
    NSString* jsonString = [NSString stringWithData:self.data];
    HGDebug(@"%@", jsonString);
    
    if (jsonString != nil && [jsonString isEqualToString:@""] == NO) {
        @try {
            NSDictionary *jsonDictionary = [jsonString JSONValue];
            if (jsonDictionary != nil){
                NSDictionary* imagesObj = [jsonDictionary objectForKey:@"images"];
                gifGifts = [self parseGIFGifts:imagesObj];
            }
        } @catch (NSException* e) {
            HGWarning(@"exception: %@, for %@", e, jsonString);
        } 
    }
    
    if (gifGifts != nil){
        [self performSelectorOnMainThread:@selector(handleNotifyGIFGiftsData:) withObject:[NSDictionary dictionaryWithObjectsAndKeys:gifGifts, @"gifGifts", nil] waitUntilDone:YES];
    }else{
        [self performSelectorOnMainThread:@selector(handleNotifyGIFGiftsData:) withObject:nil waitUntilDone:YES];
    }
    [autoReleasePool release];
}

- (NSMutableDictionary*) parseGIFGifts:(NSDictionary*)imagesObj {
    NSMutableDictionary* gifGifts = [[NSMutableDictionary alloc] init];

    NSArray *keys = [imagesObj allKeys];
    int count = [keys count];
    for (int i = 0; i < count; ++i) {
        id key = [keys objectAtIndex: i];
        NSArray* images = [imagesObj objectForKey: key];
        NSMutableArray* gifts = [[NSMutableArray alloc] init];
        for (NSDictionary* image in images) {
            HGGIFGift* gifGift = [[HGGIFGift alloc] initWithGIFGiftJsonDictionary:image];
            [gifts addObject:gifGift];
            [gifGift release];
        }
        [gifGifts setValue:gifts forKey:key];
        [gifts release];
    }
    
    return [gifGifts autorelease];
}

- (void) handleNotifyGIFGiftsData:(NSDictionary*) result {
    running = NO;

    NSMutableDictionary* gifGifts  = [result objectForKey:@"gifGifts"];
    
    if (gifGifts != nil) {
        if ([(id)self.delegate respondsToSelector:@selector(virtualGiftLoader:didRequestGIFGiftsSucceed:)]) {
            [self.delegate virtualGiftLoader:self didRequestGIFGiftsSucceed:gifGifts];
        }
    } else {
        if ([(id)self.delegate respondsToSelector:@selector(virtualGiftLoader:didRequestGIFGiftsFail:)]) {
            [self.delegate virtualGiftLoader:self didRequestGIFGiftsFail:nil];
        }
    }

    [self end];
}

- (void)handleSendVirtualGiftResponse:(id)responseData {
    NSString* jsonString = [NSString stringWithData:responseData];
    HGDebug(@"%@", jsonString);
    
    NSDictionary* responseDictionary = [jsonString JSONValue];
    NSString* orderId = [NSString stringWithFormat:@"%d", [[responseDictionary objectForKey:@"v_order_id"] intValue]];
    if ([(id)self.delegate respondsToSelector:@selector(virtualGiftLoader:didRequestSendVirtualGiftSucceed:)]) {
        [self.delegate virtualGiftLoader:self didRequestSendVirtualGiftSucceed:orderId];
    }
}

#pragma mark overrides
- (void)connectionDidFinishLoading:(NSURLConnection *)conn {
    [super connectionDidFinishLoading:conn];
    if (requestType == kRequestTypeSendVirtualGift) {
        [self handleSendVirtualGiftResponse:self.data];
    } else if (requestType == kRequestTypeRequestGIFGifts) {
        [self performSelectorInBackground:@selector(handleGetGIFGiftsResponse:) withObject:self.data];
    } else if (requestType == kRequestTypeRequestGIFGiftsForCategory) {
        [self performSelectorInBackground:@selector(handleGetGIFGiftsForCategoryResponse:) withObject:self.data];
    }
}

- (void)connection:(NSURLConnection *)conn didFailWithError:(NSError *)error {
    [super connection:conn didFailWithError:error];
	running = NO;
    if (requestType == kRequestTypeSendVirtualGift) {
        if ([(id)self.delegate respondsToSelector:@selector(virtualGiftLoader:didRequestSendVirtualGiftFail:)]) {
            [self.delegate virtualGiftLoader:self didRequestSendVirtualGiftFail:[error description]];
        }
    } else if (requestType == kRequestTypeRequestGIFGifts) {
        if ([(id)self.delegate respondsToSelector:@selector(virtualGiftLoader:didRequestGIFGiftsFail:)]) {
            [self.delegate virtualGiftLoader:self didRequestGIFGiftsFail:[error description]];
        }
    } else if (requestType == kRequestTypeRequestGIFGiftsForCategory) {
        if ([(id)self.delegate respondsToSelector:@selector(virtualGiftLoader:didRequestGIFGiftsForCategoryFail:)]) {
            [self.delegate virtualGiftLoader:self didRequestGIFGiftsForCategoryFail:[error description]];
        }
    }
}

@end
