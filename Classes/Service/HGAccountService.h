//
//  HGAccountService.h
//  HappyGift
//
//  Created by Yuhui Zhang on 4/10/12.
//  Copyright (c) 2012 Ztelic Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HGAccount.h"

@class HGAccountLoader;
@protocol HGAccountServiceDelegate;

@interface HGAccountService : NSObject{
@private
    HGAccount* currentAccount;
    HGAccountLoader* accountLoader;
    HGAccountLoader* unbindSNSAccountLoader;
}
@property (nonatomic, retain) HGAccount* currentAccount; 
@property (nonatomic, assign) id<HGAccountServiceDelegate> delegate;

+ (HGAccountService*)sharedService;

- (void)createAccount;
- (void)bindRenrenAccount:(HGAccount*)account andExpireTime: (NSUInteger)expires;
- (void)bindWeiboAccount:(HGAccount*)account andExpireTime: (NSUInteger)expires;
- (void)unbindSNSAccount:(int)networkId andProfileId:(NSString*)profileId;

- (NSArray*)loadAccounts;
- (HGAccount*)getAccount:(NSString*)userId;
- (BOOL)addAccount:(HGAccount*)account;
- (BOOL)removeAccount:(NSString*)userId;
- (BOOL)updateAccount:(HGAccount*)account;
- (BOOL)hasSNSAccountLoggedIn;
- (BOOL)isAllSNSAccountLoggedIn;
- (void)localLogout:(int)networkId;
- (void)clearPersonalCache;

@end


@protocol HGAccountServiceDelegate<NSObject>
@optional
- (void)accountService:(HGAccountService *)accountService didAccountCreateSucceed:(HGAccount*)account;
- (void)accountService:(HGAccountService *)accountService didAccountCreateFail:(NSString*)error;
- (void)accountService:(HGAccountService *)accountService didAccountBindSucceed:(HGAccount*)account;
- (void)accountService:(HGAccountService *)accountService didAccountBindFail:(NSString*)error;
- (void)accountService:(HGAccountService *)accountService didAccountUnbindSucceed:(int)networkId withUpdatedAccount:(HGAccount*)updatedAccount;
- (void)accountService:(HGAccountService *)accountService didAccountUnbindFail:(int)networkId withError:(NSString*)error;
@end
