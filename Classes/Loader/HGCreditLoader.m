//
//  HGCreditLoader.m
//  HappyGift
//
//  Created by Yujian Weng on 12-6-11.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//

#import "HGCreditLoader.h"
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
#import "HGCreditHistory.h"

#define kRequestTypeInvitation 0
#define kRequestTypeCreditByInvitation 1
#define kRequestTypeCreditByShareApp   2
#define kRequestTypeCreditByShareOrder 3
#define kRequestTypeCreditTotal 4

static NSString *kInvitationRequestFormat = @"%@/gift/index.php?route=user/invite&contact=%@&contact_type=%@";
static NSString *kCreditByInvitationRequestFormat = @"%@/gift/index.php?route=user/notify/invited&invite_code=%@&udid=%@";
static NSString *kCreditByShareAppRequestFormat = @"%@/gift/index.php?route=user/notify/share_app";
static NSString *kCreditByShareOrderRequestFormat = @"%@/gift/index.php?route=user/notify/share_order&order_id=%@";
static NSString *kCreditTotalRequestFormat = @"%@/gift/index.php?route=user/credit";


#define CREDIT_TIMESTAMP_DATA_FORMAT @"yyyy-MM-dd HH:mm:ss"

@interface HGCreditLoader()
- (NSString*)getLastModifiedTimeOfCreditHistories;
- (NSArray*)loadCreditHistories;
- (void)saveCreditHistories:(NSArray*)creditHistories andCreditBanlance:(NSNumber*)creditBanlance andCreditIsInvited:(NSNumber*)creditIsInvited andLastModifiedTime:(NSString*)lastModifiedTimeOfCreditHistories;
@end 

@implementation HGCreditLoader
@synthesize delegate;
@synthesize running;

- (void)dealloc {
    [super dealloc];
}

- (void)cancel {	
    [super cancel];
    running = NO;
}

- (void)requestInvitation:(NSString*)contact type:(NSString*)type{
    if (running) {
        return;
    }
    [self cancel];
    requestType = kRequestTypeInvitation;
    NSString* requestString = [NSString stringWithFormat:kInvitationRequestFormat, [HappyGiftAppDelegate backendServiceHost], contact, type];
    HGDebug(@"%@", requestString);
    NSURL* requestURL = [NSURL URLWithString:[requestString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    [super requestByGet:requestURL];
}

- (void)requestCreditByInvitation:(NSString*)invitation device:(NSString*)device{
    if (running) {
        return;
    }
    [self cancel];
    requestType = kRequestTypeCreditByInvitation;
    NSString* requestString = [NSString stringWithFormat:kCreditByInvitationRequestFormat, [HappyGiftAppDelegate backendServiceHost], invitation, device];
    HGDebug(@"%@", requestString);
    NSURL* requestURL = [NSURL URLWithString:[requestString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    [super requestByGet:requestURL];
}

- (void)requestCreditByShareApp:(NSString*)device{
    if (running) {
        return;
    }
    [self cancel];
    requestType = kRequestTypeCreditByShareApp;
    NSString* requestString = [NSString stringWithFormat:kCreditByShareAppRequestFormat, [HappyGiftAppDelegate backendServiceHost]];
    HGDebug(@"%@", requestString);
    NSURL* requestURL = [NSURL URLWithString:[requestString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    [super requestByGet:requestURL];    
}

- (void)requestCreditByShareOrder:(NSString*)orderId device:(NSString*)device{
    if (running) {
        return;
    }
    [self cancel];
    requestType = kRequestTypeCreditByShareOrder;
    NSString* requestString = [NSString stringWithFormat:kCreditByShareOrderRequestFormat, [HappyGiftAppDelegate backendServiceHost], orderId];
    HGDebug(@"%@", requestString);
    NSURL* requestURL = [NSURL URLWithString:[requestString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    [super requestByGet:requestURL];       
}

- (void)requestCreditTotal{
    if (running) {
        return;
    }
    [self cancel];
    requestType = kRequestTypeCreditTotal;
    NSString* requestString = [NSString stringWithFormat:kCreditTotalRequestFormat, [HappyGiftAppDelegate backendServiceHost]];
    HGDebug(@"%@", requestString);
    NSURL* requestURL = [NSURL URLWithString:[requestString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    NSMutableDictionary* headers = nil;
    NSString* lastModifiedTime = [self getLastModifiedTimeOfCreditHistories];
    
    if (lastModifiedTime) {
        headers = [NSMutableDictionary dictionaryWithObject:lastModifiedTime forKey:kHttpHeaderIfModifiedSince];
    }
    
    [super requestByGet:requestURL withHeaders:headers]; 
}

#pragma mark parsers
- (void)handleCreditResponse:(NSData*)creditResponseData {
    NSAutoreleasePool * autoReleasePool = [[NSAutoreleasePool alloc] init];

    NSString* jsonString = [NSString stringWithData:creditResponseData];
    HGDebug(@"%@", jsonString);
    
    if (requestType == kRequestTypeInvitation) {
        NSString* invitation = nil;
        if (jsonString != nil && [jsonString isEqualToString:@""] == NO) {
            NSDictionary *jsonDictionary = [jsonString JSONValue];
            if (jsonDictionary != nil){
                invitation = [jsonDictionary objectForKey:@"invite_code"];
            }
        }
        
        if (invitation != nil){
            [self performSelectorOnMainThread:@selector(handleNotifyCreditResponse:) withObject:[NSDictionary dictionaryWithObjectsAndKeys:invitation, @"invitation", nil] waitUntilDone:YES];
        }else{
            [self performSelectorOnMainThread:@selector(handleNotifyCreditResponse:) withObject:nil waitUntilDone:YES];
        }
    }else if (requestType == kRequestTypeCreditByInvitation) {
        NSNumber* credit = nil;
        if (jsonString != nil && [jsonString isEqualToString:@""] == NO) {
            NSDictionary *jsonDictionary = [jsonString JSONValue];
            if (jsonDictionary != nil){
                credit = [jsonDictionary objectForKey:@"gain_credit"];
            }
        }
        
        if (credit != nil){
            [self performSelectorOnMainThread:@selector(handleNotifyCreditResponse:) withObject:[NSDictionary dictionaryWithObjectsAndKeys:credit, @"credit", nil] waitUntilDone:YES];
        }else{
            [self performSelectorOnMainThread:@selector(handleNotifyCreditResponse:) withObject:nil waitUntilDone:YES];
        }
    }else if (requestType == kRequestTypeCreditByShareApp) {
        NSNumber* credit = nil;
        if (jsonString != nil && [jsonString isEqualToString:@""] == NO) {
            NSDictionary *jsonDictionary = [jsonString JSONValue];
            if (jsonDictionary != nil){
                credit = [jsonDictionary objectForKey:@"balance"];
            }
        }
        
        if (credit != nil){
            [self performSelectorOnMainThread:@selector(handleNotifyCreditResponse:) withObject:[NSDictionary dictionaryWithObjectsAndKeys:credit, @"balance", nil] waitUntilDone:YES];
        }else{
            [self performSelectorOnMainThread:@selector(handleNotifyCreditResponse:) withObject:nil waitUntilDone:YES];
        }
    }else if (requestType == kRequestTypeCreditByShareOrder) {
        NSNumber* credit = nil;
        if (jsonString != nil && [jsonString isEqualToString:@""] == NO) {
            NSDictionary *jsonDictionary = [jsonString JSONValue];
            if (jsonDictionary != nil){
                credit = [jsonDictionary objectForKey:@"gain_credit"];
            }
        }
        
        if (credit != nil){
            [self performSelectorOnMainThread:@selector(handleNotifyCreditResponse:) withObject:[NSDictionary dictionaryWithObjectsAndKeys:credit, @"balance", nil] waitUntilDone:YES];
        }else{
            [self performSelectorOnMainThread:@selector(handleNotifyCreditResponse:) withObject:nil waitUntilDone:YES];
        }
    }else if (requestType == kRequestTypeCreditTotal) {
        NSMutableArray* creditHistories = nil;
        NSNumber* credit = nil;
        NSNumber* invited = nil;
        if (kHttpStatusCodeNotModified == [self.response statusCode]) {
            HGDebug(@"creditHistories Ids - got 304 not modifed");
            NSArray* theCreditHistories = [self loadCreditHistories];
            creditHistories = [[NSMutableArray alloc] initWithArray:theCreditHistories];
            credit = [self loadCreditBanlance];
            invited = [self loadCreditIsInvited];
        } else {
            if (jsonString != nil && [jsonString isEqualToString:@""] == NO) {
                NSDictionary *jsonDictionary = [jsonString JSONValue];
                if (jsonDictionary != nil){
                    credit = [jsonDictionary objectForKey:@"balance"];
                    invited = [jsonDictionary objectForKey:@"is_invited"];
                    NSArray* historiesArray = [jsonDictionary objectForKey:@"history"];
                    creditHistories = [[NSMutableArray alloc] init];
                    if (historiesArray != nil && [historiesArray count] > 0){
                        for (NSDictionary* historyDictionary in historiesArray){
                            NSString* identifier = [historyDictionary objectForKey:@"id"];
                            NSString* operation = [historyDictionary objectForKey:@"ops_type"];
                            NSString* gain = [historyDictionary objectForKey:@"gain_type"];
                            NSString* value = [historyDictionary objectForKey:@"credit_value"];
                            NSString* date = [historyDictionary objectForKey:@"date_added"];
                            
                            HGCreditType type;
                            if ([operation isEqualToString:@"gain"]){
                                if ([gain isEqualToString:@"1"]){
                                    type = HG_CREDIT_TYPE_GAIN_INVITE;
                                }else if ([gain isEqualToString:@"2"]){
                                    type = HG_CREDIT_TYPE_GAIN_SHARE_APP;
                                }else if ([gain isEqualToString:@"3"]){
                                    type = HG_CREDIT_TYPE_GAIN_SHARE_ORDER;
                                }else if ([gain isEqualToString:@"4"]){
                                    type = HG_CREDIT_TYPE_GAIN_PAY;
                                }else if ([gain isEqualToString:@"6"]){
                                    type = HG_CREDIT_TYPE_GAIN_REDEEM;
                                }else{
                                    continue;
                                }
                            }else if ([operation isEqualToString:@"consume"]){
                                type = HG_CREDIT_TYPE_CONSUME;
                            }else{
                                continue;
                            }
                                
                            HGCreditHistory* creditHistory = [[HGCreditHistory alloc] init];
                            creditHistory.identifier = identifier;
                            creditHistory.value = [value intValue];
                            creditHistory.type = type;
                            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                            [dateFormatter setDateFormat:CREDIT_TIMESTAMP_DATA_FORMAT];
                            creditHistory.date = [dateFormatter dateFromString:date];
                            [dateFormatter release];
                            [creditHistories addObject:creditHistory];
                            [creditHistory release];
                        }
                    }
                }
            }
            if (creditHistories != nil){
                NSString* lastModifiedField = [self getLastModifiedHeader];
                HGDebug(@"new creditHistories data - lastModified: %@, storing data", lastModifiedField);
                [self saveCreditHistories:creditHistories andCreditBanlance:credit andCreditIsInvited:invited andLastModifiedTime:lastModifiedField];
            }
        }
        
        if (creditHistories != nil){
            [self performSelectorOnMainThread:@selector(handleNotifyCreditResponse:) withObject:[NSDictionary dictionaryWithObjectsAndKeys:creditHistories, @"creditHistories", credit, @"credit", invited, @"invited", nil] waitUntilDone:YES];
            [creditHistories release];
        }else{
            [self performSelectorOnMainThread:@selector(handleNotifyCreditResponse:) withObject:nil waitUntilDone:YES];
        }
    }
    
    
    [autoReleasePool release];
}

- (void)handleNotifyCreditResponse:(NSDictionary*)creditResponseData{
    running = NO;
    if (requestType == kRequestTypeInvitation) {
        NSString* invitation = [creditResponseData objectForKey:@"invitation"];
        if (invitation != nil) {
            if ([(id)self.delegate respondsToSelector:@selector(creditLoader:didRequestInvitationSucceed:)]) {
                [self.delegate creditLoader:self didRequestInvitationSucceed:invitation];
            }
        } else {
            if ([(id)self.delegate respondsToSelector:@selector(creditLoader:didRequestInvitationFail:)]) {
                [self.delegate creditLoader:self didRequestInvitationFail:nil];
            }
        }
    }else if (requestType == kRequestTypeCreditByInvitation) {
        NSNumber* credit = [creditResponseData objectForKey:@"credit"];
        if (credit != nil) {
            if ([(id)self.delegate respondsToSelector:@selector(creditLoader:didRequestCreditByInvitationSucceed:)]) {
                [self.delegate creditLoader:self didRequestCreditByInvitationSucceed:[credit intValue]];
            }
        } else {
            if ([(id)self.delegate respondsToSelector:@selector(creditLoader:didRequestCreditByInvitationFail:)]) {
                [self.delegate creditLoader:self didRequestCreditByInvitationFail:nil];
            }
        }
    }else if (requestType == kRequestTypeCreditByShareApp) {
        NSNumber* credit = [creditResponseData objectForKey:@"gain_credit"];
        if (credit != nil) {
            if ([(id)self.delegate respondsToSelector:@selector(creditLoader:didRequestCreditByShareAppSucceed:)]) {
                [self.delegate creditLoader:self didRequestCreditByShareAppSucceed:[credit intValue]];
            }
        } else {
            if ([(id)self.delegate respondsToSelector:@selector(creditLoader:didRequestCreditTotalFail:)]) {
                [self.delegate creditLoader:self didRequestCreditTotalFail:nil];
            }
        }
    }else if (requestType == kRequestTypeCreditByShareOrder) {
         NSNumber* credit = [creditResponseData objectForKey:@"gain_credit"];
         if (credit != nil) {
             if ([(id)self.delegate respondsToSelector:@selector(creditLoader:didRequestCreditByShareOrderSucceed:)]) {
                 [self.delegate creditLoader:self didRequestCreditByShareOrderSucceed:[credit intValue]];
             }
         } else {
             if ([(id)self.delegate respondsToSelector:@selector(creditLoader:didRequestCreditTotalFail:)]) {
                 [self.delegate creditLoader:self didRequestCreditTotalFail:nil];
             }
         }
    }else if (requestType == kRequestTypeCreditTotal) {
        NSArray* creditHistories = [creditResponseData objectForKey:@"creditHistories"];
        if (creditHistories != nil) {
            NSNumber* credit = [creditResponseData objectForKey:@"credit"];
            NSNumber* invited = [creditResponseData objectForKey:@"invited"];
            if ([(id)self.delegate respondsToSelector:@selector(creditLoader:didRequestCreditTotalSucceed:histories:invited:)]) {
                [self.delegate creditLoader:self didRequestCreditTotalSucceed:[credit intValue] histories:creditHistories invited:[invited boolValue]];
            }
        } else {
            if ([(id)self.delegate respondsToSelector:@selector(creditLoader:didRequestCreditTotalFail:)]) {
                [self.delegate creditLoader:self didRequestCreditTotalFail:nil];
            }
        }
    }
    [self end];
}

#pragma mark overrides
- (void)connectionDidFinishLoading:(NSURLConnection *)conn {
    [super connectionDidFinishLoading:conn];
    [self performSelectorInBackground:@selector(handleCreditResponse:) withObject:self.data];
}

- (void)connection:(NSURLConnection *)conn didFailWithError:(NSError *)error {
    [super connection:conn didFailWithError:error];
	running = NO;
    if (requestType == kRequestTypeInvitation) {
        if ([(id)self.delegate respondsToSelector:@selector(creditLoader:didRequestInvitationFail:)]) {
            [self.delegate creditLoader:self didRequestInvitationFail:[error description]];
        }
    }else if (requestType == kRequestTypeCreditByInvitation) {
        if ([(id)self.delegate respondsToSelector:@selector(creditLoader:didRequestCreditByInvitationFail:)]) {
            [self.delegate creditLoader:self didRequestCreditByInvitationFail:[error description]];
        }
    }else if (requestType == kRequestTypeCreditTotal) {
        if ([(id)self.delegate respondsToSelector:@selector(creditLoader:didRequestCreditTotalFail:)]) {
            [self.delegate creditLoader:self didRequestCreditTotalFail:[error description]];
        }
    }else if (requestType == kRequestTypeCreditByShareApp) {
        if ([(id)self.delegate respondsToSelector:@selector(creditLoader:didRequestCreditByShareAppFail:)]) {
            [self.delegate creditLoader:self didRequestCreditByShareAppFail:[error description]];
        }
    }else if (requestType == kRequestTypeCreditByShareOrder) {
        if ([(id)self.delegate respondsToSelector:@selector(creditLoader:didRequestCreditByShareOrderFail:)]) {
            [self.delegate creditLoader:self didRequestCreditByShareOrderFail:[error description]];
        }
    }
}

- (NSString*)getLastModifiedTimeOfCreditHistories {
    return [HGLoaderCache lastModifiedTimeForKey:kCacheKeyLastModifiedTimeOfCreditHistories];
}

- (NSArray*)loadCreditHistories {
    return [HGLoaderCache loadDataFromLoaderCache:@"creditHistories"];
}

- (NSNumber*)loadCreditBanlance {
    return [HGLoaderCache loadDataFromLoaderCache:@"creditBanlance"];
}

- (NSNumber*)loadCreditIsInvited {
    return [HGLoaderCache loadDataFromLoaderCache:@"creditIsInvited"];
}

- (void)saveCreditHistories:(NSArray*)creditHistories andCreditBanlance:(NSNumber*)creditBanlance andCreditIsInvited:(NSNumber*)creditIsInvited andLastModifiedTime:(NSString*)lastModifiedTimeOfCreditHistories {
    [HGLoaderCache saveDataToLoaderCache:creditHistories forKey:@"creditHistories"];
    [HGLoaderCache saveDataToLoaderCache:creditBanlance forKey:@"creditBanlance"];
    [HGLoaderCache saveDataToLoaderCache:creditIsInvited forKey:@"creditIsInvited"];
    [HGLoaderCache saveLastModifiedTime:lastModifiedTimeOfCreditHistories forKey:kCacheKeyLastModifiedTimeOfCreditHistories];
}

- (NSArray*)creditHistories {
    NSString* lastModifiedTime = [self getLastModifiedTimeOfCreditHistories];
    if (lastModifiedTime && ![@"" isEqualToString:lastModifiedTime]) {
        return [self loadCreditHistories];
    } else {
        return nil;
    }
}

@end
