//
//  HGRecipientLoader.m
//  HappyGift
//
//  Created by Yujian Weng on 12-5-18.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//

#import "HGRecipientLoader.h"
#import "JSON.h"
#import "HGNetworkHost.h"
#import "HGConstants.h"
#import "HGRecipient.h"
#import "HappyGiftAppDelegate.h"
#import "NSString+Addition.h"
#import <sqlite3.h>
#import "HGLogging.h"
#import "HGLoaderCache.h"

#define kRequestTypeRequestRecipients 0
#define kRequestTypePhoneContactsGetHash 1
#define kRequestTypePhoneContactsUpload 2

static NSString *kRecipientsRequestFormat = @"%@/gift/index.php?route=user/friends";
static NSString *kPhoneContactsGetHash = @"%@/gift/index.php?route=user/phone_contact/gethash";
static NSString *kPhoneContactsUpload = @"%@/gift/index.php?route=user/phone_contact/upload";

@interface HGRecipientLoader()
@end

@implementation HGRecipientLoader
@synthesize delegate;
@synthesize running;

- (void)dealloc {
    [super dealloc];
}

- (void)cancel {	
    [super cancel];
    running = NO;
}

- (void)requestRecipients {
    if (running){
        return;
    }
    [self cancel];
    requestType = kRequestTypeRequestRecipients;
    running = YES;
    
    NSString* requestString = [NSString stringWithFormat:kRecipientsRequestFormat, [HappyGiftAppDelegate backendServiceHost]];
    HGDebug(@"%@", requestString);
    NSURL* requestURL = [NSURL URLWithString:[requestString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    NSMutableDictionary* headers = nil;
    NSString* lastModifiedTime = [self getLastModifiedTimeOfRecipients];
    
    if (lastModifiedTime) {
        headers = [NSMutableDictionary dictionaryWithObject:lastModifiedTime forKey:kHttpHeaderIfModifiedSince];
    }
    
    [super requestByGet:requestURL withHeaders:headers];
}

- (void)requestPhoneContactsHash {
    if (running) {
        return;
    }
    [self cancel];
    requestType = kRequestTypePhoneContactsGetHash;
    running = YES;
    
    NSString* requestString = [NSString stringWithFormat:kPhoneContactsGetHash, [HappyGiftAppDelegate backendServiceHost]];
    HGDebug(@"%@", requestString);
    NSURL* requestURL = [NSURL URLWithString:[requestString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [super requestByGet:requestURL];
}

- (void)uploadPhoneContacts:(NSString*)contactsJson {
    if (running) {
        return;
    }
    [self cancel];
    requestType = kRequestTypePhoneContactsUpload;
    running = YES;

    NSString* body = [NSString stringWithFormat:@"contacts=%@", contactsJson];

    NSString* requestString = [NSString stringWithFormat:kPhoneContactsUpload, [HappyGiftAppDelegate backendServiceHost]];
    HGDebug(@"%@", requestString);
    NSURL* requestURL = [NSURL URLWithString:[requestString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [super requestByPost:requestURL bodyString:[body stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
}

#pragma mark parsersf

- (void)handleParsePhoneContactsUploadResult:(NSData *) result {
    NSString* jsonString = [NSString stringWithData:self.data];
    
    int uploadNumber = 0;
    
    if (jsonString != nil && [jsonString isEqualToString:@""] == NO) {
        @try {
            NSDictionary *jsonDictionary = [jsonString JSONValue];
            if (jsonDictionary != nil){
                uploadNumber = [[jsonDictionary objectForKey:@"upload_num"] intValue];
            }
        }@catch (NSException* e) {
            HGDebug(@"Exception happened inside handleParsePhoneContactsUploadResult");
        }@finally {
        }
    }
    
    if (uploadNumber > 0) {
        if ([(id)self.delegate respondsToSelector:@selector(recipientLoader:didUploadPhoneContactsSucceed:)]) {
            [self.delegate recipientLoader:self didUploadPhoneContactsSucceed:nil];
        }
    } else {
        if ([(id)self.delegate respondsToSelector:@selector(recipientLoader:didUploadPhoneContactsFail:)]) {
            [self.delegate recipientLoader:self didUploadPhoneContactsFail:nil];
        }
    }
}

- (void)handleParsePhoneContactsGetHashData:(NSData *) hashData {
    NSString* jsonString = [NSString stringWithData:self.data];
    
    NSString* hash = nil;
    
    if (jsonString != nil && [jsonString isEqualToString:@""] == NO) {
        @try {
            NSDictionary *jsonDictionary = [jsonString JSONValue];
            if (jsonDictionary != nil){
                hash = [jsonDictionary objectForKey:@"hash"];
            }
        }@catch (NSException* e) {
            HGDebug(@"Exception happened inside handleParsePhoneContactsGetHashData");
        }@finally {
        }
    }
    if (hash) {
        if ([(id)self.delegate respondsToSelector:@selector(recipientLoader:didRequestPhoneContactsHashSucceed:)]) {
            [self.delegate recipientLoader:self didRequestPhoneContactsHashSucceed:hash];
        }
    } else {
        if ([(id)self.delegate respondsToSelector:@selector(recipientLoader:didRequestPhoneContactsHashFail:)]) {
            [self.delegate recipientLoader:self didRequestPhoneContactsHashFail:nil];
        }
    }
}

- (void)handleParseRecipientsData:(NSData *)recipientsData{
    NSAutoreleasePool * autoReleasePool = [[NSAutoreleasePool alloc] init];
    NSString* jsonString = [NSString stringWithData:self.data];

    NSArray* recipients = nil;
    HGDebug(@"handleParseRecipientsData: %@", jsonString);
    
    if (kHttpStatusCodeNotModified == [self.response statusCode]) {
    } else {
        if (jsonString != nil && [jsonString isEqualToString:@""] == NO){
            NSDictionary *jsonDictionary = [jsonString JSONValue];
            if (jsonDictionary != nil){
                recipients = [self parseRecipients:jsonDictionary];
            }
        }
        
        if (recipients && [recipients count] > 0) {
            NSString* lastModifiedField = [self getLastModifiedHeader];
            HGDebug(@"new recipients data - lastModified: %@", lastModifiedField);
            [self saveLastModifiedTimeOfRecipients:lastModifiedField];
        }
    }
    
    if (recipients != nil){
        [self performSelectorOnMainThread:@selector(handleNotifyRecipientsData:) withObject:[NSDictionary dictionaryWithObjectsAndKeys:recipients, @"recipients", nil] waitUntilDone:YES];
    }else{
        [self performSelectorOnMainThread:@selector(handleNotifyRecipientsData:) withObject:nil waitUntilDone:YES];
    }
    [autoReleasePool release];
}

- (void)handleNotifyRecipientsData:(NSDictionary*)recipientsData{
    running = NO;
    NSArray* recipients = [recipientsData objectForKey:@"recipients"];
    if (recipients != nil){
        if ([(id)self.delegate respondsToSelector:@selector(recipientLoader:didRequestRecipientsSucceed:)]) {
            [self.delegate recipientLoader:self didRequestRecipientsSucceed:recipients];
        }
    }else{
        if ([(id)self.delegate respondsToSelector:@selector(recipientLoader:didRequestRecipientsFail:)]) {
            [self.delegate recipientLoader:self didRequestRecipientsFail:nil];
        }
    }
    [self end];
}


-(NSArray*) parseRecipients:(NSDictionary*)jsonDictionary{
    NSMutableArray* recipients = [[[NSMutableArray alloc] init] autorelease];
    @try {
        NSArray* recipientsJsonArray = [jsonDictionary objectForKey:@"friends"];
        //NSString* error = [jsonDictionary objectForKey:@"error"];
        for (NSDictionary* recipientJsonDictionary in recipientsJsonArray){
            HGRecipient* recipient = [self parseRecipient:recipientJsonDictionary];
            [recipients addObject:recipient];
        }
        
    }@catch (NSException* e) {
        HGDebug(@"Exception happened inside parseRecipients");
    }@finally {
        
    }
    return recipients;
}

-(HGRecipient*)parseRecipient:(NSDictionary*)recipientJsonDictionary{
    HGRecipient* recipient = [[HGRecipient alloc] init];
    
    recipient.recipientName = [recipientJsonDictionary objectForKey:@"name"];
    recipient.recipientProfileId = [recipientJsonDictionary objectForKey:@"profile_id"];
    recipient.recipientNetworkId = [[recipientJsonDictionary objectForKey:@"network"] intValue];
    recipient.recipientImageUrl = [recipientJsonDictionary objectForKey:@"image"];
    recipient.recipientBirthday = [recipientJsonDictionary objectForKey:@"birthday"];
    
    return [recipient autorelease];
}

#pragma mark overrides
- (void)connectionDidFinishLoading:(NSURLConnection *)conn {
    [super connectionDidFinishLoading:conn];
    if (requestType == kRequestTypeRequestRecipients) {
        [self performSelectorInBackground:@selector(handleParseRecipientsData:) withObject:self.data];
    } else if (requestType == kRequestTypePhoneContactsGetHash) {
        [self handleParsePhoneContactsGetHashData:self.data];
        //[self performSelectorInBackground:@selector(handleParsePhoneContactsGetHashData:) withObject:self.data];
    } else if (requestType == kRequestTypePhoneContactsUpload) {
        [self handleParsePhoneContactsUploadResult:self.data];
      //  [self performSelectorInBackground:@selector(handleParsePhoneContactsUpload:) withObject:self.data];
    }
}

- (void)connection:(NSURLConnection *)conn didFailWithError:(NSError *)error {
    [super connection:conn didFailWithError:error];
	running = NO;
    
    if (requestType == kRequestTypeRequestRecipients) {
        if ([(id)self.delegate respondsToSelector:@selector(recipientLoader:didRequestRecipientsFail:)]) {
            [self.delegate recipientLoader:self didRequestRecipientsFail:[error description]];
        }
    } else if (requestType == kRequestTypePhoneContactsGetHash) {
        if ([(id)self.delegate respondsToSelector:@selector(recipientLoader:didRequestPhoneContactsHashFail:)]) {
            [self.delegate recipientLoader:self didRequestPhoneContactsHashFail:[error description]];
        }
    } else if (requestType == kRequestTypePhoneContactsUpload) {
        if ([(id)self.delegate respondsToSelector:@selector(recipientLoader:didUploadPhoneContactsFail:)]) {
            [self.delegate recipientLoader:self didUploadPhoneContactsFail:[error description]];
        }
    }
}

#pragma persistent response data

-(NSString*)getLastModifiedTimeOfRecipients {
    return [HGLoaderCache lastModifiedTimeForKey:kCacheKeyLastModifiedTimeOfRecipients];
}

-(void)saveLastModifiedTimeOfRecipients:(NSString*)lastModifiedTimeOfRecipients {
    [HGLoaderCache saveLastModifiedTime:lastModifiedTimeOfRecipients forKey:kCacheKeyLastModifiedTimeOfRecipients];
}


@end
