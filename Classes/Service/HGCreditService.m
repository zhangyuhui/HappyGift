//
//  HGCreditService.m
//  HappyGift
//
//  Created by Zhang Yuhui on 12-6-6.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//

#import "HGCreditService.h"
#import "HGCreditLoader.h"
#import "HGConstants.h"
#import "HGAccountService.h"
#import "HGRecipient.h"
#import "UIDevice+Addition.h"
#import "HappyGiftAppDelegate.h"

#define PREFERENCE_CREDIT_REDEEM_TIMESTAMP_DATA_FORMAT @"yyyy-MM-dd HH:mm:ss.SSSS"

static HGCreditService* creditService;

@interface HGCreditService () <HGCreditLoaderDelegate>

@end

@implementation HGCreditService
@synthesize delegate;
@synthesize creditTotal;
@synthesize invited;
@synthesize creditHistories;

+ (HGCreditService*)sharedService {
    if (creditService == nil) {
        creditService = [[HGCreditService alloc] init];
    }
    return creditService;
}

+ (void)killService{
    if (creditService != nil) {
        [creditService release];
        creditService = nil;
    }    
}

- (id)init{
    self = [super init];
    if (self){
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSNumber* preferneceKeyCreditTotal = [defaults objectForKey:kHGPreferneceKeyCreditTotal];
        if (preferneceKeyCreditTotal != nil){
            creditTotal = [preferneceKeyCreditTotal intValue];
        }else{
            creditTotal = 0;
        }
    }
    return self;
}

- (void)dealloc {
    [creditLoader release];
    [creditHistories release];
    [super dealloc];
}

- (void)requestInvitation:(HGRecipient*)recipient type:(HGCreditInvitationType)type{
    if (creditLoader != nil) {
        [creditLoader cancel];
    } else {
        creditLoader = [[HGCreditLoader alloc] init];
        creditLoader.delegate = self;
    }
    
    if (type == HGCreditInvitationTypeWeibo){
        [creditLoader requestInvitation:recipient.recipientProfileId type:@"weibo"];
    }else if (type == HGCreditInvitationTypeRenren){
        [creditLoader requestInvitation:recipient.recipientProfileId type:@"renren"];
    }else if (type == HGCreditInvitationTypeEmail){
        [creditLoader requestInvitation:recipient.recipientName type:@"email"];
    }else if (type == HGCreditInvitationTypeMessage){
        [creditLoader requestInvitation:recipient.recipientName type:@"sms"];
    }
}

- (void)requestCreditByInvitation:(NSString*)invitation{
    if (creditLoader != nil) {
        [creditLoader cancel];
    } else {
        creditLoader = [[HGCreditLoader alloc] init];
        creditLoader.delegate = self;
    }
    
    NSString* uniqueGlobalDeviceIdentifier = [[UIDevice currentDevice] uniqueGlobalDeviceIdentifier];
    [creditLoader requestCreditByInvitation:invitation device:uniqueGlobalDeviceIdentifier];
}

- (void)requestCreditByShareApp{
    if (creditLoader != nil) {
        [creditLoader cancel];
    } else {
        creditLoader = [[HGCreditLoader alloc] init];
        creditLoader.delegate = self;
    }
    
    NSString* uniqueGlobalDeviceIdentifier = [[UIDevice currentDevice] uniqueGlobalDeviceIdentifier];
    [creditLoader requestCreditByShareApp:uniqueGlobalDeviceIdentifier];
}

- (void)requestCreditByShareOrder:(NSString*)orderId{
    if (creditLoader != nil) {
        [creditLoader cancel];
    } else {
        creditLoader = [[HGCreditLoader alloc] init];
        creditLoader.delegate = self;
    }
    
    NSString* uniqueGlobalDeviceIdentifier = [[UIDevice currentDevice] uniqueGlobalDeviceIdentifier];
    [creditLoader requestCreditByShareOrder:orderId device:uniqueGlobalDeviceIdentifier];    
}

- (void)requestCreditTotal{
    if (creditLoader != nil) {
        [creditLoader cancel];
    } else {
        creditLoader = [[HGCreditLoader alloc] init];
        creditLoader.delegate = self;
    }
    
    [creditLoader requestCreditTotal];    
}

- (void)clearCreditTotal{
    creditTotal = 0;
    invited = NO;
    if (creditHistories != nil){
        [creditHistories release];
        creditHistories = nil;
    }
}

#pragma mark HGCreditLoaderDelegate
- (void)creditLoader:(HGCreditLoader *)creditLoader didRequestInvitationSucceed:(NSString*)invitation{
    if ([delegate respondsToSelector:@selector(creditService:didRequestInvitationSucceed:)]){
        [delegate creditService:self didRequestInvitationSucceed:invitation];
    }
}

- (void)creditLoader:(HGCreditLoader *)creditLoader didRequestInvitationFail:(NSString*)error {
    if ([delegate respondsToSelector:@selector(creditService:didRequestInvitationFail:)]){
        [delegate creditService:self didRequestInvitationFail:error];
    }
}

- (void)creditLoader:(HGCreditLoader *)creditLoader didRequestCreditByInvitationSucceed:(int)credit{
    if (credit > 0){
        creditTotal += credit;
        invited = YES;
    }
    if ([delegate respondsToSelector:@selector(creditService:didRequestCreditByInvitationSucceed:)]){
        [delegate creditService:self didRequestCreditByInvitationSucceed:credit];
    }
}

- (void)creditLoader:(HGCreditLoader *)creditLoader didRequestCreditByInvitationFail:(NSString*)error {
    if ([delegate respondsToSelector:@selector(creditService:didRequestCreditByInvitationFail:)]){
        [delegate creditService:self didRequestCreditByInvitationFail:error];
    }
}

- (void)creditLoader:(HGCreditLoader *)creditLoader didRequestCreditTotalSucceed:(int)theCreditTotal histories:(NSArray *)theCreditHistories invited:(BOOL)theInvited{
    creditTotal = theCreditTotal;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithInt:creditTotal] forKey:kHGPreferneceKeyCreditTotal];
    [defaults synchronize];
    
    if (creditHistories != nil){
        [creditHistories release];
        creditHistories = nil;
    }
    creditHistories = [theCreditHistories retain];
    
    invited = theInvited;
}

- (void)creditLoader:(HGCreditLoader *)creditLoader didRequestCreditTotalFail:(NSString*)error{
    
}

- (void)creditLoader:(HGCreditLoader *)creditLoader didRequestCreditByShareAppSucceed:(int)credit{
    
}

- (void)creditLoader:(HGCreditLoader *)creditLoader didRequestCreditByShareAppFail:(NSString*)error{
    
}

- (void)creditLoader:(HGCreditLoader *)creditLoader didRequestCreditByShareOrderSucceed:(int)credit{
    
}

- (void)creditLoader:(HGCreditLoader *)creditLoader didRequestCreditByShareOrderFail:(NSString*)error{
    
}
@end
