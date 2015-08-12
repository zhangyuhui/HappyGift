//
//  HGNetworkConnection.h
//  HappyGift
//
//  Created by Yuhui Zhang on 5/10/10.
//  Copyright 2011 Ztelic Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString* const kHttpHeaderIfModifiedSince;
extern const int kHttpStatusCodeNotModified;

@interface HGNetworkConnection : NSObject{
    NSString *_uriFragment;
    NSMutableURLRequest *_request;
    NSURLConnection *_connection;
    NSData *_data;
    NSTimer *_timer;
    NSHTTPURLResponse *_response;
}

@property (nonatomic, retain, readonly) NSData *data;
@property (nonatomic, retain, readonly) NSHTTPURLResponse* response;

+ (id)networkConnection;

- (void)requestByGet:(NSURL *)url;
- (void)requestByGet:(NSURL *)url withHeaders:(NSDictionary *)headers;
- (void)requestByPost:(NSURL *)url bodyDictionary:(NSDictionary*)body;
- (void)requestByPost:(NSURL *)url bodyString:(NSString*)body;
- (void)cancel;
- (void)end;

- (void)connection:(NSURLConnection *)conn didFailWithError:(NSError *)error;
- (void)connectionDidFinishLoading:(NSURLConnection *)conn;
- (void)connectionDidReceiveResponse:(NSURLConnection *)conn response:(NSHTTPURLResponse*)response;
- (NSString*) getLastModifiedHeader;
@end
