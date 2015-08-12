//
//  WeiBoAuthEngine.h
//  HappyGift
//
//  Created by Yuhui Zhang on 11-10-5.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol WeiBoAuthEngineDelegate 
@optional
- (void) storeCachedOAuthData: (NSString *) data forUsername: (NSString *) username;					//implement these methods to store off the creds returned by Twitter
- (NSString *) cachedOAuthDataForUsername: (NSString *) username;										//if you don't do this, the user will have to re-authenticate every time they run
- (void) oAuthConnectionFailedWithData: (NSData *) data; 
@end

@class OAToken;
@class OAConsumer;



@interface WeiBoAuthEngine : NSObject {
	NSObject <WeiBoAuthEngineDelegate> *_delegate;
	NSString	*_consumerSecret;
	NSString	*_consumerKey;
	NSURL		*_requestTokenURL;
	NSURL		*_accessTokenURL;
	NSURL		*_authorizeURL;
	
    NSString    *_userId;
    NSString    *_userName;
	
	NSString	*_pin;
	
	OAConsumer	*_consumer;
	OAToken		*_requestToken;
	OAToken		*_accessToken; 
}

@property (nonatomic, retain) NSString *userId;
@property (nonatomic, retain) NSString *userName;
@property (nonatomic, readwrite, retain) NSString *consumerSecret, *consumerKey;
@property (nonatomic, readwrite, retain) NSURL *requestTokenURL, *accessTokenURL, *authorizeURL;	
@property (nonatomic, readonly) BOOL OAuthSetup;

+ (WeiBoAuthEngine *) currentOAuthEngine;
+ (void)setCurrentOAuthEngine:(WeiBoAuthEngine *)engine;

+ (WeiBoAuthEngine *) OAuthEngineWithDelegate: (NSObject <WeiBoAuthEngineDelegate> *) delegate;
- (WeiBoAuthEngine *) initOAuthWithDelegate: (NSObject <WeiBoAuthEngineDelegate> *) delegate;
- (BOOL) isAuthorized;
- (void) signOut;
- (void) requestAccessToken;
- (void) requestRequestToken;
- (void) updateAccessToken;
- (void) clearAccessToken;

@property (nonatomic, readwrite, retain)  NSString	*pin;
@property (nonatomic, readonly) NSURLRequest *authorizeURLRequest;
@property (nonatomic, readonly) OAConsumer *consumer;
@property (nonatomic, readonly) OAToken		*requestToken;
@property (nonatomic, readonly) OAToken		*accessToken; 
@end
