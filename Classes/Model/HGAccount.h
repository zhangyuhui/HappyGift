//
//  HGAccount.h
//  HappyGift
//
//  Created by Yuhui Zhang on 3/7/12.
//  Copyright (c) 2012 Ztelic Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HGAccount: NSObject {
    NSString*  userId;
    NSString*  userToken;
    NSString*  userName;
    NSString*  userPhone;
    NSString*  userEmail;
    NSString*  weiBoUserId;
    NSString*  weiBoUserName;
    NSString*  weiBoUserDescription;
    NSString*  weiBoUserSignature;
    NSString*  weiBoUserIcon;
    NSString*  weiBoUserIconLarge;
    NSString*  weiBoAuthToken;
    NSString*  weiBoAuthSecret;
    NSString*  weiBoAuthVerifier;
    int        weiboFavoriteCount;
    int        weiboStatusCount;
    int        weiboFollowersCount;
    int        weiboFriendsCount;
    NSTimeInterval weiboAuthExpireTime;
    
    NSString*  renrenUserId;
    NSString*  renrenUserName;
    NSString*  renrenUserIcon;
    NSString*  renrenUserIconLarge;
    NSString*  renrenAuthToken;
    NSString*  renrenAuthSecret;
    NSTimeInterval  renrenAuthExpireTime;
}
@property (nonatomic, retain) NSString*  userId;
@property (nonatomic, retain) NSString*  userName;
@property (nonatomic, retain) NSString*  userPhone;
@property (nonatomic, retain) NSString*  userEmail;
@property (nonatomic, retain) NSString*  userToken;
@property (nonatomic, retain) NSString*  weiBoUserId;
@property (nonatomic, retain) NSString*  weiBoUserName;
@property (nonatomic, retain) NSString*  weiBoUserDescription;
@property (nonatomic, retain) NSString*  weiBoUserSignature;
@property (nonatomic, retain) NSString*  weiBoUserIcon;
@property (nonatomic, retain) NSString*  weiBoUserIconLarge;
@property (nonatomic, retain) NSString*  weiBoAuthToken;
@property (nonatomic, retain) NSString*  weiBoAuthSecret;
@property (nonatomic, retain) NSString*  weiBoAuthVerifier;
@property (nonatomic, assign) int        weiboFavoriteCount;
@property (nonatomic, assign) int        weiboStatusCount;
@property (nonatomic, assign) int        weiboFollowersCount;
@property (nonatomic, assign) int        weiboFriendsCount;
@property (nonatomic, assign) NSTimeInterval weiboAuthExpireTime;

@property (nonatomic, retain) NSString*  renrenUserId;
@property (nonatomic, retain) NSString*  renrenUserName;
@property (nonatomic, retain) NSString*  renrenUserIcon;
@property (nonatomic, retain) NSString*  renrenUserIconLarge;
@property (nonatomic, retain) NSString*  renrenAuthToken;
@property (nonatomic, retain) NSString*  renrenAuthSecret;
@property (nonatomic, assign) NSTimeInterval renrenAuthExpireTime;

@end
