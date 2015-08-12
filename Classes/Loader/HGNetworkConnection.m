//
//  HGNetworkConnection.m
//  HappyGift
//
//  Created by Yuhui Zhang on 5/10/10.
//  Copyright 2011 Ztelic Inc. All rights reserved.
//

#import "HGNetworkConnection.h"
#import "HGNetworkHost.h"
#import "HGConstants.h"
#import "HappyGiftAppDelegate.h"
#import "HGLogging.h"

#define kNetworkConnectionTimeout 60.0

NSString* const kHttpHeaderIfModifiedSince = @"If-Modified-Since";
const int kHttpStatusCodeNotModified = 304;

@interface HGNetworkConnection (private)
- (void)handleHttpPost:(NSURL *)url bodyString:(NSString*)bodyString;
@end

@interface HGNetworkConnection ()
@property (nonatomic, retain) NSString *uriFragment;
@property (nonatomic, retain) NSURLConnection *connection;
@property (nonatomic, retain, readwrite) NSData *data;
@property (nonatomic, retain, readwrite) NSHTTPURLResponse* response;
@end

@implementation HGNetworkConnection

@synthesize uriFragment = _uriFragment, connection = _connection, data = _data, response = _response;


//- (id)init {
//    if (self = [super init]) {
//    }
//    
//    return self;
//}


+ (id)networkConnection {
    return [[[self alloc] init] autorelease];
}

- (void)requestByGet:(NSURL *)url {
    [self requestByGet:url withHeaders:nil];
}

- (void)requestByGet:(NSURL *)url withHeaders:(NSDictionary *)headers {
    HappyGiftAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    if (! appDelegate.networkReachable) {
        [appDelegate sendNotification:@"无法连接网络"];
		[self connection:self.connection didFailWithError:nil];
        return;
    }

#ifdef DEBUG_WEIZHI	
	//HGDebug(@"%@", url);
#endif
	
    NSArray *pathComponents = [[url path] componentsSeparatedByString:@"/"];
    self.uriFragment = [NSString stringWithFormat:@"/%@/", [pathComponents objectAtIndex:1]];
    
    [self cancel];
	
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request addValue:@"identity,gzip,deflate" forHTTPHeaderField:@"Accept-Encoding"];
    [request addValue:@"no-cache" forHTTPHeaderField:@"Cache-Control"];
    [request setTimeoutInterval:kNetworkConnectionTimeout];
    
    for (NSString* headerKey in headers) {
        NSString* headerValue = [headers objectForKey:headerKey];
        [request addValue:headerValue forHTTPHeaderField:headerKey];
    }
    
    if (_timer != nil){
        [_timer invalidate];
        _timer = nil;
    }
    _timer = [NSTimer scheduledTimerWithTimeInterval:kNetworkConnectionTimeout target:self selector:@selector(handleTimeout:) userInfo:nil repeats:NO];
    
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
    self.connection = conn;
    
    [conn release];
    [request release];
}

- (void)requestByPost:(NSURL *)url bodyString:(NSString*)body{
    HappyGiftAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    if (! appDelegate.networkReachable) {
        [appDelegate sendNotification:@"无法连接网络"];
		[self connection:self.connection didFailWithError:nil];
        return;
    }
	
    [self handleHttpPost:url bodyString:body];
}

- (void)requestByPost:(NSURL *)url bodyDictionary:(NSDictionary*)body{
    HappyGiftAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    if (! appDelegate.networkReachable) {
        [appDelegate sendNotification:@"无法连接网络"];
		[self connection:self.connection didFailWithError:nil];
        return;
    }
    
    NSEnumerator *keyEnumerator = [body keyEnumerator];
	NSString* dictKey;
	
    NSMutableString* bodyString = [NSMutableString stringWithCapacity:256];
	while ((dictKey = [keyEnumerator nextObject])) {
        if ([bodyString length] > 0){
            [bodyString appendFormat:@",\"%@\":\"%@\"", dictKey, [body objectForKey:dictKey]];
        }else{
            [bodyString appendFormat:@"\"%@\":\"%@\"", dictKey, [body objectForKey:dictKey]];
        }
        
    }
    
    [self handleHttpPost:url bodyString:bodyString];
}

- (void)handleHttpPost:(NSURL *)url bodyString:(NSString*)bodyString{
	
#ifdef DEBUG_WEIZHI	
	//HGDebug(@"%@", url);
#endif
	
    NSArray *pathComponents = [[url path] componentsSeparatedByString:@"/"];
    self.uriFragment = [NSString stringWithFormat:@"/%@/", [pathComponents objectAtIndex:1]];
    
    [self cancel];
	
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
	[request setHTTPMethod: @"POST"];
    
	[request setHTTPBody:[bodyString dataUsingEncoding: NSASCIIStringEncoding]];
    [request addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField: @"Content-Type"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request addValue:@"identity,gzip,deflate" forHTTPHeaderField:@"Accept-Encoding"];
    [request addValue:@"no-cache" forHTTPHeaderField:@"Cache-Control"];
    [request setTimeoutInterval:kNetworkConnectionTimeout];
    
    if (_timer != nil){
        [_timer invalidate];
        _timer = nil;
    }
    _timer = [NSTimer scheduledTimerWithTimeInterval:kNetworkConnectionTimeout target:self selector:@selector(handleTimeout:) userInfo:nil repeats:NO];
    
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
    self.connection = conn;
    
    [conn release];
    [request release];   
}


- (void)cancel {
    if (_timer != nil){
        [_timer invalidate];
        _timer = nil;
    }
    
    [self.connection cancel];
    self.connection = nil;
    self.data = nil;
    self.response = nil;
}

- (void)end{
    if (_timer != nil){
        [_timer invalidate];
        _timer = nil;
    }
    
    self.connection = nil;
    self.data = nil;  
    self.response = nil;
}


- (void)dealloc {
    self.uriFragment = nil;
    self.connection = nil;
    self.data = nil;
    self.response = nil;
    [super dealloc];
}

- (void)handleTimeout:(NSTimer*)timer{
    _timer = nil;
#ifdef DEBUG_WEIZHI    
    //HGDebug(@"Connection timeout");
#endif    
    [self connection:self.connection didFailWithError:[NSError errorWithDomain:@"Time out" code:256 userInfo:nil]]; 
}

#pragma mark NSURLConnection Delegate
- (void)connection:(NSURLConnection *)conn didReceiveResponse:(NSURLResponse *)theResponse {
    if ([theResponse isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *rsp = (NSHTTPURLResponse *)theResponse;
#ifdef DEBUG_WEIZHI	
        //HGDebug(@"%d", [rsp statusCode]);
        //HGDebug(@"%@", [rsp allHeaderFields]);
#endif
        
		switch ([rsp statusCode]) {
			case 200:
				break;
			case 401:
			case 407:
				break;
			default:
				break;
        }
        self.response = rsp;
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)theResponse;
        [self connectionDidReceiveResponse:_connection response:httpResponse];
    }
}


- (void)connection:(NSURLConnection *)conn didReceiveData:(NSData *)d {
    if (self.data == nil) {
        NSMutableData *md = [[NSMutableData alloc] initWithData:d];
        self.data = md;
        
        [md release];
    }
    else {
        [(NSMutableData *)self.data appendData:d];
    }
}

- (NSString*) getLastModifiedHeader {
    NSDictionary* headerFields = [self.response allHeaderFields];
    return [headerFields objectForKey:@"Last-Modified"];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)conn {
    if (_timer != nil){
        [_timer invalidate];
        _timer = nil;
    }
}


- (void)connection:(NSURLConnection *)conn didFailWithError:(NSError *)error {
    if (_timer != nil){
        [_timer invalidate];
        _timer = nil;
    }
}

- (void)connectionDidReceiveResponse:(NSURLConnection *)conn response:(NSHTTPURLResponse*)response{
}


@end
