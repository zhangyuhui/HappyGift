//
//  HGAccountLoader.h
//  HappyGift
//
//  Created by Zhang Yuhui on 02/09/12.
//  Copyright 2011 Ztelic Inc Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HGNetworkConnection.h"

@class HGAccount;
@protocol HGAccountLoaderDelegate;

@interface HGAccountLoader : HGNetworkConnection {
    BOOL running;
    int requestType;
    int unbindingNetworkId;
}
@property (nonatomic, assign)   id<HGAccountLoaderDelegate> delegate;
@property (nonatomic, readonly) BOOL  running;

- (void)requestNewUserIgnoreCookie:(BOOL)ignoreCookie;
- (void)requestBindRenrenUser:(HGAccount*)account andExpireTime:(NSUInteger)expireTime;
- (void)requestBindWeiboUser:(HGAccount*)account andExpireTime:(NSUInteger)expireTime;
- (void)requestUnbindSNSUser:(int)networkId andProfileId:(NSString*)profileId;

@end


@protocol HGAccountLoaderDelegate
- (void)accountLoader:(HGAccountLoader *)accountLoader didUserCreateSucceed:(NSString*)userId userToken:(NSString*)userToken;
- (void)accountLoader:(HGAccountLoader *)accountLoader didUserCreateFail:(NSString *)error;

- (void)accountLoader:(HGAccountLoader *)accountLoader didUserBindSucceed:(NSString*)userId userToken:(NSString*)userToken userName:(NSString*)userName userEmail:(NSString*)userEmail userPhone:(NSString*)userPhone;
- (void)accountLoader:(HGAccountLoader *)accountLoader didUserBindFail:(NSString *)error;

- (void)accountLoader:(HGAccountLoader *)accountLoader didUserUnbindSucceed:(int)networkId withNewUserId:(NSString*)userId andToken:(NSString*)token;
- (void)accountLoader:(HGAccountLoader *)accountLoader didUserUnbindFail:(int)networkId withError:(NSString *)error;
@end
