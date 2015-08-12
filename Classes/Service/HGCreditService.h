//
//  HGCreditService.h
//  HappyGift
//
//  Created by Zhang Yuhui on 12-6-6.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HGCreditLoader;
@class HGRecipient;
@protocol HGCreditServiceDelegate;

typedef enum {
    HGCreditInvitationTypeEmail = 0,
    HGCreditInvitationTypeMessage,
    HGCreditInvitationTypeWeibo,
    HGCreditInvitationTypeRenren,
} HGCreditInvitationType;

@interface HGCreditService : NSObject {
    int creditTotal;
    BOOL invited;
    NSArray* creditHistories;
    HGCreditLoader* creditLoader;
    id<HGCreditServiceDelegate> delegate;
}
@property (nonatomic, readonly) int creditTotal;
@property (nonatomic, readonly) BOOL invited;
@property (nonatomic, readonly) NSArray* creditHistories;
@property (nonatomic, assign) id<HGCreditServiceDelegate> delegate;

+ (HGCreditService*)sharedService;
+ (void)killService;

- (void)requestInvitation:(HGRecipient*)recipient type:(HGCreditInvitationType)type;
- (void)requestCreditByInvitation:(NSString*)invitation;
- (void)requestCreditByShareApp;
- (void)requestCreditByShareOrder:(NSString*)orderId;

- (void)requestCreditTotal;
- (void)clearCreditTotal;

@end

@protocol HGCreditServiceDelegate <NSObject>
@optional
- (void)creditService:(HGCreditService *)creditService didRequestInvitationSucceed:(NSString*)invitation;
- (void)creditService:(HGCreditService *)creditService didRequestInvitationFail:(NSString*)error;

- (void)creditService:(HGCreditService *)creditService didRequestCreditByInvitationSucceed:(int)credit;
- (void)creditService:(HGCreditService *)creditService didRequestCreditByInvitationFail:(NSString*)error;
@end


