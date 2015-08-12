//
//  HGTweetCommentService.h
//  HappyGift
//
//  Created by Yujian Weng on 12-8-8.
//  Copyright 2012 Ztelic Inc. All rights reserved.
//

#import "HGTweetCommentService.h"
#import "HGConstants.h"
#import "HappyGiftAppDelegate.h"
#import "HGUtility.h"
#import "HGLogging.h"
#import "HGTweet.h"
#import "HGTweetComment.h"

static HGTweetCommentService* tweetCommentService;
static NSString* localDataPath = nil;

@interface HGTweetCommentService ()

- (NSString*) keyForTweet:(HGTweet*) tweet;
- (void) persistentTweetComments;
- (NSMutableDictionary*) loadTweetComments;

@end

@implementation HGTweetCommentService
@synthesize tweetComments;

+ (void)initialize {
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    localDataPath = [[[paths objectAtIndex:0] stringByAppendingPathComponent:@"LocalData"] retain];
}

+ (void)finalize {
    [localDataPath release];
}

+ (HGTweetCommentService*)sharedService {
    if (tweetCommentService == nil) {
        tweetCommentService = [[HGTweetCommentService alloc] init];
        tweetCommentService.tweetComments = [tweetCommentService loadTweetComments];
    }
    return tweetCommentService;
}

- (NSArray*) commentsToTweet:(HGTweet*)tweet {
    if (tweet == nil) {
        return nil;
    }
    NSString* tweetKey = [self keyForTweet:tweet];
    return [tweetComments objectForKey:tweetKey];
}

- (void) addComment:(HGTweetComment*)comment toTweet:(HGTweet*)tweet {
    if (tweet == nil || comment == nil) {
        return;
    }
    NSString* tweetKey = [self keyForTweet:tweet];
    NSArray* comments = [tweetComments objectForKey:tweetKey];
    NSMutableArray* newComments = [[NSMutableArray alloc] initWithObjects:comment, nil];
    if (comments) {
        [newComments addObjectsFromArray:comments];
    }
    
    if (tweetComments == nil) {
        tweetComments = [[NSMutableDictionary alloc] init];
    }
    [tweetComments setValue:newComments forKey:tweetKey];
    [newComments release];
    [self persistentTweetComments];
}

- (NSString*) keyForTweet:(HGTweet*) tweet {
    NSString* tweetKey = [NSString stringWithFormat:@"%d#%d#%@", tweet.tweetType, tweet.tweetNetwork, tweet.tweetId];
    return tweetKey;
}

- (void) persistentTweetComments {
    if ([tweetComments count] == 0) {
        return;
    }
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:localDataPath] == NO) {
        [[NSFileManager defaultManager] createDirectoryAtPath:localDataPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSString *cacheDataPath = [localDataPath stringByAppendingPathComponent:@"tweetComments"];
    NSData* cacheData = [NSKeyedArchiver archivedDataWithRootObject:tweetComments];
    [cacheData writeToFile:cacheDataPath atomically:YES];
}

- (NSMutableDictionary*) loadTweetComments {
    id result = nil;
    NSString *cacheDataPath = [localDataPath stringByAppendingPathComponent:@"tweetComments"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:cacheDataPath]) {
        NSData* cacheData = [NSData dataWithContentsOfFile:cacheDataPath];
        result = [[[NSKeyedUnarchiver unarchiveObjectWithData:cacheData] retain] autorelease];
    }
    
    return result;
}

- (void)dealloc {
    [tweetComments release];
    [super dealloc];
}

@end
