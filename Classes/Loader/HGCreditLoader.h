//
//  HGCreditLoader.h
//  HappyGift
//
//  Created by Yujian Weng on 12-6-11.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HGNetworkConnection.h"

@protocol HGCreditLoaderDelegate;

@interface HGCreditLoader : HGNetworkConnection {
    BOOL running;
    int  requestType;
}

@property (nonatomic, assign)   id<HGCreditLoaderDelegate> delegate;
@property (nonatomic, readonly) BOOL  running;

- (void)requestInvitation:(NSString*)contact type:(NSString*)type;
- (void)requestCreditByInvitation:(NSString*)invitation device:(NSString*)device;
- (void)requestCreditByShareApp:(NSString*)device;
- (void)requestCreditByShareOrder:(NSString*)orderId device:(NSString*)device;
- (void)requestCreditTotal;

- (NSArray*)creditHistories;
@end

@protocol HGCreditLoaderDelegate
- (void)creditLoader:(HGCreditLoader *)creditLoader didRequestInvitationSucceed:(NSString*)invitation;
- (void)creditLoader:(HGCreditLoader *)creditLoader didRequestInvitationFail:(NSString*)error;

- (void)creditLoader:(HGCreditLoader *)creditLoader didRequestCreditByInvitationSucceed:(int)credit;
- (void)creditLoader:(HGCreditLoader *)creditLoader didRequestCreditByInvitationFail:(NSString*)error;

- (void)creditLoader:(HGCreditLoader *)creditLoader didRequestCreditByShareAppSucceed:(int)credit;
- (void)creditLoader:(HGCreditLoader *)creditLoader didRequestCreditByShareAppFail:(NSString*)error;

- (void)creditLoader:(HGCreditLoader *)creditLoader didRequestCreditByShareOrderSucceed:(int)credit;
- (void)creditLoader:(HGCreditLoader *)creditLoader didRequestCreditByShareOrderFail:(NSString*)error;

- (void)creditLoader:(HGCreditLoader *)creditLoader didRequestCreditTotalSucceed:(int)credit histories:(NSArray*)histories invited:(BOOL)invited;
- (void)creditLoader:(HGCreditLoader *)creditLoader didRequestCreditTotalFail:(NSString*)error;
@end
