#import <Foundation/Foundation.h>
#import "WeiBoAuthEngine.h"
#import "OAToken.h"
#import "OAConsumer.h"
#import "OAMutableURLRequest.h"

#define API_FORMAT @"json"
#define API_DOMAIN	@"api.t.sina.com.cn"

extern NSString *TWITTERFON_FORM_BOUNDARY;

@interface WeiboConnection : NSObject
{
    NSString*           requestURL;
	NSURLConnection*    connection;
	NSMutableData*      respondData;
    int                 statusCode;
    BOOL                needAuth;
	WeiBoAuthEngine*		oauthEngine;
}

@property (nonatomic, readonly) NSMutableData* respondData;
@property (nonatomic, assign) int statusCode;
@property (nonatomic, copy) NSString* requestURL;

- (id)initWithOAuthEngine:(WeiBoAuthEngine *)engine;
- (void)get:(NSString*)URL;
- (void)post:(NSString*)aURL body:(NSString*)body;
- (void)post:(NSString*)aURL data:(NSData*)data;
- (void)cancel;

- (void)URLConnectionDidFailWithError:(NSError*)error;
- (void)URLConnectionDidFinishLoading:(NSString*)content;

@end
