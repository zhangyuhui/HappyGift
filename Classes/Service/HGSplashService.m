//
//  HGSplashService.m
//  HappyGift
//
//  Created by Zhang Yuhui on 02/09/12.
//  Copyright 2011 Ztelic Inc. All rights reserved.
//

#import "HGSplashService.h"
#import "HGSplash.h"
#import "HGSplashLoader.h"
#import "HappyGiftAppDelegate.h"

#define kSplashServiceAnonymous  @"0000000000"

#define kSplashExpirationInterval  (60*60*1)

static HGSplashService* splashService = nil;
static NSString * splashServicesDataPath = nil;

@interface HGSplashService () <HGSplashLoaderDelegate>
- (void)saveData;
- (void)restoreData;
@end

@implementation HGSplashService
@synthesize splash;
@synthesize splashTimestamp;
@synthesize delegate;

+ (void)initialize {
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    splashServicesDataPath = [[[paths objectAtIndex:0] stringByAppendingPathComponent:@"HGSplashService"] retain];
    [[NSFileManager defaultManager] createDirectoryAtPath:splashServicesDataPath withIntermediateDirectories:YES attributes:nil error:nil];
}

+ (void)finalize {
    [splashServicesDataPath release];
}

+ (HGSplashService*)sharedService{
    if (splashService == nil){
        splashService = [[HGSplashService alloc] init];
    }
    return splashService;
}

- (id)init{
    self = [super init];
    if (self){
        [self restoreData];
        /*if (splash == nil){
            splash = [[HGSplash alloc] init];
            splash.title = @"女人珍藏！3个补气血食疗方法";
            splash.image = [UIImage imageNamed:@"splash_default.jpg"];
            splash.pubDate = @"0";
        }
        if (splashTimestamp == nil){
            splashTimestamp = [[NSDate dateWithTimeIntervalSince1970:0] retain];
        }*/
    }
    return self;
}

- (void)dealloc{
    [splash release];
    [splashLoader release];
    [splashTimestamp release];
    
    [super dealloc];
}

-(void)restoreData{
    NSString *splashDataPath = [splashServicesDataPath stringByAppendingPathComponent:@"splash"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:splashDataPath]) {
        NSData* splashData = [NSData dataWithContentsOfFile:splashDataPath];
        if (splash != nil){
            [splash release];
            splash = nil;
        }
        splash = [[NSKeyedUnarchiver unarchiveObjectWithData:splashData] retain];
    }
    NSString *splashTimestampDataPath = [splashServicesDataPath stringByAppendingPathComponent:@"splashTimestamp"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:splashTimestampDataPath]) {
        NSData* splashTimestampData = [NSData dataWithContentsOfFile:splashTimestampDataPath];
        if (splashTimestamp != nil){
            [splashTimestamp release];
            splashTimestamp = nil;
        }
        splashTimestamp = [[NSKeyedUnarchiver unarchiveObjectWithData:splashTimestampData] retain];
    }
}

-(void)saveData{
    if ([[NSFileManager defaultManager] fileExistsAtPath:splashServicesDataPath] == NO){
        [[NSFileManager defaultManager] createDirectoryAtPath:splashServicesDataPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *splashDataPath = [splashServicesDataPath stringByAppendingPathComponent:@"splash"];
    NSData* splashData = [NSKeyedArchiver archivedDataWithRootObject:splash];
    [splashData writeToFile:splashDataPath atomically:YES];
    
    NSString *splashTimestampDataPath = [splashServicesDataPath stringByAppendingPathComponent:@"splashTimestamp"];
    NSData* splashTimestampData = [NSKeyedArchiver archivedDataWithRootObject:splashTimestamp];
    [splashTimestampData writeToFile:splashTimestampDataPath atomically:YES];
}

- (void)checkUpdate{
    /*HappyGiftAppDelegate *appDelegate = (HappyGiftAppDelegate *)[[UIApplication sharedApplication] delegate];
    if ((appDelegate.networkReachable == YES) && (appDelegate.wifiReachable == YES)){
        NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:splashTimestamp];
        if (timeInterval > kSplashExpirationInterval){
            if (splashLoader == nil){
                splashLoader = [[HGSplashLoader alloc] init];
                splashLoader.delegate = self;
            }
            [splashLoader requestSplash];
        }
    }*/
}

- (void)handleSplashImageDownload:(HGSplash*)theSplash{
    HGSplash* theSplashForImageDownload = [theSplash retain];
    NSData *theSplashImageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:theSplashForImageDownload.url]];
    if (theSplashImageData != nil){
        theSplashForImageDownload.image = [UIImage imageWithData:theSplashImageData];
    }
    [self performSelectorOnMainThread:@selector(handleSplashImageStore:) withObject:theSplashForImageDownload waitUntilDone:YES];
    [theSplash release];
}

- (void)handleSplashImageStore:(HGSplash*)theSplash{
    if (theSplash.image != nil){
        self.splash = theSplash;
        self.splashTimestamp = [NSDate dateWithTimeIntervalSinceNow:0];
        [self saveData];
        if ([delegate respondsToSelector:@selector(splashService:didSplashSucceed:)]){
            [delegate splashService:self didSplashSucceed:theSplash];
        }
    }else{
        if ([self.delegate respondsToSelector:@selector(splashService:didSplashFail:)]) {
            [self.delegate splashService:self didSplashFail:nil];
        }
    }
}
 
#pragma mark　- HGSplashLoaderDelegate 
- (void)splashLoader:(HGSplashLoader *)theSplashLoader didRequestSucceed:(HGSplash*)theSplash{
    if ([theSplash.url isEqualToString:splash.url] == NO){
        [self performSelectorInBackground:@selector(handleSplashImageDownload:) withObject:theSplash];
    }else{
        if ([delegate respondsToSelector:@selector(splashService:didSplashFail:)]){
            [delegate splashService:self didSplashFail:nil];
        } 
    }
}

- (void)splashLoader:(HGSplashLoader *)theSplashLoader didRequestFail:(NSString*)error{
    if ([delegate respondsToSelector:@selector(splashService:didSplashFail:)]){
        [delegate splashService:self didSplashFail:error];
    }   
}
@end
