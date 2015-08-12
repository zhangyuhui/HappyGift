//
//  HGAccountLoader.m
//  HappyGift
//
//  Created by Zhang Yuhui on 02/09/12.
//  Copyright 2011 Ztelic Inc. All rights reserved.
//

#import "HGAccountLoader.h"
#import "JSON.h"
#import "HGNetworkHost.h"
#import "HGConstants.h"
#import "RenrenService.h"
#import "HappyGiftAppDelegate.h"
#import "HGLogging.h"
#import "NSString+Addition.h"
#import <sqlite3.h>
#import "HGRecipient.h"
#import "HGAccount.h"

#define kRequestTypeCreateAnonymousUser 0
#define kRequestTypeBindSNSUser         1
#define kRequestTypeUnbindSNSUser    2

@interface HGAccountLoader()
@end

@implementation HGAccountLoader
@synthesize delegate;
@synthesize running;

static NSString *kUserCreateAnonymousUserFormat = @"%@/gift/index.php?route=account/login&ignore_cookie=%@";

static NSString *kUserBindSNSUserFormat = @"%@/gift/index.php?route=account/bind_sns&network=%@&profile_id=%@&access_token=%@&expire_time=%u";

static NSString *kUserUnbindSNSUserFormat = @"%@/gift/index.php?route=account/unbind&profile_network=%d&profile_id=%@";
static NSString *kUserGlobalLogoutFormat = @"%@/gift/index.php?route=account/unbind&unbind_all=1";

- (void)dealloc {
    [super dealloc];
}

- (void)cancel {	
    [super cancel];
    running = NO;
}

- (void)requestNewUserIgnoreCookie: (BOOL)ignoreCookie{
    if (running){
        return;
    }
    [self cancel];
    running = YES;
    requestType = kRequestTypeCreateAnonymousUser;
    
    NSString* requestString = [NSString stringWithFormat:kUserCreateAnonymousUserFormat, 
                           [HappyGiftAppDelegate backendServiceHost], ignoreCookie == YES ? @"1" : @"0"];
    HGDebug(@"%@", requestString);
    NSURL* requestURL = [NSURL URLWithString:[requestString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [super requestByGet:requestURL];
}

- (void)requestBindRenrenUser:(HGAccount*)account andExpireTime:(NSUInteger)expireTime {
    if (running){
        return;
    }
    [self cancel];
    running = YES;
    requestType = kRequestTypeBindSNSUser;
    NSString* requestString;
    if ((account.renrenAuthToken != nil) && [account.renrenAuthToken isEqualToString:@""] == NO){
        NSMutableString* requestStringBuilder = [NSMutableString stringWithFormat:kUserBindSNSUserFormat, [HappyGiftAppDelegate backendServiceHost], @"2", account.renrenUserId, account.renrenAuthToken, expireTime];
        
        if (account.renrenAuthSecret && ![@"" isEqualToString:account.renrenAuthSecret]) {
            [requestStringBuilder appendFormat:@"&access_secret=%@", account.renrenAuthSecret];
        }
        requestString = requestStringBuilder;
    }else{
        requestString = [NSString stringWithFormat:kUserCreateAnonymousUserFormat, [HappyGiftAppDelegate backendServiceHost], @"0"];
    }
    HGDebug(@"%@", requestString);
    NSURL* requestURL = [NSURL URLWithString:[requestString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [super requestByGet:requestURL];
}

- (void)requestBindWeiboUser:(HGAccount*)account andExpireTime:(NSUInteger)expireTime {
    if (running){
        return;
    }
    [self cancel];
    running = YES;
    requestType = kRequestTypeBindSNSUser;
    NSString* requestString;
    if ((account.weiBoAuthToken != nil) && [account.weiBoAuthToken isEqualToString:@""] == NO){
        NSMutableString* requestStringBuilder = [NSMutableString stringWithFormat:kUserBindSNSUserFormat, [HappyGiftAppDelegate backendServiceHost], @"1", account.weiBoUserId, account.weiBoAuthToken, expireTime];
        
        if (account.weiBoAuthSecret && ![@"" isEqualToString: account.weiBoAuthSecret]) {
            [requestStringBuilder appendFormat:@"&access_secret=%@", account.weiBoAuthSecret];
        }
        requestString = requestStringBuilder;
    }else{
        requestString = [NSString stringWithFormat:kUserCreateAnonymousUserFormat, [HappyGiftAppDelegate backendServiceHost], @"0"];
    }
    HGDebug(@"%@", requestString);
    NSURL* requestURL = [NSURL URLWithString:[requestString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [super requestByGet:requestURL];
}

- (void)requestUnbindSNSUser:(int)networkId andProfileId:(NSString*)profileId {
    if (running){
        return;
    }
    [self cancel];
    running = YES;
    requestType = kRequestTypeUnbindSNSUser;
    unbindingNetworkId = networkId;
    NSString* requestString;
    
    if (networkId == NETWORK_ALL_SNS) {
        requestString = [NSString stringWithFormat:kUserGlobalLogoutFormat, [HappyGiftAppDelegate backendServiceHost]];
    } else {
        requestString = [NSString stringWithFormat:kUserUnbindSNSUserFormat, [HappyGiftAppDelegate backendServiceHost], networkId, profileId];
    }
    
    HGDebug(@"%@", requestString);
    NSURL* requestURL = [NSURL URLWithString:[requestString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [super requestByGet:requestURL];
}

- (void) handleUnbindSNSUserResponse {
    NSString* jsonString = [NSString stringWithData:self.data];  
    HGDebug(@"%@", jsonString);
    
    NSDictionary *jsonDictionary = nil;
    NSString* userId = nil;
    NSString* token = nil;
    @try {
        jsonDictionary = [jsonString JSONValue];
        NSString* error = [jsonDictionary objectForKey:@"error"];
        if (error && ![@"" isEqualToString:error]) {
            if ([(id)self.delegate respondsToSelector:@selector(accountLoader:didUserUnbindFail:withError:)]) {
                [self.delegate accountLoader:self didUserUnbindFail:unbindingNetworkId withError:error];
            }
            return;
        }
        
        int loggedOut = [[jsonDictionary objectForKey:@"logout"] intValue];
        if (loggedOut) {
            userId = [jsonDictionary objectForKey:@"user_id"];
            token = [jsonDictionary objectForKey:@"token"];
        }
    } @catch (NSException* e) {
        if ([(id)self.delegate respondsToSelector:@selector(accountLoader:didUserUnbindFail:withError:)]) {
            [self.delegate accountLoader:self didUserUnbindFail:unbindingNetworkId withError:e.description];
        }
    }

    if ([(id)self.delegate respondsToSelector:@selector(accountLoader:didUserUnbindSucceed:withNewUserId:andToken:)]) {
        [self.delegate accountLoader:self didUserUnbindSucceed:unbindingNetworkId withNewUserId:userId andToken:token];
    }
}

#pragma mark overrides
- (void)connectionDidFinishLoading:(NSURLConnection *)conn {
    [super connectionDidFinishLoading:conn];
    running = NO;
    NSString* jsonString = [NSString stringWithData:self.data];
    HGDebug(@"%@", jsonString);
    if (requestType == kRequestTypeCreateAnonymousUser){
        NSDictionary *jsonDictionary = [jsonString JSONValue];
        NSString* userId = [jsonDictionary objectForKey:@"user_id"];
        NSString* token = [jsonDictionary objectForKey:@"token"];
        if (userId == nil || token == nil){
            NSString* error = [jsonDictionary objectForKey:@"error"];
            if ([(id)self.delegate respondsToSelector:@selector(accountLoader:didUserCreateFail:)]) {
                [self.delegate accountLoader:self didUserCreateFail:error];
            }
        }else{
            if ([(id)self.delegate respondsToSelector:@selector(accountLoader:didUserCreateSucceed:userToken:)]) {
                [self.delegate accountLoader:self didUserCreateSucceed:userId userToken:token];
            }
        }
    }else if (requestType == kRequestTypeBindSNSUser){
        NSDictionary *jsonDictionary = [jsonString JSONValue];
        NSString* userId = [jsonDictionary objectForKey:@"user_id"];
        NSString* userToken = [jsonDictionary objectForKey:@"token"];
        if (userToken == nil || userToken == nil){
            NSString* error = [jsonDictionary objectForKey:@"error"];
            if ([(id)self.delegate respondsToSelector:@selector(accountLoader:didUserBindFail:)]) {
                [self.delegate accountLoader:self didUserBindFail:error];
            }
        }else{
            NSDictionary* userInfo = [jsonDictionary objectForKey:@"info"];
            NSString* userName = [userInfo objectForKey:@"name"];
            NSString* userEmail = [userInfo objectForKey:@"email"];
            NSString* userPhone = [userInfo objectForKey:@"phone"];
            if ([(id)self.delegate respondsToSelector:@selector(accountLoader:didUserBindSucceed:userToken:userName:userEmail:userPhone:)]) {
                [self.delegate accountLoader:self didUserBindSucceed:userId userToken:userToken userName:userName userEmail:userEmail userPhone:userPhone];
            }
        }
    } else if (requestType == kRequestTypeUnbindSNSUser) {
        [self handleUnbindSNSUserResponse];
    }
}

- (void)connection:(NSURLConnection *)conn didFailWithError:(NSError *)error {
    [super connection:conn didFailWithError:error];
	running = NO;
    if (requestType == kRequestTypeCreateAnonymousUser){
        if ([(id)self.delegate respondsToSelector:@selector(accountLoader:didUserCreateFail:)]) {
            [self.delegate accountLoader:self didUserCreateFail:[error description]];
        }
    } else if (requestType == kRequestTypeBindSNSUser) {
        if ([(id)self.delegate respondsToSelector:@selector(accountLoader:didUserBindFail:)]) {
            [self.delegate accountLoader:self didUserBindFail:[error description]];
        }
    } else if (requestType == kRequestTypeUnbindSNSUser) {
        if ([(id)self.delegate respondsToSelector:@selector(accountLoader:didUserUnbindFail:withError:)]) {
            [self.delegate accountLoader:self didUserUnbindFail:unbindingNetworkId withError:[error description]];
        }
    }
}
@end
