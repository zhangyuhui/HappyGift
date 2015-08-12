//
//  HGAccount.m
//  HappyGift
//
//  Created by Yuhui Zhang on 3/7/12.
//  Copyright (c) 2012 Ztelic Inc. All rights reserved.
//

#import "HGAccount.h"

@implementation HGAccount
@synthesize userId;
@synthesize userToken;
@synthesize userName;
@synthesize userPhone;
@synthesize userEmail;
@synthesize weiBoUserId;
@synthesize weiBoUserName;
@synthesize weiBoUserDescription;
@synthesize weiBoUserSignature;
@synthesize weiBoUserIcon;
@synthesize weiBoUserIconLarge;
@synthesize weiBoAuthToken;
@synthesize weiBoAuthSecret;
@synthesize weiBoAuthVerifier;
@synthesize weiboFavoriteCount;
@synthesize weiboStatusCount;
@synthesize weiboFollowersCount;
@synthesize weiboFriendsCount;
@synthesize weiboAuthExpireTime;

@synthesize renrenUserId;
@synthesize renrenUserName;
@synthesize renrenUserIcon;
@synthesize renrenUserIconLarge;
@synthesize renrenAuthToken;
@synthesize renrenAuthSecret;
@synthesize renrenAuthExpireTime;

- (void)dealloc {
    [userId release];
    [userToken release];
    [userName release];
    [userPhone release];
    [userEmail release];
    [weiBoUserId release];
    [weiBoUserName release];
    [weiBoAuthToken release];
    [weiBoAuthSecret release];
    [weiBoAuthVerifier release];
    [weiBoUserDescription release];
    [weiBoUserIcon release];
    [weiBoUserIconLarge release];
    [weiBoUserSignature release];
    
    [renrenUserId release];
    [renrenUserName release];
    [renrenUserIcon release];
    [renrenUserIconLarge release];
    [renrenAuthToken release];
    [renrenAuthSecret release];
    [super dealloc];
}
@end