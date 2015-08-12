//
//  HGFriendRecommandationLoader.m
//  HappyGift
//
//  Created by Yujian Weng on 12-6-11.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//

#import "HGFriendRecommandationLoader.h"
#import "JSON.h"
#import "HGNetworkHost.h"
#import "HGConstants.h"
#import "HGGiftOrder.h"
#import "HappyGiftAppDelegate.h"
#import "HGLogging.h"
#import "NSString+Addition.h"
#import <sqlite3.h>
#import "HGFriendRecommandation.h"
#import "HGLoaderCache.h"
#import "HGLogging.h"
#import "HGUtility.h"
#import "HGRecipientService.h"

#define kRequestTypeRecommandation 0

static NSString *kRecommandationRequestFormat = @"%@/gift/index.php?route=interest/recommend_friend&fri_offset=%d&fri_num=%d";

@implementation HGFriendRecommandationLoader
@synthesize delegate;
@synthesize running;

- (void)dealloc {
    [super dealloc];
}

- (void)cancel {	
    [super cancel];
    running = NO;
}

- (void)requestFriendRecommandationWithOffset:(int)offset andCount:(int)count {
    if (running) {
        return;
    }
    [self cancel];
    requestType = kRequestTypeRecommandation;
    
    NSString* requestString = [NSString stringWithFormat:kRecommandationRequestFormat, [HappyGiftAppDelegate backendServiceHost], offset, count];
    
    if (![HGUtility wifiReachable]) {
        NSMutableString* newRequestString = [NSMutableString stringWithString:requestString];
        [newRequestString appendFormat:@"&with_detail=0"];
        requestString = newRequestString;
    }
    
    HGDebug(@"%@", requestString);
    NSURL* requestURL = [NSURL URLWithString:[requestString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    [super requestByGet:requestURL];
}

#pragma mark parsers
- (void)handleRecommandationResponse:(NSData*)RecommandationsData {
    NSAutoreleasePool * autoReleasePool = [[NSAutoreleasePool alloc] init];
    NSArray* recommandations = nil;

    NSString* jsonString = [NSString stringWithData:self.data];
    HGDebug(@"%@", jsonString);
    
    if (jsonString != nil && [jsonString isEqualToString:@""] == NO) {
        NSDictionary *jsonDictionary = [jsonString JSONValue];
        if (jsonDictionary != nil){
            recommandations = [self parseRecommandations:jsonDictionary];
        }
    }
    
    if (recommandations != nil){
        [self performSelectorOnMainThread:@selector(handleNotifyRecommandationData:) withObject:[NSDictionary dictionaryWithObjectsAndKeys:recommandations, @"recommandations", nil] waitUntilDone:YES];
    }else{
        [self performSelectorOnMainThread:@selector(handleNotifyRecommandationData:) withObject:nil waitUntilDone:YES];
    }
    
    [autoReleasePool release];
}

-(NSArray*) parseRecommandations:(NSDictionary*)jsonDictionary{
    NSMutableArray* recommandations = [[[NSMutableArray alloc] init] autorelease];
    @try {
        NSArray* recommandationsJsonArray = [jsonDictionary objectForKey:@"recommendation"];
        for (NSDictionary* recommandationDictionary in recommandationsJsonArray){
            HGFriendRecommandation * recommandation = [self parseRecommandation:recommandationDictionary];
            if (recommandation) {
                [recommandations addObject:recommandation];
            }
        }
        
    }@catch (NSException* e) {
        HGDebug(@"Exception happened inside parseRecommandations");
    }@finally {
        
    }
    return recommandations;
}

-(HGFriendRecommandation*) parseRecommandation:(NSDictionary*)recommandationDictionary{
    HGFriendRecommandation* recommandation = [[HGFriendRecommandation alloc] init];
    
    NSDictionary* friendDictionary = [recommandationDictionary objectForKey:@"friend"];
    recommandation.recipient = [self parseRecipient:friendDictionary];
    
    NSDictionary* giftDictionary = [recommandationDictionary objectForKey:@"product"];
    HGGift* gift = [[HGGift alloc] initWithProductJsonDictionary:giftDictionary];
    recommandation.gift = gift;
    [gift release];
    
    return [recommandation autorelease];
}

-(HGRecipient*) parseRecipient:(NSDictionary*) friendDictionary {
    HGRecipient* recipient = [[HGRecipient alloc] init];
    
    recipient.recipientProfileId = [friendDictionary objectForKey:@"id"];
    recipient.recipientNetworkId = [[friendDictionary objectForKey:@"network"] intValue];
    recipient.recipientName = [friendDictionary objectForKey:@"name"];
    recipient.recipientImageUrl = [friendDictionary objectForKey:@"profile_image"];
    
    HGRecipientService *recipientService = [HGRecipientService sharedService];
    
    [recipientService updateSNSRecipientWithDBData:recipient];
    
    if (nil == [recipientService getRecipientWithNetworkId:recipient.recipientNetworkId andProfileId:recipient.recipientProfileId]) {
        [recipientService addRecipient:recipient];
    }

    return [recipient autorelease];
}

- (void)handleNotifyRecommandationData:(NSDictionary*)result {
    running = NO;
    
    NSArray* recommandations  = [result objectForKey:@"recommandations"];
    
    if (recommandations != nil) {
        if ([(id)self.delegate respondsToSelector:@selector(friendRecommandationLoader:didRequestFriendRecommandationSucceed:)]) {
            [self.delegate friendRecommandationLoader:self didRequestFriendRecommandationSucceed:recommandations];
        }
    } else {
        if ([(id)self.delegate respondsToSelector:@selector(friendRecommandationLoader:didRequestFriendRecommandationFail:)]) {
            [self.delegate friendRecommandationLoader:self didRequestFriendRecommandationFail:nil];
        }
    }
    
    [self end];
}

#pragma mark overrides
- (void)connectionDidFinishLoading:(NSURLConnection *)conn {
    [super connectionDidFinishLoading:conn];
    if (requestType == kRequestTypeRecommandation) {
        [self performSelectorInBackground:@selector(handleRecommandationResponse:) withObject:self.data];
    }
}

- (void)connection:(NSURLConnection *)conn didFailWithError:(NSError *)error {
    [super connection:conn didFailWithError:error];
	running = NO;
    if (requestType == kRequestTypeRecommandation) {
        if ([(id)self.delegate respondsToSelector:@selector(friendRecommandationLoader:didRequestFriendRecommandationFail:)]) {
            [self.delegate friendRecommandationLoader:self didRequestFriendRecommandationFail:[error description]];
        }
    }
}

@end
