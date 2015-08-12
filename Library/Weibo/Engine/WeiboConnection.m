//
//  Connection.m
//  TwitterFon
//
//  Created by kaz on 7/25/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import "WeiboConnection.h"
#import "WeiBoStringUtil.h"

#define NETWORK_TIMEOUT 5000.0

@implementation WeiboConnection

@synthesize respondData;
@synthesize statusCode;
@synthesize requestURL;

NSString *TWITTERFON_FORM_BOUNDARY = @"0194784892923";

- (id)initWithOAuthEngine:(WeiBoAuthEngine *)engine
{
	self = [super init];
    if (self){
        oauthEngine = [engine retain];
        statusCode = 0;
        needAuth = false;
    }
	return self;
}

- (void)dealloc
{
	[oauthEngine release];
    [requestURL release];
	[connection release];
	[respondData release];
	[super dealloc];
}


- (void)get:(NSString*)aURL
{
    [connection release];
	[respondData release];
    statusCode = 0;
    
    self.requestURL = aURL;
    
    NSString *URL = (NSString*)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)aURL, (CFStringRef)@"%", NULL, kCFStringEncodingUTF8);
    [URL autorelease];
	NSURL *finalURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@source=%@", 
											URL,
											([URL rangeOfString:@"?"].location != NSNotFound) ? @"&" : @"?" , 
											oauthEngine.consumerKey]];
	
	NSMutableURLRequest* req;
	OAMutableURLRequest* oaReq;
	if (needAuth) {
		oaReq = [[[OAMutableURLRequest alloc] initWithURL:finalURL
											   consumer:oauthEngine.consumer 
												  token:oauthEngine.accessToken 
												  realm: nil
									  signatureProvider:nil] autorelease];
		req = oaReq;
	}
	else {
		req = [NSMutableURLRequest requestWithURL:finalURL
									  cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
								  timeoutInterval:NETWORK_TIMEOUT];
	}
    [req setHTTPShouldHandleCookies:NO];
	
    if (needAuth){
		[oaReq prepare];
    }

 	respondData = [[NSMutableData data] retain];
	connection = [[NSURLConnection alloc] initWithRequest:req delegate:self];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

-(void)post:(NSString*)aURL body:(NSString*)body
{
    [connection release];
	[respondData release];
    statusCode = 0;
    
    self.requestURL = aURL;
    
    NSString *URL = (NSString*)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)aURL, (CFStringRef)@"%", NULL, kCFStringEncodingUTF8);
	[URL autorelease];
	NSURL *finalURL = [NSURL URLWithString:URL];
	NSMutableURLRequest* req;
	OAMutableURLRequest* oaReq;
	if (needAuth){
		oaReq = [[[OAMutableURLRequest alloc] initWithURL:finalURL
												 consumer:oauthEngine.consumer 
													token:oauthEngine.accessToken 
													realm: nil
										signatureProvider:nil] autorelease];
		req = oaReq;
	}else{
		req = [NSMutableURLRequest requestWithURL:finalURL
									  cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
								  timeoutInterval:NETWORK_TIMEOUT];
	}
    [req setHTTPMethod:@"POST"];
    [req setHTTPShouldHandleCookies:NO];
    [req setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];

    int contentLength = [body lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    
    [req setValue:[NSString stringWithFormat:@"%d", contentLength] forHTTPHeaderField:@"Content-Length"];
	NSString *finalBody = [NSString stringWithString:@""];
	if (body) {
		finalBody = [finalBody stringByAppendingString:body];
	}
	finalBody = [finalBody stringByAppendingString:[NSString stringWithFormat:@"%@source=%@", 
													(body) ? @"&" : @"?" , 
													oauthEngine.consumerKey]];
	
	[req setHTTPBody:[finalBody dataUsingEncoding:NSUTF8StringEncoding]];
    if (needAuth){
		[oaReq prepare];
    }
	
	respondData = [[NSMutableData data] retain];
	connection = [[NSURLConnection alloc] initWithRequest:req delegate:self];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

-(void)post:(NSString*)aURL data:(NSData*)data
{
    [connection release];
	[respondData release];
    statusCode = 0;

    self.requestURL = aURL;

    NSString *URL = (NSString*)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)aURL, (CFStringRef)@"%", NULL, kCFStringEncodingUTF8);
    [URL autorelease];
	NSURL *finalURL = [NSURL URLWithString:URL];
	NSMutableURLRequest* req;
	OAMutableURLRequest* oaReq;
	if (needAuth) {
		oaReq = [[[OAMutableURLRequest alloc] initWithURL:finalURL
												 consumer:oauthEngine.consumer 
													token:oauthEngine.accessToken 
													realm: nil
										signatureProvider:nil] autorelease];
		req = oaReq;
	}
	else {
		req = [NSMutableURLRequest requestWithURL:finalURL
									  cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
								  timeoutInterval:NETWORK_TIMEOUT];
	}
	NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", TWITTERFON_FORM_BOUNDARY];
    [req setHTTPShouldHandleCookies:NO];
    [req setHTTPMethod:@"POST"];
    [req setValue:contentType forHTTPHeaderField:@"Content-Type"];
    [req setValue:[NSString stringWithFormat:@"%d", [data length]] forHTTPHeaderField:@"Content-Length"];
    [req setHTTPBody:data];
    if (needAuth)
		[oaReq prepare];
	respondData = [[NSMutableData data] retain];
	connection = [[NSURLConnection alloc] initWithRequest:req delegate:self];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)cancel
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;    
    if (connection) {
        [connection cancel];
        [connection autorelease];
        connection = nil;
    }
}

- (void)connection:(NSURLConnection *)aConnection didReceiveResponse:(NSURLResponse *)aResponse
{
    NSHTTPURLResponse *resp = (NSHTTPURLResponse*)aResponse;
    if (resp) {
        statusCode = resp.statusCode;
    }
	[respondData setLength:0];
}

- (void)connection:(NSURLConnection *)aConn didReceiveData:(NSData *)data
{
	[respondData appendData:data];
}

- (void)connection:(NSURLConnection *)aConn didFailWithError:(NSError *)error
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
	[connection autorelease];
	connection = nil;
	[respondData autorelease];
	respondData = nil;
    
    [self URLConnectionDidFailWithError:error];
}

- (void)URLConnectionDidFailWithError:(NSError*)error
{
    // To be implemented in subclass
}

- (void)connectionDidFinishLoading:(NSURLConnection *)aConn
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    NSString* content = [[[NSString alloc] initWithData:respondData encoding:NSUTF8StringEncoding] autorelease];
    
    [self URLConnectionDidFinishLoading:content];

    [connection autorelease];
    connection = nil;
    [respondData autorelease];
    respondData = nil;
}

- (void)URLConnectionDidFinishLoading:(NSString*)content
{
    // To be implemented in subclass
}

@end
