//
//  HGImageService.m
//  HappyGift
//
//  Created by Zhang Yuhui on 8/24/10.
//  Copyright 2011 Ztelic Inc Inc. All rights reserved.
//

#import "HGImageService.h"
#import "HGConstants.h"
#import <sqlite3.h>
#import "HGLogging.h"

static HGImageService* imageService = nil;

#define MAX_IMAGE_DATA_NUM 1000
#define IMAGE_EXPIRE_INTERVAL (3600*24*30)

#define kImageCacheCountMax 10

static NSString *kImageHistoryDBFilename = @"ImageHistory.sqlite";
static sqlite3  *kImageHistoryDB = nil;

static NSString *kImageHistoryDBCreateFormat = @"CREATE TABLE IF NOT EXISTS ImageHistory (url TEXT, timestamp INTEGER, image BLOB)";
static NSString *kImageHistoryDBIndexFormat =  @"CREATE INDEX IF NOT EXISTS ImageHistory ON ImageHistory (url)";
static NSString *kImageHistorySQLQueryFormat  = @"SELECT image, timestamp FROM ImageHistory WHERE url = ?";
static NSString *kImageHistorySQLQueryCountFormat  = @"SELECT count(*) FROM ImageHistory WHERE url = ?";
static NSString *kImageHistorySQLInsertFormat = @"INSERT INTO ImageHistory (url, timestamp, image) VALUES (?, ?, ?)";
static NSString *kImageHistorySQLUpdateFormat = @"UPDATE ImageHistory SET timestamp = ?, image= ? WHERE url = ?";

static NSString *kImageHistorySQLDeleteFormat = @"DELETE FROM ImageHistory WHERE timestamp < ?";


@implementation HGImageData
@synthesize url;
@synthesize image;
@synthesize data;
-(void)dealloc{
    [url release];
    [image release];
    [data release];
    [super dealloc];
}
@end


@interface HGImageLoadingOperation : NSOperation {
	HGImageService* service;
    NSString* url;
    id        target;
    SEL       selector;
}
@property (nonatomic, readonly) id target;
@property (nonatomic, readonly) SEL selector;
@end

@implementation HGImageLoadingOperation
@synthesize target;
@synthesize selector;

- (id)initWithURL:(NSString *)theURL loader:(HGImageService*)theService target:(id)theTarget selector:(SEL)theSelector{
    self = [super init]; 
    if (self) {
		service = [theService retain];
        url = [theURL retain]; 
        target = [theTarget retain];
        selector = theSelector; 
    }
    return self;
}

- (void)dealloc{
	[service release];
	[target release];
	[url release]; 
	[super dealloc];
}

- (void)main{
    NSURL* imageURL = [NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    NSHTTPURLResponse* response = nil;
    NSError* error = nil;
    [request setURL:imageURL];
    //[request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPMethod:@"GET"];
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    [request release];
    if (error != nil && error != NULL) {
        HGWarning(@"response error: %@\n data is %@ for url:%@", error, data ? @"not nil" : @"nil", url);
    }
    
    if (data) {
        NSUInteger dataSize = [data length];
        if (dataSize > 500000) {
            HGWarning(@"large image size: %u of %@", dataSize, url);
        }
        
        NSString* contentLengthHeader = [[response allHeaderFields] objectForKey:@"Content-Length"];
        int contentLength = [contentLengthHeader intValue];
        if (contentLength > 0 && contentLength != dataSize) {
            HGWarning(@"data size(%u) differ from Content-Length(%u) of %@", dataSize, contentLength, url);
            data = nil;
        }
    }
    
    UIImage *imageObject = data ? [[UIImage alloc] initWithData:data] : nil;
    HGImageData* imageData = [[HGImageData alloc] init];
    imageData.url = url;
    imageData.image = imageObject;
    imageData.data = data;
    [service performSelectorOnMainThread:@selector(handleLoadedImageData:) withObject:imageData waitUntilDone:YES];
    [imageData release];
    [imageObject release];	
}
@end

@interface HGImageService(){
    
}
- (NSData*)loadHistory:(NSString*)url;    
- (BOOL)hasHistory:(NSString*)url;    
- (BOOL)saveHistory:(NSString*)url timestamp:(long long)timestamp image:(NSData*)image;
@end

@implementation HGImageService

+ (void)initialize {
    NSString *documentsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *dbPath = [documentsDir stringByAppendingPathComponent:kImageHistoryDBFilename];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:dbPath] == NO) {
		
		if ([fileManager createFileAtPath:dbPath contents:nil attributes:nil] == NO){
		}else {
			sqlite3_open([dbPath UTF8String], &kImageHistoryDB);
			
            sqlite3_exec(kImageHistoryDB, [kImageHistoryDBCreateFormat UTF8String], NULL, NULL, NULL);
            sqlite3_exec(kImageHistoryDB, [kImageHistoryDBIndexFormat UTF8String], NULL, NULL, NULL);
			
			sqlite3_close(kImageHistoryDB);
			kImageHistoryDB = nil;
        }
		
	}
}


+ (void)finalize {
    if (kImageHistoryDB != nil) {
        sqlite3_close(kImageHistoryDB);
        kImageHistoryDB = nil;
    }
}

+ (HGImageService*)sharedService{
    if (imageService == nil){
        imageService = [[HGImageService alloc] init];
    }
    return imageService;
}

- (id)init {
    if (self = [super init]) {
        if (kImageHistoryDB == nil) {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDir = [paths objectAtIndex:0];
            NSString *dbPath = [documentsDir stringByAppendingPathComponent:kImageHistoryDBFilename];
            
            if (sqlite3_open([dbPath UTF8String], &kImageHistoryDB) != SQLITE_OK) {
                sqlite3_close(kImageHistoryDB);
                kImageHistoryDB = nil;
            }
        }
        _imageLoadingArray = [[NSMutableArray alloc] init];
		_imageLoadedDictionary = [[NSMutableDictionary alloc] init];
		_imageLoadingOpertionDictionary = [[NSMutableDictionary alloc] init];
		_imageLoadingOpertionQueue = [[NSOperationQueue alloc] init];
		[_imageLoadingOpertionQueue setMaxConcurrentOperationCount:10];
        _imageStoreCondition = [[NSCondition alloc] init];
    }
    
    return self;
}

- (void)dealloc {
	[_imageLoadingArray release];
	[_imageLoadedDictionary release];
	[_imageLoadingOpertionDictionary release];
	[_imageLoadingOpertionQueue release];
    [_imageStoreCondition release];
    [super dealloc];
}

- (UIImage*)requestImage:(NSString*)url{
	HGImageData* imageData = [_imageLoadedDictionary objectForKey:url];
	if (imageData == nil){
		NSURL* imageURL = [NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
		UIImage* imageObject = [[[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:imageURL]] autorelease];
		imageData = [[HGImageData alloc] init];
		imageData.url = url;
		imageData.image = imageObject;
		[_imageLoadedDictionary setObject:imageData forKey:url];
		[imageData release];
		return imageObject;
	}else{
		return imageData.image;
	}
}

- (HGImageData*)requestImage:(NSString*)url target:(id)target selector:(SEL)selector operationQueue:(NSOperationQueue*)queue {
	HGImageData* imageData = [_imageLoadedDictionary objectForKey:url];
	if (imageData == nil){
        if ([self hasHistory:url]){
            NSData* data = [self loadHistory:url];
            
            imageData = [[[HGImageData alloc] init] autorelease];
            imageData.url = url;
            imageData.data = data;
            
            UIImage* image = [[UIImage alloc] initWithData:data];
            imageData.image = image;
            [image release];
            
            return imageData;
        }
        
		if ([_imageLoadingArray containsObject:url] == NO){
			[_imageLoadingArray addObject:url];
			HGImageLoadingOperation *operation = [[HGImageLoadingOperation alloc] initWithURL:url loader:self target:target selector:selector]; 
			NSArray* operationArray = [_imageLoadingOpertionDictionary objectForKey:url];
			if (operationArray == nil){
				[_imageLoadingOpertionDictionary setObject:[NSArray arrayWithObject:operation] forKey:url];
			}else {
				NSMutableArray* newOperationArray = [NSMutableArray arrayWithArray:operationArray];
				[newOperationArray addObject:operation];
				[_imageLoadingOpertionDictionary setObject:newOperationArray forKey:url];
			}
			[queue addOperation:operation];
			[operation release]; 
		}else {
			HGImageLoadingOperation *operation = [[HGImageLoadingOperation alloc] initWithURL:url loader:self target:target selector:selector]; 
			NSArray* operationArray = [_imageLoadingOpertionDictionary objectForKey:url];
			if (operationArray == nil){
				[_imageLoadingOpertionDictionary setObject:[NSArray arrayWithObject:operation] forKey:url];
			}else {
				NSMutableArray* newOperationArray = [NSMutableArray arrayWithArray:operationArray];
				[newOperationArray addObject:operation];
				[_imageLoadingOpertionDictionary setObject:newOperationArray forKey:url];
			}
			[operation release]; 
		}
        return nil;
	}else {
        return imageData;
	}
}

- (UIImage*)requestImage:(NSString*)url target:(id)target selector:(SEL)selector{
	return [self requestImage:url target:target selector:selector operationQueue:_imageLoadingOpertionQueue].image;
}

- (HGImageData*)requestImageForRawData:(NSString*)url target:(id)target selector:(SEL)selector{
	return [self requestImage:url target:target selector:selector operationQueue:_imageLoadingOpertionQueue];
}

- (void)cancelImageData{
	[_imageLoadingOpertionQueue cancelAllOperations];
	[_imageLoadingArray removeAllObjects];
	[_imageLoadingOpertionDictionary removeAllObjects];
}

- (void)handleLoadedImageData:(HGImageData*)data{
	HGImageData* imageData = [data retain];
	if (imageData.image) {
		[_imageLoadedDictionary setObject:imageData forKey:imageData.url];
        long long timestamp = [NSDate timeIntervalSinceReferenceDate];
        [self saveHistory:imageData.url timestamp:timestamp image:imageData.data];
	}
	[_imageLoadingArray removeObject:imageData.url];
    
    if (imageData.image) {
        NSArray* operationArray = [_imageLoadingOpertionDictionary objectForKey:imageData.url];
        for (HGImageLoadingOperation* operation in operationArray){
            if(operation.target != nil && [operation.target respondsToSelector:operation.selector]){
                [operation.target performSelectorOnMainThread:operation.selector withObject:imageData waitUntilDone:NO];
            }
        }
    }
	[_imageLoadingOpertionDictionary removeObjectForKey:imageData.url];
	[imageData release];
}

- (void)clearImageData{
	[_imageLoadingOpertionQueue cancelAllOperations];
	[_imageLoadedDictionary removeAllObjects];
	[_imageLoadingArray removeAllObjects];
	[_imageLoadingOpertionDictionary removeAllObjects];
}

- (void)checkImageData{
    if ([_imageLoadedDictionary count] > kImageCacheCountMax){
        [_imageLoadedDictionary removeAllObjects];
    }
}

- (void)setSuspended:(BOOL)suspended{
	[_imageLoadingOpertionQueue setSuspended:suspended];
}

- (BOOL)isSuspended{
	return [_imageLoadingOpertionQueue isSuspended];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
	[_imageLoadedDictionary removeAllObjects];
}

#pragma mark history
- (NSData*)loadHistory:(NSString*)url{
    if (url == nil || [url isEqualToString:@""]){
        return nil;
    }
    [_imageStoreCondition lock];
    //const char *errmsg = nil;
	
	NSString *queryString = [NSString stringWithFormat:kImageHistorySQLQueryFormat];
    const char *querySQL = [queryString cStringUsingEncoding:NSUTF8StringEncoding];
    sqlite3_stmt *queryStmt;
    
    //long long timestamp = 0;
    NSData *imageData = nil;
	
	int prep = sqlite3_prepare_v2(kImageHistoryDB, querySQL, -1, &queryStmt, NULL);
    if(prep == SQLITE_OK) {
        sqlite3_bind_text(queryStmt, 1, [url UTF8String], -1, NULL);
		if(sqlite3_step(queryStmt) == SQLITE_ROW) {
            
            int bytes = sqlite3_column_bytes(queryStmt, 0);
			const void *value = sqlite3_column_blob(queryStmt, 0);
			if( value != NULL && bytes != 0 ){
				imageData = [NSData dataWithBytes:value length:bytes];
			}
            //timestamp = sqlite3_column_int(queryStmt, 1);
        }/*else {
			errmsg = sqlite3_errmsg(kImageHistoryDB);
		}*/
    }/*else {
        errmsg = sqlite3_errmsg(kImageHistoryDB);
    }*/
    
	sqlite3_reset(queryStmt);
    if (queryStmt) {
        sqlite3_finalize(queryStmt);
        queryStmt = nil;
    }
    [_imageStoreCondition unlock];
	return imageData;
}

- (BOOL)hasHistory:(NSString*)url{
    //const char *errmsg = nil;
    [_imageStoreCondition lock];
	NSString *queryCountString = kImageHistorySQLQueryCountFormat;
    const char *queryCountSQL = [queryCountString cStringUsingEncoding:NSUTF8StringEncoding];
    sqlite3_stmt *queryCountStmt;
    
    int queryCount = 0;
	int prep = sqlite3_prepare_v2(kImageHistoryDB, queryCountSQL, -1, &queryCountStmt, NULL);
    if(prep == SQLITE_OK) {
        sqlite3_bind_text(queryCountStmt, 1, [url UTF8String], -1, NULL);
        if(sqlite3_step(queryCountStmt) == SQLITE_ROW) {
            queryCount = sqlite3_column_int(queryCountStmt, 0);
        }/*else {
			errmsg = sqlite3_errmsg(kImageHistoryDB);
		}*/
    }/*else {
        errmsg = sqlite3_errmsg(kImageHistoryDB);
    }*/
    sqlite3_reset(queryCountStmt);
    if (queryCountStmt) {
        sqlite3_finalize(queryCountStmt);
        queryCountStmt = nil;
    }
    [_imageStoreCondition unlock];
    return (queryCount == 1);
}

- (BOOL)saveHistory:(NSString*)url timestamp:(long long)timestamp image:(NSData*)image{
    [_imageStoreCondition lock];
    const char *errmsg = nil;
	
	NSString *queryCountString = [NSString stringWithFormat:kImageHistorySQLQueryCountFormat];
    const char *queryCountSQL = [queryCountString cStringUsingEncoding:NSUTF8StringEncoding];
    sqlite3_stmt *queryCountStmt;
    
    int queryCount = 0;
	int prep = sqlite3_prepare_v2(kImageHistoryDB, queryCountSQL, -1, &queryCountStmt, NULL);
    if(prep == SQLITE_OK) {
        sqlite3_bind_text(queryCountStmt, 1, [url UTF8String], -1, NULL);
        if(sqlite3_step(queryCountStmt) == SQLITE_ROW) {
            queryCount = sqlite3_column_int(queryCountStmt, 0);
        }else {
			errmsg = sqlite3_errmsg(kImageHistoryDB);
		}
    }else {
        errmsg = sqlite3_errmsg(kImageHistoryDB);
    }
    sqlite3_reset(queryCountStmt);
    if (queryCountStmt) {
        sqlite3_finalize(queryCountStmt);
        queryCountStmt = nil;
    }
    
    if (queryCount == 0){
        const char *insertSQL = [kImageHistorySQLInsertFormat cStringUsingEncoding:NSUTF8StringEncoding];
        sqlite3_stmt *insertStmt = nil;
        int insertPrep = sqlite3_prepare_v2(kImageHistoryDB, insertSQL, -1, &insertStmt, nil);
        if (insertPrep == SQLITE_OK)  {
            sqlite3_bind_text(insertStmt, 1, [url UTF8String], -1, NULL);
            sqlite3_bind_int(insertStmt,  2, timestamp);
            sqlite3_bind_blob(insertStmt, 3, [image bytes], [image length], NULL);
           
            if (sqlite3_step(insertStmt) != SQLITE_DONE) {
                errmsg = sqlite3_errmsg(kImageHistoryDB);
            }
        }else {
            errmsg = sqlite3_errmsg(kImageHistoryDB);
        }
        sqlite3_reset(insertStmt);
        if (insertStmt) {
            sqlite3_finalize(insertStmt);
            insertStmt = nil;
        }
    }else{
        const char *updateSQL = [kImageHistorySQLUpdateFormat cStringUsingEncoding:NSUTF8StringEncoding];
        sqlite3_stmt *updateStmt = nil;
        int updatePrep = sqlite3_prepare_v2(kImageHistoryDB, updateSQL, -1, &updateStmt, nil);
        if (updatePrep == SQLITE_OK)  {
            sqlite3_bind_int(updateStmt,  1, timestamp);
            sqlite3_bind_blob(updateStmt, 2, [image bytes], [image length], NULL);
            sqlite3_bind_text(updateStmt, 3, [url UTF8String], -1, NULL);
            
            if (sqlite3_step(updateStmt) != SQLITE_DONE) {
                errmsg = sqlite3_errmsg(kImageHistoryDB);
            }
        }else {
            errmsg = sqlite3_errmsg(kImageHistoryDB);
        }
        sqlite3_reset(updateStmt);
        if (updateStmt) {
            sqlite3_finalize(updateStmt);
            updateStmt = nil;
        }
    }
    [_imageStoreCondition unlock];
    return (errmsg == NULL);
}

- (BOOL)clearAllHistory {
    [self clearImageData];
    return [self clearHistory:0];
}

- (BOOL)clearHistory {
    return [self clearHistory:IMAGE_EXPIRE_INTERVAL];
}

- (BOOL)clearHistory:(NSTimeInterval)expire {
    [_imageStoreCondition lock];
    const char *errmsg = nil;
    long long timestamp = [NSDate timeIntervalSinceReferenceDate]-expire;
	
	NSString *deleteString = kImageHistorySQLDeleteFormat;
    const char *deleteSQL = [deleteString cStringUsingEncoding:NSUTF8StringEncoding];
    sqlite3_stmt *deleteStmt;
    
	int prep = sqlite3_prepare_v2(kImageHistoryDB, deleteSQL, -1, &deleteStmt, NULL);
    if(prep == SQLITE_OK) {
        sqlite3_bind_int(deleteStmt, 1, timestamp);
        if(sqlite3_step(deleteStmt) != SQLITE_DONE) {
           errmsg = sqlite3_errmsg(kImageHistoryDB);
		}
    }else{
        errmsg = sqlite3_errmsg(kImageHistoryDB);
    }
    
    sqlite3_reset(deleteStmt);
    if (deleteStmt) {
        sqlite3_finalize(deleteStmt);
        deleteStmt = nil;
    }
    
    [_imageStoreCondition unlock];
    return (errmsg == NULL);
}



@end
