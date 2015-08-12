//
//  HGLogging.m
//  HappyGift
//
//  Created by Zhang Yuhui on 2/18/11.
//  Copyright 2012 Ztelic Inc Inc. All rights reserved.
//

#import "HGLogging.h"

// current log level
#if defined (DEBUG_HAPPYGIFT)
static const HGLoggingLevel kHGLogLevel = HGLoggingLevelDebug;
#else
static const HGLoggingLevel kHGLogLevel = HGLoggingLevelInfo;
#endif
static const BOOL kDefaultMethodNameDisplay = YES;

// Logging Descriptions
static NSString * const kHGLogLevelUndefined = @"Undefined";
static NSString * const kHGLogLevelVerbose = @"Verbose";
static NSString * const kHGLogLevelDebug = @"Debug";
static NSString * const kHGLogLevelInfo = @"Info";
static NSString * const kHGLogLevelWarn = @"Warn";
static NSString * const kHGLogLevelError = @"Error";

@interface HGLogging()
+(NSString *) logDescritionBasedOnLogLevel:(HGLoggingLevel) level;
+(BOOL) logOutputString:(NSString *) logString;
@end


@implementation HGLogging

+(BOOL) performLog:(HGLoggingLevel) level file:(char*)sourceFile methodName:(NSString *) methodName lineNumber:(int)lineNumber format:(NSString*)format, ... {
    BOOL success = NO;
    if (level >= kHGLogLevel) {
        va_list ap;
        va_start(ap,format);
        NSString * fileName = [[[NSString alloc] initWithBytes:sourceFile length:strlen(sourceFile) encoding:NSUTF8StringEncoding] autorelease];
        NSString * printString = [[[NSString alloc] initWithFormat:format arguments:ap] autorelease];
        va_end(ap);
        NSString * displayMethodName = (kDefaultMethodNameDisplay) ? methodName : @"";
        NSString * logString = [NSString stringWithFormat:@"[%s:%@:%d] %@: %@",[[fileName lastPathComponent] UTF8String], 
                                displayMethodName, lineNumber, [[self class] logDescritionBasedOnLogLevel:level], printString];
        success = [[self class] logOutputString:logString];
    }
    return success;
}

+(BOOL) logOutputString:(NSString *) logString {
    NSLog(@"%@", logString);
    return YES;
}

+(NSString *) logDescritionBasedOnLogLevel:(HGLoggingLevel) level {
    NSString * description = kHGLogLevelUndefined;
    switch (level) {
        case HGLoggingLevelVerbose:
            description = kHGLogLevelVerbose;
            break;
        case HGLoggingLevelDebug:
            description = kHGLogLevelDebug;
            break;
        case HGLoggingLevelInfo:
            description = kHGLogLevelInfo;
            break;
        case HGLoggingLevelWarning:
            description = kHGLogLevelWarn;
            break;
        case HGLoggingLevelError:
            description = kHGLogLevelError;
            break;
        default:
            description = kHGLogLevelUndefined;
            break;
    }
    return description;
}


@end
